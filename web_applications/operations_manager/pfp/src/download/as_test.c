/* Test vehicle for as serial communications. */

#include "as_comm.h"


main()
{
  int eid;
  int status;
  char buffy[132];

  verbose = 1;				/* Set verbose mode on. */

  eid = open_as_comm();
  send_as_msg( eid, prompt_prompt );

  if (get_as_msg( eid, buffy ) != is_ok)
    printf( "bad status from get_as_msg \n\n" );
  else
    if (match_as_prompt( as_prompt, buffy ) == is_ok)
      printf( "matched AS mode \n\n" );
    else
      printf( "didn't match AS mode \n\n" );

}
