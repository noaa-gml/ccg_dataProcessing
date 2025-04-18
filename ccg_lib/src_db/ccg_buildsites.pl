#!/usr/bin/perl
#
# Build text site files
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Get Gas information
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "directory|d=s", "help|h", "parameter|g=s", "strategy|st=s", "update|u");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

$param = $Options{parameter};
$param =~ tr/A-Z/a-z/;

@params = ($param) ? $param : ("co2","ch4","co","h2","n2o","sf6","co2c13","co2o18","ch4c13","co2c14");

$strat_abbr = ($Options{strategy}) ? $Options{strategy} : 'flask';
$strategy = ($strat_abbr eq 'pfp') ? 'aircraft' : $strat_abbr;

$ddir = ($Options{directory}) ? $Options{directory} : '';

$update = ($Options{update}) ? 1 : 0;
#
#######################################
# Initialization
#######################################
#
$perl = "/projects/src/db/ccg_flask.pl";
$tmpfile = "/projects/tmp/ccggdb".int(10**8*rand());
@tmp = localtime();
$today = sprintf("%4.4d %2.2d %2.2d",1900+$tmp[5],1+$tmp[4],$tmp[3]);
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get strat_num if strategy is specified
#######################################
#
$strat_num = &get_field("num","strategy","abbr",$strat_abbr);
#
#
#######################################
# Get project site list
#######################################
#
$select = "SELECT DISTINCT code";
$from = " FROM gmd.site,site_desc";
$where = " WHERE gmd.site.num=site_desc.site_num";
$and = " AND site_desc.strategy_num=$strat_num";

$sql = $select.$from.$where.$and;

$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n = 0;
@list = ();
while (@tmp = $sth->fetchrow_array()) { @list[$n++] = join('|',@tmp) }
$sth->finish();
#
#######################################
# Construct "old-style" site file
#######################################
#
foreach $code (@list)
{
   $code =~ tr/A-Z/a-z/;

   foreach $param (@params)
   {
      $param =~ tr/A-Z/a-z/;


      $tmp = "${perl} -site=${code} -parameter=${param} -strategy=${strat_abbr} -oldstyle -outfile=${tmpfile} -noseconds -nouncertainty -noprogram";
      #print "$tmp\n";
      system($tmp);

      open(FILE, $tmpfile) || die "Can't open file $tmpfile.\n";
      @arr = <FILE>;
      close(FILE);

      chop(@arr);

      next if ($#arr eq -1);

      @arr = sort @arr;

      #print "${code}.${param}\n";

      $head = "${code}.${param} created on ${today} using data extracted from the CCGG DB";

      if ($update) 
      { $ddir = "/projects/${param}/${strategy}/site/"; }

      if ($ddir) { $outfile = ">${ddir}${code}.${param}"; }
      else { $outfile = ">&STDOUT"; }

      open(FILE,$outfile);
      #print FILE "${head}\n";
      foreach $row (@arr) { print FILE "${row}\n"; }
      close(FILE);
   }
}
unlink($tmpfile);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
#
#######################################
# Subroutines
#######################################
#
sub showargs()
{
   print "\n#########################\n";
   print "ccg_buildsite.pl\n";
   print "#########################\n\n";
   print "Construct an old-style site file including header.\n";
   print "Results are sent to STDOUT [default].\n";
   print "Options:\n\n";
   print "-d, -directory=[directory]\n";
   print "     destination directory\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-g, -parameter=[parameter(s)]\n";
   print "     Parameter formula (e.g., co2, co2c13, ch4).  If not\n";
   print "     specified, all parameters will be considered\n";
   print "     (e.g., co2, ch4, co, h2, n2o, sf6, co2c13, co2o18)\n\n";
   print "     Defaults to: co2,ch4,co,h2,n2o,sf6,co2c13,co2o18,ch4c13,co2c14\n";
   print "-st, -strategy=[strategy]\n";
   print "     Strategy identifier (e.g., flask [default] or pfp)\n\n";
   print "-u, -update\n";
   print "     Update old-style site files in appropriate directory\n";
   print "     (e.g., /projects/co2/flask/site/, /projects/h2/aircraft/site/).\n";
   print "     If specified, option 'd' is ignored\n\n";
   print "# Make all site flask [default] files for co2 and put them in\n";
   print "#    /home/ccg/ken/tmp/\n";
   print "   (ex) ccg_buildsite.pl -parameter=co2 -directory=/home/ccg/ken/tmp/\n\n";
   print "# Update all site files for co2 in /projects/co2/aircraft\n";
   print "   (ex) ccg_buildsite.pl -parameter=co2 -strategy=pfp -update\n\n";
   print "# Update all site files for co2, ch4, co, h2, n2o, sf6, co2c13,\n";
   print "#    co2o18, ch4c13, co2c14 in /projects/co2/flask\n";
   print "   (ex) ccg_buildsite.pl -update\n";
   exit;
}

