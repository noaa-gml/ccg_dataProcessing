#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Look at each species-dependent raw file.
# Verify that there is a corresponding "site"
# entry in the "flask_data" table.
#
# July 20, 2005 - kam
# September 11, 2006 - kam
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "date|d=s", "help|h", "outfile|o=s", "parameter|g=s", "strategy|st=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

@date = ($Options{date}) ? split(/,/, $Options{date}) : ("", "");
@params = ($Options{parameter}) ? split ',', lc($Options{parameter}) : ('co2', 'ch4', 'co', 'h2', 'n2o', 'sf6');

$file = ($Options{outfile}) ? $Options{outfile} : '';
$strat_abbr = ($Options{strategy}) ? $Options{strategy} : 'flask';
#
#######################################
# Initialization
#######################################
#
$strategy = (lc($strat_abbr) eq 'pfp') ? 'aircraft' : 'flask';
$today = &SysDate();
$narr = 0; 
@arr = ();
#
# If date is not specified, use current year
#
@tmp = split(/-/, $today);

if ($date[0] eq "") { @date = ($tmp[0]); }
if ($#date == 0) { push @date, $date[0]; }
#
# Prepare date constraints
#
($yr1, $mo1, $dy1) = split(/-/, $date[0]);

if ($mo1 eq "") { $mo1 = '01'; $dy1 = '01'; }
if ($dy1 eq "") { $dy1 = '01'; }

$date[0] = sprintf("%4.4d-%2.2d-%2.2d", $yr1, $mo1, $dy1);

($yr2, $mo2, $dy2) = split(/-/, $date[1]);

if ($mo2 eq "") { $mo2 = '12'; $dy2 = '31'; }
if ($dy2 eq "") { $dy2 = '31'; }

$date[1] = sprintf("%4.4d-%2.2d-%2.2d", $yr2, $mo2, $dy2);
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#
#######################################
# Loop thru raw files
#######################################
#
foreach $param (@params)
{
   #
   # Get parameter number
   #
   $param_num  = &get_field("num", "gmd.parameter", "formula", $param);
   #
   # instrument directories by parameter
   #
   $dir = "/projects/${param}/${strategy}/";
   opendir(DIR, $dir);
   local(@insts) = readdir(DIR);
   closedir(DIR);

   foreach $inst (@insts)
   {
      next if $inst eq ".";
      next if $inst eq "..";
      next if length($inst) ne 2;
      #
      # year directories by instrument
      #
      $dir = "/projects/${param}/${strategy}/${inst}/raw/";
      opendir(DIR, $dir);
      local(@years) = readdir(DIR);
      closedir(DIR);

      foreach $year (@years)
      {
         next if length($year) ne 4;
         next if ($year < $yr1 || $year > $yr2);
         #
         # raw files by year
         #
         $dir = "/projects/${param}/${strategy}/${inst}/raw/${year}/";
         opendir(DIR, $dir);
         local(@files) = readdir(DIR);
         closedir(DIR);

         foreach $file (@files)
         {
            @field = split(/\./, $file);

            next if ($field[$#field] ne $param);
            next if (length($field[0]) != 10);
            next if ($field[0] lt $date[0] || $field[0] gt $date[1]);
            #
            # Read raw file
            #
            print "Working on ${dir}${file} ...\n";

            open(FILE, $dir.$file) || die "Can't open $dir.$file.\n";
            @rows = <FILE>;
            close(FILE);
            chop(@rows);
            foreach $row (@rows)
            {
               next if (substr($row, 0, 3) ne "SMP");
               ($code, $num, $yr, $mo, $dy, $hr, $mn, @junk) = split ' ', $row;
               $date = "${yr}-${mo}-${dy}";
               $time = "${hr}:${mn}";
               #
               # Is there an entry for this sample in DB?
               #
               $select = "SELECT COUNT(event_num)";   
               $from = " FROM flask_data";
               $where = " WHERE event_num = $num";
               $and = " AND program_num = 1";
               $and = "${and} AND parameter_num = ${param_num}";
               $and = "${and} AND inst = '${inst}'";
               $and = "${and} AND date = '${date}'";
               $and = "${and} AND time = '${time}'";
               $sql = $select.$from.$where.$and;

               $sth = $dbh->prepare($sql);
               $sth->execute();
               @tmp = $sth->fetchrow_array();
               $sth->finish();
               
               next if $tmp[0] == 1;

               $arr[$narr++] = "${inst} ${file}  ${row}";
            }
         }
      }
   }
}
#
#######################################
# Write results
#######################################
#
if ($file) { $file = ">${file}"; } else { $file = ">&STDOUT"; }

open(FILE, ${file});
foreach $str (@arr) { print FILE "${str}\n"; }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
exit;

sub showargs()
{
   print "\n#########################\n";
   print "ccg_dbcc\n";
   print "#########################\n\n";
   print "Verify that there is an entry in the CCGG DB for each sample\n";
   print "in a raw file. Results are sent to STDOUT\n\n";
   print "Options:\n\n";
   print "-d, -date=[date range]\n";
   print "     Date (yyyy-mm-dd).  Specify a single day or range.\n";
   print "     If no date is specified, current year is used.\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-g, -parameter=[parameter(s)]\n";
   print "     paramater formulae\n";
   print "     Specify a single parameter (e.g., -parameter=co2)\n";
   print "     or any number of parameters\n\n";
   print "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n\n";
   print "# Check flask_data for co2 measurements in the year 2001\n";
   print "#    with strategy flask\n";
   print "   (ex) ccg_dbcc -date=2001 -parameter=co2 -strategy=flask\n\n";
   print "# Check flask_data for ch4 measurements between 2002-01-01\n";
   print "# and 2003-01-01 with strategy flask\n";
   print "   (ex) ccg_dbcc -date=2002-01-01,2003-01-01 -parameter=ch4\n";
   print "           -strategy=flask\n";
   exit;
}
