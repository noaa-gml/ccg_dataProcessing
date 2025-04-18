<?PHP

/**
* Log class handles writing to log file
*/

class Log
{
   /**

   * Method to update log file
   *
   * Do NOT throw errors in this class. This should not affect
   *  the processing of other classes
   *
   * There are two ways to call this method:
   *   - Syntax 1: update($input_comment)
   *      Add the $input_comment to the log file
   *   - Syntax 2: update($input_user, $input_comment)
   *      Add the $input_comment to the log file associated with $input_user 
   *
   * @param $input_user (string) Input user name
   * @param $input_comment (string) Input comment.
   * @return void
   */

   public function update()
   {
      $numargs = func_num_args();

      if ( $numargs == 1 )
      {
         $input_user = '';
         $input_comment = func_get_arg(0);
      }
      elseif ( $numargs == 2 )
      {
         $input_user = func_get_arg(0);
         $input_comment = func_get_arg(1);
      }
      else
      {
         echo "Invalid number of arguments provided for logging.<BR>\n";
         return false;
      }
      $cwd=getcwd();
   
      $logfile=(($cwd=='/var/www/html/mund/rgm/j' || $cwd=='/var/www/html/rgm/j'))?"../log/".date("Y").".txt":"log/".date("Y").".txt";
     
      $now = date("Y-m-d H:i:s");

      $fh = fopen($logfile, 'a');

      if ( $fh == FALSE )
      {
         echo "Error opening log file.<BR>\n";
         return false;
      }

      fwrite($fh, "***^^^***\n");

      if ( $input_user != '' )
      {
         fwrite($fh, "$now ($input_user) :\n");
      }
      else
      {
         fwrite($fh, "$now :\n");
      }
      fwrite($fh, $input_comment."\n");
      fclose($fh);
   }
}
