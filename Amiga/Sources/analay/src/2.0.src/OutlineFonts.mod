(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE OutlineFonts;

(* Important: Have another look at the caching system! *)

(* Common problems: To get the width of a glyph do the following:
   Regard df.GlyphMap.width. This value is a fraction. Multiply it
   with the em width (in other words: with then current point height)
   and you get the width of the glyph in pt. Kerning must be done
   individually. *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       u  : Utility,
       s  : SYSTEM,
       b  : Bullet,
       h  : Hardware,
       df : DiskFont,
       st : Strings,
       l  : LinkedLists,
       tt : TextTools,
       gt : GraphicsTools,
       bt : BasicTypes,
       avl: AVLTrees,
       mdt: MathIEEEDoubTrans,
       rio: LongRealInOut,
       io,
       NoGuruRq;


CONST highBits * = s.VAL(LONGINT,LONGSET{16});
      lowBits  * = 1;

PROCEDURE FixedToReal*(fixed:df.FIXED):LONGREAL;

BEGIN
  RETURN fixed/s.LSH(LONG(LONG(1)),16);
END FixedToReal;

PROCEDURE RealToFixed*(real:LONGREAL):df.FIXED;

BEGIN
  RETURN SHORT(SHORT(real*s.LSH(LONG(LONG(1)),16)));
END RealToFixed;



(* Library stuff *)

VAR base      : e.LibraryPtr; (* Remember to set this before using one of the following procedures *)
    baseinuse : BOOLEAN;

PROCEDURE OpenEngine     {base,-01EH}(): df.GlyphEnginePtr;
PROCEDURE CloseEngine    {base,-024H}(glyphEngine{8} : df.GlyphEnginePtr);
PROCEDURE SetInfoA       {base,-02AH}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tagList{9}     : ARRAY OF u.TagItem): BOOLEAN;
PROCEDURE SetInfo        {base,-02AH}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tag1{9}..      : u.Tag): BOOLEAN;
PROCEDURE ObtainInfoA    {base,-030H}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tagList{9}     : ARRAY OF u.TagItem): BOOLEAN;
PROCEDURE ObtainInfo     {base,-030H}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tag1{9}..      : u.Tag): BOOLEAN;
PROCEDURE ReleaseInfoA   {base,-036H}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tagList{8}     : ARRAY OF u.TagItem): BOOLEAN;
PROCEDURE ReleaseInfo    {base,-036H}(glyphEngine{8} : df.GlyphEnginePtr;
                                      tag1{9}..      : u.Tag): BOOLEAN;

(* Management for font libraries *)

TYPE FontLibraryPtr = POINTER TO FontLibrary;
     FontLibrary = RECORD(l.NodeDesc);
       name : ARRAY 80 OF CHAR; (* including ".library" *)
       base : e.LibraryPtr;
     END;

VAR fontliblist : l.List; (* List of already opened libraries *)

PROCEDURE OpenFontLibrary(name:ARRAY OF CHAR):FontLibraryPtr;

VAR node : FontLibraryPtr;

BEGIN
  node:=NIL;
  IF fontliblist.head#NIL THEN
    node:=fontliblist.head(FontLibrary);
    LOOP
      IF tt.Compare(node.name,name) THEN
        EXIT;
      END;
      IF node.next#NIL THEN
        node:=node.next(FontLibrary);
      ELSE
        EXIT;
      END;
    END;
  END;
  IF node=NIL THEN (* Opening new library *)
    NEW(node);
    IF node#NIL THEN
      fontliblist.AddTail(node);
      COPY(name,node.name);
      node.base:=e.OpenLibrary(name,0);
      IF node.base=NIL THEN
        DISPOSE(node); RETURN NIL;
      END;
    END;
  END;
  RETURN node(FontLibrary);
END OpenFontLibrary;

PROCEDURE (fontlib:FontLibraryPtr) Destruct*;

BEGIN
  IF fontlib.base#NIL THEN
    e.CloseLibrary(fontlib.base);
  END;
  fontlib.Remove;
  fontlib.Destruct^;
END Destruct;

PROCEDURE CloseAllFontLibraries;

VAR node : l.Node;

BEGIN
  node:=fontliblist.head;
  WHILE node#NIL DO
    node(FontLibrary).Destruct;
    node:=node.next;
  END;
END CloseAllFontLibraries;

PROCEDURE (fontlib:FontLibraryPtr) Obtain;

VAR exit : BOOLEAN;

BEGIN
  exit:=FALSE;
  REPEAT
    WHILE baseinuse DO
      d.Delay(10);
    END;
    e.Forbid();
    IF NOT(baseinuse) THEN
      baseinuse:=TRUE;
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;
  base:=fontlib.base;
END Obtain;

PROCEDURE (fontlib:FontLibraryPtr) Release;

BEGIN
  baseinuse:=FALSE;
END Release;



(* Basic stuff *)

PROCEDURE FontIsOutline*(path,name:ARRAY OF CHAR):BOOLEAN;

VAR fontheader : df.FontContentsHeaderPtr;
    lock       : d.FileLockPtr;
    ret        : BOOLEAN;
    str        : UNTRACED POINTER TO ARRAY OF CHAR;

BEGIN
  NEW(str,st.Length(name)+10);
  lock:=d.Lock(path,d.sharedLock);
  COPY(name,str^);
  st.Append(str^,".font");
  fontheader:=df.NewFontContents(s.VAL(e.BPTR,lock),str^);
  IF fontheader.fileID=df.ofchID THEN
    ret:=TRUE;
  ELSE
    ret:=FALSE;
  END;
  df.DisposeFontContents(fontheader);
  d.UnLock(lock);
  DISPOSE(str);
  RETURN ret;
END FontIsOutline;

PROCEDURE Dispose*(any:bt.ANY);

BEGIN
  IF any#NIL THEN
    DISPOSE(any);
  END;
END Dispose;



(* Caching system *)

(* The caching system uses AVL-Trees. *)

TYPE Cache = POINTER TO CacheDesc;
     CacheDesc = RECORD
       maxcachemem  : LONGINT;
       cachesize    : LONGINT;
       root         : avl.Root; (* Basic AVL tree containing all buffered elements *)
       nodelist     : l.List;   (* List for memory cleanup.
                                   Tail is later. Head ist to delete. *)
     END;
     CacheNode = POINTER TO CacheNodeDesc;
     CacheNodeDesc = RECORD(avl.NodeDesc)
       cache        : Cache;    (* This node's cache *)
       refnode      : l.Node;   (* Pointer to node in the nodelist for memory cleanup *)
     END;
     CacheRootNode = POINTER TO CacheRootNodeDesc;
     CacheRootNodeDesc = RECORD(CacheNodeDesc)
       nextroot     : avl.Root;
     END;
     NodeReference = POINTER TO NodeReferenceDesc;
     NodeReferenceDesc = RECORD(l.NodeDesc)
       node : avl.Node;
     END;

PROCEDURE (cache:Cache) Init(maxmemsize:LONGINT);

BEGIN
  cache.cachesize:=0;
  cache.maxcachemem:=maxmemsize;
  cache.root:=avl.Create();
  IF cache.root=NIL THEN
    HALT(20);
  END;
  cache.nodelist:=l.Create();
  IF cache.nodelist=NIL THEN
    HALT(20);
  END;
END Init;

(* Memory cleanup *)

PROCEDURE (cache:Cache) Cleanup;

VAR node,nextnode : l.Node;

BEGIN
  node:=cache.nodelist.head;
  WHILE cache.cachesize>cache.maxcachemem DO
    nextnode:=node.next;
    cache.root.Remove(node(NodeReference).node);
    node(NodeReference).node.Destruct;
    node.Remove;
    node.Destruct;
    node:=nextnode;
  END;
END Cleanup;

PROCEDURE (cache:Cache) Flush;

BEGIN
  cache.root.Destruct;
  cache.cachesize:=0;
END Flush;

PROCEDURE (cache:Cache) NewData*(size:LONGINT);

(* Call this method whenever you allocate new data for a cached node (also
   when allocating a node). This can be done in the node's Cache-Method. *)

BEGIN
  INC(cache.cachesize,size);
  IF cache.cachesize>cache.maxcachemem THEN
    cache.Cleanup;
  END;
END NewData;

PROCEDURE (rootnode:CacheRootNode) Cache(node:CacheNode):CacheNode;

BEGIN
  RETURN NIL;
END Cache;

PROCEDURE (node:CacheRootNode) Destruct*;

BEGIN
  node.nextroot.Destruct;
END Destruct;

PROCEDURE (node:CacheNode) NewNodeReference*;

VAR noderef : NodeReference;

BEGIN
  NEW(noderef);
  IF noderef#NIL THEN
    noderef.node:=node;
    node.refnode:=noderef;
    node.cache.nodelist.AddTail(noderef);
  END;
END NewNodeReference;

PROCEDURE (node:CacheNode) NodeUsed*;

BEGIN
  node.refnode.Remove;
  node.cache.nodelist.AddTail(node.refnode);
END NodeUsed;


TYPE FontCache = POINTER TO FontCacheDesc;
     FontCacheDesc = RECORD(CacheDesc)
       clearmemreg  : e.APTR; (* A pointer to a clear chip memory region. *)
       clearmemsize : LONGINT;
     END;
     FontNode = POINTER TO FontNodeDesc;
     FontNodeDesc = RECORD(CacheRootNodeDesc)
       name,path   : ARRAY 80 OF CHAR;
(*     nextroot contains the resolutions this font has already benn scaled for *)
     END;

     ResolutionNode = POINTER TO ResolutionNodeDesc;
     ResolutionNodeDesc = RECORD(CacheRootNodeDesc)
       dpi    : df.FIXED;
       xdpi   : LONGINT;
       ydpi   : LONGINT;
(*     nextroot contains the buffered sizes for this resolution *)
     END;

     SizeNode = POINTER TO SizeNodeDesc;
     SizeNodeDesc = RECORD(CacheRootNodeDesc)
       height : LONGREAL; (* Height in points *)
(*     nextroot contains the different styles of this size of the font *)
     END;

     StyleNode = POINTER TO StyleNodeDesc;
     StyleNodeDesc = RECORD(CacheRootNodeDesc)
       shearAngle,
       rotateAngle,
       emboldenX,
       emboldenY  : LONGREAL;
(*     nextroot contains the buffered bitmaps *)
     END;

     GlyphNode = POINTER TO GlyphNodeDesc;
     GlyphNodeDesc = RECORD(CacheNodeDesc)
       code   : LONGINT;
       glyph* : df.GlyphMapPtr; (* A copy of the structure returned by Bullet.ObtainInfo *)
       bitmap : g.BitMapPtr;
       raster : g.PLANEPTR;
       infoobtained : BOOLEAN;
     END;

PROCEDURE (a:ResolutionNode) Compare*(b:bt.COMPAREABLE):LONGINT;

BEGIN
  WITH b: ResolutionNode DO
    IF a.dpi<b.dpi THEN RETURN -1;
    ELSIF a.dpi=b.dpi THEN RETURN 0;
    ELSIF a.dpi>b.dpi THEN RETURN 1;
    END;
  END;
END Compare;

PROCEDURE (a:FontNode) Compare*(b:bt.COMPAREABLE):LONGINT;

BEGIN
  WITH b: FontNode DO
    IF a.name<b.name THEN RETURN -1;
    ELSIF a.name>b.name THEN RETURN 1;
    ELSIF a.name=b.name THEN
      IF a.path<b.path THEN RETURN -1;
      ELSIF a.path=b.path THEN RETURN 0;
      ELSIF a.path>b.path THEN RETURN 1;
      END;
    END;
  END;
END Compare;

PROCEDURE (a:SizeNode) Compare*(b:bt.COMPAREABLE):LONGINT;

BEGIN
  WITH b: SizeNode DO
    IF a.height<b.height THEN RETURN -1;
    ELSIF a.height=b.height THEN RETURN 0;
    ELSIF a.height>b.height THEN RETURN 1;
    END;
  END;
END Compare;

PROCEDURE (a:StyleNode) Compare*(b:bt.COMPAREABLE):LONGINT;

BEGIN
  WITH b: StyleNode DO
    IF a.shearAngle<b.shearAngle THEN RETURN -1;
    ELSIF a.shearAngle>b.shearAngle THEN RETURN 1;
    ELSIF a.shearAngle=b.shearAngle THEN
      IF a.rotateAngle<b.rotateAngle THEN RETURN -1;
      ELSIF a.rotateAngle>b.rotateAngle THEN RETURN 1;
      ELSIF a.rotateAngle=b.rotateAngle THEN
        IF a.emboldenX<b.emboldenX THEN RETURN -1;
        ELSIF a.emboldenX>b.emboldenX THEN RETURN 1;
        ELSIF a.emboldenX=b.emboldenX THEN
          IF a.emboldenY<b.emboldenY THEN RETURN -1;
          ELSIF a.emboldenY>b.emboldenY THEN RETURN 1;
          ELSIF a.emboldenY=b.emboldenY THEN RETURN 0;
          END;
        END;
      END;
    END;
  END;
END Compare;

PROCEDURE (a:GlyphNode) Compare*(b:bt.COMPAREABLE):LONGINT;

BEGIN
  WITH b: GlyphNode DO
    IF a.code<b.code THEN RETURN -1;
    ELSIF a.code=b.code THEN RETURN 0;
    ELSIF a.code>b.code THEN RETURN 1;
    END;
  END;
END Compare;

(* Caching operations:
   The following functions copy the given Node and return a pointer to the
   copy in the caching tree of the method's object *)

PROCEDURE (cache:Cache) Cache(font:FontNode):FontNode;

(* This function does not have an object. Instead its caching tree is the
   variable cachedfonts. *)

VAR cfont : FontNode;

BEGIN
  cfont:=cache.root.FindNode(font)(FontNode);
  IF cfont=NIL THEN
    NEW(cfont);
    IF cfont#NIL THEN
      COPY(font.name,cfont.name);
      COPY(font.path,cfont.path);
      cfont.cache:=cache;
      cfont.nextroot:=avl.Create();
      IF cfont.nextroot=NIL THEN
        DISPOSE(cfont); RETURN NIL;
      END;
      cfont.NewNodeReference;
    ELSE
      cfont.NodeUsed;
    END;
    cache.root.Add(cfont);
    cache.NewData(s.SIZE(FontNode)+s.SIZE(avl.Root));
  END;
  RETURN cfont;
END Cache;

PROCEDURE (font:FontNode) Cache(res:CacheNode):CacheNode;

VAR cres : ResolutionNode;

BEGIN
  WITH res: ResolutionNode DO
    cres:=font.nextroot.FindNode(res)(ResolutionNode);
    IF cres=NIL THEN
      NEW(cres);
      IF cres#NIL THEN
        cres.dpi:=res.dpi;
        cres.xdpi:=res.xdpi;
        cres.ydpi:=res.ydpi;
        cres.cache:=font.cache;
        cres.nextroot:=avl.Create();
        IF cres.nextroot=NIL THEN
          DISPOSE(cres); RETURN NIL;
        END;
        cres.NewNodeReference;
      ELSE
        cres.NodeUsed;
      END;
      font.nextroot.Add(cres);
      font.cache.NewData(s.SIZE(ResolutionNode)+s.SIZE(avl.Root));
    END;
  END;
  RETURN cres;
END Cache;

PROCEDURE (res:ResolutionNode) Cache(size:CacheNode):CacheNode;

VAR csize : SizeNode;

BEGIN
  WITH size: SizeNode DO
    csize:=res.nextroot.FindNode(size)(SizeNode);
    IF csize=NIL THEN
      NEW(csize);
      IF csize#NIL THEN
        csize.height:=size.height;
        csize.nextroot:=avl.Create();
        csize.cache:=res.cache;
        IF csize.nextroot=NIL THEN
          DISPOSE(csize); RETURN NIL;
        END;
        csize.NewNodeReference;
      ELSE
        csize.NodeUsed;
      END;
      res.nextroot.Add(csize);
      res.cache.NewData(s.SIZE(SizeNode)+s.SIZE(avl.Root));
    END;
  END;
  RETURN csize;
END Cache;

PROCEDURE (size:SizeNode) Cache(style:CacheNode):CacheNode;

VAR cstyle : StyleNode;

BEGIN
  WITH style: StyleNode DO
    cstyle:=size.nextroot.FindNode(style)(StyleNode);
    IF cstyle=NIL THEN
      NEW(cstyle);
      IF cstyle#NIL THEN
        cstyle.shearAngle:=style.shearAngle;
        cstyle.rotateAngle:=style.rotateAngle;
        cstyle.emboldenX:=style.emboldenX;
        cstyle.emboldenY:=style.emboldenY;
        cstyle.cache:=size.cache;
        cstyle.nextroot:=avl.Create();
        IF cstyle.nextroot=NIL THEN
          DISPOSE(cstyle); RETURN NIL;
        END;
        cstyle.NewNodeReference;
      ELSE
        cstyle.NodeUsed;
      END;
      size.nextroot.Add(cstyle);
      size.cache.NewData(s.SIZE(StyleNode)+s.SIZE(avl.Root));
    END;
  END;
  RETURN cstyle;
END Cache;

PROCEDURE (style:StyleNode) Cache(glyph:CacheNode):CacheNode;

VAR cglyph : GlyphNode;

BEGIN
  WITH glyph: GlyphNode DO
    cglyph:=style.nextroot.FindNode(glyph)(GlyphNode);
    IF cglyph=NIL THEN
      NEW(cglyph);
      IF cglyph#NIL THEN
        cglyph.code:=glyph.code;
        NEW(cglyph.glyph);
        cglyph.infoobtained:=FALSE;
        cglyph.cache:=style.cache;
        cglyph.NewNodeReference;
      ELSE
        cglyph.NodeUsed;
      END;
      style.nextroot.Add(cglyph);
      style.cache.NewData(s.SIZE(GlyphNode)+s.SIZE(df.GlyphMap));
    END;
  END;
  RETURN cglyph;
END Cache;

PROCEDURE (node:GlyphNode) Destruct*;

BEGIN
  g.FreeRaster(node.raster,node.glyph.bmModulo*8,node.glyph.bmRows);
  DISPOSE(node.glyph);
  node.Destruct^;
END Destruct;

PROCEDURE (node:GlyphNode) InitGlyphMap(engine:df.GlyphEnginePtr);

(* Remember to obtain library before! *)

VAR glyph : df.GlyphMapPtr;
    bool  : BOOLEAN;

BEGIN
  IF (node.raster=NIL) OR ~node.infoobtained THEN
    bool:=ObtainInfo(engine,df.glyphMap,s.ADR(glyph),u.done);
    IF NOT(bool) THEN
      node.infoobtained:=TRUE;
      e.CopyMemAPTR(glyph,node.glyph,s.SIZE(df.GlyphMap));
      node.glyph.bitMap:=NIL;

      io.WriteString("x0: "); io.WriteInt(glyph.x0,7); io.WriteLn;
      io.WriteString("y0: "); io.WriteInt(glyph.y0,7); io.WriteLn;
      io.WriteString("x1: "); io.WriteInt(glyph.x1,7); io.WriteLn;
      io.WriteString("y1: "); io.WriteInt(glyph.y1,7); io.WriteLn;
  
      IF node.raster=NIL THEN
        node.raster:=g.AllocRaster(glyph.bmModulo*8,glyph.bmRows);
      END;
      IF node.raster#NIL THEN
        e.CopyMemAPTR(glyph.bitMap,node.raster,glyph.bmModulo*glyph.bmRows);
  
        node.cache.NewData(glyph.bmModulo*glyph.bmRows);
  
        IF glyph.bmModulo*glyph.bmRows>node.cache(FontCache).clearmemsize THEN
          IF node.cache(FontCache).clearmemreg#NIL THEN
            e.FreeMem(node.cache(FontCache).clearmemreg,node.cache(FontCache).clearmemsize);
          END;
          node.cache(FontCache).clearmemreg:=e.AllocMem(glyph.bmModulo*glyph.bmRows,LONGSET{e.chip,e.memClear});
          IF node.cache(FontCache).clearmemreg#NIL THEN
            node.cache(FontCache).clearmemsize:=glyph.bmModulo*glyph.bmRows;
          ELSE
            node.cache(FontCache).clearmemsize:=0;
          END;
        END;
      END;
  
      bool:=ReleaseInfo(engine,df.glyphMap,glyph,u.done);
    END;
  END;
END InitGlyphMap;

PROCEDURE (node:GlyphNode) ObtainBitMap(bitmap:g.BitMapPtr;color:INTEGER;VAR mask:g.PLANEPTR):BOOLEAN;

VAR i : INTEGER;

BEGIN
  IF node.raster=NIL THEN
    RETURN FALSE;
  ELSE
    g.InitBitMap(bitmap^,8,node.glyph.bmModulo*8,node.glyph.bmRows);
    mask:=node.raster;
    IF bitmap#NIL THEN
      FOR i:=0 TO 7 DO
        IF i IN s.VAL(SET,color) THEN
          bitmap.planes[i]:=node.raster;
        ELSE
          bitmap.planes[i]:=node.cache(FontCache).clearmemreg;
        END;
      END;
    END;
    RETURN TRUE;
  END;
END ObtainBitMap;



(* Cache for fonts *)

VAR fontcache : FontCache;



(* Font class *)

TYPE Font * = POINTER TO FontDesc;
     FontDesc * = RECORD(l.NodeDesc)
       path,name,                        (* excluding ".font" *)
       otagname,
       enginename  : ARRAY 80 OF CHAR;   (* including ".library" *)
       engine      : df.GlyphEnginePtr;
       library     : FontLibraryPtr;
       tagbase     : u.TagListPtr;
       tagbasesize : LONGINT;

(* Never call a method of the following objects! Use the c* objects instead! *)

       font        : FontNode;           (* Node of the font, as it would look in the AVL caching tree *)
       resolution  : ResolutionNode;     (* Resolution used AT THE MOMENT! *)
       size        : SizeNode;           (* Size used AT THE MOMENT! *)
       style       : StyleNode;          (* Style used AT THE MOMENT! *)
       glyph     * : GlyphNode;          (* Glyph used AT THE MOMENT! *)

(* Use the methods of these objects! *)

       cfont       : FontNode;           (* Pointer to the actual node in the caching tree *)
       cresolution : ResolutionNode;
       csize       : SizeNode;
       cstyle      : StyleNode;
       cglyph    * : GlyphNode;
     END;


CONST startResolution = 0;
      startSize       = 1;
      startStyle      = 2;
      startGlyph      = 3;

PROCEDURE (font:Font) DoCaching(level:INTEGER);

BEGIN
  IF level<=startResolution THEN
    font.cresolution:=font.cfont.Cache(font.resolution)(ResolutionNode);
  END;
  IF level<=startSize THEN
    font.csize:=font.cresolution.Cache(font.size)(SizeNode);
  END;
  IF level<=startStyle THEN
    font.cstyle:=font.csize.Cache(font.style)(StyleNode);
  END;
  IF level<=startGlyph THEN
    font.cglyph:=font.cstyle.Cache(font.glyph)(GlyphNode);
  END;
END DoCaching;

PROCEDURE (font:Font) Destruct*;

BEGIN
  IF font.tagbase#NIL THEN
    e.FreeMem(font.tagbase,font.tagbasesize);
  END;
  IF font.library#NIL THEN
    IF font.engine#NIL THEN
      font.library.Obtain;
      CloseEngine(font.engine);
      font.library.Release;
    END;
    font.library.Destruct;
  END;
  IF font.resolution#NIL THEN DISPOSE(font.resolution); END;
  IF font.size#NIL THEN DISPOSE(font.size); END;
  IF font.style#NIL THEN DISPOSE(font.style); END;
  IF font.glyph#NIL THEN DISPOSE(font.glyph); END;
  font.Destruct^;
END Destruct;

PROCEDURE (font:Font) ObtainBitMap*(bitmap:g.BitMapPtr;color:INTEGER;VAR mask:g.PLANEPTR):BOOLEAN;

BEGIN
  IF font.cglyph.raster=NIL THEN
    font.library.Obtain;
    font.cglyph.InitGlyphMap(font.engine);
    font.library.Release;
  END;
  RETURN font.cglyph.ObtainBitMap(bitmap,color,mask);
END ObtainBitMap;

PROCEDURE (font:Font) BlitCharPix*(rast:g.RastPortPtr;x,y:INTEGER):LONGREAL;

(* Returns the width of the blitted char in pixels *)

VAR bitmap : g.BitMap;
    mask   : g.PLANEPTR;
    bool   : BOOLEAN;
    glyph  : df.GlyphMapPtr;

BEGIN
  bool:=font.ObtainBitMap(s.ADR(bitmap),rast.fgPen,mask);
  IF bool THEN
    glyph:=font.cglyph.glyph;
    g.BltMaskBitMapRastPort(s.ADR(bitmap),0,0,rast,x-glyph.x0+1,y-glyph.y0+1,bitmap.bytesPerRow*8,bitmap.rows,s.VAL(s.BYTE,SHORTSET{h.abc,h.abnc,h.anbc}),mask);

(* Debugging *)
    g.Move(rast,x,y);
    g.Draw(rast,x+4,y);
(*    RETURN glyph.blackWidth;*)
    RETURN font.csize.height*1/72*font.cresolution.xdpi*FixedToReal(glyph.width);
  ELSE
    RETURN -1;
  END;
END BlitCharPix;

PROCEDURE (font:Font) BlitCharMM*(rast:g.RastPortPtr;x,y:INTEGER):LONGREAL;

(* Returns the width of the blitted char in mm *)

VAR bitmap : g.BitMap;
    mask   : g.PLANEPTR;
    bool   : BOOLEAN;
    glyph  : df.GlyphMapPtr;

BEGIN
  bool:=font.ObtainBitMap(s.ADR(bitmap),rast.fgPen,mask);
  IF bool THEN
    glyph:=font.cglyph.glyph;
    g.BltMaskBitMapRastPort(s.ADR(bitmap),0,0,rast,x-glyph.x0+1,y-glyph.y0+1,bitmap.bytesPerRow*8,bitmap.rows,s.VAL(s.BYTE,SHORTSET{h.abc,h.abnc,h.anbc}),mask);

(* Debugging *)
    g.Move(rast,x,y);
    g.Draw(rast,x+4,y);

    RETURN font.csize.height*1/72/2.54*FixedToReal(glyph.width);
  ELSE
    RETURN -1;
  END;
END BlitCharMM;

(* Style tags *)

CONST shearAngle  * = 1;
      rotateAngle * = 2;
      emboldenX   * = df.emboldenX;
      emboldenY   * = df.emboldenY;
      underLined  * = df.underLined; (* Types see DiskFont *)

(* Attribute tags *)

      txBaseline  * = 100;
      charWidth   * = 101;
      textKerning * = df.textKernPair;
      designKerning * = df.designKernPair;

PROCEDURE (font:Font) Set*(tag,data:e.APTR):BOOLEAN;

VAR bool : BOOLEAN;

BEGIN
  bool:=TRUE;
  font.library.Obtain;
  CASE s.VAL(LONGINT,tag) OF
  | df.deviceDPI   : font.resolution.dpi:=data;
                     font.resolution.xdpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));
                     font.resolution.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),16));
                     font.resolution.ydpi:=s.VAL(LONGINT,s.LSH(s.VAL(LONGSET,data),-16));
                     bool:=SetInfo(font.engine,tag,data,u.done);
                     font.DoCaching(startResolution);
  | df.glyphCode   : font.glyph.code:=data;
                     bool:=SetInfo(font.engine,tag,data,u.done);
                     font.DoCaching(startGlyph);
                     font.cglyph.InitGlyphMap(font.engine);
  | df.glyphCode2  : bool:=SetInfo(font.engine,tag,data,u.done);
  ELSE END;
  font.library.Release;
  RETURN bool;
END Set;

PROCEDURE (font:Font) Set64*(tag:e.APTR;data:LONGREAL):BOOLEAN;

VAR bool : BOOLEAN;

BEGIN
  bool:=TRUE;
  font.library.Obtain;
  CASE s.VAL(LONGINT,tag) OF
  | df.pointHeight : font.size.height:=data;
                     bool:=SetInfo(font.engine,tag,RealToFixed(data),u.done);
                     font.DoCaching(startSize);
  | shearAngle     : font.style.shearAngle:=data;
                     bool:=SetInfo(font.engine,df.shearSin,RealToFixed(mdt.Sin(3.141592654*data/180)),
                                               df.shearCos,RealToFixed(mdt.Cos(3.141592654*data/180)),
                                               u.done);
                     font.DoCaching(startStyle);
  | rotateAngle    : font.style.rotateAngle:=data;
                     bool:=SetInfo(font.engine,df.rotateSin,RealToFixed(mdt.Sin(3.141592654*data/180)),
                                               df.rotateCos,RealToFixed(mdt.Cos(3.141592654*data/180)),
                                               u.done);
                     font.DoCaching(startStyle);
  | emboldenX      : font.style.emboldenX:=data;
                     bool:=SetInfo(font.engine,df.emboldenX,RealToFixed(data),
                                               u.done);
                     font.DoCaching(startStyle);
  | emboldenY      : font.style.emboldenY:=data;
                     bool:=SetInfo(font.engine,df.emboldenY,RealToFixed(data),
                                               u.done);
                     font.DoCaching(startStyle);
  ELSE END;
  font.library.Release;
  RETURN bool;
END Set64;

PROCEDURE (font:Font) Get*(tag:e.APTR;VAR data:e.APTR):BOOLEAN;

VAR data2 : e.APTR;
    bool  : BOOLEAN;

BEGIN
  font.library.Obtain;
  CASE s.VAL(LONGINT,tag) OF
  | txBaseline : (* Returned in pixels *)
                 font.cglyph.InitGlyphMap(font.engine);
                 data:=s.VAL(e.APTR,LONG(font.cglyph.glyph.y0-font.cglyph.glyph.blackTop+1));
  ELSE bool:=ObtainInfo(font.engine,tag,s.ADR(data2),u.done);
       data:=data2;
  END;
  font.library.Release;
  RETURN bool;
END Get;

PROCEDURE (font:Font) Get64*(tag:e.APTR;VAR data:LONGREAL):BOOLEAN;

VAR fixed : df.FIXED;
    long  : LONGINT;
    data2 : e.APTR;
    bool  : BOOLEAN;

BEGIN
  bool:=TRUE;
  font.library.Obtain;
  CASE s.VAL(LONGINT,tag) OF
  | txBaseline : (* Returned in mm *)
                 font.cglyph.InitGlyphMap(font.engine); (* Called because it's not sure that font.Set(glyphCode) was called before (where this funciton call actually should be made). *)
                 long:=font.cglyph.glyph.y0-font.cglyph.glyph.blackTop+1;
                 data:=long/font.cresolution.ydpi*25.4;
  | charWidth  : fixed:=font.cglyph.glyph.width;
                 data:=FixedToReal(fixed)*font.csize.height; (* Now data contains the width of the current glyph in pt. *)
                 data:=data/72*25.4; (* Now data contains width in mm *)
  | textKerning: (* Returns the virtual width of glyph 1 in mm. *)
                 bool:=ObtainInfo(font.engine,df.textKernPair,s.ADR(data2),u.done);
                 fixed:=s.VAL(df.FIXED,data2);
                 data:=FixedToReal(fixed)*font.csize.height; (* Now data contains the width of the current glyph in pt. *)
                 data:=data/72*25.4; (* Now data contains width in mm *)
  | designKerning: (* Returns the virtual width of glyph 1 in mm. *)
                 bool:=ObtainInfo(font.engine,df.designKernPair,s.ADR(data2),u.done);
                 fixed:=s.VAL(df.FIXED,data2);
                 data:=FixedToReal(fixed)*font.csize.height; (* Now data contains the width of the current glyph in pt. *)
                 data:=data/72*25.4; (* Now data contains width in mm *)
  ELSE END;
  font.library.Release;
  RETURN bool;
END Get64;

PROCEDURE NewFont*(path,name:ARRAY OF CHAR):Font;

VAR font        : Font;
    otaghandle  : d.FileHandlePtr;
    info        : d.FileInfoBlockPtr;
    tagbasemem  : e.APTR;
    tagbase     : u.TagListPtr;
    strptr      : e.STRPTR;
    tag,nexttag : u.TagItemPtr;
    long        : LONGINT;
    bool        : BOOLEAN;

BEGIN
  NEW(font);
  IF font#NIL THEN
    NEW(font.font);
    IF font.font=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    COPY(path,font.font.path);
    COPY(name,font.font.name);
    NEW(font.resolution);
    IF font.resolution=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    NEW(font.size);
    IF font.size=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    NEW(font.style);
    IF font.style=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    NEW(font.glyph);
    IF font.glyph=NIL THEN
      font.Destruct; RETURN NIL;
    END;

    font.resolution.dpi:=highBits*300+lowBits*300;
    font.resolution.xdpi:=300;
    font.resolution.ydpi:=300;
    font.size.height:=12;
    font.style.shearAngle:=0;
    font.style.rotateAngle:=0;
    font.style.emboldenX:=0;
    font.style.emboldenY:=0;
    font.glyph.code:=ORD("A");
    font.cfont:=fontcache.Cache(font.font);

    COPY(path,font.path);
    COPY(name,font.name);

    COPY(path,font.otagname);
    st.Append(font.otagname,name);
    st.Append(font.otagname,df.suffix);

(* Reading otag file *)

    otaghandle:=d.Open(font.otagname,d.oldFile);
    IF otaghandle=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    info:=d.AllocDosObjectTags(d.fib,u.done);
    bool:=d.ExamineFH(otaghandle,info^);
    IF NOT(bool) THEN
      font.Destruct; RETURN NIL;
    END;
    tagbasemem:=e.AllocMem(info.size,LONGSET{});
    IF tagbasemem=NIL THEN
      font.Destruct; RETURN NIL;
    END;
    tagbase:=tagbasemem;
    strptr:=tagbasemem;
    long:=d.Read(otaghandle,strptr^,info.size);
    bool:=d.Close(otaghandle);
    font.tagbase:=tagbase;
    font.tagbasesize:=info.size;
    d.FreeDosObject(d.fib,info);

(* Checking size of otag file *)

    tag:=u.FindTagItem(df.fileIdent,tagbase);
    IF (tag#NIL) & (s.VAL(LONGINT,tag.data)=info.size) THEN

(* Resolving addresses *)

      tag:=tagbasemem;
      nexttag:=tag;
      WHILE tag#NIL DO
        IF (s.VAL(LONGSET,df.indirect)*s.VAL(LONGSET,tag.tag))=s.VAL(LONGSET,df.indirect) THEN
          tag.data:=s.VAL(e.APTR,s.VAL(LONGINT,tag.data)+s.VAL(LONGINT,tagbasemem));
        END;
        tag:=u.NextTagItem(nexttag);
      END;

(* Looking for engine *)

      tag:=u.FindTagItem(df.engine,tagbase);
      COPY(s.VAL(e.STRPTR,tag.data)^,font.enginename);
      st.Append(font.enginename,".library");
      font.library:=OpenFontLibrary(font.enginename);
      IF font.library=NIL THEN
        DISPOSE(font);
        RETURN NIL;
      END;

      font.library.Obtain;
      font.engine:=OpenEngine();
      IF font.engine=NIL THEN
        DISPOSE(font);
        font.library.Release;
        RETURN NIL;
      END;
      bool:=b.SetInfo(font.engine,df.oTagPath,s.ADR(font.otagname),
                                  df.oTagList,tagbasemem,
                                  u.done);
      IF bool THEN
        DISPOSE(font);
        font.library.Release;
        RETURN NIL;
      END;

      font.DoCaching(startResolution);
      font.library.Release;

      bool:=font.Set(df.deviceDPI,font.resolution.dpi);
      bool:=font.Set64(df.pointHeight,font.size.height);
      bool:=font.Set(df.glyphCode,font.glyph.code);
    ELSE
      DISPOSE(font);
      RETURN NIL;
    END;
  END;
  RETURN font;
END NewFont;

BEGIN
  baseinuse:=FALSE;
  fontliblist:=l.Create();
  IF fontliblist=NIL THEN
    HALT(20);
  END;

  NEW(fontcache);
  IF fontcache=NIL THEN
    HALT(20);
  END;
  fontcache.Init(1000000);
  fontcache.clearmemreg:=e.AllocMem((256 DIV 8)*200,LONGSET{e.chip,e.memClear});
  fontcache.clearmemsize:=(256 DIV 8)*200;
  IF fontcache.clearmemreg=NIL THEN
    HALT(20);
  END;
CLOSE
  IF fontliblist#NIL THEN
    CloseAllFontLibraries;
    fontliblist.Destruct;
  END;
  IF fontcache#NIL THEN
    IF fontcache.root#NIL THEN
      DISPOSE(fontcache.root);
    END;
    IF fontcache.clearmemreg#NIL THEN
      e.FreeMem(fontcache.clearmemreg,fontcache.clearmemsize);
    END;
    DISPOSE(fontcache);
  END;
END OutlineFonts.

