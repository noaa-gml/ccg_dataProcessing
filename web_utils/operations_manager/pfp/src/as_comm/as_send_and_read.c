#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <signal.h>
#include <errno.h>
#include <ctype.h>
#include <string.h>

#include "as_comm.h"

int main(argc, argv)
int argc;
char *argv[];
{
   int fd = 0;
   int wait = 1;
   int status;

   char device[100];
   char command[30] = "\r\r";

   if ( argc == 1 )
   { end_prog ("as_send_and_read", "No arguments provided.\n"); }
   if ( argc == 2 )
   {
      strcpy(device, argv[1]);
      // Send two carriage returns so we will definitely get a prompt
      strcpy(command, "\r\r");
   }
   else if ( argc == 3 )
   {
      strcpy(device, argv[1]);

      wait = atoi(argv[2]);

      strcpy(command, "\r\r");
   }
   else if ( argc == 4 )
   {
      strcpy(device, argv[1]);

      wait = atoi(argv[2]);

      strcpy(command, argv[3]);
      strcat(command, "\r");
   }
   else
   { end_prog ("as_send_and_read", "Too many arguments provided.\n"); }

   //printf("DEVICE: %s\n", device);
   //printf("COMMAND: %s\n", command);
   //printf("MDELAY: %d\n", wait);

   fd = open_serial(&device, 9600, 0);

   status = Device_send(fd, &command);

   Device_print_data(fd, wait);

   exit (0);
}
