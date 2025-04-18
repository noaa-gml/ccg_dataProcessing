/* Program to retreive the sampling history from an AS sampling unit. 
 * Starts by finding the highest-level 'AS' mode
 * of the controller, then puts the controller in (H)istory mode, 
 * then requests each type of history (altitude,
 * location, fill conditions, errors, ambient conditions). As each 
 * line of each history is received, it is added to
 * a file specified in the header. 
 */

/* Revisions:

	 3 Oct 1995	first version
        27 Apr 2006     nth version - Added get_as_datetim and get_all_pressure
*/

#include "as_comm.h"		/* Includes all needed system includes. */

/* #define save_filepath  "/projects/aircraft/history" */		/* Don't include the last '/' */
#define save_filepath  "/home/magicc/history"		/* Don't include the last '/' */


/* Function to read in individual history tables and save them to file. 
 * First writes the section title argument
 * to the file. Then prompts the AS sample controller with the given prompt. 
 * Assembles lines character by character, 
 * (this is a legacy of communicating with AS prompts) and writes a line to 
 * the output file when complete. Expects
 * n_samples lines plus a header line in each table. Excessive waiting causes 
 * an error exit from the program. 
 */

#define as_timeout 10			/* Serial line timeout, in seconds. */
#define as_latency 1			/* Maximum AS controller response time, in seconds. */
#define as_buffsize 2000		/* Most characters in a single history table reply. */


/***************************************************************/
void goto_limits_mode( as_eid )
  int as_eid;
{
  char reply[maxline];
  int result;
  char *p_string;
                                                                                          
  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply );
  if (match_as_prompt( limits_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );  /* If not already in LIMITS mode, start over at AS mode. */
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
      as_exit("goto_limits_mode", "! Could not reach SETUP mode \n");
    send_as_msg( as_eid, limits_command );
    get_as_msg( as_eid, reply );

    p_string = reply + strlen( reply ) - strlen( limits_prompt );        /* Position pointer where prompt should be. */
                                                                                          
    /* if (strstr( limits_prompt, p_string ) != 0) */
    if (strstr( limits_prompt, p_string ))
      as_exit( "goto_LIMITS_mode", "! Could not reach LIMITS mode \n" );
  }
}

double get_as_pressure( as_eid, savefile )
  int as_eid;
  FILE *savefile;
{
  char buffy[as_buffsize];
  char *p_buffy;
  char out_s[maxline];
  char *p_out;
  char *p_end;
  clock_t whenever;
  int nchars;
  char *press;
  double press_double;

  sleep( as_latency );

  while (read( as_eid, buffy, 1 ) > 0 );

  send_as_msg( as_eid, monitor_command );

/* First, 'fast buffer' all of the reply in, to avoid character
 * loss when dealing with the serial driver on a line-by-line
 * or character-by-character basis. Depend on latency timeout to
 * let us know when we're done.
 */
                                                                                          
  p_buffy = buffy;
  whenever = clock();
  while (clock() < (whenever + (as_latency * CLOCKS_PER_SEC)))
    if ((nchars = read( as_eid, p_buffy, maxline )) > 0)
    {
      p_buffy += nchars;
      whenever = clock();
    }

/* Now parse the buffer into lines, and write the lines out to file.
 * Throw away the first line and the remnants of the
 * last line as being prompt leftovers.
 */
                                                                                          
    p_end = p_buffy;
    p_buffy = buffy;
                                                                                          
    while (*p_buffy++ != '\n' && p_buffy < p_end);      /* Remove first line. */
    //while (*p_buffy++ != '\n' && p_buffy < p_end);      /* Remove second line. */

    p_out = out_s;
    /* Get 3 lines */
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    *p_out = '\0';                      /* Terminate string. */

    if ( ! ( press = strstr( out_s, "pressure" ) ) )
      as_exit( "get_as_pressure", "! Could not find pressure value \n" );

    press += 8;

    /* Pass the rest of the string after "pressure" into atof.
       atof reliably cuts out the number and throws away the rest
       of the string. */
    press_double = atof(press);

    return press_double;

    //printf ( "%3.1f\n", press_double );

    // Need to find pavg!
}

/***************************************************************/
void get_all_pressure( as_eid, savefile, as_press )
  int as_eid;
  FILE *savefile;
  char *as_press;
{
  char reply[maxline];
  double front_press;
  double ave_press;
  char out_str[30];

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply );
  if (match_as_prompt( test_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );  /* If not already in TEST mode, start over at AS mode. */
    send_as_msg( as_eid, test_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( test_prompt, reply ) != is_ok)
      as_exit("get_all_pressure", "! Could not reach TEST mode \n");
  }

  /* Get the front pressure */

  front_press = get_as_pressure(as_eid, savefile);

  /* Open the bypass valve */
  send_as_msg( as_eid, bypass_command );
  get_as_msg( as_eid, reply );
  send_as_msg( as_eid, open_command );
  get_as_msg( as_eid, reply );

  /* Let the pressure average out */
  sleep(2);

  /* Close the bypass valve */
  send_as_msg( as_eid, bypass_command );
  get_as_msg( as_eid, reply );
  send_as_msg( as_eid, close_command );
  get_as_msg( as_eid, reply );

  /* Get the average pressure */
  ave_press = get_as_pressure(as_eid, savefile);

  sprintf( out_str, " ~ Pf:%3.1f ~ Pave:%3.1f", front_press, ave_press );

  strcpy(as_press, out_str);
  //printf ( "%3.1f\n", front_press );
  //printf ( "%3.1f\n", ave_press );

}

/***************************************************************/
int get_as_datetime( as_eid, savefile, vtime )
  int as_eid;
  FILE *savefile;
  char *vtime;
{
  char reply[maxline];
  int mode_found, tries, i;
  int j, k; /* Abused graciously */
  char pfield[10];
  char ttime[25];
  char ddate[25];
  int diff;
  int year;
  int ver2chk;
  int t_begin = -1;
  int t_end = -1;
  int d_end = -1;
  time_t now;
  struct tm *p_utc;
  time_t utc_time;
  struct tm *p_pfp;
  time_t pfp_time;
  char *pch;
  char out_str[30];

  mode_found = not_ok;
  tries = 0;

  send_as_msg( as_eid, prompt_prompt );
  get_as_msg( as_eid, reply );
  if (match_as_prompt( setup_prompt, reply ) != is_ok)
  {
    goto_AS_mode( as_eid );  /* If not already in SETUP mode, start over at AS mode. */
    send_as_msg( as_eid, setup_command );
    get_as_msg( as_eid, reply );
    if (match_as_prompt( setup_prompt, reply ) != is_ok)
      as_exit("goto_as_datetime", "! Could not reach SETUP mode \n");
  }
  send_as_msg(as_eid, date_command);
  get_as_msg(as_eid, reply);
  /* printf("%s\n",reply); */

  /* There is a bug in version 3 PFPs. When a user gets to the date prompt
     if they just hit enter, then it will set the time to 00:00:00. This
     problem does not exist with version 2 PFPs. */

  /* Note: When the date_command is sent to the PFP, the date and time at
     that moment is cached. As the date and time is set through prompts,
     the fields are changed to the inputted number. The seconds field cannot
     be set though. This section of the code takes ~5 seconds to run. So,
     the PFP time is offset by another ~5 seconds every time this section
     of code is run. If the program crashes and restarts again, the more
     times this section of code runs the more the offset in the time will
     increase. */
  i=0;
  ver2chk=0;
  while (strstr(reply, date_entry_prompt))
  {

     /* Get the beginning index of the number field */
     j=5;
     t_begin=-1;
     while ( t_begin == -1 )
     {
        if ( reply[j] >= '0' && reply[j] <= '9' )
        { t_begin = j; }
        else { j++; }
     }

     /* Get the end index of the number field */
     t_end=-1;
     while ( t_end == -1 )
     {
        if ( reply[j] < '0' || reply[j] > '9' )
        { t_end = j; }
        j++;
     }

     /* Cut out the number from the reply */
     j=0;
     for ( k=t_begin; k<t_end; k++ )
     {
        pfield[j] = reply[k];
        j++; 
     }
     pfield[j] = '\0';

     /* We do not want to run this function for version 2's because their
        date format is different. And since at this time (4/25/2006) there are
        only a few version 2's in operation there is no need to write extra
        code that is going to be used infrequently. The bug in version 2's is
        when it shows the year, it is current year - 1900. In version 3's the
        year is stored as the 4 digit current year. */
     if ( i == 0 )
     {
        year = atoi(pfield);
        if ( year < 1000 ) { ver2chk = 1; }
     }

     /* Send the number back the PFP */
     sprintf ( pfield, "%s\r\n", pfield);

     send_as_msg(as_eid, pfield);
     get_as_msg(as_eid, reply);
     /* printf("%s\n", reply); */
     i++;
  }

  if ( ver2chk == 1 ) { return 0; }

  /* p_utc and p_pfp are both pointers to a struct tm.
     Everytime that gmtime() is called, the struct tm that
     gmttime uses is overwritten. So, p_utc and p_pfp
     point to the same structure. We need to make sure
     to get the right times to compare. Immediately
     after getting the system time, we figure out the seconds.
     Then parse the date and time string from the PFP and
     figure out the seconds for that. Then difftime() */

  /* Get the current time */
  now = time( NULL );
  if ((p_utc = gmtime( &now )) == NULL)
    as_exit("get_as_datetime", "! Could not get system time \n");
  utc_time = mktime(p_utc);
  /* printf("%d\n", utc_time); */

  now = time( NULL );
  p_pfp = gmtime( &now );

  /* The reply is something like "Date and Time now set to HH:MM:SS  YYYY-MM-DD" */
  /* Cut the time field from the reply */
  j=5;
  t_begin=-1;
  while ( t_begin == -1 )
  {
     if ( reply[j] >= '0' && reply[j] <= '9' )
     { t_begin = j; }
     else { j++; }
  }

  /* The time field is in the format HH:MM:SS which is a 8 character field */
  j=0;
  for ( k=t_begin; k<t_begin+8; k++ )
  {
     pfield[j] = reply[k];
     j++; 
  }
  pfield[j] = '\0';

  strcpy(ttime, pfield);

  /* Make sure that colons are in the time, in case we have dropped characters */
  if ( ( ttime[2] != ':' ) || ( ttime[5] != ':' ))
    as_exit("get_as_datetime", "! PFP time error \n");

  j=0;
  pch = strtok (ttime,":");
  while (pch != NULL)
  {
    if ( j==0 )
       p_pfp->tm_hour = atoi(pch);
    if ( j==1 )
       p_pfp->tm_min = atoi(pch);
    if ( j==2 )
       p_pfp->tm_sec = atoi(pch);
    /* printf ("%s\n",pch); */
    pch = strtok (NULL, ":");
    j++;
  }

  /* Cut the date field from the reply */
  d_end = -1;
  j = strlen(reply);
  while ( d_end == -1 )
  {
     if ( reply[j] >= '0' && reply[j] <= '9' )
     { d_end = j; }
     else { j--; }
  }

  /* The date field is in the format YYYY-MM-DD, which is a 10 character field */
  j=0;
  for ( k=d_end-9; k<=d_end; k++ )
  {
     pfield[j] = reply[k];
     j++; 
  }
  pfield[j] = '\0';

  strcpy(ddate, pfield);

  /* Make sure that the dashes are date, in case we have dropped characters */
  if ( ( ddate[4] != '-' ) || ( ddate[7] != '-' ) )
    as_exit("get_as_datetime", "! PFP date error \n");

  j=0;
  pch = strtok (ddate,"-");
  while (pch != NULL)
  {
    if ( j==0 )
       p_pfp->tm_year = atoi(pch) - 1900;
    if ( j==1 )
       p_pfp->tm_mon = atoi(pch) - 1;
    if ( j==2 )
       p_pfp->tm_mday = atoi(pch);
    /* printf ("%s\n",pch); */
    pch = strtok (NULL, "-");
    j++;
  }

  /* printf ( "%d\n", p_utc->tm_mday); */

  pfp_time = mktime(p_pfp);
  /* printf("%d\n", pfp_time); */

  diff = difftime(pfp_time, utc_time);

  sprintf( out_str, " ~ sys minus pfp:%d", diff );

  strcpy(vtime, out_str);

  return 1;
}

/***************************************************************/
char *get_as_samplemode( as_eid, savefile )
  int as_eid;
  FILE *savefile;
{
  char buffy[as_buffsize];
  char *p_buffy;
  char out_s[maxline];
  char *p_out;
  char *p_end;
  clock_t whenever;
  int nchars;
  char *smode;

  sleep( as_latency );			/* Cleanout anything left in serial buffer first. */
  while (read( as_eid, buffy, 1 ) > 0 );

  send_as_msg( as_eid, list_command );

/* First, 'fast buffer' all of the reply in, to avoid character 
 * loss when dealing with the serial driver on a line-by-line
 * or character-by-character basis. Depend on latency timeout to 
 * let us know when we're done. 
 */

  p_buffy = buffy;
  whenever = clock();
  while (clock() < (whenever + (as_latency * CLOCKS_PER_SEC)))
    if ((nchars = read( as_eid, p_buffy, maxline )) > 0)
    {
      p_buffy += nchars;
      whenever = clock();
    }

/* Now parse the buffer into lines, and write the lines out to file. 
 * Throw away the first line and the remnants of the
 * last line as being prompt leftovers. 
 */

    p_end = p_buffy;
    p_buffy = buffy;

    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove first line. */
    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove second line. */
    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove third line. */
    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove fourth line. */
    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove fifth line. */
    while (*p_buffy++ != '\n' && p_buffy < p_end);	/* Remove six line. */

    p_out = out_s;
    /* Get 3 lines */
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));
    *p_out = '\0';			/* Terminate string. */

    smode = "";                         /* Set a default return */
    if (p_buffy != p_end)		/* Make sure we are not pass the end */
    {
       /* Match on substrings, setting to smode to the one that matches */
       if ( strstr( out_s, "semi auto" ) )
          smode = " ~ sampling mode:semi";
       if ( strstr( out_s, "full auto" ) )
          smode = " ~ sampling mode:full";
    }

    // fprintf ( savefile, out_s );

    return(smode);
}

/***************************************************************/
void read_history( as_eid, savefile, section_title, command_prompt )
  int as_eid;
  FILE *savefile;
  char *section_title;
  char *command_prompt;
{
  char buffy[as_buffsize];
  char *p_buffy;
  char out_s[maxline];
  char *p_out;
  char *p_end;
  clock_t whenever;
  int nchars;

  sleep( as_latency );			/* Cleanout anything left in serial buffer first. */
  while (read( as_eid, buffy, 1 ) > 0 );

  fprintf( savefile, "%s\n", section_title );

  send_as_msg( as_eid, command_prompt );

/* First, 'fast buffer' all of the reply in, to avoid character 
 * loss when dealing with the serial driver on a line-by-line
 * or character-by-character basis. Depend on latency timeout to 
 * let us know when we're done. 
 */

  p_buffy = buffy;
  whenever = clock();
  while (clock() < (whenever + (as_latency * CLOCKS_PER_SEC)))
    if ((nchars = read( as_eid, p_buffy, maxline )) > 0)
    {
      p_buffy += nchars;
      whenever = clock();
    }

/* Now parse the buffer into lines, and write the lines out to file. 
 * Throw away the first line and the remnants of the
 * last line as being prompt leftovers. 
 */

    p_end = p_buffy;
    p_buffy = buffy;

    while (*p_buffy++ != '\n');		/* Remove first line. */

    while (p_buffy != p_end)
    {
      p_out = out_s;

      while ((p_buffy != p_end) && ((*p_out++ = *p_buffy++) != '\n'));

      *p_out = '\0';			/* Terminate string. */

      if (p_buffy != p_end)		/* Remove last line. */
        fprintf( savefile, out_s );
    }

  fprintf( savefile, "\n\n" );
}


/***************************************************************/
main( argc, argv )
 int argc; 
 char *argv[];
{
  FILE *savefile;
  int as_eid;
  char reply_s[maxline];
  struct tm *p_utc;
  time_t now;

  char *smode;
  char ptime[25];
  char as_press[25];
  char *history_str;
  char *history_title;
  
  char save_filename[maxline];

  verbose = 0;		/* Set/turn off serial communication display. */

  /*
  Pass serial port device driver
  November 8, 2004 - kam
  */
  strcpy(serialport, argv[1]);

/* Create filepath and name based on date and time, 
 * just like any other rawfile. */
  
/* !!! Modified to go to stdout instead.  
 * Let the calling shell determine the filename. 
 */

/*
  now = time( NULL );
  if ((p_utc = gmtime( &now )) == NULL)
    as_exit( argv[0], "! Couldn't get system UTC time \n" );
  p_utc->tm_year += 1900;
  p_utc->tm_mon += 1;
  sprintf( save_filename, "%s/%04d/%04d%02d%02d%02d.his", 
	   save_filepath, p_utc->tm_year, p_utc->tm_year, p_utc->tm_mon, p_utc->tm_mday, p_utc->tm_hour );

  if ((savefile = fopen( save_filename, "w" )) == NULL)
    as_exit( argv[0], "! Couldn't open history save file named %s \n", save_filename );
*/
  
  savefile = stdout;

  as_eid = open_as_comm();

  /* Goto the LIMITS menu and get the sampling mode */ 
  goto_limits_mode ( as_eid );
  smode = get_as_samplemode ( as_eid, savefile );

  history_str = "Site History";

  history_title = (char *)calloc(strlen(smode) + strlen(history_str) + 6, sizeof(char));

  strcpy(history_title, history_str);
  strcat(history_title, smode);
  //fprintf( savefile, history_title);

  get_all_pressure( as_eid, savefile, as_press );

  /* printf( "%s\n", as_press ); */

  history_str = history_title;

  history_title = (char *)calloc(strlen(as_press) + strlen(history_str) + 6, sizeof(char));

  strcpy(history_title, history_str);
  strcat(history_title, as_press);

  if ( get_as_datetime ( as_eid, savefile, ptime ) )
  {
    /* printf ( "%s\n", ptime ); */

    history_str = history_title;

    history_title = (char *)calloc(strlen(ptime) + strlen(history_str) + 6, sizeof(char));

    strcpy(history_title, history_str);
    strcat(history_title, ptime);
  }

  goto_AS_mode( as_eid );
  send_as_msg( as_eid, history_command );
  get_as_msg( as_eid, reply_s );
  if (match_as_prompt( history_prompt, reply_s ) != is_ok)
    as_exit( argv[0], "! Couldn't get AS controller into History mode \n" );

  read_history( as_eid, savefile, history_title, site_command );
  read_history( as_eid, savefile, "Serial Number History", serial_command );  
  read_history( as_eid, savefile, "Altitude History", altitude_command );
  read_history( as_eid, savefile, "Location History", location_command );
  read_history( as_eid, savefile, "Fill History", fill_command );
  read_history( as_eid, savefile, "Error History", err_command );
  read_history( as_eid, savefile, "Ambient Conditions", conditions_command );
/*
   add to return to main menu
   to correct checksum errors?
   October 22, 2004 - mph,kam
*/
  goto_AS_mode( as_eid );

  close( as_eid );
/*  fclose( savefile ); */
}
