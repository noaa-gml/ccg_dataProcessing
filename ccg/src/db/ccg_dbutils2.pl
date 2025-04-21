#Utility wrappers for sql queries
#I didn't add these to ccg_dbutils.pl because they use prototyping which may cause issues for callers.
#jwm - 4/16
#
#REQUIRES ccg_dbutils, declared $dbh and calls to connect_db() prior and disconnect_db() after
#require "/projects/src/db/ccg_utils.pl";
#require "/projects/src/db/ccg_dbutils.pl";


sub dosql($@){
#Returns a reference to an array of hash references (each row).
#Use like this:
#       $a=dosql("select * from tag_view",());
#       foreach $row (@{$a}){
#              my($num,$desc)=@{$row}{qw(num display_name)};
#              print "$num: $desc\n";
#              #or
#              print ${$row}{num}."\n";
#       }
#
#You can use bind variables like this:
#$a=dosql("select * from tag_view where internal_flag like ?",('A..'));

        my ($sql,@bind_values)=@_;
        my $sth=$dbh->prepare($sql);
        $sth->execute(@bind_values);
        my $a=$sth->fetchall_arrayref({});
        $sth->finish(); 
        return $a;

}
sub dosqlval($@){
#Returns single value as a scalar.
#Returns undef if no rows or error.
##Use like this:
#print dosqlval("select count(*) from tag_view where internal_flag like ?",('A..'));
        my($sql,@bind_values)=@_;
        my $val="";
        my $sth=$dbh->prepare($sql);
        my $a=$sth->execute(@bind_values);
	if($a){
        	$val=$sth->fetchrow_array();
	}
        $sth->finish();
        return $val;
}
sub dodml($@){
#do an insert/update/delete/create
#Returns number of affected rows when relevant, -1 if not known, undef on error
#If you are doing multiple inserts (lots) it may be better to roll your own like this:
#my $sth=$dbh->prepare($sql);
#   foreach...
#       n++ if $sth->execute(@bind_values);
        
        my($sql,@bind_values)=@_;
        my $n=$dbh->do($sql,undef,@bind_values);
        return $n;
}
sub demodb(){
#Use the mund_dev database and put up a notice for testing
        dodml("use mund_dev",());
        print "\nUsing database: ".dosqlval("select database()",())."\n\n";
}
sub arrayToJSON($@){
#Takes passed reference to perl array or hash and converts to a json array or object.
#Values can be scalar, arrays or hashes.
#Note; all scalar values are quoted like strings even if numbers.  This is because of complexity of determining unambiguous type of scalar and because the 
#current only use (php web app communication) treats all as string anyway.  We use this instead of json libs because we want to make sure 
#the output is compatible with php web app (see below).
#NOTE! this must be kept in sync with inc/dbutils/dbutils.php->arrayToJSON() function
#
#Note; this is intended for jsonifying config variables, not user input.  Escaping below is not robustly tested.

	my ($arr)=@_;
 	my $json="";
	if(ref($arr) eq 'HASH' || ref($arr) eq 'ARRAY'){
		my $hash=(ref($arr) eq 'HASH');
		$json=($hash)?'{':'[';
		if($hash){
			for my $key (keys %{$arr}){
				$json.="\"$key\":";
				my $val=$arr->{$key};
				if(ref($val) eq 'ARRAY' || ref($val) eq 'HASH'){$json.=arrayToJSON($val);}
				else{
					$val =~ s/"/\\"/g;#escape embedded double quotes
					$json.="\"$val\"";#quote the whole string
				}
				$json.=",";
			}
		}else{
			for my $val (@{$arr}){
				if(ref($val) eq 'ARRAY' || ref($val) eq 'HASH'){$json.=arrayToJSON($val);}
				else{
					$val =~ s/"/\\"/g;#escape embedded double quotes
                                        $json.="\"$val\"";#quote the whole string
				}
				$json.=",";
			}
		}		
		$json= substr($json,0,-1);#remove trailing comma
		$json.=($hash)?'}':']';	
	}else{
		$json="{}";#empty object
	}
	return $json;
}

1;
