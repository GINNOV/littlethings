               char *file, long line);		/* mwcontrol.c	*/
char *	MWGetCWD (char *path, int size, char *file, long line);		/* mwgetcwd.c	*/
char *	MWGetEnv (const char *name, char *file, long line);		/* mwgetenv.c	*/
char *	MWStrDup (const char *str, char *file, long line);		/* mwstrdup.c	*/
int	MWCheckA (struct MWAlc *mwa);		/* mwcontrol.c	*/
int	_STI_240_MWInit (void);		/* mwcontrol.c	*/
static void	MWClose (void);		/* mwcontrol.c	*/
void	MWCheck (void);		/* mwcontrol.c	*/
void	MWFreeMem (void *mem, long size, long internal,
void	MWHold (void);		/* mwcontrol.c	*/
void	MWInit (BPTR dbfh, LONG flags, char *dbnm);		/* mwcontrol.c	*/
void	MWLimit (LONG chiplim, LONG fastlim);		/* mwcontrol.c	*/
void	MWPrintf (char *ctl, ...);		/* mwcontrol.c	*/
void	MWPurge (void);		/* mwcontrol.c	*/
void	MWReport (char *title, long level);		/* mwreport.c	*/
void	MWTerm (void);		/* mwcontrol.c	*/
void	_STD_240_MWTerm (void);		/* mwcontrol.c	*/
void *	MWAllocMem (long size, long flags, long internal, char *file, long line);		/* mwcontrol.c	*/
void *	MWrealloc (void *mem, long size, char *file, long line);		/* mwcontrol.c	*/
