/* Program to retreive the sampling history from a PFP sampling unit -
 downloads, formats & stores the individual PFP history blocks and
 some ancilliary date and pressure information in a single file. */

/* Revisions:

	 3 Oct 1995	first version
        27 Apr 2006     nth version - Added get_as_datetim and get_all_pressure
        19 Oct 2006     modified to handle PFP firmware v3.03 and v3.06(+)
                        wrapped as_comm.h and as_comm.c into this file so it
                          can stand alone 
                        revised open() call for serial port to be a cleaner
                          non-canonical implementation
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
#define maxline 128

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


/*********************************************************************/
/* Routine to get the current PFP sample mode setting, i.e. semi- or
  full-automatic. For this we must go to Limits Mode, list the limits
  and find the sampling mode label. Return a formatted string for the
  history file. */

void *get_pfp_samplemode( char *p_result_s )
{
  goto_pfp_mode( "S\r", "SETUP> " );  /* First get reliably to Setup Mode, */
  send_pfp_msg( "L\r" );              /* then kick down to Limits Mode, */
  get_pfp_reply( buffy, '>' );        /* read & dump the Limits prompt, */
  send_pfp_msg( "L\r" );              /* then list the Limits. */
  get_pfp_reply( buffy, '>' );        
  
/* Match on substrings, formatting the output based on whats found. Could 
   just copy in the strings returned by the PFP, but this gives us more 
   control over formatting. */

  if (strstr( buffy, "semi auto" ))
    strcpy( p_result_s, "semi" );
  else
    if (strstr( buffy, "full auto" ))
      strcpy( p_result_s, "full" );
    else
      as_exit( "get_pfp_samplemode", "! Could not find sampling mode flag \n" );
}


/***************************************************************/
/* Routine to measure the PFP manifold pressure using the Monitor
  command in Test Mode. Assumes the PFP is already in Test Mode (this
  cuts down multiple change-mode calls). Simply looks for the 
  "pressure" keyword in the big mess that is returned, then grabs
  all digits after the keyword and copies them into the returned
  string. */

void get_pfp_pressure( char *p_press )
{
  char *p_buffy;

  send_pfp_msg( "M\r" );
  get_pfp_reply( buffy, '>' );

  if ((p_buffy = strstr( buffy, "pressure" )) == NULL)
    as_exit( "get_pfp_pressure", "! Could not find pressure value \n" );

                                    /* Get past keyword & whitespace. */
  while (!(isdigit( *(++p_buffy))) && (*p_buffy != '\0'));

  while ((isdigit(*p_buffy)) || (*p_buffy == '.'))
    *p_press++ = *p_buffy++;

  *p_press = '\0';                       /* Terminate copied string. */
}


/*********************************************************************/
/* This routine does the pressure dance to get readings of the current
  front and (sort of) back manifold pressures, for PFPs that have been
  modified with a back manifold. Reads the front manifold pressure,
  then opens the solenoid bypass valve and reads the 'average' of the
  front and back manifold pressures. Returns string representations of
  the front-manifold and average-manifold pressures for inclusion in the
  history file. */

void get_all_pressures( char *p_frontpress, char *p_avgpress )
{
  goto_pfp_mode( "T\r", "TEST> " );

  get_pfp_pressure( p_frontpress );

  send_pfp_msg( "B\r" );          /* Open the solenoid bypass - no need */
  send_pfp_msg( "O\r" );          /* to read the reply. */

  sleep(2);                         /* Let the pressure average out */

  send_pfp_msg( "B\r" );          /* Close the bypass valve */
  send_pfp_msg( "C\r" );          

  get_pfp_pressure( p_avgpress );
}


/********************************************************************/
/* Function to read a PFP date/time prompt, copy the prompt (current)
 value and send it back to the PFP as the 'new' value. This satisfies
 the PFP date/time set sequence without actually changing the current
 PFP date and time.
  Assume that the prompt from the PFP is waiting in the input buffer.
  Oh, return the numerical value of the copied value string, because
 it's needed for a status check. */

int pfp_datetime_response()
{
  char reply_s[ maxline ];
  char sendback_s[ maxline ];
  char *p_reply; 
  char *p_sendback;

  get_pfp_reply( reply_s, ':' );      /* Assume every date/time prompt ends
                                        with a ':'. */
  p_reply = reply_s;
  p_sendback = sendback_s;

  while (!(isdigit( *p_reply )))      /* Get us to the prompt value. */
    p_reply++;

  while (isdigit( *p_reply ))         /* Copy the prompt value. */
    *(p_sendback++) = *(p_reply++);

  *(p_sendback++) = '\r';             /* Add a carriage return. */
  *p_sendback = '\0';                 /* Terminate the prompt reply. */

  send_pfp_msg( sendback_s );         /* Send the number back to the PFP. */

  return( atoi( sendback_s ));        /* Return the numeric value for
                                        further testing. */
} 


/********************************************************************/
/* Routine to find groups of digits in a character buffer and convert
 them to integer values. Note that the pointer to the buffer is double
 dereferenced so that the pointer position after the last set of
 digits can be returned in order to continue the search for the next
 set of digits. Note also that this pointer is always left on a non-
 digit character.
  The buffer is presumed to be 0-terminated (like a string) so we don't
 accidently core dump. */

int get_next_timevalue( char **p_p_buff )
{
  char digits_s[ 32 ];
  char *p_digits;
                                     /* Find the start of a set of digits. */
  while (!(isdigit( **p_p_buff)) && (**p_p_buff != '\0'))
    *p_p_buff += 1;
                                     /* Now copy all the digit cahracters. */
  p_digits = digits_s;
  while ((isdigit( **p_p_buff )) && (**p_p_buff != '\0'))         
  {
    *(p_digits++) = **p_p_buff;
    *p_p_buff += 1;
  }

  *p_digits = '\0';                  /* Terminate digits string. */

  return( atoi( digits_s ));
}


/********************************************************************/
/* Function to read the current PFP date and time, compare it to
  real (system) time, and return the difference as a formatted string.
   Because the date and time are only accesible through Setup mode
  in Versions 2 and 3.03, must do it the hard way by pretending to
  set the clock. Because of the (D)ate vs (T)ime menu differences
  between versions 3.03 and 3.06+, need to prompt for the whole menu
  and make a decision on what flavor PFP we're talking to. Ugly, but
  temporary. Yeah.
   Because Version 3.03 has a bug that clears the time if no arguments
  are given for time values, must echo the current time values.
   Because this process is error prone, take the actual PFP time from
  the confirmation at the end of the PFP date/time setting sequence. 
   Note that the PFP time read can be off by up to 5 seconds due to all
  this fooling around. */

int get_pfp_time_offset( char *p_time_s )
{
  char *p_buffy;
  char *p_prompt;
  int time_offset;
  int promptyear;
  struct tm pfp_datetime;

  goto_pfp_mode( "S\r", "SETUP> " );      /* Get into Setup Mode, */

  send_pfp_msg( "\r" );                   /* Get PFP to kick out the menu */
  get_pfp_reply( buffy, '>' );              /* to see if this is a 3.03 or */
  if (strstr( buffy, "(T)ime" ) != NULL)    /* 3.06+; set the 'set time'*/
    p_prompt = "T\r";                     /* prompt accordingly. */
  else
    p_prompt = "D\r";
  
  send_pfp_msg( p_prompt );              /* Send the date/time set command. */

  promptyear = pfp_datetime_response();     /* Echo the year, */
  pfp_datetime_response();                  /* month, */
  pfp_datetime_response();                  /* day, */
  pfp_datetime_response();                  /* hour, */
  pfp_datetime_response();                  /* minute (no seconds). */
  
 /* The summary time set reply is something like "Date and Time now set 
   to HH:MM:SS  YYYY-MM-DD". Parse this out by just looking for groups 
   of digits, which is simple but may not be robust enough. */

  if (promptyear < 1000)                    /* If Version 2, 0 result. */
    time_offset = 0;
  else
  {
     get_pfp_reply( buffy, '>' );       /* Presume that summary time response
                                          is sitting in system in buffer. */  

     p_buffy = strstr( buffy, "Time" );  /* Start number search after this
                                          tag name in reply. */

/* Tragically, the date and time report is reversed in PFP version 3.03
  versus 3.06+. Hence an extra decision step here to get the order right. */

     if (*p_prompt == 'T')
     {
       pfp_datetime.tm_year = get_next_timevalue( &p_buffy ) - 1900;
       pfp_datetime.tm_mon =  get_next_timevalue( &p_buffy ) - 1;
       pfp_datetime.tm_mday = get_next_timevalue( &p_buffy );

       pfp_datetime.tm_hour = get_next_timevalue( &p_buffy );
       pfp_datetime.tm_min =  get_next_timevalue( &p_buffy );
       pfp_datetime.tm_sec =  get_next_timevalue( &p_buffy );
     }
     else
     {
       pfp_datetime.tm_hour = get_next_timevalue( &p_buffy );
       pfp_datetime.tm_min =  get_next_timevalue( &p_buffy );
       pfp_datetime.tm_sec =  get_next_timevalue( &p_buffy );

       pfp_datetime.tm_year = get_next_timevalue( &p_buffy ) - 1900;
       pfp_datetime.tm_mon =  get_next_timevalue( &p_buffy ) - 1;
       pfp_datetime.tm_mday = get_next_timevalue( &p_buffy );
     }
                                       /* Note system time is always UTC. */
     time_offset = mktime( &pfp_datetime ) - time( NULL );
     time_offset += pfp_datetime.tm_gmtoff;   /* Re-correct mktime for UTC. */
  }
  
  sprintf( p_time_s, "%d", time_offset );
}


/***************************************************************/
/* Function to read in individual history blocks and save them 
  to the history file. First writes the section title argument
  to the file, then prompts the PFP with the given history block
  prompt. The PFP will respond with 12 lines of history information,
  which are first buffered in all together, then broken into lines
  (terminated by <cr>) and written to the file. */

void read_history( char *section_title, char *command_prompt )
{
  char *p_buffy;
  char out_s[maxline];
  char *p_out;

  send_pfp_msg( command_prompt );

/* Buffer up the reply from the PFP and check the size. If smaller than the
 magic number shown here, assume that the PFP did not reply with a full
 twelve lines of info because the requested history block does not exist in
 this version of the PFP. If the block doesn't exist, write nothing to the
 save file. Make an exception for the Serial Number History, which should
 return fewer characters than a prompt listing. */
 
  get_pfp_reply( buffy, '>' );

/* Now parse the buffer into lines, and write the lines out to file. 
  Throw away the first line and the remnants of the last line as being
  prompt leftovers. */

  fprintf( savefile, "%s\n", section_title );

  p_buffy = buffy;

  while ((*p_buffy != '\0') && (*p_buffy++ != '\n'));  /* Remove first line. */

  while (*p_buffy != '\0')
  {
    p_out = out_s;
    while ((*p_buffy != '\0') && ((*p_out++ = *p_buffy++) != '\n'));
    *p_out = '\0';			/* Terminate string. */
    if (*p_buffy != '\0')		/* Remove last line. */
      fprintf( savefile, out_s );
  }

  fprintf( savefile, "\n" );
}


/***************************************************************/
/* Get the site code, just from version 2 or 3.03. This routine
 is broken out here just to be tidy. Assumes PFP is already in
 History Mode. */

void read_site_history()
{
  char *p_end;
  char *p_buffy;

  send_pfp_msg( "S\r" );                   
  get_pfp_reply( buffy, '>' );               

  p_buffy = strstr( buffy, "Site" );     /* Site Code reply starts with */
  p_end = strstr( buffy, "HISTORY" );    /* keyword 'Site', ends with */
  *p_end = '\0';                         /* History prompt. */

  fprintf( savefile, "%s \n\n", p_buffy );  /* Write to History File,
                                              mimicking unusual number of
                                              newlines for historical 
                                              reasons. */
}


/***************************************************************/
/* To create the History File, this program communicates with the
  PFP over the host serial link. First it using several peculiar
  parsing routines to get special information like the PFP serial
  number, time and date, and manifold pressure(s). Then it reads
  all available History Mode blocks from the PFP, and puts all the
  available information in the designated savefile as it goes. */

int main( int argc, char *argv[] )
{
  char mode_s[32];
  char fpress_s[32];
  char apress_s[32];
  char time_s[32];
  char *p_unitblock;
  char *p_endblock;

/* Take the serial port as a command-line argument. */

  if ((argv[1] != NULL) && (strlen(argv[1]) >3))
    pfp_eid = open_pfp_comm( argv[1] );               
  else
    as_exit( argv[0], "! No serial port argument given on command line \n" );

/* Let calling program redirect stdout to the final file destination. */

  savefile = stdout;                     

/* Get 'extra' information like pressures and time offsets that are not part
  of the PFP firmware mandate. */

  get_pfp_samplemode ( mode_s );             /* Go to Limits mode and get the 
                                               sampling mode setting value. */ 
  get_all_pressures( fpress_s, apress_s );   /* Go to Test mode and get the 
                                               current manifold pressure. */ 
  get_pfp_time_offset( time_s );             /* Go to Setup mode and get 
                                               (current - PFP) time. */
  goto_pfp_mode( "H\r", "HISTORY> " );
  send_pfp_msg( "U\r" );
  get_pfp_reply( buffy, '>' );

          /* This is the same 3.03/3.06+ test used by the perl translator. */ 

  if (strstr( buffy, "firmware" ) != NULL)
  {                                                 /* PFP version 3.06+ */
    fprintf( savefile, "Unit History \n" );
    p_unitblock = strstr( buffy, "serial" );        /* Clean up Unit History */
    p_endblock = strstr( buffy, "HISTORY" );        /* block reply and write */
    *p_endblock = '\0';                             /* it to History File. */
    fprintf( savefile, p_unitblock ); 
    fprintf( savefile, "sys_minus_pfp_time: %s \n", time_s );
    fprintf( savefile, "front_pressure: %s \n", fpress_s );
    fprintf( savefile, "avg_pressure: %s \n\n", apress_s );
    read_history( "Altitude History",  "A\r" );
    read_history( "Location History",  "L\r" );
    read_history( "Time History",      "T\r" );
    read_history( "Fill History",      "F\r" );
    read_history( "Flag History",      "E\r" );
    read_history( "Ambient History",   "C\r" );
    read_history( "GPS History",       "G\r" );
  }
  else
  {                                              /* PFP version 2 or 3.03 */
    fprintf( savefile, 
     "Site History ~ sampling mode:%s ~ Pf:%s ~ Pave:%s ~ sys minus pfp:%s \n",
     mode_s, fpress_s, apress_s, time_s );
    read_site_history();
    read_history( "Serial Number History", "N\r" );  
    read_history( "Altitude History",   "A\r" );
    read_history( "Location History",   "L\r" );
    read_history( "Fill History",       "F\r" );
    read_history( "Error History",      "E\r" );
    read_history( "Ambient Conditions", "C\r" );
  }

  send_pfp_msg( "Q\r" );          /* added return-to-main-menu to prevent v2 
                                      checksum errors */
  close( pfp_eid );
}
