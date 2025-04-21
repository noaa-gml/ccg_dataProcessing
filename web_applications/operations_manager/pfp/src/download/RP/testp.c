
#include "as_comm.h"

main()
{
  char c;
  int eid;

  if ((eid = open( "/dev/console", (O_RDONLY | O_NDELAY), 0 )) < 0)
    printf( "couldn't open \n" );
  else
    while( 1 )
      if (read( eid, &c, 1 ) == 1)
	putchar( c );
      else
	printf( "no input \n" );

}
