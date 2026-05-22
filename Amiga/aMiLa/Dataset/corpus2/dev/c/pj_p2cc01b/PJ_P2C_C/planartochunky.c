/* This is a function to convert planar image data to the chunky */

#include "planartochunky.h"

UBYTE	*PlanarToChunky (chunky_byte, X_PLANAR, ImageByteSize, Depth)
UBYTE	*chunky_byte;
UBYTE	*X_PLANAR;
int	ImageByteSize;
int	Depth;
{
	int j, i, k;

	UBYTE	TEMPBYTE, *PLANAR[8], *image;

	image = chunky_byte;

	for(k = 0; k < Depth; k++)
		PLANAR[k] = X_PLANAR + ( k * ImageByteSize );

/* convert planar to chunky and put pixels in the structure; */

	for (j = 0; j < ImageByteSize; j++)
	{
		for (i=0; i < BitsPerByte; i++)
		{
			for (k = 0; k < Depth; k++)
			{
				TEMPBYTE=*PLANAR[k];
				*image |= (((TEMPBYTE << i) & AND_FILTER) >> (7-k));
			}
			image++;
		}
		for (k = 0; k < Depth; k++)
			PLANAR[k]++;
	}
	for (i = 0;i < BitsPerByte * ImageByteSize; i++)
		printf ("%4x, ",chunky_byte[i]);
	printf ("\n\n");

	printf ("0x%8x\n",chunky_byte);
	printf ("\n\n");

	return(chunky_byte);
}
