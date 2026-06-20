#include <proto/datatypes.h>

#include <datatypes/datatypesclass.h>
#include <datatypes/pictureclass.h>
#include <datatypes/pictureclassExt.h>

#include <stdio.h>


main(int argc, char *argv[])
{
   Object *dto;
   struct BitMapHeader *bmhd;

   if(argc!=2)
      printf("Need one picture as parameter");

   if( dto = NewDTObject( argv[1],
            DTA_SourceType,         DTST_FILE,
            DTA_GroupID,            GID_PICTURE,
            PDTA_DestMode,          MODE_V43,
            TAG_DONE) )
   {
      if( (GetDTAttrs ( dto,
             PDTA_BitMapHeader, &bmhd,
             TAG_DONE ) ) == 1 )
      {
         printf( "\nBitMapHeader Struct:\n");
         printf( "Width: %d\n", bmhd->bmh_Width);
         printf( "Height: %d\n", bmhd->bmh_Height);
         printf( "Depth: %d\n", bmhd->bmh_Depth);
      }
      else printf("GetDTAttrs failed");

      DisposeDTObject(dto);
      dto=NULL;
   }
   else printf("NewDTObject failed");
return 0;
}
