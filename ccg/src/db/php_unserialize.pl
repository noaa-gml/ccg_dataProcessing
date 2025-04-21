
sub read_chars
{
   my ( $data, $offset, $length ) = @_;
   # Read $length number of chars from data[offset]

   my $buf = '';
   my $char = '';

   $buf = substr($data, $offset, $length);

   my $chars = length($buf);
   my $readdata = $buf;

   return ( $chars, $readdata );
}

sub read_until
{
   my ( $data, $offset, $stopchar ) = @_;
   # Read from data[offset] until you encounter some char $stopchar

   my $buf = '';
   my $char = substr($data, $offset, 1);
   my $i=2;

   do
   {
      if ( $i+$offset > length($data) )
      {
         die('Invalid serialized string.');
      }

      $buf = $buf.$char;
      $char = substr($data, $offset+($i-1), 1);
      $i++;
   } while ( $char ne $stopchar );

   my $chars = length($buf);
   my $readdata = $buf;

   return ( $chars, $readdata);
}

sub php_unserialize
{
   my ( $data, $offset ) = @_;

   if ( $offset == '' ) { $offset = 0; }

   my $dtype = substr($data, $offset, 1);

   my $dataoffset = $offset+2;
   my $chars = 0;
   my $datalength = 0;
   my $readdata;

   if ( $dtype eq 'i' )
   {
      # integer

      $readdata = '';

      ( $chars, $readdata ) = &read_until($data, $dataoffset, ';');
      $readdata = int($readdata);
      # +1 for end semicolon
      $dataoffset += $chars + 1;
   }
   elsif ( $dtype eq 'b' )
   {
      # boolean 

      $readdata = '';

      ( $chars, $readdata ) = &read_until($data, $dataoffset, ';');
      $readdata = ( $readdata ) ? 1 : 0;
      # +1 for ead semicolon
      $dataoffset += $chars + 1;
   }
   elsif ( $dtype eq 'd' )
   {
      # floating point

      $readdata = '';

      ( $chars, $readdata ) = &read_until($data, $dataoffset, ';');
      $readdata = sprintf("%f", $readdata);
      # +1 for ead semicolon
      $dataoffset += $chars + 1;
   }
   elsif ( $dtype eq 'N' )
   {
      # null

      $readdata = undef;
   }
   elsif ( $dtype eq 's' )
   {
      # string

      $readdata = '';

      my $stringlength = '';
      ( $chars, $stringlength ) = &read_until($data, $dataoffset, ':' );

      # +2 for colons around length field
      $dataoffset += $chars + 2;

      ( $chars, $readdata ) = &read_chars($data, $dataoffset, int($stringlength));
      # +2 for endquote and semicolon
      $dataoffset += $chars + 2;

      if ( $chars != int($stringlength) && int($stringlength) != length($readdata) )
      { die("String length mismatch."); }
   }
   elsif ( $dtype eq 'a' )
   {
      # array

      $readdata = {};

      my $keys = 0;
      # How many keys does this list have?
      ($chars, $keys) = &read_until($data, $dataoffset, ':');
      # +2 for semicolons around length field
      $dataoffset += $chars +2;

      my $ktype;
      my $kchars;
      my $key;
      my $vtype;
      my $vchars;
      my $value;
      my $i;

      # Loop through and fetch this number of key/value pairs
      for ( $i=0; $i<int($keys); $i++ )
      {
         # Read the key
         ($ktype, $kchars, $key) = &php_unserialize($data, $dataoffset);
         $dataoffset += $kchars;

         # Read the value of the key
         ($vtype, $vchars, $value) = &php_unserialize($data, $dataoffset);
         $dataoffset += $vchars;

         $readdata->{$key} = $value;
      }

      # +1 for end bracket;
      $dataoffset += 1;
   }
   else
   {
      die ("Unknown / unhandled data type '$dtype'");
   }

   $type = $dtype;
   $ooffset = $dataoffset - $offset;
   $value = $readdata;

   return ( $type, $ooffset, $value);
}

1;
