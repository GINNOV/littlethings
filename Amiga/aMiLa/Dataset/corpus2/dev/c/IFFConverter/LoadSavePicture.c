/*
**     $VER: LoadSavePicture.c V0.10 (21-08-95)
**
**     Author:  Gerben Venekamp
**     Updates: 19-06-95  Version 0.01       Intial module
**              21-08-95  Version 0.02       GetFileName() has been modified so that Load and Save
**                                           picture can use their own variables and ASL FileRequester
**                                           structure.
**
**  LoadSavePicture.c this is where a picture gets loaded or pictures
**  get loaded. Also saving picture/pictures is handled here.
**
*/


#include <datatypes/pictureclass.h>
#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <libraries/asl.h>
#include <proto/asl.h>
#include <proto/dos.h>
#include <proto/iffparse.h>

#include "IFFConverter.h"

// Defining variables
struct ExecBase *SysBase;
BPTR LoadFileName_lock;
BPTR SaveFileName_lock;

ULONG Asl_FRTags_Single[] = {
   ASLFR_DoMultiSelect, FALSE,
   ASLFR_DrawersOnly, FALSE,
TAG_DONE
};

ULONG Asl_FRTags_Sequence[] = {
   ASLFR_DoMultiSelect, FALSE,
   ASLFR_DrawersOnly, FALSE,
   TAG_DONE
};

ULONG Asl_FRTags_Multiple[] = {
   ASLFR_DoMultiSelect, TRUE,
ASLFR_DrawersOnly, FALSE,
TAG_DONE
};

ULONG Asl_FRTags_Dir[] = {
   ASLFR_DoMultiSelect, FALSE,
   ASLFR_DrawersOnly, TRUE,
   TAG_DONE
};

// NOTE: This structure is also used in SavePicture.a so *ANY* change to this
//       structure should also be made to Savepicture.a
struct Save_Buffer_struct {
   UBYTE *Buffer;
   ULONG BufferSize;
   ULONG BufferLeft;
   BPTR  FileHeader;
};


// Defining prototypes
void AddExtension(STRPTR, STRPTR);
BOOL GetFileName(APTR, ULONG *, BPTR *, struct FileRequester *, ULONG *, LONG );
void LoadPicture(enum FileModeType);
void  SavePicture(SavePicStruct_t *);
//void SavePicture(struct Screen *, enum FileModeType, enum RenderModeType, IFFClip_s *);
void __asm SaveCopperAGA(register __a2 ULONG *,
                         register __a3 APTR);
void __asm SaveCopperECS(register __a2 ULONG *,
                         register __a3 APTR);
void __asm SaveCopper32bit(register __a2 ULONG *,
                           register __a3 APTR);
void __asm SaveCopper4bit(register __a2 ULONG *,
                          register __a3 APTR);
void __asm SaveFont8(register __a2 struct BitMap *,
                     register __a3 APTR);
void __asm SaveInterleave(register __a0 struct BitMap *,
                          register __a1 APTR,
                          register __a2 APTR,
                          register __a3 APTR);
void __asm SaveRaw(register __a0 struct BitMap *,
                   register __a1 APTR,
                   register __a2 APTR,
                   register __a3 APTR);


/*
**  LoadPicture(fm_FileMode)
**
**     Loads one or more pictures. When 'FileMode' is 'Single',
**     'LoadPicture' will load a single picture and displays it. In all
**     other cases 'LoadPicture' will load the pictures, ask the place
**     to save them, convert and save them one by one.
**
**  pre:  fm_FileMode - Depending on 'fm_FileMode', 'LoadPicture' acts
**                      differently. When 'fm_FileMode' equals:
**                        Single   - An IFF ILBM picture is loaded and
**                                   displayed. User is able to adjust the
**                                   clipping reagon and then save the
**                                   clipped picture.
**                        Sequence - Loads a sequence of IFF ILBM pictures.
**                                   File name is determined by a basename
**                                   followed by a dot and then a number
**                                   consisting out of 4 digits. You can
**                                   select a clipping reagon for the first
**                                   picture. All other pictures will use
**                                   this clipping.
**                        Multiple - Loads one or more IFF ILBM pictures
**                                   and saves them automaticly. No clipping
**                                   is possible.
**                        Dir      - All files in a particular directory
**                                   are tested for IFF ILBM. If so, then
**                                   the picture is automaticly saved. So,
**                                   no clipping is possible.
**  post: None.
**
*/
void LoadPicture(enum FileModeType fm_FileMode)
{
   UWORD register Temp_Width;
   UWORD register Temp_Height;
   UWORD register Temp_Depth;
   ULONG register Temp_Size;

   ULONG register *Asl_FRTags;
   
   LONG rc;
   struct IFFHandle *iff = NULL;
   
   switch( fm_FileMode )
   {
      case FM_Single:
         Asl_FRTags = Asl_FRTags_Single;
         break;
      case FM_Sequence:
         Asl_FRTags = Asl_FRTags_Sequence;
         ErrorHandler(IFFerror_NotImplemented, "Load Sequence");
         return;
         break;
      case FM_Multiple:
         Asl_FRTags = Asl_FRTags_Multiple;
         ErrorHandler(IFFerror_NotImplemented, "Load Multiple");
         return;
         break;
      case FM_Dir:
         Asl_FRTags = Asl_FRTags_Dir;
         ErrorHandler(IFFerror_NotImplemented, "Load Dir");
         return;
         break;
   }
   
   if( GetFileName(&LoadFileName, &LoadFileNameSize, &LoadFileName_lock, Asl_FRLoad, Asl_FRTags, ACCESS_READ) )
   {
      if(iff = AllocIFF())
      {
         if( iff->iff_Stream = OpenFromLock(LoadFileName_lock) )
         {
            InitIFFasDOS(iff);
            if( !OpenIFF(iff, IFFF_READ) )
            {
               if( !ParseIFF(iff, IFFPARSE_STEP) )
               {
                  struct ContextNode *cn = NULL;
                  
                  if( (cn = CurrentChunk(iff)) && (cn->cn_ID == ID_FORM) )
                  {
                     LONG propArray[] = { ID_ILBM, ID_CAMG,
                                          ID_ILBM, ID_BMHD,
                                          ID_ILBM, ID_CMAP,
                                          ID_ILBM, ID_BODY
                     };
                     
                     if( !PropChunks(iff, propArray, 4) )
                     {
                        if( !StopOnExit(iff, ID_ILBM, ID_FORM) )
                        {
                           rc = ParseIFF(iff, IFFPARSE_SCAN);
                           if( rc==0 || rc==IFFERR_EOC )
                           {
                              struct StoredProperty *sp;
                              
                              if(sp = FindProp(iff, ID_ILBM, ID_BMHD))
                              {
                                 struct BitMapHeader *BitMapHdr = sp->sp_Data;
                                 
                                 if( sp = FindProp(iff, ID_ILBM, ID_CAMG) )
                                 {
                                    ULONG DisplayMode = *(ULONG *) sp->sp_Data;
                                    
                                    if( sp = FindProp(iff, ID_ILBM, ID_CMAP) )
                                    {
                                       APTR CMapData = sp->sp_Data;
                                       
                                       if( sp = FindProp(iff, ID_ILBM, ID_BODY) )
                                       {
                                          switch( RebuildViewScreen(BitMapHdr, DisplayMode, CMapData, sp->sp_Data) )
                                          {
                                             case RVS_Okay:
                                                PictureValid = TRUE;
                                                
                                                Temp_Width  = BitMapHdr->bmh_Width;
                                                Temp_Height = BitMapHdr->bmh_Height;
                                                Temp_Depth  = BitMapHdr->bmh_Depth;
                                                Temp_Size   = ((Temp_Width + 7) >> 3) * Temp_Height * Temp_Depth;
                                                
                                                PicWidth  = Temp_Width;
                                                PicHeight = Temp_Height;
                                                PicSize   = IFFClip.ClipSize   = Temp_Size;
                                                PicDepth  = Temp_Depth;
                                                IFFClip.ClipLeft  = 0;
                                                IFFClip.ClipTop   = 0;
                                                
                                                IFFClip.ClipWidth  = Temp_Width  - 1;
                                                IFFClip.ClipHeight = Temp_Height - 1;
                                                
                                                // Mark as first clipping
                                                OldClipLeft = -1;
                                                
                                                UpdateDimensions(GD_PicWidth,   PicWidth,
                                                                 GD_PicHeight,  PicHeight,
                                                                 GD_PicDepth,   PicDepth,
                                                                 GD_PicSize,    PicSize,
                                                                 GD_ClipWidth,  IFFClip.ClipWidth + 1,
                                                                 GD_ClipHeight, IFFClip.ClipHeight + 1,
                                                                 GD_ClipLeft,   IFFClip.ClipLeft,
                                                                 GD_ClipTop,    IFFClip.ClipTop,
                                                                 GD_ClipSize,   IFFClip.ClipSize,
                                                                 GD_Sentinal);
                                                
                                                UpdateGadgets(GD_Save,       &EnableGadget,
                                                              GD_ClipWidth,  &EnableGadget,
                                                              GD_ClipHeight, &EnableGadget,
                                                              GD_ClipLeft,   &EnableGadget,
                                                              GD_ClipTop,    &EnableGadget,
                                                              TAG_DONE);
                                                break;
                                             case RVS_PictureFailure:
                                             case RVS_NoWindow_PictureOkay:
                                             case RVS_NoWindow_PictureFailure:
                                             case RVS_BlackScreen:
                                             case RVS_NoScreen:
                                             case RVS_NoColourMap:;
                                          }
                                       }
                                       else
                                          ErrorHandler( IFFerror_NotFound, "BODY Chunk" );
                                    }
                                    else
                                       ErrorHandler( IFFerror_NotFound, "CMAP Chunk" );
                                 }
                                 else
                                    ErrorHandler( IFFerror_NotFound, "CMAG Chunk" );
                              }
                              else
                                 ErrorHandler( IFFerror_NotFound, "BitMapHeader" );
                           }
                           else
                              ErrorHandler( IFFerror_Fail, "IFFParse" );
                        }
                        else
                           ErrorHandler( IFFerror_Fail, "StopOnExit" );
                     }
                     else
                        ErrorHandler( IFFerror_Fail, "PropChunks" );
                  }
                  else
                     ErrorHandler( IFFerror_NoIFFErr, NULL );
               }
               else
                  ErrorHandler( IFFerror_Fail, "ParseIFF" );
               
               CloseIFF(iff);
            }
            else
               ErrorHandler( IFFerror_Fail, "OpenIFF" );
            
            Close(iff->iff_Stream);
         }
         else
            ErrorHandler( IFFerror_Fail, "OpenFromLock" );
         
         FreeIFF(iff);
      }
      else
         ErrorHandler( IFFerror_Fail, "AllocIFF" );
   }
// Remember that when a 'FileName' could not been gotten, a message
// has been displayed to notify the user. So no addtional actions
// are required at this stage.
   
}


/*
**  SavePicture(PicScreen, fm_FileMode, rm_RenderMode, Clip)
**
**     Save one or more pictures to disk.
**
**  pre:  PicScreen - Pointer to the screen to be saved.
**        fm_Filemode - Mode of file to be saved.
**        fm_Rendermode - Mode of file to be saved.
**        Clip - Pointer to a clipping reagon
**  post: None.
**
*/
//void SavePicture(struct Screen *PicScreen, enum FileModeType fm_FileMode, enum RenderModeType rm_RenderMode, IFFClip_s *IFFClip)
void  SavePicture(SavePicStruct_t *PictureToSave)
{
   ULONG register *Asl_FRTags;
   
   switch( PictureToSave->FileMode )
   {
      case FM_Single:
         Asl_FRTags = Asl_FRTags_Single;
         break;
      case FM_Sequence:
         ErrorHandler(IFFerror_NotImplemented, "Save Sequence");
         break;
      case FM_Multiple:
         ErrorHandler(IFFerror_NotImplemented, "Save Multiple");
         break;
      case FM_Dir:
         ErrorHandler(IFFerror_NotImplemented, "Save Dir");
         break;
   }
   
   if( GetFileName(&SaveFileName, &SaveFileNameSize, &SaveFileName_lock, Asl_FRSave, Asl_FRTags, ACCESS_WRITE) )
   {
      struct Save_Buffer_struct SaveBuf;
      
      // Check to see whether we need to allocate memory for a screen buffer or
      // for a copperlist / colourmap.
      if( PictureToSave->RenderMode == RM_Copper )
         SaveBufferSize = 16000;
      else
         SaveBufferSize = PictureToSave->IFFClip.ClipSize;
         
      if( !(AllocThisMemNoComplain(&SaveBuffer, SaveBufferSize, MEMF_CLEAR)) )
      {
         SaveBufferSize = DefaultSaveBufferSize;
         if( !(AllocThisMemNoComplain(&SaveBuffer, SaveBufferSize, MEMF_CLEAR)) )
            SaveBufferSize = 0;
      }
      
      // All locks need to be unlocked. Since getting a name also means getting a lock
      // and we don't use this lock, we need to unlock it. Easy huh.
      UnLock(SaveFileName_lock);
      
      SaveBuf.Buffer     = SaveBuffer;
      SaveBuf.BufferSize = SaveBuf.BufferLeft = SaveBufferSize;
      SaveBuf.FileHeader = Open(SaveFileName, MODE_NEWFILE);

      switch( PictureToSave->RenderMode )
      {
         case RM_Interleave:
            FreeThisMem(&PlanePtrs, PlanePtrsSize);
            PlanePtrsSize = (PictureToSave->ViewScreen->ViewPort.RasInfo->BitMap->Depth)<<2;
            AllocThisMem(&PlanePtrs, PlanePtrsSize, MEMF_CLEAR);
            
            SaveInterleave( PictureToSave->ViewScreen->RastPort.BitMap, PlanePtrs, &(PictureToSave->IFFClip), &SaveBuf );
            break;
            
         case RM_Raw:
            FreeThisMem(&PlanePtrs, PlanePtrsSize);
            PlanePtrsSize = (PictureToSave->ViewScreen->ViewPort.RasInfo->BitMap->Depth)<<2;
            AllocThisMem(&PlanePtrs, PlanePtrsSize, MEMF_CLEAR);
            
            SaveRaw( PictureToSave->ViewScreen->RastPort.BitMap, PlanePtrs, &(PictureToSave->IFFClip), &SaveBuf );
            break;
            
         case RM_Copper:
            // Close and delete current file. This is necessary because it is not
            // the right name it's just a base name. What we need are base names
            // with the proper extensions. Call this a diry hack, but it works.
            // What we do is build some sort of colourmap and save each different
            // colourmap to a file. Since we maintain only one buffer, we can also
            // hold just one filehandle. This means that we need to close the buffer
            // and open a new file.
            Close(SaveBuf.FileHeader);    // Wrong name! So close it.
            DeleteFile(SaveFileName);     // Now delete it, because it's just an empty file.
            
            // Extra space has been reserved to fit an extension. So no worries
            // about array boundries.
            AddExtension(SaveFileName, ".AGA");
            SaveBuf.FileHeader = Open(SaveFileName, MODE_NEWFILE);
            SaveCopperAGA( ColourMap, &SaveBuf );
            Close(SaveBuf.FileHeader);
            
            AddExtension(SaveFileName, ".ECS");
            SaveBuf.FileHeader = Open(SaveFileName, MODE_NEWFILE);
            SaveCopperECS( ColourMap, &SaveBuf );
            Close(SaveBuf.FileHeader);
            
            AddExtension(SaveFileName, ".32bit");
            SaveBuf.FileHeader = Open(SaveFileName, MODE_NEWFILE);
            SaveCopper32bit( ColourMap, &SaveBuf );
            Close(SaveBuf.FileHeader);
            
            AddExtension(SaveFileName, ".4bit");
            SaveBuf.FileHeader = Open(SaveFileName, MODE_NEWFILE);
            SaveCopper4bit( ColourMap, &SaveBuf );
            // Do NOT Close. This will be done outside the switch statement.
            
            break;
         case RM_Font8:
            SaveFont8( ViewScreen->RastPort.BitMap, &SaveBuf) ;
            break;
      }
      
      Close(SaveBuf.FileHeader);
      
      FreeThisMem(&SaveBuffer, SaveBufferSize);
   }
}


/*
**  AddExtension( BaseName, BaseNameLenghth, Extension )
**
**     Add an extension to a basename. If an extension already exists,
**     it will be replaced by the new extention.
**
**  pre:  BaseName - Pointer to a basename.
**        BaseNameLength - Length of the basename in bytes.
**        Extension - Extension tot add.
**  post: BaseName - Pointer to the updates basename
**
*/
void AddExtension(STRPTR BaseName, STRPTR Extension)
{
   // Locate the end of the base filename.
   while( (*BaseName != '\0') && (*BaseName != '.') )
      *BaseName++;
      
   // Make sure the String terminator '\0' is included! This makes
   // it possible to overwrite an old extension.
   do
      *BaseName++ = *Extension;
   while(*Extension++ != '\0');
}


/*
**  succes = GetFileName(FileName, FileNameSize, FileName_lock, Asl_FileRequester, Asl_FRTags, accessMode)
**
**     Get a file name through an Asl FileRequester.
**
**  pre:  FileName - Pointer to an address of a pointer variable
**                   which holds the address of block of allocated
**                   memory.
**        FileNameSize - Pointer to a variable which hold the length
**                       of the file name.
**        FileName_lock - Pointer to a variable which hold the
**                        lock on the filename.
**        Asl_FileRequester - Pointer to an asl FileRequester structure.
**        Asl_FRTags - Pointer to a structure which holds some additional
**                     tags to be used with 'AslRequest'.
**        accessMode - ACCESS_READ or ACCESS_WRITE depending whether function
**                     is used to get a filename and lock for a read or
**                     write file.
**  post: FileName - The value of the pointer to which 'FileName' points,
**                   has been filled with the address of a new allocated
**                   memory block, which holds the file name.
**        FileNameSize - The value of the variable to which 'FileNameSize'
**                       points, has been changed to the new size of
**                       the new file name.
**        FileName_lock - The value of the variable to which 'FileName_lock'
**                        points, has been changed to the new lock of
**                        the new file name.
**
*/
BOOL GetFileName(APTR FileName, ULONG *FileNameSize, BPTR *FileName_lock, struct FileRequester *Asl_FileRequester, ULONG *Asl_FRTags, LONG accessMode)
{
   BOOL Retry;
   STRPTR Source, Destination;
   
   do {
      Retry = FALSE;
      
      if( AslRequest(Asl_FileRequester, (struct TagItem *)Asl_FRTags) )
      {
         // Free possible allocated memory.
         FreeThisMem(FileName, *FileNameSize);
         
         // Get the filename length inorder to create a buffer which
         // will hold the entire filename, including its path.
         *FileNameSize = StringLength(Asl_FileRequester->fr_Drawer) + StringLength(Asl_FileRequester->fr_File) + 2;
         
         // Compemsate for write files. Add extension size.
         if( accessMode == ACCESS_WRITE )
            *FileNameSize += ExtensionSize;

         // Allocate appropiate memory for filename buffer
         AllocThisMem(FileName, *FileNameSize, MEMF_CLEAR);
         
         // Setup 'Source' and 'Destination' for copying path.
         Source = Asl_FileRequester->fr_Drawer;
         Destination = *(STRPTR *)FileName;
         
         // Copy path of FileName
         while( *Destination++ = *Source++ );
         
         // Concatenate 'Path' and 'FileName' to make one name.
         AddPart( *(STRPTR *)FileName, Asl_FileRequester->fr_File, *FileNameSize );
         
         if( accessMode == ACCESS_READ )
         {
            if(!( *FileName_lock = Lock( *(STRPTR *)FileName, ACCESS_READ ) ))
               Retry = ErrorHandler( IFFerror_NoLockDoReturn, *(STRPTR *)FileName );
         }
         else
         {
            if( *FileName_lock = Lock( *(STRPTR *)FileName, ACCESS_READ ) )
               switch( ErrorHandler(IFFerror_FileExistsAsk, SaveFileName) )
               {
                  case 1:
                     Retry = TRUE;
                  case 0:
                     UnLock(*FileName_lock);
                     break;
               }
         }
      }
      else
      {
         FileName_lock = NULL;
         // AslRequest returnd FALSE. Check for KickStart Version for additional checking.
         if( SysBase->LibNode.lib_Version >= 38 )
         {
            // KickStart V38+. Now we can check whether the user cancelled
            // the job, or a problem caused AlsRequest to return FALSE.
            switch( IoErr() )
            {
               case 0:
                  // User cancelled the job.
                  break;
               case ERROR_NO_FREE_STORE:
                  ErrorHandler(IFFerror_AslNoFreeStore, NULL);
                  break;
               case ERROR_NO_MORE_ENTRIES:
                  ErrorHandler(IFFerror_AslNoMoreEntries, NULL);
                  break;
            }
         }
         // AslRequest just returned FALSE and pre V38 there's nothing we can do.
         return(FALSE);
      }
   } while(Retry);
   
   if( (accessMode == ACCESS_READ) && (*FileName_lock == NULL) )
      return(FALSE);
   return(TRUE);
}
