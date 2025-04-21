#
#######################################
# Convert yr mo dy hr mn to decimal year
#######################################
#
sub date2dec
{
	my ($yr,$mo,$dy,$hr,$mn) = @_;

	my $i,$d,$leap,$dd;
	my @dim_noleap = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	my @dim_leap = (0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

	if (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0)) 
	{
		@dim = @dim_leap;
		$leap = 1;
	}
	else
	{
		@dim = @dim_noleap;
		$leap = 0;
	}

	for ($i=1,$d=$dy; $i<$mo; $i++) { $d += @dim[$i]; }

	$dd = $yr + (($d-1) * 24.0 + $hr + ($mn/60.0)) / ((365 + $leap) * 24.0);

 	return $dd;
}
#
#######################################
# Convert yr mo dy hr mn to decimal year
#######################################
#
sub dec2date
{
	my ($dd) = @_;

	my $leap,$yr,$mo,$dy,$hr,$mn;
	my @diy_noleap = (-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365);
	my @diy_leap = (-9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366);

	$yr = int $dd;

	if (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0)) 
	{
		@diy = @diy_leap;
		$leap = 1;
	}
	else
	{
		@diy = @diy_noleap;
		$leap = 0;
	}

	$decimal = $dd - $yr;
	$fhoy = $decimal * ((365.0 + $leap) * 24.0);
	$ihoy = int $fhoy;

	$mn = round(($fhoy - $ihoy) * 60.0,0);

	if ($mn == 60) { $mn = 0;  $ihoy++; }

	$doy = ($ihoy / 24.0) + 1.0;

	$mo = 0;
	do { $mo++; } while ($mo < 13 && $diy[$mo] < int $doy);
	$mo--;

	$dy = int($doy - $diy[$mo]);

	$hr = int($ihoy % 24.0);
	;
	return $yr, $mo, $dy, $hr, $mn;
}

sub     round
{

local($n,$power)=@_;

        $t=$n*(10.0**(-1*$power));
        $t1=($t<0) ? $t-0.5 : $t+0.5;
        return(int($t1)*(10.0**$power));
}
1;
