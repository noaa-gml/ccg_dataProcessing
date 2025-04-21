#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "gc.h"

void process_file (FILE *fp, int filetype);
void gc_Stats (gcPeaks *p, chromatogram run, int channel);
void gc_data (gcPeaks *p, chromatogram run, int channel);

int 	channel;
int 	results = 0;
int	findtimefile = 1, findidfile = 1, all_channels = 1;
char	*timefile=NULL, *idfile=NULL;

/*********************************************************/
void printusage(char *s)
{
	fprintf (stderr, "Usage: %s [-t timefile] [-i idfile]\n", s);
	fprintf (stderr, "          [-c channel] [-d directory]\n");
	fprintf (stderr, "          file1 file2 ...\n");
	fprintf (stderr, "-t: Time file for integration instructions.\n");
	fprintf (stderr, "-i: Peak id file for naming peaks.\n");
	fprintf (stderr, "-d: Specify data directory.\n");
	fprintf (stderr, "-c: Channel number.\n");
}

/**********************************************************/
int main(int argc, char *argv[])
{
	FILE 	*fp;
	int	c, filenum, filetype;
	char	*filename;
	char 	*datadir=NULL;
	extern char *optarg;
	extern int optind;

/*
 * Get command line options 
 */

	while ((c=getopt(argc, argv, "rc:t:i:d:")) != EOF) {
		switch (c) {
		case 'r':
			results = 1;
			break;
		case 'd':
			datadir = strdup(optarg);
			break;
		case 'c':
			sscanf (optarg, "%d", &channel);
			all_channels = 0;
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

/*
 * Loop through all file names, read data from file,
 * integrate and print out result string.
 */

	if (datadir) gc_SetDataDir(datadir);

	for (filenum=optind; filenum < argc; filenum++) {
		filename = argv[filenum];
		filetype = gc_FileType(filename);
filetype = TEXT_FILE;

		if (filetype == UNKNOWN_FILE) {
			fprintf (stderr, "Unknown file type for %s.\n", filename);
		} else {
			fp = fopen (filename, "r");
			if (fp == NULL) {
				fprintf (stderr, "Cannot open file %s.\n", filename);
			} else {
				process_file(fp, filetype);
				fclose(fp);
			}
		}
	}

	exit(0);

}

/*****************************************************************/
void process_file (FILE *fp, int filetype)
{
	int	i, cs, ce;
	int	n;
	char	*datestr;
	chromatogram run;
	gcPeaks *p;


	n = gc_ReadFile(fp, &run, filetype);
	if (n != 0) {
		fprintf (stderr, "Error reading file.\n");
		return;
	}
	
	datestr = gc_SetDateStringFromRun(run);
	if (findidfile ) idfile = gc_GetPeakIDFile (datestr);
		

	if (all_channels) {
		cs = 0;
		ce = run.nchannels;
	} else if (channel < run.nchannels) {
		cs = channel;
		ce = channel+1;
	} else
		return;

	for (i=cs; i<ce; i++) {
		if (findtimefile) timefile = gc_GetTimeFile (datestr, i);
		p = gc_integrate (run.data[i], run.npoints, run.sample_rate, timefile);
		if (p->npeaks>0) {
			gc_id (p, idfile, i);
		}
		if (results) {
			gc_Stats (p, run, i);
		} else {
			gc_data(p, run, i);
		}

		gc_Free(p);
	}
}


/**********************************************************/
void gc_data (gcPeaks *p, chromatogram run, int channel)
{
	int i;
	long v;
	float *xdata;
	int flag = (1L<<21);

	xdata = (float *) calloc (run.npoints, sizeof(float));
        for (i=0; i<run.npoints; i++) {
                xdata[i]  = (float) i/run.sample_rate;
        }


	for (i = 0; i < run.npoints; i++) {
		printf ("%6.1f ", xdata[i]);
		printf ("%9ld ", run.data[0][i]);
		printf ("%9ld ", p->smooth[i]);
		printf ("%9ld ", p->detrend[i]);
		printf ("%11.3f ", p->slope[i]);
		v = getBC(i, flag);
		printf ("%8ld ", v);
		printf ("%9ld ", p->bfit[i]);
		printf ("\n");
	}
}

/****************************************************************/
void gc_Stats(gcPeaks *peaks, chromatogram run, int channel)
{
	int i, n;
	float height, area, ret_time, start, end, t1, t2, pw;
	long start_level, end_level;
	char *code, *name, s[20];

	if (peaks->npeaks == 0) {
		return;
	}

	for (i=0; i<peaks->npeaks; i++) {

		name = peaks->peaks[i].name;
		n = strlen(name);
		if (n == 0) {
			sprintf (s, "Peak%d", i);
			name = s;
		}
		height = peaks->peaks[i].height;
		area = peaks->peaks[i].area;
                ret_time = peaks->peaks[i].xcrest/run.sample_rate;
                start = peaks->peaks[i].xstart/run.sample_rate;
                end = peaks->peaks[i].xend/run.sample_rate;
                t1 = peaks->peaks[i].xhalfheight_up/run.sample_rate;
                t2 = peaks->peaks[i].xhalfheight_down/run.sample_rate;
                pw = t2 - t1;
                start_level = peaks->peaks[i].start_level;
                end_level = peaks->peaks[i].end_level;
		code = peaks->peaks[i].bcode;

		printf ("%-10s %16.9e %16.9e %6.1f %5.1f %4s %6.1f %6.1f %10ld %10ld\n", 
			name, height, area, ret_time, pw, code, start, end, start_level, end_level);
	}

	return;

}
