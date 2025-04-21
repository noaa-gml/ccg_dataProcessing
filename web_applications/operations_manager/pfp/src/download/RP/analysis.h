/* Definitions for inclusion in any C program used in the script-form
   control system for CCG analysis. */

/* Revision History

  28 Apr 92	log file name, log file line tags defined.
  18 Jun 92	open_fluke, open_file functions added.
  13 Jul 92     modified for Fluke software revision.
   2 Aug 92     changed temporary log file names
   6 Nov 92	added labels & filenames for CO2 references
  14 Nov 92     added CO2 data read/write functions
  24 Nov 92     added analysis_exit function
   3 May 94	added standard configuration file definition
*/


/* System Includes */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <dvio.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <strings.h>


/* Global Definitions */

#define is_ok  1
#define not_ok  0
#define program_success  0
#define program_failed  -1
#define string_match  0

#define maxline  132
#define label_size  10
#define date_size  15

#define max_samples  20

#define site_label_size  3
#define id_label_size    8


/* Data File Name Definitions */

#define co2_log_file  "co2.log"		/* Temporary file for CO2 measurement results. */
#define ch4_log_file  "ch4.log"		/* Temporary file for CH4 measurement results. */
#define co_log_file   "co.log"		/* Temporary file for CO measurement results. */

#define co2_ref_gas_filename  "references.co2"
#define ch4_ref_gas_filename  "references.ch4"
#define co_ref_gas_filename   "references.co"


/* Device I/O File Name Definitions */

#define control_config_filename  "control.config"


/* Global Format Definitions */

#define reference_gases_header	    "reference    cylinder    mixing ratio    port    install date "
#define reference_gas_entry_format  "%s    %s    %7.2f    %d    %s \n"

#define sample_id_header  "site    year    month    day    hour    min    flask id    method"
#define sample_id_format  "%3s %4d %02d %02d %02d %02d %8s %c"

#define analysis_id_header "flow    volume    year    day    month    hour    min"
#define analysis_id_format "  %4d %4d  %4d %02d %02d %02d %02d"



/* Global Type Definitions */

struct ref_gas_record_type
{
  char label[ label_size ];
  char cylinder[10];
  float mixing_ratio;
  int port;
  char install_date[ date_size ];
};

struct sample_id_type
{
  char site_label[ site_label_size ];
  struct tm sample_date;
  char flask_id[ id_label_size ];
  char method;
};

struct analysis_id_type
{
  int flow;
  int volume;
  struct tm analysis_date;
};





/* Standard system error exit routine, which all functions must use to
  consistantly report errors and exit cleanly (should cause analysis
  system shutdown by error trap at highest level program/script call).
  The source_id argument is a string intended to be the name of the function or
  program which is exiting. The error_msg argument may be specific to the
  error cause, and may include conversion specs with arguments following.
  If the system error flag errno is non-zero, a call to the standard
  error message printout is also made. All error messages go to stderr,
  which may be redirected from a higher level. Note this routine requires
  the inclusion of <stdarg.h>. */

void analysis_exit( source_id, error_msg )
  char *source_id;
  char *error_msg;
{
  va_list p_args;

  va_start( p_args, error_msg );          /* Initialize argument pointer. */
  fprintf( stderr, "%s: ", source_id );   /* Print location of error. */
  vfprintf( stderr, error_msg, p_args );  /* Print cause of error. */

  if (errno != 0)                       /* Print system error, if any. */
    fprintf( stderr, "  sys err %d, %s \n", errno, strerror( errno ) );

  va_end( p_args );                     /* Clean up pointer list handling. */

  exit( program_failed );               /* Failure flags defined in analysis.h */
}


/* Function to read a reference gas entry from a reference gas file. Accepts
   the file pointer to read from, and assumes the file has already been
   positioned in the area of interest. Reads lines until a line scans
   succesfully or a label tag is encountered or the end of file is found.
   Returns is_ok if succesful, and fills in the reference gas structure pointed
   to. Returns not_ok if failed. */

int read_reference_gas_entry( p_ref_file, p_record )
  FILE *p_ref_file;
  struct ref_gas_record_type *p_record;
{
  int result;
  char entry_s[ maxline ];

  result = not_ok;

  while ((fgets( entry_s, maxline, p_ref_file ) != NULL) &&
	 (result != is_ok))
  {
    if (sscanf( entry_s, reference_gas_entry_format,
		p_record->label, &(p_record->mixing_ratio),
		&(p_record->port), p_record->cylinder,
		p_record->install_date ) == 5)
      result = is_ok;
  }
  return( result );
}


/* Function to write a reference gas entry. Accepts a file pointer to write
   to and a filled in reference gas data structure. Assumes the file has
   already been positioned. Exits the hard way if the write fails. */

void write_reference_gas_entry( p_ref_file, p_record )
  FILE *p_ref_file;
  struct ref_gas_record_type *p_record;
{
  char entry_s[ maxline ];

  sprintf( entry_s, reference_gas_entry_format,
	   p_record->label, p_record->mixing_ratio, 
	   p_record->port, p_record->cylinder,
	   p_record->install_date );

  if (fputs( entry_s, p_ref_file ) == EOF)
    analysis_exit( "write_reference_gas_entry",
                   "file write failed for entry \n  '%s' \n", entry_s );
}


/* Function to create the 31 character sample id that starts most data lines. 
 Accepts as arguments a pointer to the sample_id structure containing the
 information to construct the 31 characters according to the globally defined
 format and a pointer to the destination string. If the site label string is
 a null string, then only the flask id is printed; this is for the special 
 case of reference gas entries in raw files. Usually, this function will be
 called to start creating a data line, then analysis data will be appended
 later. Note that the date and time are accepted in UNIX format, and the
 year and month are adjusted for CCG output format. */

void make_sample_id( p_sample, result_s )
  struct sample_id_type *p_sample;
  char *result_s;
{
  if (strlen( p_sample->site_label ) <= 1)
    sprintf( result_s, "%29s  ", p_sample->flask_id );
  else
    sprintf( result_s, sample_id_format, p_sample->site_label, 
	     (p_sample->sample_date.tm_year + 1900), (p_sample->sample_date.tm_mon +1),
	     p_sample->sample_date.tm_mday, p_sample->sample_date.tm_hour,
	     p_sample->sample_date.tm_min, p_sample->flask_id,
	     p_sample->method );
}


/* Function to fill in a string with analysis-related information, for
  creating raw file entries. Accepts as arguments a pointer to an
  analysis_id structure containing the analysis date, and a pointer
  to the string to write into. Usually, this function will be called
  after creating the sample id, appended to the sample id string, and
  followed by the actual raw measurement values. */

void make_analysis_id( p_analysis, result_s )
  struct analysis_id_type *p_analysis;
  char *result_s;
{
  sprintf( result_s, analysis_id_format, p_analysis->flow, p_analysis->volume,
	   (p_analysis->analysis_date.tm_year + 1900), (p_analysis->analysis_date.tm_mon +1),
	   p_analysis->analysis_date.tm_mday, p_analysis->analysis_date.tm_hour,
	   p_analysis->analysis_date.tm_min );
}
