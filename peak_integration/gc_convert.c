#include "peaks.h"
#include "gc.h"

void gc_convert(gcPeaks *p)
{
	int i, a;


	p->npeaks = Npeaks;
	for (i=0; i<Npeaks; i++) {

		p->peaks[i].xstart = Peaks[i].xstart;
		p->peaks[i].xend = Peaks[i].xend;
		p->peaks[i].xcrest = Peaks[i].xcrest;
		p->peaks[i].xhalfheight_up = Peaks[i].xhalfheight_up;
		p->peaks[i].xhalfheight_down = Peaks[i].xhalfheight_down;
		p->peaks[i].xstartwidth = Peaks[i].xstartwidth;
		p->peaks[i].xendwidth = Peaks[i].xendwidth;
		p->peaks[i].parent_index = Peaks[i].parent_index;
		p->peaks[i].start_level = Peaks[i].start_level;
		p->peaks[i].end_level = Peaks[i].end_level;

		a=0;
		if (Peaks[i].start.resolved) a = a | RESOLVED;
		if (Peaks[i].start.tangent) a = a | TANGENT;
		if (Peaks[i].start.forced) a = a | FORCED;
		if (Peaks[i].start.fused) a = a | FUSED;
		if (Peaks[i].start.valley_point) a = a | VALLEY_POINT;
		if (Peaks[i].start.penetrated) a = a | PENETRATED;
		if (Peaks[i].start.shoulder_point) a = a | SHOULDER_POINT;
		if (Peaks[i].start.rider) a = a | RIDER;
		if (Peaks[i].start.mouse) a = a | MOUSE;
		if (Peaks[i].start.horizontal) a = a | HORIZONTAL;
		if (Peaks[i].start.shoulder_crest) a = a | SHOULDER_CREST;
		if (Peaks[i].start.skewed) a = a | SKEWED;

		p->peaks[i].bc_start = a;

		a=0;
		if (Peaks[i].end.resolved) a = a | RESOLVED;
		if (Peaks[i].end.tangent) a = a | TANGENT;
		if (Peaks[i].end.forced) a = a | FORCED;
		if (Peaks[i].end.fused) a = a | FUSED;
		if (Peaks[i].end.valley_point) a = a | VALLEY_POINT;
		if (Peaks[i].end.penetrated) a = a | PENETRATED;
		if (Peaks[i].end.shoulder_point) a = a | SHOULDER_POINT;
		if (Peaks[i].end.rider) a = a | RIDER;
		if (Peaks[i].end.mouse) a = a | MOUSE;
		if (Peaks[i].end.horizontal) a = a | HORIZONTAL;
		if (Peaks[i].end.shoulder_crest) a = a | SHOULDER_CREST;
		if (Peaks[i].end.skewed) a = a | SKEWED;

		p->peaks[i].bc_end = a;

		a = 0;
		if (Peaks[i].start_options.bi) a |= BI;
		if (Peaks[i].start_options.vv) a |= VV;
		if (Peaks[i].start_options.fh) a |= FH;
		if (Peaks[i].start_options.bh) a |= BH;
		if (Peaks[i].start_options.cf) a |= CF;
		if (Peaks[i].start_options.nb) a |= NB;
		if (Peaks[i].start_options.fb) a |= FB;
		if (Peaks[i].start_options.nt) a |= NT;
		if (Peaks[i].start_options.ft) a |= FT;
		if (Peaks[i].start_options.nr) a |= NR;
		if (Peaks[i].start_options.fr) a |= FR;
		if (Peaks[i].start_options.nf) a |= NF;
		if (Peaks[i].start_options.ns) a |= NS;

		p->peaks[i].start_options = a;

		a = 0;
		if (Peaks[i].end_options.bi) a |= BI;
		if (Peaks[i].end_options.vv) a |= VV;
		if (Peaks[i].end_options.fh) a |= FH;
		if (Peaks[i].end_options.bh) a |= BH;
		if (Peaks[i].end_options.cf) a |= CF;
		if (Peaks[i].end_options.nb) a |= NB;
		if (Peaks[i].end_options.fb) a |= FB;
		if (Peaks[i].end_options.nt) a |= NT;
		if (Peaks[i].end_options.ft) a |= FT;
		if (Peaks[i].end_options.nr) a |= NR;
		if (Peaks[i].end_options.fr) a |= FR;
		if (Peaks[i].end_options.nf) a |= NF;
		if (Peaks[i].end_options.ns) a |= NS;

		p->peaks[i].end_options = a;
	}
}



