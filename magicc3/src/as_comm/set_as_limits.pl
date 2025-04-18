#!/usr/bin/perl
#
#This script will set default pfp limits for passed/connected pfp and set any specific overrides that
#are configured for passed site or are present in the passed file.  
#See help for details and examples.
#
#Note; We couldn't figure out how to 'accept' or keep a currently set value. That's unfortunate because our initial strategy was
#to set the pfp to the firmware defaults and then override with and site file configs.  This would allow new limits in future firmware
#versions to be created without breaking anything.  Our strategy now is to have a master default configs file (see below) that
#must have a value for every available question.  It sets all pfp limits and then overrides with any site specific configs.
#This means that we'll have to keep that master file updated unfortunately.

use strict;
use Time::Local;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

my @aLimits= ();
my @aDefaults = ();
my $help=0;
my %limits = ();
my $maxtries = 100;
my $verbose = 0;
my $numset=0;
my $numOverrides=0;
my $overrideEntriesTxt="";
my $noerror;
my $infile = '';
my $site='';
my $project='';
my $serialport = '/dev/ttyr300';#Default to dev port
my $version = '';
my $uid = '';
my $asid = '';
my @reply = ();
my $line = ''; 
my $configDir='/ccg/aircraft/plans/limits/';
my $defaultFile=$configDir."surface_default.cfg";
my $overrideFile="";

#
#######################################
# Parse Arguments
#######################################
#

$noerror = GetOptions(  "help|h"=>\$help,
                        "infile|f:s"=>\$infile,
			"site|s:s"=>\$site,
			"project:s"=>\$project,
                        "port|p:s"=>\$serialport,
                        "pfpid|i:s"=>\$uid,
                        "verbose|v"=>\$verbose);

if ( $noerror != 1 ) {print "Invalid options\n"; &showargs(); }
if ($help) { &showargs() }

if(!($infile || ($site && $project ))){die("Must pass site/project or infile\nsite:$site project:$project infile:$infile\n");}
if(!($uid && $serialport)){die("Must pass pfpid and port\n\n");}

#default defaults are surface_default.cfg.  Override with aircraft when passed.
if($project eq 'aircraft'){
	$defaultFile=$configDir."aircraft_default.cfg";
}


$overrideFile=$infile;
$site=lc($site);
if($infile eq ''){$overrideFile=$configDir.$site."_".$project."_default.cfg";}

print "Using default limits from\n$defaultFile\n";

# Read $infile
if(open(INFILE, "<$overrideFile")){
	@aLimits = <INFILE>;
	close(INFILE);
}else{
	if($infile){#a file was passed, but couldn't be opened.  error out.  If a site was passed, we'll still print a message and quit, but not error. Users wanted to be notified.
		die("Can't open file '$infile'");
	}else{
		print "Unable to find site/project limit override config file:$overrideFile\n\nNO LIMITS HAVE BEEN SET!\n\nYou must either set them manually or by clicking cancel, creating appropriate config file and then re-uploading.\n\n";
		exit 0;
	}
}
#Read defaults file
open(INFILE, "<$defaultFile")|| die("Can't open defaults file '$defaultFile'");
@aDefaults = <INFILE>;
close(INFILE);

#if ( &check_as_memory($serialport) != 0 ) { die(); }

$version = &get_as_version($serialport);
$version=lc($version);

#!!!! 3G? or 3F?  Need to test 3F menus if we want to do it.
if($version lt '3g'){
	print "Automatic default limits can only be set on PFP versions 3g+.  You must set this PFP's limits manually. Version:$version.\n";
	exit 0;#Exit without error.
}

$asid = &get_as_id($serialport, $version);



if ( $asid ne $uid )
{
   die("PFP ID number($asid) does not match the ID requested($uid)");
}

#Parse the defaults config file and put all known limits into a hash.
if($verbose){print("Defaults:\n");}
foreach my $line ( @aDefaults)
{
        # Strip comments, white spaces and empty lines 
        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next if($line eq "");

        #parse out the name:value pair
        my ($name,$value)=split(":",$line);
        $value=~ s/^\s+//;
	if($verbose){print("$name:$value\n");}
        $limits{$name}=$value;
}
#Parse the site config file and put all overrides into the hash.
if($verbose){print("\nOverrides:\n");}

foreach my $line ( @aLimits)
{
        # Strip comments, white spaces and empty lines 
        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
	$line =~ s/;.*$//;
        next if($line eq "");

        #parse out the name:value pair
        my ($name,$value)=split(":",$line);
        $value=~ s/^\s+//;
	if($limits{$name} ne $value){
		$numOverrides++;
		$overrideEntriesTxt.="$name:$value\n";
	}
	if($verbose){print("$name:$value\n");}

        $limits{$name}=$value;
}

#Hard code 1 answer for version 3F to avoid a bug in the firmware
if($version eq '3f'){
	$limits{"prefill_all_after_test"}='N';
}

if($verbose){print("\n\n");}

#Set the pfp values
if( &goto_as_menu($serialport,$version,'limits')==0){
	#Basically, we'll loop through the plan, sample and test limits and set them if we have a value,
	#Error out if not.

	#Plan limits first:
	if(&processSection("P")){
		 #Now Sample limits 
		 if(&processSection("S")){
			#Now Test limits
			if(&processSection("T")){
				#print out new limits:
				@reply=&as_send_and_read($serialport,'1','L');
				my $entries=($numOverrides==1)?"1 override entry from $overrideFile found:\n":"$numOverrides override entries from $overrideFile found:\n";
				$entries.="<b>".$overrideEntriesTxt."</b>";
				print "$entries\n$numset total configuration itmes set.\nLimits are now set to:\n\n";
				foreach my $line (@reply){print $line."\n";}
				&goto_as_menu($serialport, $version, 'main');
				exit(0);
			}
		}
	}               
}
&goto_as_menu($serialport, $version, 'main');
print "Error setting limits.  You should  manually verify they are set correctly.\n";
die;

sub processSection(){
        #Enter the interactive data entry for passed section and process all known overrides
        #Assumes some variables declared above.
        #This module is more for code re-use than modularity...
        #Returns true if we successfully get back to the limits menu.
        my ($section)=@_;
        @reply=&as_send_and_read($serialport,'1',$section);
        if($#reply>-1){
                my $continue=1;
                my $try=0;
                while($continue==1 && $try<$maxtries){
                        my $val='';
                        my $key='';
                        while($#reply >-1){
                                $line=pop(@reply);
                                $try++;#Failsafe to prevent infinite loop if we get unexpected responses.

                                #See if we're back at the menu (after cycling through all options), and exit loop if so.
                                if(&check_as_menu($version,'limits',$line)==0){
                                        $continue=0;
                                        return 1;#Return true for success
                                }
                                if($verbose){print $line."\n";}

                                #See if this line is one we know about and might be in our hash.
                                $key=&getKey($line);
                                if($key){last;}
                        }
                        #If we're still in interactive mode, send through the value;
                        if($continue){
				if($key && exists($limits{$key})){
					$val=$limits{$key};
			
                                	@reply = &as_send_and_read($serialport,'1',$val);
                                	if($verbose){print "Sending:'$val'\n";}
                                	$numset++;
				}else{
					die("Error setting limit for line $line(key:$key).  Either it is an unknown limit or there is not a corresponding value set in the defaults file: $defaultFile.");
   				
				} 
                        }
                }
        }
        return 0;

}
sub getKey(){
        my ($line)=@_;
        my $key="";
        $line=lc($line);
        #Return hash key to use for input prompt (if known)

        #Plan Limits
        if(isMatch($line,"altitude tolerance")){$key="alt_tolerance";}
        elsif(isMatch($line,"latitude tolerance")){$key="lat_tolerance";}
        elsif(isMatch($line,"longitude tolerance")){$key="lon_tolerance";}        
        elsif(isMatch($line,"sample mode")){$key="sample_mode";}
        elsif(isMatch($line,"should pumps run continuous")){$key="cont_capture";}

        #Sample Limits
        elsif(isMatch($line,"max flush time")){$key="max_flush_time";}
        elsif(isMatch($line,"manifold flush volume")){$key="manifold_flush_vol";}
        elsif(isMatch($line,"sample flush volume")){$key="sample_flush_vol";}
        elsif(isMatch($line,"manifold pre-fill flush volume")){$key="pre_man_flush_vol";}
        elsif(isMatch($line,"sample pre-fill flush volume")){$key="pre_sample_flush_vol";}
        elsif(isMatch($line,"pause after pre-fill")){$key="pause_after_prefill";}
        elsif(isMatch($line,"pre-fill all samples after system test")){$key="prefill_all_after_test";}
        elsif(isMatch($line,"pre-fill each sample before")){$key="prefill_each_before_fill";}
        elsif(isMatch($line,"manifold flush time without pcp")){$key="man_flush_time_wo_pcp";}
        elsif(isMatch($line,"sample flush time without pcp")){$key="sample_flush_time_wo_pcp";}
        #Test Limits
        elsif(isMatch($line,"max fill time")){$key="max_fill_time";}
        elsif(isMatch($line,"prefill pressure")){$key="prefill_pressure";}
        elsif(isMatch($line,"final fill pressure")){$key="final_fill_pressure";}
        elsif(isMatch($line,"max test time")){$key="max_test_time";}
        elsif(isMatch($line,"min test flow")){$key="min_flowrate";}
        elsif(isMatch($line,"max system pressure")){$key="max_pressure";}
        elsif(isMatch($line,"min supply limit")){$key="min_supply";}
        elsif(isMatch($line,"should system test be bypassed")){$key="bypass_system_test";}
        elsif(isMatch($line,"should all valves be set closed before system test")){$key="close_valves_at_test";}
        elsif(isMatch($line,"")){$key="";}


        #elsif(isMatch($line,"")){$key="";}
        return $key;
}
sub isMatch(){
        my($line,$desc)=@_;
        if(index(lc($line),lc($desc)) != -1){return 1;}
        else{return 0;}
}
sub showargs(){

print "
#############################
set_as_limits.pl
#############################

This script will set pfp limits using default configuration settings in $defaultFile using any override
values in passed infile or site specific overrides present in the config directory: $configDir.
The site files are named [site code]_[project]_limits.cfg.
-site 
	3 letter site code
-project 
	ccg project (surface, aircraft, obs...)
-pfpid
	prefix of pfp (3155 for 3155-FP)
-port
	port pfp is connected on (/dev/ttyr100)
-infile
	send either site,project,nflasks or infile to use.

examples:
set_as_limits.pl -p='/dev/ttyr300' -pfpid='3155' -infile='myfile.cfg'
or
set_as_limits.pl -p='/dev.ttyr300' -pfpid='3155' -site='bld' -project='surface'

\n";
exit (0);
}
