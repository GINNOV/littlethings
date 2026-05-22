#ifndef	__STARTUP_H__
#define	__STARTUP_H__

/*********************************************************************/

struct CTDT
{
	int	(*fp)(void);
	long	priority;
};

struct HunkSegment
{
	unsigned int Size;
	struct HunkSegment *Next;
};

/*********************************************************************/

extern CONST struct CTDT	__ctdtlist[];

/*********************************************************************/

ULONG SAVEDS RunConstructors(struct MyLibrary *LibBase);
VOID SAVEDS RunDestructors(struct MyLibrary *LibBase);

/*********************************************************************/

#endif	/* __STARTUP_H__ */
