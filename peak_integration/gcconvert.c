#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <malloc.h>

#include "gc.h"

/**********************************************************/
int main(int argc, char *argv[])
{
	FILE 	*fp;
	int	i, filetype, n, nameonly, start;
	chromatogram run;
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
printf ("file type is %d\n", filetype);
		
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

	name = gc_SetFileNameFromRun(run, GC_FILE);
	if (nameonly) {
		printf ("%s\n", name);
	} else {
		fp = fopen (name, "w");
		if (fp == NULL) {
			fprintf (stderr, "Can't open output file %s.\n", name);
			exit(1);
		}
		gc_WriteFile(fp, &run);
	}
	
	exit(0);
}
