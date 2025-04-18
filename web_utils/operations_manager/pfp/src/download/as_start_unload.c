/* Put flask unit into unload mode with a simple call to unload ready. This opens the outlet valve in preperation 
  for the first sample. This routine is neccesary only for Version 0 of the sample unit (outlet valve eliminated
  in Version 2 and above).*/
  
/* Revisions:
	27 Feb 1993	new versions of as control routines use analysis_exit for error trapping.
	 2 Oct 1995	updated for new version of as_comm
*/
	
#include "as_comm.h"


main()
{
  int as_eid;

  as_eid = open_as_comm();
  goto_UNLOAD_mode( as_eid );
  close( as_eid );
}
