/*
 *
 * (c) Copyright 1993 Peter Salameh, University of California, San Diego.
 *
 *     See SOURCE.NOTICE file for information on use of this source code.
 * 
 */

/* Removed _ from curvefit_ for HP-UX */
/* Made baseline_calc a float instead of int */

/*#define	DEBUG_FIT*/
/*#define	DEBUG_RIDER*/
/*#define	DEBUG_PENETRATION*/
/*#define	DEBUG*/

/*
 * peaksarea.c
 *
 * Final integration pass
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "gc.h"

static	int	find_true_baselines(gcPeaks *p);
static	void	set_true_baseline(gcPeaks *p, int istart, int iend);
static	int	set_penetration_baseline(gcPeaks *p, int istart, int iend);
static	float	area_calc(gcPeaks *P, int ipeak);
static  float	height_calc(gcPeaks *p, int ipeak);

static	void	set_crest_at_max_height(gcPeaks *p, int ipeak);
static	void	set_halfheight_points(gcPeaks *p, int ipeak);
static  float   mean_float_level(gcPeaks *p, int ibunch, int halfwidth);

static	int	RiderPass;


/***********************************************************/
void gc_area(gcPeaks *p)
{
	int	i;
	int	parent;
	int	count;

	count = 0;		/* to prevent possible infinite loop */

	RiderPass = 0;
	while(find_true_baselines(p) && count < 10)	/* find and set ture baselines*/
		count++;

	RiderPass = 1;
	while(find_true_baselines(p) && count < 10)	/* repeat for rider */
		count++;


	/* calculated gross peak areas */

	for (i = 0; i < p->npeaks; i++)
		p->peaks[i].area = area_calc(p, i);


	/* subtract areas of rider peaks */

	for (i = 1; i < p->npeaks; i++) {
		if (p->peaks[i].bc_start & RIDER) {
			parent = p->peaks[i].parent_index;
			p->peaks[parent].area -= p->peaks[i].area;
#ifdef DEBUG_RIDER
			fprintf(stderr, "Rider %d (area %f), Parent %d (area without rider %f)\n", i, p->peaks[i].area, parent, p->peaks[parent].area);
#endif
		}
	}

/*
 * Set crest to maximum height (not level).
 * Calculate peak heights and
 * find peak half height points on either side of crest.
*/

	for (i = 0; i < p->npeaks; i++) {
		set_crest_at_max_height(p, i);
		p->peaks[i].height = height_calc(p, i);
		set_halfheight_points(p, i);
	}
}

/***********************************************************/
static	int find_true_baselines(gcPeaks *p)
{
	int	i;
	int	istart;
	int	iend;
	int	have_penetration;

	have_penetration = 0;

	/*
	 * if RiderPass, do only for rider peaks
	 * otherwise skip rider peaks
	 */

	istart = iend = -1;
	for (i = 0; i < p->npeaks; i++) {

		if (RiderPass) {
			if (!(p->peaks[i].bc_start & RIDER)) continue;
		} else { 
			if (p->peaks[i].bc_start & RIDER) continue;
		}
		
		if (p->peaks[i].bc_start & (RESOLVED | PENETRATED | VALLEY_POINT)) istart = i;
		if (p->peaks[i].bc_end   & (RESOLVED | PENETRATED | VALLEY_POINT)) iend = i;

		if (istart != -1 && iend != -1) {
			set_true_baseline(p, istart, iend);

			/*
			 * keep setting new baselines between istart and iend
			 * to deepest penetrating point until no more
			 */
			if (set_penetration_baseline(p, istart, iend))
				have_penetration = 1;

			istart = -1;
			iend = -1;
		}
	}

	return(have_penetration);
}


/***********************************************************/
/*
 * set baselines between istart and iend to deepest penetrating point
 * returns 0 if found none, otherwise returns 1
 */
static	int set_penetration_baseline(gcPeaks *p, int istart, int iend)
{
	int	i;
	float	baseline;
	float	penetration;
	int	max_penetration;
	int	max_penetration_peak;

	if (istart == iend)
		return(0);

	max_penetration = 0;
	max_penetration_peak = 0;

	/*
	 * Find peak with max_penetration at it's end
	 * (if none, then can't be penetration start,
	 *  since end fused to the next start)
	 */
	for (i = istart; i < iend; i++) {
		if (RiderPass) {
			if (!(p->peaks[i].bc_start & RIDER)) continue;
		} else {
			if (p->peaks[i].bc_start & RIDER) continue;
		}

		/*
		 * if no penetration, then penetration negative
		 * (can get very sligh penetration here, but ok)
		 */
		baseline = gc_getBaseline(p, i, p->peaks[i].xend);

		/*
		 * penetration within 0.1% considered on baseline!
		 * (otherwise infinite loop here)
		 */
		penetration = baseline - p->peaks[i].end_level;
		if (abs((int) penetration) < (int) (0.001*abs((int) baseline)) )
			continue;

#ifdef DEBUG_PENETRATION
		fprintf(stderr, "baseline %d, end_level %d, penetration %d, maxpenetration %d\n", baseline, Peaks[ipeak].end_level, penetration, max_penetration);
#endif


		if (penetration > max_penetration) {
			max_penetration = penetration;
			max_penetration_peak = i;
		}
	}

#ifdef DEBUG_PENETRATION
	fprintf(stderr, "istart %d, iend %d, max_penetration_peak %d\n", istart, iend, max_penetration_peak);
#endif
	if (max_penetration) {

		/*
		 * baseline from true start to penetrated end
		 */
		p->peaks[max_penetration_peak].bc_end |= PENETRATED;
		p->peaks[max_penetration_peak].bc_end &= ~VALLEY_POINT; /* turn off valley point bit */
		p->peaks[max_penetration_peak].bc_end &= ~HORIZONTAL;
		set_true_baseline(p, istart, max_penetration_peak);

		/*
		 * baseline from penetrated start to true end
		 */
		p->peaks[max_penetration_peak + 1].bc_start |= PENETRATED;
		p->peaks[max_penetration_peak + 1].bc_start &= ~VALLEY_POINT;
		p->peaks[max_penetration_peak + 1].bc_start &= ~HORIZONTAL;
		set_true_baseline(p, max_penetration_peak + 1, iend);

		return(1);
	} else {
		return(0);
	}

}


/***********************************************************/
/*
 * apply FH and BH if set
 *
 * if not FH or BH, then calculated baseline between
 * true starting and ending points
 *
 * assign baseline to all peaks between istart and iend
 */
static	void set_true_baseline(gcPeaks *p, int istart, int iend)
{

	int	ipeak;
	int	ibunch;
	double	start_level, end_level;
	double	start_bunch, end_bunch;
	double	a, b, c, d;
	double	x[6], y[6];
	int	nfit;
	int	halfwidth;

/*
 * is starting or ending level determined by a horizontal
 * line from a resolved baseline point?
 *
 * (only resolved points may provide the level for a horizontal
 * baseline, otherwise baseline discontinuities may result)
 *
 * (I'm not considering the case when both are set,
 * to allow horizontal-sloped-horizontal for fused
 * peaks inbetween istart and iend)
 *
 * (don't set horizontal at point set my manual integration,
 * since user has control)
 */

	if ((p->peaks[istart].start_options & BH) && (p->peaks[iend].bc_end & RESOLVED)) 
		if (!(p->peaks[istart].bc_start & MOUSE))
			p->peaks[istart].bc_start |= HORIZONTAL;

	if ((p->peaks[iend].end_options & FH) && (p->peaks[istart].bc_start & RESOLVED))
		if (!(p->peaks[iend].bc_end & MOUSE))
			p->peaks[iend].bc_end |= HORIZONTAL;


	if (p->peaks[iend].bc_end & HORIZONTAL) {
		a = p->peaks[istart].start_level;
		b = 0;
		c = d = 0;

	} else if (p->peaks[istart].bc_start & HORIZONTAL) {
		a = p->peaks[iend].end_level;
		b = 0;
		c = d = 0;

	} else if ((p->peaks[istart].start_options & CF) && (p->peaks[iend].end_options & CF)) {

		halfwidth = p->peaks[istart].xstartwidth/2;

		ibunch = p->peaks[istart].xstart;
		x[0] = (double) ibunch;
		y[0] = (double) mean_float_level(p, ibunch, halfwidth);

		ibunch -= 2* (int) p->peaks[istart].xstartwidth/2;
		x[1] = (double) ibunch;
		y[1] = (double) mean_float_level(p, ibunch, halfwidth);


		halfwidth = p->peaks[iend].xendwidth/2;

		ibunch = p->peaks[iend].xend;
		x[2] = (double) ibunch;
		y[2] = (double) mean_float_level(p, ibunch, halfwidth);

		ibunch += 2*p->peaks[iend].xendwidth/2;
		x[3] = (double) ibunch;
		y[3] = (double) mean_float_level(p, ibunch, halfwidth);


		nfit = 4;
#ifdef DEBUG_FIT
		for (i = 0; i < nfit; i++)
			fprintf(stderr, "x[%d] = %f, y[%d] = %f\n", i, x[i], i, y[i]);
#endif

/*
		curvefit(x, y, nfit, &a, &b, &c, &d);
*/
a = b= c= d= 0;
	} else {
		start_level = (double) p->peaks[istart].start_level;
		end_level   = (double) p->peaks[iend].end_level;
		start_bunch = (double) p->peaks[istart].xstart;
		end_bunch   = (double) p->peaks[iend].xend;
		
		b = (end_level - start_level)/(end_bunch - start_bunch);

		a = start_level - b*start_bunch;
		c = d = 0;
#ifdef DEBUG
	fprintf (stderr, "start_level %f, end_level %f, start_bunch %f, end_bunch %f\n", start_level, end_level, start_bunch, end_bunch);
#endif
	}


#ifdef DEBUG
	fprintf(stderr, "istart %d, iend %d, a %f, b %f, c %f, d %f\n", istart, iend, a, b, c, d);
#endif

	/*
	 * now assign baseline to all peaks between istart and iend
	 * (do I set horizotal flag for peaks between istart and iend?)
	 */
	for (ipeak = istart; ipeak <= iend; ipeak++) {
		p->peaks[ipeak].a = (float) a;
		p->peaks[ipeak].b = (float) b;
		p->peaks[ipeak].c = (float) c;
		p->peaks[ipeak].d = (float) d;
	}

}




/***********************************************************/
/*
 * calculate gross area (including riders) for peak ipeak
 */
static	float area_calc(gcPeaks *p, int i)
{
	int	j;
	float	area, a1, a2;

/* use trapezoidal rule for integrating. */

	area = 0.0;
	for (j = p->peaks[i].xstart; j < p->peaks[i].xend; j++) {
		a1 = (float) (p->smooth[j]) - gc_getBaseline(p, i, j);
		a2 = (float) (p->smooth[j+1]) - gc_getBaseline(p, i, j+1);
		area += (a1+a2);
	}

	area = area/2.0/p->sample_rate;
		
	return(area);
}

/***********************************************************/
/*
 * calculate height peak ipeak
 */
static	float height_calc(gcPeaks *p, int i)
{
	int	xcrest;
	int	halfwidth;
	float	height;

	xcrest = p->peaks[i].xcrest;

	halfwidth = HALFBASELINEWIDTH(xcrest)/2;
	height = mean_float_level(p, xcrest, halfwidth) - gc_getBaseline(p, i, xcrest);

	return(height);
}



/***********************************************************/
/*
 * start from crest and search to either side
 * for halfheight points
 */
static	void set_halfheight_points(gcPeaks *p, int ipeak)
{
	int	i, halfheight;


	/* halfheight threshold = baseline + 1/2 height */

	halfheight = gc_getBaseline(p, ipeak, p->peaks[ipeak].xcrest) + (p->peaks[ipeak].height/2);

	/* search backwards from crest */

	i = p->peaks[ipeak].xcrest;
	while (p->smooth[i] > halfheight) i--;
	p->peaks[ipeak].xhalfheight_up = i;


	/* search forward from crest */

	i = p->peaks[ipeak].xcrest;
	while (p->smooth[i] > halfheight) i++;
	p->peaks[ipeak].xhalfheight_down = i;
}

/***********************************************************/
/*
 * set crest to maximum height rather than level!
 */
static	void set_crest_at_max_height(gcPeaks *p, int ipeak)
{
	int	xstart, xcrest, xend;
	int	max_height_bunch;
	float	max_height, height;
	int	i;

	xcrest = p->peaks[ipeak].xcrest;
	xstart = p->peaks[ipeak].xstart;
	xend   = p->peaks[ipeak].xend;

	max_height = p->smooth[xcrest] - gc_getBaseline(p, ipeak, xcrest);
	max_height_bunch = xcrest;

	for (i = xstart; i<=xend; i++) {
		height = p->smooth[i] - gc_getBaseline(p, ipeak, i);
		if (height > max_height) {
			max_height = height;
			max_height_bunch = i;
		}
	}

	p->peaks[ipeak].xcrest = max_height_bunch;
}


/***********************************************************/
static float mean_float_level(gcPeaks *p, int ibunch, int halfwidth)
{
	int	i;
	float	mean;

	mean = 0;
	for (i = ibunch - halfwidth; i <= ibunch + halfwidth; i++)
		mean += (float) p->smooth[i];

	mean /= (float) (2*halfwidth + 1);

	return(mean);
}
