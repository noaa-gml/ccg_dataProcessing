<?php

######################################################################
function calDB ()
{
        // Connecting, selecting database
        $link = mysql_connect('localhost', 'apache', '')
        or die('Could not connect: ');
        mysql_select_db('reftank') or die('Could not select database');

}

?>
