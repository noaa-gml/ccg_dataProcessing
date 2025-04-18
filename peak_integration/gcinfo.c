#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "gc.h"

#define NEXT 1

void print_analysis_date(chromatogram run);
void print_file_name(chromatogram run, int filetype);
void print_table_header(void);
void print_run_table(chromatogram run);
void print_run( chromatogram run);
void process_file (chromatogram run, int filetype);
void ProcessFile (char *filename, int filetype);

int	print_filename = 0, print_adate = 0, print_table = 0;

/*********************************************************/
void printusage(s)
char *s;
{
	fprintf (stderr, "Usage: %s [-d | -f | -t ] [ -l file ]\n", s);
	fprintf (stderr, "          file1 file2 ...\n");
	fprintf (stderr, "-d: Print analysis date for each specified file.\n");
	fprintf (stderr, "-f: Print filename generated from sample date and time.\n");
	fprintf (stderr, "-t: Print table of various parameters.\n");
	fprintf (stderr, "-l: Specify file with list of files to read.\n");
}

/**********************************************************/
int main(int argc, char *argv[])
{
	FILE 	*fp;
	int	c, filenum, filetype;
	char	*name, filename[512];
	char 	*filelist = NULL;
	extern char *optarg;
	extern int optind;

/*
 * Get command line options 
 */

	while ((c=getopt(argc, argv, "dftl:")) != EOF) {
		switch (c) {
		case 'd':
			print_adate = 1;
			break;
		case 'f':
			print_filename = 1;
			break;
		case 't':
			print_table = 1;
			print_table_header();
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


	if (filelist) {
		fp = fopen (filelist, "r");
		if (fp==NULL) {
			fprintf (stderr, "Can't open list file %s.\n", filelist);
		} else {
			while (fgets (filename, 200, fp) != NULL) {
				filename[strlen(filename)-1] = '\0';
				filetype = gc_FileType(filename);
				ProcessFile (filename, filetype);
			}
			fclose(fp);
		}
	}

	for (filenum=optind; filenum < argc; filenum++) {
		name = argv[filenum];
		filetype = gc_FileType(name);
		ProcessFile (name, filetype);
	}

	exit (0);
}


/*****************************************************************/
void ProcessFile (char *filename, int filetype)
{
	FILE *fp;
	int type, n;
	char *datestr, *name;
	chromatogram run;


	if (filetype == UNKNOWN_FILE) {
		fprintf (stderr, "Unknown file type for %s.\n", filename);
		return;
	}

	
	if (filetype == ARCHIVE_FILE) {
/*
		fp = gc_OpenArchive (filename);
		if (fp == NULL) return;

		r=0;
		while (r >= 0) {
			process_file (fp, filetype);
			r = gc_NextArchiveFile(fp);
		}
*/
		datestr="000000000000";
		while ((name = gc_SearchArchive(filename, datestr, NEXT)) != NULL) {
			fp = gc_OpenFile (filename, name);
			type = gc_FileType (name);
			n = gc_ReadFile(fp, &run, type);
			if (n != 0) {
				fprintf (stderr, "Error reading file.\n");
				return;
			}
			process_file(run, type);
			datestr = gc_SetDateStringFromRun(run);
			fclose(fp);
		}
			
	} else {
		fp = fopen (filename, "r");
		if (fp != NULL) {
			n = gc_ReadFile(fp, &run, filetype);
			if (n != 0) {
				fprintf (stderr, "Error reading file.\n");
				return;
			}
			process_file(run, filetype);
			fclose(fp);
		}
	}
}

/*****************************************************************/
void process_file (chromatogram run, int filetype)
{
	if (print_table) {
		print_run_table (run);
	} else if (print_filename) {
		print_file_name(run, filetype);
	} else if (print_adate) {
		print_analysis_date(run);
	} else {
		print_run(run);
	}
}

/************************************************************************/
void print_run( chromatogram run)
{
	printf ("Year:               %d\n", run.year);
	printf ("Month:              %d\n", run.month);
	printf ("Day:                %d\n", run.day);
	printf ("Hour:               %d\n", run.hour);
	printf ("Minute:             %d\n", run.minute);
	printf ("Second :            %d\n", run.second);
	printf ("GMT:                %d\n", run.is_gmt);
	printf ("# Points:           %d\n", run.npoints);
	printf ("# Channels:         %d\n", run.nchannels);
	printf ("Samples per second: %g\n", run.sample_rate);
        printf ("Port:               %d\n", run.port);
}


/************************************************************************/
void print_run_table(chromatogram run)
{
	
	printf ("%7d", run.year);
	printf ("%3d", run.month);
	printf ("%3d", run.day);
	printf ("%5d", run.hour);
	printf ("%3d", run.minute);
	printf ("%3d", run.second);
	printf ("%3d", run.is_gmt);
	printf ("%10d", run.npoints);
	printf ("%8d", run.nchannels);
	printf ("%9.1f", run.sample_rate);
        printf ("%4d", run.port);
	printf ("\n");
}

/************************************************************************/
void print_table_header(void)
{
	printf ("      Date");
	printf ("        Time");
	printf ("   GMT");
	printf ("   # points");
	printf ("   # Chan.");
	printf ("  Hz ");
	printf (" Port ");
	printf ("\n");
}
/************************************************************************/
void print_file_name(chromatogram run, int filetype)
{
	char *name;
	
	name = gc_SetFileNameFromRun(run, filetype);
	printf ("%s\n", name);
}
/************************************************************************/
void print_analysis_date(chromatogram run)
{
	printf ("%4d %02d %02d %02d %02d\n", run.year, run.month, run.day, run.hour, run.minute);
}
