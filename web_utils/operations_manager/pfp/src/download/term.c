/* A quick & dirty terminal emulator for communicating with the AS flask package from a workstation. Port,
  parameters and options are all hardwired. */

/* Revision History

  8 Jul 1996	first version
  9 Jul 1996	try input buffer to cope with slow character handling
*/



/* System Includes */

#include "as_comm.h"		/* Includes required system includes. */



/* Function to open serial port communications with AS flask unit. Opens
  device files and sets port parameters. Returns the serial port device file
  eid or error (negative value).
*/

int open_as_comm()
{
  int eid;
  struct termios termcon;
  int n;

/*
  if ((eid = open( "/dev/tty05", (O_RDWR | O_NDELAY), 0 )) < 0)
*/
  if ((eid = open( "/dev/ttyn00", (O_RDWR | O_NDELAY), 0 )) < 0)
  {
    printf( "!serial port open cratered - can't do anything \n" );
    exit( -1 );
  }
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
    {
      printf( "!couldn't set port parameters (in termios block) \n" );
      exit( -1 );
    }

    tcflush( eid, TCIOFLUSH );				/* Flush the buffer (it's polite). */
  }
  return( eid );
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

#define buffsize 4096

main()
{
  int fdin, fdout;
  char inchar, outchar;
  char buff[buffsize];
  char *pin, *pout, *pend;

  fdout = open_as_comm();

  if ((fdin = open( "/dev/console", (O_RDONLY | O_NDELAY), 0 )) < 0)
  {
    printf( "!couldn't open console - crashing... \n" );
    exit( -1 );
  }

  pin = pout = buff;
  pend = buff + buffsize;

  while (1)
  {
    if (read( fdin, &inchar, 1 ) > 0) 
    {
      if (inchar == '\n')			/* Convert newline to return character, which is what as controller responds to. */
	inchar = '\r';
      write( fdout, &inchar, 1 );   
    }

    while (read( fdout, pin, 1 ) > 0)
      if (++pin > pend)
	pin = buff;				/* Wrap the buffer on input. */

    if (pin != pout) 
    {
      write( 0, pout++, 1);
      if (pout > pend)
	pout = buff;				/* Wrap the buffer on output. */
    }
  }
}
