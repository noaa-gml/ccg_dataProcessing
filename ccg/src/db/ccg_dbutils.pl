#
#######################################
# Connect to DB
#######################################
#
sub connect_db
{
   my $host="";
   my $dr = "";
   my $db = "";
   my $user = "";
   my $pwd = '';

   my $z = "DBI:$dr:database=$db;host=$host";
   $dbh = DBI->connect($z, $user, $pwd , {
      PrintError => 0,   ### Don't report errors via warn(  )
      RaiseError => 1    ### Do report errors via die(  )
   } );


   return $dbh;
}
sub connect_db_restricted
{
   my $host="";
   my $dr = "";
   my $db = "";
   my $user ="";
   my $pwd = '';

   my $z = "DBI:$dr:database=$db;host=$host";
   $dbh = DBI->connect($z, $user, $pwd , {
      PrintError => 0,   ### Don't report errors via warn(  )
      RaiseError => 1    ### Do report errors via die(  )
   } );


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
   my ($sql, $n, $sth);

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
   my ($f, $t) = @_;
   my ($n,@arr,$sth);

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
# 2. project (e.g., ccg_surface, ccg_aircraft, ccg_obs, ccg_tower)
#######################################
#
sub get_binlist
{
   my ($code,$project) = @_;

   my ($i,$f,$tmp,$binlist,$arr);

   $i = int(10**8*rand());
   $f = "/tmp/z".$i;

   $perl = "/projects/src/db/ccg_binning.pl";
   $tmp = "${perl} -site=${code}";
   if ( $project ne "" ) { $tmp = "${tmp} -project=${project}"; }
   $tmp = "${tmp} > ${f}";
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
# 1. site (e.g., car030, pocn30, sgp374
# 2. project (e.g., ccg_surface, ccg_aircraft, ccg_obs, ccg_tower)
#######################################
#
sub get_bin_params
{
   my ($site,$project) = @_;

   my ($width);
   my ($code,$bin);
   my ($i,$j,$k,$f,$tmp,$arr,$bin_info);
   my ($sn,$sc,$pn,$d1,$d2,$lmin,$lmax,$tn);

   $binby = '';
   $min = (0);
   $max = (0);

   $bin = substr($site, 3);
   $code = substr($site, 0, 3);
   
   if ($bin eq '') {return}

   $i = int(10 ** 8 * rand());
   $f = "/tmp/z" . $i;

   $perl = "/projects/src/db/ccg_binning.pl";
   $tmp = "${perl} -site=${code}";
   if ( $project ne "" ) { $tmp = "${tmp} -project=${project}"; }
   $tmp = "${tmp} > ${f}";
   system($tmp);

   open (FILE, $f);
   local(@arr) = <FILE>;
   close (FILE);

   for ($i = 0; $i < @arr; $i++)
   {
      chop($arr[$i]);

      next if !($arr[$i]);

      ($sn, $sc, $pn, $d1, $d2, $binby, $lmin, $lmax, $width, $tn) = split /\|/, $arr[$i];

      @tmp = split("-", $d1);
      $d1 = &date2dec($tmp[0], $tmp[1], $tmp[2], 12, 0);
      @tmp = split("-", $d2);
      $d2 = &date2dec($tmp[0], $tmp[1], $tmp[2], 12, 0);

      if ($binby eq 'alt' && $project eq "ccg_aircraft") { $bin = $bin * 100.0; }

      if ($binby eq 'lat')
      {
         $h = (substr($bin, 0, 1) eq 'n') ? 1 : -1;
         $bin = substr($bin, 1, 2) * $h;
      }

      if ( $#arr > 0 && $project eq "ccg_surface" )
      {
         $center = ( $lmax + $lmin ) / 2.0;
         if ( $lmin == $bin )
         {
            $min = $center - $width / 2.0;
            $max = $center + $width / 2.0;
            last;
         }
      }
      else
      {
         if (($width == 0) && $lmin == $bin)
         {
            $min = $bin;
            $max = $bin;
            last;
         }
         else
         {
            $min = $bin - $width / 2.0;
            $max = $bin + $width / 2.0;
         }
      }
   }
   unlink($f);
}

#
#######################################
# Get data summary information
# User may supply constraints on
#  site_num
#  site_code
#  parameter_num
#  parameter_formula
#  project_num
#  project_abbr
#  strategy_num
#  strategy_abbr
#  program_num
#  program_abbr
#
#  output argument: 'hash' or 'array'
#     return hash of arrays or array of hashes
#     default: array of hashes
#
# This function returns an array or hash based on user input
#  that contain all of the data_summary information joined
#  with related information
#######################################
#

sub get_data_summary
{
   my (%argshash) = @_;
   my ($dbh, $sth);
   my @selectcolumns = ();
   my $selectcolumn;
   my @strings = ();
   my $line;
   my @arr = ();
   my ($sql, $select, $from, $where, $etc);
   my %tmphash;
   my ($dbname, $fieldname);

   @selectcolumns = ();

   # data_summary
   push(@selectcolumns, 't1.first~+~datasum_first');
   push(@selectcolumns, 't1.last~+~datasum_last');
   push(@selectcolumns, 't1.count~+~datasum_count');

   # gmd.site
   push(@selectcolumns, 't2.num~+~site_num');
   push(@selectcolumns, 't2.code~+~site_code');
   push(@selectcolumns, 't2.name~+~site_name');
   push(@selectcolumns, 't2.country~+~site_country');
   push(@selectcolumns, 't2.lat~+~site_lat');
   push(@selectcolumns, 't2.lon~+~site_lon');
   push(@selectcolumns, 't2.elev~+~site_elev');
   push(@selectcolumns, 't2.lst2utc~+~site_lst2utc');
   push(@selectcolumns, 't2.flag~+~site_flag');
   push(@selectcolumns, 't2.description~+~site_description');
   push(@selectcolumns, 't2.map_coords~+~site_map_coords');
   push(@selectcolumns, 't2.image~+~site_image');
   push(@selectcolumns, 't2.comments~+~site_comments');

   # gmd.parameter
   push(@selectcolumns, 't3.num~+~parameter_num');
   push(@selectcolumns, 't3.formula~+~parameter_formula');
   push(@selectcolumns, 't3.name~+~parameter_name');
   push(@selectcolumns, 't3.unit~+~parameter_unit');
   push(@selectcolumns, 't3.unit_name~+~parameter_unit_name');
   push(@selectcolumns, 't3.formula_html~+~parameter_formula_html');
   push(@selectcolumns, 't3.unit_html~+~parameter_unit_html');
   push(@selectcolumns, 't3.formula_idl~+~parameter_formula_idl');
   push(@selectcolumns, 't3.unit_idl~+~parameter_unit_idl');
   push(@selectcolumns, 't3.formula_matplotlib~+~parameter_formula_matplotlib');
   push(@selectcolumns, 't3.unit_matplotlib~+~parameter_unit_matplotlib');
   push(@selectcolumns, 't3.description~+~parameter_description');

   # project
   push(@selectcolumns, 't4.num~+~project_num');
   push(@selectcolumns, 't4.name~+~project_name');
   push(@selectcolumns, 't4.abbr~+~project_abbr');
   push(@selectcolumns, 't4.description~+~project_description');
   push(@selectcolumns, 't4.comments~+~project_comments');

   # strategy
   push(@selectcolumns, 't5.num~+~strategy_num');
   push(@selectcolumns, 't5.name~+~strategy_name');
   push(@selectcolumns, 't5.abbr~+~strategy_abbr');

   # status
   push(@selectcolumns, 't6.num~+~status_num');
   push(@selectcolumns, 't6.name~+~status_name');
   push(@selectcolumns, 't6.comments~+~status_comments');

   # program
   push(@selectcolumns, 't7.num~+~program_num');
   push(@selectcolumns, 't7.name~+~program_name');
   push(@selectcolumns, 't7.abbr~+~program_abbr');

   foreach $selectcolumn ( @selectcolumns )
   {
      ($dbname, $fieldname) = split(/~\+~/, $selectcolumn);

      $select = ( $select eq '' ) ? " SELECT $dbname as $fieldname" : $select.", $dbname as $fieldname";
   }

   $from = " FROM ccgg.data_summary as t1, gmd.site as t2, gmd.parameter as t3";
   $from = $from.", ccgg.project as t4, ccgg.strategy as t5, ccgg.status as t6";
   $from = $from.", gmd.program as t7";
   $where = " WHERE t1.site_num = t2.num AND t1.parameter_num = t3.num";
   $where = $where." AND t1.project_num = t4.num AND t1.strategy_num = t5.num";
   $where = $where." AND t1.status_num = t6.num AND t1.program_num = t7.num";

   if ( defined($argshash{site_code}) )
   {
      @arr = split(',', $argshash{site_code});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t2.code = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{site_num}) )
   {
      @arr = split(',', $argshash{site_num});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t2.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{parameter_formula}) )
   {
      @arr = split(',', $argshash{parameter_formula});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t3.formula = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{parameter_num}) )
   {
      @arr = split(',', $argshash{parameter_num});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t3.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{project_abbr}) )
   {
      @arr = split(',', $argshash{project_abbr});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t4.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{project_num}) )
   {
      @arr = split(',', $argshash{project_num});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t4.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{strategy_abbr}) )
   {
      @arr = split(',', $argshash{strategy_abbr});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t5.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{strategy_num}) )
   {
      @arr = split(',', $argshash{strategy_num});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t5.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{program_abbr}) )
   {
      @arr = split(',', $argshash{program_abbr});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t7.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{program_num}) )
   {
      @arr = split(',', $argshash{program_num});

      @strings = ();
      foreach $line ( @arr )
      { push(@strings, "t7.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', @strings)." )";
   }

   if ( defined($argshash{orderby} ) )
   {
      $etc = '';
      if ( $argshash{orderby} eq "site_code" )
      { $etc = " ORDER BY t2.code"; }
      elsif ( $argshash{orderby} eq "site_num" )
      { $etc = " ORDER BY t2.num"; }
      elsif ( $argshash{orderby} eq "parameter_formula" )
      { $etc = " ORDER BY t3.formula"; }
      elsif ( $argshash{orderby} eq "parameter_num" )
      { $etc = " ORDER BY t3.num"; }
      elsif ( $argshash{orderby} eq "project_abbr" )
      { $etc = " ORDER BY t4.abbr"; }
      elsif ( $argshash{orderby} eq "project_num" )
      { $etc = " ORDER BY t4.num"; }
      elsif ( $argshash{orderby} eq "strategy_abbr" )
      { $etc = " ORDER BY t5.abbr"; }
      elsif ( $argshash{orderby} eq "strategy_num" )
      { $etc = " ORDER BY t5.num"; }
      elsif ( $argshash{orderby} eq "program_abbr" )
      { $etc = " ORDER BY t7.abbr"; }
      elsif ( $argshash{orderby} eq "program_num" )
      { $etc = " ORDER BY t7.num"; }
     
   }

   $sql = $select.$from.$where.$etc;

   #print "$sql\n";

   #
   #######################################
   # Connect to Database
   #######################################
   #
   $dbh = &connect_db();

   if ( $argshash{output} eq 'hash' )
   {
      my %results = ();
      $sth = $dbh->prepare($sql);
      $sth->execute();

      foreach $selectcolumn ( @selectcolumns )
      {
         ($dbname, $fieldname) = split(/~\+~/, $selectcolumn);
         $results{$fieldname} = ();
      }

      while (@tmp = $sth->fetchrow_array())
      {
         $tmphash = {};

         for ( $i=0; $i<=$#selectcolumns; $i++ )
         {
            ($dbname, $fieldname) = split(/~\+~/, $selectcolumns[$i]);
            push @{ $results{$fieldname} }, $tmp[$i];
         }
      }
      $sth->finish();

      return(%results);
   }
   else
   {
      my @results = ();
      $sth = $dbh->prepare($sql);
      $sth->execute();
      while (@tmp = $sth->fetchrow_array())
      {
         $tmphash = {};

         for ( $i=0; $i<=$#selectcolumns; $i++ )
         {
            ($dbname, $fieldname) = split(/~\+~/, $selectcolumns[$i]);
            $tmphash->{$fieldname} = $tmp[$i];
         }
   
         push(@results, $tmphash);
      }
      $sth->finish();

      return(@results);
   }

   #
   #######################################
   # Disconnect from DB
   #######################################
   #
   &disconnect_db($dbh);
}

sub get_relatedfield
{
   ##################################
   # get_relatedfield()
   #  Convert one data field value into another data field value.
   #  This function is useful for converting a primary key number into
   #  another data field value. For example, converting parameter number
   #  into parameter formula
   #  Return values:
   #      1 - An error occured
   #      0 - No problems
   #
   #  (ex) $formula = get_relatedfield('1', 'parameter_num', 'parameter_formula',\$exitcode);
   #
   ##################################

   my $value = $_[0];
   my $from= $_[1];
   my $to = $_[2];
   # $exitcode is $_[3] but a return variable
   #   From http://www.troubleshooters.com/codecorn/littperl/perlsub.htm
   #    For readability therefore, on output or input/output arguments
   #    it is therefore important to use the output argument as $_[] or
   #    @_ throughout the function to let the reader know it's an
   #    output argument.

   my $returnvalue = '';
   my @results = ();
   my @tmp = ();
   my %dbfields = ();
   my $junk;
   my $sql;
   my $sth;
   my ($fromtable, $totable);

   # Define the hash to convert names to database fields
   $dbfields{site_num} = 'gmd.site.num';
   $dbfields{site_code} = 'gmd.site.code';
   $dbfields{site_name} = 'gmd.site.name';
   $dbfields{site_country} = 'gmd.site.country';
   $dbfields{site_lat} = 'gmd.site.lat';
   $dbfields{site_lon} = 'gmd.site.lon';
   $dbfields{site_elev} = 'gmd.site.elev';
   $dbfields{site_lst2utc} = 'gmd.site.lst2utc';
   $dbfields{site_flag} = 'gmd.site.flag';
   $dbfields{site_description} = 'gmd.site.description';
   $dbfields{site_map_coords} = 'gmd.site.map_coords';
   $dbfields{site_image} = 'gmd.site.image';
   $dbfields{site_comments} = 'gmd.site.comments';
   $dbfields{parameter_num} = 'gmd.parameter.num';
   $dbfields{parameter_formula} = 'gmd.parameter.formula';
   $dbfields{parameter_name} = 'gmd.parameter.name';
   $dbfields{parameter_unit} = 'gmd.parameter.unit';
   $dbfields{parameter_unit_name} = 'gmd.parameter.unit_name';
   $dbfields{parameter_formula_html} = 'gmd.parameter.formula_html';
   $dbfields{parameter_unit_html} = 'gmd.parameter.unit_html';
   $dbfields{parameter_formula_idl} = 'gmd.parameter.formula_idl';
   $dbfields{parameter_unit_idl} = 'gmd.parameter.unit_idl';
   $dbfields{parameter_formula_matplotlib} = 'gmd.parameter.formula_matplotlib';
   $dbfields{parameter_unit_matplotlib} = 'gmd.parameter.unit_matplotlib';
   $dbfields{parameter_description} = 'gmd.parameter.description.';
   $dbfields{project_num} = 'ccgg.project.num';
   $dbfields{project_name} = 'ccgg.project.name';
   $dbfields{project_abbr} = 'ccgg.project.abbr';
   $dbfields{project_description} = 'ccgg.project.description';
   $dbfields{project_comments} = 'ccgg.project.comments';
   $dbfields{strategy_num} = 'ccgg.strategy.num';
   $dbfields{strategy_name} = 'ccgg.strategy.name';
   $dbfields{strategy_abbr} = 'ccgg.strategy.abbr';
   $dbfields{status_num} = 'ccgg.status.num';
   $dbfields{status_name} = 'ccgg.status.name';
   $dbfields{status_comments} = 'ccgg.status.comments';
   $dbfields{program_num} = 'gmd.program.num';
   $dbfields{program_name} = 'gmd.program.name';
   $dbfields{program_abbr} = 'gmd.program.abbr';
   $dbfields{event_num} = 'flask_event.num';
   $dbfields{event_site_num} = 'flask_event.site_num';
   $dbfields{event_project_num} = 'flask_event.project_num';
   $dbfields{event_strategy_num} = 'flask_event.strategy_num';
   $dbfields{event_date} = 'flask_event.date';
   $dbfields{event_time} = 'flask_event.time';
   $dbfields{event_dd} = 'flask_event.dd';
   $dbfields{event_me} = 'flask_event.me';
   $dbfields{event_lat} = 'flask_event.lat';
   $dbfields{event_lon} = 'flask_event.lon';
   $dbfields{event_alt} = 'flask_event.alt';
   $dbfields{event_comment} = 'flask_event.comment';
   $dbfields{instrument_num} = 'instrument.num';
   $dbfields{instrument_id} = 'instrument.id';

   if ( ! defined($dbfields{$from}) )
   {
      #die("'$from' is not a defined datafield.");
      $_[3] = 1;
      return ($returnvalue);
   }
   if ( ! defined($dbfields{$to}) )
   {
      #die("'$to' is not a defined datafield.");
      $_[3] = 1;
      return ($returnvalue);
   }

   @tmp = split(/\./, $dbfields{$from});
   $junk = pop(@tmp);
   $fromtable = join('.', @tmp);

   @tmp = split(/\./, $dbfields{$to});
   $junk = pop(@tmp);
   $totable = join('.', @tmp);

   if ( $fromtable ne $totable )
   {
      #die("'$from' and '$to' are from two different tables.");
      $_[3] = 1;
      return ($returnvalue);
   }

   $sql = " SELECT ".$dbfields{$to}." FROM $fromtable WHERE ".$dbfields{$from}." = ?";

   #print "SQL: $sql\n";
   #print "VALUE: ".$value."\n";

   $sth = $dbh->prepare($sql);
   $sth->execute($value);

   while (@tmp = $sth->fetchrow_array())
   { push(@results, join('~+~', @tmp)); }
   $sth->finish();

   if ( scalar $#results == 0 )
   {
      $returnvalue = $results[0];
      $_[3] = 0;
      return($returnvalue);
   }
   else
   {
      $_[3] = 1;
      return($returnvalue);
   }
}
sub get_altsource
{
   my ($event_num, $alt_source) = @_;
   my $i;
   my ($name, $value);
   my ($comment, $newcomment);
   my @tmparr;

   $comment = &get_relatedfield($event_num, 'event_num', 'event_comment');

   @tmparr = split(/~\+\~/, $comment);

   for ( $i=0; $i<=$#tmparr; $i++ )
   {
      ($name, $value) = split(':',$tmparr[$i],2);

      if ( $name eq 'alt' )
      {
         return $value;
      }
   }

   return '';
}
sub set_altsource
{
   my ($event_num, $alt_source) = @_;
   my $i;
   my ($name, $value);
   my ($comment, $newcomment);
   my @tmparr;
   my ($sql, @sqlargs);

   $comment = &get_relatedfield($event_num, 'event_num', 'event_comment');

   @tmparr = split(/~\+\~/, $comment);

   for ( $i=0; $i<=$#tmparr; $i++ )
   {
      ($name, $value) = split(':',$tmparr[$i],2);

      if ( $name eq 'alt' )
      {
         $tmparr[$i] = $name.':gps_nav';
         last;
      }
   }

   $newcomment = join('~+~', @tmparr);

   $sql = "UPDATE ccgg.flask_event SET comment = ? WHERE num = ? LIMIT 1";
   @sqlargs = ($newcomment, $event_num);

   #print $sql."\n";
   #print join('|', @sqlargs)."\n";
   $sth = $dbh->prepare($sql);
   $sth->execute(@sqlargs);
   $sth->finish();
}
1;
