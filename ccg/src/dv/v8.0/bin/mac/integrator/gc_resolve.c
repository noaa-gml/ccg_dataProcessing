/*#define DEBUG */
/*
 *
 * (c) Copyright 1993 Peter Salameh, University of California, San Diego.
 *
 *     See SOURCE.NOTICE file for information on use of this source code.
 * 
 */

#include <stdio.h>
#include "gc.h"

static int getBaselineCode(int t);
static double bunch_mean_level(gcPeaks *p, int ibunch, int halfwidth, int end_of_peak);

/*************************************************************/
void gc_resolve(gcPeaks *p)
{

	int	i;

	int	xstart, xend;
	int	min_bunch;
	int	max_bunch;

	int halfwidth;

	if (p->npeaks == 0) return;

/*
 * make sure peak starts not < 0
 * and peak ends not > Nbunch
 */

	min_bunch = 1 + (int)(BASELINEWIDTH(0)/2);
	max_bunch = (int)(p->npoints - 2 - (int)(BASELINEWIDTH(p->npoints)/2));

/* by definition */

	p->peaks[0].bc_start |=  RESOLVED;
	p->peaks[p->npeaks - 1].bc_end |= RESOLVED;

	if ( !p->peaks[p->npeaks - 1].xend )
		p->peaks[p->npeaks-1].xend = max_bunch;

	for (i=0; i<p->npeaks; i++) {
		if (p->peaks[i].xstart < min_bunch) p->peaks[i].xstart = min_bunch;
		if (p->peaks[i].xend > max_bunch) p->peaks[i].xend = max_bunch;
	}

/*
 * Ensure peak starts and ends do not overlap for adjacent peaks
 * (because some peaks start BASELINE_WIDTH(pw) before positive slope)
 *
 * check that previous peak isn't a parent peak
 * since  all rider peaks overlap their parent peak
 */

	for (i=1; i<p->npeaks; i++) {
		if (p->peaks[i].bc_end & RIDER) continue;
		if (p->peaks[i].xstart < p->peaks[i-1].xend)
			p->peaks[i-1].xend = p->peaks[i].xstart - 1;
	}

/*
 * Set baseline options bits for peak start and end
 */

	for (i=0; i<p->npeaks; i++) {
		p->peaks[i].start_options = getBaselineCode(p->peaks[i].xstart);
		p->peaks[i].end_options =   getBaselineCode(p->peaks[i].xend);
	}

/*
 * set valley_point if vv option
 * (don't set if manual integration, since user has control)
 */

	for (i=0; i<p->npeaks; i++) {
		if (p->peaks[i].bc_start & FUSED && !p->peaks[i].bc_start & MOUSE) 
			if (p->peaks[i].start_options & VV)
				p->peaks[i].bc_start |= VALLEY_POINT;

		if (p->peaks[i].bc_end & FUSED && !p->peaks[i].bc_end & MOUSE) 
			if (p->peaks[i].end_options & VV)
				p->peaks[i].bc_end |= VALLEY_POINT;
	}


/*
 * set starting and ending baseline levels
 *
 * (peak shape tests in peaks_find use single bunch
 * level for peak height, etc.)
 */

	for (i=0; i<p->npeaks; i++) {
		xstart = p->peaks[i].xstart;
		halfwidth = BASELINEWIDTH(xstart)/2;
		if (p->peaks[i].bc_start & FUSED)
			halfwidth = HALFBASELINEWIDTH(xstart)/2;

		p->peaks[i].xstartwidth = 2*halfwidth + 1;
		p->peaks[i].start_level = bunch_mean_level(p, xstart, halfwidth, 0);

#ifdef DEBUG
	fprintf(stderr, "peak %d, xstart %d, halfwidth %d, start_level %ld\n", i, xstart, halfwidth, p->peaks[i].start_level);
#endif
		

		xend = p->peaks[i].xend;
		halfwidth = BASELINEWIDTH(xend)/2;   /* = HALFBASELINEWIDTH(xend)  = 1/8 PW at xend */
		if (p->peaks[i].bc_end & FUSED)
			halfwidth = HALFBASELINEWIDTH(xend)/2;

		p->peaks[i].xendwidth = 2*halfwidth + 1;
		p->peaks[i].end_level = bunch_mean_level(p, xend, halfwidth, 1);

#ifdef DEBUG
	fprintf(stderr, "peak %d, xend %d, halfwidth %d, end_level %ld\n", i, xend, halfwidth, p->peaks[i].end_level);
#endif

	}

}


/***************************************************************/
static int getBaselineCode(int t)
{
	int a;

	a = 0;
	if ((int) getBC(t, BI)) a = a | BI;
	if ((int) getBC(t, VV)) a = a | VV;
	if ((int) getBC(t, FH)) a = a | FH;
	if ((int) getBC(t, BH)) a = a | BH;
	if ((int) getBC(t, CF)) a = a | CF;
	if ((int) getBC(t, NB)) a = a | NB;
	if ((int) getBC(t, FB)) a = a | FB;
	if ((int) getBC(t, NT)) a = a | NT;
	if ((int) getBC(t, FT)) a = a | FT;
	if ((int) getBC(t, NR)) a = a | NR;
	if ((int) getBC(t, FR)) a = a | FR;
	if ((int) getBC(t, NF)) a = a | NF;
	if ((int) getBC(t, NS)) a = a | NS;
	if ((int) getBC(t, CB)) a = a | CB;

	return (a);
}

/***************************************************************/
static double bunch_mean_level(gcPeaks *p, int ibunch, int halfwidth, int end_of_peak)
{
	int	i, start, end;
	double	mean;

	/*
	 * check for potential long overflow and use
	 * float version to get mean
	 *
	 * or just return center value
	 */
	mean = 0;

	/* If we want one sided averaging, then find the start and end points
	 * to average.  For the end of the peak, we average over 
	 * peak end to peak end + 2*halfwidth.
	 * For the start of the peak, we average over
	 * peak start - 2*halfwidth to peak start
	 * Double check that start and end points are not outside range of points.
	 * If not one sided averaging, then average over point +/- 2*halfwidth.
	*/
	if ((int) getBC(ibunch, OS)) {
		if (end_of_peak) {
			end = ibunch+2*halfwidth;
			if (end >= p->npoints ) end = p->npoints-1;
			for (i=ibunch; i<=end; i++) 
				mean += p->smooth[i];
		} else {
			start = ibunch-2*halfwidth;
#ifdef DEBUG
fprintf (stderr, "start = %d, value = %ld\n", start, p->smooth[start]);
#endif
			if (start < 0) start = 0;
			for (i=start; i<=ibunch; i++) 
				mean += p->smooth[i];
		}
	} else {

#ifdef DEBUG
fprintf (stderr, "start = %d, value = %ld\n", ibunch-halfwidth, p->smooth[ibunch-halfwidth]);
#endif
		for (i = ibunch - halfwidth; i <= ibunch + halfwidth; i++)
			mean += p->smooth[i];
	}

	mean /= (2*halfwidth + 1);

	return(mean);
}
