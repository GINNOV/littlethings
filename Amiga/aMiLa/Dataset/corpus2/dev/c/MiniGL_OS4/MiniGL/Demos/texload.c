#include <exec/exec.h>
#include <proto/exec.h>
#include <proto/datatypes.h>
#include <proto/graphics.h>
#include <proto/Picasso96API.h>
#include <proto/intuition.h>
#include <datatypes/pictureclass.h>
#include <intuition/gadgetclass.h>

#include <stdio.h>
#include <stdlib.h>

#include <GL/gl.h>

extern struct IntuitionIFace *IIntuition;
struct DataTypesIFace *IDataTypes = 0;
struct Library *DataTypes = 0;

void CloseMyDatatypes(void)
{
	if (IDataTypes) IExec->DropInterface((struct Interface *)IDataTypes);
	if (DataTypes) IExec->CloseLibrary(DataTypes);
}

void * LoadImage(const char *fileName, uint32 *Width, uint32 *Height)
{
	Object *o = 0;
	struct BitMapHeader *bmhd = 0;
	void *img = 0;

	if (!IDataTypes)
	{
		atexit(CloseMyDatatypes);
		DataTypes = IExec->OpenLibrary("datatypes.library", 0);
		if (!DataTypes) return 0;
		
		IDataTypes = (struct DataTypesIFace *)IExec->GetInterface(DataTypes,
			"main", 1, NULL);
		if (!IDataTypes) return 0;
	}

	o = IDataTypes->NewDTObject((char *) fileName,
		DTA_GroupID, GID_PICTURE,
		OBP_Precision, PRECISION_IMAGE,
		PDTA_DestMode, PMODE_V43,
	TAG_END);
	
	if (o)
	{
		IDataTypes->GetDTAttrs(o, PDTA_BitMapHeader, &bmhd, TAG_END);

		if (bmhd)
		{
			*Width = bmhd->bmh_Width;
			*Height = bmhd->bmh_Height;
			
			img = IExec->AllocVec(*Width * *Height * sizeof(uint32), MEMF_CLEAR);
			if (img)
			{
				struct pdtBlitPixelArray bpa;

				bpa.MethodID = PDTM_READPIXELARRAY;
				bpa.pbpa_PixelData = img;
				bpa.pbpa_PixelFormat = PBPAFMT_RGBA;
				bpa.pbpa_PixelArrayMod = *Width * sizeof(uint32);
				bpa.pbpa_Left = 0;
				bpa.pbpa_Top = 0;
				bpa.pbpa_Width = *Width;
				bpa.pbpa_Height = *Height;
				IIntuition->IDoMethodA(o, /*0, 0,*/
					(Msg)&bpa);
			}
		}
		IDataTypes->DisposeDTObject(o);
	}

	return img;
}

GLuint mglMakeTextureFromFile(GLenum internalFormat, 
	const char *fileName, 
	uint32 *Width, 
	uint32 *Height)
{
	uint32 w,h;
	GLuint texture;
	
	void *img = LoadImage(fileName, &w, &h);
	if (!img) return 0;
	
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexImage2D(GL_TEXTURE_2D, 0,
		internalFormat, 
		w, h, 0,
		GL_RGBA, GL_UNSIGNED_BYTE,
		img);
		
	IExec->FreeVec(img);
	if (glGetError () != GL_NO_ERROR)
	{
		glDeleteTextures(1, &texture);
		return 0;
	}
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	if (Width) *Width = w;
	if (Height) *Height = h;

	return texture;
}

GLuint mglMakeMipMapFromFiles(GLenum internalFormat, 
	const char *fileName, 
	uint32 *Width, 
	uint32 *Height)
{
	uint32 w,h;
	GLuint texture;
	GLint i=0;
	
	
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	do {
		char buffer[256];
		sprintf(buffer, fileName, i);
		
		void *img = LoadImage(buffer, &w, &h);
		if (!img) break;

		glTexImage2D(GL_TEXTURE_2D, i,
			internalFormat, 
			w, h, 0,
			GL_RGBA, GL_UNSIGNED_BYTE,
			img);
		
		if (i==0)
		{
			if (Width) *Width = w;
			if (Height) *Height = h;
		}
		
		IExec->FreeVec(img);
		if (glGetError () != GL_NO_ERROR)
		{
			glDeleteTextures(1, &texture);
			return 0;
		}
		
		i++;
	} while (1);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	return texture;
}

