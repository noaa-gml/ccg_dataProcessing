#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "gc.h"

void ProcessFile (char *filename);
void process_file (FILE *fp, int filetype);
void gc_PrintData (gcPeaks *p, chromatogram run, int channel);

int 	channel;
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

	fprintf (stderr, "If timefile is not specified,  an attempt is made to find\n");
	fprintf (stderr, "the correct timefile based on the sample date of the \n");
	fprintf (stderr, "chromatogram.  This timefile must use a date naming\n");
	fprintf (stderr, "convention (e.g. 199403051530.x.tf).  If no timefile is\n");
	fprintf (stderr, "found, default values are used for integration.\n\n");
	fprintf (stderr, "If idfile is not specified, an attempt is made to find\n");
	fprintf (stderr, "the correct peakid file based on the sample date of the\n");
	fprintf (stderr, "chromatogram.  This idfile must use a data naming \n");
	fprintf (stderr, "convention (e.g. 199403051530.id).  If no idfile is \n");
	fprintf (stderr, "found, 'NA' is used (Not Available) for the peak name.\n\n");

	fprintf (stderr, "For either the timefile of peakid file to be found\n");
	fprintf (stderr, "automatically, the environment variable GCDATADIR must\n");
	fprintf (stderr, "be set, or the -d option must be specified.\n\n");

	fprintf (stderr, "If the data directory is specified, then when the program\n");
	fprintf (stderr, "looks for the timefile and idfile, the directories \n");
	fprintf (stderr, "'datadir/integration' and datadir/peakid' are searched\n");
	fprintf (stderr, "for the timefile and idfile respectively. This overrides the\n");
	fprintf (stderr, "directory specified by GCDATADIR, if any.  If the -t and\n");
	fprintf (stderr, "-i options are both used, -d has no effect.\n\n");

	fprintf (stderr, "If channel is not specified, all channels are used.\n\n");
}

/**********************************************************/
int main(int argc, char *argv[])
{
	FILE 	*fp;
	int	c, filenum;
	char	*name, filename[512];
	char 	*datadir=NULL;
	char 	*filelist = NULL;
	extern char *optarg;
	extern int optind;

/*
 * Get command line options 
 */

	while ((c=getopt(argc, argv, "c:t:i:d:m:f:l:")) != EOF) {
		switch (c) {
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
		case 'l':
			filelist = strdup(optarg);
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
 * Check if file names were specified.
 */

/*
	if (optind >= argc) {
		fprintf (stderr, "No files specified.\n");
		printusage(argv[0]);
		exit (1);
	}
*/

/*
 * Loop through all file names, read data from file,
 * integrate and print out result string.
 */

	if (datadir) gc_SetDataDir(datadir);

	if (filelist) {
		fp = fopen (filelist, "r");
		if (fp==NULL) {
			fprintf (stderr, "Can't open list file %s.\n", filelist);
		} else {
			while (fgets (filename, 200, fp) != NULL) {
				filename[strlen(filename)-1] = '\0';
				ProcessFile (filename);
			}
			fclose(fp);
		}
	}

	for (filenum=optind; filenum < argc; filenum++) {
		name = argv[filenum];
		ProcessFile (name);
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
			gc_PrintData(p, run, i);
		}
		gc_Free(p);
	}
}


/*****************************************************************/
void ProcessFile (char *filename)
{
	FILE *fp;
	int r;
	int filetype;
	char *name;

	filetype = gc_FileType(filename);

	if (filetype == UNKNOWN_FILE) {
		fprintf (stderr, "Unknown file type for %s.\n", filename);
		return;
	}

	
	if (filetype == ARCHIVE_FILE) {
		fp = gc_OpenArchive (filename);
		if (fp == NULL) {
			fprintf (stderr, "Can't open archive %s.\n", filename);
			return;
		}

		r=0;
		while (r >= 0) {
			process_file (fp, GC_FILE);
			r = gc_NextArchiveFile(fp);
		}
		fclose(fp);
	} else {
		fp = fopen (filename, "r");
		if (fp == NULL) {
			name = gc_ArchiveName (filename);
			if (name == NULL) {
				fprintf (stderr, "Can't open file %s.\n", filename);
				return;
			} else {
				fp = gc_OpenFile(name, filename);
				if (fp == NULL) {
					fprintf (stderr, "Can't open file %s.\n", filename);
					return;
				}
                        }
		}
		process_file(fp, filetype);
		fclose(fp);
	}
}
/**********************************************************/
void gc_PrintData (gcPeaks *p, chromatogram run, int channel)
{
	static char *format = "%4d %02d %02d %02d %02d %2d %d %10s %10.6e %10.6e %6.1f %4s";
	char	*name;
	float	ret_time;
	int	i;


	for (i=0; i<p->npeaks; i++) {
		ret_time = (p->peaks[i].xcrest/p->sample_rate);

		if (strcmp(p->peaks[i].name, "") == 0) 
			name = "NA";
		else
			name = p->peaks[i].name;

if (run.port < 0) run.port = 0;
		printf (format, 
				run.year, 
				run.month, 
				run.day, 
				run.hour, 
				run.minute, 
				run.port, 
				channel,
				name, 
				p->peaks[i].height, 
				p->peaks[i].area, 
				ret_time,
				p->peaks[i].bcode);

		printf ("\n");
	}
}
