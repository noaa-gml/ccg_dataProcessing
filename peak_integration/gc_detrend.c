/*#define DEBUG */

#include "gc.h"

/*
	for (i=0; i<npoints; i++) {
		if (i < (int) ptr->x[0]) 
			ptr->detrend[i] = data[i];
		else if (i >= ptr->x[ptr->n - 1])
			ptr->detrend[i] = data[i] - ptr->bfit[ptr->x[ptr->n - 1]] + ptr->y[0];
		else
			ptr->detrend[i] = data[i] - ptr->bfit[i] + ptr->y[0];
	}

*/

/******************************************************************/
void gc_detrend (long *data, int npoints, gcPeaks *p)
{
	int i, first_bfit, first_nobfit;
	long y1, y2, diff, offset;

/*
 * In order not to have discontinuities in the chromatogram after
 * detrending, need to apply the appropriate offsets based on any
 * previous sections that did have a baseline fit.
 * For sections where there was no baseline fitting,
 * the detrended data is the data point minus the value of the last 
 * baseline fit point from the previous section, plus the value
 * of the first baseline fit point from the previous section.
 * For sections with baseline fitting, the detrended data is that 
 * data point minus the fit value, plus the value of the first
 * baseline fit for that section.
 */

	y1 = 0;
	y2 = 0;
	first_bfit = 1;
	first_nobfit = 0;
	diff = 0;
	offset = 0;
	for (i=0; i<npoints; i++) {
		if (p->bfit[i] < 0) {
			if (first_nobfit) {
				offset += diff;
				first_nobfit = 0;
			}
			p->detrend[i] = data[i] - offset;   /* y1 + y2; */
			first_bfit = 1;
		} else {
			if (first_bfit) {
				y2 = p->bfit[i];
				first_bfit = 0;
			}
			p->detrend[i] = data[i] - p->bfit[i] + y2 - offset;
			diff = p->bfit[i] - y2;
			first_nobfit = 1;
		}
	}
}
