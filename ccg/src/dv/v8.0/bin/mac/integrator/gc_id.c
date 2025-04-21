
/*
 *
 * (c) Copyright 1993 Peter Salameh, University of California, San Diego.
 *
 *     See SOURCE.NOTICE file for information on use of this source code.
 * 
 *
 * MODIFIED *  kwt
 * 
 * . Changed method of getting peak id file name.  Now it is passed
 *   to this routine from elsewhere.
 * . Added some error checking to scanf call, also check to make
 *   sure Ngas doesn't overrun its max value.
 * . Removed getline() call with fgets, sscanf combination.
 *
 */

/*#define	DEBUG*/

/*
 * Peaks_read_idfile() -- read peakid table
 *
 * Peaks_id() -- identify peaks
 *
 */

#include <stdio.h>
#include <string.h>

#include "gc.h"

static int gc_read_idfile(gcPeaks *p, char *peakid_file, int channel);

#define MAXGAS		100
static  struct {
	char	name[10];
	int	start;
	int	end;
} Peakid[MAXGAS];

static	int	Ngas;


/****************************************************************/
static int gc_read_idfile(gcPeaks *p, char *peakid_file, int channel)
{
	FILE	*peakid;
	char	line[512], line1[512];
	int	n, t, chan;
	float   rt, width;

	Ngas = 0;

	if (peakid_file == NULL) return(0);

	if ( (peakid = fopen(peakid_file, "r")) == NULL) {
		fprintf(stderr, "cannot open peak id file: %s\n", peakid_file);
		return(-1);
	}

/* 
 * if line starts with '#' or is blank, skip it.
 * Read line up to any '#' or end of line
 * Skip lines that are for a different channel.
 */

	while (fgets(line1, 512, peakid) != NULL) {
		line[0] = '\0';
		sscanf (line1, "%[^\n#]", line);
		if (strlen(line) <= 1) continue;
		n = sscanf(line, "%s %d %f %f", Peakid[Ngas].name, &chan, &rt, &width);

		if (n != 4) {
			fprintf (stderr, "Format error in Peak ID file: %s\n", line);
		} else if (chan != channel ) {
			continue;
		} else {

/* convert rt and width to start and end positions */

			t = rt - width/2;
			Peakid[Ngas].start = t*p->sample_rate;
			t = rt + width/2;
			Peakid[Ngas].end = t*p->sample_rate;

			Ngas++;
			if (Ngas == MAXGAS) {
				fprintf (stderr, "Maximum number of peak id's found.\n");
				break;
			}
		}
	}


	fclose(peakid);

#ifdef DEBUG
	fprintf(stderr, "Number of gases in peak id file: %d\n", Ngas);
#endif

	return(0);

}


/****************************************************************/
/* Read the id file to identify which peak is which species.
 */
void gc_id(gcPeaks *p, char *idfile, int nchannel)
{

	int	rt;
	float	area;
	int	j, index, i;


	gc_read_idfile(p, idfile, nchannel);


/* Initialize all peak names to "" */

	for (i=0; i<p->npeaks; i++) strcpy (p->peaks[i].name, "");

/* Find largest peak in window (by area) */

	for (j = 0; j < Ngas; j++) {

		area = 0;
		index = -1;

/* loop through all peaks, find largest peak within window */

		for (i = 0; i < p->npeaks; i++) {
			rt = p->peaks[i].xcrest;
			if (rt > Peakid[j].start && rt < Peakid[j].end) {
				if (p->peaks[i].area > area) {
					index = i;
					area = p->peaks[i].area;
				}
			}
		}

/* Now copy the name to the peak found */

		if (index > -1)
			strcpy(p->peaks[index].name, Peakid[j].name);
	}

}
