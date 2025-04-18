#!/usr/bin/perl
#
# pfp_edithis.pl
#
# Script to edit PFP history file given a PFP summary file
#

@months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
	   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

$sumfile=@ARGV[0];
#
# Read summary file
#
open (FILE, $sumfile) || die "Can't open file $sumfile.\n";
@sum=<FILE>;
close(FILE);
#
# Read corresponding history file
#
$hisfile=$sumfile;
$hisfile=~s/\.sum/\.his/;

open (FILE, $hisfile) || die "Can't open file $hisfile.\n";
@his=<FILE>;
close(FILE);
#
# Loop through summary file
#
for ($isum=0; $isum<@sum; $isum++)
{ 
	#
	# Parse summary string
	#
	($site,$yr,$mo,$dy,$hr,$mn,$id,$me,$lat,$lon,$alt,$flg,$z,$temp,$press,$rh)=split(' ',$sum[$isum]);

	($z,$sample_num)=split(/\-/,$id);
	$sample_num =~ s/^0//;
	#
	#************************************
	# Update Site History
	#************************************
	#
	if ($isum==0) {&update_site_history(*his,$site);}
	#
	#************************************
	# Update Serial Number History
	#************************************
	#
	if ($isum==0) {&update_serial_number_history(*his,$id);}
	#
	#************************************
	# Update Location History table
	#************************************
	#
   	&update_location_history(*his,$mo,$dy,$hr,$mn,$lat,$lon,$sample_num);
	#
	#************************************
	# Update Altitude History
	#************************************
	#
     	&update_altitude_history(*his,$alt,$sample_num);
	#
	#************************************
	# Update Ambient Conditions
	#************************************
	#
  	&update_ambient_conditions(*his,$temp,$press,$rh,$sample_num);
}
#
# Send edited history to stdout
#
for ($i=0; $i<@his; $i++) { print $his[$i]; }


sub	update_site_history
{
local(*his,$site)=@_;

	$format="%s %s  %s";

	for ($i=0; $i<@his; $i++)
	{ 
		if ($his[$i] =~ "Site History") { $i1=$i; }
		if ($his[$i] =~ "Serial Number History") { $i2=$i; }
	}
	for ($i>$i1; $i<$i2; $i++)
	{
		next if (($z=grep(/[a-z,A-Z]/,$his[$i]))==0);
		if ($his[$i] =~ "Site Code")
		{
			($a1,$a2,$a3)=split(' ',$his[$i]);
			$his[$i]=sprintf($format,$a1,$a2,$site);
		}
	}
}

sub	update_serial_number_history
{
local(*his,$id)=@_;

	for ($i=0; $i<@his; $i++)
	{ 
		if ($his[$i] =~ "Serial Number History") { $i1=$i; }
		if ($his[$i] =~ "Altitude History") { $i2=$i; }
	}
	for ($i>$i1; $i<$i2; $i++)
	{
		next if (($z=grep(/[a-z,A-Z]/,$his[$i]))==0);
		if ($his[$i] =~ "Serial Number")
		{
			($a1,$a2,$a3)=split(' ',$his[$i]);

			($a4,$a5)=split('\-',$id);
			#
			# if PFP id in history file has a hyphen 
			# then assume ##-## otherwise replace old with new.
			#
			if (($z=grep(/\-/,$a3))!=0)
			{
				$format="%s %s  %2.2d-%2.2d";
				$his[$i]=sprintf($format,$a1,$a2,$a4/100,$a4%100);
			}
			else
			{
				$format="%s %s  %2.2d%2.2d";
				$his[$i]=sprintf($format,$a1,$a2,$a4/100,$a4%100);
			}
		}
	}
}

sub	update_altitude_history
{
local(*his,$alt,$sample_num)=@_;
	#
	# Replace altitude
	#
	$format=" %2d %10d %10d %8d %10d %7d %7d\n";

	for ($i=0; $i<@his; $i++)
	{ 
		if ($his[$i] =~ "Altitude History") { $i1=$i+1; }
		if ($his[$i] =~ "Location History") { $i2=$i; }
	}
	for ($i=$i1; $i<$i2; $i++)
	{
		($a1,$a2,$a3,$a4,$a5,$a6,%a7)=split(' ',$his[$i]);
		next if (($z=grep(/[0-9]/,$a1))==0);
		if ($a1==$sample_num)
		{
			#
			# Convert from meters to feet
			#
			$his[$i]=sprintf($format,$a1,&round($alt*3.28084,1),$a3,$a4,$a5,$a6,$a7);
		}
	}
}

sub	update_location_history
{
local(*his,$mo,$dy,$hr,$mn,$lat,$lon,$sample_num)=@_;
	#
	# Update sample date/time and associated sample number
	#
	$format="  %2d %11.3f %8.3f %9.3f %8.3f     %2.2d:%2.2d  %s %s %.3s %2.2d \n";

	for ($i=0; $i<@his; $i++)
	{ 
		if ($his[$i] =~ "Location History") { $i1=$i+1; }
		if ($his[$i] =~ "Fill History") { $i2=$i; }
	}
	for ($i=$i1; $i<$i2; $i++)
	{
		(@a)=split(' ',$his[$i]);
		next if (($z=grep(/[0-9]/,$a[0]))==0);
		if ($a[0]==$sample_num)
		{
			$his[$i]=sprintf($format,$a[0],$lat,$lon,$a[3],$a[4],$hr,$mn,$a[6],$a[7],$months[$mo-1],$dy);
		}
	}
}

sub	update_ambient_conditions
{
local(*his,$temp,$press,$rh,$sample_num)=@_;

	$format=" %2d %13.1f %22.1f %19.1f\n";

	for ($i=0; $i<@his; $i++)
	{ 
		if ($his[$i] =~ "Ambient Conditions") { $i1=$i+1; }
	}
	$i2=$i;

	for ($i=$i1; $i<$i2; $i++)
	{
		($a1)=split(' ',$his[$i]);
		next if (($z=grep(/[0-9]/,$a1))==0);
		if ($a1==$sample_num)
		{
			$his[$i]=sprintf($format,$a1,$temp,$press,$rh);
		}
	}
}

sub	round
{
local($n,$power)=@_;

	$t=$n*(10.0**(-1*$power));
	$t1=($t<0) ? $t-0.5 : $t+0.5;
	return(int($t1)*(10.0**$power));
}
