/* Definitions required for serial communications between host controller and AS unit controller. */

/* Revisions:

	2 Oct 1995	first revision
	04 June 2004    second revision, updated to include more prompts and commands
*/


/* Common System Includes */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
/* #include <dvio.h> */
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
#define ohyes 42
#define nope 0
#define program_failed -1
#define maxline 128

/* Globals 'n Such */

int verbose;		/* If set, sends copies of serial messages to stdout (for debugging). */
char serialport[30];
FILE *fpout;


/* I/O File Definitions */

#define as_serial_port "/dev/tty09"



/* AS Prompt Definitions -
  these strings define the prompts that control and/or are returned by the
  AS controller. They MUST match the prompts defined in the AS controller
  source code.
*/

#define as_prompt        "AS> "
#define unload_prompt    "UNLOAD> "
#define history_prompt   "HISTORY> "
#define as_open_result   "valve open"
#define as_close_result  "valve closed"
#define quit_command     "Q\r\n"
#define unload_command   "U\r\n"
#define open_command     "O\r\n"
#define close_command    "C\r\n"
#define history_command	 "H\r\n"
#define altitude_command "A\r\n"
#define location_command "L\r\n"
#define fill_command     "F\r\n"
#define err_command      "E\r\n"
#define conditions_command  "C\r\n"
#define prompt_prompt    "\r\n"
#define site_command     "S\r\n"
#define serial_command   "N\r\n"
#define list_command     "L\r\n"
#define setup_command    "S\r\n"
#define sample_command   "S\r\n"
#define add_command      "A\r\n"
#define limits_command   "L\r\n"
#define setup_prompt     "SETUP> "
#define sample_prompt    "SAMPLE PLAN> "
#define limits_prompt    "LIMITS> "
#define fix_prompt       "FIX MEMORY> "
#define add_sample        "): "
#define add_altitude      "plan altitude (ft): "
#define add_latitude      "plan latitude (degrees): "
#define add_longitude     "plan longitude (degrees): "
#define add_year          "plan year: "
#define add_month         "plan month: "
#define add_day           "plan day: "
#define add_hour          "plan hour: "
#define add_minute        "plan minute: "
#define delete_sure       "are you sure? (Y/N): "
#define delete_command    "D\r\n"
#define yes_command       "Y\r\n"
#define fix_command       "F\r\n"
#define delete_sample     "): "
#define number_command    "N\r\n"
#define date_command      "D\r\n"
#define date_entry_prompt "enter new: "
#define sitecode_command  "C\r\n"
#define code_enter_prompt "enter new site code: "
#define code_confirm      "new site code set to  "
