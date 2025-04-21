/*#define DEBUG */
/*
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gc.h"

static float default_bc(int code);
static int tf_compare(const void *s1, const void *s2);
static int get_code_type(char *code);

timeFunction TimeFunction[MAX_TIMECODES];
int ntf = 0;
	
static int tf_compare();


/************************************************************************/
/*
 * read timefunctions file specified
 * curved baseline skipped for now.
 */
int gc_read_timefile(gcPeaks *ptr, char *file)
{
	FILE	*timefile;
	char	line[512], line1[512];
	char	code[5];
	float	sec, value;
	int	i, type, n;


#ifdef DEBUG
fprintf (stderr, "Time file = %s\n", file);
#endif

	if (file == NULL) return (-1);

	if ( (timefile = fopen(file, "r")) == NULL) {
		fprintf(stderr, "Cannot open integration file: %s\n", file);
		return(-1);
	}

	i=0;
	while (fgets(line1, 512, timefile) != NULL) {
		line[0] = '\0';
		sscanf (line1, "%[^\n#]", line);
		if (strlen(line) <= 1) continue;

#ifdef DEBUG
		fprintf(stderr, "Timefile line: %s\n", line);
#endif

		if (sscanf(line, "%f %s %f", &sec, code, &value) < 3) {
			fprintf(stderr, "bad format in file: %s\n", file);
			continue;
		}

		type = get_code_type (code);
		if (type >= 0) {
			if (sec < 0) sec = 0;
			n = sec * ptr->sample_rate;
			TimeFunction[i].start = n;
			TimeFunction[i].value = value;
			TimeFunction[i].type = type;
			i++;
		}
	}
	fclose(timefile);

	ntf = i;


/* Sort functions to make sure in ascending order */

	qsort ((void *) TimeFunction, (size_t) ntf, sizeof (timeFunction), tf_compare);

#ifdef DEBUG
fprintf (stderr, "Start   Value Type\n");
for (i=0; i<ntf; i++) {
fprintf (stderr, "%4d  %8.2f %2d\n", TimeFunction[i].start, TimeFunction[i].value, TimeFunction[i].type);
}
#endif

	return (0);

}


/**************************************************************/
static int get_code_type(char *code)
{
	if (strcmp (code, "PW")==0) return (PW);
	if (strcmp (code, "PT")==0) return (PT);
	if (strcmp (code, "BI")==0) return (BI);
	if (strcmp (code, "BS")==0) return (BS);
	if (strcmp (code, "BE")==0) return (BE);
	if (strcmp (code, "VV")==0) return (VV);
	if (strcmp (code, "FH")==0) return (FH);
	if (strcmp (code, "BH")==0) return (BH);
	if (strcmp (code, "CF")==0) return (CF);
	if (strcmp (code, "NB")==0) return (NB);
	if (strcmp (code, "FB")==0) return (FB);
	if (strcmp (code, "NT")==0) return (NT);
	if (strcmp (code, "FT")==0) return (FT);
	if (strcmp (code, "NR")==0) return (NR);
	if (strcmp (code, "FR")==0) return (FR);
	if (strcmp (code, "NF")==0) return (NF);
	if (strcmp (code, "NS")==0) return (NS);
	if (strcmp (code, "CB")==0) return (CB);
	if (strcmp (code, "CT")==0) return (CT);
	if (strcmp (code, "SF")==0) return (SF);
	if (strcmp (code, "OS")==0) return (OS);

	return (-1);
}

/**************************************************************/
static int tf_compare(const void *s1, const void *s2)
{
	timeFunction *t1 = (timeFunction *) s1;
	timeFunction *t2 = (timeFunction *) s2;


	if (t1->start <  t2->start) return (-1);
	if (t1->start == t2->start) return (0);
	if (t1->start >  t2->start) return (1);

	return (0);
}

/****************************************************************/
/*
float getBC (t, code)
int t;
int code;
{
	int i;
	float val;

	val = default_bc(code);

	for (i=0; i<ntf; i++) {
		if (TimeFunction[i].type != code) continue;

		if (t >= TimeFunction[i].start){
			val = TimeFunction[i].value;
		}

		if (t < TimeFunction[i].start) break;
	}

	return (val);
}
*/

/****************************************************************/
/* Return the value of baseline code at time t */
float getBC (int t, int code)
{
	int i;

	for (i=ntf-1; i>=0; i--) {
		if (TimeFunction[i].type != code) continue;


		if (t >= TimeFunction[i].start){
			return (TimeFunction[i].value);
		}
	}

	return (default_bc(code));
}

/**************************************************************/
/* return default basline code values.
 * Most are 0, so check only for those with non-zero default.
 */
static float default_bc(int code)
{
	if (code == PW) return (5);
	if (code == PT) return (500);
	if (code == SF) return (0.6);

	return (0);
}
