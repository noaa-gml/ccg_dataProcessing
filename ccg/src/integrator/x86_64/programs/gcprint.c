#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <malloc.h>

#include "gc.h"

/*********************************************************/
void printusage(char *s)
{
	fprintf (stderr, "Usage: %s [-t timefile] [-a archive] [-i idfile]\n", s);
	fprintf (stderr, "          [-c channel] [-d directory]\n");
	fprintf (stderr, "          file\n");
	fprintf (stderr, "-t: Time file for integration instructions.\n");
	fprintf (stderr, "-i: Peak id file for naming peaks.\n");
	fprintf (stderr, "-d: Specify data directory.\n");
	fprintf (stderr, "-c: Channel number.\n");
	fprintf (stderr, "-a: Archive name.\n");

}

/**********************************************************/
int main(int argc, char **argv)
{
	FILE 	*fp;
	int	i, filetype, n, c;
	chromatogram run;
	char	*datestr, *datadir=NULL;
	int channel = 0;
	char *idfile = NULL, *timefile = NULL;
	gcPeaks *p;
	char *name, *archive = NULL;
	float x, y1;
	long y, y2, y3, y4;
	int findidfile = 1, findtimefile=1;

        extern char *optarg;
        extern int optind;

/* Parse argument options */

	while ((c=getopt(argc, argv, "a:c:t:i:d:")) != EOF) {
		switch (c) {
		case 'a':
			archive = strdup(optarg);
			break;
		case 'd':
			datadir = strdup(optarg);
			break;
		case 'c':
			sscanf (optarg, "%d", &channel);
			break;
		case 'i':
			idfile = strdup(optarg);
			findidfile = 0;
			break;
		case 't':
			timefile = strdup(optarg);
			findtimefile = 0;
			break;
		case '?':
		default:
			fprintf (stderr, "Bad option.\n");
			printusage (argv[0]);
			exit(1);
			break;
		}
	}

        if (optind >= argc) {
                fprintf (stderr, "%s: No input files specified.\n", argv[0]);
                exit(1);
        } 
	name = argv[optind];

/* ----------------------------------- */

	if (archive != NULL) {
		fp = gc_OpenFile(archive, name);
		if (fp == NULL) {
			fprintf (stderr, "Can not find file %s in archive %s.", name, archive);
			exit(1);
		} 
	} else {
		fp = fopen (name, "r");
		if (fp == NULL) {
			fprintf (stderr, "Can't open file %s.\n", name);
			exit(1);
		}
	}

	filetype = gc_FileType(name);
		
	n = gc_ReadFile(fp, &run, filetype);
	if (n != 0) {
		fprintf (stderr, "Error reading %s.\n", name);
		exit(1);
	}

	fclose(fp);

	if (datadir) gc_SetDataDir(datadir);
	datestr = gc_SetDateStringFromRun(run);
	if (findidfile ) idfile = gc_GetPeakIDFile (datestr);
	if (findtimefile) timefile = gc_GetTimeFile (datestr, channel);
	p = gc_integrate (run.data[channel], run.npoints, run.sample_rate, timefile);
	for (i=0; i<run.npoints; i++) {
		x  = (float) i/p->sample_rate;	/* convert x to time */
		y  = run.data[channel][i]; /* raw data */
/*
		y1 = p->slope[i];
		y2 = p->detrend[i];
		y3 = p->smooth[i];
		y4 = p->bfit[i];

		printf ("%10.3f %10ld %12.4f %10ld %10ld %10ld\n", x, y, y1, y2, y3, y4);
*/
		printf ("%10.3f %10ld\n", x, y);
	}

	exit(0);
}
