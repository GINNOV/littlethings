/*
**  Simple driver-spec listing for MiniGL/Warp3D
**  Author: Christian Michael 21 01 2002
*/

/* 02-04-02:
** Surgeon: added proper driverlist-scan for active drivers 
*/


#include <mgl/gl.h>

#include <Warp3D/Warp3D.h>
#ifdef __VBCC__
	#include <proto/warp3d.h>
#else
	#ifdef __GNUC__
		#ifdef __PPC__
		#include <Warp3D/Warp3D_protos.h>
		#else
		#include <inline/Warp3D.h>
		#endif
	#elif defined(__STORM__)
		#include <clib/Warp3D_protos.h>
	#endif
#endif
#include <stdio.h>
#include <stdlib.h>

//Should contain all texformats supported by W3D

int TexFmt_Array[] = {
	W3D_CHUNKY,
	W3D_A8,
	W3D_L8,
	W3D_I8,
	W3D_L8A8,
	W3D_R5G6B5,
	W3D_A1R5G5B5,
	W3D_A4R4G4B4,
	W3D_R8G8B8,
	W3D_R8G8B8A8,
	W3D_A8R8G8B8,
	-999,
};

char TexFmt_Str [][32] = {
	{"W3D_CHUNKY"},
	{"W3D_A8"},
	{"W3D_L8"},
	{"W3D_I8"},
	{"W3D_L8A8"},
	{"W3D_R5G6B5"},
	{"W3D_A1R5G5B5"},
	{"W3D_A4R4G4B4"},
	{"W3D_R8G8B8"},
	{"W3D_R8G8B8A8"},
	{"W3D_A8R8G8B8"},
};

//Expand this :)

int Supported_Array[] = {
	W3D_Q_DRAW_POINT,
	W3D_Q_DRAW_LINE,
	W3D_Q_DRAW_TRIANGLE,
	W3D_Q_CULLFACE,
	W3D_Q_GOURAUDSHADING,
	W3D_Q_SPECULAR,
	W3D_Q_ONE_ONE,
	W3D_Q_CHROMATEST,
	W3D_Q_STENCILBUFFER,
	W3D_Q_FOGGING,
	W3D_Q_ANTIALIASING,
	W3D_Q_TEXMAPPING3D,
	W3D_Q_RECTTEXTURES,
	W3D_Q_PERSPECTIVE,
	W3D_Q_BILINEARFILTER,
	W3D_Q_MMFILTER,
	-999,
};

char Supported_Str [][64] = {
	{"POINT DRAWING                 "},
	{"LINE DRAWING                  "},
	{"TRIANGLE DRAWING              "},
	{"BACKFACE CULLING              "},
	{"GOURAUDSHADING                "},
	{"SPECULAR HILIGHTS             "},
	{"ADDITIVE BLENDING (ONE, ONE)  "},
	{"CHROMA TEST                   "},
	{"STENCILBUFFER                 "},
	{"FOGGING                       "},
	{"ANTIALIASING                  "},
	{"VOLUMETRIC TEXTURES           "},
	{"RECTANGULAR TEXTURES          "},
	{"PERSPECTIVE CORRECT TEXMAPPING"},
	{"BILINEAR FILTERING            "},
	{"MIPMAP FILTERING              "},
};


char Res_Supported_Str [][32] = {
	{"dummy"},
	{"dummy"},
	{"dummy"},
	{"FULLY SUPPORTED"},
	{"PARTIALLY SUPPORTED"},
	{"UNSUPPORTED"},
};


GLboolean Query_TexFmt(W3D_Driver *driver, ULONG mask, GLboolean fullsupport)
{
    ULONG info, destfmt;

    destfmt = mini_CurrentContext->w3dContext->format;

    info = W3D_GetDriverTexFmtInfo(driver, mask, destfmt);

    if(fullsupport)
    {
    	if(info & W3D_TEXFMT_FAST)
      	return GL_TRUE;
      else
      	return GL_FALSE;
    }
    else
    {
	if(info & W3D_TEXFMT_UNSUPPORTED)
		return GL_TRUE;
	else
		return GL_FALSE;
    }
}

int Query_Supported (W3D_Driver *driver, ULONG query)
{
    ULONG destfmt;
    destfmt = mini_CurrentContext->w3dContext->format;

    return (int)W3D_QueryDriver(driver, query, destfmt);
}

int main ()
{
    char *name;
    W3D_Driver **driver;
    int i,k;

    MGLInit();

    mglChoosePixelDepth(16);
    mglChooseWindowMode(GL_TRUE);
    mglCreateContext(0,0,320,240);

    driver = W3D_GetDrivers();

    while (1)
    {

	if(*driver == NULL)
		break;

	k = Query_Supported(driver[0], W3D_Q_MAXTEXWIDTH);

	if (k < 128) //skip inactive drivers
	{
		driver++;
		continue;
	}

	name = driver[0]->name;
      printf("\n\n%s - Warp3D/MiniGL driver specs:\n", name);

      printf("\n");

	i=0;

	while (1)
	{
	  if(Supported_Array[i] == -999)
		break;

        k = Query_Supported(driver[0], (ULONG)Supported_Array[i]);

	  printf("- %s %s\n", &Supported_Str[i][0], &Res_Supported_Str[k][0]);

	i++;
	}

      printf("\n");

	//get max texture dimensions:

	k = Query_Supported(driver[0], W3D_Q_MAXTEXWIDTH);

	if (k)
	{
	printf("- MAX texture dimensions: %i x %i\n", k, Query_Supported(driver[0], W3D_Q_MAXTEXHEIGHT));
	}

      printf("\n");

      printf("- Texture formats directly supported in HW:\n\n");

	i=0;

	while (1)
	{
	  if(TexFmt_Array[i] == -999)
		break;

        if(Query_TexFmt(driver[0], (ULONG)TexFmt_Array[i], GL_TRUE))
	  	printf("  %s\n", &TexFmt_Str[i][0]);
	i++;
	}

      printf("\n");

      printf("- Totally incompatible texture formats:");

	i=0;
	k=0;

	while (1)
	{
	  if(TexFmt_Array[i] == -999)
		break;

        if(Query_TexFmt(driver[0], (ULONG)TexFmt_Array[i], GL_FALSE))
	  {
	  	printf("\n  %s", &TexFmt_Str[i][0]);
		k++;
	  }
	i++;
	}

	if (k == 0)
		printf("  NONE\n");

      printf("\n");

      printf("- MiniGL Extensions:\n\n  %s\n", glGetString(GL_EXTENSIONS));

      printf("\n\n");

   driver++;
   }

    mglDeleteContext();
    MGLTerm();

    return 0;
}
