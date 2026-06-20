/**************************************************************************/
/*                                image.h                                 */
/**************************************************************************/
/*                                                                        */
/* 05-Sep-2011 constants                                                  */
/* 22-Jan-2009 */
/**/


#define IMAGE_TEMPLATE_NONE       -1
#define IMAGE_TEMPLATE_PALETTE     0
#define IMAGE_TEMPLATE_COLORWHEEL  1
#define IMAGE_TEMPLATE_COLORSPREAD 2
#define IMAGE_TEMPLATE_PALETTEREF  3


struct ImageDataInfo
{
  FILE *f ;
  int width ;
  int height ;
  int template ;
  int radius ;
  struct RastPort *rp ;
  struct ColorMap *cm ;
} ;


int getwidth(struct ImageDataInfo *info) ;
int getheight(struct ImageDataInfo *info) ;
int getrowX(struct ImageDataInfo *info, int row, unsigned char *array, int color) ;

struct ImageDataInfo *image_open(char *filename) ;
void image_init(struct ImageDataInfo *info) ;
void image_close(struct ImageDataInfo *info) ;

