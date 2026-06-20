/* GNU conform ReadArgs wrapper */
/* © Stefan Haubenthal 2005/06 */

#ifndef _GETOPT_H_
#define _GETOPT_H_

extern char *optarg;
extern int optind;
struct option
{
  const char *name;
  int has_arg;
  int *flag;
  int val;
};
extern int getopt_long(int argc, char * const argv[], const char *shortopts,
		       const struct option *longopts, int *longind);
enum {no_argument, required_argument, optional_argument};

#endif
