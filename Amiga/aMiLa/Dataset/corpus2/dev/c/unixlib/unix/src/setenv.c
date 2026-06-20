#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <dos/var.h>
#include <proto/dos.h>

/*
 * setenv --
 *	Set the value of the local variable "name" to be "value".
 *	If rewrite is set, replace any current value.
 */
int
setenv(const char *name, const char *value, int rewrite)
{
	char buf[32];
	int ret = 0;
	int len = strlen(name);
	char *tname = malloc(len+1);

	strcpy(tname, name);
	if (tname[len-1] == '=')		/* get rid of `=' in name  */
		tname[len-1] = 0;
	if (*value == '=')			/* get rid of `=' in value */
		++value;
	len = strlen(value);
	if (GetVar(tname, buf, sizeof(buf), LV_VAR) < 0) /* if doesn't exists */
		rewrite = 1;				 /* set unconditional */
	if (rewrite && !SetVar(tname, value, len, GVF_LOCAL_ONLY)) {
		errno = ENOMEM;
		ret = -1;
	}
	free(tname);
	return(ret);
}

/*
 * unsetenv(name) --
 *	Delete environmental variable "name".
 */
void
unsetenv(const char *name)
{
	DeleteVar(name, GVF_LOCAL_ONLY);
}
