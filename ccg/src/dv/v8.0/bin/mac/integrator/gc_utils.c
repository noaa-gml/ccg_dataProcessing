#include "gc.h"


/***********************************************************/
/*
 * Calculate baseline level for peak and bunch
 * (Define macro in peaks.h so ibunch cast to int?)
 *
 * "peaks.h" flag CurvedBaseline tells baseline calc
 * whether to include curved fit or not (if present)
 */
float gc_getBaseline(gcPeaks *p, int ipeak, int t)
{
	double	x;
	double	level;

	x = (double) t;
	level = 0;

	if (!p->peaks[ipeak].c && !p->peaks[ipeak].d) {
		level = (double) p->peaks[ipeak].a + x * (double) p->peaks[ipeak].b;
	} else {
		level  = (double) p->peaks[ipeak].a;
		level += (double) p->peaks[ipeak].b/x;
		level += (double) p->peaks[ipeak].c/(x*x);
		level += (double) p->peaks[ipeak].d/(x*x*x);
	}

	return( (float) level );
}

