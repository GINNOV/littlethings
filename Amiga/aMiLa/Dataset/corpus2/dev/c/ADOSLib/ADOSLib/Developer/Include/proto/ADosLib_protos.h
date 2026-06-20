BOOL	CheckProzessor ();		/* CheckProcessor.c	*/
BOOL	CheckSetPatchVersion (struct ExecBase *SysBase, UWORD version, UWORD revision);		/* CheckSetPatchVersion.c	*/
char *	getcwd (char *path, int size);		/* getcwd.c	*/
int	cmp (char **a, char **b);		/* cmp.c	*/
int	setenv (char *name, char *value);		/* setenv.c	*/
int	SystemErrNil (char *com);		/* SystemErrNil.c	*/
int	unlink (char *name);		/* unlink.c	*/
void	GetCurrentPath (register char *path);		/* GetCurrentPath.c	*/
void	GetProgramPath (register char *path);		/* GetProgramPath.c	*/
void	makedir (UBYTE *file);		/* makedir.c	*/
void	putenv (char *s);		/* putenv.c	*/
