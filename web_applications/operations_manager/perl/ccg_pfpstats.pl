#!/usr/bin/perl

use DBI;
use Getopt::Std;
use Switch;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
#######################################
# Output file name
#######################################
#

#
# Checks for -o$filename to see if the user passed in an output filename
#
&getopts('o:');

$file = $opt_o;

# cp pfp.2004 /www/ccgg/chao/perl/pfp.all
# cat pfp.2005 >> /www/ccgg/chao/perl/pfp.all

my @pfplist = ();
my @infolist = ();
$omdir = "/var/www/html/om";

# Get today's date
@today = localtime();
$today[5] += 1900;
$today[4] += 1;

$today_dd = &date2dec($today[5], $today[4], $today[3]);

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

#
# Create the concatenated log file from the last 2 years
#
opendir(DIR, "$omdir/log");
@files = grep(/pfp\.[0-9]+$/,readdir(DIR));
closedir(DIR);

@files = sort(@files);

$filenum = scalar @files;

$tmpfile = $omdir.'/tmp/pfp'.int(10**8*rand()).'.all';

system ("cp $omdir/log/$files[$filenum-2] $tmpfile");
system ("cat $omdir/log/$files[$filenum-1] >> $tmpfile");

#
# Open the big log file
#
open(INFILE,"<$tmpfile");

while(<INFILE>)
{
   # Good practice to store $_ value because
   #  subsequent operations may change it.
   my($line) = $_;

   # Good practice to always strip the trailing
   #  newline from the line.
   chomp($line);

   # Only get lines that begin with YYYY-MM-DD
   next if ( $line !~ m/^[0-9]{4}-[0-9]{2}-[0-9]{2}/ );

   ($date, $str) = split(/\./, $line, 2);

   @datearr = split('-', $date);
   $date_dd = &date2dec(@datearr);

   # Only find entries from the past year
   next if ( $today_dd - $date_dd ) > 1;

   # Convert the line to upper case.
   $line =~ tr/[a-z]/[A-Z]/;

   if ($line =~ m/(CHECKED IN|PREP ROOM)/)
   {
      # Print the line to the screen and add a newline
      #print "$line\n";
      @strlist = split(/ +/, $line );
      @datetime = split(/\./, $strlist[0]);
      if ( ! ( $strlist[2] =~ m/-FP/ ) )
      {
         $pfpid = $strlist[3];
         #print "$datetime[0] $strlist[3]\n";
      }
      else
      {
         $pfpid = $strlist[2];
         #print "$datetime[0] $strlist[2]\n";
      }

      if ($line =~ m/(CHECKED IN)/)
      {
         # CHECKED IN

         #
         # Sometimes there is a period at the end of the site name, remove that
         #
         $site = substr($strlist[6], 0, 3);

         $sitenum = get_field('num','gmd.site','code',"$site");

         if ( $sitenum ne '' )
         {
            $pfplist[++$#pfplist] = $site.'~'.$pfpid.'~'.$datetime[0];
         }
         else
         {
            #print "*********************************************************\n";
            #print "$site not found\n";
            #print "*********************************************************\n";
         }
      }
      else
      {
         # PREP ROOM

         for ( $n=scalar $#pfplist; $n>=0; $n--)
         {
            $infostr = $pfplist[$n];

            #
            # Field 0 - Site Code
            #       1 - PFP ID
            #       2 - Checked In date
            #
            @field = split(/\~/, $infostr );

            $sitenum = get_field('num','gmd.site','code',"$field[0]");

            @idfield = split(/-/,$field[1]);

            #
            # Convert the Check In date to decimal
            #
            $chkindate = $field[2];
            @tmp = split(/-/,$chkindate);
            $chkindd = date2dec($tmp[0],$tmp[1],$tmp[2],12,0);

            #
            # Convert the Prep Room date into decimal
            #
            $prepdate = $datetime[0];
            @tmp = split(/-/,$prepdate);
            $prepdd = &date2dec($tmp[0],$tmp[1],$tmp[2],12,0);

            if ( $field[1] == $pfpid && $prepdate ne $chkindate )
            {

               # print "$infostr~$datetime[0]\n";

               @idfield = split(/-/,$field[1]);

               $select = " SELECT MIN(t2.date)";
               $from = "  FROM flask_event AS t1, flask_data AS t2";
               $where = " WHERE t1.site_num = '$sitenum' AND t1.strategy_num = '2'";
               $and = " AND t2.parameter_num = ? AND id LIKE '$idfield[0]-%'";
               $and = $and." AND t2.date BETWEEN '$chkindate' AND '$prepdate'";
               $and = $and." AND t1.num = t2.event_num";

               $sql = $select.$from.$where.$and;

               $select_handle = $dbh->prepare($sql);

               $infolist[++$#infolist] = $field[0];

               @parameter_nums = ('1', '20', '7');

               foreach $parameter_num ( @parameter_nums )
               {
                  $select_handle->execute($parameter_num);

                  $date = $select_handle->fetchrow_array();
                  $select_handle->finish();
                  #
                  # Set to a default date difference
                  #
                  $tmpdif = -999;

                  if ( $date ne '' )
                  {
                     @tmp = split(/-/,$date);
                     $tmpdd = date2dec($tmp[0],$tmp[1],$tmp[2],12,0);
                     if ( $tmpdd >= $chkindd )
                     {
                        $tmpdif = ( $tmpdd - $chkindd ) * 365;
                     }
                  }

                  $infolist[$#infolist] = $infolist[$#infolist].'~'.$tmpdif;
               }

               # Prep - Checkin
               #
               # Set to a default date difference
               #
               $tmpdif = -999;
               if ( $prepdd != $chkindd )
               {
                  $tmpdif = ( $prepdd - $chkindd ) * 365;
               }
               $infolist[$#infolist] = $infolist[$#infolist].'~'.$tmpdif;

               #if ( $sitenum eq '482' )
               #{
               #   print join("\n", @pfplist)."\n";
               #   print "$line\n";
               #   print "$pfpid $chkindate $prepdate\n";
               #   print $infolist[$#infolist]."\n";;
               #}

               #if ( $field[1] eq '3156-FP' )
               #{
               #   print join("\n", @pfplist)."\n";
               #   print "$line\n";
               #   print "$pfpid $chkindate $prepdate\n";
               #   print $infolist[$#infolist]."\n";;
               #} 

               splice(@pfplist, $n, 1);

               # We found the most recent entry, exit out of the loop
               last;
            }
         }
      }
   }
}

#foreach $field ( @pfplist )
#{
#   if ( $field ne '' ) 
#   {
#      print "$field\n";
#   }
#}

@infolist = sort ( @infolist );

#
# This is so that the last actual site is displayed, since we only print
# when the site code changes. So, the last actual site won't print
# unless something comes after it
#
$infolist[++$#infolist] = '^^^~-999~-999~-999';

my @magicc = ();
my @gcms = ();
my @sil = ();
my @prep = ();

$prevsite = '???';

if ($file) { $file = ">${file}"; }
else { $file = ">&STDOUT"; }

open(FILE,${file});

#
####################################
# Current Date
####################################
#
# Get the all the values for current time
                                                                                          
$date = localtime(time);
                                                                                          
#
# Grab the current day, named month, and year
#
                                                                                          
@tmp = split(/\s+/, $date);
$day = $tmp[2];
$month = $tmp[1];
$year = $tmp[4];

printf FILE "                               DAYS SINCE CHECKIN (PAST 1 YEARS)\n";
printf FILE "\n";
printf FILE "DATE: $day $month $year\n";
printf FILE "\n";
printf FILE "SITE      MAGICC             GCMS               SIL              PREP\n";
printf FILE "      avg min max num   avg min max num   avg min max num   avg min max num\n";
printf FILE "----  ---------------   ---------------   ---------------   ---------------\n";

foreach $field ( @infolist )
{
   #print "***********************: ".@magicc." ".@gcms." ".@sil." ".@prep."*************\n";
   #print "$field\n";
   if ( $field ne '' )
   {
      @sitedays = split(/~/,$field);
      if ( $prevsite ne $sitedays[0])
      {
         if ( $prevsite ne '???' )
         {
            $magiccsum = 0;
            $magiccmin = 999;
            $magiccmax = -999;
            $gcmssum = 0;
            $gcmsmin = 999;
            $gcmsmax = -999;
            $silsum = 0;
            $silmin = 999;
            $silmax = -999;
            $prepsum = 0;
            $prepmin = 999;
            $prepmax = -999;
                                                                                          
            foreach $num ( @magicc )
            {
               $num = round($num);
               $magiccsum = $magiccsum + $num;
               if ( $num < $magiccmin ) { $magiccmin = $num; }
               if ( $num > $magiccmax ) { $magiccmax = $num; }
            }
            foreach $num ( @gcms )
            {
               $num = round($num);
               $gcmssum = $gcmssum + $num;
               if ( $num < $gcmsmin ) { $gcmsmin = $num; }
               if ( $num > $gcmsmax ) { $gcmsmax = $num; }
            }
            foreach $num ( @sil )
            {
               $num = round($num);
               $silsum = $silsum + $num;
               if ( $num < $silmin ) { $silmin = $num; }
               if ( $num > $silmax ) { $silmax = $num; }
            }
            foreach $num ( @prep )
            {
               #print "$num\n";
               $num = round($num);
               $prepsum = $prepsum + $num;
               if ( $num < $prepmin ) { $prepmin = $num; }
               if ( $num > $prepmax ) { $prepmax = $num; }
            }
                                                                                          
            $magiccnum = scalar @magicc;
            $gcmsnum = scalar @gcms;
            $silnum = scalar @sil;
            $prepnum = scalar @prep;
                                                                                          
            if ( $magiccnum != 0 )
            {
               printf FILE "%3s   %3d %3d %3d %3d   ", $prevsite, round($magiccsum/$magiccnum), $magiccmin, $magiccmax, $magiccnum;
            }
            else
            {
               printf FILE "%3s     -   -   -   -   ", $prevsite;
            }
                                                                                          
            if ( $gcmsnum != 0 )
            {
               printf FILE "%3d %3d %3d %3d   ", round($gcmssum/$gcmsnum), $gcmsmin, $gcmsmax, $gcmsnum;
            }
            else
            {
               printf FILE "  -   -   -   -   ";
            }
                                                                                          
            if ( $silnum != 0 )
            {
               printf FILE "%3d %3d %3d %3d   ", round($silsum/$silnum), $silmin, $silmax, $silnum;
            }
            else
            {
               printf FILE "  -   -   -   -   ";
            }                                                                                           
            if ( $prepnum != 0 )
            {
               printf FILE "%3d %3d %3d %3d\n", round($prepsum/$prepnum), $prepmin, $prepmax, $prepnum;
            }
            else
            {
               printf FILE "  -   -   -   -\n";
            }
         }
         $#magicc = -1;
         $#gcms = -1;
         $#sil = -1;
         $#prep = -1;
         $prevsite = $sitedays[0];
      }

      if ( $sitedays[1] ne '-999' )
      {
         $magicc[++$#magicc] = $sitedays[1];
      }
      if ( $sitedays[2] ne '-999' )
      {
         $gcms[++$#gcms] = $sitedays[2];
      }
      if ( $sitedays[3] ne '-999' )
      {
         $sil[++$#sil] = $sitedays[3];
      }
      if ( $sitedays[4] ne '-999' )
      {
         $prep[++$#prep] = $sitedays[4];
      }
                                                                                          
      #print "$field\n";
   }
}

close(FILE);

unlink($tmpfile);

#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
#

