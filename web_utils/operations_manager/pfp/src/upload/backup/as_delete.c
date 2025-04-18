#include "as_comm3.h"
#include "as_comm3.c"


int main()

{
  char reply[maxline];
  static char checkstr[maxline];
 
  int as_eid, check=1,chk2=0, ok=0, n;
      
  as_eid = open_as_comm();
  goto_AS_mode(as_eid);
  n=delete_samples(as_eid);
  /*printf("%d\n", n);*/
  if (n==0)
    {
      printf("All OK!\n");
      return ok;
    }
  else
    {
      printf("!  delete sample failed.\n");
      return -1;
    }
}     
