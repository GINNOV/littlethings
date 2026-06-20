#ifndef _GRP_H
#define _GRP_H

struct group {
  char *gr_name;		/* name of the group */
  char *gr_passwd;		/* encrypted password of the group */
  gid_t gr_gid;			/* numerical group ID */
  char **gr_mem;		/* null-terminated array of pointers to the
				   individual member names */
};

#endif
