/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: font.c                                  */
/*    |< |         text support functions                     */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/text.h>

#include <egs/egs.h>
#include <egs/egsblit.h>
#include <egs/proto/egs.h>
#include <egs/proto/egsblit.h>

#include "common.h"
#include "layers.h"
#include "giraffebase.h"

extern struct GiraffeBase *GiraffeBase;




/* font resource tracking. */
struct {
  struct fontfamily *hash_table;
  int    empty_slots;
  int    total_slots;
  int    font_count;
}font_resources;


void init_font( void )
{
  font_resources.hash_table  = NULL;
  font_resources.total_slots = 0;
  font_resources.font_count  = 0;
  font_resources.empty_slots = 0;
  return;
}

int getprime( int min )
{
  if(min<11)return(11);
  return(17);
}




int hashFont( char *name )
{
  int i,hash;

  /*
   * Hash value is used to index between families
   * of fonts, so it should only depend upon the 
   * shared name.
   */
  hash = 0;
  for(i=0;name[i];i++)hash += name[i];

  hash = hash % font_resources.total_slots;
  if(!hash)hash=1;

  return(hash);
}

struct fontfamily *search_hash( char *name )
{
  int i,hash;

  hash = hashFont(name);

  i = hash;
  while(font_resources.hash_table[i].key)
    {
      /*
       * Check if the font family has
       * already been added.
       */
      if(font_resources.hash_table[i].key == hash)
	if(!strcmp(name,font_resources.hash_table[i].name))
	  break;
      
      /*
       * Increment by the hash value to the
       * next slot. Check for going outside
       * of the table.
       */
      if((i+=hash)>=font_resources.total_slots)
	i -= font_resources.total_slots;
    }
  /*
   * If not already done so, reserver this
   * entry for the user.
   */
  if(!font_resources.hash_table[i].key)
    {
      font_resources.hash_table[i].key = hash;
      font_resources.empty_slots--;
      font_resources.font_count++;
    }
  return font_resources.hash_table+i;
}


void *search_btree( struct font **btree, int key )
{
  struct font *index;

  /*
   * The btree is sorted by
   * the size of the font.
   */
  for(index = *btree;index;)
    {
      if(key==index->pointsize)return index;
      
      if(key>index->height)
	index=index->upper;
      else index=index->lower;
    }
  return NULL;
}

void *add_btree( struct font **btree, struct font *font )
{
  struct font **index;

  /*
   * The btree is sorted by
   * the size of the font.
   */
  for(index = btree;*index;)
    {
      if(font->pointsize==(*index)->pointsize)return NULL;
      
      if(font->pointsize>(*index)->height)
	index = &((*index)->upper);
      else 
	index = &((*index)->lower);
    }
  *index = font;
  font->upper = NULL;
  font->lower = NULL;

  return NULL;
}

void remove_btree( struct font **btree, struct font *font )
{
  struct font **index;

  /*
   * The btree is sorted by
   * the size of the font.
   */
  for(index = btree;*index;)
    {
      if(font==(*index))
	{
	  /*
	   * We've found the index above the
	   * one. Now, to remove it.
	   */
	  *index = NULL;

	  if(font->lower)
	    {
	      (*index) = font->lower;
	      if(font->upper)
		{
		  do
		    {
		      if(font->upper->pointsize>(*index)->height)
			index = &((*index)->upper);
		      else 
			index = &((*index)->lower);
		    } while(*index);
		  font->upper = NULL;
		}
	      font->lower = NULL;
	    }
	  else
	    {
	      (*index) = font->upper;
	      font->upper = NULL;
	    }

	  break;
	}      

      if(font->pointsize>(*index)->height)
	index = &((*index)->upper);
      else 
	index = &((*index)->lower);
    }
  return;
}
  

void addFontResource( char *name, struct font *font )
{
  int    i,length;
  struct fontfamily *old_table,*family;

  if(!font_resources.empty_slots)
    {
      /*
       * First save the values of the
       * old hash table in some stack
       * parameters.
       */
      old_table = font_resources.hash_table;
      length    = font_resources.total_slots;

      /*
       * Now change the size of the hash
       * table to accomodate more entries.
       * Set the entries as NULL, then copy 
       * from the old table to the new.
       */
      font_resources.total_slots=getprime(2*font_resources.font_count+1);
      font_resources.hash_table=(struct fonthash *)allocm(sizeof(struct fontfamily)*font_resources.total_slots);
	
      font_resources.font_count=0;
      font_resources.empty_slots=0;

      if(old_table)
	{
	  /*
	   * Copy all of the old entries.
	   */
	  for(i=0;length;i++)
	    {
	      if(old_table[i].key && old_table[i].key!=-1)
		{
		  if(family = search_hash(old_table[i].name))
		    {
		      family->name = old_table[i].name;
		      family->tree = old_table[i].tree;
		    }
		}
	    }
	  freem(old_table);
	}
    }


  if(family=search_hash(name))
    {
      /*
       * We've found the appropriate slot. If
       * the name is non-NULL, then just add this
       * font to the existing family btree. Otherwise
       * this font is the first of its kind.
       */
      if(!family->name)
	{
	  if(family->name=allocm(strlen(name)+1))
	    strcpy(family->name,name);
	}
      /*
       * Create a new font family for
       * this font.
       */
      font->name = family->name;
      add_btree(&family->tree,font);
    }

  return;
}

void removeFontResource( struct font *font )
{
  struct fontfamily *family;

  if(family=search_hash(font->name))
    {
      remove_btree(&family->tree,font);

      if(!family->tree)
	{
	  family->key  = -1;

	  if(family->name)
	    freem(family->name);
	  family->name = NULL;
	}
    }
  return;
}

struct font *searchfont( char *name, int pointsize )
{
  struct fontfamily *family;

  if(font_resources.hash_table)
    {
      if(family=search_hash(name))
	return search_btree(&family->tree,pointsize);

    }
  return(NULL);
}

void *usefont( struct font *font )
{
  if(checkobject(font,GT_Font))
    {
      font->usecount++;
      return(font);
    }
  return(NULL);
}


EB_ColorTable bw[]={0x00000000,0xffffff00};
	   
void *openfont( char *name, int size )
{
  struct TextFont *RealFont;
  struct TextAttr attributes;
  struct font *font;
  g_Message {
    g_UnpackMsg;
  }g_EndMessage;

  attributes.ta_Name=name;
  attributes.ta_YSize=size;
  attributes.ta_Style=0;
  attributes.ta_Flags=0;


  /* first check if i've already opened the font. */
  if(font=searchfont(name,size))
    { return(usefont(font));
    }

  if(RealFont=(struct TextFont *)OpenFont(&attributes))
    { 
      if(font=(struct font *)allocobject(GT_Font,sizeof(struct font)))
	{
	  font->RealFont=RealFont;
      
	  font->width=RealFont->tf_XSize;
	  font->height=RealFont->tf_YSize;
	  font->baseline=RealFont->tf_Baseline;
	  font->lochar=RealFont->tf_LoChar;
	  font->hichar=RealFont->tf_HiChar;
      
	  font->packing=(struct bitpack *)RealFont->tf_CharLoc;
	  font->space=(uword *)RealFont->tf_CharSpace;
	  font->kern=(uword *)RealFont->tf_CharKern;
      
	  if(font->data=g_AllocMask(RealFont->tf_Modulo<<3,RealFont->tf_YSize,NULL))
	    {
	      /* strange behavior of Expand method!! */
	      g_Rectangle(font->data,0xffffff00,0,0,font->data->Width,font->data->Height);

	      /* create image to copy the bitplane */
	      g_UnpackMsgPrep((APTR)RealFont->tf_CharData,
			      RealFont->tf_Modulo<<3,
			      RealFont->tf_YSize,
			      1,bw);
	      if(g_UnpackMsgSend(font->data))
		{ 
		  font->pointsize=size;
		  font->usecount=1;
		  addFontResource(name,font);
		  return(font);
		}

	      g_FreeMask(font->data);
	    }
	  freeobject(font);
	}
      CloseFont(RealFont);
    }
  return(NULL);
}

void closefont( struct font *font )
{
  if(!checkobject(font,GT_Font))return;

  if(!(--font->usecount))
    {
      removeFontResource(font); 
      CloseFont(font->RealFont);
      g_FreeMask(font->data);
      freeobject(font);
    }
  return;
}

BOOL prepclip( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, struct rectangle *r );

int text( struct cliplist *clip, struct font *font, E_EBitMapPtr bitmap, struct G_GC *gc, int x, int y, char *string, int length )
{
  int    i,is,ie;
  int    xi;
  char   value;
  ulong  width;
  ulong  front,back;
  uword  *space;

  E_EBitMapPtr mask;
  struct rectangle bounds,rect,area;

  if(gc->DrawMode&GC_FIXEDFONT)space=NULL;
  else space = font->space;

  y-=font->baseline;
  width=textlength(font,gc,string,length);

  if(gc->DrawMode&GC_INVERSVID)
    {
      if(gc->DrawMode&GC_JAM2)
	{
	  front=gc->BgPen;
	  back = gc->FgPen;
	}
      else return (int)(x+width);
    }
  else
    {
      front = gc->FgPen;
      back  = (gc->DrawMode&GC_JAM2?gc->BgPen:-1);
    }

  if(!prepclip(clip,bitmap,gc,&area))return (int)(x+width);

  bounds.min.coor.x = x;
  bounds.min.coor.y = y;
  bounds.max.coor.x = x+width-1;
  bounds.max.coor.y = y+font->height-1;

  if(!cliprectangle(&bounds,&area,&rect))return (int)(x+width);

  /*
   * Now we'll size it to just the
   * characters that fit within the
   * clipped area.  Draw the entire
   * character.
   */
  for(i=0;i<length;i++)
    {
      xi=bounds.min.coor.x;
      if(string[i]!=' ')
	xi+=(space?space[string[i]-font->lochar]:font->width);
      else xi+=font->width;

      if(xi>rect.min.coor.x)break;
      bounds.min.coor.x=xi;
    }
  is = i;
  /*
   * Now find the last character.
   */
  bounds.max.coor.x = xi-1;
  for(i++;i<length;i++)
    {
      xi=bounds.max.coor.x;
      if(xi>=rect.max.coor.x)break;

      if(string[i]!=' ')
	xi += (space?space[string[i]-font->lochar]:font->width);
      else xi += font->width;

      bounds.max.coor.x=xi;
    }
  ie = i;


  if(mask=g_AllocMask(rectwidth(bounds),font->height,NULL))
    {
      /*
       * Advance to the first character
       * that has not been
       * clipped.
       */

      xi=0;
      for(i=is;i<ie;i++)
	{
	  /*
	   * Draw the first character.
	   */
	  if(string[i]!=' ')
	    {
	      value = string[i]-font->lochar;
	      g_Copy(mask,xi+(font->kern?font->kern[value]:0),0,font->packing[value].width,font->height,font->data,font->packing[value].offset,0);
	      xi += (space?space[value]:font->width);
	    }
	  else xi += font->width;
	}
      filltwotone(clip,bitmap,front,back,mask,&bounds,&rect);

      g_FreeMask(mask);
    }
  return (int)(x+width);
}

int ltext( struct font *font, struct layer *layer, struct G_GC *gc, int x, int y, char *string, int length )
{
  if(!checkobject(font,GT_Font))return(x);

  locklayer(layer);

  if(layer->visibility)
    {
      x=text(layer->clip,font,layer->bitmap,gc,x+layer->bounds.min.coor.x,y+layer->bounds.min.coor.y,string,length);
      x-=layer->bounds.min.coor.x;
    }
  unlocklayer(layer);

  return(x);
}

int textlength( struct font *font, struct G_GC *gc, char *string, int length )
{
  int i,width;
  uword *space;

  if(gc->DrawMode&GC_FIXEDFONT)space=NULL;
  else space=font->space;

  if(!checkobject(font,GT_Font))return(0);

  width=0;
  for(i=0;i<length;i++)
    {
      if(string[i]!=' ')width+=(space?space[string[i]-font->lochar]:font->width);
      else width+=font->width;
    }
  return(width);
}

void *lclearswath( struct font *font, struct layer *layer, struct G_GC *gc, int x, int y)
{
  struct G_GC _gc;
  
  if(!checkobject(font,GT_Font))return(gc);
  if(!checkobject(layer,GT_Layer))return(gc);

  locklayer(layer);

  _gc = *gc;
  _gc.DrawMode^=GC_INVERSVID;
  if(x<rectwidth(layer->bounds))
    rectanglefill(layer->clip,layer->bitmap,&_gc,x+layer->bounds.min.coor.x,layer->bounds.min.coor.y+y-font->baseline,rectwidth(layer->bounds)-x,font->height);

  unlocklayer(layer);

  return(gc);
}


ulong justifytext( struct font *font, struct G_GC *gc, char *string, int length, ulong width, ulong height, ulong flags )
{
  int text_width;
  union point xy;

  if(!checkobject(font,GT_Font))return(NULL);

  text_width=textlength(font,NULL,string,length);

  switch(flags&FONT_JUSTIFY_HORZ_MASK)
    {
    case FONT_JUSTIFY_HORZ_CENTER:
      xy.coor.x= (width-text_width)/2;
      break;
    case FONT_JUSTIFY_HORZ_LEFT:
      xy.coor.x=0;
      break;
    case FONT_JUSTIFY_HORZ_RIGHT:
      xy.coor.x=width-text_width;
      break;
    }
  switch(flags&FONT_JUSTIFY_VERT_MASK)
    {
    case FONT_JUSTIFY_VERT_CENTER:
      xy.coor.y= (height-font->height)/2 + font->baseline;
      break;
    case FONT_JUSTIFY_VERT_TOP:
      xy.coor.y=font->baseline;
      break;
    case FONT_JUSTIFY_VERT_BOTTOM:
      xy.coor.y=height-font->height+font->baseline;
      break;
    }
      
  return(xy.xy);
}

unsigned short getfontheight( struct font *font )
{
  return font->height;
}

unsigned short getfontbaseline( struct font *font )
{
  return font->baseline;
}

unsigned short getfontwidth( struct font *font, char ch )
{
  if((ch>=font->lochar)&&(ch<=font->hichar))
    {
      if((ch==' ')||(!font->space))
	return font->width;
      return font->space[ch-font->lochar];
    }
  return 0;
}

void quickrectangle()
{
  /* don't be using this yet. */
  /* under construction.      */
  Alert(0xdeadcafe);
  return;
}

void cleareol( struct font *font, struct layer *layer, BitMapPtr bitmap, struct G_GC *gc, int x, int y )
{
  struct rectangle bounds,rect;

  /*
   * Determine area in which text is
   * normally placed.
   */
  if(!layer)
    {
      bounds.min.xy = 0;
      bounds.max.coor.x = g_Width(bitmap)-1;
      bounds.max.coor.y = g_Height(bitmap)-1;
    }
  else bounds = layer->bounds;

  if(gc->Area)
    {
      if(!cliprectangle(gc->Area,&bounds,&rect))return;
    }
  else
    rect = bounds;

  /*
   * Okay, now determine where to
   * clear.
   */
  rect.min.coor.y = greater(rect.min.coor.y,y-font->baseline);
  rect.max.coor.y = lesser(rect.min.coor.y,y-font->baseline+font->height);
  rect.min.coor.x = greater(rect.min.coor.x,x);
  rect.max.coor.x = lesser(rect.max.coor.x,x);

  if((rect.min.coor.x<=rect.max.coor.x)&&
     (rect.min.coor.y<=rect.max.coor.y))quickrectangle((layer?layer->clip:NULL),bitmap,gc->BgPen,gc->FgPen,&rect);

  return;
}

void clearbol( struct font *font, struct layer *layer, BitMapPtr bitmap, struct G_GC *gc, int x, int y )
{
  struct rectangle bounds,rect;
  
  /*
   * Determine area in which text is
   * normally placed.
   */
  if(!layer)
    {
      bounds.min.xy = 0;
      bounds.max.coor.x = g_Width(bitmap)-1;
      bounds.max.coor.y = g_Height(bitmap)-1;
    }
  else bounds = layer->bounds;
  
  if(gc->Area)
    {
      if(!cliprectangle(gc->Area,&bounds,&rect))return;
    }
  else
    rect = bounds;
  
  /*
   * Okay, now determine where to
   * clear.
   */
  if(x<rect.min.coor.x)return;
  rect.max.coor.x = lesser(rect.max.coor.x,x);

  rect.min.coor.y = greater(rect.min.coor.y,y-font->baseline);
  rect.max.coor.y = lesser(rect.min.coor.y,y-font->baseline+font->height);

  if((rect.min.coor.x<=rect.max.coor.x)&&
     (rect.min.coor.y<=rect.max.coor.y))quickrectangle((layer?layer->clip:NULL),bitmap,gc->BgPen,gc->FgPen,&rect);
  
  return;
}

/* font.c */
