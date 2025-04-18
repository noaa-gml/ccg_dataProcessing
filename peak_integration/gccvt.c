#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <malloc.h>

#include "gc.h"

/**********************************************************/
main(argc, argv)
int argc;
char *argv[];

{
	FILE 	*fp;
	int	i, j, filetype, n, nameonly=0, start;
	chromatogram run;
	struct tm *tm;
	char *name;


	start = 1;
	for (i = 1; i < argc; i++) {
		if (strcmp (argv[i], "-f") == 0) {
			nameonly = 1;
			start++;
		}
	}

	if (start >= argc ) {
		fprintf (stderr, "Wrong number of arguements.\n");
		fprintf (stderr, "Usage: %s [-f] file\n",argv[0]);
		exit(1);
	}
 
	name = argv[start];

	fp = fopen (name, "r");
	if (fp == NULL) {
		fprintf (stderr, "Can't open file %s.\n", name);
		exit(1);
	}

	filetype = gc_FileType(name);
		
	n = gc_ReadFile(fp, &run, filetype);
	if (n != 0) {
		fprintf (stderr, "Error reading %s.\n", name);
		exit(1);
	}

	fclose(fp);

/* Open the gc file.  Name is from the start time of chromatogram.
 * Assumes the environmental variable GCDATADIR is set to the
 * directory wanted.  If not, directory is the current one. 
*/

	name = gc_SetFileNameFromRun(run, TEXT_FILE);
	if (nameonly) {
		printf ("%s\n", name);
	} else {
		fp = fopen (name, "w");
		if (fp == NULL) {
			fprintf (stderr, "Can't open output file %s.\n", name);
			exit(1);
		}
                fprintf (fp, "%d %d %d %d %d %d %d\n", run.year,
                                                   run.month,
                                                   run.day,
                                                   run.hour,
                                                   run.minute,
                                                   run.second,
                                                   0);
                fprintf (fp, "%d\n", run.port);
                fprintf (fp, "%f\n", run.sample_rate);
                fprintf (fp, " 1 %d\n", run.npoints);
                for (i=0; i<run.npoints; i++) fprintf (fp, "%ld\n", run.data[0][i]);
                fclose (fp);
	}
	
	exit(0);
}
