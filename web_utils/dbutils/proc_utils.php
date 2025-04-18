<?php

function proc_streamCmd($cmd, $logfile='',$autoscroll=true,$completionJS=''){
    /*Runs command and streams output back to browser.  Automatically closes on user abort.  Can't be called by ajax,
    but ajax can populate a div with an iframe to a php page that then just links this file and calls this function.  $_SESSION can be used
    to pass the cmd 
    $autoscroll rolls the window so the latest output is visible
    $completionJS - js to run when finished.  Should be a function like parent.jsfunc() or
        parent.document.getElementById('runcmd_div').innerHTML('Done!')
        jsfunc may need to be declared in head or imported (not body).
    ex:
    <html><head></head><body>Loading...
    <?php
        session_start();
            if(isset($_SESSION['cmd']))$cmd=$_SESSION['cmd'];
        session_write_close();
        if(!$cmd){
            echo("Failed to load command");exit();
        }
        require_once("/var/www/html/inc/dbutils/proc_utils.php");
        $f="/var/www/html/aircore/lib/aircore_trajectory_prediction/work_dir/log.txt";
        proc_streamCmd($cmd,$f);
    
    ?>
    </body></html>
    
    */
    if($logfile)logerr("Running cmd: $cmd\n",$logfile);

    $descriptorspec = array(
       0 => array("pipe", "r"),   // stdin is a pipe that the child will read from
       1 => array("pipe", "w"),   // stdout is a pipe that the child will write to
       2 => array("pipe", "/tmp/error-output.txt", "a")    // stderr is a file to write to
    );
    flush();ob_implicit_flush(true);ob_end_flush();
    $proc=new Proc($cmd,$descriptorspec, null, array());
    echo "<pre>";$isDownload=false;$downloadblock=0;$prevWasDownload=false;
    if ($proc->isRunning()) {
        if($logfile)logerr("Proc running",$logfile);
        while ($s = fgets($proc->pipe(1))) {
            if(connection_aborted()){
                if($logfile)logerr("User abort detected, closing proc",$logfile);
                $proc->close();
            }
            #Special logic to handle download progress bar
            if(strpos($s, 'Downloading') === 0){
                if(!$prevWasDownload){#first one, set up a new div block
                    $downloadblock++;
                    print("<div id='downloadProg_${downloadblock}'></div>
                        <script>window.scrollTo(0,document.body.scrollHeight);</script>");
                }
                $prevWasDownload=true;
                $s=str_replace("\n","",$s);#newline messes with js assignment
                print("<script>document.getElementById('downloadProg_${downloadblock}').innerHTML=\"$s\";</script>");
                
            }else{  
                $prevWasDownload=false;
                print $s;
                if($autoscroll)print "<script>window.scrollTo(0,document.body.scrollHeight);</script>";//Keep content scolled to bottom (assumes being called in iframe.)
            }
            flush();
        }
    }
    
    $proc->close();
    
    echo "</pre>";
    if($completionJS)echo "<script>$completionJS;</script>";    
}
$toLogFile_first2=true;
function logerr($txt,$file){#Dumps text to $file for debugging process stuff...
    if($file && $txt){
        global $toLogFile_first2;
        $mode=($toLogFile_first2)?"w":"a";
        if(!$handle = fopen($file, $mode)){//attempt to open file
            var_dump ("Cannot open writable log file: $file");
            exit();
        }
        if (fwrite($handle, $txt."\n") === FALSE) {//attempt to write to it.
            echo ("Cannot write to file ($txt)");
            exit();
        }
        fclose($handle);
        $toLogFile_first2=false;
    }
}

class Proc
{//Wrapper class to proc_open.  attempts to ensure kill works, but had to add check to caller to actually
//get it to work when page refreshes (if(connection_aborted()){).  See above  proc_streamCmd().
    private $_process;
    private $_pipes;

    public function __construct($cmd, $descriptorspec, $cwd = null, $env = null)
    {
        $this->_process = proc_open("exec ".$cmd, $descriptorspec, $this->_pipes, $cwd, $env);
        if (!is_resource($this->_process)) {
            throw new Exception("Command failed: $cmd");
        }
    }

    public function __destruct()
    {
        if ($this->isRunning()) {
            $this->terminate();
        }
    }

    public function pipe($nr)
    {
        return $this->_pipes[$nr];
    }

    public function terminate($signal = 15)
    {   #Send terminate signal and don't wait for response.
        $s=$this->getStatus();
        
        posix_kill($s['pid'], SIGKILL);
        
        $ret = proc_terminate($this->_process, $signal);
        
        if (!$ret) {
            throw new Exception("terminate failed");
        }
    }

    public function close()
    {   #Controlled shutdown.
        #According to the interwebs: It is important that you close any pipes before calling
          // proc_close in order to avoid a deadlock
        #I'm not sure that's needed, but seems harmless.
        fclose($this->_pipes[0]);
        fclose($this->_pipes[1]);
        fclose($this->_pipes[2]);
        $ret=proc_close($this->_process);
        return $ret;
    }

    public function getStatus()
    {
        return proc_get_status($this->_process);
    }

    public function isRunning()
    {
        $st = $this->getStatus();
        return $st['running'];
    }
}

?>