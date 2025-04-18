<?PHP

require_once "DB.php";

/**
* Database class to interact with Carbon Cycle Group database
*/

class CCGDB extends DB
{
   /**
   * Constructor method for instantiating a CCGDB object
   *
   * @return (CCGDB) Instantiation of CCGDB object
   */
   public function __construct()
   {

      $server = '';
      $database = '';
      $user = '';
      $pwd = '';

      return parent::__construct($server, $database, $user, $pwd);
   }
}
