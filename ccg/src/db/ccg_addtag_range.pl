#!/usr/bin/perl
#
#This script can be used to add a tag range for 1 or more data rows.
#
#See help section below and script comments for details.
#
#On error a message will be printed to screen and an exit with non zero return status.  Some errors may be logged.
#
#jwm - 5/16
#
use DBI;
use Getopt::Long;
use strict;
use warnings;

require "/ccg/src/db/ccg_utils.pl";
require "/ccg/src/db/ccg_dbutils.pl";
require "/ccg/src/db/ccg_dbutils2.pl";

#Variables with some defaults for optional arguements
my ($noerror,$i,@tmp,$dbh,$sql,$a);
my $data_num="";
my @data_nums=();
my $help="";
my $tag_num="";
my $comment="";
my $update=0;
my $description="Tag added via script";
my $count=0;
my $verbose=0;
my $productionDB=1;
my $prelim=0;
my $data_source=9; #Default to 9 which is generic added from this script.  see tag_createTagRange stored proc for details.
my $json={};#"";#(Optional)NOTE! Use with caution and test thouroughly with the php tag frontend to make sure it can read it. This is the 
#json criteria to be stored with the tag range.  Pass like this ccg_addtag_range.pl -d=21128,21130,21132 -t=3 -u --json ev_program=1 --json ev_site=244
#Passed keys must be cooridinated with the php frontend.  You should likely pass  --json doNotEdit=1 so the front end doesn't try to edit (unless you know what you're doing...)  caveat emptor
#
#Parse Arguments

if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(  "help|h"=>\$help,
		"data_num|d:s"=>\$data_num,
		"tag_num|t:i"=>\$tag_num,
		"comment|c:s"=>\$comment,
		"prelim|p:i"=>\$prelim,
		"update|u"=>\$update,
		"verbose|v"=>\$verbose,
		"productionDB:i"=>\$productionDB,
		"data_source:i"=>\$data_source,
		"json:s%"=>\$json);

if ( $noerror != 1 ) { exit; }
if ($help) { &showargs() }

if(!($data_num && $tag_num)){&showargs();exit;}

# Connect to Database
$dbh = &connect_db();
if(!$productionDB){demodb();}

#Create temp tables used by the stored proc.
dodml("create temporary table t_data_nums as select num from flask_data where 1=0",());
dodml("create temporary table t_event_nums as select num from flask_event where 1=0",());#This one isn't used by this script (currently), but is required by the proc

#Parse the 1+ data_nums passed and put into the temp table.
@data_nums=split(",",$data_num);
$sql="insert t_data_nums select ?";
foreach my $num (@data_nums){
	dodml($sql,($num));
}

#Verify they are all good numbers
$a=dosqlval("select count(*) from t_data_nums t left join flask_data d on d.num=t.num where d.num is null",());
if($a){&doError("Error: $a data_num(s) are not valid.");}

#See if any of the target rows already have the tag and remove if so.
$a=dodml("delete t from t_data_nums t, flask_data_tag_view v where t.num=v.data_num and v.tag_num=?",($tag_num));
if($a>0 && $verbose){
	my $t=($a==1)?"Skipping 1 row because it already has this tag.":"Skipping $a rows because they already have this tag.";
	print "$t\n";
}
$a=dodml("delete t from t_data_nums t, flask_event_tag_view v, flask_data_view d where d.data_num=t.num and d.event_num=v.event_num and v.tag_num=?",($tag_num));
if($a>0 && $verbose){
        my $t=($a==1)?"Skipping 1 row because it already has this tag.":"Skipping $a rows because they already have this tag.";
        print "$t\n";
}


#See if any of the target rows are not converted to the tag system yet and remove if so.
##Actually, now we'll allow these to be tagged too as the sp (below) can handle both.jwm 11/1/16
#$a=dodml("delete t from t_data_nums t, flask_data_view v where t.num=v.data_num and v.update_flag_from_tags=0",());
#if($a>0 && $verbose){
#	my $t=($a==1)?"Skipping 1 row because it has":"Skipping $a rows because they have";
#	print "$t not been converted to the tagging system yet.\n";
#}

#See how many data_nums are left
$a=dosqlval("select count(*) from t_data_nums");

if(!$update){
	print "$a row(s) to process.  Pass -u to do actual update\n\n";
	exit(0);
}

#Create the tag range.
if($a){
	if($verbose){print "Adding tag range for $a row(s).\n";}
	my $jsonCriteria="";
	#Parse any json criteria passed to the script and bundle pass to the sp.  If none passed, package the data_nums
	if(%$json){
		$jsonCriteria=arrayToJSON($json);
	}else{
		my @numArr=();
		$a=dosql("select num from t_data_nums",());
		foreach my $row (@{$a}){push(@numArr,$row->{qw(num)});}
		$jsonCriteria=arrayToJSON({"d_data_num"=>\@numArr});
       	}
	
	#`tag_createTagRange`(v_userid int,v_tag_num int, v_comment text,v_prelim tinyint,v_json_selection_criteria text,v_data_source int, v_description varchar(255), out v_status int,out v_mssg varchar(255),out v_numrows int,out v_range_num int) 
	#Note 48 is generic ccg user.
	if($comment){#We want comment to go in as a null when not present, but I had trouble getting it to bind hence the conditional switch here..
		dodml(q{call tag_createTagRange(48,?,?,?,?,?,?,@v_status,@v_mssg,@v_numrows,@v_range_num)},($tag_num,$comment,$prelim,$jsonCriteria,$data_source,$description));
	}else{
		dodml(q{call tag_createTagRange(48,?,null,?,?,?,?,@v_status,@v_mssg,@v_numrows,@v_range_num)},($tag_num,$prelim,$jsonCriteria,$data_source,$description));
	}

	#fetch the results
	$a=dosql(q{select @v_status as 'status',@v_mssg as 'message', @v_numrows as 'numrows', @v_range_num as range_num},());
	if($a){
		my $tmp=@{$a}[0];
		my($status,$message,$numrows,$range_num)=@{$tmp}{qw(status message numrows range_num)};
		
		if($status){#Some sort of error
			&doError("Error inserting tag: Status:$status Message:$message");
		}else{
			if($verbose){print $message."\n";}
		}
	}else{
		&doError("Unknown error calling tag insert procedure");
	}
}

# Disconnect from DB
#
&disconnect_db($dbh);
#


exit(0);

#######################################
# Subroutines
#######################################
#
sub doError(){
        my($msg)=@_;
        $msg="\n$msg\n\nParameters; data_num:$data_num tag_num:$tag_num prelim:$prelim comment:$comment.\n";
	#log error too.
	dodml(q{insert tag_entry_errors (data_num,user,comment) select ?,?,user()},($data_num,$msg));
	die $msg."Stopped at: ";
        #exit();
}
sub showargs()
{
	print 	"
#######################
ccg_addtag
#######################

This script can be used to add a new tag range.

If a passed flask_data row already has the passed tag or the row has not been converted to the tagging system, 
it will be skipped.

On success, this exits with a zero.  On error, a non-zero value.


Options:
-h, -help
	Produce help menu

-d, -data_num
	1 or more flask_data.num(s)  If passing multiple, comma delim (no spaces) like this:
	-d=123,345,567

-t, -tag_num
	tag_dictionary.num id for the tag/flag to add.  

-comment
	optional comment to write to the tag range (not flask_data.comment!)

-p, -prelim
	Default 0, pass 1 to mark the range as preliminary.

-u, -update
	pass to do actual update, if left off, we just print insert statement.

-v, -verbose

-productionDB (default 1)
	Pass 0 to use mund_dev.flask_data copy.  Pass 1 to use live production database.
	This is for dev purpurses
-json
	(optional) JSON criteria used for selection.  Can be used by php frontend for various display purposes.  See code comments in script for how to use.

-data_source (optiona) defaults to 9.  See mysql stored proc tag_createTagRange for details.
Examples:
   	ccg_addtag_range.pl -d=386529,38 -t=20 -u -v
	ccg_addtag_range.pl -d=386529 -t=10 -c='Flux dripping from capicitor' -u
";
   exit(1);
}

