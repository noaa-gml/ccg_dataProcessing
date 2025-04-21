#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# ccg_requesthandler
#
# This script processes CCGG data requests, if there are no errors
#
# 1) prepare data files and readme files
# 2) zip or tar files (include appropriate README for each parameter)
# 3) assign random name to compressed file
# 4) save compressed file to /www/
# 5) e-mail data requestor, recipient, and PIs
# 6) remove temporary directory and files
#
# If there are errors in the process:
#    Types of errors: No data, no contact, no readme file
#
# 1) prepare data files and readme files
# 2) e-mail data requestor of error
#
# December 2006 - dyc
#
#######################################
# Parse Arguments
#######################################
##########################
$dev=true;
###########################
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "affiliation|a=s", "comment", "compression|c=s", "dataargs=s", "email|e=s", "eventargs=s", "file=s", "help|h", "merge=i", "name|n=s", "not", "project|p=s", "strategy|st=s", "user|u=s", "average=s", "showtags");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

if ($Options{file}) { $file = $Options{file} } else { &showargs() };

if ($Options{project}) { $project_abbr = $Options{project} } else { &showargs() };

if ($Options{strategy}) { $strategy_abbr = $Options{strategy} } else { &showargs() };

$compression = ($Options{compression}) ? $Options{compression} : "zip";
$dataargs = $Options{dataargs};
$eventargs = $Options{eventargs};
$not = $Options{not};
$merge = $Options{merge};
$comment = $Options{comment};
$showtags = 0; #default to 0 for all projects, may be overriden below for flask as appropriate.

my $average="";
if($Options{average}){$average=$Options{average};}

#
# Get recipient information
#
$rname = ($Options{name}) ? $Options{name} : "";
$raffi = ($Options{affiliation}) ? $Options{affiliation} : "";
$recipient = ($Options{email}) ? $Options{email} : "";

$requestor = ($Options{user}) ? $Options{user} : "";

#
#######################################
# Initialization
#######################################
#
#$perl_readme = "/projects/ftp/readme/build_readme.pl";
$perl_readme = "/projects/ftp/readme/build_readme.pl";

$reqno = int(10**8*rand());
$dir = "/aftp/data/ccgg/requests/";
$wdir = "NOAA_${reqno}/";
@errarr = ();

if ( ( lc($project_abbr) eq 'ccg_surface' &&
       lc($strategy_abbr) eq 'insitu' )
     ||
     lc($project_abbr) eq 'ccg_obs' )
{
   $perl_request = "/projects/src/db/ccg_datarequest_insitu.pl";
}
elsif ( lc($project_abbr) eq 'ccg_tower' )
{
   $perl_request = "/projects/src/db/ccg_datarequest_tower.pl";
}
elsif ( lc($project_abbr) eq 'ccg_aircraft' ||
        lc($project_abbr) eq 'ccg_surface' )
{
   $perl_request = "/projects/src/db/ccg_datarequest_flask.pl";
   if ($dev) {$perl_request = "/projects/src/db/ccg_datarequest_flask2.pl";}
   
   $showtags = $Options{showtags};
}
else
{
   $perl_request = '';
   push (@errarr, "Project '$project_abbr' not recognized.");
}

#6/23/16-adding this as option on web page...
#Per Ed's request 12.3.15.  Defaulting all obs data to hourly.  In the future this could
#be added as an option on the web request page.
#my $average = '';
#if ( lc($project_abbr) eq 'ccg_obs' ){
#	$average='hour';
#}

#
#######################################
# Read Input file
#######################################
#
open (FILE, $file) || push(@errarr, "Can't open file ${file}.");
@list = <FILE>;
close (FILE);
#
# Create a temporary directory
#
$z = "mkdir -p -m777 ${dir}${wdir}";
#print "$z\n";
system($z) == 0 || push(@errarr, "Can't open output directory.");
#system("cp $file /tmp/j.txt");
#
# Merge the data list together
#
if ( $merge ) { &MergeList(); }

#
#######################################
# Process request - one line at a time
#######################################
#
@list = sort(@list);
foreach $item (@list)
{
   # Parse item
   chomp($item);
   ($site_code, $parameterprogram_str) = split (/\|/, lc($item), 2);
   @parameterprogram_abbrs = &unique_array(split(',', $parameterprogram_str));

   #
   # Request data
   #
   if ( -e $perl_request && ! -z $perl_request )
   {
      $z = "${perl_request} -site='${site_code}'";
      $z = $z." -parameterprogram='${parameterprogram_str}'";
      $z = $z." -project='${project_abbr}' -strategy='${strategy_abbr}'";
      $z = $z." -outputdir='${dir}${wdir}'";
      if ( $eventargs ne "" ) { $z = $z." -eventargs='${eventargs}'"; }
      if ( $dataargs ne "" ) { $z = $z." -dataargs='${dataargs}'"; }
      if ( $merge ) { $z = $z." -merge='${merge}'"; }
      if ( $comment ) { $z = $z." -comment"; }
      if ( $not ) { $z = $z." -not"; }
      if ( $average ne "" ) { $z = $z." -average='${average}'";}
      if ( $showtags ) {$z.=" -showtags";}
      

      print "$z\n";
      @data = `${z} 2>&1`;
   }
   else
   { push(@data, "ERROR: ${perl_request} does not exist.\n"); } 

   @data_err = ();
   @data_err = grep(index($_, "ERROR") != -1, @data);
   push (@errarr, @data_err);

   $projectstr = (split(/_/, $project_abbr))[1];
   foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
   {
      ($parameter_formula, $program_abbr) = split('~', $parameterprogram_abbr, 2);

      #
      # Prepare README
      #

      if ( -e $perl_readme )
      {
         $rsave = "${dir}${wdir}README_${parameter_formula}_${projectstr}-${strategy_abbr}_${program_abbr}.html";
         $z = "${perl_readme} -parameter=${parameter_formula} -project=${project_abbr} -strategy=${strategy_abbr} -program=${program_abbr}";
         #print "$z\n";
         #
         # Redirect STDERR to STDOUT because build_readme.pl sends errors to STDERR
         #
         @readme = `${z} 2>&1`;
     
         if ( $#readme < 1 )
         { push (@readme, "ERROR: ${parameter_formula} ${program_abbr} README file is empty."); }
      }
      else
      { push(@readme, "ERROR: ${perl_readme} does not exist.\n"); } 

      @readme_err = ();
      @readme_err = grep(index($_, "ERROR") != -1, @readme);
      push (@errarr, @readme_err);

      #
      # If no errors, display the results
      #
      #if ( $#errarr < 0 )
      if ( $#readme_err < 0 )
      {
         open(FILE,">${rsave}");
         foreach $row (@readme)
         {
            chomp($row);
            print FILE "${row}\n";
         }
         close(FILE);
      }
   }
} 

#
#######################################
# Compress data file(s) and README(s)
#######################################
#
#
# If the user did not specified a merge file, then
#    merge the site+parameter information together
#    so we can have consistent output in the email.
#    It will always show a merged format.
#
if ( ! ( $merge ) ) { &MergeList(); }

#
# If data was found and no readme errors, then compress the directory
#
if ( $#errarr < 0 )
{
   #
   # Name output file
   #
   $outfile = "NOAA_${reqno}.${compression}";
   #
   # Get list of data files
   #
   if ($compression eq "zip")
   {
      $z = "cd ${dir}; zip -q ${dir}${outfile} ${wdir}*";
   }
   elsif ($compression eq "tar")
   {
      $z = "cd ${dir}; tar cf ${dir}${outfile} ${wdir}; gzip ${dir}${outfile}";
      $outfile = $outfile.".gz";
   }
   #print "$z\n";
   system($z);

   if ( $requestor )
   {
      if ( $recipient )
      {
         #
         #######################################
         # Notify Recipient of Data
         #######################################
         #
         $to  = "To: \"${rname}\" <${recipient}>";
         $cc  = "";
         $bcc  = "Bcc:  john.mund\@noaa.gov";
         $reply_to = "Reply-to: ${requestor}";
         $subject  = "Subject:  Request for NOAA CCCG atmospheric data";

         $requestinfo = 0;
         $showconstraints = 0;
         $content = &MakeEmailContent($requestinfo, $showconstraints);
         &SendEmail($to,$cc,$bcc,$reply_to,$subject,$content);
      }

      #
      #######################################
      # Notify Requestor of Success
      #######################################
      #
      $to  = "To: ${requestor}";
      $cc  = "";
      $bcc  = "Bcc:  john.mund\@noaa.gov";
      $reply_to = "Reply-to: \"John Mund\" <john.mund\@noaa.gov>";
      $subject  = "Subject:  Success - Request for NOAA CCCG atmospheric data";

      $requestinfo = 1;
      $showconstraints = 1;
      $content = &MakeEmailContent($requestinfo, $showconstraints);
      &SendEmail($to,$cc,$bcc,$reply_to,$subject,$content);
   }

   &EmailPI();
   &EmailCollab();
}

if ( $#errarr > -1 )
{
   #
   #######################################
   # Notify Admin of Error
   #######################################
   #
   $to  = "To: john.mund\@noaa.gov";
   $cc  = "";
   $bcc  = "";
   $reply_to = "Reply-to: \"John Mund\" <john.mund\@noaa.gov>";
   $subject  = "Subject:  Error(s) in Processing Data Request";

   $requestinfo = 0;
   $showconstraints = 1;
   $content = &MakeEmailContent($requestinfo, $showconstraints);
   &SendEmail($to,$cc,$bcc,$reply_to,$subject,$content);

   #
   # Print the output to be captured by the web interface
   #
   $content = &MakeErrorReport();
   print STDERR $content;
}

#
#######################################
# Clean Up
#######################################
#
#
# Remove temporary directory and files
#
$z = "rm -r ${dir}${wdir}";
#print "$z\n";
system($z);

unlink($file);

if ( $#errarr < 0 )
{
   #
   # Change mode of file so that it can later be removed.
   #
   $z = "chmod 666 -f ${dir}${outfile}";
   #print "$z\n";
   system($z);

}


if ( $#errarr < 0 )
{
   # 0 problems
   exit 0;
}

# 1 or more problems encountered
exit 1;


sub EmailPI()
{
   #
   #######################################
   # Connect to Database
   #######################################
   #
   $dbh = &connect_db();

   #
   #######################################
   # Notify each project pi
   #######################################
   #
   $t1 = "project_contact";
   $t2 = "contact";

   $project_num = &get_relatedfield($project_abbr, 'project_abbr', 'project_num');
   $strategy_num = &get_relatedfield($strategy_abbr, 'strategy_abbr', 'strategy_num');

   open (FILE, $file) || push(@errarr, "Can't open file ${file}.");
   @list = <FILE>;
   close (FILE);

   #
   # Get a list of all the contacts
   #
   @pi = ();
   foreach $item ( @list )
   {
      chomp($item);
      ($site_code, $parameterprogram_str) = split (/\|/, lc($item), 2);
      @parameterprogram_abbrs = &unique_array(split(',', $parameterprogram_str));

      foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
      {
         ($parameter_formula, $program_abbr) = split('~', $parameterprogram_abbr);

         $parameter_num = &get_relatedfield($parameter_formula, 'parameter_formula', 'parameter_num');
         $program_num = &get_relatedfield($program_abbr, 'program_abbr', 'program_num');
         $site_num = &get_relatedfield($site_code, 'site_code', 'site_num');

         $select = " SELECT DISTINCT ${t2}.email";
         $from = " FROM ${t1}, ${t2}";
         $where = " WHERE ${t1}.site_num = ?";
         $and = " AND ${t1}.project_num = ?";
         $and = $and." AND ${t1}.strategy_num = ?";
         $and = $and." AND ${t1}.program_num = ?";
         $and = $and." AND ${t1}.parameter_num = ?";
         $and = $and." AND ${t1}.contact_num = ${t2}.num";

         $sql = $select.$from.$where.$and;
         @sqlargs = ($site_num, $project_num, $strategy_num, $program_num, $parameter_num);

         #print "$sql\n";
         #print join('|', @sqlargs)."\n";

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);

         @tmp = $sth->fetchrow_array();

         push @pi, join("|", @tmp);
         $sth->finish();
      }
   }

   #
   # Extract each unique e-mail
   #
   @pi = &unique_array(@pi);

   $to = "";
   foreach $piinfo ( @pi )
   {
      #print "$piinfo\n";
      if ( $piinfo ne "" )
      {
         $to = ( $to eq "" ) ? "To: $piinfo" : "${to}, $piinfo";
      }
   }

   &MergeList();

   #
   ##################################
   # Notify contact of data request
   ##################################
   #
   #print "$to\n";
   #$to = "To:  danlei.chao\@noaa.gov";
   $cc = "";
   $bcc = "Bcc:  john.mund\@noaa.gov";
   $reply_to = "Reply-to: \"John Mund\" <john.mund\@noaa.gov>";
   $subject  = "Subject:  PI contact - Request for NOAA CCCG atmospheric data";

   $requestinfo = 1;
   $showconstraints = 1;
   $content = &MakeEmailContent($requestinfo, $showconstraints);
   &SendEmail($to,$cc,$bcc,$reply_to,$subject,$content);

   #
   #######################################
   # Disconnect from DB
   #######################################
   #
   &disconnect_db($dbh);
}


sub EmailCollab()
{
   #
   # Get a list of all the collaborators
   #
   @collab = ();
   foreach $item ( @list )
   {
      chomp($item);
      ($site_code, $parameterprogram_str) = split (/\|/,, lc($item), 2);

      if ( $site_code eq 'sgp' ) 
      { push(@collab, 'SCBiraud@lbl.gov'); }
      elsif ( $site_code eq 'str' )
      { push(@collab, 'MLFischer@lbl.gov'); }
      elsif ( $site_code eq 'wgc' )
      { push(@collab, 'MLFischer@lbl.gov'); }
      elsif ( $site_code eq 'lac' )
      { push(@collab, 'john.b.miller@noaa.gov'); }
      elsif ( $site_code eq 'crv' )
      { push(@collab, 'john.b.miller@noaa.gov'); }
   }

   #
   # Extract each unique e-mail
   #
   @collab = &unique_array(@collab);

   $to = "";
   foreach $collabinfo ( @collab )
   {
      #print "$collabinfo\n";
      if ( $collabinfo ne "" )
      {
         $to = ( $to eq "" ) ? "To: $collabinfo" : "${to}, $collabinfo";
      }
   }

   &MergeList();

   #
   ##################################
   # Notify contact of data request
   ##################################
   #
   if ( $to ne '' )
   {
      #print "$to\n";
      #$to = "To:  danlei.chao\@noaa.gov";
      $cc = "";
      $bcc  = "Bcc:  john.mund\@noaa.gov";
      $reply_to = "Reply-to: \"John Mund\" <john.mund\@noaa.gov>";
      $subject  = "Subject:  Collaborator contact - Request for NOAA CCCG atmospheric data";

      $requestinfo = 1;
      $showconstraints = 1;
      $content = &MakeEmailContent($requestinfo, $showconstraints);
      &SendEmail($to,$cc,$bcc,$reply_to,$subject,$content);
   }
}

sub SendEmail()
{
   #
   # Send an e-mail
   #
   my($to,$cc,$bcc,$reply_to,$subject,$content) = @_;

   if (!$dev) {
    
   
      
      if ($dev) {
         $subject="${subject}, ${to} ";
         $to="To: john.mund@noaa.gov";
         $cc="";
      }
     
   
      $sendmail = "/usr/sbin/sendmail -t";
      open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
      print SENDMAIL $to,"\n";
      if ( $cc ne "" ) { print SENDMAIL $cc,"\n"; }
      if ( $bcc ne "" ) { print SENDMAIL $bcc,"\n"; }
      print SENDMAIL $reply_to,"\n";
      print SENDMAIL $subject,"\n";
      print SENDMAIL $content,"\n";
      close(SENDMAIL);
      #print "$to\n";
      #print "$cc\n";
      #print "$bcc\n";
      #print "$reply_to\n";
      #print "$subject\n";
      #print "$content\n";
   }
}

sub MakeEmailContent()
{
   my($requestinfo,$showconstraints) = @_;
   #
   # Make the content of the e-mail
   #
   $content = "Content-type: text/plain\n\n";

   if ( $requestinfo )
   {
      $content = "${content}Request made by: ${requestor}\n";
      $content = "${content}Request sent to:\n";
      $content = "${content}Name: ${rname}\n";
      $content = "${content}Affiliation: ${raffi}\n";
      $content = "${content}Email: ${recipient}\n\n";
      $content = "${content}#######################################################\n";
   }

   $content = "${content}CCGG Data Request Summary:\n\n";
   foreach $item (@list)
   {
      # Parse item
      chomp($item);
      ($site_code, $parameterprogram_str) = split (/\|/, lc($item), 2);
      @parameterprogram_abbrs = &unique_array(split(',', $parameterprogram_str));

      @tmparr = ();
      foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
      {
         ($parameter_formula, $program_abbr) = split ('~', $parameterprogram_abbr, 2);
         push(@tmparr, $parameter_formula.' '.$program_abbr);   
      } 
      $content = "${content}Site:Gases\t\t\t".uc($site_code).":".uc(join(',', @tmparr))."\n";
   }

   $content = "${content}\n";
   $content = "${content}Project:\t\t\t".uc($project_abbr)."\n";
   $content = "${content}Strategy:\t\t\t".uc($strategy_abbr)."\n";
   $content = "${content}Compression:\t\t\t".uc($compression)."\n";

   if ( $showconstraints || $#errarr > -1 )
   {
      $content = "${content}Sample Constraints:\t\t$eventargs\n";
      $content = "${content}Data Constraints:\t\t$dataargs\n";
      $mergestr = ( $merge ) ? "TRUE" : "FALSE";
      $content = "${content}Merge Output:\t\t\t$mergestr\n";
      $notstr = ( $not ) ? "TRUE" : "FALSE";
      $content = "${content}Negate Flag:\t\t\t$notstr\n\n";

      $content = "${content}If there are no constraints on the requested data, the\n";
      $content = "${content}distribution includes all data in the database at the\n";
      $content = "${content}time the request is processed.\n\n";
   }

   if ( $#errarr > -1 )
   {
      $content = "${content}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
      $content = "${content}There was a problem processing your request.\n\n";
      foreach $error ( @errarr )
      {
         chomp($error);
         $content = "${content}$error\n";
      }
      $content = "${content}\n";
      $content = "${content}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
   }
   else
   {
      $content = "${content}\n\n";
      $content = "${content}************************************************************\n";
      $content = "${content}NOTE: 2015-11-20\n";
      $content = "${content}Updated the content and format of event files to include elevation in\n";
      $content = "${content}meters above sea level (masl) and sample collection intake height in\n";
      $content = "${content}meters above ground level (magl). Elevation plus collection intake\n";
      $content = "${content}height equals altitude, which has always been included in the NOAA\n";
      $content = "${content}distribution. In adding these 2 fields, the event number column\n";
      $content = "${content}has moved. The new format is described in the readme; Sections 7.3 and 7.4.\n";

      $content = "${content}*************************************************************\n";
      $content = "${content}WARNING: Your data request may include PRELIMINARY DATA.\n";
      $content = "${content}Preliminary data have not yet been carefully examined by\n";
      $content = "${content}our lab and may include experimental errors.  Please contact\n";
      $content = "${content}the PI before using preliminary data.  Preliminary data are\n";
      $content = "${content}identified by a \"P\" in the 3rd column of the QC flag.  The\n";
      $content = "${content}\"P\" assignment is removed once the quality of the\n";
      $content = "${content}measurement has been determined.\n";
      $content = "${content}*************************************************************\n\n\n";
      $content = "${content}Your request has been successfully processed.\n\n";
      $content = "${content}You may access your compressed file as follows:\n\n";
      $content = "${content}ftp://aftp.cmdl.noaa.gov/data/ccgg/requests/${outfile}\n\n";
      $content = "${content}Notes:  This file may take at most 30 minutes to become\n";
      $content = "${content}available for access. Also, this file will be removed\n";
      $content = "${content}automatically in 10 days.\n\n";
      $content = "${content}Please review the included README file(s) before using these data.\n\n\n\n";
      $content = "${content}Thank you for your interest.\n\n";
      $content = "${content}National Oceanic and Atmospheric Administration (NOAA)\n";
      $content = "${content}Global Monitoring Laboratory (GML)\n";
      $content = "${content}Carbon Cycle Greenhouse Gases (CCGG)";
   }

   return $content;
}

sub MakeErrorReport()
{
   #
   # Make the content of the error report
   #
   $content = "CCGG Data Request Error Report:\n\n";
   foreach $item (@list)
   {
      # Parse item
      chomp($item);
      ($site_code, $parameterprogram_str) = split (/\|/, lc($item), 2);
      @parameterprogram_abbrs = &unique_array(split(',', $parameterprogram_str));

      @tmparr = ();
      foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
      {
         ($parameter_formula, $program_abbr) = split ('~', $parameterprogram_abbr, 2);
         push(@tmparr, $parameter_formula.' '.$program_abbr);   
      } 
      $content = "${content}Site:Gases\t\t\t".uc($site_code).":".uc(join(',', @tmparr))."\n";
   }

   $content = "${content}\n";
   $content = "${content}Project:\t\t\t".uc($project_abbr)."\n";
   $content = "${content}Strategy:\t\t\t".uc($strategy_abbr)."\n";
   $content = "${content}Compression:\t\t\t".uc($compression)."\n";

   $content = "${content}Sample Constraints:\t\t$eventargs\n";
   $content = "${content}Data Constraints:\t\t$dataargs\n";
   $mergestr = ( $merge ) ? "TRUE" : "FALSE";
   $content = "${content}Merge Output:\t\t\t$mergestr\n";
   $notstr = ( $not ) ? "TRUE" : "FALSE";
   $content = "${content}Negate Flag:\t\t\t$notstr\n\n";

   $content = "${content}If there are no constraints on the requested data, the\n";
   $content = "${content}distribution includes all data in the database at the\n";
   $content = "${content}time the request is processed.\n\n";

   $content = "${content}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
   $content = "${content}There was a problem processing your request.\n\n";
   foreach $error ( @errarr )
   {
      chomp($error);
      $content = "${content}$error\n";
   }
   $content = "${content}\n";
   $content = "${content}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";

   return $content;
}

sub MergeList()
{
   # Merges the data list together
   # Example, merge ALT|CO~CCGG and ALT|CO2~CCGG to become ALT|CO~CCGG,CO2~CCGG
   #
   my @mergelist = ();
   my $nmerge = -1;
   my $prevcode = "###";
   my $i;

   for ( $i=0; $i<@list; $i++ )
   {
      chomp($list[$i]);
      @field = split(/\|/, $list[$i]);
      if ( $prevcode eq $field[0] )
      { $mergelist[$nmerge] = $mergelist[$nmerge].",$field[1]"; }
      else
      {
         $nmerge++;
         $mergelist[$nmerge] = "$field[0]|$field[1]";
         $prevcode = $field[0];
      }
   }

   @list = @mergelist;
}

sub showargs()
{
   print "\n#########################\n";
   print "ccg_requesthandler.pl\n";
   print "#########################\n\n";
   print "This script processes CCGG data requests.\n\n";
   print "1) prepare data files\n";
   print "2) names data files\n";
   print "3) zip or tar files (include appropriate README for each parameter)\n";
   print "4) assign random name to compressed file\n";
   print "5) save compressed file to /www/..\n";
   print "6) remove temporary directory and files\n";
   print "7) e-mail data requestor\n\n";
   print "Options:\n\n";
   print "-a, -affiliation=[affiliate]\n";
   print "     Specify affiliation of the recipient\n\n";
   print "-c, -compression=[compression type]\n";
   print "     Compression format of data file(s) (e.g., zip or tar)\n\n";
   print "-dataargs=[analysis constraints]\n";
   print "     Analysis constraints passed directly to ccg_flask.pl\n\n";
   print "-e, -email=[e-mail]\n";
   print "     Specify e-mail address of the recipient\n\n";
   print "-eventargs=[event constraints]\n";
   print "     Sample constraints passed directly to ccg_flask.pl\n\n";
   print "-file=[input file]\n";
   print "     Specify input file\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-merge=[merge option]\n";
   print "     See ccg_flask.pl documentation\n\n";
   print "-n, -name=[name]\n";
   print "     Specify name of the recipient\n\n";
   print "-not\n";
   print "     Negate the flag constraint logic\n\n";
   print "-p, -project=[project]\n";
   print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
   print "-s, -site=[site]\n";
   print "     Specify the site\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n\n";
   print "-u, -user\n";
   print "     Specify the data requestor e-mail\n\n";
   print "# Request co2 data at BRW for strategy flask with analysis dates\n";
   print "#    between 2003-01-01 and 2004-01-01. Send the request to\n";
   print "#    Dan Chao - NOAA ( danlei.chao\@noaa.gov ). Carbon copy\n";
   print "#    the e-mail to the requestor, kenneth.masarie\@noaa.gov\n";
   print "   (ex) ./ccg_requesthandler.pl -parameter=co2 -site=BRW\n";
   print "           -strategy=flask -dataargs=2003-01,2004 -compression=zip\n";
   print "           -user=kenneth.masarie\@noaa.gov -email=danlei.chao\@noaa.gov\n";
   print "           -affiliation=NOAA -name='Dan Chao'\n";
   exit;
}
