#include "script.h"
#ifdef DUMP
#include "bitstream.h"
#endif

////////////////////////////////////////////////////////////
//  This file is derived from the 'buggy' SWF parser provided
//  by Macromedia.
//
//  Modifications : Olivier Debon  <odebon@club-internet.fr>
//  

static char *rcsid = "$Id: script.cc,v 1.15 1999/02/14 22:06:34 olivier Exp $";

#define printf

//////////////////////////////////////////////////////////////////////
// Inline input script object methods.
//////////////////////////////////////////////////////////////////////

//
// Inlines to parse a Flash file.
//
inline U8 CInputScript::GetByte(void) 
{
    return m_fileBuf[m_filePos++];
}

inline U16 CInputScript::GetWord(void)
{
    U8 * s = m_fileBuf + m_filePos;
    m_filePos += 2;
    return (U16) s[0] | ((U16) s[1] << 8);
}

inline U32 CInputScript::GetDWord(void)
{
    U8 * s = m_fileBuf + m_filePos;
    m_filePos += 4;
    return (U32) s[0] | ((U32) s[1] << 8) | ((U32) s[2] << 16) | ((U32) s [3] << 24);
}




//////////////////////////////////////////////////////////////////////
// Input script object methods.
//////////////////////////////////////////////////////////////////////

CInputScript::CInputScript(void)
// Class constructor.
{
    // Initialize the input pointer.
    m_fileBuf = NULL;

    // Initialize the file information.
    m_filePos = 0;
    m_fileSize = 0;
    m_fileStart = 0;
    m_fileVersion = 0;

    // Initialize the bit position and buffer.
    m_bitPos = 0;
    m_bitBuf = 0;

    // Initialize the output file.
    m_outputFile = NULL;

    // Set to true if we wish to dump all contents long form
    m_dumpAll = false;

    // if set to true will dump image guts (i.e. jpeg, zlib, etc. data)
    m_dumpGuts = false;

    return;
}


CInputScript::~CInputScript(void)
// Class destructor.
{
    // Free the buffer if it is there.
    if (m_fileBuf)
    {
	delete program;
        delete m_fileBuf;
        m_fileBuf = NULL;
        m_fileSize = 0;
    }
}


U16 CInputScript::GetTag(void)
{
    // Save the start of the tag.
    m_tagStart = m_filePos;
    
    // Get the combined code and length of the tag.
    U16 code = GetWord();

    // The length is encoded in the tag.
    U32 len = code & 0x3f;

    // Remove the length from the code.
    code = code >> 6;

    // Determine if another long word must be read to get the length.
    if (len == 0x3f) len = (U32) GetDWord();

    // Determine the end position of the tag.
    m_tagEnd = m_filePos + (U32) len;
    m_tagLen = (U32) len;

    return code;
}


void CInputScript::GetRect (Rect * r)
{
    InitBits();
    int nBits = (int) GetBits(5);
    r->xmin = GetSBits(nBits);
    r->xmax = GetSBits(nBits);
    r->ymin = GetSBits(nBits);
    r->ymax = GetSBits(nBits);
}

void CInputScript::GetMatrix(Matrix* mat)
{
    InitBits();

    // Scale terms
    if (GetBits(1))
    {
        int nBits = (int) GetBits(5);
        mat->a = (float)(GetSBits(nBits))/(float)0x10000;
        mat->d = (float)(GetSBits(nBits))/(float)0x10000;
    }
    else
    {
     	mat->a = mat->d = 1.0;
    }

    // Rotate/skew terms
    if (GetBits(1))
    {
        int nBits = (int)GetBits(5);
        mat->c = (float)(GetSBits(nBits))/(float)0x10000;
        mat->b = (float)(GetSBits(nBits))/(float)0x10000;
    }
    else
    {
     	mat->b = mat->c = 0.0;
    }

    // Translate terms
    int nBits = (int) GetBits(5);
    mat->tx = GetSBits(nBits);
    mat->ty = GetSBits(nBits);
}


void CInputScript::GetCxform(Cxform* cx, BOOL hasAlpha)
{
    int flags;
    int nBits;

    InitBits();

    flags = (int) GetBits(2);
    nBits = (int) GetBits(4);
    cx->aa = 1.0; cx->ab = 0;
    if (flags & 1)
    {
        cx->ra = (float) GetSBits(nBits)/256.0;
        cx->ga = (float) GetSBits(nBits)/256.0;
        cx->ba = (float) GetSBits(nBits)/256.0;
        if (hasAlpha) cx->aa = (float) GetSBits(nBits)/256.0;
    }
    else
    {
        cx->ra = cx->ga = cx->ba = 1.0;
    }
    if (flags & 2)
    {
        cx->rb = (S32) GetSBits(nBits);
        cx->gb = (S32) GetSBits(nBits);
        cx->bb = (S32) GetSBits(nBits);
        if (hasAlpha) cx->ab = (S32) GetSBits(nBits);
    }
    else
    {
        cx->rb = cx->gb = cx->bb = 0;
    }
}


char *CInputScript::GetString(void)
{
    // Point to the string.
    char *str = (char *) &m_fileBuf[m_filePos];

    // Skip over the string.
    while (GetByte());

    return str;
}

void CInputScript::InitBits(void)
{
    // Reset the bit position and buffer.
    m_bitPos = 0;
    m_bitBuf = 0;
}


S32 CInputScript::GetSBits (S32 n)
// Get n bits from the string with sign extension.
{
    // Get the number as an unsigned value.
    S32 v = (S32) GetBits(n);

    // Is the number negative?
    if (v & (1L << (n - 1)))
    {
        // Yes. Extend the sign.
        v |= -1L << n;
    }

    return v;
}


U32 CInputScript::GetBits (S32 n)
// Get n bits from the stream.
{
    U32 v = 0;

    for (;;)
    {
        S32 s = n - m_bitPos;
        if (s > 0)
        {
            // Consume the entire buffer
            v |= m_bitBuf << s;
            n -= m_bitPos;

            // Get the next buffer
            m_bitBuf = GetByte();
            m_bitPos = 8;
        }
        else
        {
         	// Consume a portion of the buffer
            v |= m_bitBuf >> -s;
            m_bitPos -= n;
            m_bitBuf &= 0xff >> (8 - m_bitPos);	// mask off the consumed bits
            return v;
        }
    }
}

void CInputScript::ParseFreeCharacter()
{
    U32 tagid = (U32) GetWord();
    printf("tagFreeCharacter \ttagid %-5u\n", tagid);
}


void CInputScript::ParsePlaceObject()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlPlaceObject;
	ctrl->flags = (PlaceFlags)(placeHasMatrix | placeHasCharacter);

	ctrl->character = getCharacter(GetWord());
	ctrl->depth = GetWord();

	GetMatrix(&(ctrl->matrix));

	if ( m_filePos < m_tagEnd ) 
	{
		ctrl->flags = (PlaceFlags)(ctrl->flags | placeHasColorXform);

		GetCxform(&ctrl->cxform, false);
	}

	program->addControlInCurrentFrame(ctrl);
}


void CInputScript::ParsePlaceObject2()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlPlaceObject2;

	ctrl->flags = (PlaceFlags)GetByte();
	ctrl->depth = GetWord();

	// Get the tag if specified.
	if (ctrl->flags & placeHasCharacter)
	{
		ctrl->character = getCharacter(GetWord());
	}

	// Get the matrix if specified.
	if (ctrl->flags & placeHasMatrix)
	{
		GetMatrix(&(ctrl->matrix));
	}

	// Get the color transform if specified.
	if (ctrl->flags & placeHasColorXform) 
	{
		GetCxform(&ctrl->cxform, true);
	}        

	// Get the ratio if specified.
	if (ctrl->flags & placeHasRatio)
	{
		ctrl->ratio = GetWord();
	}        

	// Get the ratio if specified.
	if (ctrl->flags & placeHasName)
	{
		ctrl->name = GetString();
	}        

	// Get the clipdepth if specified.
	if (ctrl->flags & placeHasClip) 
	{
		ctrl->clipDepth = GetWord();
	}        

	program->addControlInCurrentFrame(ctrl);
}


void CInputScript::ParseRemoveObject()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlRemoveObject;
	ctrl->character = getCharacter(GetWord());
	ctrl->depth = GetWord();

	program->addControlInCurrentFrame(ctrl);
}


void CInputScript::ParseRemoveObject2()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlRemoveObject2;
	ctrl->depth = GetWord();

	program->addControlInCurrentFrame(ctrl);
}


void CInputScript::ParseSetBackgroundColor()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlBackgroundColor;
	ctrl->color.red = GetByte();
	ctrl->color.green = GetByte();
	ctrl->color.blue = GetByte();

	program->addControlInCurrentFrame(ctrl);
}


void CInputScript::ParseDoAction()
{
	Control *ctrl;
	ActionRecord *ar;

	ctrl = new Control;
	ctrl->type = ctrlDoAction;

	do {
		ar = ParseActionRecord();
		if (ar) {
			ctrl->addActionRecord( ar );
		}
	} while (ar);

	program->addControlInCurrentFrame(ctrl);

}


void CInputScript::ParseStartSound()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->character = getCharacter(GetWord());
	ctrl->type = ctrlStartSound;

	program->addControlInCurrentFrame(ctrl);

	if (!m_dumpAll)
	return;

	U32 code = GetByte();

	printf("code %-3u", code);

	if ( code & soundHasInPoint )
		printf(" inpoint %u ", GetDWord());
	if ( code & soundHasOutPoint )
		printf(" oupoint %u", GetDWord());
	if ( code & soundHasLoops )
		printf(" loops %u", GetWord());

	printf("\n");
	if ( code & soundHasEnvelope ) 
	{
		int points = GetByte();

		for ( int i = 0; i < points; i++ ) 
		{
		    printf("\n");
			printf("mark44 %u", GetDWord());
			printf(" left chanel %u", GetWord());
			printf(" right chanel %u", GetWord());
		    printf("\n");
		}
	}
}


void CInputScript::ParseStopSound()
{
	Control *ctrl;

	ctrl = new Control;
	ctrl->type = ctrlStopSound;

	program->addControlInCurrentFrame(ctrl);
}

ShapeRecord *
CInputScript::ParseShapeRecord(long getAlpha)
{
	ShapeRecord *sr;

	// Determine if this is an edge.
	BOOL isEdge = (BOOL) GetBits(1);

	if (!isEdge)
	{
		// Handle a state change
		U16 flags = (U16) GetBits(5);

		// Are we at the end?
		if (flags == 0)
		{
			// End of shape
			return 0;
		}

		sr = new ShapeRecord;

		sr->type = shapeNonEdge;
		sr->flags = (ShapeFlags)flags;

		// Process a move to.
		if (flags & flagsMoveTo)
		{
			U16 nBits = (U16) GetBits(5);
			sr->x = GetSBits(nBits);
			sr->y = GetSBits(nBits);
		}

		// Get new fill info.
		if (flags & flagsFill0)
		{
			sr->fillStyle0 = GetBits(m_nFillBits);
		}
		if (flags & flagsFill1)
		{
			sr->fillStyle1 = GetBits(m_nFillBits);
		}

		// Get new line info
		if (flags & flagsLine)
		{
			sr->lineStyle = GetBits(m_nLineBits);
		}

		// Check to get a new set of styles for a new shape layer.
		if (flags & flagsNewStyles)
		{
			FillStyleDef *fillDefs;
			LineStyleDef *lineDefs;
			long n;

			// Parse the style.
			fillDefs = ParseFillStyle(&n, getAlpha);
			sr->newFillStyles = fillDefs;
			sr->nbNewFillStyles = n;

			lineDefs = ParseLineStyle(&n, getAlpha);
			sr->newLineStyles = lineDefs;
			sr->nbNewLineStyles = n;

			InitBits();	// Bug !

			// Reset.
			m_nFillBits = (U16) GetBits(4);
			m_nLineBits = (U16) GetBits(4);
		}

		//if (flags & flagsEndShape)
			//printf("\tEnd of shape.\n\n");
  
		return flags & flagsEndShape ? 0 : sr;
	}
	else
	{
		sr = new ShapeRecord;

		if (GetBits(1))
		{
			sr->type = shapeLine;

			// Handle a line
			U16 nBits = (U16) GetBits(4) + 2;	// nBits is biased by 2

			// Save the deltas
			if (GetBits(1))
			{
				// Handle a general line.
				sr->dX = GetSBits(nBits);
				sr->dY = GetSBits(nBits);
			}
			else
			{
				// Handle a vert or horiz line.
				if (GetBits(1))
				{
					// Vertical line
					sr->dY = GetSBits(nBits);
					sr->dX = 0;
				}
				else
				{
					// Horizontal line
					sr->dX = GetSBits(nBits);
					sr->dY = 0;
				}
			}
		}
		else
		{
			sr->type = shapeCurve;

		 	// Handle a curve
			U16 nBits = (U16) GetBits(4) + 2;	// nBits is biased by 2

			// Get the control
			sr->ctrlX = GetSBits(nBits);
			sr->ctrlY = GetSBits(nBits);

			// Get the anchor
			sr->anchorX = GetSBits(nBits);
			sr->anchorY = GetSBits(nBits);
		}

		return sr;
	}
}


FillStyleDef * CInputScript::ParseFillStyle(long *n, long getAlpha)
// 
{
	FillStyleDef *defs;
	U16 i = 0;

	// Get the number of fills.
	U16 nFills = GetByte();

	// Do we have a larger number?
	if (nFills == 255)
	{
		// Get the larger number.
		nFills = GetWord();
	}

	*n = nFills;
	defs = new FillStyleDef[ nFills ];

	// Get each of the fill style.
	for (i = 0; i < nFills; i++)
	{
		U16 fillStyle = GetByte();

		defs[i].type = (FillType) fillStyle;

		if (fillStyle & 0x10)
		{
			defs[i].type = (FillType) (fillStyle & 0x12);

			// Get the gradient matrix.
			GetMatrix(&(defs[i].matrix));

			// Get the number of colors.
			defs[i].gradient.nbGradients = GetByte();

			// Get each of the colors.
			for (U16 j = 0; j < defs[i].gradient.nbGradients; j++)
			{
				defs[i].gradient.ratio[j] = GetByte();
				defs[i].gradient.color[j].red = GetByte();
				defs[i].gradient.color[j].green = GetByte();
				defs[i].gradient.color[j].blue = GetByte();
				if (getAlpha) {
					defs[i].gradient.color[j].alpha = (float)GetByte()/255;
				}
			}
		}
		else if (fillStyle & 0x40)
		{
			defs[i].type = (FillType) (fillStyle & 0x41);

			// Get the bitmapId
			defs[i].bitmap = (Bitmap *)getCharacter(GetWord());
			defs[i].pix = 0;

			// Get the bitmap matrix.
			GetMatrix(&(defs[i].matrix));
		}
		else
		{
			defs[i].type = (FillType) 0;

			// A solid color
			defs[i].color.red = GetByte();
			defs[i].color.green = GetByte();
			defs[i].color.blue = GetByte();
			if (getAlpha) {
				defs[i].color.alpha = (float)GetByte()/255;
			}
		}
	}
	
	return defs;
}

LineStyleDef * CInputScript::ParseLineStyle(long *n, long getAlpha)
{
	LineStyleDef *defs;
	long i;

	// Get the number of lines.
	U16 nLines = GetByte();

	// Do we have a larger number?
	if (nLines == 255)
	{
		// Get the larger number.
		nLines = GetWord();
	}

	*n = nLines;
	defs = new LineStyleDef[ nLines ];

	// Get each of the line styles.
	for (i = 0; i < nLines; i++)
	{
    		defs[i].width = GetWord();
    		defs[i].color.red = GetByte();
    		defs[i].color.green = GetByte();
    		defs[i].color.blue = GetByte();
		if (getAlpha) {
			defs[i].color.alpha = (float)GetByte()/255;
		}
	}

	return defs;
}


void CInputScript::ParseDefineShape(int level)
{
	Shape *shape;
	Rect rect;
	ShapeRecord *shapeRecord = 0;
	U32 tagid;
	FillStyleDef *fillDefs;
	LineStyleDef *lineDefs;
	long n;

	tagid = (U32) GetWord();
	shape = new Shape(tagid,level);

	addCharacter(shape);

	// Get the frame information.
	GetRect(&rect);

	shape->setBoundingBox(rect);

	// ShapeWithStyle
	fillDefs = ParseFillStyle(&n, level == 3);

	shape->setFillStyleDefs(fillDefs,n);

	lineDefs = ParseLineStyle(&n, level == 3);

	shape->setLineStyleDefs(lineDefs,n);

	InitBits();
	m_nFillBits = (U16) GetBits(4);
	m_nLineBits = (U16) GetBits(4);

	do {
		shapeRecord = ParseShapeRecord(level == 3);
		if (shapeRecord) {
			shape->addShapeRecord( shapeRecord );
		}
	} while (shapeRecord);
	
	shape->buildShape();
}

void CInputScript::S_DumpImageGuts()
{
    U32 lfCount = 0;                
	printf("----- dumping image details -----");
    while (m_filePos < m_tagEnd)
    {
        if ((lfCount % 16) == 0)
        {
            fprintf(stdout, "\n");
        }
        lfCount += 1;
        fprintf(stdout, "%02x ", GetByte());
    }
    fprintf(stdout, "\n");
}

void CInputScript::ParseDefineBits()
{
    Bitmap *bitmap;
    U32 tagid = (U32) GetWord();
    int status;

    bitmap = new Bitmap(tagid,1);

    addCharacter(bitmap);

    status = bitmap->buildFromJpegAbbreviatedData(&m_fileBuf[m_filePos]);

    if (status < 0) {
    	fprintf(stderr,"Unable to read JPEG data\n");
    }
}


void CInputScript::ParseDefineBitsJPEG2()
{
    Bitmap *bitmap;
    U32 tagid = (U32) GetWord();
    int status;

    bitmap = new Bitmap(tagid,2);

    addCharacter(bitmap);

    status = bitmap->buildFromJpegInterchangeData(&m_fileBuf[m_filePos]);

    if (status < 0) {
    	fprintf(stderr,"Unable to read JPEG data\n");
    }
}

void CInputScript::ParseDefineBitsJPEG3()
{
    Bitmap *bitmap;
    U32 tagid = (U32) GetWord();
    int status;
    long offset;

    printf("tagDefineBitsJPEG3 \ttagid %-5u\n", tagid);

    bitmap = new Bitmap(tagid,3);

    addCharacter(bitmap);

    offset = GetDWord();	// Not is the specs !!!!

    // WARNING THIS DOES NOT READ ALPHA VALUES !!!!!
    status = bitmap->buildFromJpegInterchangeData(&m_fileBuf[m_filePos]);

    if (status < 0) {
    	fprintf(stderr,"Unable to read JPEG data\n");
    }
}


void CInputScript::ParseDefineBitsLossless()
{
	Bitmap *bitmap;
	U32 tagid = (U32) GetWord();
	int status;
	int tableSize;

	bitmap = new Bitmap(tagid,0);

	addCharacter(bitmap);

	int format = GetByte();
	int width  =  GetWord();
	int height = GetWord();

	if (format == 4) {
		printf("New Zlib Image !!!\n");
	}

	if (format == 3) {
		tableSize = GetByte();
	}

	status = bitmap->buildFromZlibData(&m_fileBuf[m_filePos], width, height, format, tableSize);

	if (status < 0) {
		fprintf(stderr,"Unable to read ZLIB data\n");
	}
}


void CInputScript::ParseDefineBitsLossless2()
{
    U32 tagid = (U32) GetWord();

    fprintf(stdout, "tagDefineBitsLossless2 \ttagid %-5u\n", tagid);

    if (!m_dumpAll)
        return;
     
    int format = GetByte();
	int width  =  GetWord();
	int height = GetWord();
	printf("format %-3u width %-5u height %-5u\n", format, width, height);
        
    if (!m_dumpGuts)
        return;
        
    S_DumpImageGuts();
}


void CInputScript::ParseJPEGTables()
{
    Bitmap::readJpegTables(&m_fileBuf[m_filePos]);
}


ButtonRecord * CInputScript::ParseButtonRecord(long getCxform)
{
	U16 state;
	U16 layer;
	Matrix matrix;
	ButtonRecord *br;

	state = (U16) GetByte();

	if (state == 0) return 0;

	br = new ButtonRecord;

	br->state = (ButtonState) state;
	br->character = getCharacter(GetWord());
	br->layer = GetWord();
	br->cxform = 0;

	GetMatrix(&(br->buttonMatrix));

	if (getCxform) {
		br->cxform = new Cxform;
		GetCxform(br->cxform, true);
	}

	return br;
}

ActionRecord * CInputScript::ParseActionRecord()
{
	U8 action,skip;
	U16 length, frame;
	char *url, *target, *label;
	ActionRecord *ar;

	action = GetByte();
	if (action == 0) return 0;

	ar = new ActionRecord;
	ar->action = (Action)action;

	switch (action) {
		case ActionGotoFrame:
			length = GetWord();
			ar->frameIndex = GetWord();
			break;
		case ActionGetURL:
			length = GetWord();
			url = strdup(GetString());
			target = strdup(GetString());
			ar->url = url;
			ar->target = target;
			break;
		case ActionWaitForFrame:
			length = GetWord();
			ar->frameIndex = GetWord();
			ar->skipCount = GetByte();
			break;
		case ActionSetTarget:
			length = GetWord();	// Skip length, undocumented
			ar->target = GetString();
			break;
		case ActionGoToLabel:
			length = GetWord();	// Skip length, undocumented
			ar->frameLabel = GetString();
			break;
	}

	return ar;
}

void CInputScript::ParseDefineButton()
{
	Button		*button;
	ButtonRecord	*buttonRecord;
	ActionRecord	*actionRecord;

	U32 tagid = (U32) GetWord();

	button = new Button(tagid);

	addCharacter(button);

	do {
		buttonRecord = ParseButtonRecord();
		if (buttonRecord) {
			button->addButtonRecord( buttonRecord );
		}
	} while (buttonRecord);
	
	do {
		actionRecord = ParseActionRecord();
		if (actionRecord) {
			button->addActionRecord( actionRecord );
		}
	} while (actionRecord);
}


void CInputScript::ParseDefineButton2()
{
	Button		*button;
	ButtonRecord	*buttonRecord;
	ActionRecord	*actionRecord;
	U16		 transition;
	U16		 offset;
	U8		 menu;

	U32 tagid = (U32) GetWord();

	printf("tagDefineButton2 \ttagid %-5u\n", tagid);

	button = new Button(tagid);

	addCharacter(button);

	menu = GetByte();

	offset = GetWord();

	do {
		buttonRecord = ParseButtonRecord(true);
		if (buttonRecord) {
			button->addButtonRecord( buttonRecord );
		}
	} while (buttonRecord);

	while (offset) {
		offset = GetWord();

		transition = GetWord();

		do {
			actionRecord = ParseActionRecord();
			if (actionRecord) {
				button->addActionRecord( actionRecord );
			}
		} while (actionRecord);

		button->addCondition( transition );
	}
}


void CInputScript::ParseDefineFont()
{
    SwfFont	*font;
    U32 tagid = (U32) GetWord();
    long	 start;
    long	 nb,n;
    long	 offset;
    long	*offsetTable;
    Shape	*shapes;

    font = new SwfFont(tagid);
    addCharacter(font);

    start = m_filePos;

    offset = GetWord();
    nb = offset/2;
    offsetTable = new long[nb];
    offsetTable[0] = offset;

    for(n=1; n<nb; n++)
    {
	    offsetTable[n] = GetWord();
    }

    shapes = new Shape[nb];

    for(n=0; n<nb; n++)
    {
	ShapeRecord *shapeRecord;

	m_filePos = offsetTable[n]+start;

	InitBits();
	m_nFillBits = (U16) GetBits(4);
	m_nLineBits = (U16) GetBits(4);

	do {
		shapeRecord = ParseShapeRecord();
		if (shapeRecord) {
			shapes[n].addShapeRecord( shapeRecord );
		}
	} while (shapeRecord);

	shapes[n].buildShape();

    }

    font->setFontShapeTable(shapes,nb);

    delete offsetTable;
}


void CInputScript::ParseDefineMorphShape()
{
    U32 tagid = (U32) GetWord();

    fprintf(stdout, "tagDefineMorphShape \ttagid %-5u\n", tagid);
}

void CInputScript::ParseDefineFontInfo()
{
    SwfFont	*font;
    U32 tagid = (U32) GetWord();
    long	 nameLen;
    char	*name;
    long	 n,nb;
    FontFlags    flags;
    long	*lut;

    font = (SwfFont *)getCharacter(tagid);

    assert(font != 0);

    nameLen = GetByte();
    name = new char[nameLen+1];
    for(n=0; n < nameLen; n++)
    {
    	name[n] = GetByte();
    }
    name[n]=0;

    font->setFontName(name);

    flags = (FontFlags)GetByte();

    font->setFontFlags(flags);

    nb = font->getNbGlyphs();

    lut = new long[nb];

    for(n=0; n < nb; n++)
    {
    	if (flags & fontWideCodes) {
		lut[n] = GetWord();
	} else {
		lut[n] = GetByte();
	}
    }

    font->setFontLookUpTable(lut);

}


void CInputScript::ParseDefineFont2()
{
	int n;
	U32 tagid = (U32) GetWord();
	FontFlags	 flags;
	char		*name;
	long		 nameLen;
	long		 fontGlyphCount;
	long         	 offset;
	long		*offsetTable;
	Shape       	*shapes;
	long        	 start;
	SwfFont     	*font;
	long 		*lut;

	font = new SwfFont(tagid);
	addCharacter(font);

	flags = (FontFlags)GetWord();

	font->setFontFlags(flags);

	nameLen = GetByte();
	name = new char[nameLen+1];
	for(n=0; n < nameLen; n++)
	{
		name[n] = GetByte();
	}
	name[n]=0;

	font->setFontName(name);

	fontGlyphCount = GetWord();

	start = m_filePos;

	offsetTable = new long[fontGlyphCount];
	for (n=0; n<fontGlyphCount; n++) {
		if (flags & 8) {
			offsetTable[n] = GetDWord();
		} else {
			offsetTable[n] = GetWord();
		}
	}

	shapes = new Shape[fontGlyphCount];

	for (n=0; n<fontGlyphCount; n++) {
		ShapeRecord *shapeRecord;

		m_filePos = offsetTable[n]+start;

		InitBits();
		m_nFillBits = (U16) GetBits(4);
		m_nLineBits = (U16) GetBits(4);

		do {
			shapeRecord = ParseShapeRecord();
			if (shapeRecord) {
				shapes[n].addShapeRecord(shapeRecord);
			}
		} while (shapeRecord);

		shapes[n].buildShape();
	}

	font->setFontShapeTable(shapes,fontGlyphCount);

	delete offsetTable;

	lut = new long[fontGlyphCount];

	for(n=0; n < fontGlyphCount; n++)
	{
		if (flags & 4) {
			lut[n] = GetWord();
		} else {
			lut[n] = GetByte();
		}
	}

	font->setFontLookUpTable(lut);

	// This is an incomplete parsing
}

TextRecord * CInputScript::ParseTextRecord(int hasAlpha)
{
	TextRecord *tr;
	TextFlags   flags;

	flags = (TextFlags) GetByte();
	if (flags == 0) return 0;

	tr = new TextRecord;

	tr->flags = flags;

	if (flags & isTextControl) {
		if (flags & textHasFont) {
			long fontId;

			fontId = GetWord();
			tr->font = (SwfFont *)getCharacter(fontId);
		}
		if (flags & textHasColor) {
			tr->color.red = GetByte();
			tr->color.green = GetByte();
			tr->color.blue = GetByte();
			if (hasAlpha) {
				tr->color.alpha = GetByte();
			}
		}
		if (flags & textHasXOffset) {
			tr->xOffset = GetWord();
		}
		if (flags & textHasYOffset) {
			tr->yOffset = GetWord();
		}
		if (flags & textHasFont) {
			tr->fontHeight = GetWord();
		}
		tr->nbGlyphs = GetByte();
	} else {
		tr->flags = (TextFlags)0;
		tr->nbGlyphs = (long)flags;
	}

	tr->glyphs = new Glyph[ tr->nbGlyphs ];

	InitBits();
	for (int g = 0; g < tr->nbGlyphs; g++)
	{
		tr->glyphs[g].index = GetBits(m_nGlyphBits);
		tr->glyphs[g].xAdvance = GetBits(m_nAdvanceBits);
	}

	return tr;
}

void CInputScript::ParseDefineText(int hasAlpha)
{
	Text		*text;
	TextRecord	*textRecord;
	Matrix  	 m;
	Rect		 rect;
	U32 tagid = (U32) GetWord();

	text = new Text(tagid);
	addCharacter(text);

        GetRect(&rect);
	text->setTextBoundary(rect);

	GetMatrix(&m);
	text->setTextMatrix(m);

	m_nGlyphBits = GetByte();
	m_nAdvanceBits = GetByte();

	do {
		textRecord = ParseTextRecord(hasAlpha);
		if (textRecord) {
			text->addTextRecord( textRecord );
		}
		if (m_filePos >= m_tagEnd) break;
	} while (textRecord);
}


void CInputScript::ParseDefineSound()
{
	Sound		*sound;
	U32 tagid = (U32) GetWord();
	long		 nbSamples;
	long		 flags;
	char		*buffer;

	sound = new Sound(tagid);

	flags = GetByte();
	sound->setSoundFlags(flags);

	addCharacter(sound);

	nbSamples = GetDWord();
	buffer = sound->setNbSamples(nbSamples);

	if (flags & soundIsADPCMCompressed) {
		Adpcm		*adpcm;
		
		adpcm = new Adpcm( &m_fileBuf[m_filePos] , flags & soundIsStereo );

		adpcm->Decompress((short *)buffer, nbSamples);

		delete adpcm;
	} else {
		memcpy(buffer, &m_fileBuf[m_filePos], m_tagLen-5);
	}
}


void CInputScript::ParseDefineButtonSound()
{
    U32 tagid = (U32) GetWord();
    Button	*button;

    printf("tagDefineButtonSound \ttagid %-5u\n", tagid);

    button = (Button *)getCharacter(tagid);

    if (button == 0) {
	printf("	Couldn't find Button id %d\n", tagid);
	return;
    }

    // step through for button states
    for (int i = 0; i < 4; i++)
    {
        Sound	*sound;
        U32 soundTag = GetWord();

	sound = (Sound *)getCharacter(soundTag);

	if (sound) {
		button->setButtonSound(sound,i);
	} else if (soundTag) {
		printf("	Couldn't find Sound id %d\n", soundTag);
	}

        switch (i)
        {
            case 0:         
                printf("upState \ttagid %-5u\n", soundTag);
                break;
            case 1:            
                printf("overState \ttagid %-5u\n", soundTag);
                break;
            case 2:            
                printf("downState \ttagid %-5u\n", soundTag);
                break;
        }
         
        if (soundTag)
        {
            U32 code = GetByte();
        	printf("sound code %u", code);

        	if ( code & soundHasInPoint )
        		printf(" inpoint %u", GetDWord());
        	if ( code & soundHasOutPoint )
        		printf(" outpoint %u", GetDWord());
        	if ( code & soundHasLoops )
        		printf(" loops %u", GetWord());

			printf("\n");
			if ( code & soundHasEnvelope ) 
			{
				int points = GetByte();

				for ( int p = 0; p < points; p++ ) 
				{
				    printf("\n");
					printf("mark44 %u", GetDWord());
					printf(" left chanel %u", GetWord());
					printf(" right chanel %u", GetWord());
						printf("\n");
				}
			}
        }
    	if (m_filePos == m_tagEnd) break;
    }
        
}

void CInputScript::ParseSoundStreamHead()
{
	int mixFormat = GetByte();

	// The stream settings
	int format = GetByte();
	int nSamples = GetWord();

	printf("tagSoundStreamHead \tmixFrmt %-3u frmt  %-3u nSamples %-5u\n", mixFormat, format, nSamples);
}

void CInputScript::ParseSoundStreamHead2()
{
	int mixFormat = GetByte();

	// The stream settings
	int format = GetByte();
	int nSamples = GetWord();

    //printf("tagSoundStreamHead2 \tmixFormat %-3u format %-3u nSamples %-5u\n", mixFormat, format, nSamples);
}

void CInputScript::ParseSoundStreamBlock()
{
    printf("tagSoundStreamBlock\n");
}

void CInputScript::ParseDefineButtonCxform()
{
	ButtonRecord *br;
	Button	*button;
	U32 tagid = (U32) GetWord();

	button = (Button *)getCharacter(tagid);

	for (br = button->getButtonRecords(); br; br = br->next)
	{
		br->cxform = new Cxform;
		GetCxform(br->cxform, false);
	}
}

void CInputScript::ParseNameCharacter()
{
    U32 tagid = (U32) GetWord();
    char *label = GetString();

    printf("tagNameCharacter \ttagid %-5u label '%s'\n", tagid, label);
}


void CInputScript::ParseFrameLabel()
{
    char *label = GetString();

    program->setCurrentFrameLabel(label);
}


void CInputScript::ParseDefineMouseTarget()
{
    printf("tagDefineMouseTarget\n");
}


void CInputScript::ParseDefineSprite()
{
	Sprite  *sprite;
	Program *prg;

        U32 tagid = (U32) GetWord();
        U32 frameCount = (U32) GetWord();

	if (frameCount == 0) return;

        printf("tagDefineSprite \ttagid %-5u \tframe count %-5u\n", tagid, frameCount);

	sprite = new Sprite(tagid, frameCount);

	addCharacter(sprite);

	prg = sprite->getProgram();

	// Set current program
	program = prg;

	ParseTags();
}


void CInputScript::ParseUnknown(long code, long len)
{
    printf("Unknown Tag : %d  - Length = %d\n", code, len);
}


void CInputScript::ParseTags()
// Parses the tags within the file.
{

    // Initialize the end of frame flag.
    BOOL atEnd = false;

    // Reset the frame position.
    U32 frame = 0;

    // Loop through each tag.
    while (!atEnd)
    {
	U32 here;

        // Get the current tag.
        U16 code = GetTag();

        //printf("Code %d, tagLen %8u \n", code, m_tagLen);

	here = m_filePos;

        // Get the tag ending position.
        U32 tagEnd = m_tagEnd;

	if (m_tagEnd > m_actualSize) {
		fprintf(stdout,"File is shorter than expected (%d/%d)!\n",m_actualSize,m_tagEnd);
		break;
	}

        switch (code)
        {
	    case stagProtect:
		break;

            case stagEnd:

                // We reached the end of the file.
                atEnd = true;

                break;
        
            case stagShowFrame:
                // Increment to the next frame.
                ++frame;

		program->setCurrentFrame(frame);

                break;

            case stagFreeCharacter:
                ParseFreeCharacter();
                break;

            case stagPlaceObject:
                ParsePlaceObject();
                break;

            case stagPlaceObject2:
                ParsePlaceObject2();
                break;

            case stagRemoveObject:
                ParseRemoveObject();
                break;

            case stagRemoveObject2:
                ParseRemoveObject2();
                break;

            case stagSetBackgroundColor:
                ParseSetBackgroundColor();
                break;

            case stagDoAction:
                ParseDoAction();
                break;

            case stagStartSound:
                ParseStartSound();
                break;

	    case stagStopSound:
                ParseStopSound();
	    	break;

            case stagDefineShape: 
                ParseDefineShape(1);
                break;

            case stagDefineShape2:
                ParseDefineShape(2);
                break;

            case stagDefineShape3:
                ParseDefineShape(3);
                break;

            case stagDefineBits:
                ParseDefineBits();
                break;

            case stagDefineBitsJPEG2:
                ParseDefineBitsJPEG2();
                break;

            case stagDefineBitsJPEG3:
                ParseDefineBitsJPEG3();
                break;

            case stagDefineBitsLossless:
                ParseDefineBitsLossless();
                break;

            case stagDefineBitsLossless2:
                ParseDefineBitsLossless2();
                break;

            case stagJPEGTables:
                ParseJPEGTables();
                break;

            case stagDefineButton:
                ParseDefineButton();
                break;

            case stagDefineButton2:
                ParseDefineButton2();
                break;

            case stagDefineFont:
                ParseDefineFont();
                break;

            case stagDefineMorphShape:
                ParseDefineMorphShape();
                break;

            case stagDefineFontInfo:
                ParseDefineFontInfo();
                break;

            case stagDefineText:
                ParseDefineText(0);
                break;

            case stagDefineText2:
                ParseDefineText(1);
                break;

            case stagDefineSound:
                ParseDefineSound();
                break;

            case stagDefineButtonSound:
                ParseDefineButtonSound();
                break;

            case stagSoundStreamHead:
                ParseSoundStreamHead();
                break;

            case stagSoundStreamHead2:
                ParseSoundStreamHead2();
                break;

            case stagSoundStreamBlock:
                ParseSoundStreamBlock();
                break;

            case stagDefineButtonCxform:
                ParseDefineButtonCxform();
                break;

            case stagDefineSprite:
		Program *save;

		save = program;
                ParseDefineSprite();
		program->rewindMovie();
		program = save;
                break;

            case stagNameCharacter:
                ParseNameCharacter();
                break;

            case stagFrameLabel:
                ParseFrameLabel();
                break;

            case stagDefineFont2:
                ParseDefineFont2();
                break;

            default:
                ParseUnknown(code, m_tagLen);
                break;
        }

	//printf("Bytes read = %d\n", m_filePos-here);

        // Increment the past the tag.
        m_filePos = tagEnd;
    }
}

BOOL CInputScript::ParseData(char * data, long size)
{
	U8 fileHdr[8];

	memcpy(fileHdr,data,8);

	// Verify the header and get the file size.
	if (fileHdr[0] != 'F' || fileHdr[1] != 'W' || fileHdr[2] != 'S' )
	{
		fprintf(stderr, "Not a Flash File.\n");
		return false;
	}
	else
	{
		// Get the file version.
		m_fileVersion = (U16) fileHdr[3];
	}

	// Get the file size.
	m_fileSize = (U32) fileHdr[4] | ((U32) fileHdr[5] << 8) | ((U32) fileHdr[6] << 16) | ((U32) fileHdr[7] << 24);
	
	m_actualSize = size;

	// Verify the minimum length of a Flash file.
	if (m_fileSize < 21)
	{
		printf("ERROR: File size is too short\n");
		return false;
	}

	m_fileBuf = (unsigned char *)data;

	// Set the file position past the header and size information.
	m_filePos = 8;

	// Get the frame information.
	GetRect(&frameRect);

	frameRate = GetWord() >> 8;

	frameCount = GetWord();

	program = new Program(frameCount);

	// Set the start position.
	m_fileStart = m_filePos;	

	// Parse the tags within the file.
	ParseTags();

	return true;
}
