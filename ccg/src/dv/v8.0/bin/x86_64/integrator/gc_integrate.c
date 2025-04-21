
/*
#define DEBUG
*/
/*
 *
 */

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#include "gc.h"

static void gc_baselinecode(gcPeaks *p);
static char *format_bc(int bc);		/* start or end */
static void gc_Peaks_print(gcPeaks *p, char *pass);

void gc_smooth(long *, int , float *, gcPeaks *p, int);
void gc_find(gcPeaks *p);
void gc_area(gcPeaks *p);
void gc_resolve(gcPeaks *p);
void gc_baselinefit(long *data, int n, gcPeaks *p);
int gc_read_timefile(gcPeaks *p, char *file);
void gc_segments(gcPeaks *p);
void gc_detrend (long *data, int npoints, gcPeaks *p);


int gc_errno;

/************************************************************/
/* The main integration routine.  
 *
 * INPUT:
 *	data - Long integer array containing chromatogram values.
 *      npoints - Number of points in data[].
 *	sample_rate - Number of samples per second in data[].
 *	timefile    - Name of file to get integration information.
 *
 * OUTPUT:
 *	Pointer to Peaks structure, or NULL if error occurs.
 *
 */
gcPeaks *gc_integrate(long *data, int npoints, float sample_rate, char *timefile)
{
	int  i, n;
	gcPeaks *ptr;
float *junk;
/*
struct timeval  t1, t2;
struct timezone tzp;
float elapsed_time, time_diff();
*/

/*
printf ("sample rate in gc_integrate = %f\n", sample_rate);
printf ("npoints = %d\n", npoints);
printf ("data[0] = %ld\n", data[0]);
if (timefile) {
printf ("timefile = %s\n", timefile);
}
*/


	if (npoints <= 0) {
		gc_errno = GC_NO_DATA_POINTS;
		return (NULL);
	}

	ptr = (gcPeaks *) malloc (sizeof (gcPeaks));
	ptr->detrend = (long *) calloc (npoints, sizeof (long));
	ptr->smooth =  (long *) calloc (npoints, sizeof (long));
	ptr->slope =   (float *) calloc (npoints, sizeof (float));
	ptr->bfit =    (long *) calloc (npoints, sizeof (long));
junk =   (float *) calloc (npoints, sizeof (float));

	ptr->sample_rate = sample_rate;
	ptr->npoints = npoints;
	ptr->n = 0;


#ifdef DEBUG
	fprintf(stderr, "npoints %d, sample rate = %f, data[0] = %d, data[%d] = %d\n", npoints, sample_rate, (int) data[0], npoints-1, (int) data[npoints-1]);
#endif

/*
 * Read the timefile for information on how to
 * integrate the chromatogram.
 * If timefile not specified or can't be read,
 * continue on and integrate with internal defaults.
 */

/*
gettimeofday(&t1, &tzp);
*/
	n = gc_read_timefile(ptr, timefile);
/*
gettimeofday(&t2, &tzp);
elapsed_time = time_diff(t1, t2);
printf ("read timefile: %f\n", elapsed_time);
*/

#ifdef DEBUG
	fprintf(stderr, "Done with gc_read_timefile()\n");
#endif


/*----------------------------------------
 * curved baseline fit and subtraction here
 *-----------------------------------------*/


	gc_baselinefit(data, npoints, ptr);
#ifdef DEBUG
	fprintf(stderr, "Done with gc_baselinefit()\n");
#endif

	gc_detrend (data, npoints, ptr);


#ifdef DEBUG
	fprintf(stderr, "Done with gc_baselinefit(); data[0] = %d, data[%d] = %d\n", (int) ptr->detrend[0], npoints-1, (int) ptr->detrend[npoints-1]);
#endif
/*
gettimeofday(&t1, &tzp);
elapsed_time = time_diff(t2, t1);
printf ("baseline fit: %f\n", elapsed_time);
*/

/*
for (i=0; i<npoints; i++) printf ("%f %d\n", (float) i/sample_rate, ptr->detrend[i]);
*/


	gc_smooth (ptr->detrend, ptr->npoints, ptr->slope, ptr, 1);
#ifdef DEBUG
	fprintf(stderr, "Done with gc_smooth, degree = 1\n");
#endif
/*
gettimeofday(&t2, &tzp);
elapsed_time = time_diff(t1, t2);
printf ("smooth 1: %f\n", elapsed_time);
*/


	gc_smooth(ptr->detrend, ptr->npoints, junk, ptr, 0);
for (i=0; i<npoints; i++) ptr->smooth[i] = (long) junk[i];
free(junk);
#ifdef DEBUG
	fprintf(stderr, "Done with gc_smooth, degree = 0\n");
#endif
/*
for (i=0; i<npoints; i++) printf ("%f %d\n", (float) i/sample_rate, ptr->smooth[i]);
*/
/*
gettimeofday(&t1, &tzp);
elapsed_time = time_diff(t2, t1);
printf ("smooth 0: %f\n", elapsed_time);
*/



	gc_segments (ptr);
/*
gettimeofday(&t2, &tzp);
elapsed_time = time_diff(t1, t2);
printf ("segments: %f\n", elapsed_time);
*/

	gc_find(ptr);
#ifdef DEBUG
gc_Peaks_print (ptr, "gc_find");
#endif
/*
gettimeofday(&t1, &tzp);
elapsed_time = time_diff(t2, t1);
printf ("find: %f\n", elapsed_time);
*/

/*
 * don't run Peaks_find() if manual integration
 */

/*
	if (!ManualIntegration) {
		Peaks_find();
#ifdef DEBUG
		fprintf(stderr, "\nNpeaks = %d\n", Npeaks);
		Peaks_print("Peaks_find");
#endif
	} else {
		Peaks_manual();
	}
*/


	gc_resolve(ptr);
#ifdef DEBUG
gc_Peaks_print (ptr, "gc_resolve");
#endif
/*
gettimeofday(&t2, &tzp);
elapsed_time = time_diff(t1, t2);
printf ("resolve: %f\n", elapsed_time);
*/

	gc_area(ptr);
#ifdef DEBUG
gc_Peaks_print(ptr, "Peaks_area");
#endif
/*
gettimeofday(&t1, &tzp);
elapsed_time = time_diff(t2, t1);
printf ("area: %f\n", elapsed_time);
*/

	gc_baselinecode(ptr);
/*
gettimeofday(&t2, &tzp);
elapsed_time = time_diff(t1, t2);
printf ("baseline code: %f\n", elapsed_time);
*/

#ifdef DEBUG
printf ("leaving gc_integrate.\n");
#endif

	return (ptr);
}

/******************************************************************/
static void gc_baselinecode(gcPeaks *p)
{
	int i;

	for (i=0; i<p->npeaks; i++) {
		strcpy (p->peaks[i].bcode, format_bc(p->peaks[i].bc_start));
		strcat (p->peaks[i].bcode, format_bc(p->peaks[i].bc_end));
	}
}
	

/******************************************************************/
static char *format_bc(int bc)
{
	static char string[8];
	int n=0;

	/* first set exclusive code, indicating baseline construction */

	if (bc & TANGENT) string[n++] = 'T';

	 else if (bc & RESOLVED) string[n++] = 'B';

	 else if (bc & FUSED) {

		if (bc & PENETRATED) string[n++] = 'P';

		else if (bc & VALLEY_POINT) string[n++] = 'V';

		else string[n++] = 'F';
	}


	/* now for non-exclusive, descriptive codes (in order) */

	if (bc & SHOULDER_POINT) string[n++] = 'S';	/* shoulder point */


	if (bc & FORCED) string[n++] = 'I';	/* integration inhibit forced point */

	if (bc & HORIZONTAL) string[n++] = 'H';

	if (bc & RIDER) string[n++] = 'R';	/* at start means peak is rider */
						/* at end means peak has rider */

	if (bc & MOUSE) string[n++] = 'M';	/* manually set point */

	string[n] = '\0';

	return (string);

}
/**********************************************************************/
/*
float time_diff(struct timeval first, struct timeval second)
{
        float usec, td;
        int sec;

        if (first.tv_usec > second.tv_usec) {
                second.tv_usec += 1000000;
                second.tv_sec--;
        }
        usec = ((float) (second.tv_usec - first.tv_usec))/1000000.0;
        sec = second.tv_sec - first.tv_sec;
        td = (float) sec+usec;
        return (td);
}
*/

/**********************************************************************/
static void gc_Peaks_print(gcPeaks *p, char *pass)
{
	int	i;
	int bc, bb;

	for (i = 0; i < p->npeaks; i++) {

		fprintf(stderr, "\nPeak %d structure after %s:\n", i, pass);

		fprintf(stderr, "Baseline points: start %d half-ht %d crest %d half-ht %d end %d\n", p->peaks[i].xstart, p->peaks[i].xhalfheight_up, p->peaks[i].xcrest, p->peaks[i].xhalfheight_down, p->peaks[i].xend);

		bc = p->peaks[i].bc_start;
fprintf (stderr, "bc = %d\n", bc);
		fprintf(stderr, "Baseline start codes: resolved %ld tangent %ld forced %ld fused %ld penetrated %ld shoulder %ld rider %ld mouse %ld\n", bc & RESOLVED, bc & TANGENT, bc & FORCED, bc & FUSED, bc & PENETRATED, bc & SHOULDER_POINT, bc & RIDER, bc & MOUSE);

		bc = p->peaks[i].bc_end;
fprintf (stderr, "bc = %d\n", bc);
		fprintf(stderr, "Baseline   end codes: resolved %ld tangent %ld forced %ld fused %ld penetrated %ld shoulder %ld rider %ld mouse %ld\n", bc & RESOLVED, bc & TANGENT, bc & FORCED, bc & FUSED, bc & PENETRATED, bc & SHOULDER_POINT, bc & RIDER, bc & MOUSE);

		bb = p->peaks[i].start_options;
		fprintf(stderr, "Baseline start options: bi %ld bs %ld be %ld   vv %ld fh %ld bh %ld cf %ld   nb %ld fb %ld   nt %ld ft %ld  nr %ld fr %ld  nf %ld ns %ld\n", bb & BI, bb & BS, bb & BE, bb & VV, bb & FH, bb & BH, bb & CF, bb & NB, bb & FB, bb & NT, bb & FT, bb & NR, bb & FR, bb & NF, bb & NS);

		bb = p->peaks[i].end_options;
		fprintf(stderr, "Baseline   end options: bi %ld bs %ld be %ld   vv %ld fh %ld bh %ld cf %ld   nb %ld fb %ld   nt %ld ft %ld  nr %ld fr %ld  nf %ld ns %ld\n", bb & BI, bb & BS, bb & BE, bb & VV, bb & FH, bb & BH, bb & CF, bb & NB, bb & FB, bb & NT, bb & FT, bb & NR, bb & FR, bb & NF, bb & NS);
	}

}
