#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

# Provide all information related to the user-supplied site(s).
# The GLOBALVIEW standard is supported.
# June 29, 2007 - kam

# Modified - March 14, 2014 (kam)
# Moved contents of obspack.site_aux to gmd.site making site_aux code added
# in June 2012 unnecessary. site_aux code removed.

# Modified - June 6, 2012 (kam)
# Modified again to read obspack.site_aux table before looking
# in text file.  Also, added 'fieldlist' argument.  Allows user 
# to specify output fields. Note: to-do.  Change text file to
# name:value pairing to work with fieldlist argument.

# Modified - March 28, 2012 (kam)
# Modified to accommodate an additional site information text file.  
# The routine will first query the GMD DB for site information. If
# the site is not found, the routine will then look for the site code in 
# /ccg/src/db/ccg_siteinfo.txt, the default "addl_siteinfo_file".  The user
# may also supply a alternate file but it must be identically formatted to
# the default text file.
#
# Columns in optional additional site information text file
#
# col 1: site code (not restricted to 3-characters).  If a delimiter is required, use a hyphen (-)
# col 2: site name
# col 3: site country
# col 4: lat
# col 5: lon
# col 6: elev (masl)
# col 7: sample height (magl)
# col 8: LT to UTC conversion
# col 9: comment
#
#  (ex) BRN | Burns, Oregon | United States | 44.47 | -119.69 | 1398 | 6.5 | 8 | Mathias Geockede 2008-08-13
#  (ex) lat20-alt3500_99D2 | name | North America | 20 | -999.99 | 3500 | 0 | -99 | provided by Arlyn
#
# If an entry is made in the GMD DB for a site in ccg_siteinfo.txt, the
# entry in ccg_siteinfo.txt should be removed.

#
#######################################
# Parse Arguments
#######################################
#
if ( $#ARGV == -1 ) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "code|c=s", "addl_siteinfo_file=s", "fieldlist|f=s", "outfile|o=s", "site|s=s");

if ( $noerror != 1 ) { exit; }

if ( $Options{help} ) { &showargs() }

if ( !($Options{code}) and !($Options{site}) ) { &showargs() }

@sites = ();
$list = ( $Options{code} ) ? $Options{code} : $Options{site};
@tmp = split(',', $list);
for ( $i=0; $i<@tmp; $i++ ) { $sites[$i] = lc($tmp[$i]); }

# Field list
$fieldlist = ( $Options{fieldlist} ) ? $Options{fieldlist} : "num,code,name,country,lat,lon,elev,lst2utc";

# additional site information input file?
$addl_siteinfo_file = ( $Options{addl_siteinfo_file} ) ? $Options{addl_siteinfo_file} : "/ccg/src/db/ccg_siteinfo.txt";

# destination file?
$outfile = ( $Options{outfile} ) ? $Options{outfile} : "";
#
#######################################
# Initialization
#######################################
#
@result = ();
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get site information for each site
#######################################
#
foreach $site (@sites)
{
   ( $code, $ext ) = split(/_/, $site);
   $code_ = $code;

   # Get Site information

   $sql = "SELECT ${fieldlist} FROM gmd.site WHERE code='${code}'";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   @siteinfo = $sth->fetchrow_array();
   $sth->finish();

   if ( $#siteinfo == -1 )
   {

      # try again using only 1st 3 characters of code
      # added 2008-07-31 (kam)

      # changed $z to $code otherwise cannot get at cooperating agency or intake height when
      # code from split command above is lef010, car030, etc.  (2009-10-14, kam)
      # $z = substr( $code, 0, 3 );

      $code = substr( $code, 0, 3 );

      $sql = "SELECT ${fieldlist} FROM gmd.site WHERE code='${code}'";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      @siteinfo = $sth->fetchrow_array();
      $sth->finish();

   }

   if ( $#siteinfo == -1 && $addl_siteinfo_file ne "" )
   {

      # try again if addl_siteinfo_file argument is set
      # added 2012-03-28 (kam)

      if ( -e $addl_siteinfo_file == 0 )
      { 
         print STDERR "${addl_siteinfo_file} does not exist.";
         exit;
      }

      @addlsites = &ReadFile( $addl_siteinfo_file );
      @addlsites = grep !/^#/, @addlsites;
      
      # (ex) BRN | Burns, Oregon | United States | 44.47 | -119.69 | 1398 | 6.5 | 8 | Mathias Geockede 2008-08-13

      @z = grep /^${code_}/i, @addlsites;

      if ( $#z != -1 )
      {
         @fields = split( /\|/, $z[0] );
         for ( $i=0; $i<@fields; $i++ ) { $fields[$i] = &trim( $fields[$i] ); }
         push ( @siteinfo, -1, @fields[0..9] );
         #@siteinfo=@fields;
      }
   }

   next if ( $#siteinfo == -1 );

   @labinfo = ();
   @strategyinfo = ();
   @platforminfo = ();
   @coopinfo = ();
   @intakeinfo = ();

   if ( $ext ne "" )
   {
      $labno = substr( $ext, 0, 2 );

      $gv_strategy = substr($ext, 2, 1);
      $gv_platform = substr($ext, 3, 1);

      # Get Lab information

      $sql = "SELECT num, name, country, abbr, logo FROM obspack.lab WHERE num=${labno}";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      @labinfo = $sth->fetchrow_array();
      $sth->finish();
 
      next if ($#labinfo == -1);

      # Get Strategy information

      $sql = "SELECT abbr, name FROM gv_strategy WHERE abbr='${gv_strategy}'";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      @strategyinfo = $sth->fetchrow_array();
      $sth->finish();

      next if ($#strategyinfo == -1);

      # Get Platform information

      $sql = "SELECT num, name FROM gv_platform WHERE num=${gv_platform}";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      @platforminfo = $sth->fetchrow_array();
      $sth->finish();

      next if ($#platforminfo == -1);

      # Get Cooperating Agency and Sample Intake Height if lab_no == 1

      @coopinfo = ( "", "" );
      @intakeinfo = ( "" );

      if ($labno == 1 or $labno == 99)
      { 
         # This logic is approximately true

         ($ccgg_project_num, $ccgg_strategy_num) = &GV2CCGG ($gv_strategy, $gv_platform);

         # Cooperating Agency

         $sql = "SELECT site_coop.name, site_coop.abbr FROM site_coop,gmd.site WHERE gmd.site.code='${code}'";
         $sql = "${sql} AND gmd.site.num=site_num AND strategy_num=$ccgg_strategy_num AND project_num=$ccgg_project_num";
         $sth = $dbh->prepare($sql);
         $sth->execute();
         @tmp = $sth->fetchrow_array();
         $sth->finish();

         if ( $#tmp != -1 ) { @coopinfo = @tmp }

         # Intake Height

         $sql = "SELECT intake_ht FROM site_desc,gmd.site WHERE gmd.site.code='${code}'";
         $sql = "${sql} AND gmd.site.num=site_num AND strategy_num=$ccgg_strategy_num AND project_num=$ccgg_project_num";
         $sth = $dbh->prepare($sql);
         $sth->execute();
         @tmp = $sth->fetchrow_array();
         $sth->finish();

         if ( $#tmp != -1 ) { @intakeinfo = @tmp }
      }
   }

   # intake height exists in @siteinfo when site information is from additional site information file.
   # Remove intake height from siteinfo under these conditions and put in @intakeinfo.
   # This bit of code is not robust and will need to be tended to if the content coming
   # from the GMD DB or the additional site information file changes.
   
   if ( $#siteinfo == 8 )
   {
      @intakeinfo = ( $siteinfo[7] );
      @siteinfo = ( @siteinfo[0..6], $siteinfo[8] );
   }

   # Build result string

   push @result, join('|', @siteinfo, @labinfo, @strategyinfo, @platforminfo, @coopinfo, @intakeinfo);

}
#
#######################################
# Write results
#######################################
#
$outfile = ($outfile) ? $outfile : "&STDOUT";
open( FILE, ">${outfile}" );


foreach $item (@result) { print FILE "${item}\n"; }
close(FILE);
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
   print "ccg_siteinfo\n";
   print "#########################\n\n";
   print "Provide all information pertaining to user-supplied site(s). The GLOBALVIEW standard \n";
   print "is supported. If the site alone is specifed, the return includes the following pipe (|)\n";
   print "delimited fields...\n\n";
   print "site_num, site_code, site_name, site_country, site_lat, site_lon, site_elev, site_lst2utc\n\n";
   print "If the GLOBALVIEW standard is used, the following additional fields are provided.\n\n";
   print "lab_num, lab_name, lab_country, lab_abbr, lab_logo\n";
   print "sampling_strategy_abbr, sampling_strategy_name\n";
   print "platform_num, platform_name.\n\n";
   print "If the GLOBALVIEW standard is used and lab is ESRL, the following additional fields are provided.\n\n";
   print "coop_name, coop_abbr, intake_ht\n\n";
   print "\nOptions:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-c, -site=[site(s)]\n";
   print "     Specify a single site (e.g., -site=BRW_01D0)\n";
   print "     or any number of sites (e.g., -site=BRW_01D0,SBL_06C0,LEF_01C3,CAR_01D2,smo)\n\n";
   print "-f, -fieldlist=[list of fields]\n";
   print "     Specify a list of DB table fields to output (e.g., -fieldlist=name or -f='lat,lon,elev,name'\n";
   print "     If not specified, default is 'num,code,name,country,lat,lon,elev,lst2utc'.\n\n";
   print "-i, -addl_siteinfo_file=[addl_siteinfo_file]\n";
   print "     An additional site information text file.  The routine will first query the\n";
   print "     GMD DB.  If the site is not found, it will then look for the site code in the\n";
   print "     addl_siteinfo_file.  If none is specified, a default is used (/ccg/src/db/ccg_siteinfo.txt).\n";
   print "     The file is expected to have the following format...\n\n";
   print "     # Columns are delimited by the pipe (|) and defined as follows:\n";
   print "     #\n";
   print "     # col 1: 3-letter code\n";
   print "     # col 2: site name\n";
   print "     # col 3: site country\n";
   print "     # col 4: lat\n";
   print "     # col 5: lon\n";
   print "     # col 6: elev (masl)\n";
   print "     # col 7: sample height (magl)\n";
   print "     # col 8: LT to UTC conversion\n";
   print "     # col 9: comment [optional]\n\n";
   print "     (ex) BRN | Burns, Oregon | United States | 44.47 | -119.69 | 1398 | 6.5 | 8 | Mathias Geockede 2008-08-13\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "     (ex) ccg_siteinfo.pl -site=brw_01D0,smo,sbl_06C0,sbl_06D0 -outfile=/home/ccg/ken/temp\n";
   exit;
}
