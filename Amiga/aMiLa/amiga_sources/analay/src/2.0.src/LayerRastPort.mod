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


MODULE LayerRastPort;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       l  : Layers,
       s  : SYSTEM,
       ll : LinkedLists,
       NoGuruRq;

PROCEDURE AllocRastPort*(width,height,depth:INTEGER):g.RastPortPtr;

VAR rast : g.RastPortPtr;
    map  : g.BitMapPtr;
    i    : INTEGER;

BEGIN
  width:=(width+7) DIV 8;
  width:=width*8;
  rast:=NIL;
  rast:=e.AllocMem(s.SIZE(g.RastPort),LONGSET{e.chip,e.memClear});
  IF rast#NIL THEN
    map:=e.AllocMem(s.SIZE(g.BitMap),LONGSET{e.chip,e.memClear});
    IF map#NIL THEN
      g.InitRastPort(rast^);
      g.InitBitMap(map^,depth,width,height);
      FOR i:=0 TO depth-1 DO
        map.planes[i]:=NIL;
        map.planes[i]:=g.AllocRaster(map.bytesPerRow*8,map.rows);
        IF map.planes[i]=NIL THEN
          WHILE i>0 DO
            DEC(i);
            g.FreeRaster(map.planes[i],map.bytesPerRow*8,map.rows);
          END;
          i:=depth+1;
        END;
      END;
      IF i>=depth+1 THEN
        e.FreeMem(map,s.SIZE(g.BitMap));
        e.FreeMem(rast,s.SIZE(g.RastPort));
        rast:=NIL;
      ELSE
        rast.bitMap:=map;
      END;
    ELSE
      e.FreeMem(rast,s.SIZE(g.RastPort));
      rast:=NIL;
    END;
  END;
  RETURN rast;
END AllocRastPort;

PROCEDURE FreeRastPort*(VAR rast:g.RastPortPtr);

VAR map    : g.BitMapPtr;
    width,
    height,
    depth,i: INTEGER;

BEGIN
  map:=rast.bitMap;
  width:=map.bytesPerRow*8;
  height:=map.rows;
  depth:=map.depth;
  FOR i:=0 TO depth-1 DO
    g.FreeRaster(map.planes[i],width,height);
  END;
  e.FreeMem(map,s.SIZE(g.BitMap));
  e.FreeMem(rast,s.SIZE(g.RastPort));
END FreeRastPort;

PROCEDURE AllocBitMap*(width,height,depth:INTEGER):g.BitMapPtr;

VAR map  : g.BitMapPtr;
    i    : INTEGER;

BEGIN
  width:=(width+7) DIV 8;
  width:=width*8;
  map:=e.AllocMem(s.SIZE(g.BitMap),LONGSET{e.chip,e.memClear});
  IF map#NIL THEN
    g.InitBitMap(map^,depth,width,height);
    FOR i:=0 TO depth-1 DO
      map.planes[i]:=NIL;
      map.planes[i]:=g.AllocRaster(map.bytesPerRow*8,map.rows);
      IF map.planes[i]=NIL THEN
        WHILE i>0 DO
          DEC(i);
          g.FreeRaster(map.planes[i],map.bytesPerRow*8,map.rows);
        END;
        i:=depth+1;
      END;
    END;
    IF i>=depth+1 THEN (* Failed *)
      e.FreeMem(map,s.SIZE(g.BitMap));
      map:=NIL;
    ELSE (* All OK! *)
    END;
  END;
  RETURN map;
END AllocBitMap;

PROCEDURE FreeBitMap*(VAR map:g.BitMapPtr);

VAR width,
    height,
    depth,i: INTEGER;

BEGIN
  width:=map.bytesPerRow*8;
  height:=map.rows;
  depth:=map.depth;
  FOR i:=0 TO depth-1 DO
    g.FreeRaster(map.planes[i],width,height);
  END;
  e.FreeMem(map,s.SIZE(g.BitMap));
  map:=NIL;
END FreeBitMap;

TYPE LayerRastPort * = POINTER TO LayerRastPortDesc;
     LayerRastPortDesc * = RECORD(ll.NodeDesc)
       bitmap    * : g.BitMapPtr;
       layerinfo * : g.LayerInfoPtr;
       layer     * : g.LayerPtr;
       rast      * : g.RastPortPtr;
     END;

PROCEDURE AllocLayerRast*(width,height,depth:INTEGER):LayerRastPort;

VAR layerrast : LayerRastPort;

BEGIN
  NEW(layerrast);
  IF layerrast#NIL THEN
    layerrast.bitmap:=AllocBitMap(width,height,depth);
    IF layerrast.bitmap#NIL THEN
      width:=layerrast.bitmap.bytesPerRow*8;
      height:=layerrast.bitmap.rows;
      depth:=layerrast.bitmap.depth;
      layerrast.layerinfo:=l.NewLayerInfo();
      IF layerrast.layerinfo#NIL THEN
        layerrast.layer:=l.CreateUpfrontLayer(layerrast.layerinfo,layerrast.bitmap,0,0,width-1,height-1,SET{g.layerSmart},NIL);
        IF layerrast.layer#NIL THEN
          layerrast.rast:=layerrast.layer.rp;
        END;
      END;
    END;
    IF (layerrast.bitmap=NIL) OR (layerrast.layerinfo=NIL) OR (layerrast.layer=NIL) THEN
      DISPOSE(layerrast); layerrast:=NIL;
    END;
  END;
  RETURN layerrast;
END AllocLayerRast;

PROCEDURE FreeLayerRast*(VAR layerrast:LayerRastPort);

VAR bool : BOOLEAN;

BEGIN
  bool:=l.DeleteLayer(layerrast.layer);
  l.DisposeLayerInfo(layerrast.layerinfo);
  FreeBitMap(layerrast.bitmap);
  DISPOSE(layerrast); layerrast:=NIL;
END FreeLayerRast;

(*VAR layerrast : LayerRastPort;
    rast      : g.RastPortPtr;

BEGIN
  layerrast:=AllocLayerRast(320,100,2);
  rast:=layerrast.rast;
  g.Move(rast,0,0);
  g.Draw(rast,1000,1000);
  g.RectFill(rast,-10,-10,400,400);
  FreeLayerRast(layerrast);*)
END LayerRastPort.

