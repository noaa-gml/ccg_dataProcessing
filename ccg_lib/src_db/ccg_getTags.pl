#!/usr/bin/perl
#
#This script can be used to fetch associated tag information for a passed flask_data row.
#
#See help section below and script comments for details.
#
#jwm - 6/17
#
use DBI;
use Getopt::Long;
use strict;
use warnings;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/ccg_dbutils2.pl";

#Variables with some defaults for optional arguements
my ($noerror,$i,@tmp,$dbh,$sql,$a);
my $event_num=0;
my $parameter="";
my $adate="";
my $atime="";
my $inst="";
my $data_num="";
my $help="";
my $productionDB=1;

#Parse Arguments

if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(  "help|h"=>\$help,
		"data_num|d:i"=>\$data_num,
		"event_num|e:i"=>\$event_num,
		"parameter|g:s"=>\$parameter,
		"adate:s"=>\$adate,
		"atime:s"=>\$atime,
		"inst:s"=>\$inst,
		"productionDB:i"=>\$productionDB);
if ( $noerror != 1 ) { exit; }
if ($help) { &showargs() }


#Either data_num or the 5 unique params to id row + flag or tag is required
if(!(($data_num || ($event_num && $parameter && $adate && $atime && $inst)))){&showargs();exit;}

# Connect to Database
$dbh = &connect_db();
if(!$productionDB){demodb();}

#Find unique data_num if not passed.
if(!($data_num)){
	#Note default string matches in our mysql db are not case sensitive, but we'll convert for clarity and 
	#future proofing.
	$parameter=lc($parameter);
	$inst=lc($inst);
	my @bind_values=($event_num,$parameter,$adate,$atime,$inst);
	$data_num=dosqlval(q{select data_num from flask_data_view where event_num=? and lower(parameter)=? and adate=? and atime=? and lower(inst)=?},@bind_values);
	if(!$data_num){
		&doError("Could not find unique row for passed parameters."); 
	}
}else{
	#Verify passed data_num is a good data_num
	$i=dosqlval("select count(*) from flask_data d where d.num=?",($data_num));
	if($i!=1){
		&doError("Error: passed data_num is not in flask_data!");
	}
}

if($data_num){
	#create and fill the ids temp table;
	dodml("create temporary table t_data_nums(index(num)) as select num from flask_data where num=?",($data_num));
	
	#make call to sp 
	dodml("call tag_getTagDetails",());

	#fetch the output
	my $out=dosqlval("select tag_details_formatted from t_tag_details where data_num=?",($data_num));#There will only be one, but doesn't hurt to qualify.

	if($out){print $out."\n";}	
}

# Disconnect from DB
#
&disconnect_db($dbh);
#


exit(0);

sub doError(){
        my($msg)=@_;
        $msg="\n$msg\n\nParameters; data_num:$data_num event_num:$event_num parameter:$parameter adate:$adate atime:$atime inst:$inst \n";
	die $msg."Stopped at: ";
}
sub showargs()
{
	print 	"
#######################
ccg_addtag
#######################

This script can be used to retrieve all tag information for passed flask_data row.

You can call it using unique row identifiers (event,parameter,adate,atime,inst) for a single
row or alternately using the flask_data.num unique id.  

On success, this exits with a zero.  On error, a non-zero value.


Options:
-h, -help
	Produce help menu

#To id target rows, pass either data_num(s) or event_num,parameter,adate,atime,inst

-d, -data_num
	flask_data.num target id

-e, -event_num
	event_num for flask_data row.
-g, -parameter=[parameter]
	paramater formulae
	Specify a single parameter (e.g., -parameter=co2) (not case sensitive)
-adate
	quoted analysis date in yyyy-mm-dd format (e.g., -adate='2008-02-01')
-atime
	quoted analysis time in hh:mm:ss 24h format (e.g., -atime='14:33:15')
-inst
	instrument used for analysis.

-productionDB (default 1)
	Pass 0 to use mund_dev.flask_data copy.  Pass 1 to use live production database.
	This is for dev purpurses

";
   exit(1);
}

