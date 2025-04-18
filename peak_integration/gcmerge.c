/*
 * Merge two gc text files into one file with two channels
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <malloc.h>

#include "gc.h"

/**********************************************************/
int main(int argc, char **argv)
{
	FILE 	*fp1, *fp2;
	int	i, filetype, n, npoints;
	chromatogram run1, run2;
	char *name1, *name2;


	if (argc != 3 ) {
		fprintf (stderr, "Wrong number of arguments.\n");
		fprintf (stderr, "Usage: %s file1 file2\n",argv[0]);
		exit(1);
	}
 
	name1 = argv[1];
	name2 = argv[2];

	fp1 = fopen (name1, "r");
	if (fp1 == NULL) {
		fprintf (stderr, "Can't open file %s.\n", name1);
		exit(1);
	}
	fp2 = fopen (name2, "r");
	if (fp2 == NULL) {
		fprintf (stderr, "Can't open file %s.\n", name2);
		exit(1);
	}

	filetype = gc_FileType(name1);
	n = gc_ReadFile(fp1, &run1, filetype);
	if (n != 0) {
		fprintf (stderr, "Error reading %s.\n", name1);
		exit(1);
	}
	fclose(fp1);

	filetype = gc_FileType(name2);
	n = gc_ReadFile(fp2, &run2, filetype);
	if (n != 0) {
		fprintf (stderr, "Error reading %s.\n", name2);
		exit(1);
	}
	fclose(fp2);

	printf ("%d %d %d %d %d %d %d\n", run1.year,
					run1.month,
					run1.day,
					run1.hour,
					run1.minute,
					run1.second,
					run1.is_gmt);
	printf ("%d\n", run1.port);
	printf ("%f\n", run1.sample_rate);
	printf ("%2d %d\n", 2, run1.npoints);

	npoints=run1.npoints;
	if (run2.npoints < npoints) npoints = run2.npoints;

	for (i=0; i<npoints; i++) {
		printf ("%ld %ld\n", run1.data[0][i], run2.data[0][i]);
	}

	exit(0);
}
