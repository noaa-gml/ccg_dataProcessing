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
  04 June 2004  adapted from as_comm.h and made stand-alone, goto_sampleplan_mode, check_as_id, fix_memory added.
*/



/* System Includes */

#include "as_comm.h"		/* Includes required system includes. */
#include "string.h"
#include "strings.h"



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

  fclose(stderr);
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

/* if ((eid = open( "/dev/ttyn00", (O_RDWR | O_NDELAY), 0 )) < 0) */

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

/* changed from 0.15 to 0.25, November 22, 2004 - kam */
/* changed from 0.25 to 1.0, January 4, 2005 - kam,dwg */
/* changed as_timout from 1 to 5 s, January 4, 2005 - kam,dwg */

#define as_latency	1.00		/* Maximum response time of flask unit controller, in seconds.*/
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

void send_as_msg( int as_eid, char *p_outbuff )
  
{
  write( as_eid, p_outbuff, strlen( p_outbuff ));
  if (verbose)
    printf( "(send: %s ) \n", p_outbuff );
}

/******************************************************************************************************/
/* Function to append a \r\n to the data to be entered.  Then send the data to the open serial device.*/

void send_as_data(int as_eid, char *p_outbuff )
     
{
  char crlf[]="\r\n";
    p_outbuff=strcat(p_outbuff,crlf);
  write(as_eid, p_outbuff, strlen( p_outbuff ));
  if (verbose)
    printf("(send: %s ) \n",p_outbuff);
}


/****************************************************************************************************************/
/* Function to match an AS controller mode prompt to find out what mode the AS controller is in. Arguments are the
  prompt to match (from as_comm.h) and a string received from the controller. It is assumed that the prompt will
  be the last thing in the string and that the string is complete (fully received). Returns is_ok if there is a
  match, not_ok if no match. */

int match_as_prompt( p_prompt, p_string )
  char *p_prompt;
  char *p_string;
{
  int result;

  p_string = p_string + strlen( p_string ) - strlen( p_prompt );/* Position pointer where prompt should be. */
  /*printf("\n----%s::%s----\n",p_string,p_prompt);*/
  if (strcmp( p_prompt, p_string ) == 0)
    result = is_ok;
  else
    result = not_ok;

  return( result );
}

int match_prompt( p_prompt, p_string )  /*only input from a prompt*/
  char *p_prompt;
  char *p_string;
 
{
  int result;
  size_t  n;
  n = (strlen(p_string) - 1);
  *(p_string + n)=NULL;
  p_string = p_string + (strlen( p_string )) - strlen( p_prompt );

  /*printf("\n----%s:::%s----\n",p_string, p_prompt);*/

  if (strcmp(p_prompt, p_string) == 0)
    result = is_ok;
  else
    result = not_ok;

  return( result );
}

int match_data_prompt( p_prompt, p_string )  /*only input from a prompt*/
  char *p_prompt;
  char *p_string;
 
{
  int result;
  size_t  n;
 
  /* n = (strlen(p_string)-1); */      /*use for version 3.0*/
  n = (strlen(p_string));              /*use for Version 2.0*/

  (int) *(p_string+n)=NULL;
  p_string = p_string + (strlen( p_string )) - (strlen( p_prompt ));
  /* printf("\n----%s|||%s----\n",p_string, p_prompt); */
  if (strcmp(p_prompt, p_string) == 0)
    result = is_ok;
  else
    result = not_ok;

  return( result );
}


int match_data_prompt_v2( p_prompt, p_string )  /*only input from a prompt*/
  char *p_prompt;
  char *p_string;
 
{
  int result;
  size_t  n;
 
  /*n = (strlen(p_string)-1); */
  n = (strlen(p_string));

  (int) *(p_string+n)=NULL;
  p_string = p_string + (strlen( p_string )) - (strlen( p_prompt ));
  /*printf("\n----%s|||%s----\n",p_string, p_prompt);*/
  if (strcmp(p_prompt, p_string) == 0)
    result = is_ok;
  else
    result = not_ok;

  return( result );
}


/***********************************************************************************************************************/

/* Function to return the AS controller to the highest-level or 'AS' mode, from which all other modes may be reached. Handy
  to use to set a starting place before trying to reach a specific mode. Tries 4 times to reach the 'AS' mode (that's the
  greatest depth of the controller menus), then takes the noble suicide error exit route. */

#define max_AS_tries  5

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

/****************************************************************************************************************/
/* Function to fix the memory when checksums need updating.*/

int fix_memory(as_eid)
     int as_eid;
{
  char reply[maxline];
  int mem_fixed=1;
  goto_AS_mode(as_eid);
  send_as_msg(as_eid, fix_command);
  get_as_msg(as_eid, reply);
  /*printf("%s\n", reply);*/
  if (match_as_prompt( fix_prompt, reply ) != is_ok) 
     as_exit("fix_memory", "! Could not reach FIX MEMORY mode\n");
  send_as_msg(as_eid,fix_command);
  get_as_msg(as_eid, reply);
  send_as_msg(as_eid, yes_command);
  get_as_msg(as_eid, reply);
  if (match_data_prompt( "updated\r\nFIX MEMORY> ", reply ) != is_ok)
    printf("Did not update check sums.");
  return mem_fixed;
}
  
  

/*************************************************************************************************/
/* Function to set the PFP controller date and time to UTC.  Uses the system time.*/

int set_as_date(as_eid)
     int as_eid;
    
{
  char reply[maxline];
  int date_set=0;
  int mode_found, tries, i;
  char *yearstr, *monthstr, *daystr, *hourstr, *minstr;
  char *datestr;
  char year[10], day[5], month[5], hour[5],  min[5];
  char *sendstr;
  time_t now;
  struct tm *gmt;
  
  mode_found = not_ok;
  tries = 0;

  
  yearstr=&year[0];  /*Initialize pointers to date memory*/
  monthstr=&month[0];
  daystr=&day[0];
  hourstr=&hour[0];
  minstr=&min[0];
  now=time(NULL);
  gmt=gmtime(&now);  /*enter current time into date/time structure*/
  datestr=asctime(gmt);
  
  /*printf("GMT is: %s\n", datestr);*/
  /*strftime(str, maxline, "year %Y, month %m, day%d, hour%H, minute%M\n", gmt);
    printf("%s",str);*/
  strftime(year,10,"%Y", gmt); /*Get the year*/
  year[4]=NULL;
  yearstr=strcat(year,"\r\n");
  /*printf("%s\n",yearstr);*/
  strftime(month,5,"%m", gmt);
  month[2]=NULL;
  monthstr=strcat(month,"\r\n");
  /*printf("%s\n",monthstr);*/
  strftime(day,10,"%d", gmt);
  day[2]=NULL;
  daystr=strcat(day,"\r\n");
  /*printf("%s\n",daystr);*/
  strftime(hour,10,"%H", gmt);
  hour[2]=NULL;
  hourstr=strcat(hour,"\r\n");
  /*printf("%s\n",hourstr);*/
  strftime(min,10,"%M", gmt);
  min[2]=NULL;
  minstr=strcat(min,"\r\n");
  /*printf("%s\n",minstr);*/
  
  goto_AS_mode(as_eid);
  send_as_msg(as_eid, setup_command);
  get_as_msg(as_eid, reply);
  /*printf("%s\n",reply);*/
  if (match_as_prompt( setup_prompt, reply ) != is_ok)
     { 
       while ((tries++ < max_AS_tries) && (mode_found == not_ok))
       {
	 send_as_msg( as_eid,prompt_prompt );
	 get_as_msg( as_eid, reply );
	 /*printf("%s\n", reply);*/
	 mode_found = match_prompt(setup_prompt, reply );
       }
       if (mode_found!=is_ok)
        as_exit( "set_as_date", "! Could not reach SETUP mode \n" );
      } 
  send_as_msg(as_eid, date_command);
  get_as_msg(as_eid, reply);
  /*printf("%s\n",reply);*/
  i=0;
  while (match_data_prompt(date_entry_prompt, reply) == is_ok )
    {                             /*This loop enters the date information*/
    if (i==0)
      sendstr=yearstr;
    if (i==1)
      sendstr=monthstr;
    if (i==2)
      sendstr=daystr;
    if (i==3)
      sendstr=hourstr;
    if (i==4)
      sendstr=minstr;
    send_as_msg(as_eid, sendstr);
    get_as_msg(as_eid, reply);
    /*printf("%s\n", reply);*/
    i++;
  }  
  if (match_as_prompt(setup_prompt, reply)==is_ok)
    return date_set;
  else
    return -1;
}



/*************************************************************************************************/
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
    goto_AS_mode( as_eid );/* If not already in UNLOAD mode, start over at AS mode. */
    send_as_msg( as_eid, unload_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( unload_prompt, reply ) != is_ok)
      as_exit( "goto_UNLOAD_mode", "! Could not reach UNLOAD mode \n" );
  }
}


void goto_SETUP_mode( as_eid )
  int as_eid;
{
  char reply[maxline];

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply ); 
  if (match_as_prompt( setup_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );	/* If not already in SETUP mode, start over at AS mode. */
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
      as_exit( "goto_SETUP_mode", "! Could not reach SETUP mode \n" );
  }
}

/**************************************************************************/
/*Function to place the controller in Sample Plan mode from any other mode*/

void goto_sampleplan_mode( as_eid )
  int as_eid;
{
  char replymem[maxline];
  char *reply;
  int mode_found, tries;
  
  mode_found = not_ok;
  tries = 0;
  reply=&replymem[0];
  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply ); 
  /*printf("%s\n", reply);*/
  if (match_as_prompt( sample_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    /*printf("%s\n", reply);*/
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
     { 
       while ((tries++ < max_AS_tries) && (mode_found == not_ok))
       {
	 send_as_msg( as_eid,prompt_prompt );
	 get_as_msg( as_eid, reply );
	 /*printf("%s\n", reply);*/
	 mode_found = match_prompt(setup_prompt, reply );
       }
       if (mode_found!=is_ok)
        as_exit( "goto_sampleplan_mode", "! Could not reach SETUP mode \n" );
	} 

    mode_found = not_ok;
    tries = 0;

    send_as_msg( as_eid, sample_command );
    get_as_msg( as_eid, reply);
    /*printf("%s\n", reply);*/
    if (match_as_prompt(sample_prompt, reply ) != is_ok)
      {
	while ((tries++ < max_AS_tries) && (mode_found == not_ok))
        {
	 send_as_msg( as_eid, prompt_prompt );
	 get_as_msg( as_eid, reply );
	 /*printf("%s\n", reply);*/
	 mode_found = match_prompt(sample_prompt, reply);
        }  
        if (mode_found!=is_ok)
         as_exit( "goto_sampleplan_mode", "! Could not reach SAMPLE PLAN mode \n" );
      }
  }
}

/******************************************************************************************************/
/* Function to delete all previous flight plan information*/

int delete_samples(as_eid)
     int as_eid;
{
  char reply[maxline];
  int i=0;
  static char num[2];
  char *numptr;
  
  
  for (i=0;i<20;i++)
    {
      sprintf(num, "%2d", (i+1));
      numptr=strcat(num, "\r\n");
      send_as_msg(as_eid, setup_command);
      get_as_msg(as_eid, reply);
      /*printf("%s\n", reply);*/
      send_as_msg(as_eid, sample_command);
      get_as_msg(as_eid, reply);
      /*printf("%s\n", reply);*/
      send_as_msg(as_eid, delete_command);
      get_as_msg(as_eid, reply);
      /*printf("%s\n", reply);*/
      if (match_data_prompt(delete_sample, reply ) == is_ok)
	{
	  send_as_msg(as_eid,numptr);
	  get_as_msg(as_eid, reply);
	  /*printf("%s\n", reply);*/
	  if (match_data_prompt(delete_sure, reply) == is_ok)
	  {
	    send_as_msg(as_eid, yes_command);
	    get_as_msg(as_eid, reply);
	    /*printf("%s\n", reply);*/
	  }
	  else
	  {
	    as_exit("delete_samples", "!  Error Deleting Samples.\n");
	    /*printf("Error deleting samples.\n");*/
	    i=20;
	  }
	 }
      else
	{
	  as_exit("delete_samples", "!  Error Deleting Samples.\n");
	  /*printf("Error deleting samples.\n");*/
	  i=20;
	}
     }
  /*printf("Done deleting samples.\n");*/
  return 0;
}

/************************************************************************************************************/
/*Function to check the id of a PFP when a flight plan is sent to it.  ID is sent in the form of xxxx*      */
/*There can be no other characters in the number just xxxx 4 straight numbers. Any text is fine after the number.*/

int check_as_id(as_eid, idbuff)
     int as_eid;
     char idbuff[maxline];
     
{
  char reply[maxline];  /*define some memory*/
  char *checkstr;
  char *returnstr;
  char *strptr;
  int a=0,n=0;
  char *token[maxline];
  goto_AS_mode(as_eid);
  send_as_msg(as_eid, history_command);
  get_as_msg(as_eid, reply);
  /*printf("reply: %s", reply);*/
  if (match_as_prompt( history_prompt, reply ) != is_ok) 
     as_exit("check_as_id", "! Could not reach History mode to check ID number\n");
  send_as_msg(as_eid, number_command);
  get_as_msg(as_eid, reply);
  /*printf("%s\n", reply);*/
  token[a] = strtok(reply," ");
  token[++a]=strtok(NULL," ");
  token[++a]=strtok(NULL," ");
  /*printf("%d\n\n",a);*/
  n=a;
   for(a=0;a<n+1;a++)
    {
      /*printf("token %d is %s\n",a,token[a]);*/
    }
  (int) idbuff[4]=NULL;
  strptr=&idbuff[0];  /*create a pointer to the input serial string*/
  checkstr=strcat(token[n],"");
  /*printf("%s\n",checkstr);*/
  token[5]=strtok(checkstr, "\r");
  returnstr=strcat(token[5],"");
  /*printf("|||his:%s, file:%s|||\n",returnstr,strptr);*/
  n=strcmp(returnstr,strptr);  /* compare the serial number of unit to the serial number in the input file*/
  if (n==0)
    return is_ok;
  else
    return not_ok;
}

/******************************************************************************************************/
/* Function to set the site code of a PFP.  Uses a 3 digit string as the code entered. */

int set_as_sitecode( as_eid, codestr)
     int as_eid;
     char codestr[3];
{
  char reply[maxline], code[4], strsend[maxline], stringck[maxline];
  char *ptrcode;
  char *replyptr, *strsendptr, *stringckptr, *ptrcodestr;
  int mode_found, tries;
  
  ptrcode=&code[0];
  mode_found = not_ok;
  tries = 0;

  replyptr=&reply[0];
  strsendptr=&strsend[0];
  stringckptr=&stringck[0];
  ptrcodestr=&codestr[0];

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply ); 
  /*printf("%s\n", reply);*/
  if (match_as_prompt( setup_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    /*printf("%s\n", reply);*/
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
     { 
       while ((tries++ < max_AS_tries) && (mode_found == not_ok))
       {
	 send_as_msg( as_eid,prompt_prompt );
	 get_as_msg( as_eid, reply );
	 /*printf("%s\n", reply);*/
	 mode_found = match_prompt(setup_prompt, reply );
       }
       if (mode_found!=is_ok)
        as_exit( "se_as_sitecode", "! Could not reach SETUP mode \n" );
      } 
  }
  send_as_msg(as_eid, sitecode_command);
  get_as_msg(as_eid, reply);
  /*printf("%s\n", reply);*/

  if (match_data_prompt( code_enter_prompt, reply ) != is_ok)
    as_exit( "set_as_sitecode", "!  Error setting site code.\n");

  code[0]=codestr[0];
  code[1]=codestr[1];
  code[2]=codestr[2];
  code[3]=NULL;
  /*printf("%s\n",code);
    printf("%s\n", codestr);*/
  strsendptr = strcat(ptrcode, "\r\n");
  /*printf("%s\n", strsendptr);*/
  send_as_msg( as_eid, strsendptr);
  get_as_msg( as_eid, reply);
  /*printf("%s\n", reply);*/

  if (match_data_prompt(setup_prompt, reply ) == is_ok)
     return 0;
  else
     return -1;
}



/******************************************************************************************************/
void goto_limits_mode( as_eid )
  int as_eid;
{
  char reply[maxline];

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply ); 
  if (match_as_prompt( limits_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );			/* If not already in LIMITS mode, start over at AS mode. */
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
      as_exit("goto_limits_mode", "! Could not reach SETUP mode \n");
    send_as_msg( as_eid, limits_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( sample_prompt, reply ) != is_ok)
      as_exit( "goto_LIMITS_mode", "! Could not reach LIMITS mode \n" );
  }
}

