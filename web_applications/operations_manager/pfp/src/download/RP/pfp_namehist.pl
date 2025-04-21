#!/usr/bin/perl

# Program to get the new name of aircraft history file,
# based on date and time of first sample.
#

%months = ('JAN', 1, 'FEB', 2, 'MAR', 3, 'APR',  4, 'MAY',  5, 'JUN',  6,
	   'JUL', 7, 'AUG', 8, 'SEP', 9, 'OCT', 10, 'NOV', 11, 'DEC', 12);


# Read each history file, get first sample time.
# Then generate new file name.

	$year = $ARGV[0];
	$file = $ARGV[1];
	open (FILE, $file) || die "Can't open file $file.\n";

#	$a = `basename $file`;
#	$year = substr ($a, 0, 4);

	while (<FILE>) {
		if ($_ =~ "Location History") {
			$_ = <FILE>;
			$_ = <FILE>;
			if ($_ =~ "location and time results") { <FILE>; }
			for ($i=0; $i<20; $i++) {

				$_ = <FILE>;
				($sample, $slat, $slon, $elat, $elon, $stime, $etime, $tz, $mon, $day) = split (' ');
				$hour = substr($stime, 0, 2);
				$minute = substr($stime, 3, 2);
				last if ($day != 0);
			}
		}
	}

	if ($day == 0) {
		print "Cannot rename $file, did not find a valid sample date.\n";
	} else {
		$basenewfile = sprintf ("%4d-%02d-%02d.%02d%02d", $year, $months{uc($mon)}, $day, $hour, $minute);

		print "$basenewfile\n";
	}

