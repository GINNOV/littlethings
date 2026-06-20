/*********************************************************************
----------------------------------------------------------------------

	MysticView
	Save Image

----------------------------------------------------------------------
*********************************************************************/

#include <stdio.h>

#include "Mystic_Global.h"
#include "Mystic_Tools.h"
#include "Mystic_Debug.h"

#include <guigfx/guigfx.h>
#include <proto/guigfx.h>
#include <proto/dos.h>

#include <dos/dos.h>

//extern int _OSERR;

//#undef	GLOBAL
#include <jinclude.h>
#include <jpeglib.h>
#include <jerror.h>


BOOL SaveJPEG(char *filename, PICTURE *pic)
{
	return FALSE;
}

//#if 0
	BOOL success = FALSE;

	if (filename && pic)
	{
		if (DoPictureMethod(pic, PICMTHD_RENDER, PIXFMT_0RGB_32, NULL))
		{
			FILE *outfile;
			UBYTE *rawdata;
			ULONG width, height;
			UBYTE *linebuffer;

			GetPictureAttrs(pic, PICATTR_Width, &width, PICATTR_Height, &height,
				PICATTR_RawData, &rawdata, TAG_DONE);

			if (outfile = fopen(filename, "wb"))
			{

				if (linebuffer = Malloc(width*4))
				{
					struct jpeg_compress_struct cinfo;
					struct jpeg_error_mgr jerr;
					int i, x;
					UBYTE *p;

					JSAMPROW row_pointer[1];
					row_pointer[0] = linebuffer;

					cinfo.err = jpeg_std_error(&jerr);
					jpeg_create_compress(&cinfo);

					success = TRUE;

					if (_OSERR)
					{
						success = FALSE;
					}
					else
					{
						jpeg_stdio_dest(&cinfo, outfile);

						if (_OSERR)
						{
							success = FALSE;
						}
						else
						{
							cinfo.image_width = width;
							cinfo.image_height = height;
							cinfo.input_components = 3;
							cinfo.in_color_space = JCS_RGB;
							
							jpeg_set_defaults(&cinfo);
							
							jpeg_start_compress(&cinfo, TRUE);

							if (_OSERR)
							{
								success = FALSE;
							}
							else
							{
								success = TRUE;

								for (i = 0; i < height; ++i)
								{
									p = linebuffer;
									for (x = 0; x < width; ++x)
									{
										*p++ = rawdata[1];
										*p++ = rawdata[2];
										*p++ = rawdata[3];
										rawdata += 4;
									}
			
									jpeg_write_scanlines(&cinfo, row_pointer, 1);

									if (_OSERR)
									{
										success = FALSE;
										break;
									}
								}
							}
						}
						
						if (success)
						{
							jpeg_finish_compress(&cinfo);
						}
					}
					
					jpeg_destroy_compress(&cinfo);
						
					Free(linebuffer);
				}
				
				fclose(outfile);
			}
		}
	
	}
	
	return success;
}
//#endif
