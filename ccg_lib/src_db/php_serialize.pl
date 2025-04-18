sub php_serialize
{
   # This works with array and hash references. This method allows
   # $input_data to be anything and then this program can figure
   # out what type of data it is and how to handle it.

   # Examples
   # ----------------------
   # Array
   # @arr = ('hi1');
   # push(@arr, 'hi2');
   # push(@arr, 'hi3');
   # 
   # delete($arr[1]);
   #
   # $string = &php_serialize(\@arr);
   # ----------------------

   # ----------------------
   # Hash
   # %arr = ();

   # $arr{'hi'} = 'yep';
   # $arr{'hi2'} = 'no';
   # $arr{'nest'} = {};
   # $arr{'nest'}{'panda'} = 'den';

   # $string = &php_serialize(\%arr);

   # ----------------------


   my ( $input_data ) = @_;

   my $outstr;

   if ( ref($input_data) eq 'HASH' )
   {
      # Hash

      my @keys = keys(%{ $input_data });
      my $key;
      my $namestr;
      my $valuestr;

      $outstr = 'a:'.scalar(@keys).':{';
      foreach $key ( @keys )
      {
         $namestr = &php_serialize($key);
         $valuestr = &php_serialize($input_data->{$key});

         $outstr = $outstr.$namestr.$valuestr;
      }
      $outstr = $outstr.'}';
   }
   elsif ( ref($input_data) eq 'ARRAY' )
   {
      # Array

      my $i;
      my $namestr;
      my $valuestr;

      $outstr = 'a:'.($#{$input_data}+1).':{';
      for ( $i=0; $i<$#{$input_data}+1; $i++ )
      {
         $namestr = &php_serialize($i);
         $valuestr = &php_serialize(${$input_data}[$i]);

         $outstr = $outstr.$namestr.$valuestr;
      }
      $outstr = $outstr.'}';

   }
   elsif ( ref($input_data) eq '' )
   {
      # No boolean because there is no way to tell the difference between an
      # integer and 0 or 1 in perl

      if ( $input_data =~ m/^[0-9]+$/ )
      {
         # Integer
         $outstr = "i:$input_data;"; 
      }
      elsif ( $input_data =~ m/^[0-9]*\.?[0-9]+$/)
      {
         # Float
         $outstr = "d:$input_data;"; 
      }
      elsif ( $input_data eq undef )
      {
         # Null
         $outstr = 'N;';
      }
      else
      {
         # Everything else is a string
         $outstr = 's:'.length($input_data).':"'.$input_data.'";';
      }
   }
   else
   { die("Unrecognized type for input data."); }

   return $outstr;
}

1;
