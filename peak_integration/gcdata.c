#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "gc.h"

void ProcessFile (char *filename);
void process_file (FILE *fp, int filetype);
void gc_PrintData (gcPeaks *p, chromatogram run, int channel);
void gc_Stats (gcPeaks *p, chromatogram run, int channel);

int 	channel;
int 	results = 0;
int 	full_listing = 0;
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

	while ((c=getopt(argc, argv, "frc:t:i:d:m:f:l:")) != EOF) {
		switch (c) {
		case 'f':
			full_listing = 1;
			break;
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
printf ("xxxxxxxxxxxxxxx\n");
		p = gc_integrate (run.data[i], run.npoints, run.sample_rate, timefile);
printf ("$$$xxxxxxxxxxxxxxx\n");
printf ("npeaks is %d\n", p->npeaks);
		if (p->npeaks>0) {
printf ("xxxxxxxxxxxxxxx\n");
			gc_id (p, idfile, i);
printf ("xxxxxxxxxxxxxxx\n");
			if (results) {
				gc_Stats (p, run, i);
			} else {
				gc_PrintData(p, run, i);
			}
		}
printf ("==================\n");
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
printf ("opened archive\n");
		if (fp == NULL) {
			fprintf (stderr, "Can't open archive %s.\n", filename);
			return;
		}

		r=0;
		while (r >= 0) {
			process_file (fp, TEXT_FILE);
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
	static char *format2= "% 8.3f %10ld %8.3f %10ld %4.1f";
	char	*name;
	float	ret_time;
	int	i;
	long ys, ye;
	float peak_width, t1, t2, xs, xe;


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

		if (full_listing) {
			xs = p->peaks[i].xstart/p->sample_rate;
			xe = p->peaks[i].xend/p->sample_rate;
			ys = gc_getBaseline(p, i, xs);
			ye = gc_getBaseline(p, i, xe);
			t1 = p->peaks[i].xhalfheight_up/p->sample_rate;
                        t2 = p->peaks[i].xhalfheight_down/p->sample_rate;
			peak_width = t2 - t1;
			printf (format2, 
				xs,
				ys,
				xe,
				ye,
				peak_width);
		}

		printf ("\n");
	}
}


/****************************************************************/
void gc_Stats(gcPeaks *peaks, chromatogram run, int channel)
{
	int i;
	int valve, port;
	int bcs, bce;
	float t1, t2;

	if (peaks->npeaks == 0) {
		return;
	}


	port = (run.port >= 10) ? run.port/10 : run.port;
	valve = (run.port >= 10) ? run.port%10 : 0;
	
	printf ( "*****  Chromatogram Data.  *****\n\n");
	printf ( "Channel Number:              %d\n",channel);
	printf ( "Port Number:                 %d\n", port);
	printf ( "Valve Number:                %d\n", valve);
	printf ( "Sampling Rate (Hz):          %.1f\n", run.sample_rate);
	printf ( "Number of Data Points:       %d\n\n", run.npoints);
	printf ( "Number of Peaks:             %d\n\n",peaks->npeaks);
/*	printf ( "Data File:       %s\n",datafile); */
	printf ( "Time File:       %s\n",timefile);
	printf ( "Peak ID File:    %s\n\n",idfile);
	for (i=0; i<peaks->npeaks; i++) {
		printf ( "------------------------------------------\n");
		if (strcmp (peaks->peaks[i].name, "") == 0) 
			printf ( "Peak Number %d:  Unknown\n\n", i);
		else
			printf ( "Peak Number %d:  %s\n\n", i, peaks->peaks[i].name);
		printf ( "     Peak area:                 %.2f\n",peaks->peaks[i].area);
		printf ( "     Peak Height:               %.2f\n",peaks->peaks[i].height);
		printf ( "     Start:                     %.2f seconds\n",peaks->peaks[i].xstart/peaks->sample_rate);
		printf ( "     End:                       %.2f seconds\n",peaks->peaks[i].xend/peaks->sample_rate);
		printf ( "     Crest:                     %.2f seconds\n",peaks->peaks[i].xcrest/peaks->sample_rate);
		t1 = peaks->peaks[i].xhalfheight_up/peaks->sample_rate;
		t2 = peaks->peaks[i].xhalfheight_down/peaks->sample_rate;
		printf ( "     Peak Width:                %.2f seconds\n",t2-t1);
		printf ( "     Start Level:               %ld\n",peaks->peaks[i].start_level);
		printf ( "     End Level:                 %ld\n",peaks->peaks[i].end_level);
		printf ( "\n");
		bcs = peaks->peaks[i].bc_start;
		bce = peaks->peaks[i].bc_end;
		printf ( "  Baseline codes:     Start    End\n"); 
		printf ( "     Resolved           %d       %d\n", 
			(bcs & RESOLVED) ? 1 : 0, (bce & RESOLVED) ? 1 : 0);
		printf ( "     Tangent            %d       %d\n", 
			(bcs & TANGENT) ? 1 : 0, (bce & TANGENT) ? 1 : 0);
		printf ( "     Forced             %d       %d\n",
			(bcs & FUSED) ? 1 : 0, (bce & FUSED) ? 1 : 0);
		printf ( "     Fused              %d       %d\n",
			(bcs & FUSED) ? 1 : 0, (bce & FUSED) ? 1 : 0);
		printf ( "     Penetrated         %d       %d\n",
			(bcs & PENETRATED) ? 1 : 0, (bce & PENETRATED) ? 1 : 0);
		printf ( "     Shoulder           %d       %d\n",
			(bcs & SHOULDER_POINT) ? 1 : 0, (bce & SHOULDER_POINT) ? 1 : 0);
		printf ( "     Rider              %d       %d\n",
			(bcs & RIDER) ? 1 : 0, (bce & RIDER) ? 1 : 0);
		printf ( "     Mouse              %d       %d\n",
			(bcs & MOUSE) ? 1 : 0, (bce & MOUSE) ? 1 : 0);
		printf ( "\n");
	}

}
