<?PHP

/**
* EmailLog class handles writing to email log file
*/

class EmailLog
{
   /**
   * Method to update email log file
   *
   * Do NOT throw errors in this class. This should not affect
   *  the processing of other classes
   *
   * This is separate from the general log as it stores all emails
   *
   * There are two ways to call this method:
   *   - Syntax 1: update($input_comment)
   *      Add the $input_comment to the log file
   *   - Syntax 2: update($input_user, $input_comment)
   *      Add the $input_comment to the log file associated with $input_user 
   *
   * @param $input_user (string) Input user name
   * @param $input_comment (string) Input comment/HTML.
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

      $logfile = "log/".date("Y")."_email.html";
      $now = date("Y-m-d H:i:s");

      $fh = fopen($logfile, 'a');

      if ( $fh == FALSE )
      {
         echo "Error opening log file.<BR>\n";
         return false;
      }

      fwrite($fh, "<BR><BR><HR><BR><BR>\n");

      if ( $input_user != '' )
      {
         fwrite($fh, "<H3>$now ($input_user)</H3><BR>\n");
      }
      else
      {
         fwrite($fh, "<H3>$now</H3><BR>\n");
      }
      fwrite($fh, $input_comment."<BR>\n");
      fclose($fh);
   }
}
