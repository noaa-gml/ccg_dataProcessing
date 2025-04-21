
/*
 *
 * (c) Copyright 1993 Peter Salameh, University of California, San Diego.
 *
 *     See SOURCE.NOTICE file for information on use of this source code.
 * 
 */

/*
 * peaks.h 
 */

#ifndef	PEAKS_INCLUDE
#define	PEAKS_INCLUDE

#define	MAXPEAKS	100

/*
 * Some flags follow
 * (extern because initialized in peaksintegrate.c)
 */
extern	int	ManualIntegration;
extern	int	SlopeCalcOnly;
extern	int	SmoothOnly;
extern	int	CurvedBaseline;
extern	int	StoreBaselines;

/* defined in peakslope.c */

extern 	int	SmoothingType;
extern	float	SmoothFactor;


#define	TIME_FROM_BUNCH(i)	( ((float) i)/Peaks_header.hz - Peaks_header.inject_time_offset )
#define BUNCH_FROM_TIME(i)	 ( (int) ((i + Peaks_header.inject_time_offset)*Peaks_header.hz) )


/*
 * For MinSmooth 3:
 * 	Pw = MinPw = 10*5, (Pw+10)/20 = 3, with Nsmooth = Pw/20
 * 	Pw = MinPw = 5*5, (Pw+3)/10 = 3, with Nsmooth = Pw/10
 */
#define	MinPw		25			/* 5 sec at 5 Hz */
#define	MinSmooth	3			/* enforced in Peaks_smooth() */


/*
 * IDIVIDE: integer divide with rounding
 */
#define	IDIVIDE(w, d)		( (int) ( ( (float) w + (float) d/2 ) / d) )


/*
 * Useful macros below
 */
#define	BASELINE_WIDTH(w)	IDIVIDE(w, 4)
#define	HALF_BASELINE_WIDTH(w)	IDIVIDE(w, 8)

#define	PEAKHEIGHT(i)		(Bunch[Peaks[i].xcrest] - Bunch[Peaks[i].xstart])
#define	PEAKHALFHEIGHT(i)	((Bunch[Peaks[i].xcrest] + Bunch[Peaks[i].xstart])/2)

#define	PEAKWIDTH1(i)		(Peaks[i].xcrest - Peaks[i].xhalfheight_up)
#define	PEAKWIDTH2(i)		(Peaks[i].xhalfheight_down - Peaks[i].xcrest)

#define	CREST_TO_FUSED(i,j)	(Peaks[j].xstart - Peaks[i].xcrest)
#define	HEIGHT_FROM_PARENT(i,j)	(Bunch[Peaks[j].xcrest] - Bunch[Peaks[i].xstart])


/*
 * These macros prevent access to arrays beyond limits
 * (may not be necessary if code only needs to check in limited places)
 */
#define	BUNCHINDEX(i)	( (i<Nbunch) ? ( (i>0) ? i : 0) : Nbunch-1)

#define	BUNCH(i)	*(Bunch + BUNCHINDEX(i))
#define	SLOPEBUNCH(i)	*(SlopeBunch + BUNCHINDEX(i))
#define	SLOPE2BUNCH(i)	*(Slope1 + BUNCHINDEX(i))

#define RUNNING_MEAN	1
#define SAVITZKY_GOLAY	2


int	Npeaks;			/* index of current peak (starts at 0) */
				/* number of peaks after integration complete */

int	Nbunch;			/* number of bunches in chromatogram */

long	*Bunch;			/* points to ReadBunch */

#define MAXBUNCH 20000 		/* 20000 = 4000 seconds at 5 Hz */

long	ReadBunch[MAXBUNCH];
long	SlopeBunch[MAXBUNCH];
float	Slope1[MAXBUNCH];
float	Slope2[MAXBUNCH];

typedef	struct	{
	int	version;
	int	npeaks;
	long	time;
	float	hz;			/* Manual Integration flag here? */
	float	inject_time_offset;	/* reserved here? */

	int	reserved1;
	int	reserved2;
	int	reserved3;
	int	reserved4;

	/* coeffients for curved baseline fit */

	int	baselinefit;		/* flag */
	int	firstbunch;
	double	a;
	double	b;
	double	c;
	double	d;
	double	e;
} BaselineHeader;

BaselineHeader	Peaks_header;


/*
 * Baseline option bits (DEFAULT ALL 0's)
 *
 * These bits set for peak if on at time of peak crest
 * (timefunctions.c ensures mutually exclusive bits not on at the same time)
 *
 * nb = no resolved baseline point (disable resolved baseline test)
 * fb = force resolved baseline point where fused
 *	this appears to only differ from vv in width
 *	of baseline averaged for level
 *
 * nt = disable tangent skimming on tailing peaks
 * ft = force tangent skimming on first peak of fused group
 *
 * fh and bh only apply to "true" baseline points which are:
 * 	- resolved (by resolved test or fb set)
 *	- valley-valley
 *	- penetrated fused
 */
typedef	struct {
	unsigned	bi : 1;		/* baseline inhibit */
	unsigned	bs : 1;		/* baseline force start */
	unsigned	be : 1;		/* baseline force end */

	unsigned	vv : 1;		/* valley - valley (effects start point) */
	unsigned	fh : 1;		/* forward horizontal */
	unsigned	bh : 1;		/* backward horizontal */
	unsigned	cf : 1;		/* curved baseline fit */

	unsigned	nb : 1;		/* no (resolved) baseline, fused only */
	unsigned	fb : 1;		/* force fused baseline point resolved */

	unsigned	nt : 1;		/* disable ending tangent fit */
	unsigned	ft : 1;		/* forced ending tangent fit */

	unsigned	nr : 1;		/* disable rider peak(s) */
	unsigned	fr : 1;		/* forced rider peaks(s) */

	unsigned	nf : 1;		/* no fused peaks, implies ns */
	unsigned	ns : 1;		/* no shoulder peaks */

	/*
	 * reserved bits for future use
	 * (compiler uses an unsigned long (32 bits) for these bitfield structs,
	 * so just reserve so can initialize to zero)
	 */
	unsigned	reserved : 17;
} BaselineBits;


/*
 * baseline codes for peak start and end
 */
typedef struct	{
	/* resolved set for all these */

	unsigned	resolved : 1;
	unsigned	tangent: 1;		/* peak end by tangent_fit_test() */
	unsigned	forced: 1;		/* by Integration Inhibit */

	/* fused set for all these */

	unsigned	fused : 1;
	unsigned	valley_point: 1;
	unsigned	penetrated : 1;
	unsigned	shoulder_point : 1;	/* fused point by shoulder test */

	/* these don't have to do with baseline resolved */

	unsigned	rider : 1;		/* on start, peak is rider */
						/* on end, peak has rider(s) */

	unsigned	mouse : 1;		/* start or end modified by mouse */

	/* other descriptions of how baseline constructed */

	unsigned	horizontal : 1;		/* horizontal to match other true end */

	/* other peak descriptions */

	unsigned	shoulder_crest : 1;	/* on start, peak is rear shoulder */
						/* on end, peak is front shoulder */

	unsigned	skewed : 1;		/* on start, front skewed */
						/* on end, peak is tailing */
						/* (for future use) */

	/*
	 * reserved bits for future use
	 * (compiler uses an unsigned long for these bitfield structs,
	 * so just reserve so can initialize to zero)
	 */
	unsigned	reserved : 20;
} BaselineCodes;


/*
 *
 */
typedef struct	{
	unsigned short	xstart;
	unsigned short	xend;
	unsigned short	xcrest;			/* bunch at peak max */

	unsigned short	xhalfheight_up;		/* bunch at halfheight comming up */
	unsigned short	xhalfheight_down;	/* bunch at halfheight going down */

	unsigned short	xstartwidth;		/* baseline widths */
	unsigned short	xendwidth;

#ifdef __STDC__
	signed short	parent_index;		/* -1 if not a rider peak */
#else
	short	parent_index;		/* -1 if not a rider peak */
#endif


	long	start_level;
	long	end_level;

	float	area;
	float	height;

	float	a;		/* a + b*t */
	float	b;
	float	c;		/* a + b/t + c/t^2 + d/t^3 */
	float	d;

	BaselineCodes	start;
	BaselineCodes	end;

	BaselineBits	start_options;
	BaselineBits	end_options;

	char	name[12];	/* from Peaks_id() */
} BaselineStruct;


BaselineStruct	Peaks[MAXPEAKS];

#endif	/* PEAKS_INCLUDE */
