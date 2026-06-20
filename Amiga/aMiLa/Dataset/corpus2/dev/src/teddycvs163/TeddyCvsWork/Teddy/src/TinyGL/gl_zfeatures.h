
#ifndef _tgl_features_h_
#define _tgl_features_h_


/* It is possible to enable/disable (compile time) features in this
   header file. */

#define TGL_FEATURE_ARRAYS         1
#define TGL_FEATURE_DISPLAYLISTS   1
#define TGL_FEATURE_POLYGON_OFFSET 1

/* enable various convertion code from internal pixel format (usually
   16 bits per pixel) to any external format */
#define TGL_FEATURE_16_BITS        1
#define TGL_FEATURE_8_BITS         1
#define TGL_FEATURE_24_BITS        1
#define TGL_FEATURE_32_BITS        1

/* 16 bits per pixel are computed during rendering. Only 16 bits are
   working now, but some code exists for 15, 24 and 32 bits per pixel */

/*#define TGL_FEATURE_RENDER_BITS    15*/
#define TGL_FEATURE_RENDER_BITS    16
/*#define TGL_FEATURE_RENDER_BITS    24*/
/*#define TGL_FEATURE_RENDER_BITS    32*/


#endif /* _tgl_features_h_ */
