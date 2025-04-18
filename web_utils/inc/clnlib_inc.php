<?PHP
#
# Cleaning/Checker functions
#

# Whole number - ctype_digit()
# Decimal number - is_float()
# String - preg_match()

#
# Function CleanSiteCode ########################################################
#
function CleanSiteCode($code)
{
   $sql = "SELECT LOWER(code) FROM gmd.site";
   $sites = ccgg_query($sql);

   $sites[count($sites)] = 'xxx';

   if ( in_clnarray(strtolower($code), $sites) ) { return(TRUE); }

   #if ( strlen($code) != 3 && strlen($code) != 6 ) { return(FALSE); }

   #if ( ! (ctype_alnum($code) ) ) { return(FALSE); }

   return(FALSE);
}
#
# Function CleanParam ########################################################
#
function CleanParam($param)
{
   # parameter
   $clnparams = explode(",",constant("IADVGASES"));
   $clnparams[count($clnparams)] = 'multi-gas';
   $clnparams[count($clnparams)] = 'single';
   $clnparams[count($clnparams)] = 'multi';

   if ( !(in_clnarray(strtolower($param),$clnparams) ) ) { return(FALSE); }

   return(TRUE);
}
#
# Function CleanProject ########################################################
#
function CleanProject($project,$type)
{
   if ( $type == 'short' ) { $str = "SUBSTRING_INDEX(abbr,'_',-1)"; }
   else { $str = "abbr"; }

   $sql = "SELECT ${str} FROM gmd.project WHERE program_num = '1'";
   $projects = ccgg_query($sql);

   $projects[count($projects)] = 'custom';
   $projects[count($projects)] = 'all';

   if ( ! (in_clnarray(strtolower($project), $projects)) ) { return(FALSE); }

   return(TRUE);
}
#
# Function CleanNSubmits ########################################################
#
function CleanNSubmits($nsubmits)
{
   if ( ! (is_numeric($nsubmits) ) ) { return(FALSE); }

   if ( $nsubmits >= 0 ) { return(FALSE); }

   return(TRUE);
}
?>
