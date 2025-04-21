<?PHP

require_once "Log.php";

/**
*
* database class to handle general database interactions such as connecting,
* disconnecting, retrieving data and executing stataments.
*
* Please see http://stackoverflow.com/questions/4595964/who-needs-singletons
*/

class DB
{
   /** Database connection handle */
   protected $database_handle;

   /** Database server */
   protected $server;

   /** Database */
   protected $database;

   /** Database username */
   protected $user;

   /** Database pwd */
   protected $pwd;

   /**
   * Constructor method for instantiating a DB object
   *
   * @param $server (string) database server address
   * @param $database (string) specific database on server
   * @param $user (string) Username access credentials
   * @param $pwd (string) Password access credentials
   * @return (DB) Instantiated object
   */
   public function __construct($server, $database, $user, $pwd)
   {
      $this->server = $server;
      $this->database = $database;
      $this->user = $user;
      $this->pwd = $pwd;

      return $this;
   }

   /**
   * Method to connect to database
   *
   * This method also addresses when the database handle has disappeared and
   * we need to reconnect.
   *
   * @return void
   */
   public function connect()
   {
      if ( ! $this->database_handle)
      {
         $this->database_handle = new PDO('mysql:host='.$this->server.';dbname='.$this->database, $this->user, $this->pwd);
      }
      else
      {
         # Do we need to recconect?
         try
         {
            $sql = 'SELECT 1';
            $sth = $this->database_handle->prepare($sql);
            $sth->execute();
         }
         catch (PDOException $e)
         {
            $this->database_handle = new PDO('mysql:host='.$this->server.';dbname='.$this->database, $this->user, $this->pwd);
         }
      }

      if ( ! $this->database_handle )
      {
         throw new PDOException("Unable to connect to database");
      }
   }

   /**
   * Method to disconnect from database
   *
   * @return void
   */
   public function disconnect()
   {
      $this->database_handle = NULL;
   }

   /**
   * Method to convert the object into a string
   *
   * This is primarily used when creating a log entry
   *
   * @return (string) String version of the object.
   */
   public function __toString()
   {
      return 'Serialized data: '.serialize($this);
   }

   /**
   * Magic method called by PHP automagically when using serialize().
   *
   * This is necessary because database handles cannot be serialized.
   * Session variables are automatically serialized.
   *
   * @return void
   */
   public function __sleep()
   {
      return array ('server', 'database', 'user', 'pwd');
   }

   /**
   * Method to query data from the database
   *
   * There are two ways to call this:
   *  - Syntax 1: queryData($sql)
   *     - Query the database using $sql.
   *  - Syntax 2: queryData($sql, $sqlargs)
   *     - Query the database using the prepared statement $sql and
   *       $sqlargs.
   *       (ex) $sql = 'SELECT num FROM table WHERE name = ?';
   *            $sqlargs = array ('Bob')
   *
   * @param $sql (string) SQL statament
   * @param $sqlargs (array) Array of arguments for prepared statement $sql
   * @return (array) Array of results
   */
   public function queryData()
   {
      $numargs = func_num_args();

      if ( $numargs == 1 )
      {
         $sql = func_get_arg(0);
         $sqlargs = array();
      }
      elseif ( $numargs == 2 )
      {
         $sql = func_get_arg(0);
         $sqlargs = func_get_arg(1);
      }
      else
      {
         throw new BadMethodCallException("Incorrect number of arguments.");
      }

      #print $sql."<BR>";
      #print join('|',$sqlargs)."<BR>";

      #
      # Filtering
      #  Do not allow these words in the SQL statament
      #
      $blacklist_arr = array ( 'drop', 'replace', 'create', 'alter', 'grant', 'flush', 'kill', 'load', 'optimize', 'lock', 'revoke' );

      foreach ( $blacklist_arr as $blacklist_item )
      {
         if ( preg_match("/$blacklist_item/i", $sql) )
         {
            Log::update($sql."\n".join('~+~', $sqlargs));
            var_dump($sql);var_dump($sqlargs);
            throw new PDOException("Problem with SQL statement. Keyword not allowed.");
         }
      }

      $results = array();

      $this->connect();
      $sth = $this->database_handle->prepare($sql);
      if ( method_exists($sth, "execute") )
      {
         if ( ! $sth->execute($sqlargs) )
         {
            Log::update(serialize($sth->errorInfo()));
            var_dump($sql);var_dump($sqlargs);
            throw new PDOException("Problem with SQL statament.".serialize($sth->errorInfo()));
         }
      }
      else
      {
         Log::update(serialize($this->database_handle->errorInfo()));
         throw new PDOException("Problem with SQL statement.".serialize($this->database_handle->errorInfo()));
      }
      $results = $sth->fetchAll();
      return $results;
   }

   /**
   * Method to submit query to database
   *
   * There are two ways to call this:
   *  - Syntax 1: executeSQL($sql)
   *     - Send $sql to the database
   *  - Syntax 2: executeSQL($sql, $sqlargs)
   *     - Send prepared statement $sql and $sqlargs to database
   *       (ex) $sql = 'UPDATE table SET name = ? WHERE num = ?';
   *            $sqlargs = array ('Bob', '1')
   *
   * @param $sql (string) SQL statament
   * @param $sqlargs (array) Array of arguments for prepared statement $sql
   * @return void
   */
   public function executeSQL($sql, $sqlargs)
   {
      # Please note that $this->getValue() can return 'undefined' which is different
      #  from ''. Undefined values will break prepared statements.
      $numargs = func_num_args();

      if ( $numargs == 1 )
      {
         $sql = func_get_arg(0);
         $sqlargs = array();
      }
      elseif ( $numargs == 2 )
      {
         $sql = func_get_arg(0);
         $sqlargs = func_get_arg(1);
      }
      else
      {
         throw new BadMethodCallException("Incorrect number of arguments.");
      }

      #print $sql."<BR>";
      #print join('|',$sqlargs)."<BR>";

      #
      # Filtering
      #  Do not allow these words in the SQL statament
      #
      $blacklist_arr = array ( 'drop', 'replace', 'create', 'alter', 'grant', 'flush', 'kill', 'load', 'optimize', 'lock', 'revoke' );

      foreach ( $blacklist_arr as $blacklist_item )
      {
         if ( preg_match("/$blacklist_item/i", $sql) )
         {
            Log::update($sql."\n".join('~+~', $sqlargs));
            var_dump($sql);var_dump($sqlargs);
            throw new PDOException("Problem with SQL statement. Keyword not allowed.");
         }
      }

      $this->connect();
      $sth = $this->database_handle->prepare($sql);
      if ( method_exists($sth, "execute") )
      {
         if ( ! $sth->execute($sqlargs) )
         {
            Log::update(serialize($sth->errorInfo()));
            var_dump($sql);var_dump($sqlargs);
            throw new PDOException("Problem with SQL statament.");
         }
      }
      else
      {
         Log::update(serialize($this->database_handle->errorInfo()));
         var_dump($sql);var_dump($sqlargs);
         throw new PDOException("Problem with SQL statement.".serialize($this->database_handle->errorInfo()));
      }
   }

   /**
   * Method to compare two database objects
   *
   * Note, this method works closely with __sleep()
   */
   public function matches($input_object)
   {
      if ( serialize($this) === serialize($input_object) )
      { return (TRUE); }
      else
      { return (FALSE); }
   }
}

?>
