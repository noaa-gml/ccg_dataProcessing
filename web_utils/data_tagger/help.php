<html>
    <head> 
        <LINK rel="stylesheet" type="text/css" href="styles.css">
    </head>
    <body class='helpContent'>
        <div class='title1'>Help</<div><br>
        <?php
        include("lib/help_contents.php");
        foreach($help as $topic=>$content){
            echo "<br><div class='title3'><a name='$topic'>$topic</a></div><div class='data'>$content</div>";
        }
        ?>
    </body>
</html>
