/*----------------------------------------------------------------------*
 * IFFR.C  Support routines for reading IFF-85 files.          1/23/86
 * (IFF is Interchange Format File.)
 *
 * By Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 *
 * This version for the Commodore-Amiga computer.
 *
 * Uses "gio".  Either link with gio.c, or set the GIO_ACTIVE flag to 0
 * in gio.h.
 *----------------------------------------------------------------------*/
#include "iff/gio.h"
#include "iff/iff.h"

/* ----- Private subroutine FileLength() --------------------------------*/
/* Returns the length of the file or else a negative IFFP error code
 * (NO_FILE or DOS_ERROR). AmigaDOS-specific implementation.
 * SIDE EFFECT: Thanks to AmigaDOS, we have to change the file's position
 * to find its length.
 * Now if Amiga DOS maintained fh_End, we'd just do this:
 *    fileLength = (FileHandle *)BADDR(file)->fh_End; */
LONG FileLength(file)  BPTR file;  {
    LONG fileLength = NO_FILE;

    if (file > 0)  {
	GSeek(file, 0, OFFSET_END);	/* Seek to end of file.*/
	fileLength = GSeek(file, 0, OFFSET_CURRENT);
	    /* Returns position BEFORE the seek, which is #bytes in file. */
	if (fileLength < 0)
	    fileLength = DOS_ERROR;	/* DOS being absurd.*/
	}

    return(fileLength);
    }

/* ---------- Read -----------------------------------------------------*/

/* ---------- OpenRIFF --------------------------------------------------*/
IFFP OpenRIFF(file0, new0, clientFrame)
	BPTR file0;   GroupContext *new0;  ClientFrame *clientFrame; {
    register BPTR file = file0;
    register GroupContext *new = new0;
    IFFP iffp = IFF_OKAY;

    new->parent       = NULL;		/* "whole file" has no parent.*/
    new->clientFrame  = clientFrame;
    new->file         = file;
    new->position     = 0;
    new->ckHdr.ckID   = new->subtype    = NULL_CHUNK;
    new->ckHdr.ckSize = new->bytesSoFar = 0;

    /* Set new->bound and go to the file's beginning. */
    new->bound = FileLength(file);
    if (new->bound < 0)
	iffp = new->bound;		   /* File system error! */
    else if ( new->bound < sizeof(ChunkHeader) )
	iffp = NOT_IFF;			   /* Too small for an IFF file. */
    else
	GSeek(file, 0, OFFSET_BEGINNING);  /* Go to file start. */

    return(iffp);
    }

/* ---------- OpenRGroup -----------------------------------------------*/
IFFP OpenRGroup(parent0, new0)   GroupContext *parent0, *new0; {
    register GroupContext *parent = parent0;
    register GroupContext *new    = new0;
    IFFP iffp = IFF_OKAY;

    new->parent       = parent;
    new->clientFrame  = parent->clientFrame;
    new->file         = parent->file;
    new->position     = parent->position;
    new->bound        = parent->position + ChunkMoreBytes(parent);
    new->ckHdr.ckID   = new->subtype    = NULL_CHUNK;
    new->ckHdr.ckSize = new->bytesSoFar = 0;

    if ( new->bound > parent->bound  ||  IS_ODD(new->bound) )
	iffp = BAD_IFF;
    return(iffp);
    }

/* ---------- CloseRGroup -----------------------------------------------*/
IFFP CloseRGroup(context)   GroupContext *context; {
    register LONG position;

    if (context->parent == NULL) {
	}  /* Context for whole file.*/
    else {
	position = context->position;
	context->parent->bytesSoFar += position - context->parent->position;
	context->parent->position = position;
	}
    return(IFF_OKAY);
    }

/* ---------- SkipFwd --------------------------------------------------*/
/* Skip over bytes in a context. Won't go backwards.*/
/* Updates context->position but not context->bytesSoFar.*/
/* This implementation is AmigaDOS specific.*/
IFFP SkipFwd(context, bytes)   GroupContext *context;  LONG bytes; {
    IFFP iffp = IFF_OKAY;

    if (bytes > 0) {
	if (-1 == GSeek(context->file, bytes, OFFSET_CURRENT))
	    iffp = BAD_IFF;	/* Ran out of bytes before chunk complete.*/
	else
	    context->position += bytes;
	}
    return(iffp);
    }

/* ---------- GetChunkHdr ----------------------------------------------*/
ID GetChunkHdr(context0)   GroupContext *context0;  {
    register GroupContext *context = context0;
    register IFFP iffp;
    LONG remaining;

    /* Skip remainder of previous chunk & padding. */
    iffp = SkipFwd(context,
	ChunkMoreBytes(context) + IS_ODD(context->ckHdr.ckSize));
    CheckIFFP();

    /* Set up to read the new header. */
    context->ckHdr.ckID = BAD_IFF;	/* Until we know it's okay, mark it BAD.*/
    context->subtype    = NULL_CHUNK;
    context->bytesSoFar = 0;

    /* Generate a psuedo-chunk if at end-of-context. */
    remaining = context->bound - context->position;
    if (remaining == 0) {
	context->ckHdr.ckSize = 0;
	context->ckHdr.ckID   = END_MARK;
	}

    /* BAD_IFF if not enough bytes in the context for a ChunkHeader.*/
    else if (sizeof(ChunkHeader) > remaining) {
	context->ckHdr.ckSize = remaining;
	}

    /* Read the chunk header (finally). */
    else {
        switch (
	    GRead(context->file, (BYTE *)&context->ckHdr, sizeof(ChunkHeader))
	    ) {
	    case -1: return(context->ckHdr.ckID = DOS_ERROR);
	    case 0:  return(context->ckHdr.ckID = BAD_IFF);
	    }

	/* Check: Top level chunk must be LIST or FORM or CAT. */
	if (context->parent == NULL)
	    switch(context->ckHdr.ckID) {
		case FORM:  case LIST:  case CAT:  break;
		default:    return(context->ckHdr.ckID = NOT_IFF);
		}

	/* Update the context. */
	context->position += sizeof(ChunkHeader);
	remaining         -= sizeof(ChunkHeader);

	/* Non-positive ID values are illegal and used for error codes.*/
	/* We could check for other illegal IDs...*/
	if (context->ckHdr.ckID <= 0)
	     context->ckHdr.ckID = BAD_IFF;

	/* Check: ckSize negative or larger than # bytes left in context? */
	else if (context->ckHdr.ckSize < 0  ||
		 context->ckHdr.ckSize > remaining) {
	    context->ckHdr.ckSize = remaining;
	    context->ckHdr.ckID   = BAD_IFF;
	    }

	/* Automatically read the LIST, FORM, PROP, or CAT subtype ID */
	else switch (context->ckHdr.ckID) {
	    case LIST:  case FORM:  case PROP:  case CAT:  {
		iffp = IFFReadBytes(context,
				    (BYTE *)&context->subtype,
				    sizeof(ID));
		if (iffp != IFF_OKAY)
		    context->ckHdr.ckID = iffp;
		break; }
	    }

	}
    return(context->ckHdr.ckID);
    }

/* ---------- IFFReadBytes ---------------------------------------------*/
IFFP IFFReadBytes(context, buffer, nBytes)
    GroupContext *context;   BYTE *buffer;   LONG nBytes; {
    register IFFP iffp = IFF_OKAY;

    if (nBytes < 0)
	iffp = CLIENT_ERROR;
    else if (nBytes > ChunkMoreBytes(context))
	iffp = SHORT_CHUNK;
    else if (nBytes > 0)
	switch ( GRead(context->file, buffer, nBytes) ) {
	    case -1: {iffp = DOS_ERROR; break; }
	    case 0:  {iffp = BAD_IFF;   break; }
	    default: {
		context->position   += nBytes;
		context->bytesSoFar += nBytes;
		}
	    }

    return(iffp);
    }

/* ---------- SkipGroup ------------------------------------------------*/
IFFP SkipGroup(context)  GroupContext *context;  {
    }	/* Nothing to do, thanks to GetChunkHdr */

/* ---------- ReadIFF --------------------------------------------------*/
IFFP ReadIFF(file, clientFrame)  BPTR file;  ClientFrame *clientFrame;  {
    /*CompilerBug register*/ IFFP iffp;
    GroupContext context;

    iffp = OpenRIFF(file, &context);
    context.clientFrame = clientFrame;

    if (iffp == IFF_OKAY)
	switch (iffp = GetChunkHdr(&context)) {
	    case FORM: { iffp = (*clientFrame->getForm)(&context); break; }
	    case LIST: { iffp = (*clientFrame->getList)(&context); break; }
	    case CAT : { iffp = (*clientFrame->getCat )(&context); break; }
	    /* default: Includes IFF_DONE, BAD_IFF, NOT_IFF... */
	    }

    CloseRGroup(&context);

    if (iffp > 0)		/* Make sure we don't return an ID.*/
	iffp = NOT_IFF;		/* GetChunkHdr should've caught this.*/
    return(iffp);
    }

/* ---------- ReadIList ------------------------------------------------*/
IFFP ReadIList(parent, clientFrame)
    GroupContext *parent;  ClientFrame *clientFrame; {
    GroupContext listContext;
    IFFP iffp;
    BOOL propOk = TRUE;

    iffp = OpenRGroup(parent, &listContext);
    CheckIFFP();

    /* One special case test lets us handle CATs as well as LISTs.*/
    if (parent->ckHdr.ckID == CAT)
	propOk = FALSE;
    else
	listContext.clientFrame = clientFrame;

    do {
	switch (iffp = GetChunkHdr(&listContext)) {
	    case PROP: {
		if (propOk)
		    iffp = (*clientFrame->getProp)(&listContext);
		else
		    iffp = BAD_IFF;
		break;
		}
	    case FORM: { iffp = (*clientFrame->getForm)(&listContext); break; }
	    case LIST: { iffp = (*clientFrame->getList)(&listContext); break; }
	    case CAT : { iffp = (*clientFrame->getCat )(&listContext); break; }
	    /* default: Includes END_MARK, IFF_DONE, BAD_IFF, NOT_IFF... */
	    }
	if (listContext.ckHdr.ckID != PROP)
	    propOk = FALSE;	/* No PROPs allowed after this point.*/
	} while (iffp == IFF_OKAY);

    CloseRGroup(&listContext);

    if (iffp > 0)	/* Only chunk types above are allowed in a LIST/CAT.*/
	iffp = BAD_IFF;
    return(iffp == END_MARK ? IFF_OKAY : iffp);
    }

/* ---------- ReadICat -------------------------------------------------*/
/* By special arrangement with the ReadIList implement'n, this is trivial.*/
IFFP ReadICat(parent)  GroupContext *parent;  {
    return( ReadIList(parent, NULL) );
    }

/* ---------- GetFChunkHdr ---------------------------------------------*/
ID GetFChunkHdr(context)   GroupContext *context; {
    register ID id;

    id = GetChunkHdr(context);
    if (id == PROP)
	context->ckHdr.ckID = id = BAD_IFF;
    return(id);
    }

/* ---------- GetF1ChunkHdr ---------------------------------------------*/
ID GetF1ChunkHdr(context)   GroupContext *context; {
    register ID id;
    register ClientFrame *clientFrame = context->clientFrame;

    switch (id = GetChunkHdr(context))  {
	case PROP: { id = BAD_IFF; break; }
	case FORM: { id = (*clientFrame->getForm)(context); break; }
	case LIST: { id = (*clientFrame->getList)(context); break; }
	case CAT : { id = (*clientFrame->getCat )(context); break; }
	/* Default: let the caller handle other chunks */
	}
    return(context->ckHdr.ckID = id);
    }

/* ---------- GetPChunkHdr ---------------------------------------------*/
ID GetPChunkHdr(context)   GroupContext *context; {
    register ID id;

    id = GetChunkHdr(context);
    switch (id) {
	case LIST:  case FORM:  case PROP:  case CAT:  {
	    id = context->ckHdr.ckID = BAD_IFF;
	    break; }
	}
    return(id);
    }

