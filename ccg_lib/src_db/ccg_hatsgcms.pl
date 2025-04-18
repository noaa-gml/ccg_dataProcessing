#!/usr/bin/perl

use DBI;
use Getopt::Long;
use File::Copy;
use File::Path;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

# Sample call syntax
# ./ccg_flaskupdate.pl -file=/home/ccg/chao/tmp/test.fc -value -flag -comment -verbose -skipwords -update

#
#############################
# Initialization
#############################
#
$ddir = '/ccg/hats_gcms';
$queuedir = $ddir.'/upload_queue';
$archivedir = $ddir.'/upload_archive';
$perlcode = '/projects/src/db/ccg_flaskupdate.pl';

#
# Read the queue dir
#
opendir(DIR,$queuedir) || die("Cannot open directory !\n");
@queuedir_contents= readdir(DIR);
closedir(DIR);

#
# Loop through each file in the queue dir
#
foreach $filename (@queuedir_contents)
{
   if(!(($filename eq ".") || ($filename eq "..")))
   {

      # Get the $yr so we can make the archive directory
      my ( $fname, $ext ) = split(/\./, $filename);
      my ( $date, $time ) = split ( /_/, $fname);
      my ( $yr, $mo, $dy ) = split ( /\-/, $date);

      $qfile = $queuedir.'/'.$filename;
      $afile = $archivedir.'/'.$yr.'/'.$filename;
      #print "$qfile \n";
      #print "$afile \n";

      $args = '-file='.$qfile;

      #
      # Match the extension of the filename to see which arguments
      #    we need to pass to ccg_flaskupdate.pl
      #

      @filefields = split (/\./, $filename);

      $ext = @filefields[$#filefields];

      if ( $ext =~ /^[vfc]{1,3}$/i )
      {
         if ( $ext =~ /v/i )
         { $args = $args.' -value'; }
         if ( $ext =~ /f/i )
         { $args = $args.' -flag'; }
         if ( $ext =~ /c/i )
         { $args = $args.' -comment'; }
      }
      else
      {
         if ( $filename =~ /\.err$/i || $filename =~ /\.out$/i )
         { next; }

         #print "ERROR: '$filename' File type not recognized.\n";
         # Send error e-mail
         $sendmail = "/usr/sbin/sendmail -t";
         open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!\n";
         print SENDMAIL "To: Ben Miller <Ben.R.Miller\@noaa.gov>\n";
         #print SENDMAIL "Cc: Danlei Chao <Danlei.Chao\@noaa.gov>\n";
         #if ( $bcc ne "" ) { print SENDMAIL $bcc,"\n"; }
         print SENDMAIL "Reply-to: John Mund <john.mund\@noaa.gov>\n";
         print SENDMAIL "Subject: ERROR ccg_flaskupdate.pl $filename\n";
         print SENDMAIL "MIME-version: 1.0\n";
         print SENDMAIL "Content-Type: text/plain; charset=ISO-8859-1; format=flowed\n";
         print SENDMAIL "Content-Transfer-Encoding: 7bit\n";
         print SENDMAIL "\n";
         print SENDMAIL "'$filename' type not recognized.\n";
         print SENDMAIL "\n";
         close(SENDMAIL);
         next;
      }

      #
      # Name the standard output and standard error file
      #
      $qstderrfile = $qfile.'.err';
      $qstdoutfile = $qfile.'.out';
      $astderrfile = $afile.'.err';
      $astdoutfile = $afile.'.out';

      # Always use the verbose option
      $args = $args." -verbose";

      # Update the database
      $args = $args." -update";

      # Don't preserve the flags
      $args = $args." -nopreserve";

      #print "$perlcode $args\n";
      # Call the perl script with the arguments. Send the standard
      #    out meassages and the standard error messages to the
      #    correct files
      system ("$perlcode $args 1>$qstdoutfile 2>$qstderrfile");

      #
      # We are done processing the current file, move the input
      #    file to the archive directory. Move the standard
      #    out file to the archive directory
      #
      $rcount = 1; 

      if ( -e $afile || -e $astdoutfile || -e $astderrfile )
      {
         # If any archive files already exist, loop until
         #    we make a file name that does not exist
         while ( 1 )
         {
            $rcount++;
            if ( ! -e $afile.$rcount && 
                 ! -e $astdoutfile.$rcount &&
                 ! -e $astderrfile.$rcount )
            { last; }
         }
      }

      # Make the appropriate year directory in the archive directory
      if ( ! -e "$archivedir/$yr/" )
      { eval { mkpath("$archivedir/$yr/") }; }

      if ( $rcount <= 1 ) 
      {
         #print $afile."\n";
         move($qfile,$afile);
         #print $astdoutfile."\n";
         move($qstdoutfile,$astdoutfile);
      }
      else
      {
         #print $afile.$rcount."\n";
         move($qfile,$afile.$rcount);
         #print $astoutfile.$rcount."\n";
         move($qstdoutfile,$astdoutfile.$rcount);
      }

      # Check if the standard error file is zero
      if ( -z $qstderrfile )
      {
         # Standard error file is zero, we have no errors or warnings
         unlink $qstderrfile;

         #
         # Send success e-mail
         #
         $sendmail = "/usr/sbin/sendmail -t";
         open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!\n";
         print SENDMAIL "To: Ben Miller <Ben.R.Miller\@noaa.gov>\n";
         #print SENDMAIL "Cc: Danlei Chao <Danlei.Chao\@noaa.gov>\n";
         #if ( $bcc ne "" ) { print SENDMAIL $bcc,"\n"; }
         print SENDMAIL "Reply-to: John Mund <john.mund\@noaa.gov>\n";
         print SENDMAIL "Subject: ccg_flaskupdate.pl $filename success\n";
         print SENDMAIL "MIME-version: 1.0\n";
         print SENDMAIL "Content-Type: text/plain; charset=ISO-8859-1; format=flowed\n";
         print SENDMAIL "Content-Transfer-Encoding: 7bit\n";
         print SENDMAIL "\n";
         print SENDMAIL "Processing $filename was successful with no errors.\n";
         print SENDMAIL "\n";
         close(SENDMAIL);
      }
      else
      {
         # Standard error file is not zero, we have problems

         @qstderr_arr = ();
         open(ERRFILE,$qstderrfile);
         @qstderr_arr = <ERRFILE>;
         close(ERRFILE);
         @errarr = grep(index($_, "ERROR:") != -1, @qstderr_arr);
         @warningarr = grep(index($_, "WARNING:") != -1, @qstderr_arr);

         # It should never display this because if the error file is not empty
         #    there should at least one error or one warning
         $subjectline = "Subject: Contact Dan Chao if you see this! ccg_hatsgcms.pl $filename\n";
         if ( $#errarr > 0 )
         {
            if ( $#warningarr > 0 )
            { $subjectline = "Subject: ERRORs and WARNINGs in ccg_flaskupdate.pl $filename\n"; }
            else
            { $subjectline = "Subject: ERRORs in ccg_flaskupdate.pl $filename\n"; }
         }
         else
         {
            if ( $#warningarr > 0 )
            { $subjectline = "Subject: WARNINGs in ccg_flaskupdate.pl $filename\n"; }
         }

         # Move the standard error file into the archive directory
         if ( $rcount <= 1 ) 
         {
            #print $astderrfile."\n";
            move($qstderrfile,$astderrfile);
         }
         else
         {
            #print $astderrfile.$rcount."\n";
            move($qstderrfile,$astderrfile.$rcount);
         }

         # Send error e-mail
         $sendmail = "/usr/sbin/sendmail -t";
         open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!\n";
         print SENDMAIL "To: Ben Miller <Ben.R.Miller\@noaa.gov>\n";
         #print SENDMAIL "Cc: Danlei Chao <Danlei.Chao\@noaa.gov>\n";
         #if ( $bcc ne "" ) { print SENDMAIL $bcc,"\n"; }
         print SENDMAIL "Reply-to: John Mund <john.mund\@noaa.gov>\n";
         print SENDMAIL $subjectline;
         print SENDMAIL "MIME-version: 1.0\n";
         print SENDMAIL "Content-Type: text/plain; charset=ISO-8859-1; format=flowed\n";
         print SENDMAIL "Content-Transfer-Encoding: 7bit\n";
         print SENDMAIL "\n";
         print SENDMAIL "Problems encountered while processing $filename.\n";
         print SENDMAIL "\n";
         close(SENDMAIL);

      }
   }
}
exit;

