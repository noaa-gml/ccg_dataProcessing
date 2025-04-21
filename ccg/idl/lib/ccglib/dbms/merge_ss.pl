#!/usr/bin/perl
#
#SEE NOTES below from jwm.. this has become outdated (site file indexes off.. not worth fixing all functionality unless someone is using. 
#Just correcting the update mode for now (and disabling flag merge which happens again elsewhere when actually sending to db anyway)
#jwm 1/2020
#
# Courtesy of KWT.
# August 18, 2005
#
# ==========================================================================
# Print usage instructions

sub usage {
    die <<"EndUsage";
usage: merge_ss (-g gas -d sitedir | -n) [-u] [-h]

Version $Version
Merge site strings into site file.
Required Parameters:
     -g gas     -- Gas species for the input data.

     -d sitedir -- Directory with location of site files. 

     -n         -- Check input site strings with network site files rather
	           than species site files.  The -u, -d and -g  options are 
		   ignored if -n is specified.

Optional Parameters:

     -u -- Update the site files with input site strings.  This option is
           required to make any changes to site files.
	   If -u is not included, program checks to see if input site string
           exists in site directory, and prints a message if it does not.

     -l file -- Name of file to log messages when updating site files.

     -h -- Help.  Just display this message and quit.

Either -d and -g together  or -n must be specified.

EndUsage
}

# ==========================================================================
# Initialize variables

$Version    = "1.0";
$update     = 0;
$network    = 0;
$sitefile   = "";
$tsite      = "";
$tyr        = "";
$file_read  = 0;
$ix         = -1;
$uselog     = 0;
$logfile    = "";
$def_header = "selected on 1900 12 31 thru sample 12345-78 adate 2001 03 15";

# ==========================================================================
# Get the command-line options

require "getopts.pl";
&Getopts('hnud:g:l:');
if ($@ || $opt_h) { &usage; }

if ($opt_u) { $update  = 1; }
if ($opt_n) { $network = 1; }

if ($opt_d) { $datadir = $opt_d; }
if ($opt_g) { $species = $opt_g; }
if ($opt_l) { $logfile = $opt_l; }

if ( $network) {
	$datadir = "/projects/network/flask/site";
} else {
	if (! $datadir) { die "Site directory not specified.\n"; }
	if (! -d $datadir) { die "Directory $datadir does not exist.\n"; }
	if (! $species) { die "Gas species not specified.\n"; }
}


if ($logfile) {
	open (LOGFILE, ">>$logfile");
	$uselog = 1;
}



#==========================================================================
#  Read a string from stdin.  Get the station code and year.
#  If it is a different station from previous string, or
#  if the same station then write data back to file, read in new file.
#
#  Look for string in flask string array. If it is there, put new string
#  in its place.
#  If not,  and updating site file, add to site file string array,
#  otherwise print a message saying string not found.

	while (<>) {
		($site, $yr) = split (' ', $_, 3);

		if ( ($site ne $tsite) ) {
			if ($update && $file_read) {
				write_site ($sitefile, $header, @a);
			}

			if ($network) {
				$sitefile = sprintf ("%s/%.3s", $datadir, 
					   lc($site));
			} else {
				$sitefile = sprintf ("%s/%.3s.%s", $datadir, 
					   lc($site), $species);
			}

			print STDERR "Working on $site...\n";
			if (open (SITE,$sitefile)) {
				$header = <SITE>;
				@a = sort(<SITE>);
				$file_read = 1;
				close (SITE);
				$ix = -1;
			} else {
				# $header=sprintf ("%3s %s\n", $species, $def_header);
				@a="";
				$file_read = 1;
				$ix = -1;
			}
		}
		

# 
# Search through site string list for matching line.
# If updating, must match both sample info and analysis date.
# Copy flag from site string to new string, replace old site string with
# new site string.
# If not updating, get all lines that match sample info (multiple aliquots),
# search through these to see if analysis date matches, if so check mixing ratio.
#

		if ($update) { 
			$ix = &search ($_, @a);
			if ($ix >= 0) {
				#jwm - 1/2020 - the offsets of both the search and replacing are off on current site files used by Syliva...
				#not sure who else may be using these, but I fixed to work with her files and disabled functions she doesn't 
				#use(flag merging because that happens in ccg_flaskupdate anyway).  We'll see if anyone complains.. they should be using a more modern implementation anyway.
				#substr($_, 41, 3) = get_flag ($_, $a[$ix]);
				$a[$ix] = $_;
			} else {
				push @a, $_; 
			}
		} else {
			print("THIS feature has been deprecated (indexes incorrect/out of date formats).  Let john.mund\@noaa.gov know if you need this re-implemented.\n");
			exit(1);
			($ix, $nmatch, @match) = &search2 ($_, @a);
			if ($ix < 0) {
				chop($_);
				print "$_ not found.\n";
			} elsif ( ! $network) {
				$a1 = substr($_, 45);
				$gotmatch = 0;
				foreach $i (0..$nmatch) {
					$a2 = substr($match[$i], 45);
					if ($a1 eq $a2) {
						$gotmatch = 1;
						$mr1 = substr($_, 32, 8);
						$mr2 = substr($match[$i], 32, 8);
						$diff = abs($mr1 - $mr2);
						if ( $diff > 0.011) {
							chop($_);
							print "$_ mixing ratio mismatch ($mr2, $diff).\n";
						}
						last;
					}
				}

				if (! $gotmatch) {
					chop($_);
					print "$_ analysis date mismatch.\n";
				}
					
			}
		}
		$tsite = $site;
		$tyr = $yr;
	}

# If updating, write site string back to site file.

	if ($update && $file_read) {
		write_site ($sitefile, $header, @a);
	}


# ==========================================================================
# Set the flag columns in the input string correctly.
# If the 1st flag column in either the new string or old string is
# an '*', use the flag from the new string.
# If the 3rd flag column in the new string is not '.', keep it and use 
# columns 1 and 2 from the old string.
# If the 3rd flag column in the new string is '.', 
# use the flags from the old string.

sub get_flag
{
	my ($newstring, $oldstring) = @_;
	my $flag;
#Jwm 1/2020 - these indexes are no longer correct for site files being used by instaar...
	if (substr($newstring, 41, 1) eq "*" || substr($oldstring, 41, 1) eq "*" ) {
		$flag = substr ($newstring, 41, 3);
	} elsif (substr($newstring, 43, 1) ne ".") {
		$flag = sprintf ("%s%s", substr($oldstring, 41, 2), substr($newstring, 43,1));
	} else {
		$flag = sprintf ("%s%s", substr($oldstring, 41, 3));
	}
	return $flag;
}

# ==========================================================================
sub write_site
{
	local ($sitefile, $header, @lines) = @_;

	if ($uselog) {print LOGFILE "\tUpdating $sitefile.\n";}
	if (open (OUTFILE, ">$sitefile")) {
		print OUTFILE $header;
		print OUTFILE sort(@lines);
		close (OUTFILE);
	} else {
		print STDERR "Can't open $sitefile for writing.\n";
		if ($uselog) {print LOGFILE "Can't open $sitefile for writing.\n";}
	}
}

# ==========================================================================
# Search through site file string list for the line that matches the input line.
# A match is if the first 31 characters and everything after the flag agree.
# That is, ignore mixing ratio and flag when matching.

sub search
{
	local ($line, @list) = @_;
	my $i;
	my $s1;
	my $s2;
	my $start;
#updating index locations (and below)
#jwm 1/2020
	#$s1 = substr ($line, 0, 31);
	#$s2 = substr ($line, 45);
	$s1 = substr ($line, 0, 32);
        $s2 = substr ($line, 48);
	if ($ix == -1) {
		$start = 0;
	} else {
		$start = $ix;
	}
	for $i ($start..$#list) {
		$s3 = substr($list[$i], 0, 32);#was 31
		if ($s1 eq $s3) {
			if ($s2 eq substr($list[$i], 48)) {#was 45
				return $i;
			}
		}
		last if ($s1 lt $s3);
	}

	return -1;
}

# ==========================================================================
# Search through site file string list for the lines that match the input line.
# A match is if the first 31 characters agree.
# That is, ignore mixing ratio and flag when matching.

sub search2
{
	local ($line, @list) = @_;
	my $i;
	my $s1;
	my $start;

	$s1 = substr ($line, 0, 31);
	if ($ix == -1) {
		$start = 0;
	} else {
		$start = $ix;
	}

	$first = -1;
	$n = 0;
	@match = "";
	for $i ($start..$#list) {
		$s3 = substr($list[$i], 0, 31);
		last if ($s1 lt $s3);
		if ($s1 eq $s3) {
			if ($first < 0) {$first = $i;}
			$match[$n] = $list[$i];
			$n++;
		}
	}

	return ($first, $n, @match);
}
