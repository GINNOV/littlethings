#ifndef POWERUP_PPCLIB_OBJECT_H
#define POWERUP_PPCLIB_OBJECT_H

/**************************************************
 *
 *
 *              PPCLoadElfObjectTags()
 *
 *
 **************************************************/

#define	PPCELFLOADOBJECTTAG_DUMMY	(TAG_USER + 0x23300)

/* pointer to a filename of the elf file */
#define	PPCELFLOADTAG_ELFNAME		(PPCELFLOADOBJECTTAG_DUMMY + 0x0)

/* pointer to the elf stream resident in memory.
 * PPCELFLOADTAG_ELFNAME and PPCELFLOADTAG_ELFADDRESS
 * are mutually exclusive
 */
#define	PPCELFLOADTAG_ELFADDRESS	(PPCELFLOADOBJECTTAG_DUMMY + 0x1)

/* length of the elf stream. This tag is optional
 */
#define	PPCELFLOADTAG_ELFLENGTH		(PPCELFLOADOBJECTTAG_DUMMY + 0x2)

/* Stream IO Hook
 * so you can implement your own loader system
 * BOOL CallHookPkt(hook,Handle,&Msg);
 *
 */
#define	PPCELFLOADTAG_HOOK		(PPCELFLOADOBJECTTAG_DUMMY + 0x3)

/* Load an ElfObject as a SharedLib Module
 * BOOL
 */
#define	PPCELFLOADTAG_LIBRARY		(PPCELFLOADOBJECTTAG_DUMMY + 0x4)

/* File Ptr
 * BPTR
 */
#define	PPCELFLOADTAG_FILE		(PPCELFLOADOBJECTTAG_DUMMY + 0x5)

/* pointer to THE name of the elf lib */
#define	PPCELFLOADTAG_ELFLIBNAME	(PPCELFLOADOBJECTTAG_DUMMY + 0x6)

/* Ask for at least version x of a SharedLib Module
 * ULONG
 */
#define	PPCELFLOADTAG_LIBVERSION	(PPCELFLOADOBJECTTAG_DUMMY + 0x7)

/* Ask for at least revision x of a SharedLib Module
 * ULONG
 */
#define	PPCELFLOADTAG_LIBREVISION	(PPCELFLOADOBJECTTAG_DUMMY + 0x8)

/* Ask for the specific version of a SharedLib Module
 * BOOL
 */
#define	PPCELFLOADTAG_LIBEXACTVERSION	(PPCELFLOADOBJECTTAG_DUMMY + 0x9)
#define	PPCELFLOADTAG_LIBEXACTREVISION	(PPCELFLOADOBJECTTAG_DUMMY + 0xa)




struct ElfStreamMsg
{
	ULONG	Type;
	ULONG	Arg1;	/* Open->No Meaning,Close->No Meaning,Read->Address,Seek->Offset */
	ULONG	Arg2;	/* Open->No Meaning,Close->No Meaning,Read->Length,Seek->Type */
};

/* The Result must be a Handle */
#define	PPCELFLOADTYPE_OPEN	0
/* The Result must be a boolean */
#define	PPCELFLOADTYPE_CLOSE	1
/* The Result must be the read length or -1 */
#define	PPCELFLOADTYPE_READ	2
/* The Result must be the old offset or -1 */
#define	PPCELFLOADTYPE_SEEK	3

/**************************************************
 *
 *
 *              PPCGetElfInfos() Tags
 *
 *
 **************************************************/

#define	PPCELFINFOTAG_DUMMY		(TAG_USER + 0x23000)

/* Returns the name of an elfobject */
#define	PPCELFINFOTAG_NAME		(PPCELFINFOTAG_DUMMY + 0x0)

/* Returns infos about a reloc instead of a symbol
 * A special PPCSymbolStruct is passed by ti_Data
 * which tells if you search for a symbol name
 * or wanna find a symbol for a certain address.
 * Result=TRUE if the search was successful and then
 * the SymbolStruct contains other important infos
 */
#define	PPCELFINFOTAG_RELOC		(PPCELFINFOTAG_DUMMY + 0x1)



/* Set this Boolean if you want the infos global.
   Then all Elfobjects are searched.
 */
#define	PPCELFINFOTAG_GLOBAL		(PPCELFINFOTAG_DUMMY + 0x2)


/* Define this Hook if you wanna get informations about every
   Symbol in a specific ElfObject or in all.
   (ElfObject==NULL || PPCELFINFOTAG_GLOBAL=TRUE)
   That`s the way how the PPCGetObjectInfo() calls your hook.
   MyInfo contains the passed infos, so you could show all
   important symbols or relocs if possible.

   CallHookPkt(ScanSymbolHook,
               (APTR) ElfSubStructure, // Not really useful
               (APTR) MyInfo);

 */
#define	PPCELFINFOTAG_SCANSYMBOLHOOK	(PPCELFINFOTAG_DUMMY + 0x3)



struct	PPCObjectInfo
{
	ULONG	Address;
/* Name of the Object
 * If this is set PPCGetElfInfo search for the Name
 * Otherwise Address is used to search for an object
 */
	char	*Name;
/* Type of the object
 */
	ULONG	Type;

/* Subtype of the object
 * Symbol:
 * COMMON=BSS
 * FUNCTION
 * ...
 * Section:
 *
 * Reloc:
 * Relocation Type
 */
	ULONG	SubType;
/* Symbol:
 * Local,Global,Weak
 * Section:
 *
 */
	ULONG	Binding;
/* Size of the object
 */
	ULONG	Size;
};

#define	PPCELFINFOTYPE_SECTION		0

/* A Symbol whose SubType defines the real
   symbol Type and Binding contains the
   state of the symbol.
 */
#define	PPCELFINFOTYPE_SYMBOL		1

/* A common section(BSS) symbol whose SubType
   defines the real symbol Type and Binding
   contains the state of the symbol.
 */
#define	PPCELFINFOTYPE_COMSYMBOL	2

/* A reloc entry is quite simular to a symbol.
   It`s only useful to connect certain instruction
   addresses with certain symbols where you can`t
   calculate the symbol value in an easy way.
   i.e 16 bit PPC addressmodes..ADDR16_HI,HA
 */
#define	PPCELFINFOTYPE_RELOC		3



/*------------------------------------------------------------------------*/
/*  definition of the symbol types`	 	                                   */
/*------------------------------------------------------------------------*/

#define	STT_NOTYPE	0
#define	STT_OBJECT	1
#define	STT_FUNC	2
#define	STT_SECTION	3
#define	STT_FILE	4
#define	STT_LOPROC	13
#define	STT_HIPROC	15


/*------------------------------------------------------------------------*/
/*  definition of the symbol bindings 	                                   */
/*------------------------------------------------------------------------*/

#define	STB_LOCAL		0
#define	STB_GLOBAL		1
#define	STB_WEAK		2
#define	STB_LOPROC		13
#define	STB_HIPROC		15


/*------------------------------------------------------------------------*/
/*  definition of the supported elf.rela types                            */
/*------------------------------------------------------------------------*/

#define  R_PPC_NONE			0
#define  R_PPC_ADDR32			1
#define  R_PPC_ADDR24			2
#define  R_PPC_ADDR16			3
#define  R_PPC_ADDR16_L			4
#define  R_PPC_ADDR16_HI		5
#define  R_PPC_ADDR16_HA		6
#define  R_PPC_ADDR14			7
#define  R_PPC_ADDR14_BRTAKEN		8
#define  R_PPC_ADDR14_BRNTAKEN		9
#define  R_PPC_REL24			10
#define  R_PPC_REL14			11
#define  R_PPC_REL14_BRTAKEN		12
#define  R_PPC_REL14_BRNTAKEN		13
#define  R_PPC_GOT16			14
#define  R_PPC_GOT16_LO			15
#define  R_PPC_GOT16_HI			16
#define  R_PPC_GOT16_HA			17
#define  R_PPC_PLTREL24			18
#define  R_PPC_COPY			19
#define  R_PPC_GLOB_DAT			20
#define  R_PPC_JMP_SLOT			21
#define  R_PPC_RELATIVE			22
#define  R_PPC_LOCAL24PC		23
#define  R_PPC_UADDR32			24
#define  R_PPC_UADDR16			25
#define  R_PPC_REL32			26
#define  R_PPC_PLT32			27
#define  R_PPC_PLTREL32			28
#define  R_PPC_PLT16_LO			29
#define  R_PPC_PLT16_HI			30
#define  R_PPC_PLT16_HA			31
#define  R_PPC_SDAREL16			32
#define  R_PPC_SECTOFF			33
#define  R_PPC_SECTOFF_LO		34
#define  R_PPC_SECTOFF_HI		35
#define  R_PPC_SECTOFF_HA		34



#endif
