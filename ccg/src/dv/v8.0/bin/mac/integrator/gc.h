#ifndef _GC
#define _GC

#ifndef _NO_PROTO
#if    !(defined(__STDC__) && __STDC__) \
    && !defined(__cplusplus) && !defined(c_plusplus) \
    && !defined(FUNCPROTO) 
#define _NO_PROTO
#endif /* __STDC__ */
#endif /* _NO_PROTO */

#include <stdio.h>
#include <time.h>

/*============================================================
 * Definitions
 *==========================================================*/

#define MAX_POINTS	20000
#define MAX_CHANNELS	8
#define	MAX_QC		10

#define	UNKNOWN_FILE	0
#define GC_FILE		1
#define	ITX_FILE	2
#define	ARCHIVE_FILE	3
#define TEXT_FILE	4
#define ZIP_FILE	5

#define MAX_TIMECODES	200
#define MAX_SEGMENTS	200
#define MAX_CURVE_POINTS		50
#define MAX_PEAKS	200

#define NOT_ARCHIVE	0	/* file test return value */
#define ARCHIVE		1	/* file test return value for archive file */

/* GC error numbers */
/* (for future use */

#define GC_NO_DATA_POINTS	1

/* The following are baseline options that can
 * take a 0 or 1 value.
 * For use in PeakStruct start_options, end_options
 */

#define BI	(1L<<0)		/* Baseline inhibit */
#define VV	(1L<<1)		/* Valley to Valley */
#define FH	(1L<<2)		/* Force horizontal baseline ??????*/
#define BH	(1L<<3)		/* Baseline horizontal */
#define CF	(1L<<4)		/* Curve fit */
#define NB	(1L<<5)		/* No baseline */
#define FB	(1L<<6)		/* Force baseline, otherwise fused */
#define NT	(1L<<7)		/* No tangent */
#define FT	(1L<<8)		/* Force tangent */
#define NR	(1L<<9)		/* No rider */
#define FR	(1L<<10)	/* Force rider */
#define NF	(1L<<11)	/* No fused peaks */
#define NS	(1L<<12)	/* No shoulder peaks */
#define CB	(1L<<13)	/* Curved baseline point */

/* The following are baseline options that can
 * take any value.  Keep these exclusive of 
 * above values.
 */

#define PW	(1L<<20)	/* Peak width */
#define PT	(1L<<21)	/* Peak threshold */
#define BS	(1L<<22)	/* Baseline start */
#define BE	(1L<<23)	/* Baseline end */
#define CT	(1L<<24)	/* Curve fit type */
#define SF	(1L<<25)	/* Smoothing factor */
#define OS	(1L<<26)	/* One sided smoothing to determine baseline level */

/* Baseline codes */
/* For use in PeakStruct bc_start, bc_end */

#define RESOLVED	(1L<<0)
#define TANGENT		(1L<<1) 	/* peak end by tangent_fit_test() */
#define FORCED		(1L<<2) 	/* by Integration Inhibit */
#define FUSED		(1L<<3)
#define VALLEY_POINT	(1L<<4)
#define PENETRATED	(1L<<5)
#define SHOULDER_POINT	(1L<<6) 	/* fused point by shoulder test */
#define RIDER		(1L<<7) 	/* on start, peak is rider */
#define MOUSE		(1L<<8) 	/* start or end modified by mouse */
#define HORIZONTAL	(1L<<9) 	/* horizontal to match other true end */
#define SHOULDER_CREST	(1L<<10) 	/* on start, peak is rear shoulder */
					/* on end, peak is front shoulder */
#define SKEWED		(1L<<11) 	/* on start, front skewed */
					/* on end, peak is tailing */
					/* (for future use) */



/*============================================================
 * Macros 
 *==========================================================*/

/* * IDIVIDE: integer divide with rounding */

#define	IDIVIDE(w, d)		( (int) ( ( (float) w + (float) d/2 ) / d) )

#define	BASELINE_WIDTH(w)	IDIVIDE(w, 4)
#define	HALF_BASELINE_WIDTH(w)	IDIVIDE(w, 8)

#define BASELINEWIDTH(t)     ((int) (getBC(t, PW) * p->sample_rate)/4)
#define HALFBASELINEWIDTH(t) ((int) (getBC(t, PW) * p->sample_rate)/8)

/*============================================================
 * Structure definitions 
 *==========================================================*/
typedef struct {
	short	year;
	short	month;
	short	day;
	short	hour;
	short	minute;
	short	second;
	short	is_gmt;
	short	port;
	float	sample_rate;
	short	nchannels;
	short	npoints;
	long	data[MAX_CHANNELS][MAX_POINTS];
} chromatogram;

typedef struct {
	int	type;
	int	start;
	float	value;
} timeFunction;

typedef	struct {

	int		slope;		/* -1, 0, +1 */

	int		start_bunch;
	int		end_bunch;
	int		length;		/* just for convience */

	int		max_level;
	int		min_level;

	int		slope2pt;

	/*
	 * these indicate change of state (on to off, off to on)
	 * of these baseline bits within the segment
	 */
	int		bi;		/* baseline inhibit */
	int		bs;		/* baseline force start */
	int		be;		/* baseline force end */

} Peak_segment;

typedef struct	{
	short	xstart;
	short	xend;
	short	xcrest;			/* bunch at peak max */

	short	xhalfheight_up;		/* bunch at halfheight comming up */
	short	xhalfheight_down;	/* bunch at halfheight going down */

	short	xstartwidth;		/* baseline widths */
	short	xendwidth;

	short	parent_index;		/* -1 if not a rider peak */


	long	start_level;
	long	end_level;

	float	area;
	float	height;

	int     bc_start;
	int	bc_end;

	int	start_options;
	int	end_options;

	float		a, b, c, d;

	char	bcode[14];
	char	name[12];	/* from Peaks_id() */
} PeakStruct;

typedef struct {
	long		*detrend;
	long		*smooth;
	float 		*slope;
	long 		*bfit;
	int		npoints;
	float		sample_rate;
	int		npeaks;
	int		n;
	long		x[MAX_CURVE_POINTS];
	long		y[MAX_CURVE_POINTS];
	PeakStruct      peaks[MAX_PEAKS];
} gcPeaks;

extern int gc_errno;

/*============================================================
 * Function prototypes
 *==========================================================*/

int gc_NextArchiveFile(FILE *fp);
FILE *gc_OpenArchive (char *name);
void gc_Free(gcPeaks *p);
int gc_GetArchiveList (char *archive, char *p[], int *num);
int gc_RetrieveFile(char *datadir, char *datestr, chromatogram *run, char *ext);
char *gc_ArchiveName(char *file);
char *gc_SetFileNameFromRun(chromatogram run, int filetype);
char *gc_SetDateStringFromRun(chromatogram run);
int gc_FileType (char *filename);
void asscanf (char *line, long *d, int n);
int gc_ReadFile (FILE *fp, chromatogram *run, int filetype);
int gc_WriteFile (FILE *fp, chromatogram *run);
char *gc_SearchArchive(char *archive, char *datestr, int comp_type);
int gc_file_type(FILE *fp);
FILE *gc_OpenFile(char *archive, char *file);
char *gc_SetFileDateString(int year, int month,int  day, int hour, int sample);
char *gc_GetPeakIDFile(char *datestr);
char *gc_GetTimeFile(char *datestr, int channel);
void gc_SetDataDir (char *dir);
float getBC (int t, int code);
float gc_getBaseline(gcPeaks *p, int ipeak, int t);
gcPeaks *gc_integrate(long *data, int npoints, float sample_rate, char *timefile);
void gc_id(gcPeaks *p, char *idfile, int nchannel);


#endif /* _GC */
 /* DON'T ADD STUFF AFTER THIS #endif */
