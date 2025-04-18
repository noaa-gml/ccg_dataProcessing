#!/usr/bin/perl

# Uses output from relater2.pl to create diagram link
# to pass to yumi.me
#
# For example, http://yuml.me/diagram/class/%5BDepartment%5D,%5BSpecialDepartment%5D,%5BSpecial%2FDepartment2%5D,%5BSpecialDepartment%5D-%5E%5BDepartment%5D,%5BSpecial%2FDepartment2%5D-%5E%5BDepartment%5D,%5BSpecial%2FDepartment2%5D-%5E%5BDepartment%5D

require '/projects/src/db/ccg_utils.pl';

$file = 'input.txt';

open(FILE, "$file");
@inputarr = <FILE>;
close(FILE);

chomp(@inputarr);

@inputarr = grep(/^[^#]/, @inputarr);

foreach $inputline ( @inputarr )
{
   ($dbtable, $source) = split(/~/, $inputline);

   push(@entities, sprintf('[%s]', &urlencode($dbtable)));
   push(@entities, sprintf('[%s]', &urlencode($source)));

   push(@relations, sprintf('[%s]-^[%s]', &urlencode($source), &urlencode($dbtable)));
}

@entities = &unique_array(@entities);

print join(',', @entities).','.join(',',@relations)."\n";

exit;
