
#include <stdio.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfx.h>
#include <libraries/dos.h>
#include "jiff.h"

struct ILBM_info root_info;  /*static so get initialized to zero*/
struct ILBM_info *read_ilbm(FILE *file,struct ILBM_info *info,long length,
	short just_colors);
struct ILBM_info *read_body(FILE *file,register struct ILBM_info *info,long length);

struct ILBM_info *read_iff(char *name)
{
short just_colors=0;

struct ILBM_info *info = &root_info;
FILE *file;
struct form_chunk chunk;

if ((file = fopen(name, "r") ) == 0)
	{
	return(NULL);
	}

if ( fread(&chunk, sizeof(struct form_chunk), 1, file) != 1)
	{
	fclose(file);
	return(NULL);
	}

if (chunk.fc_type.b4_type != FORM)
	{
	fclose(file);
	return(NULL);
	}

if (chunk.fc_subtype.b4_type != ILBM)
	{
	fclose(file);
	return(NULL);
	}


info = read_ilbm(file, info, chunk.fc_length - sizeof(chunk), just_colors);
fclose(file);
return(info);
}

struct ILBM_info *read_ilbm(FILE *file,struct ILBM_info *info,long length,
	short just_colors)
{
struct iff_chunk chunk;
int i;
long read_in = 0;
int got_header = FALSE;  /*to make sure gots the header first*/
int got_cmap = FALSE;  /*make sure get cmap before "BODY" */

/*make sure the Planes are all NULL so can free up memory easily
  on error abort */
for (i=0; i<8; i++)
	info->bitmap.Planes[i] = NULL;

while (read_in < length)
	{
	if (fread(&chunk, sizeof(chunk), 1, file) != 1)
		{
		return(NULL);
		}
	switch (chunk.iff_type.b4_type)
		{
		case BMHD:
			if (fread(&info->header, sizeof(info->header), 1, file) != 1)
				{
				return(NULL);
				}
			got_header = TRUE;
			break;
		case CMAP:
			if (!got_header)
				{
				return(NULL);
				}
			if (chunk.iff_length <= 3*MAXCOL )
				{
				if (fread(info->cmap, (int)chunk.iff_length, 1, file) != 1)
					{
					return(NULL);
					}
				}
			else
				{
				if (fread(info->cmap, 3*MAXCOL, 1, file) != 1)
					{
					return(NULL);
					}
				bit_bucket(file, chunk.iff_length - sizeof(3*MAXCOL));
				}
			got_cmap = TRUE;
			if (just_colors)
				return(info);
			break;
		case BODY:
			if (!got_cmap)
				{
				return(NULL);
				}
			return (read_body(file, info, chunk.iff_length));

		default:	/*squawk about unknown types if PARANOID */
		case GRAB:  /*ignore documented but unwanted types*/
		case DESTI:
		case SPRT:
		case CAMG:
		case CRNG:
		case CCRT:
			bit_bucket(file, chunk.iff_length);
			break;
		}
	read_in += chunk.iff_length + sizeof(chunk);
	}
return(NULL);
}



struct ILBM_info *read_body(FILE *file,register struct ILBM_info *info,long length)
{
struct ILBM_header *header;
struct BitMap *bm;
int i, j;
int rlength;
int plane_offset;


/* ok a little more error checking */
if (info->header.compression != 0 && info->header.compression != 1)
	{
	return(NULL);
	}

/*set up the bitmap part that doesn't involve memory allocation first -
  hey this part does get done, and let's be optimistic...*/
info->bitmap.BytesPerRow = line_bytes(info->header.w);
info->bitmap.Rows = info->header.h;
info->bitmap.Depth = info->header.nPlanes;
info->bitmap.Flags = info->bitmap.pad = 0;

rlength = info->bitmap.Rows * info->bitmap.BytesPerRow;

for (i=0; i<info->header.nPlanes; i++)
	{
	if ((info->bitmap.Planes[i] = ralloc(rlength)) == NULL)
		{
		free_planes( &info->bitmap );
		return(NULL);
		}
	}
plane_offset = 0;
for (i=0; i<info->bitmap.Rows; i++)
	{
	/* this test should be in the inner loop for shortest code,
	   in the outer loop for greatest speed, so sue me I compromised */
	if (info->header.compression == 0)
		{
		for (j = 0; j < info->bitmap.Depth; j++)
			{
			if ( fread(info->bitmap.Planes[j] + plane_offset,
				info->bitmap.BytesPerRow, 1, file) != 1)
				{
				free_planes( &info->bitmap);
				return(NULL);
				}
			}
		}
	else
		{
		register char *dest, value;
		register int so_far, count;  /*how much have unpacked so far*/

		for (j = 0; j < info->bitmap.Depth; j++)
			{
			so_far = info->bitmap.BytesPerRow;
			dest = (char *)info->bitmap.Planes[j] + plane_offset;
			while (so_far > 0)
				{
				if ( (value = getc(file)) > 0)
					{
					count = (int)value + 1;
					so_far -= count;
					if ( fread(dest, count, 1, file) != 1)
						{
						free_planes( &info->bitmap);
						return(NULL);
						}
					dest += count;
					}
				else
					{
					count = (int)-value + 1;
					so_far -= count;
					value = getc(file);
					while (--count >= 0)  /*this is fastest loop in C */
						*dest++ = value;
					}
				}
			if (so_far != 0)
				{
				free_planes( &info->bitmap);
				return(NULL);
				}
			}
		}
	plane_offset += info->bitmap.BytesPerRow;
	}
return(info);
}


void free_planes(register struct BitMap *bmap)
{
PLANEPTR plane;
long length;
short i;

length = bmap->BytesPerRow * bmap->Rows;

for (i=0; i<8; i++)
	if ( (plane = bmap->Planes[i]) != NULL)
		rfree(plane, length);
}
