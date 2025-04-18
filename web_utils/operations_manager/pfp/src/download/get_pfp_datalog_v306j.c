/* Program to retreive the continuous data log from a PFP sampling unit -
 downloads the datalog a paragraph at a time from the serial port
 specified on the command line, and spits the results out to stdio
 where it is presumably piped to a save file by the host process. This
 is a self-contained stand-alone program for both compilation and execution. */

/* Revisions:

  24 June 2009      1st version, source code borrowed from get_pfp_history
*/


/* Common System Includes */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <strings.h>
#include <termio.h>
#include <termios.h>
#include <unistd.h>
#include <stropts.h>

/* Handy General Definitions */

#define is_ok 1
#define not_ok 0
#define maxline 512

/* Magic Number definitions, placed here for easy reference. */

#define as_timeout 10		/* Serial line timeout, in seconds. */
#define as_latency 1		/* Max PFP response time, in seconds. */
#define as_buffsize 2000	/* Most chars in a history table reply. */

/* Global variables, defined here reduce subroutine overhead. */

  FILE *savefile;               /* The output file (= stdout ) */
  int pfp_eid;                  /* The hardware serial port open id. */
  char buffy[ as_buffsize ];    /* Define the big reply buffer here, once and
                                   global, to reduce allocation overhead. */


/***************************************************************/
/* Standard system error exit routine, which all comm functions 
  should use to consistantly report errors and exit cleanly.
  The source_id argument is a string intended to be the name of 
  the subroutine which is exiting. The error_msg argument string
  is for documenting the problem, and may include conversion specs 
  with arguments following.
  If the system error flag errno is non-zero, a call to the standard
  error message printout is also made. All error messages go to stderr,
  which may be redirected from a higher level. Note this routine requires
  the inclusion of <stdarg.h>. */

void as_exit( char *source_id, char *error_msg, ... )
{
  va_list p_args;

  va_start( p_args, error_msg );          /* Initialize argument pointer. */
  fprintf( stderr, "%s: ", source_id );   /* Print location of error. */
  vfprintf( stderr, error_msg, p_args );  /* Print cause of error. */

  if (errno != 0)                       /* Print system error, if any. */
    fprintf( stderr, "  sys err %d, %s \n", errno, strerror( errno ) );

  va_end( p_args );                     /* Clean up pointer list handling. */

  exit( -1 );                           /* Halts program w/ error set. */
}



/****************************************************************************/
/* Routine to initialize a file descriptor to and given serial port and init
  the hardware & software configuration. As per gnu lib ref manual, best to
  open the port, then get its i/o settings, modify them for our needs and
  re-write the settings.
  NOTE that the serial port is opened non-canonical 
  (character oriented) and nonblocking, so that at least one character
  must be received before read calls can return. Read calls will also keep
  reading until no character is received for 100 ms. */

int open_pfp_comm( char *serialportname )
{
  int fdsp;
  struct termios serialport;

  if ((fdsp = open( serialportname, (O_RDWR))) < 0)
    as_exit( "open_pfp_com", 
             "open cratered for serial port name %s \n", serialportname );

  if (tcgetattr( fdsp, &serialport ) < 0)
    as_exit( "open_pfp_com", 
             "could not get settings for serial port %s \n", serialportname );

  cfmakeraw( &serialport );     /* make port noncanonical */ 
  serialport.c_iflag &= ~INPCK;	/* turn off input parity checking */
  serialport.c_iflag &= ~IXOFF;	/* turn off input start/stop control */
  serialport.c_oflag &= ~ONLCR;	/* turn off linefeed append */
  serialport.c_cflag |= CLOCAL;	/* ignore modem status lines */
  serialport.c_cflag |= CREAD;	/* enable input reading */
  serialport.c_cflag &= ~CSTOPB;	/* set one stop bit */
  serialport.c_cflag &= ~PARENB;	/* set no parity */
  serialport.c_cflag |= CS8;		/* set 8 bits per byte */
  cfsetspeed( &serialport, B9600 );
  serialport.c_cc[VTIME] = 2;	/* set character wait timeout for 200 ms */
  serialport.c_cc[VMIN] = 0;    /* If MIN is zero, read will return as soon
                                 as any number of characters is recieved.
                                 Since there is a delay in the get_pfp_reply
                                 function (below), most characters should
                                 already be in the receive buffer. Using this
                                 mode is a compromise, neccesary because the
                                 other modes will block until at least one
                                 character is received (which hangs program
                                 if PFP is unplugged). */

  if (tcsetattr( fdsp, TCSAFLUSH, &serialport ) < 0)
    as_exit( "open_pfp_com", 
      "could not change settings for serial port %s \n", serialportname );

  return( fdsp );
}


/*****************************************************************************/
/* Routine to provide timeout protection for serial port reads. This routine
  should be called before every serial port read.  */

void waitforit()
{
  fd_set set;
  struct timeval timeout;

  FD_ZERO( &set );
  FD_SET( pfp_eid, &set );

  timeout.tv_sec = 1;
  timeout.tv_usec = 0;

  if (select( FD_SETSIZE, &set, NULL, NULL, &timeout ) == 0)
    { printf( "serial port read timeout \n" ); exit(0); }
}


/***********************************************************************/
/* Function to send a command to PFP controller. Split off as a seperate
  function to easily add diagnostics if needed. */
/* Delay after send added here to slow things down a bit, prevent stepping
 on the PFP during replies. This couldn't hurt in the serial/ethernet
 environment where delivery times and character bunching are uncertain. */

void send_pfp_msg( char *p_outbuff )
{
  write( pfp_eid, p_outbuff, strlen( p_outbuff ));
  sleep( 1 );
}


/***************************************************************/
/* Routine to buffer the reply from a PFP after a command prompt
 is sent. Since this can be a multi-line reply, the buffer can get
 quite large (see defined size above). Buffer everything in on a
 character-by-character basis, then terminate the buffer like it
 was one big string and hand the buffer and character
 count back to the calling routine. This avoids missing any reply
 characters or lines if serial communications get bunched up over
 remote connections. Use the terminating character argument to 
 decide when the message is complete, and depend on the timeout (VTIME)
 set when opening the serial port (see above) as a safety timeout.
  If no characters at all are received within as_timeout seconds,
 declare the line dead and commit an error exit. */

int get_pfp_reply( char *p_buff, char endchar )
{
  int n_newchars;
  int final_length;
  int found_end;

  final_length = 0;
  found_end = not_ok;

  while ((final_length < as_buffsize) && (found_end == not_ok))
  {
    if ((n_newchars = read( pfp_eid, p_buff, as_buffsize )) > 0)
    {
      final_length += n_newchars;
      for( ; n_newchars >0; n_newchars--)  /* Check each new character to */
        if (*(++p_buff) == endchar)        /* see if the block end character */
          found_end = is_ok;               /* has come in yet. */
    }
    else
      found_end = is_ok;           /* Mis-use end flag here to get us out
                                    of the loop on a timeout or error. */
  }

  if (final_length == 0)
    as_exit( "get_pfp_reply", "! no reply from PFP \n" );

  *(++p_buff) = '\0';                      /* Terminate like a string for the
                                              convenience of some calling
                                              routines. */
  return( final_length );
}


/********************************************************************/
/* Function to put the PFP controller into a requested mode. Starts
  by always returning to the root AS mode, then gives the mod command
  from there and checks the returned prompt to see if the mode was
  actually entered. NOTE that this scheme is only good for going down
  one level in the PFP modes, but that's all that's needed in to get
  all the history information (even info needed from other modes).
   Note that the read buffer is a global string variable.
   If the requested mode cannot be entered, commits an error exit 
  because someting fundamental must be wrong, eh? */

void goto_pfp_mode( char *p_mode_command, char *p_mode_prompt )
{
  int n_tries;

  		             /* Start by going to AS mode no matter what. */
  n_tries = 0;
  do
  {
    send_pfp_msg( "Q\r" );
    get_pfp_reply( buffy, '>' ); 
  } 
  while (!(strstr( buffy, "AS> ")) && (n_tries++ < 3));

  if (n_tries >= 3)
    as_exit( "goto_pfp_mode", "! Could not reach AS> prompt from PFP \n" );

  send_pfp_msg( p_mode_command );
  get_pfp_reply( buffy, '>' );

  if (!(strstr( buffy, p_mode_prompt )))
    as_exit( "goto_pfp_mode", "! Could not reach %s mode \n", p_mode_prompt );
}


/***************************************************************/
/* Function to read in datalog pargraphs and save them 
  to the datalog file. Paragraphs are separated by a blank line,
  so this routine buffers characters until two carriage returns
  in a row (seperated by a single character, the line feed) are
  received, then stores that paragraph to the designated savefile.
  The end of the datalog is defined by a timeout when no more
  characters are received. */

void read_datalog()
{
  char *p_buff;			/* Use this to point at the (global) serial in buffer. */
  char paragraph[maxline];	/* Use this to assemble a data paragraph, one char at a time. */
  char *p_par;			/* Handy pointer into the data paragraph string. */

  int start_of_log;		/* Use to flag the top of the datalog dump. */
  int n_newchars;		/* Character count for any one visit to the serial in read. */
  int par_length;		/* Use to check that the data paragraph string does not over-run. */

  start_of_log = not_ok;
  p_par = paragraph;			/* Reset char output to start for new paragraph. */
  par_length = 0;			/* Reset data paragraph length counter. */

  while ((n_newchars = read( pfp_eid, buffy, as_buffsize )) > 0) 	/* Get received serial characters. */
  {
    p_buff = buffy;					/* Init convenience pointer to serial input buffer. */
    for( ; n_newchars >0; n_newchars--)  
    {  
      *p_par++ = *p_buff++;			  	/* Move a character from the serial */
					  		/* input buffer to the paragraph buffer. */
      par_length++;					/* Increment current size of data paragraph. */
      if (par_length > (maxline -4))			/* Test if data paragraph now too big; */
      {
        *p_par++ = '\r';				/* if it is, then trigger a paragraph save (don't */
        *p_par++ = '\r';                                /* want to risk losing data). */
      }

      if (*(p_par -1) == '#')				/* This character marks the true beginning of the */
        start_of_log = is_ok;				/* datalog dump, thus eliminating echoed PFP commands. */

      if (*(p_par -1) == '\r')        	  		/* See if blank line has happened yet.  */
        if ((*(p_par-2) == '\r') ||   			/* (build a little flexibility into the 'blank */
            (*(p_par-3) == '\r') ||   			/* line' definition by checking the last three */
            (*(p_par-4) == '\r'))     			/* character positions for the first occurance */
        { 				  		/* of <cr>) */
          *p_par = '\0';	  			/* Terminate data paragraph string. */
          if (start_of_log == is_ok)
            fprintf( savefile, paragraph );		/* Save data paragraph to designated file. */
          p_par = paragraph;				/* Reset char output to start for new paragraph. */
          par_length = 0;				/* Reset data paragraph length counter. */
        }
    }
  }
}



/***************************************************************/
/* To download the PFP data log, this program communicates with the
  PFP over the host serial link.
*/

int main( int argc, char *argv[] )
{

/* Take the serial port as a command-line argument. */

  if ((argv[1] != NULL) && (strlen(argv[1]) >3))
    pfp_eid = open_pfp_comm( argv[1] );               
  else
    as_exit( argv[0], "! No serial port argument given on command line \n" );

/* Let calling program redirect stdout to the final file destination. */

  savefile = stdout;                     

/* Get into History mode, and test whether this is a version 3.06j PFP (and
 therefore capable of having a data log. This is the same 3.03/3.06+ test 
 used by the perl translator in OM. */ 

  goto_pfp_mode( "H\r", "HISTORY> " );
  send_pfp_msg( "U\r" );
  get_pfp_reply( buffy, '>' );

  if (strstr( buffy, "firmware" ) != NULL)
  {                                                 /* So this is a PFP version 3.06j then... */
    send_pfp_msg( "D\r" );			    /* Give command to dump the datalog out. */
    read_datalog();				    /* Store datalog paragraphs to savefile as they come out. */
  }

/* Note that if this was not a version 3.06j PFP, we do nothing. */

  send_pfp_msg( "Q\r" );          /* added return-to-main-menu to prevent v2 
                                      checksum errors */
  close( pfp_eid );
}
