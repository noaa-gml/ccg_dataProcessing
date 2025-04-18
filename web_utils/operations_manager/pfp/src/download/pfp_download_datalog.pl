#!/usr/bin/perl
#
# pfp_download_datalog.pl
#
# Script to download Portable Flask Package (PFP) Data log
#
$projdir = "/var/www/html/om/";
$workdir = "${projdir}pfp/src/";

$serialport = ($ARGV[0]) ? $ARGV[0] : "/dev/ttyr300";
$outfile = ($ARGV[1]) ? $ARGV[1] : "";
#
# Download the datalog file from PFP
#
if ($outfile) { $err = system("${workdir}download/get_pfp_datalog_v306j ${serialport} > ${outfile}"); }
else { $err = system("${workdir}download/get_pfp_datalog_v306j ${serialport} "); }

if ( $outfile ) 
{
   if ( -z $outfile ) { unlink($outfile); }
   else
   {
      # Reformat the text so that  are removed and each
      # line has an eol (\r\l)
      open(FILE, $outfile);
      @arr = <FILE>;
      close(FILE);

      @outarr = ();
      foreach $line ( @arr )
      {
         chomp($line);
         $line =~ s///g;
         $line =~ s/\n/\r\l/g;

         push(@outarr, $line);
      }

      open(FILE, ">$outfile");
      foreach $line ( @outarr ) { print FILE "$line\n"; }
      close(FILE);
   }
}

if ($err)
{
        print "error running get_as_datalog\n";
	exit 2;
}

if (!($err) && $outfile) { chmod 0666, $outfile; }
