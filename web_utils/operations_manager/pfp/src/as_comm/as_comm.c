#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/file.h>
#include <sys/time.h>
#include <termios.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#include "as_comm.h"

static struct    itimerval timer, otimer;

int program_failed = 0;
volatile sig_atomic_t keep_reading = 1;

/*********************************************************/
/* The read from serial device has timed out. */
void no_read()
{
//   fprintf (stderr, "Read from serial line timed out.\n");
   keep_reading = 0;
}
/*********************************************************/
void end_prog( char *name, ... )
{
   va_list p_args;
   char *fmt;

   if (errno != 0)                         /* Print system error, if any. */
      fprintf( stderr, " System err %d, %s \n", errno, strerror( errno ) );

   va_start( p_args, name);                     /* Initialize argument pointer. */
   fprintf( stderr, "%s: ", name);

   fmt = va_arg(p_args, char *);
   if (fmt != NULL)
      vfprintf( stderr, fmt, p_args ); /* Print cause of error. */

   va_end( p_args );                       /* Clean up pointer list handling. */

   exit( program_failed );                 /* Failure flags defined in analysis.h */
}
/*********************************************************/
int Device_send(fd, command)
int fd;
char *command;
{
   int n;
   char s[1024];


   sprintf (s, "%s\n", command);
   n = write (fd, s, strlen(s));

   return (0);
}

/*********************************************************/
char *Device_read_data(fd, wait)
int fd;
int wait;
{
   /*
   There are limiting factors in this function. Each answer
   can have at most the characters defined for the answer
   variable. The total data returned can have at most the
   characters defined for the data variable.
   */

   static char answer[1000];
   static char data[3000];
   int n;
   char * i;

   struct sigaction sact;

   if ( wait < 1 ) { wait = 1; }
//   printf("WAIT: %d\n", wait);

   timer.it_value.tv_sec = wait;
   timer.it_value.tv_usec = 0;
   timer.it_interval.tv_sec = 0;
   timer.it_interval.tv_usec = 0;

   answer[0] = '\0';

/* Read data forever until keep_reading is set to 0 is found. */

   keep_reading = 1;
   while (keep_reading) {
      // Explicitly set how SIGALRM is handled when thrown.
      // Must use this because signal(SIGALRM,no_read) will
      // terminate the program. 
      sigemptyset( &sact.sa_mask );
      sact.sa_flags = 0;
      sact.sa_handler = no_read;
      sigaction( SIGALRM, &sact, NULL );

      setitimer(ITIMER_REAL, &timer, &otimer);
      n = read (fd, answer, 1000);
      signal(SIGALRM, SIG_IGN);

      //printf("Read line\n");

      if ( n>0) {
         i = strchr(answer, '\n');

         answer[i-answer+1] = '\0';

         strcat(data, answer);
      } else {
         return (data);
      }

   }

   return (data);
}

/*********************************************************/
void Device_print_data(fd, wait)
int fd;
int wait;
{
   static char answer[1000];
   int n;
   char * i;

   struct sigaction sact;

   if ( wait < 1 ) { wait = 1; }
//   printf("WAIT: %d\n", wait);

   timer.it_value.tv_sec = wait;
   timer.it_value.tv_usec = 0;
   timer.it_interval.tv_sec = 0;
   timer.it_interval.tv_usec = 0;

   answer[0] = '\0';

/* Read data forever until keep_reading is set to 0 is found. */

   keep_reading = 1;
   while (keep_reading) {
      // Explicitly set how SIGALRM is handled when thrown.
      // Must use this because signal(SIGALRM,no_read) will
      // terminate the program. 
      sigemptyset( &sact.sa_mask );
      sact.sa_flags = 0;
      sact.sa_handler = no_read;
      sigaction( SIGALRM, &sact, NULL );

      setitimer(ITIMER_REAL, &timer, &otimer);
      n = read (fd, answer, 1000);
      signal(SIGALRM, SIG_IGN);

      //printf("Read line\n");

      if ( n>0) {
         i = strchr(answer, '\n');

         answer[i-answer+1] = '\0';

         printf(answer);
      }
   }
}

/*********************************************************/
void Device_clear_data(fd, wait)
int fd;
int wait;
{
   static char answer[1000];
   int n;

   struct sigaction sact;

   if ( wait < 1 ) { wait = 1; }
//   printf("WAIT: %d\n", wait);

   timer.it_value.tv_sec = wait;
   timer.it_value.tv_usec = 0;
   timer.it_interval.tv_sec = 0;
   timer.it_interval.tv_usec = 0;

   answer[0] = '\0';

/* Read data forever until keep_reading is set to 0 is found. */

   keep_reading = 1;
   while (keep_reading) {
      // Explicitly set how SIGALRM is handled when thrown.
      // Must use this because signal(SIGALRM,no_read) will
      // terminate the program. 
      sigemptyset( &sact.sa_mask );
      sact.sa_flags = 0;
      sact.sa_handler = no_read;
      sigaction( SIGALRM, &sact, NULL );

      // Read the answer but discard it. This will clear the
      // buffer.
      setitimer(ITIMER_REAL, &timer, &otimer);
      n = read (fd, answer, 1000);
      signal(SIGALRM, SIG_IGN);
   }
}

/******************************************************************/
/* Open the serial interface */

int open_serial (devfile, baud, flag)
char *devfile;
int baud, flag;
{
   int fd = 0, brate;
   struct termios tty = {IXON | IXOFF, ONLCR, CS8 | CLOCAL | CREAD, ICANON };

   switch (baud) {
   case 300: brate = B300; break;
   case 600: brate = B600; break;
   case 1200: brate = B1200; break;
   case 2400: brate = B2400; break;
   case 4800: brate = B4800; break;
   case 9600: brate = B9600; break;
   case 19200: brate = B19200; break;
   case 38400: brate = B38400; break;
   case 57600: brate = B57600; break;
   default: 
      fprintf (stderr, "Bad baud rate value %d.\n", baud);
      exit(1);
   }

   if (flag) {
      cfmakeraw( &tty );      /* make port noncanonical */
      tty.c_iflag &= ~INPCK; /* turn off input parity checking */
      tty.c_iflag &= ~IXOFF; /* turn off input start/stop control */
      tty.c_oflag &= ~ONLCR; /* turn off linefeed append */
      tty.c_cflag |= CLOCAL; /* ignore modem status lines */
      tty.c_cflag |= CREAD;  /* enable input reading */
      tty.c_cflag &= ~CSTOPB;        /* set one stop bit */
      tty.c_cflag &= ~PARENB;        /* set no parity */
      tty.c_cflag |= CS8;            /* set 8 bits per byte */
   }

   tty.c_cflag |= brate;

   errno=0;

/* get serial device file name e.g. /dev/tty09 */

   if ((fd = open (devfile, O_RDWR | O_NOCTTY,  0)) == -1) { 
      fprintf (stderr, "Can't open serial port %s.\n", devfile);
      fprintf (stderr, "%s\n", strerror(errno));
      end_prog ("open_serial", "Can't open device file %s.\n", devfile);
   }

   tcsetattr (fd, TCSANOW, &tty);

   return (fd);
}
