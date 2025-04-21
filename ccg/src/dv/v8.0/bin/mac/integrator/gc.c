/*
 * gc file handling convenience routines.
 *
 * Data and related integration files are stored in a
 * directory scheme like this:
 *
 * 		 	 GCDATADIR
 *                     /     |     \ 
 *                peakid    data   integration
 *                  |        |         |
 *                files     year     files
 *                           |
 *                          files
 *
 * GCDATADIR by default is set by an environmental variable
 * of the same name.  This can be overridden by calling the
 * gc_SetDataDir routine.
 *
 * Naming conventions for files are defined by a string based on
 * the date of the data of interest; year, month, day, hour, minute:
 *
 * Peak id files 	yymmddhhmm.id
 * Integration files	yymmddhhmm.n.tf where n is channel number
 * Data files		yymmddhhmm.gc 
 * Data archive files   yymmdd.a
 *
 *
 * If you specify a data file name, then you should be able to 
 * determine the correct peakid file and integration file to use
 * based on the name.
 *
 * Routines in this file:
 *
 *	gc_SetDataDir:		Set the directory name of GCDATADIR
 *	gc_SetFileDateString:	Set the date string based on sample date
 *	gc_GetTimeFile:		Find the time file correspondig to sample date and channel
 *	gc_GetPeakIDFile:	Find the peak id file corresponding to sample date
 *	gc_OpenFile:		Open the gc data file
 *	gc_ReadFile:		Read the data file into the gc data structure
 *	gc_WriteFile:		Write the data into file
 *
 * Helper routines not usually called by user:
 *
 *	gc_file_type:	See if file name is for an archive file.
 *
 *
 * This version does not read unix archive files, only individual files.
 * This is for the transition to using zip files instead of archive files,
 * and probably using zip utilities to access the zip file instead.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/types.h>

#include "gc.h"

extern int alphasort();

static char *dirname(char *filename);

static char pattern[20];
static char *datadir = NULL;

/*
main()
{
	char *file, d1[30], *datestr;


	datestr = "93081912";
	printf ("date string = %s\n", datestr);

	sprintf (d1, "%s.0.tf", datestr);
	file = GetTimeFile (datestr, 0);
	printf ("timefile = %s\n", file);

	sprintf (d1, "%s.id", datestr);
	file = GetPeakIDFile (datestr);
	printf ("idfile = %s\n", file);

	exit(0);
}
*/

/****************************************************************/
/* Override the data directory, which is usually set by
 * the environment variable GCDATADIR.  If datadir is not NULL,
 * then the string it points to should be used.
 */

void gc_SetDataDir (char *dir)
{
	if (datadir) free(datadir);
	datadir = (strcpy(malloc(strlen(dir) + 1), dir));
}


/****************************************************************/
/* Search through directory to find timefile corresponding to
 * datestr.  Remember the list of files so we don't have to 
 * rescan the directory every time if the directory doesn't change.
 */
char *gc_GetTimeFile(char *datestr, int channel)
{
	struct dirent *dp;
	DIR *dirp;
	char *s, d2[20], dir[512], tmp_name[20];
	static char timefile[512];


	if (datadir == NULL) {
		s = getenv("GCDATADIR");
		if (s == NULL ) s = "./";
	} else {
		s = datadir;
	}
	sprintf (dir, "%s/integration", s);
	sprintf (pattern, ".%d.tf", channel);
	sprintf (d2, "%s.%d.tf", datestr, channel);

        dirp = opendir (dir);
        if ( dirp == NULL) {
                fprintf (stderr, "Error reading directory %s.\n", dir);
                perror(" ");
                return (NULL);
        }

        strcpy (tmp_name, "000000000000.0.tf");
        while ((dp = readdir (dirp)) != NULL) {
		if (strstr(dp->d_name, pattern)) {
                        if (strcmp (dp->d_name,  d2) <= 0 &&
                            strcmp (dp->d_name, tmp_name)>= 0) {
                                strcpy (tmp_name, dp->d_name);
                        }
                }
        }
	closedir(dirp);

        if (strcmp (tmp_name, "000000000000.0.tf") == 0) {
                return (NULL);
        } else {
                sprintf (timefile, "%s/%s", dir, tmp_name);
                return (timefile);
        }
}

/****************************************************************/
char *gc_GetPeakIDFile(char *datestr)
{
	struct dirent *dp;
	DIR *dirp;
	char *s, d2[20], dir[512], tmp_name[20];
	static char timefile[512];


	if (datadir == NULL) {
		s = getenv("GCDATADIR");
		if (s == NULL ) s = "./";
	} else {
		s = datadir;
	}
	sprintf (dir, "%s/peakid", s);
	sprintf (pattern, ".id");
	sprintf (d2, "%s.id", datestr);

	dirp = opendir (dir);
        if ( dirp == NULL) {
                fprintf (stderr, "Error reading directory %s.\n", dir);
                perror(" ");
                return (NULL);
        }

        strcpy (tmp_name, "000000000000.id");
        while ((dp = readdir (dirp)) != NULL) {
		if (strstr(dp->d_name, pattern)) {
                        if (strcmp (dp->d_name,  d2) <= 0 &&
                            strcmp (dp->d_name, tmp_name)>= 0) {
                                strcpy (tmp_name, dp->d_name);
                        }
                }
        }
	closedir(dirp);

        if (strcmp (tmp_name, "000000000000.id") == 0) {
                return (NULL);
        } else {
                sprintf (timefile, "%s/%s", dir, tmp_name);
                return (timefile);
        }
}


/****************************************************************/
char *gc_SetFileDateString(int year, int month, int day, int hour, int sample)
{
	static char s[15];

	sprintf (s, "%0d%02d%02d%02d%02d", year, month, day, hour, sample);
	return (s);
}

/************************************************************************/
/* OBSOLETE - Writes data in binary format.  Should only write in text
 * format now. */
int gc_WriteFile (FILE *fp, chromatogram *run)
{
	int i;

	fwrite ((char *)&run->year,        1, sizeof(short), fp);
	fwrite ((char *)&run->month,       1, sizeof(short), fp);
	fwrite ((char *)&run->day,         1, sizeof(short), fp);
	fwrite ((char *)&run->hour,        1, sizeof(short), fp);
	fwrite ((char *)&run->minute,      1, sizeof(short), fp);
	fwrite ((char *)&run->second,      1, sizeof(short), fp);
	fwrite ((char *)&run->is_gmt,      1, sizeof(short), fp);
	fwrite ((char *)&run->port,        1, sizeof(short), fp);
	fwrite ((char *)&run->sample_rate, 1, sizeof(float), fp);
	fwrite ((char *)&run->nchannels,   1, sizeof(short), fp);
	fwrite ((char *)&run->npoints,     1, sizeof(short), fp);
	for (i=0; i<run->nchannels; i++)
		fwrite((char *)run->data[i], run->npoints, sizeof(long), fp);
	

	return (1);
}

/************************************************************************/
int gc_ReadFile (FILE *fp, chromatogram *run, int filetype)
{
	char s1[40], s2[40], s3[40], s4[40], s5[40], s6[40], s7[40], s8[40], s9[40];
	long d[MAX_CHANNELS];
	int i, j, nchan, n, end=0, sec, min, hr, mn, day, yr, port, valve, gmt, npoints;
	float interval, samplerate;
	char line[200], date[15], time[10];

	switch (filetype) {
	case GC_FILE:
		fread ((char *)&run->year,        1, sizeof(short), fp);
		fread ((char *)&run->month,       1, sizeof(short), fp);
		fread ((char *)&run->day,         1, sizeof(short), fp);
		fread ((char *)&run->hour,        1, sizeof(short), fp);
		fread ((char *)&run->minute,      1, sizeof(short), fp);
		fread ((char *)&run->second,      1, sizeof(short), fp);
		fread ((char *)&run->is_gmt,      1, sizeof(short), fp);
		fread ((char *)&run->port,        1, sizeof(short), fp);
		fread ((char *)&run->sample_rate, 1, sizeof(float), fp);
		fread ((char *)&run->nchannels,   1, sizeof(short), fp);
		fread ((char *)&run->npoints,     1, sizeof(short), fp);
		for (i=0; i<run->nchannels; i++)
			fread ((char *)run->data[i], run->npoints, sizeof(long), fp);
		break;
	case TEXT_FILE:
		fscanf (fp, "%d %d %d %d %d %d %d", &yr, &mn, &day, &hr, &min, &sec, &gmt);
		run->year = yr;
		run->month = mn;
		run->day = day;
		run->hour = hr;
		run->minute = min;
		run->second = sec;
		run->is_gmt = gmt;
		fscanf (fp, "%d", &port);
		run->port = port;
		fscanf (fp, "%f", &samplerate);
		run->sample_rate = samplerate;
		fscanf (fp, "%d %d %*[\n]", &nchan, &npoints);
		run->nchannels = nchan;
		run->npoints = npoints;
		for (j=0; j<npoints; j++) {
			fgets(line, 200, fp);
			asscanf (line, d, nchan);
			for (i=0; i<nchan; i++) run->data[i][j] = d[i];
		}
		break;
	case ITX_FILE:
		fgets(line, 200, fp);
		fgets(line, 200, fp);
		n = sscanf (line, "%s %s %s %s %s %s %s %s %s", s1, s2, s3, s4, s5, s6, s7, s8, s9);
		
		nchan = n-1;

		fgets(line, 200, fp);
		sscanf (line, "%s", s1);
		if (strcmp(s1, "BEGIN") != 0) { return (-1); }

		j=0;
		do {
			fgets(line, 200, fp);
			sscanf (line, "%s", s1);
			if (strcmp(s1, "END") == 0) 
				end = 1;
			else {
				asscanf (line, d, nchan);

				for (i=0; i<nchan; i++)
					run->data[i][j] = d[i];

				j++;
			}

		} while (!end);

		fgets (line, 200, fp);
/*
 * get the time date and port number.
 * Newer files have a valve indicator field, which indicates which
 * ref. gas is used.  
 */
/*
		sscanf (line, "%*s %*s %*s \" %*s %*s %s %s %d", time, date, &port);
*/
		n = sscanf (line, "%*s %*s %*s \" %*s %*s %s %s %d; %*s %*s %*s %*s %*s %d", time, date, &port, &valve);
		if (n < 4) valve=0;
		port = port*10 + valve;

		sscanf (time, "%2d:%2d:%2d", &hr, &min, &sec);
		sscanf (date, "%2d-%2d-%d", &mn, &day, &yr);

		for (i=1; i<nchan; i++) fgets (line, 200, fp);

		fgets (line, 200, fp);
		sscanf (line, "%*s %*s %*s %*[^,], %*[^,], %f", &interval);

		run->year = yr;
		run->month = mn;
		run->day = day;
		run->hour = hr;
		run->minute = min;
		run->second = sec;
		run->is_gmt = 0;

		run->npoints = j;
		run->nchannels = nchan;
		run->port = port;
		run->sample_rate = 1/interval;

		break;
	}

	return (0);
}

/*******************************************************************/
void asscanf (char *line, long d[], int n)
{
	int r=0;

	switch (n) {
	case 1:
		r=sscanf (line, "%ld", &d[0]);
		break;
	case 2:
		r=sscanf (line, "%ld %ld", &d[0], &d[1]);
		break;
	case 3:
		r=sscanf (line, "%ld %ld %ld", &d[0], &d[1], &d[2]);
		break;
	case 4:
		r=sscanf (line, "%ld %ld %ld %ld", &d[0], &d[1], &d[2], &d[3]);
		break;
	case 5:
		r=sscanf (line, "%ld %ld %ld %ld %ld", &d[0], &d[1], &d[2], &d[3], &d[4]);
		break;
	case 6:
		r=sscanf (line, "%ld %ld %ld %ld %ld %ld", &d[0], &d[1], &d[2], &d[3], &d[4], &d[5]);
		break;
	case 7:
		r=sscanf (line, "%ld %ld %ld %ld %ld %ld %ld", &d[0], &d[1], &d[2], &d[3], &d[4], &d[5], &d[6]);
		break;
	case 8:
		r=sscanf (line, "%ld %ld %ld %ld %ld %ld %ld %ld", &d[0], &d[1], &d[2], &d[3], &d[4], &d[5], &d[6], &d[7]);
		break;
	}
	if (r != n ) {
		fprintf (stderr, "Read error: Expected %d channels, got %d.\n", n, r);
	}
}

/************************************************************************/
/* Determine chromatogram file type base on extension in file name. */
int gc_FileType (char *filename)
{
	char *p, extension[20];

	p = strrchr (filename, '.');
	if (p == NULL) return (UNKNOWN_FILE);

	sscanf (p, "%s", extension);
	if (strcmp (extension, ".gc") == 0) return (GC_FILE);
	else if (strcmp(extension, ".zip") == 0) return (ZIP_FILE);
	else if (strcmp(extension, ".g") == 0) return (GC_FILE);
	else if (strcmp(extension, ".itx") == 0) return (ITX_FILE);
	else if (strcmp(extension, ".txt") == 0) return (TEXT_FILE);
	else if (strcmp(extension, ".t") == 0) return (TEXT_FILE);
	else if (strcmp(extension, ".a") == 0) return (ARCHIVE_FILE);
	else return (UNKNOWN_FILE);
}

/*********************************************************************/
char *gc_SetDateStringFromRun(chromatogram run)
{
	static char s[15];


	sprintf (s, "%4d%02d%02d%02d%02d", run.year,
					   run.month,
					   run.day,
				           run.hour,
					   run.minute);
	return (s);
}

/*********************************************************************/
char *gc_SetFileNameFromRun(chromatogram run, int filetype)
{
	static char s[500];
	char *dir = NULL;
	static char *ftype[] = {"unk", "gc", "itx", "a", "txt"};
	int f;


	if (filetype < 0 || filetype > 4) 
		f = 0;
	else
		f = filetype;

	if (datadir == NULL) {
		dir = getenv("GCDATADIR");
	} else {
		dir = datadir;
	}


	if (dir == NULL ) {
		sprintf (s, "%4d%02d%02d%02d%02d.%s", 
					   run.year,
					   run.month,
					   run.day,
				           run.hour,
					   run.minute,
					   ftype[f]);
	} else {
		sprintf (s, "%s/data/%d/%4d%02d%02d%02d%02d.%s", dir, 
					   run.year,
					   run.year,
					   run.month,
					   run.day,
				           run.hour,
					   run.minute,
					   ftype[f]);
	}
	return (s);
}


/*********************************************************************/
/* Given a file name, construct the archive file name that it 
 * would be stored in.
 */

char *gc_ArchiveName(char *file)
{
	static char archive[512];
	char *s, *dir;
	int n, year, month, day;
	

	s = strrchr (file, '/');

/* check if there is a directory attached to file name
 * If not, just return archive file name without a directory.
 */

	if (s == NULL) {
		n = sscanf (file, "%4d%2d%2d", &year, &month, &day);
		if (n != 3) {
			fprintf (stderr, "Can't form archive file name from %s.\n", file);
			return (NULL);
		}
		sprintf (archive, "%4d%02d%02d.a", year, month, day);
		return (archive);

	} else {
		n = sscanf (s+1, "%4d%2d%2d", &year, &month, &day);
		if (n != 3) {
			fprintf (stderr, "Can't form archive file name from %s.\n", file);
			return (NULL);
		}

		dir = dirname (file);
		sprintf (archive, "%s/%d%02d%02d.zip", dir, year, month, day);
		return (archive);
	}
}
		
/*****************************************************************************/
static char *dirname(char *filename)
{
   static char dir[512];
   char *strrchr(), *n, *p;
   int c;

   n=strrchr (filename, '/');
   c=0;
   p=filename;
   while (p != n) {
      dir[c] = filename[c];
      c++;
      p++;
   }
   dir[c]='\0';
   return (dir);
}

/*****************************************************************************/
void gc_Free(gcPeaks *p)
{
	if (p) {
	
		if (p->detrend) free(p->detrend);
		if (p->smooth) free(p->smooth);
		if (p->slope) free(p->slope);
		if (p->bfit) free(p->bfit);

		free(p);
	}
}
