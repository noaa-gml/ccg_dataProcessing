/*#define DEBUG  */
/*#define DEBUG_BI */
/*#define DEBUG_END */
/*#define DEBUG_CANCEL*/

#include <stdio.h>
#include "gc.h"
#include "peaks.h"
/*#include "peaksegments.h" */
/*#include "timefunctions.h" */

/*
 * Peaks_find()
 *
 */
void gc_convert();

static	int upslope_too_flat(void);
static	int downslope_too_flat(void);
static	void peak_cancel(void);
static	void peak_crest_set(void);
static	void pos_segment(void);
static	void neg_segment(void);
static	void flat_segment(void);
static	void peak_start(void);
static	void peak_fused(void);
static	void peak_front_shoulder(void);
static	void peak_rear_shoulder(void);
static	void peak_halfheight_set(void);
static	int resolved_end_test(int ipeak);
static	void tangent_end_test(void);
static	void tailing_peak_test(void);
static	int get_ok_baseline_point(int xstart);
static int get_valley_bunch(int ibunch);
static int get_min_bunch(int xstart, int xend, int halfwidth);
static int get_max_bunch(int xstart, int xend, int halfwidth);
static double bunch_mean_level(int ibunch, int halfwidth);
static BaselineBits getBaselineBits(int i);
static int getPw(int i);
static float getPosPt(int i);
static float getNegPt(int i);
static int valley_before_start(int iseg, int pw);
static float baseline_slope(int start_bunch, int end_bunch);

#define	NSKEWED		6		/* 6 X PEAKWIDTH2 */

#define	NTANGENT	5		/* 5 X PEAKWIDTH2 */

#define NTANGENT_FLAT	4		/* Allow tangent if next segment is flat */
					/* and combined length meets NTANGENT test */


#define	NPLATEAU	4		/* 5 * PW */

#define	CONFIRMED_DOWNSLOPE(i)		 ( (Bunch[Peaks[i].xcrest] - Bunch[Segment[Iseg].start_bunch]) >  (int) (PEAKHEIGHT(i)/4) )



static	int	Iseg;			/* current segment number */
static	int	Baseline;		/* True Baseline Flag */
static	int	Tailing_parent_peak;	/* On tailing parent peak's "baseline" */

static	int	Resolved_start_peak;	/* index of peak */
static	int	Resolved_start_segment;	/* index of corresponding segment */

static	int	Peak_start_segment;	/* index of segment starting a peak */

/*
 * zeroed structures below
 * (make sure say current!)
 */
BaselineCodes	zero_baseline_codes = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
BaselineBits	zero_baseline_bits =  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

BaselineStruct	BlankPeak = {
	 0, 0, 0, 0, 0, 0, 0, -1,				/* shorts */
	 0, 0,							/* longs */
     	 0, 0, 0, 0, 0, 0,					/* floats */
    	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},		/* start bc */
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},		/* end bc */
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},	/* start options bits */
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},	/* end options bits */
	 ""};							/* name */

/*
 * Main peak finding loop
 */


extern Peak_segment Segment[MAX_SEGMENTS];
extern int Nsegments;

static float sample_rate;	/* for conversion of pw from seconds to number of points */

/**************************************************************/
void gc_find(p)
gcPeaks *p;
{

Bunch = p->smooth;
sample_rate = p->sample_rate;


	Tailing_parent_peak = -1;	/* not on Tailing parent peak's "baseline" */


	Baseline = 1;			/* Start with true baseline */
	Npeaks = -1;			/* Index to Peaks structure */

	for (Iseg = 0; Iseg < Nsegments; Iseg++) {
		if (Segment[Iseg].slope > 0)
			pos_segment();
		else if (Segment[Iseg].slope < 0)
			neg_segment();
		else
			flat_segment();
	}

	Npeaks++;	/* convert index to count */

	gc_convert(p);	/* convert Salameh's Peaks structure to gcPeaks structure */

}




/*
 * This test replaces tests like
 *	- plateau
 *	- minimum height
 *
 */
/************************************************************/
static	int upslope_too_flat()
{
	float	slope;
	float	pt;
	int	xstart, xend;

	/*
	 * calculate slope from peak start to end of flat segment
	 */
	xstart = Peaks[Npeaks].xstart;
	xend   = Segment[Iseg].end_bunch;

	slope = (Bunch[xend] - Bunch[xstart])/( (float) (xend - xstart) );

	pt = getPosPt(xstart);
	if (slope > pt/2)
		return(0);		/* peak ok to this point */

#ifdef DEBUG_CANCEL
	fprintf(stderr, "Peak %d, start %f - end seg %f, pt %f, up slope %f\n", Npeaks, TIME_FROM_BUNCH(xstart), TIME_FROM_BUNCH(xend), pt, slope);
#endif

	peak_cancel();
	return(1);
}

/************************************************************/
static	int downslope_too_flat()
{
	float	slope;
	float	pt;
	int	xstart, xend;

	/*
	 * calculate slope from peak crest to end of flat segment
	 */
	xstart = Peaks[Npeaks].xcrest;
	xend   = Segment[Iseg].end_bunch;

	slope = (Bunch[xend] - Bunch[xstart])/( (float) (xend - xstart) );

	pt = getNegPt(xstart);
	if (slope < -pt/2)
		return(0);		/* peak ok to this point */

#ifdef DEBUG_CANCEL
	fprintf(stderr, "Peak %d, crest %f - end seg %f, pt %f, down slope %f\n", Npeaks, TIME_FROM_BUNCH(xstart), TIME_FROM_BUNCH(xend), pt, slope);
#endif

	peak_cancel();
	return(1);
}

/************************************************************/
static	void peak_cancel()
{

	Npeaks--;			/* it's cancelled */


	/*
	 * Now decide what to do about end of previous fused peak
	 * (if any)
	 *
	 * Choices are
	 *  call previous end resolved
	 *     - depends on steepness and relative height of valley
	 *     - depends on relative height of ending point from xstart
	 *     - depends on PEAKWIDTH2 distances ending point is from crest
	 *
	 *  continue looking for previous peak's end
	 *    - current flat segment may CONTAIN previous peaks' end
	 *
	 */

	if (Npeaks < 0) {
		Baseline = 1;
		return;
	}


	if (Npeaks == Tailing_parent_peak) {
		Peaks[Npeaks].end.rider = 0;
		Peaks[Npeaks].end.resolved = 0;
		Tailing_parent_peak = -1;
		Baseline = 0;
	}

	if (Peaks[Npeaks].end.resolved) {
		Baseline = 1;
		return;
	}

	/*
	 * PEAKHEIGHT(Npeaks+1) requires cancelled peak to have a crest set!
	 */
	if (PEAKHEIGHT(Npeaks+1) > (int) PEAKHEIGHT(Npeaks)/50) {
		Baseline = 1;
		Peaks[Npeaks].end.resolved = 1;
		Peaks[Npeaks].end.fused = 0;
		Peaks[Npeaks].end.shoulder_point = 0;
		Peaks[Npeaks].end.shoulder_crest = 0;
	} else {
		Peaks[Npeaks].xend = 0;
		Peaks[Npeaks].end.fused = 0;
		Peaks[Npeaks].end.shoulder_point = 0;
		Peaks[Npeaks].end.shoulder_crest = 0;

		/*
		 * look for end of this peak in flat segment
		 * where this peak was canceled!
		 */
		resolved_end_test(Npeaks);
	}

}


/*
 * segment is flat, previous segment is positive
 * set crest if higher than already set crest
 */
/************************************************************/
static	void peak_crest_set()
{
	int	crest;
	int	xstart, xend;
	int	pw;
	int	halfwidth;
	
	if (Peaks[Npeaks].xcrest) {
		crest = Bunch[Peaks[Npeaks].xcrest];
		if (Segment[Iseg].max_level < crest && Segment[Iseg-1].max_level < crest)
			return;
	}


	xstart	= Segment[Iseg].start_bunch;
	xend	= Segment[Iseg].end_bunch;

	pw	= getPw(xstart);
	xstart -= BASELINE_WIDTH(pw);

	halfwidth = HALF_BASELINE_WIDTH(pw)/2;

	Peaks[Npeaks].xcrest = get_max_bunch(xstart, xend, halfwidth);

	/*
	 * If get a new crest, then reset xhalfheight_down!
	 */
	Peaks[Npeaks].xhalfheight_down = 0;
}

/*
 * Positive segment possibilities:
 *	- start of new (resolved) peak
 *	- start of fused peak
 *	- confirmation of front shoulder
 *	- peak continuing up after flat
 */
/************************************************************/
static	void pos_segment()
{

	if (Baseline) {
		peak_start();				/* possible resolved start */
		return;
	}

	/* Iseg-1 is neg or flat */

	if (Segment[Iseg - 1].slope < 0) {		/* fused (neg, pos) */
		peak_fused();
		return;
	}

	/* Iseg-1 segment is flat, Iseg-2 is neg or pos */

	if (Segment[Iseg - 2].slope < 0) {		/* fused (neg, flat, pos) */
		peak_fused();
		return;
	}


	/* Iseg-2 is pos, possible front shoulder (pos, flat, pos) */

	if (Segment[Iseg].slope2pt && Segment[Iseg-2].slope2pt) {
		peak_front_shoulder();
		return;
	}


	/* if here, then continuing up peak after a flat region */

}


/*
 * Negative segment possibilities:
 *	- baseline drifting down (not in a peak)
 *	- on down slope of normal peak
 *	- on down slope of rear shoulder
 *	- continuing down after flat
 */
/************************************************************/
static	void neg_segment()
{

	if (Baseline)
		return;

	/*
	 * we're in a peak and comming down
	 *
	 * if not rear shoulder, then find
	 *	-crest
	 *	-halfheight down
	 */

	/* Iseg-1 is pos or flat */

	if (Segment[Iseg-1].slope > 0) {	/* past peak crest (pos, neg) */
		peak_crest_set();

		tailing_peak_test();		/* after peak crest found */

		peak_halfheight_set();
		tangent_end_test();
		return;
	}

	/* Iseg-1 is flat, Iseg-2 is pos or neg */

	if (Segment[Iseg-2].slope > 0) {	/* past peak crest (pos, flat, neg)*/
		peak_halfheight_set();
		tangent_end_test();
		return;
	}

	/* Iseg-2 is neg, possible rear shoulder (neg, flat, neg)*/

	if (Segment[Iseg].slope2pt && Segment[Iseg-2].slope2pt) {
		peak_rear_shoulder();
		return;
	}


	/* if here, then continuing up down after a flat region */

	peak_halfheight_set();
	tangent_end_test();
}

/*
 * Flag segment possibilities:
 *	- flat baseline
 *	- top of peak
 *	- resolved end of peak
 *	- flat region between fused peaks
 *	- flat on way up or down peak
 *	  (may or may not be shoulder)
 */
/************************************************************/
static	void flat_segment()
{

	int	pw;
	int	xcrest;


	/*
	 * If on tail of Tailing_parent_peak and not
	 * in a rider peak (Baseline = 1), then
	 * look for resolved end of Tailing_parent_peak
	 */
	if (!Baseline && Tailing_parent_peak > -1) {
		resolved_end_test(Tailing_parent_peak);
		return;
	}


	if (Baseline)				/* flat baseline */
		return;


	/*
	 * Not confirmed downslope if current level
	 * above 3/4 the current peak height
	 */
	if (!CONFIRMED_DOWNSLOPE(Npeaks) || !Peaks[Npeaks].xcrest) {

		peak_crest_set();		/* do before too flat test */
						/* so know height of cancelled peak */

		if (upslope_too_flat())		/* peak cancelled if true */
			return;

		xcrest = Peaks[Npeaks].xcrest;
		pw = getPw(xcrest);

		/*
		 * a simple plateau test in case sharp
		 * peak upslope make upslope_too_flat test fail
		 */
		if ( (Segment[Iseg].end_bunch - xcrest) > NPLATEAU*pw) {
			peak_cancel();
			return;
		}


		tailing_peak_test();		/* after peak crest found */

		return;

	}



	/*
	 * If here then on confimed downslope
	 * look for resolved end or downslope too flat
	 */
	if (resolved_end_test(Npeaks)) {	/* resolved end if true */

		/*
		 * If rider resolved, look for end of
		 * parent in same segment
		 */
		if (Tailing_parent_peak > -1)
			resolved_end_test(Tailing_parent_peak);

		return;
	}


	if (downslope_too_flat())		/* peak cancelled if true*/
		return;

}


/*
 * possible start of resolved peak
 * (Iseg is positive)
 */
/************************************************************/
static	void peak_start()
{
	int	xstart;
	int	pw;

	BaselineBits	options;


	xstart = Segment[Iseg].start_bunch;
	pw = getPw(xstart);
	options = getBaselineBits(xstart);


	xstart = get_ok_baseline_point(xstart);
	if (xstart < 0)				/* baseline inhibit */
		return;



	/*
	 * if Iseg-1 negatively sloped
	 *	- set start at valley point
	 *	- don't move start back here
	 *	  (done only in tangent end test depending on slopes)
	 */
	if ( valley_before_start(Iseg, pw) ) {

#ifdef DEBUG_START
		fprintf(stderr, "peak start: get_valley_bunch(%f) = ", TIME_FROM_BUNCH(xstart));
#endif
		xstart = get_valley_bunch(xstart);

	} else {

#ifdef DEBUG_START
		fprintf(stderr, "peak start: %f moved back to ", TIME_FROM_BUNCH(xstart));
#endif
		xstart -= BASELINE_WIDTH(pw);
		if (xstart < 0) xstart = 0;	/* BUG FIX, KWT 16 Jun 97 */

	}


#ifdef DEBUG_START
	fprintf(stderr, "%f\n", TIME_FROM_BUNCH(xstart));
#endif

	/*
	 * set index to Resolved_start_peak
	 * (here and first peak on tailing parent)
	 */
	Npeaks++;
	Peaks[Npeaks] = BlankPeak;
	Peaks[Npeaks].xstart = xstart;
	Peak_start_segment = Iseg;


	Baseline = 0;
	Resolved_start_peak = Npeaks;
	Resolved_start_segment = Iseg;

	Peaks[Npeaks].start.resolved = 1;

}


/*
 * start of fused peak
 * (Iseg is positive)
 */
/************************************************************/
static	void peak_fused()
{

	int	xstart;
	BaselineBits	options;


	xstart = Segment[Iseg].start_bunch;

	options = getBaselineBits(xstart);
	if (options.nf)				/* fused peaks disabled */
		return;


	xstart = get_valley_bunch(xstart);	/* find fused valley */


	/*
	 * set end of previous peak one bunch before valley point
	 */
	Peaks[Npeaks].end.fused = 1;
	Peaks[Npeaks].xend = xstart - 1;
	
	Npeaks++;
	Peaks[Npeaks] = BlankPeak;
	Peaks[Npeaks].xstart = xstart;
	Peaks[Npeaks].start.fused = 1;
	Peak_start_segment = Iseg;

	/*
	 * check for fb (forced resolved baseline) option
	 */
	if (options.fb) {
		Baseline = 0;
		Resolved_start_peak = Npeaks;
		Resolved_start_segment = Iseg;

		Peaks[Npeaks].start.fused = 0;
		Peaks[Npeaks].start.resolved = 1;

		Peaks[Npeaks-1].end.fused = 0;
		Peaks[Npeaks-1].end.resolved = 1;
	}

}


/*
 * Confirmation of front shoulder terminates front shoulder peak
 * and begins new peak at end of front shoulder
 *
 * (Iseg is positive)
 */
/************************************************************/
static	void peak_front_shoulder()
{

	BaselineBits	options;
	int	xstart;
	int	crest_start, crest_end;
	int	pw;


	xstart = Segment[Iseg].start_bunch;	/* start of next peak */

	options = getBaselineBits(xstart);
	if (options.ns || options.nf)		/* shoulders disabled */
		return;


	/*
	 * end of front shoulder found
	 * (no xhalfheight_down set for front shoulder)
	 */
	Peaks[Npeaks].xend = xstart - 1;
	Peaks[Npeaks].end.fused = 1;
	Peaks[Npeaks].end.shoulder_point = 1;
	Peaks[Npeaks].end.shoulder_crest = 1;


	/*
	 * search for shoulder's actual crest along flat segment
	 */
	pw = getPw(xstart - 1);
	crest_start = Segment[Iseg-1].start_bunch;
	crest_end = Segment[Iseg-1].end_bunch;
	Peaks[Npeaks].xcrest = get_max_bunch(crest_start, crest_end, HALF_BASELINE_WIDTH(pw)/2);


	tailing_peak_test();		/* after peak crest found */


	/*
	 * start of new peak one bunch after
	 * end of front shoulder
	 */
	Npeaks++;
	Peaks[Npeaks] = BlankPeak;
	Peaks[Npeaks].xstart = xstart;
	Peaks[Npeaks].start.fused = 1;
	Peaks[Npeaks].start.shoulder_point = 1;
	Peak_start_segment = Iseg;

}


/*
 * Confirmation of rear shoulder peak terminates previous peak
 * and begins search for rear shoulder peak ending
 *
 * (Iseg is negative)
 */
/************************************************************/
static	void peak_rear_shoulder()
{

	BaselineBits	options;
	int	xstart;
	int	crest_start, crest_end;
	int	pw;

	
	xstart = Segment[Iseg-1].start_bunch;	/* start of rear shoulder */

	options = getBaselineBits(xstart);
	if (options.ns || options.nf)		/* shoulders disabled */
		return;

	/*
	 * end previous peak one bunch before
	 * first zero slope
	 */
	Peaks[Npeaks].xend = xstart - 1;
	Peaks[Npeaks].end.shoulder_point = 1;
	Peaks[Npeaks].end.fused = 1;


	/*
	 * start of rear shoulder found:
	 *    - crest set at start of rear shoulder by new_peak_init()
	 *
	 *    - no xhalfheight_down found for rear shoulder
	 *	since difficult to determine halfheight on shoulder peak
	 *
	 *    - special case in resolved_end_test() for rear shoulder
	 */

	Npeaks++;
	Peaks[Npeaks] = BlankPeak;
	Peaks[Npeaks].xstart = xstart;
	Peaks[Npeaks].start.fused = 1;
	Peaks[Npeaks].start.shoulder_point = 1;
	Peaks[Npeaks].start.shoulder_crest = 1;

	Peak_start_segment = Iseg - 1;	/* first segment of peak is the flat */

	/*
	 * search for shoulder's actual crest along flat segment
	 */
	crest_start = Segment[Iseg-1].start_bunch;
	crest_end = Segment[Iseg-1].end_bunch;
	pw = getPw(crest_start);
	Peaks[Npeaks].xcrest = get_max_bunch(crest_start, crest_end, HALF_BASELINE_WIDTH(pw)/2);

	tailing_peak_test();		/* after peak crest found */

}

/*
 * set peak half height, if not already set
 *
 * this routine called from neg_segment() if beyond peak crest
 * and not a rear shoulder peak
 */
/************************************************************/
static	void peak_halfheight_set()
{

	int	halfheight;
	int	i;

	if (Peaks[Npeaks].xhalfheight_down)	/* already reached */
		return;

	halfheight = PEAKHALFHEIGHT(Npeaks);

	/* check that segment gets low enought for halfheight */

	if (Segment[Iseg].min_level > halfheight)
		return;

	for (i = Segment[Iseg].start_bunch; i <= Segment[Iseg].end_bunch; i++)
		if (Bunch[i] < halfheight)
			break;

	Peaks[Npeaks].xhalfheight_down = i;

}



/*
 * true baseline test for peak specified
 *
 * this routine only called once for a peak!
 */
/************************************************************/
static	int resolved_end_test(int ipeak)
{
	int	flat_test;
	int	xend;

	int	nonflat_length;



#ifdef DEBUG_END
	if (ipeak = Tailing_parent_peak)
		fprintf(stderr, "Tailing parent resolved end test at %f\n", TIME_FROM_BUNCH(Segment[Iseg].start_bunch));
#endif


	flat_test = PEAKWIDTH2(ipeak);

	/*
	 * if haven't reached halfheight, then strange looking peak
	 *	- may be a rear shoulder
	 *	- may be flat between fused peaks
	 *	- may be resolved end or peak shouldn't have
	 *	  been started in the first place
	 *
	 */
	if (!Peaks[ipeak].xhalfheight_down)
		flat_test = getPw( (int) Peaks[ipeak].xcrest)/2;



	/*
	 * Allow 1 segment interruption of flat test
	 * as long as interruption total length is less than
	 * flat test.  Since flat test is generally around
	 * Pw/2 and segment minimum length is Pw/4, only
	 * a segment between these lengths will pass this test.
	 *
	 * (note: 2 interrupting segments are up/down = a peak)
	 */
	xend = 0;
	if (!Segment[Iseg-2].slope) {
		nonflat_length = Segment[Iseg].start_bunch - Segment[Iseg-2].end_bunch;
		if (nonflat_length < flat_test)
			xend = Segment[Iseg-2].end_bunch + flat_test;
	}


	if (!xend) {
		if (Segment[Iseg].length < flat_test)
			return(0);

		xend = Segment[Iseg].start_bunch + flat_test;
	}



	if (xend < Segment[Iseg].start_bunch)
		xend = Segment[Iseg].start_bunch;


#ifdef DEBUG_END
	fprintf(stderr, "Resolved end test peak %d, last segment sign %d, flat start %f, resolved end %f\n", ipeak, Segment[Iseg-1].slope, TIME_FROM_BUNCH(Segment[Iseg].start_bunch), TIME_FROM_BUNCH(xend));
#endif


	/* True baseline regained! (here and tangent fit only) */

	Baseline = 1;
	Peaks[ipeak].xend = xend;
	Peaks[ipeak].end.resolved = 1;

	/*
	 * end last rider if parent ended
	 * (if last rider not ended)
	 */
	if (ipeak < Npeaks) {

#ifdef DEBUG_END
		fprintf(stderr, "Tailing parent %d ended, End of last rider %d\n", ipeak, Peaks[Npeaks].xend);
#endif

		if (!Peaks[Npeaks].xend) {
			Peaks[Npeaks].xend = xend;
			Peaks[Npeaks].end.resolved = 1;
		}

		if (ipeak != Tailing_parent_peak) {

			/* code check */

			fprintf(stderr, "resolved_end_test: Npeaks %d, ipeak %d, Tailing_parent_peak %d\n", Npeaks, ipeak, Tailing_parent_peak);
		}

		Tailing_parent_peak = -1;
	}

	return(1);

}

/*
 * tangent resolved baseline end
 *	- if length of negative segment > NTANGENT*PEAKWIDTH2(Npeaks)
 *	  (NTANGENT a number between 6 and 10)
 *
 *	- tangent baseline from Resolved_start_peak
 *	  (never from a fused peak!)
 *
 *	- riders on a tailing peak are considered resolved
 *	  (on the tailing peak baseline)
 *
 */
/************************************************************/
static	void tangent_end_test()
{
	float	slope;
	float	steepest_slope;
	float	flatest_slope;
	float	pt;
	int	pw;
	int	steepest_slope_bunch;
	int	flatest_slope_bunch;
	int	resolved_start;
	int	start_bunch, end_bunch;
	int	neg_length, tangent_test;
	int	xcrest;
	int	i;

	BaselineBits	options;


	if (!Peaks[Npeaks].xhalfheight_down)
		return;

	xcrest = Peaks[Npeaks].xcrest;
	options = getBaselineBits(xcrest);

	if (options.nt)				/* no tangent option */
		return;

	/*
	 * use neg_length instead of Segment[Iseg].length
	 * because could have short segments of flat
	 * between negative segments
	 */
	if (!options.ft) {

		tangent_test = NTANGENT*PEAKWIDTH2(Npeaks);
		neg_length = Segment[Iseg].end_bunch - Peaks[Npeaks].xcrest;

		if (neg_length < tangent_test) {
			if (neg_length < (int) (NTANGENT_FLAT*PEAKWIDTH2(Npeaks)) )
				return;

			/*
			 * If next segment is flat,
			 * combined length may meet tangent test
			 */
			if (Iseg > Nsegments - 2)
				return;

			if (Segment[Iseg+1].slope)
				return;

			neg_length += Segment[Iseg+1].length;
			if (neg_length < tangent_test)
				return;

		}

	}


	resolved_start = Peaks[Resolved_start_peak].xstart;
	pt = getNegPt(xcrest);

	/*
	 * search for point on neg_segment which gives
	 * the steepest negative baseline slope from the start of
	 * the Resolved_start_peak
	 */
	start_bunch = Segment[Iseg].start_bunch;
	end_bunch = Segment[Iseg].end_bunch;
	steepest_slope_bunch = end_bunch;
	steepest_slope = baseline_slope(resolved_start, end_bunch);

	/*
	 * no tangent fit if baseline slope to end of negative
	 * segment is not more negative than -pt/2 (level)
	 */
	if (steepest_slope > -pt/2)
		return;

	for (i = end_bunch; i > start_bunch; i--) {

		slope = baseline_slope(resolved_start, i);

		/*
		 * don't go past level
		 */
		if (slope > -pt/2)
			break;

		if (slope < steepest_slope) {
			steepest_slope_bunch = i;
			steepest_slope = slope;
		}

	}


	/*
	 * "Baseline" regained, even if on parent's tail
	 */
	Baseline = 1;
	Peaks[Npeaks].xend = steepest_slope_bunch;
	Peaks[Npeaks].end.resolved = 1;
	Peaks[Npeaks].end.tangent = 1;


	/*
	 * now that we have a tangent end, check slope before
	 * peak start to see if negative, and if so find
	 * tangent resolved starting point also!
	 */
	pw = getPw(start_bunch);
	if ( !valley_before_start(Resolved_start_segment, pw) )
		return;


	start_bunch = Peaks[Resolved_start_peak].xstart;
	end_bunch = start_bunch - BASELINE_WIDTH(pw);

	/*
	 * start_bunch at valley
	 * move back up slope until find minimum
	 * baseline slope
	 */
	flatest_slope = steepest_slope;
	flatest_slope_bunch = start_bunch;
	for (i = start_bunch; i >= end_bunch; i--) {
		slope = baseline_slope(i, Peaks[Npeaks].xend);

		if (slope < flatest_slope)
			break;

		flatest_slope = slope;
		flatest_slope_bunch = i;
	}


	Peaks[Resolved_start_peak].xstart = flatest_slope_bunch;

}


/*
 * tangent_start_test run once for each peak
 * (to see if peak is a rider peak) from:
 *	- neg_segment or flat_segment once peak crest is found
 *	- peak_rear_shoulder
 *	- peak_front_shoulder
 */
/************************************************************/
static	void tailing_peak_test()
{

	int	rider_height;
	int	flat_on_tail;
	BaselineBits	options;


	if (Tailing_parent_peak > -1) {

		/*
		 * if here, then on a tailing peak
		 */
		rider_height = HEIGHT_FROM_PARENT(Tailing_parent_peak, Npeaks);
		if (PEAKHEIGHT(Npeaks) > rider_height)
			rider_height = PEAKHEIGHT(Npeaks);

		flat_on_tail = 0;
		if (!Segment[Peak_start_segment - 1].slope)
			flat_on_tail = 1;

		if (!Segment[Peak_start_segment - 2].slope)
			flat_on_tail = 1;

		if ((rider_height > PEAKHALFHEIGHT(Tailing_parent_peak)) || flat_on_tail) {

			/*
			 * rider peak > parent's halfheight ends tailing parent
			 * (resolved peak start is end of parent)
			 *
			 * or if segment before rider is flat, then
			 * parent is ended also!
			 */
			Peaks[Tailing_parent_peak].xend = Peaks[Resolved_start_peak].xstart - 1;
			Peaks[Tailing_parent_peak].end.fused = 1;
			Peaks[Tailing_parent_peak].end.resolved = 0;

			/*
		 	 * If here by flat segment before current peak,
			 * then current peak must be Resolved_start_peak
			 * since this peak wouldn't have been resolved
			 * without a flat segment proceeding it.
			 */
			Peaks[Resolved_start_peak].start.fused = 1;
			Peaks[Resolved_start_peak].start.resolved = 0;
			Peaks[Resolved_start_peak].start.rider = 0;


			/*
			 * if current peak is the first rider
			 * (short height after false crest),
			 * then tailing peak has no riders
			 */
			if (Resolved_start_peak == Tailing_parent_peak + 1)
				Peaks[Tailing_parent_peak].end.rider = 0;

			Tailing_parent_peak = -1;

			return;
		}

		/*
		 * if here, peak is a rider on the tailing peak
		 */
		Peaks[Npeaks].parent_index = Tailing_parent_peak;
		Peaks[Npeaks].start.rider = 1;
		return;
	}



	/*
	 * Look for Tailing parent peak
 	 * to exist, must have peaks fused down it's side
	 */
	if (!Peaks[Npeaks].start.fused)
		return;


	options = getBaselineBits(Peaks[Npeaks].xcrest);

	if (options.nr)			/* no rider option */
		return;

	/*
	 * peak can't be tailing if have rider before
	 * halfheight is reached (even if forced rider)!
	 */
	if (!Peaks[Npeaks-1].xhalfheight_down)
		return;

	/*
	 * Peak can't be a fused rider if slope reaches
	 * zero before the peak!
	 * (i.e. must be fused to negative slope)
	 */

	if (!Segment[Peak_start_segment - 1].slope)
		return;

	if ( (int) (CREST_TO_FUSED(Npeaks-1, Npeaks)) > (int) (NSKEWED*PEAKWIDTH2(Npeaks-1)) ) {

		/*
		 * This height test won't work if parent peak tail
		 * drops below it's starting point, so then must
		 * do a forced tangent
		 */
		if (HEIGHT_FROM_PARENT(Npeaks-1, Npeaks) > PEAKHALFHEIGHT(Npeaks-1))
			return;
	} else {

		/*
	 	 * Here we have forced parent condition
		 * forced rider (fr) must be on before rider peak's crest
	 	 */
		if (!options.fr)
			return;
	}

	/*
	 * If got here, then we have a tailing peak with riders
	 */

	Tailing_parent_peak = Npeaks - 1;

	Peaks[Tailing_parent_peak].end.rider = 1;
	Peaks[Tailing_parent_peak].end.fused = 0;
	Peaks[Tailing_parent_peak].end.resolved = 1;

	/*
	 * First rider peak is "resolved" on the parent's tailing "baseline"
	 * (tail of parent is defined as "baseline")
	 *
	 * so if rider's resolved end found, then "baseline" regained
	 *
	 */
	Resolved_start_peak = Npeaks;
	Resolved_start_segment = Peak_start_segment;

	Peaks[Npeaks].start.rider = 1;
	Peaks[Npeaks].start.fused = 0;
	Peaks[Npeaks].start.resolved = 1;
	Peaks[Npeaks].parent_index = Tailing_parent_peak;
	return;
}



/*
 * if baseline inhibit off at xstart
 *	- return xstart
 *
 * if baseline inhibit on at xstart
 *	- if no change in BI during segment, return -1
 *
 *	- if change during segment, find point where BI off (if any)
 *	  xstart and segment end and return, else return -1
 */
/************************************************************/
static	int get_ok_baseline_point(int xstart)
{

	int	i;
	int	xend;
	BaselineBits	options;

	xend   = Segment[Iseg].end_bunch;

	options = getBaselineBits(xstart);

#ifdef DEBUG_BI
	fprintf(stderr, "get_ok_baseline_point: xstart %d, BI %d\n", xstart, options.bi);
#endif

	if (!options.bi)			/* BI off at segment start */
		return(xstart);

	if (!Segment[Iseg].bi)			/* no change in BI during segment */
		return(-1);

	for (i = xstart; i < xend; i++) {
		options = getBaselineBits(i);
		if (!options.bi)
			return(i);
	}

	return(-1);
}

/*
 * below are generally useful routines declared in "peaks.h"
 * (put here because this file is small)
 */



/*
 * search for valley point within +/-BASELINE_WIDTH(Pw) of bunch
 */
/************************************************************/
static int get_valley_bunch(int ibunch)
{
	int	halfwidth;
	int	pw;

	pw = getPw(ibunch);
	halfwidth = HALF_BASELINE_WIDTH(pw)/2;
	return(get_min_bunch(ibunch - BASELINE_WIDTH(pw), ibunch + BASELINE_WIDTH(pw), halfwidth));
}


/************************************************************/
static int get_min_bunch(int xstart, int xend, int halfwidth)
{
	int	i;
	int	min_bunch;
	double	min_level;
	double	mean;

	min_bunch = (xstart + xend)/2;			/* in case flat */
	min_level = bunch_mean_level(min_bunch, halfwidth);
	for (i = xstart; i <= xend; i++) {

		mean = bunch_mean_level(i, halfwidth);
		if (mean < min_level) {
			min_level = mean;
			min_bunch = i;
		}
	}

	return(min_bunch);
}

/************************************************************/
static int get_max_bunch(int xstart, int xend, int halfwidth)
{
	int	i;
	int	max_bunch;
	double	max_level;
	double	mean;

	max_bunch = (xstart + xend)/2;			/* in case flat */
	max_level = bunch_mean_level(max_bunch, halfwidth);
	for (i = xstart; i <= xend; i++) {

		mean = bunch_mean_level(i, halfwidth);
		if (mean > max_level) {
			max_level = mean;
			max_bunch = i;
		}
	}

	return(max_bunch);
}


/*
 * mean level, no range checking done here
 */
/************************************************************/
static double bunch_mean_level(int ibunch, int halfwidth)
{
	int	i;
	double	mean;

	/*
	 * check for potential long overflow and use
	 * float version to get mean
	 *
	 * or just return center value
	 */
	mean = 0;
	for (i = ibunch - halfwidth; i <= ibunch + halfwidth; i++)
		mean += Bunch[i];

	mean /= (2*halfwidth + 1);

	return(mean);
}

/************************************************************/
static BaselineBits getBaselineBits(int i)
{
	BaselineBits options;

	options.nf = (int) getBC(i, NF);
	options.fb = (int) getBC(i, FB);
	options.ns = (int) getBC(i, NS);
	options.nt = (int) getBC(i, NT);
	options.ft = (int) getBC(i, FT);
	options.nr = (int) getBC(i, NR);
	options.bi = (int) getBC(i, BI);

	options.reserved = 0;
	options.fr = 0;
	options.nb = 0;
	options.cf = 0;
	options.bh = 0;
	options.fh = 0;
	options.vv = 0;
	options.be = 0;
	options.bs = 0;

	return (options);
}

/************************************************************/
static int getPw(int i)
{
	return ((int) (getBC(i, PW) * sample_rate));
}

/************************************************************/
static float getPosPt(int i)
{
	return (getBC(i, PT));
}

/************************************************************/
static float getNegPt(int i)
{
	return (getBC(i, PT));
}
/*
 * rule for valley before a peak start segment
 */
/************************************************************/
static int valley_before_start(int iseg, int pw)
{

	if (iseg < 1)
		return(0);

	if (Segment[iseg - 1].slope < 0)
		return(1);


	if (Segment[iseg - 1].length > 2*BASELINE_WIDTH(pw))
		return(0);

	if (iseg < 2)
		return(0);

	if (Segment[iseg - 2].slope < 0)
		return(1);

	return(0);
}


/*
 * slope of the baseline drawn between start_bunch and end_bunch
 */
/************************************************************/
static float baseline_slope(int start_bunch, int end_bunch)
{
	return( (Bunch[end_bunch] - Bunch[start_bunch]) /
		(float) (end_bunch - start_bunch) );
}
