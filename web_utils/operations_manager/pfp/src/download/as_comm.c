/* A library for HP-UX programs which communicate over serial line with the aircraft sampling flask unit controller.

	as_exit( source_id, error_msg )			error exit routine
	open_as_comm()					open serial port i/o
	get_as_msg( as_eid, p_inbuff )			receive string from serial port
	send_as_msg( as_eid, p_outbuff )		send string from serial port
	match_as_prompt( p_prompt, p_string )		match a prompt string to the end of a received string
	goto_AS_mode( as_eid )				send AS controller to highest-level 'AS' mode 
	goto_UNLOAD_mode( as_eid )			put AS controller into UNLOAD mode

  Revision History

  12 May 1992   first version.  
  27 May 1995	adapted from as_comm.h and made stand-alone, as_exit put to use
*/



/* System Includes */

#include "as_comm.h"		/* Includes required system includes. */



/* Standard system error exit routine, which all comm functions must use to
  consistantly report errors and exit cleanly (should cause analysis
  system shutdown by error trap at highest level program/script call).
  The source_id argument is a string intended to be the name of the function or
  program which is exiting. The error_msg argument may be specific to the
  error cause, and may include conversion specs with arguments following.
  If the system error flag errno is non-zero, a call to the standard
  error message printout is also made. All error messages go to stderr,
  which may be redirected from a higher level. Note this routine requires
  the inclusion of <stdarg.h>. */

void as_exit( char *source_id, char *error_msg, ... )
  /*
  char *source_id;
  char *error_msg;
  */
{
  va_list p_args;

  va_start( p_args, error_msg );          /* Initialize argument pointer. */
  fprintf( stderr, "%s: ", source_id );   /* Print location of error. */
  vfprintf( stderr, error_msg, p_args );  /* Print cause of error. */

  if (errno != 0)                       /* Print system error, if any. */
    fprintf( stderr, "  sys err %d, %s \n", errno, strerror( errno ) );

  va_end( p_args );                     /* Clean up pointer list handling. */

  exit( program_failed );               /* Failure flags defined locally, for now. */
}



/* Function to open serial port communications with AS flask unit. Opens
  device files and sets port parameters. Returns the serial port device file
  eid or error (negative value).
*/

int open_as_comm()
{
  int eid;
  struct termios termcon;
  int n;

/* if ((eid = open( "/dev/ttyS0", (O_RDWR | O_NDELAY), 0 )) < 0) */

/*  if ((eid = open( "/dev/ttyn00", (O_RDWR | O_NDELAY), 0 )) < 0) */

  if ((eid = open( serialport, (O_RDWR | O_NDELAY), 0 )) < 0)
    as_exit( "open_as_com", "open cratered \n" );
  else
  {					            /* Create a termios block: */
    termcon.c_iflag = 0;		            /* No input modes set. */
    termcon.c_oflag = 0;		            /* No output modes set. */
    termcon.c_cflag = B9600 | CS8 | CREAD | CLOCAL;
    termcon.c_lflag = 0;		            /* No local modes set. */
    for (n =0; n <NCCS; n++)
      termcon.c_cc[n] = _POSIX_VDISABLE;            /* Disable all control chars. */
    termcon.c_cc[VMIN] = 0;		            /* Set no minimum char count. */

    if (ioctl( eid, TCSETS, &termcon ) < 0)
      as_exit( "open_as_com", "couldn't set port parameters (in termios block) \n" );

    tcflush( eid, TCIOFLUSH );				/* Flush the buffer (it's polite). */
  }
  return( eid );
}


/* A function to receive a complete message from a flask unit. This task is complicated by the flask unit echoing characters sent
  and by the message usually not terminating with a <cr> (usually the line is left hanging after the prompt prints). This confuses
  the UNIX serial driver. The solution is to request characters from the driver one at a time, until no more are available for at
  least 1 second (the maximum expected latency of the flask unit controller). All of the characters are assembled as one string, to
  represent the controller's response. The flip side of the timing issue is that if no characters are received for at least 10
  seconds, the line is considered dead and an error value is returned. The function causes an error exit if no characters 
  were received. */

/* changed as_timeout from 10 to 5 s (January 4, 2005 - kam,dwg) */

#define as_latency	1		/* Maximum response time of flask unit controller, in seconds.*/
#define as_timeout	5		/* Serial line timeout for dead line, in seconds. */


void get_as_msg( as_eid, p_inbuff )
  int as_eid;
  char *p_inbuff;
{
  char buffy;
  char *p_remember;
  clock_t whenever;
  clock_t lineout;
  int nchars;

  p_remember = p_inbuff;
  nchars = 0;
  lineout = clock();

  while ((nchars == 0) && (clock() < (lineout + (as_timeout * CLOCKS_PER_SEC))))
  {
    whenever = clock();
    while (clock() < (whenever + (as_latency * CLOCKS_PER_SEC)))
      if (read( as_eid, &buffy, 1 ) > 0)
      {
        *(p_inbuff++) = buffy;
	nchars++;
        whenever = clock();
      }
  }

  *p_inbuff = '\0';		/* Terminate string. */

  if (nchars == 0)
    as_exit( "get_as_msg", "! Did not receive any reply from flask unit controller \n" );
  else
    if (verbose)
      printf( "(get: %s ) \n", p_remember );
}




/* Function to send a command to AS controller. Split off as a seperate
  function to easily evaluate global verbose flag and display prompt
  on stdout if set. */

void send_as_msg( as_eid, p_outbuff )
  int as_eid;
  char *p_outbuff;
{
  write( as_eid, p_outbuff, strlen( p_outbuff ));
  if (verbose)
    printf( "(send: %s ) \n", p_outbuff );
}




/* Function to match an AS controller mode prompt to find out what mode the AS controller is in. Arguments are the
  prompt to match (from as_comm.h) and a string received from the controller. It is assumed that the prompt will
  be the last thing in the string and that the string is complete (fully received). Returns is_ok if there is a
  match, not_ok if no match. */

int match_as_prompt( p_prompt, p_string )
  char *p_prompt;
  char *p_string;
{
  int result;

  p_string = p_string + strlen( p_string ) - strlen( p_prompt );	/* Position pointer where prompt should be. */

  if (strcmp( p_prompt, p_string ) == 0)
    result = is_ok;
  else
    result = not_ok;

  return( result );
}



/* Function to return the AS controller to the highest-level or 'AS' mode, from which all other modes may be reached. Handy
  to use to set a starting place before trying to reach a specific mode. Tries 4 times to reach the 'AS' mode (that's the
  greatest depth of the controller menus), then takes the noble suicide error exit route. */

#define max_AS_tries  4

void goto_AS_mode( as_eid )
  int as_eid;
{
  int tries;
  char reply[maxline];
  int as_mode_found;

  as_mode_found = not_ok;
  tries = 0;

  while ((tries++ < max_AS_tries) && (as_mode_found == not_ok))
  {
    send_as_msg( as_eid, quit_command );
    get_as_msg( as_eid, reply );
    as_mode_found = match_as_prompt( as_prompt, reply );
  }

  if (as_mode_found != is_ok)
    as_exit( "goto_AS_mode", "! Could not reach AS mode in %d tries \n", max_AS_tries );
}



/* Put the AS controller into UNLOAD mode. This is a seperate function because it MAY be called before the first sample is
  opened, but NEEDS to be called before any sample is opened (to ensure the correct mode). Does not return status because
  failure to reach the mode will cause an error exit directly from here. */

void goto_UNLOAD_mode( as_eid )
  int as_eid;
{
  char reply[maxline];

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply ); 
  if (match_as_prompt( unload_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );			/* If not already in UNLOAD mode, start over at AS mode. */
    send_as_msg( as_eid, unload_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( unload_prompt, reply ) != is_ok)
      as_exit( "goto_UNLOAD_mode", "! Could not reach UNLOAD mode \n" );
  }
}
