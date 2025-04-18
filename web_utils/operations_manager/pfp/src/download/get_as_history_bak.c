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

  goto_AS_mode( as_eid );
  send_as_msg( as_eid, history_command );
  get_as_msg( as_eid, reply_s );
  if (match_as_prompt( history_prompt, reply_s ) != is_ok)
    as_exit( argv[0], "! Couldn't get AS controller into History mode \n" );

  read_history( as_eid, savefile, "Site History", site_command );
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
