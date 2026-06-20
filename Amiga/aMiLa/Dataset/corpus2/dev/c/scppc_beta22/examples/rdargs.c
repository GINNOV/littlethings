#include <proto/dos.h>
#include <proto/exec.h>

#define TEMPLATE "FOLDER/K,PUBSCREEN/K,SETTINGS/K,PORTNAME/K,MAIL/S,TO/K,CC/K,SUBJECT/K,FILE/K,"\
	"SCREENTOFRONT/S,ADDRESS/K,REALNAME/K,SPOOLFILE/K,REPLYTO/K,DONTGETMAIL/S"
typedef enum { ARG_FOLDER, ARG_PUBSCREEN, ARG_SETTINGS, ARG_PORTNAME, ARG_MAIL,
	ARG_TO, ARG_CC, ARG_SUBJECT, ARG_FILE, ARG_SCREENTOFRONT,
	ARG_ADDRESS, ARG_REALNAME, ARG_SPOOLFILE, ARG_REPLYTO, ARG_DONTGETMAIL,
	ARGNUM } Args;


LONG ArgArray[ARGNUM+1];

main()
{
        struct RDArgs *RDArgs;

	if (RDArgs = ReadToolArgs( TEMPLATE, ArgArray ))
	{
		printf("%x\n", ArgArray[ARG_PORTNAME]);
		FreeToolArgs( RDArgs );
	}
}


ReadToolArgs( STRPTR template, LONG *argarray )
{
	struct RDArgs *rda = AllocDosObject( DOS_RDARGS, NULL );

	if (rda && template)
	{
		rda->RDA_ExtHelp = NULL;
		rda = ReadArgs(template, argarray, rda);
	}
	return rda;
}


FreeToolArgs( struct RDArgs *rda )
{
	if (rda)
	{
		if ( rda->RDA_Source.CS_Buffer )
			FreeVec( rda->RDA_Source.CS_Buffer );
		FreeArgs( rda );
		FreeDosObject( DOS_RDARGS, rda );
	}
}
