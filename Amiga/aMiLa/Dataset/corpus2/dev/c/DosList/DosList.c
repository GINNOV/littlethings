/***********************************************************************************/
/*                                                                                 */
/* This is meant to be just a didactic example for who want to know to get device, */
/* volume or assign names, but it can be used for any thing you want.              */
/*                                                                                 */
/* No limitations. Really!                                                         */
/*                                                                                 */
/* Author: Michele Locati                                                          */
/* EMail : mlocati@rocketmail.com                                                  */
/* Date  : 17/10/97 (friday!)                                                      */
/*                                                                                 */
/***********************************************************************************/
/***********************************************************************************/
/*                                                                                 */
/* Compiled with Dice v3.20 (1.6.96) for Amigas with 2.0+                          */
/*                                                                                 */
/***********************************************************************************/

#include <stdio.h>
#include <string.h>
#include <clib/dos_protos.h>
#include <dos/dosextens.h>

BOOL GetDosList(void);
void FreeDosList(void);
STRPTR BCPL2STRPTR(BSTR s);

typedef struct
{
	STRPTR	Name;
	STRPTR	Drive;
} Volume;

typedef struct
{
	STRPTR	Name;
	STRPTR	Path;
} Assign;

Volume *Volumes;
Assign *Assigns;
STRPTR *Devices;
int NumVolumes, NumAssigns, NumDevices;
char strtmp[256];

/* wbmain() is called when starting from Workbench*/
int wbmain(void)
{
	return(main());
}

int main(void)
{
	int i;
	
	GetDosList();

	printf("Assigns: %d\n", NumAssigns);
	for (i=0; i<NumAssigns; i++)
		printf("\t%s:\t%s\n", Assigns[i].Name, Assigns[i].Path);
	
	printf("\nVolumes: %d\n", NumVolumes);
	for (i=0; i<NumVolumes; i++)
		printf("\t%s:\t%s\n", Volumes[i].Drive, Volumes[i].Name);

	printf("\nDevices: %d\n", NumDevices);
	for (i=0; i<NumDevices; i++)
		printf("\t%s\n", Devices[i]);

	FreeDosList();

	return(0);
}

BOOL GetDosList(void)
{
	struct DosList *dl;
	int i;

	
	printf("Getting assigns...\n");
	NumAssigns=0;
	dl=LockDosList(LDF_ASSIGNS | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_ASSIGNS))
		NumAssigns++;
	UnLockDosList(LDF_ASSIGNS | LDF_READ);
	Assigns=(Assign *)malloc(NumAssigns * sizeof(Assign));
	i=0;
	dl=LockDosList(LDF_ASSIGNS | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_ASSIGNS))
	{
		Assigns[i].Name=BCPL2STRPTR(dl->dol_Name);
		NameFromLock(dl->dol_Lock, strtmp, 255);
		Assigns[i].Path=strdup(strtmp);
		i++;
	}
	UnLockDosList(LDF_ASSIGNS | LDF_READ);


	printf("Getting volumes...\n");
	NumVolumes=0;
	dl=LockDosList(LDF_VOLUMES | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_VOLUMES))
		NumVolumes++;
	UnLockDosList(LDF_VOLUMES | LDF_READ);
	Volumes=(Volume *)malloc(NumVolumes * sizeof(Volume));
	i=0;
	dl=LockDosList(LDF_VOLUMES | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_VOLUMES))
	{
		Volumes[i].Drive=strdup(((struct Task *)dl->dol_Task->mp_SigTask)->tc_Node.ln_Name);
		Volumes[i++].Name=BCPL2STRPTR(dl->dol_Name);
	}
	UnLockDosList(LDF_VOLUMES | LDF_READ);


	printf("Getting devices...\n");
	NumDevices=0;
	dl=LockDosList(LDF_DEVICES | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_DEVICES))
		NumDevices++;
	UnLockDosList(LDF_DEVICES | LDF_READ);
	Devices=(STRPTR *)malloc(NumDevices * sizeof(STRPTR));
	i=0;
	dl=LockDosList(LDF_DEVICES | LDF_READ);
	while (dl=NextDosEntry(dl, LDF_DEVICES))
		Devices[i++]=BCPL2STRPTR(dl->dol_Name);
	UnLockDosList(LDF_DEVICES | LDF_READ);
}

STRPTR BCPL2STRPTR(BSTR s)
{
	STRPTR ris;
	STRPTR eq;
	
	if (!s)
		return(NULL);
	eq=(STRPTR)BADDR(s);
	if (!eq[0])
		return(NULL);
	ris=(STRPTR)malloc(eq[0] + 1);
	memcpy(ris, eq + 1, eq[0]);
	ris[eq[0]]=0;
	return(ris);
}

void FreeDosList(void)
{
	int i;

	
	printf("Freeing assigns...");
	for (i=0; i<NumAssigns; i++)
	{
		free(Assigns[i].Name);
		free(Assigns[i].Path);
	}
	free(Assigns);
	NumAssigns=0;


	printf("\nFreeing volumes...\n");
	for (i=0; i<NumVolumes; i++)
	{
		free(Volumes[i].Drive);
		free(Volumes[i].Name);
	}
	free(Volumes);
	NumVolumes=0;

	
	printf("Freeing devices...\n");
	for (i=0; i<NumDevices; i++)
		free(Devices[i]);
	free(Devices);
	NumDevices=0;
}
