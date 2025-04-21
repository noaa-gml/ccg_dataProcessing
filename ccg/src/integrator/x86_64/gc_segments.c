
/*
 *
 * (c) Copyright 1993 Peter Salameh, University of California, San Diego.
 *
 *     See SOURCE.NOTICE file for information on use of this source code.
 * 
 */

/*#define DEBUG */

#include <stdio.h>

#include "gc.h"


/*
 * Factors which scale to Pw (other factors defined in peaks.h)
 * (Pw passed explicitly to macro so clear function of current Pw)
 *
 * Note BASELINE_WIDTH (in peaks.h) is IDIVIDE(w, 4) or w/4
 * (good dimension to scale to)
 */
#define	MINSEG(w)		IDIVIDE(w, 4)

#define	MINPOS(w)		IDIVIDE(w, 4)
#define	MINNEG(w)		IDIVIDE(w, 4)
#define MINZERO(w)		IDIVIDE(w, 4)


/*
 * Current contiguous slope counts
 */
static	int	Npos;
static	int	Nneg;
static	int	Nzero;

/*
 * these are for shoulder test
 */
static	int	N2pos;
static	int	N2neg;

static	int	Max_level;
static	int	Min_level;

static	int	BI_change;
static	int	BS_change;
static	int	BE_change;

static	int	Segment_start;

static	int	Pw;


static int new_segment_test(int i, long level);

Peak_segment	Segment[MAX_SEGMENTS];
int		Nsegments = 0;

/*********************************************************************/
void gc_segments(gcPeaks *p)
{
	int	i;
	int	bi, tbi;
/* uncomment if user specified baseline start and end implemented
	int	bs, be;
	int	tbs, tbe;
*/
	float	Pt;
	Npos = Nneg = Nzero = 0;	 /* Initialize counts and flags */
	N2pos = N2neg = 0;

	Nsegments = 0;
	Segment_start = 0;

	Max_level = Min_level = p->smooth[0];

	tbi = (int) getBC(0, BI);
/*
	tbs = (int) getBC(0, BS);
	tbe = (int) getBC(0, BE);
*/

	BI_change = 0;
	BS_change = 0;
	BE_change = 0;

	/*
	 * set up segments for entire chromatogram
	 */

	for (i = 0; i < p->npoints; i++) {

		if ((bi = (int) getBC(i, BI)) != tbi) {
			BI_change = 1;
			tbi = bi;
		}
/*
 * Add in when implemented
 *
		if ((be = (int) getBC(i, BE)) != tbe) {
			BE_change = 1;
			tbe = be;
		}
		if ((bs = (int) getBC(i, BS)) != tbs) {
			BS_change = 1;
			tbs = bs;
		}
*/

		Pw = getBC(i, PW) * p->sample_rate;   /* Peak width in number of points */
		Pt = getBC(i, PT);


/* look for peak threshold crossings */

		if (p->slope[i] >= Pt) {
			if (!Npos) new_segment_test(i, p->smooth[i]);
			
			Npos++;
			Nneg = 0;
			N2neg = 0;
			Nzero = 0;

			if (p->slope[i] >= 2*Pt) N2pos++;

		} else if (p->slope[i] <= -Pt) {
			if (!Nneg) new_segment_test(i, p->smooth[i]);

			Nneg++;
			Npos = 0;
			N2pos = 0;
			Nzero = 0;
			
			if (p->slope[i] <= - 2*Pt) N2neg++;

		} else {
			if (!Nzero) new_segment_test(i, p->smooth[i]);

			Nzero++;
			Npos = 0;
			Nneg = 0;
			N2pos = 0;
			N2neg = 0;

		}

		if (p->smooth[i] > Max_level) Max_level = p->smooth[i];
		if (p->smooth[i] < Min_level) Min_level = p->smooth[i];
	}

	new_segment_test(p->npoints, 0);		/* last segment, if long enough */

	
#ifdef DEBUG
fprintf(stderr, "Nsegments %d\n", Nsegments);
fprintf(stderr, "Slope  Start  End  Length   Slope2Pt   Level range\n");
for (i=0; i<Nsegments; i++) {
fprintf(stderr, "%3d %7d %5d %5d %8d %10d %10d\n", Segment[i].slope, Segment[i].start_bunch, Segment[i].end_bunch, Segment[i].length, Segment[i].slope2pt, Segment[i].min_level, Segment[i].max_level);
}
#endif

}

/*********************************************************************/
static int new_segment_test(int i, long level)
{
	int	Merge;

	if (Npos > MINPOS(Pw)) {
		Segment[Nsegments].slope = 1;

		Segment[Nsegments].slope2pt = 0;
		if (N2pos > MINPOS(Pw))
			Segment[Nsegments].slope2pt = 1;

	} else if (Nneg > MINNEG(Pw)) {
		Segment[Nsegments].slope = -1;

		Segment[Nsegments].slope2pt = 0;
		if (N2neg > MINNEG(Pw))
			Segment[Nsegments].slope2pt = 1;

	} else if (Nzero > MINZERO(Pw)) {
		Segment[Nsegments].slope = 0;
		Segment[Nsegments].slope2pt = 0;

	} else {
		/*
		 * to reset Segment_start here
		 * may cause gaps between segments
		 */
		return(0);
	}

#ifdef DEBUG
fprintf(stderr, "add segment %d %ld\n", i, level);
#endif


	Merge = 0;
	if (Nsegments)
		if (Segment[Nsegments].slope == Segment[Nsegments-1].slope)
			Merge = 1;

	if (Merge)
		Nsegments--;

	if (!Merge)
		Segment[Nsegments].start_bunch = Segment_start;

	Segment[Nsegments].end_bunch = i - 1;
	Segment[Nsegments].length = Segment[Nsegments].end_bunch - Segment[Nsegments].start_bunch + 1;


	if (Merge) {
		if (Max_level < Segment[Nsegments].max_level) Max_level = Segment[Nsegments].max_level;
		if (Min_level > Segment[Nsegments].min_level) Min_level = Segment[Nsegments].min_level;
	}

	if (!Merge) {

		/* don't zero, since merging with previous values */

		Segment[Nsegments].bi = 0;
/*
		Segment[Nsegments].bs = 0;
		Segment[Nsegments].be = 0;
*/
	}

	if (BI_change)
		Segment[Nsegments].bi = 1;

/*
	if (BS_change)
		Segment[Nsegments].bs = 1;
	if (BE_change)
		Segment[Nsegments].be = 1;
*/

	Segment[Nsegments].max_level = Max_level;
	Segment[Nsegments].min_level = Min_level;


	Segment_start = i;
	Max_level = Min_level = level;
	BI_change = 0;
/*
	BS_change = 0;
	BE_change = 0;
*/
	Nsegments++;

	return(1);
}


