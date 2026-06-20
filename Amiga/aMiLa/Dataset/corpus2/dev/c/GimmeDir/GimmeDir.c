/* routines for reading directory contents	*/
/* ---------------------------------------	*/

/* For instructions:									*/
/* - read comments in this listing				*/
/* - look at example program						*/
/* - read autodocs at dos.library/ExAll		*/
/* - look at includes dos/exall.h				*/

/* MINIMUM REQUIRED: AmigaOS 2.0					*/
/* by Daniel Mealha Cabrita (dancab@polbox.com)	 19th june, 1998	*/

/* THIS SOURCE CAN FREELY DISTRIBUTED AND USED BY PERSONALS						*/
/* THE ONLY COMERCIAL PRODUCT ALLOWED TO DISTRIBUTE IS THE AMINET CDs		*/
/* other commercial-related interests about distributing it, contact			*/
/* the author first.																			*/

#include <clib/dos_protos.h>
#include <dos/exall.h>
#include <clib/exec_protos.h>

/* directory buffer size in bytes	*/
/* less than 4kb is not a good idea, more makes almost no difference	*/
#define TamBuf 4096

struct tGimmeDir {
	BPTR MeuLock;
	struct ExAllControl *MeuDosObj;
	BOOL Continuar;
	struct ExAllData *pMeuBuff;
	struct ExAllData *OndeEsta;
	long Tipo;
	char MatChave[514];
	};

struct tGimmeDir *InitGimmeDir (char *DirName, long oTipo, char *aChave);
void EndGimmeDir (struct tGimmeDir *pGimmeDir);
void EndGimmeDir39 (struct tGimmeDir *pGimmeDir);
struct ExAllData *GimmeDir (struct tGimmeDir *pGimmeDir);

/* initialize things...	given:												*/
/* DirName	- name of directory (eg.: "dh1:Test")						*/
/* oTipo		- type of listing (ED_NAME, ED_TYPE, ED_SIZE...etc)	*/
/* aChave	- match string (eg.: "#?.lha") or 0L (same as #?)		*/
/* RETURNS pointer you should keep											*/
struct tGimmeDir *InitGimmeDir (char *DirName, long oTipo, char *aChave)
{
	struct tGimmeDir *pGimmeDir;
	
	if (pGimmeDir = AllocVec (sizeof (tGimmeDir), 0L))
	{
		if (pGimmeDir->pMeuBuff = AllocVec (TamBuf, 0L))
		{
			if (pGimmeDir->MeuLock = Lock(DirName, ACCESS_READ))
			{
				if (pGimmeDir->MeuDosObj = AllocDosObject (DOS_EXALLCONTROL, NULL));
				{
					if (aChave)
					{
						ParsePatternNoCase (aChave, &pGimmeDir->MatChave[0], 514);
						pGimmeDir->MeuDosObj->eac_MatchString = &pGimmeDir->MatChave[0];
					}
					else
					{
						pGimmeDir->MeuDosObj->eac_MatchString = NULL;
					}
					pGimmeDir->MeuDosObj->eac_LastKey = 0;
					pGimmeDir->MeuDosObj->eac_MatchFunc = NULL;	
					pGimmeDir->Tipo = oTipo;

					pGimmeDir->Continuar = ExAll (pGimmeDir->MeuLock, pGimmeDir->pMeuBuff, TamBuf, oTipo, pGimmeDir->MeuDosObj);
					if (pGimmeDir->MeuDosObj->eac_Entries)
						pGimmeDir->OndeEsta = pGimmeDir->pMeuBuff;
					else
						pGimmeDir->OndeEsta = NULL;

					return (pGimmeDir);
				}		
				FreeDosObject (DOS_EXALLCONTROL, pGimmeDir->MeuDosObj);
			}
			UnLock (pGimmeDir->MeuLock);
		}
		FreeVec (pGimmeDir->pMeuBuff);
	}
	FreeVec (pGimmeDir);
	return(0);
}

/* finishes the job.. frees all the stuff previosly allocated given:	*/
/* struct tGimmeDir * --- the POINTER given to you previously			*/
/* This can be called before you finishing reading all the files.		*/
void EndGimmeDir (struct tGimmeDir *pGimmeDir)
{
	while (pGimmeDir->Continuar)
		pGimmeDir->Continuar = ExAll (pGimmeDir->MeuLock, pGimmeDir->pMeuBuff, TamBuf, pGimmeDir->Tipo, pGimmeDir->MeuDosObj);
	FreeDosObject (DOS_EXALLCONTROL, pGimmeDir->MeuDosObj);
	UnLock (pGimmeDir->MeuLock);
	FreeVec (pGimmeDir->pMeuBuff);
	FreeVec (pGimmeDir);
}

/* same as EndGimmeDir but makes less overhead	*/
/* and it's more elegant. :-)							*/
/* NEEDS AmigaOS V39 (because ExAllEnd)			*/
void EndGimmeDir39 (struct tGimmeDir *pGimmeDir)
{
	if (pGimmeDir->Continuar)
		ExAllEnd (pGimmeDir->MeuLock, pGimmeDir->pMeuBuff, TamBuf, pGimmeDir->Tipo, pGimmeDir->MeuDosObj);
	FreeDosObject (DOS_EXALLCONTROL, pGimmeDir->MeuDosObj);
	UnLock (pGimmeDir->MeuLock);
	FreeVec (pGimmeDir->pMeuBuff);
	FreeVec (pGimmeDir);
}

/* Gives ONE file name or NULL (if there's no more files to list).	*/
/* To read all the files you must call it repeately.						*/
/* It returns a pointer to an ExAllData structure, where you can		*/
/* find the filename, filesize, etc.. depending what you previously	*/
/* defined with InitGimmeDir. (ED_NAME, ED_TYPE, ED_SIZE...etc)		*/
struct ExAllData *GimmeDir (struct tGimmeDir *pGimmeDir)
{
	struct ExAllData *MeuTempy;

	if (!pGimmeDir->OndeEsta)
	{
		if (!pGimmeDir->Continuar)
		{
			return(0);		
		}
		else
		{
			pGimmeDir->Continuar = ExAll (pGimmeDir->MeuLock, pGimmeDir->pMeuBuff, TamBuf, pGimmeDir->Tipo, pGimmeDir->MeuDosObj);
			pGimmeDir->OndeEsta = pGimmeDir->pMeuBuff;
		}
	}

 	MeuTempy = pGimmeDir->OndeEsta;
	pGimmeDir->OndeEsta = MeuTempy->ed_Next;
	return (MeuTempy);
}

