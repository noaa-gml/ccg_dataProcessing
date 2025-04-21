#include <unistd.h>

#define REAL_FILE "/projects/aircraft/lib/pfp/pfp_makesum.pl"

main(ac,av)
int	ac;
char	**av;
{
	/*
	This c-wrapper is required when
	calling Perl scripts with the UNIX
	setuid set.  See Programming Perl,
	Second Edition, pp 360-361.
	
	August 21, 2000 - kam
	*/
	execv(REAL_FILE,av);
}
