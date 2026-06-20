/*********************************************************************
----------------------------------------------------------------------

	MysticView
	Save Image

----------------------------------------------------------------------
*********************************************************************/

#include <stdio.h>


#include <guigfx/guigfx.h>
#include <proto/guigfx.h>
#include <proto/dos.h>

#include <dos/dos.h>

extern int _OSERR;

#include <jinclude.h>
#include <jpeglib.h>
#include <jerror.h>

void SaveJPEG()

				{
					struct jpeg_compress_struct cinfo;
					struct jpeg_error_mgr jerr;
					int i, x;
					UBYTE *p;

					JSAMPROW row_pointer[1];
	//				row_pointer[0] = linebuffer;

					cinfo.err = jpeg_std_error(&jerr);
					jpeg_create_compress(&cinfo);

				}
				
