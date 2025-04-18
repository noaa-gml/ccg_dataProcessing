#!/usr/bin/perl
use strict;
use warnings;
require "/ccg/src/db/ccg_utils.pl";
require "/ccg/src/db/validator.pl";
use Data::Dumper; #For debugging arrays and hashes.  Use like: print Dumper(\@data);


#JWM - 9.14.17
sub find_first_line_with_word {
    my ($filename, $search_word) = @_;
    open my $fh, '<', $filename or die "Could not open file '$filename': $!";
    
    my $line_number = -1;
    
    while (my $line = <$fh>) {
        $line_number++;
        chomp $line;
        if ($line =~ /^\Q$search_word\E/i) {  # Case-insensitive match for lines starting with the search word
            close $fh;
            return $line_number;
        }
    }
    
    close $fh;
    return undef;  # Return undef if no match is found
}

sub parseSimpleCSV()
{#NOTE; this may not be 100%.  It seemed to be truncating datasets in some cases.  Not sure if it was content or memory or what, but wanted to switch
   #to array based (instead of hash) because of naming issues anyway so didn't fully persue.  Have not noted any issues with parseSimpleCSVToArray()
   #jwm - 9.18
    #This does a 'simple' csv parsing.  This only works on files (like data files it was designed for) that do not
    #have embedded quotes or commas in the data fields.  It just does a simple split on separator and removes all quotes.
    #If you need more robust parsing, Text::CSV should be looked at.  It was not installed on all target environments though (and has a lot of overhead), so hence this...
    
    #Returns an array of hash references (header row as hash keys)
    # $file: file path
    # $headerRow: # (starting from 0) of header line
    # $separator: string of separator, usually a comma.  If single space passed, it matches variable white space.  Any valid param to split can be used.
    # (optional)$lc -> lower case header/hash names. 1 yes, 0 no (default)
    
    #Returns an array of hash references.  You can use like this:
    #   my @data=&parseSimpleCSV("test.csv",1,',');
    #   foreach my $line(@data){
    #        my %h=%{$line};#turn reference into a hash
    #        print $h{'TIMESTAMP'}."\n";
    #   }
    #   #or
    #   print $data[1]->{JUL}."\n";
    
    #NOTE; This method removes all quotes
        
    my ($file,$headerRow,$separator,$lc)=@_;
    my @data=();my @headerLine=();my $lcHeader=0;
    if (defined ($lc)) {
        $lcHeader=$lc;
    }
    
    #Get the header line for col names.  (note this is inefficient for big files.. should just read that line)
    my @lines=&ReadFile2($file);
    if(@lines){
	
    	my $t=$lines[$headerRow];
    	$t=~ s/^#//;#Strip leading comment # if there.
        if ($lcHeader) {$t=lc($t);}#Lower case all names if requested.
	#chomp($t);#remove line endings.  Actually this doesn't work right on windows files  and leaves the cr which causes issues..
        $t =~ s/\R\z//;#remove line endings

    	if($separator ne ' '){@headerLine=split($separator,$t);}
    	else{@headerLine=split(' ',$t);}#had to explicitly pass ' ' to get white space match to work, couldn't pass as variable for some reason.
 
    	#&printArray(@headerLine);
        #&printArray(@lines);
    	my $i=-1;
    	foreach my $line(@lines){
        	$i++;
		#chomp($line);#see above.
		$line =~ s/\R\z//;
        	next if $line=~ /^\#/;#skip comments
        	next if $line=~ /^\s*$/;#skip empty lines
        	next if $i<=$headerRow;#jwm. 7/19. added in <.  some files have extra lines at top that aren't comments (initfiles).  This skips those too.
        	$line =~ s/"//g;#Strip all quotes everywhere.  See comments above.
        	$line =~ s/'//g;
                my @fields=();
        	#parse line
        	if($separator ne ' '){@fields=split($separator,$line);}
        	else {@fields=split(' ',$line);}#see above.
        	
        	#Error if cols don't match header
        	if (scalar @fields != scalar @headerLine) {
        	    print "Error.  Number of columns does not match header columns.  Line # $i\n$line\n";
        	    &printObj(@fields);
            	    &printObj(@headerLine);
            		exit();
        	}
        
        	#Create a hash of line using column headers as keys
        	my %t=();my $n=0;
        	foreach my $col(@headerLine){
        	    $t{$col}=$fields[$n];
        	    $n++;
        	}
        	
        	#add to output array
        	push(@data,\%t);
        	
    	}
    }else{ print "Error opening file $file\n";}	
    
    return @data;
}
sub parseSimpleCSVToArray(){
    #See comments above.  This is similar, but returns an indexed array instead of hash
    #Returns an array of array references 
    # $file: file path
    # $skipLines: # of lines to skip
    # $separator: string of separator, usually a comma.  If single space passed, it matches variable white space.  Any valid param to split can be used.
    
    #Returns an array of array references.  You can use like this:
    #   my @data=&parseSimpleCSVToArray("test.csv",1,',');
    #   foreach my $line(@data){
    #        my @a=@{$line};#turn reference into an array
    #        print $a[2]."\n";
    #   }
    #   #or
    #   print $data[1]->[2]."\n";
    
    #NOTE; This method removes all quotes
        
    my ($file,$skipLines,$separator)=@_;
    my @data=();

    #Get the header line for col names.  (note this is inefficient for big files.. should just read that line)
    my @lines=&ReadFile2($file);
    if(@lines){
    	my $i=-1;my $numCols=-1;
    	foreach my $line(@lines){
            $i++;
        	next if $i<$skipLines;
        	$line =~ s/"//g;#Strip all quotes everywhere.  See comments above.
        	$line =~ s/'//g;
            my @fields=();
        	#parse line
        	if($separator ne ' '){@fields=split($separator,$line);}
        	else {@fields=split(' ',$line);}#see above.
        	
        	#Error if cols don't match previous lines.
        	if (scalar @fields != $numCols && $numCols>=0) {
        	    print "Error.  Number of columns does not match header columns. File:$file Line # $i\n$line\n";
        	    #&printObj(@fields);
                #exit();
        	}
            $numCols=scalar @fields;#Track number of cols
            
        	#add to output array
        	push(@data,\@fields);  	
    	}
    }else{ print "Error opening file $file\n";}	
    
    return @data;
}
sub getHashVariable(){
    #Returns value if present for key in h hash, or defaultValue, type can be 'date', 'time', 'datetime','int', 'float','string'
    #Returns string 'FALSE' if not present or not valid $type
    #To make a required field, pass '' for default value and 1 for required.  This will exit if missing/invalid
    #Note; $hash must be a reference to a hash, not the hash itself!!
    #Note type string returns true if non blank.
    #Note this tries upper and lower case keys
    my ($hashRef,$key,$defaultValue,$type,$required)=@_;
    my %h=%{$hashRef};#turn reference into a hash
    my $return=$defaultValue;
    my $t='';
    if(defined($h{lc($key)})){$t=$h{lc($key)};} #Lower case
    elsif(defined($h{uc($key)})){$t=$h{uc($key)};} #upper case
    if ($t ne '') {
        my $valid=0;
        if ($type eq 'date') {$valid=&ValidDate($t);}
        elsif($type eq 'time'){$valid=&ValidTime($t);}
        elsif($type eq 'datetime'){$valid=&ValidDatetime($t);}
        elsif($type eq 'int'){$valid=&ValidInt($t);}
        elsif($type eq 'float'){$valid=&ValidFloat($t);}
        elsif($type eq 'string'){if($t ne ''){$valid=1;}}
        if ($valid){$return=$t;}        
    }
    if ($return eq '' && $required==1) {
        print "ERROR: Invalid/Missing value ('$t') for key:'$key', defaultValue:'$defaultValue', type:'$type', required:'$required'.  /ccg/src/db/perllib.pl->getHashVariable()\n";
        printObj(%h);
        exit(1);
    }
    
    return $return;
}
sub printArray(){
    #dump array to screen
    my @a=@_;
    foreach my $line(@a){print $line."\n";} 
}
sub printObj{#better name for below
    print Dumper(\@_);
}
sub printComplex{#dump arbitrary obj to screen.
    print Dumper(\@_);
}
sub parseDateStamp{
    #Parses a timestamp in format of 2017-08-28 23:01:59
    #returns ($yr,$mo,$dy,$hr,$mn,$sc,$date,$time,$dd);
    
    my ($z)=@_;
    my $yr = substr($z,0,4);
    my $mo= substr($z,5,2);
    my $dy= substr($z,8,2);
    my $hr = substr( $z, 11, 2 );
    my $mn = substr( $z, 14,2 );
    my $sc = substr( $z, 17, 2 );
    my $date= substr($z,0,10);
    my $time=substr($z,11,8);
    my $dd = &date2dec( $yr, $mo, $dy, $hr, $mn, $sc );
    return ($yr,$mo,$dy,$hr,$mn,$sc,$date,$time,$dd);
}
sub now(){
	#Returns various date time parts of current datetime in an array, first local, then gmt
	#0 date
	#1 date time
	#2 year
	#3 month num
	#4 day num
	#5 hr num
	#6 min num
	#7 sec num
	#8 month name
	#9 day of yr
	#10 pretty datetime
	#GMT
	#11 date
	#12 date time
	#13 year
	#14 month num
	#15 day num
	#16 hr num
	#17 min num
	#18 sec num
	#19 month name
	#20 day of yr
	#21 pretty datetime
	
	use POSIX qw(strftime);
	my $now=time();
	#local
	my ($sc,$mn,$hr,$dy,$mo,$yr,$wd,$doy,$dst) = localtime($now);
	my $thisYear=$yr+1900;my $thisMon=$mo+1;
	my $date = sprintf("%04d-%02d-%02d",$thisYear,$thisMon,$dy);
	my $datetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$thisYear, $mo+1, $dy,$hr,$mn,$sc);
	my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	my $prettydt=strftime "%a %b %e %H:%M:%S %Y", localtime($now);
	#gmt
	my $gmtprettydt=strftime "%a %b %e %H:%M:%S %Y", gmtime($now);
	my ($gsc,$gmn,$ghr,$gdy,$gmo,$gyr,$gwd,$gdoy,$gdst) = gmtime($now);
        my $gthisYear=$gyr+1900;my $gthisMon=$gmo+1;
        my $gdate = sprintf("%04d-%02d-%02d",$gthisYear,$gthisMon,$gdy);
        my $gdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$gthisYear, $gmo+1, $gdy,$ghr,$gmn,$gsc);
	
	return ($date,$datetime,$thisYear,$thisMon,$dy,$hr,$mn,$sc,$abbr[$mo],$doy,$prettydt,$gdate,$gdatetime,$gthisYear,$gthisMon,$gdy,$ghr,$gmn,$gsc,$abbr[$gmo],$gdoy,$gmtprettydt);
}
sub logToFile{
    #write passed data to /tmp/perllog.txt
    #overwrites whatever may be there
    my ($txt)=@_;
    open(my $fh,'>','/tmp/perllog.txt');
    print $fh $txt."\n";
    close $fh;
}
sub sendEmail(){
   #Sends email using sendmail.
   my ($to,$cc,$bcc,$reply_to,$subject,$content) = @_;
   my $sendmail = "/usr/sbin/sendmail -t";
   open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
   print SENDMAIL "To: $to","\n";
   if ( $cc ne "" ) { print SENDMAIL "CC: $cc","\n"; }
   if ( $bcc ne "" ) { print SENDMAIL "bcc: $bcc","\n"; }
   print SENDMAIL "Reply-to: $reply_to","\n";
   print SENDMAIL "Subject: $subject","\n";
   print SENDMAIL $content,"\n";
   close(SENDMAIL);
}

sub ReadFile2{
   #Same as ccg_utils.pl->ReadFile(), but does a chomp instead of chop so that lines with no LE don't lose last char.
   #I'd like to fix the lib version, but am concerned that chop was used for specific reason like if weird line endings exists on
   #some files.  Since that's used everywhere (and has no comments on why chop used), made 2nd version for specific cases where
   #chomp is definately more appropriate. jwm - 8/18:
   my ($f) = @_;
   my @arr = ();
   open (FILE, $f) || return @arr;
   (@arr) = <FILE>;
   chomp (@arr);
   close (FILE);

   return @arr;
}


