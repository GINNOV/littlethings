;/* This Example Shows Reaction's bitmap.image
gcc -o BitMapExample BitMapExample.c -lauto -lraauto
quit
 */

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>

static struct Image *image;
static struct Screen *screen;
static struct Gadget *gadget;

int main( void )
{  

	Object *Win_Object;
   	Object *But_Object;
   	struct Window *window;
   	struct Image *image1=NULL,*image2=NULL,*image3=NULL;
   	struct BitMap *bitmap;
   	ULONG result,signal;
   	BOOL done=FALSE;

      	if(screen=IIntuition->LockPubScreen(NULL))
      	{  
        
		 /* Make an image out of an IFF file.
       		* The image will be included in the window layout, and is
          	* used to clip two other images from
          	*/
         		image1=BitMapObject,
            		BITMAP_SourceFile,"PROGDIR:buttons.iff",
            		BITMAP_OffsetX, 0,
            		BITMAP_OffsetY, 0,
            		BITMAP_Width, 577,
            		BITMAP_Height, 30,
            		BITMAP_Screen,screen,
         		BitMapEnd;

	         	if(image1)
    	     	{  
            		/* Get the bitmap of the image */
            		IIntuition->GetAttr(BITMAP_BitMap,image1,(ULONG *)&bitmap);

	            	Win_Object = WindowObject,
               			WA_ScreenTitle, "Reaction OS4",
               			WA_Title, "ReAction BitMap Example",
               			WA_SizeGadget, TRUE,
               			WA_Left, 40,
               			WA_Top, 30,
               			WA_InnerWidth,100,
               			WA_DepthGadget, TRUE,
               			WA_DragBar, TRUE,
               			WA_CloseGadget, TRUE,
               			WA_Activate, TRUE,
               			WA_PubScreen,screen,
               			WINDOW_ParentGroup, VGroupObject,
                  				LAYOUT_SpaceOuter, TRUE,
                  				LAYOUT_HorizAlignment,LALIGN_CENTER,
                  
                  				StartImage,image1,
	              				CHILD_NoDispose,TRUE,

	                  				/* Add a button with its imagery read from two
    	               				* transparent GIF files. BITMAP_Masking,TRUE will
        	           				* make the imagery appear transparent.
                   				*/
                  					StartMember, But_Object = ButtonObject,
                     					GA_ReadOnly, TRUE,
                     					GA_Image,image2=BitMapObject,
                        						BITMAP_BitMap,bitmap,
                        						BITMAP_OffsetX,0,
                        						BITMAP_OffsetY,0,
                        						BITMAP_Width,120,
                        						BITMAP_Height,30,
                        						BITMAP_SelectBitMap,bitmap,
                        						BITMAP_SelectOffsetX,30,
                        						BITMAP_SelectOffsetY,0,
                        						BITMAP_SelectWidth,120,
                        						BITMAP_SelectHeight,30,
                        						BITMAP_Masking,TRUE,
                      					EndImage,
                  					EndMember,
                  					CHILD_WeightedWidth, 0,
                  					CHILD_WeightedHeight, 0,

	               			EndMember,
            			EndWindow;

             		/*  Object creation sucessful? */
            		if( Win_Object )
		         {
               			/*  Open the window. */
               			if( window = (struct Window *) RA_OpenWindow(Win_Object) )
               			{
                  				ULONG wait;
               
                  				/* Obtain the window wait signal mask. */
                  				IIntuition->GetAttr( WINDOW_SigMask, Win_Object, &signal );
                   			
					/* Input Event Loop */
                  				while( !done )
                  				{
					 	IIntuition->SetAttrs(image2, BITMAP_OffsetX, 32, TAG_END);

                     				wait = IExec->Wait(signal|SIGBREAKF_CTRL_C);

                     				if (wait & SIGBREAKF_CTRL_C) done = TRUE;
                     				
						else
                      					while ((result = RA_HandleInput(Win_Object,NULL)) != WMHI_LASTMSG)
                     					{

                        						switch(result)
                        						{
                           							case WMHI_CLOSEWINDOW:
                              							done = TRUE;
                              							break;
                        						}
                     					}
                 					
               				}
                				/* Disposing of the window object will
                				* also close the window if it is
                				* already opened and it will dispose of
                				* all objects attached to it.
                				*/
               				IIntuition->DisposeObject( Win_Object );
            			}
            
            			/* Dispose the images ourselves as button.gadget doesn't
             			* do this for its GA_Image...
             			*/
            			if(image2) IIntuition->DisposeObject(image2);
            			if(image3) IIntuition->DisposeObject(image3);
            			if(image1) IIntuition->DisposeObject(image1);
            
         			}

         			IIntuition->UnlockPubScreen(NULL,screen);
      		}
	}
}

