/* Open a given sample valve in the AS flask package. Use the routines
  in as_comm to open the serial channel to the flask controller and
  move to Unload mode. Give the sample valve open command, and wait
  for confirmation of the valve opening or a timeout. */

/* Revisions:
	28 Feb 1993	use new version of as_comm.h, with functions that trap their own errors through analysis_exit
	 2 Oct 1995	use new version of as_comm
*/


#include "as_comm.h"


main( argc, argv )
  int argc;
  char *argv[];
{
  int as_eid;
  int sample_n;
  char reply_s[maxline];
  char command_s[maxline];

/* Check that we have command line arguments of sufficient quantity
  and quality. */

  if (argc < 2)
    as_exit( argv[0], "! Sample number not given. \n" );

  sample_n = atoi( argv[1] );
  if ((sample_n < 1) || (sample_n > 20))
    as_exit( argv[0], "! Impractical sample number %s given, needs to be 1-20  \n", argv[1] );


/* Open the serial channel, and establish communication by making
  sure we're in unload mode. */

  as_eid = open_as_comm();
  goto_UNLOAD_mode( as_eid );


/* Now give the open command and the sample number. */

  sprintf( command_s, "%s %s %s", open_command, argv[1], prompt_prompt );
  send_as_msg( as_eid, command_s );
  get_as_msg( as_eid, reply_s );

/* Now check the reply for a completion prompt. If the command has already completed, we are dealing with a Version 2
  (or greater) sampling unit and are done. If it has not completed, we need are dealing with the slower Version 0 unit,
  and need to wait a few seconds for actuation to complete. */

  if (match_as_prompt( unload_prompt, reply_s ) != is_ok)
  {
    sleep( 10 );					/* Delay 10 seconds for valve actuation. */
    get_as_msg( as_eid, reply_s );
  }

/* Now see if the reply string contains the key phrase signaling a succesful opening. */

  if (strstr( reply_s, as_open_result ) == NULL)
    as_exit( argv[0], "! Sample valve %s failed to open. \n", argv[1] );

  close( as_eid );
}
