<?PHP

require_once "DB_User.php";

function ValidAuthentication($input_database_object, $user_obj)
{
   if ( get_class($user_obj) === 'DB_User' &&
        $user_obj->validate($input_database_object, $user_obj->getUsername(), $user_obj->getUsername().'+'.$_SERVER['HTTP_USER_AGENT']) )
   { return true; }
   else
   { return false; }
}

function ValidateAuthentication($input_database_object, $user_obj)
{
   try
   {
      if ( ! ValidAuthentication($input_database_object, $user_obj) )
      { throw new Exception ("Authentication failed."); }
   }
   catch ( Exception $e )
   {

      #debug_print_backtrace();
      #session_destroy(); #This was causing problems with saved sess state.jwm 20210115
      header("Location: login.php?url=".urlencode($_SERVER['REQUEST_URI']));
      exit;
   }
}

function array_unique_obj($input_array)
{
    # I was unable to get array_unique() to work in PHP for objects
    # so I wrote my own function
    # This is similar to the unique_array() function in perl

    $search_array = $input_array;
    $retarr = $input_array;
   
    while(count($search_array) > 0 )
    {
       $object = array_shift($search_array);

       $seen = 0;
       foreach ( $retarr as $key=>$value )
       {
          if ( $object->__toString() === $value->__toString() )
          {
             # Keep the first occurrence and remove the following
             if ( $seen === 0 )
             { $seen++; }
             else
             { unset($retarr[$key]); }
          }
       }
    } 

    return($retarr);
}

function match_in_array($input_needle, $input_haystack)
{
   foreach ( $input_haystack as $tmp_obj )
   {
      if ( $tmp_obj->matches($input_needle))
      { return true; }
   }

   return false;
}

function equal_in_array($input_needle, $input_haystack)
{
   foreach ( $input_haystack as $tmp_obj )
   {
      if ( $tmp_obj->equals($input_needle)) 
      { return true; }
   }

   return false;
}

function compare_object_array($input_objects1, $input_objects2, $type='equal')
{
   if ( count($input_objects1) == 0 && count($input_objects2) == 0 )
   { return (array(array(), array())); }
   elseif ( count($input_objects1) == 0 && count($input_objects2) > 0 )
   { return (array(array(), $input_objects2)); }
   elseif ( count($input_objects1) > 0 && count($input_objects2) == 0 )
   { return (array($input_objects1, array())); }


   $matchcount_arr1 = array_fill(0, count($input_objects1), 0);
   $matchcount_arr2 = array_fill(0, count($input_objects2), 0);

   if ( $type == 'match' )
   {
      for ( $i=0; $i<count($input_objects1); $i++ )
      {
         for ( $j=0; $j<count($input_objects2); $j++ )
         {
            if ( ! method_exists($input_objects1[$i], 'matches') )
            { throw new Exception("Unable to call method 'matches' of object passed."); }

            if ( $input_objects1[$i]->matches($input_objects2[$j]) )
            {
               $matchcount_arr1[$i]++;
               $matchcount_arr2[$j]++;
            }
         }
      }
   }
   else
   {
      for ( $i=0; $i<count($input_objects1); $i++ )
      {
         for ( $j=0; $j<count($input_objects2); $j++ )
         {
            if ( ! method_exists($input_objects1[$i], 'equals') )
            { throw new Exception("Unable to call method 'equals' of object passed."); }

            if ( $input_objects1[$i]->equals($input_objects2[$j]) )
            {
               $matchcount_arr1[$i]++;
               $matchcount_arr2[$j]++;
            }
         }
      }
   }

   foreach ( array_merge($matchcount_arr1, $matchcount_arr2) as $count )
   {
      if ( $count > 1 )
      { throw new Exception ("Unexpected number of matches found."); }
   }

   $delete_objects = array();
   for ( $j=0; $j<count($matchcount_arr2); $j++ )
   {
      if ( $matchcount_arr2[$j] === 0 )
      { array_push($delete_objects, $input_objects2[$j]); }
   }

   $add_objects = array();
   for ( $i=0; $i<count($matchcount_arr1); $i++ )
   {
      if ( $matchcount_arr1[$i] === 0 )
      { array_push($add_objects, $input_objects1[$i]); }
   }

   return ( array($add_objects, $delete_objects) );
}

function mb_unserialize($string)
{
   # Please see http://stackoverflow.com/questions/2853454/php-unserialize-fails-with-non-encoded-characters

   # This address the issue with multi-byte characters (non english letters)
   #   while using unserialize
   # For example, strlen('à') is > 1 so unserialize() fails

   $string = preg_replace('!s:(\d+):"(.*?)";!se', "'s:'.strlen('$2').':\"$2\";'", $string);
   $result = @unserialize($string);

   return $result;
}

function NoCacheLinks()
{
?>

<script>
$(window).load( function() {

   //
   // Add a random number at the end of each URL so that the browser does not
   //  use the cache and loads the information new. This is especially needed
   //  for changes to Javascript
   //
   $( "a:not([href^=#])" ).each(function() {
      var _href = $(this).attr("href");

      // If the url contains a '#' then ignore it 
      if ( _href != undefined &&
           _href.indexOf("#") == -1 )
      {
         if ( _href.indexOf("?") >= 0 )
         {
            $(this).attr("href", _href+'&randnum='+ $.now());
         }
         else
         {
            $(this).attr("href", _href+'?randnum='+ $.now());
         }
      }
   });
});
</script>
<?PHP
}
?>
