/* Send a quit command to the flask unit to get it out of unload mode and shut the manifold valve. This program
  is maintained for compatiblity with Version 0 flask unit (Version 2 and above do not have a manifold valve). */

/* Revisions:
	28 Feb 1993	use new version of as_comm.h, with routines that trap their own errors through analysis_exit
	 2 Oct 1995	for use with new version of as_comm
*/


#include "as_comm.h"

main()
{
  int as_eid;
  char ignore_s[128];

  as_eid = open_as_comm();
  send_as_msg( as_eid, quit_command );
  get_as_msg( as_eid, ignore_s );

  close( as_eid );
}
