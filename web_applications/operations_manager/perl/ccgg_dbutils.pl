#
#######################################
# Connect to DB
#######################################
#
sub connect_db
{
	$host="db.cmdl.noaa.gov";
	$dr = "mysql";
	$db = "";
 	$user = "";
 	$pwd = "";

	$z = "DBI:$dr:database=$db;host=$host";
	$dbh = DBI->connect($z, $user, $pwd) or die $DBI::errstr;

	return $dbh;
}
#
#######################################
# Disconnect from DB
#######################################
#
sub disconnect_db
{
	($dbh) = @_;
         $dbh->disconnect();
}
#
#######################################
# Get single field from a DB table
# User provides field and table name
# and key field and key variable
#######################################
#
sub get_field
{
	my ($f, $t, $k, $v) = @_;
	my $n;

	$sql="SELECT ${f} FROM ${t} WHERE ${k} = '${v}'";

	$sth = $dbh->prepare($sql);
	$sth->execute();
	$n = $sth->fetchrow_array();
	$sth->finish();

	return $n;
}
#
#######################################
# Get all fields from specified column of a DB table
# User provides column and table name
#######################################
#
sub get_all_fields
{
	my ($f, $t,) = @_;
	my $n,@arr;

	$sql = "SELECT ${f} FROM ${t}";

	$sth = $dbh->prepare($sql);
	$sth->execute();

	$n = 0; @arr = ();
	while (@tmp = $sth->fetchrow_array()) { @arr[$n++]=join(' ',@tmp) }
	$sth->finish();

	return @arr;
}
#
#######################################
# Get list of bins
# User must supply
# 1. site (e.g., car, poc, sgp
# 2. project (e.g., flask,pfp,obs,tower)
#######################################
#
sub get_binlist
{
	my ($code,$project) = @_;

	my ($i,$f,$tmp,$binlist,$arr);

	$i = int(10**8*rand());
	$f = "/tmp/z".$i;

	$perl = "/projects/src/db/ccg_binning.pl";
	$tmp = "${perl} -s${code} -p${project} > ${f}";
	(system($tmp));

	open (FILE, ${f});
	local(@arr) = <FILE>;
	chop(@arr);
	close (FILE);
	unlink($f);

	@binlist = ();
	foreach $element (@arr)
	{
		($sn,$sc,$pn,$d1,$d2,$binby,$lmin,$lmax,$width,$tn) = split /\|/,$element;

		for ($ib = $lmin; $ib<=$lmax; $ib=$ib+$width)
		{
			$site = "${code}${ib}";

			if ($binby eq 'lat')
			{
				$h = ($ib < 0) ? 's' : 'n';
				$lat = sprintf("%2.2d",abs($ib));
				$site = "${code}${h}${lat}";
			}
			push @binlist,$site;
			last if ($width == 0);
		}
	}
}
#
#######################################
# Get binning parameters
# User must supply
# 1. site (e.g., car3000, pocn30, sgp374
# 2. project (e.g., flask,pfp,obs,tower)
#######################################
#
sub get_bin_params
{
	my ($site,$project) = @_;

	my ($width);
	my ($code,$bin);
	my ($i,$j,$k,$f,$tmp,$arr,$bin_info);
	my ($sn,$sc,$pn,$d1,$d2,$lmin,$lmax,$tn);

	$binby='';
	$min=(0);
	$max=(0);

	$bin=substr($site,3);
	$code=substr($site,0,3);
	
	if ($bin eq '') {return}

	$i=int(10**8*rand());
	$f="/tmp/z".$i;

	$perl="/projects/src/db/ccg_binning.pl";
	$tmp="${perl} -s${code} -p${project} > ${f}";
	(system($tmp));

	open (FILE, ${f});
	local(@arr) = <FILE>;
	close (FILE);

	for ($i=0; $i<@arr; $i++)
	{
		chop($arr[$i]);

		next if !($arr[$i]);

		($sn,$sc,$pn,$d1,$d2,$binby,$lmin,$lmax,$width,$tn) = split /\|/,$arr[$i];

		@tmp=split("-",$d1);
		$d1 = &date2dec($tmp[0],$tmp[1],$tmp[2],12,0);
		@tmp=split("-",$d2);
		$d2 = &date2dec($tmp[0],$tmp[1],$tmp[2],12,0);

		if ($binby eq 'lat')
		{
			$h=(substr($bin,0,1) eq 'n') ? 1 : -1;
			$bin=substr($bin,1,2)*$h;
		}

		if (($width == 0) && $lmin == $bin)
		{
			$min=$bin;
			$max=$bin;
			last;
		}
		else
		{
			$min=$bin-$width/2.0;
			$max=$bin+$width/2.0;
		}
	}
	unlink($f);
}
1;
