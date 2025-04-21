

/* Convert a binary chromatogram file from hp format to linux binary format */
/* This is, swap bytes */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

/**********************************************************/
int main(int argc, char **argv)
{
	int	id, id2, i, np;
short n;
short *p;
long *p2;
	float f;
	char s[200];
	char s2[200];

        id = open (argv[1], O_RDONLY);
        id2 = open ("test.gc", O_RDWR | O_CREAT, 0644);


	/* year */
	for (i=0; i<8; i++) {
		read (id, s, sizeof(short));
		s2[0] = s[1];
		s2[1] = s[0];
		write (id2, s2, 2);
p = (short *) s2;
	}

	read (id, s, sizeof(float));
	s2[0] = s[3];
	s2[1] = s[2];
	s2[2] = s[1];
	s2[3] = s[0];
	write (id2, s2, sizeof(float));
	
	for (i=0; i<2; i++) {
		read (id, s, sizeof(short));
		s2[0] = s[1];
		s2[1] = s[0];
		write (id2, s2, 2);
	}

p = (short *) s2;
np = (int) *p;

	for (i=0; i<np; i++) {
		read (id, s, sizeof(long));
		s2[0] = s[3];
		s2[1] = s[2];
		s2[2] = s[1];
		s2[3] = s[0];
		write (id2, s2, 4);
	}

close(id2);
}
