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


MODULE MenuManager;

IMPORT I : Intuition,
       g : Graphics,
       d : Dos,
       e : Exec,
       s : SYSTEM,
       u : Utility,
       l : LinkedLists,
       gt: GadTools,
       st: Strings;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

VAR firstmenu,actmenu : I.MenuPtr;
    firstitem,actitem : I.MenuItemPtr;
    firstsub,actsub   : I.MenuItemPtr;
    itemwidth,itemcommandwidth,
    stripheight,subcommandwidth,
    subwidth,actsubnum,
    menuxpos,menuwidth: INTEGER;
    subheight         : ARRAY 100 OF INTEGER;
    screen            : I.ScreenPtr;
    rast              : g.RastPortPtr;
    menus             : UNTRACED POINTER TO ARRAY OF gt.NewMenu;
    menucount         : INTEGER;
    cutstr            : ARRAY 2 OF CHAR;

PROCEDURE StartMenu*(window:I.WindowPtr);

BEGIN
  NEW(menus,100);
  menucount:=0;
  firstmenu:=NIL;
  actmenu:=NIL;
  firstitem:=NIL;
  actitem:=NIL;
  firstsub:=NIL;
  actsub:=NIL;
  itemwidth:=0;
  itemcommandwidth:=0;
  stripheight:=0;
  subcommandwidth:=0;
  subwidth:=0;
  menuxpos:=0;
  screen:=window.wScreen;
  rast:=s.ADR(screen.rastPort);
END StartMenu;

(*PROCEDURE DoSubStrip(first:I.MenuItemPtr;maxheight,xpos,move:INTEGER);

VAR number,diff,width,add : INTEGER;
    item                  : I.MenuItemPtr;
    intui,intui2          : I.IntuiTextPtr;
    image                 : I.ImagePtr;

BEGIN
  number:=1;
  WHILE subheight[actsubnum] DIV number>maxheight DO
    INC(number);
  END;

  item:=first;
  WHILE item#NIL DO
    subwidth:=item.width;
    subcommandwidth:=item.height;
    item.height:=rast.font.ySize+2;
    item:=item.nextItem;
  END;

  width:=subwidth+subcommandwidth+10;
  diff:=0;
  add:=0;
  item:=first;
  WHILE item#NIL DO
    IF item.width#-1 THEN
      intui:=s.VAL(I.IntuiTextPtr,item.itemFill);
      intui:=intui.nextText;
      IF intui#NIL THEN
        intui.leftEdge:=width-intui.leftEdge;
      END;
    ELSE
      image:=s.VAL(I.ImagePtr,item.itemFill);
      image.width:=width-2;
      item.height:=5;
    END;
    item.width:=width;
    IF item.topEdge+item.height-diff>subheight[actsubnum] DIV number THEN
      diff:=item.topEdge;
      INC(add);
    END;
    DEC(item.topEdge,diff);
    INC(item.leftEdge,add*(width+4)+move);

    item:=item.nextItem;
  END;

  diff:=number*(width+4);
  diff:=screen.width-(diff+xpos+move)-6;
  IF diff<0 THEN
    item:=first;
    WHILE item#NIL DO
      item.leftEdge:=item.leftEdge+diff;
      item:=item.nextItem;
    END;
  END;
END DoSubStrip;

PROCEDURE DoStrip(first:I.MenuItemPtr;maxheight,xpos:INTEGER);

VAR number,diff,width,add : INTEGER;
    item                  : I.MenuItemPtr;
    intui,intui2          : I.IntuiTextPtr;
    image                 : I.ImagePtr;

BEGIN
  number:=1;
  WHILE stripheight DIV number>maxheight DO
    INC(number);
  END;

  width:=itemwidth+itemcommandwidth+10;
  IF width<menuwidth THEN
    width:=menuwidth;
  END;
  diff:=0;
  add:=0;
  item:=first;
  WHILE item#NIL DO
    IF item.width#-1 THEN
      intui:=s.VAL(I.IntuiTextPtr,item.itemFill);
      intui:=intui.nextText;
      IF intui#NIL THEN
        intui.leftEdge:=width-intui.leftEdge;
      END;
    ELSE
      image:=s.VAL(I.ImagePtr,item.itemFill);
      image.width:=width-2;
    END;
    item.width:=width;
    IF item.topEdge+item.height-diff>stripheight DIV number THEN
      diff:=item.topEdge;
      INC(add);
    END;
    DEC(item.topEdge,diff);
    INC(item.leftEdge,add*(width+4));
    item:=item.nextItem;
  END;

  diff:=number*(width+4);
  diff:=screen.width-(diff+xpos)-6;
  IF diff<0 THEN
    item:=first;
    WHILE item#NIL DO
      item.leftEdge:=item.leftEdge+diff;
      item:=item.nextItem;
    END;
  END;

  actsubnum:=0;
  item:=first;
  WHILE item#NIL DO
    DoSubStrip(item.subItem,maxheight-item.topEdge-2,xpos,itemwidth+10);
    INC(actsubnum);
    item:=item.nextItem;
  END;
END DoStrip;*)

PROCEDURE AllocName(name:ARRAY OF CHAR):s.ADDRESS;

VAR point : UNTRACED POINTER TO ARRAY OF CHAR;

BEGIN
  NEW(point,LEN(name)+1);
  COPY(name,point^);
  RETURN s.ADR(point^);
END AllocName;

PROCEDURE NewMenu*(name:e.STRPTR);

VAR lastmenu : I.MenuPtr;

BEGIN
  menus[menucount].type:=gt.title;
  menus[menucount].label:=name;
  menus[menucount].commKey:=NIL;
  menus[menucount].flags:=SET{};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  IF firstitem#NIL THEN
    DoStrip(firstitem,screen.height-(screen.barHeight+4),actmenu.leftEdge);
  END;
  lastmenu:=actmenu;
  actmenu:=NIL;
  NEW(actmenu);
  IF lastmenu#NIL THEN
    lastmenu.nextMenu:=actmenu;
  ELSE
    firstmenu:=actmenu;
  END;

  actmenu.leftEdge:=menuxpos;
  actmenu.topEdge:=0;
  actmenu.width:=g.TextLength(rast,name,st.Length(name))+10;
  menuwidth:=actmenu.width;
  INC(menuxpos,actmenu.width+10);
  actmenu.flags:={I.miDrawn,I.menuEnabled};
  actmenu.menuName:=AllocName(name);

  itemwidth:=0;
  itemcommandwidth:=0;
  stripheight:=0;
  firstitem:=NIL;
  actitem:=NIL;
  actsubnum:=-1;*)
END NewMenu;

(*PROCEDURE AllocIntuiText(left,right:ARRAY OF CHAR;check:BOOLEAN):I.IntuiTextPtr;

VAR intui,intui2 : I.IntuiTextPtr;

BEGIN
  NEW(intui);
  intui.frontPen:=screen.detailPen;
  intui.backPen:=screen.blockPen;
  intui.drawMode:=g.jam2;
  intui.leftEdge:=2;
  intui.topEdge:=1;
  IF check THEN
    INC(intui.leftEdge,I.checkWidth);
  END;
  intui.iTextFont:=NIL;
  intui.iText:=AllocName(left);
  intui.nextText:=NIL;
  IF right[0]#0X THEN
    NEW(intui2);
    intui2.frontPen:=screen.detailPen;
    intui2.backPen:=screen.blockPen;
    intui2.drawMode:=g.jam2;
    intui2.leftEdge:=g.TextLength(rast,right,st.Length(right))+2;
    intui2.topEdge:=1;
    intui2.iTextFont:=NIL;
    intui2.iText:=AllocName(right);
    intui2.nextText:=NIL;
    intui.nextText:=intui2;
  END;
  RETURN intui;
END AllocIntuiText;

PROCEDURE Item(left,right:ARRAY OF CHAR;cut:CHAR;check,checked:BOOLEAN);

VAR lastitem : I.MenuItemPtr;
    width    : INTEGER;
    str      : ARRAY 2 OF CHAR;

BEGIN
  lastitem:=actitem;
  actitem:=NIL;
  NEW(actitem);
  IF lastitem#NIL THEN
    lastitem.nextItem:=actitem;
  ELSE
    firstitem:=actitem;
    actmenu.firstItem:=firstitem;
  END;

  actitem.leftEdge:=0;
  actitem.topEdge:=stripheight;
  actitem.width:=0;
  actitem.height:=rast.font.ySize+2;
  INC(stripheight,actitem.height+(actitem.height DIV 10));
  actitem.flags:={I.itemText,I.itemEnabled,I.highComp};
  actitem.mutualExclude:=LONGSET{};
  actitem.itemFill:=AllocIntuiText(left,right,check);
  actitem.selectFill:=NIL;
  actitem.command:=cut;
  actitem.subItem:=NIL;
  IF cut#0X THEN
    INCL(actitem.flags,I.commSeq);
    str[0]:=cut;
    str[1]:=0X;
    width:=g.TextLength(rast,str,1)+24;
    IF width>itemcommandwidth THEN
      itemcommandwidth:=width;
    END;
  END;
  IF right[0]#0X THEN
    width:=g.TextLength(rast,right,st.Length(right));
    IF width>itemcommandwidth THEN
      itemcommandwidth:=width;
    END;
  END;
  IF check THEN
    INCL(actitem.flags,I.checkIt);
    INCL(actitem.flags,I.menuToggle);
    IF checked THEN
      INCL(actitem.flags,I.checked);
    END;
    width:=g.TextLength(rast,left,st.Length(left));
    INC(width,I.checkWidth);
    IF width>itemwidth THEN
      itemwidth:=width;
    END;
  ELSE
    width:=g.TextLength(rast,left,st.Length(left));
    IF width>itemwidth THEN
      itemwidth:=width;
    END;
  END;
  INC(actsubnum);
  subheight[actsubnum]:=0;
  subwidth:=0;
  subcommandwidth:=0;
  firstsub:=NIL;
  actsub:=NIL;
END Item;

PROCEDURE SubItem(left,right:ARRAY OF CHAR;cut:CHAR;check,checked:BOOLEAN);

VAR lastsub : I.MenuItemPtr;
    width   : INTEGER;
    str     : ARRAY 2 OF CHAR;

BEGIN
  lastsub:=actsub;
  actsub:=NIL;
  NEW(actsub);
  IF lastsub#NIL THEN
    lastsub.nextItem:=actsub;
  ELSE
    firstsub:=actsub;
    actitem.subItem:=firstsub;
  END;

  actsub.leftEdge:=0;
  actsub.topEdge:=subheight[actsubnum]-1;
  actsub.width:=0;
  actsub.height:=rast.font.ySize+2;
  INC(subheight[actsubnum],actsub.height+(actsub.height DIV 10));
  actsub.flags:={I.itemText,I.itemEnabled,I.highComp};
  actsub.mutualExclude:=LONGSET{};
  actsub.itemFill:=AllocIntuiText(left,right,check);
  actsub.selectFill:=NIL;
  actsub.command:=cut;
  actsub.subItem:=NIL;
  IF cut#0X THEN
    INCL(actsub.flags,I.commSeq);
    str[0]:=cut;
    str[1]:=0X;
    width:=g.TextLength(rast,str,1)+24;
    IF width>subcommandwidth THEN
      subcommandwidth:=width;
    END;
  END;
  IF right[0]#0X THEN
    width:=g.TextLength(rast,right,st.Length(right));
    IF width>subcommandwidth THEN
      subcommandwidth:=width;
    END;
  END;
  IF check THEN
    INCL(actsub.flags,I.checkIt);
    INCL(actsub.flags,I.menuToggle);
    IF checked THEN
      INCL(actsub.flags,I.checked);
    END;
    width:=g.TextLength(rast,left,st.Length(left));
    INC(width,I.checkWidth);
    IF width>subwidth THEN
      subwidth:=width;
    END;
  ELSE
    width:=g.TextLength(rast,left,st.Length(left));
    IF width>subwidth THEN
      subwidth:=width;
    END;
  END;
  actsub.width:=subwidth;
  actsub.height:=subcommandwidth;
END SubItem;*)

PROCEDURE Separator*;

VAR lastitem : I.MenuItemPtr;
    image    : I.ImagePtr;

BEGIN
  menus[menucount].type:=gt.item;
  menus[menucount].label:=gt.barLabel;
  menus[menucount].commKey:=NIL;
  menus[menucount].flags:=SET{};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  lastitem:=actitem;
  actitem:=NIL;
  NEW(actitem);
  IF lastitem#NIL THEN
    lastitem.nextItem:=actitem;
  ELSE
    firstitem:=actitem;
    actmenu.firstItem:=firstitem;
  END;

  NEW(image);
  image.leftEdge:=1;
  image.topEdge:=1;
  image.width:=0;
  image.height:=2;
  image.depth:=0;
  image.imageData:=NIL;
  image.planePick:=SHORTSET{};
  image.planeOnOff:=SHORTSET{};
  image.nextImage:=NIL;

  actitem.leftEdge:=0;
  actitem.topEdge:=stripheight;
  actitem.width:=-1;
  actitem.height:=5;
  INC(stripheight,5);
  actitem.flags:=I.highNone;
  actitem.mutualExclude:=LONGSET{};
  actitem.itemFill:=image;
  actitem.selectFill:=NIL;
  actitem.command:=0X;
  actitem.subItem:=NIL;
  INC(actsubnum);*)
END Separator;

PROCEDURE SubSeparator*;

VAR lastsub : I.MenuItemPtr;
    image   : I.ImagePtr;

BEGIN
  menus[menucount].type:=gt.sub;
  menus[menucount].label:=gt.barLabel;
  menus[menucount].commKey:=NIL;
  menus[menucount].flags:=SET{};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  lastsub:=actsub;
  actsub:=NIL;
  NEW(actsub);
  IF lastsub#NIL THEN
    lastsub.nextItem:=actsub;
  ELSE
    firstsub:=actsub;
    actitem.subItem:=firstsub;
  END;

  NEW(image);
  image.leftEdge:=1;
  image.topEdge:=1;
  image.width:=0;
  image.height:=2;
  image.depth:=0;
  image.imageData:=NIL;
  image.planePick:=SHORTSET{};
  image.planeOnOff:=SHORTSET{};
  image.nextImage:=NIL;

  actsub.leftEdge:=0;
  actsub.topEdge:=subheight[actsubnum]-1;
  actsub.width:=-1;
  actsub.height:=5;
  INC(subheight[actsubnum],5);
  actsub.flags:=I.highNone;
  actsub.mutualExclude:=LONGSET{};
  actsub.itemFill:=image;
  actsub.selectFill:=NIL;
  actsub.command:=0X;
  actsub.subItem:=NIL;*)
END SubSeparator;

PROCEDURE NewItem*(text:e.STRPTR;cut:CHAR);

BEGIN
  menus[menucount].type:=gt.item;
  menus[menucount].label:=text;
  IF cut#0X THEN
    cutstr[0]:=cut;
    cutstr[1]:=0X;
    menus[menucount].commKey:=AllocName(cutstr);
  ELSE
    menus[menucount].commKey:=NIL;
  END;
  menus[menucount].flags:=SET{I.itemText,I.highComp};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  Item(text,"",cut,FALSE,FALSE);*)
END NewItem;

PROCEDURE NewItem2*(text,cut:e.STRPTR);

BEGIN
  menus[menucount].type:=gt.item;
  menus[menucount].label:=text;
  menus[menucount].commKey:=cut;
  menus[menucount].flags:=SET{I.itemText,I.highComp,gt.commandString};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  Item(text,cut,0X,FALSE,FALSE);*)
END NewItem2;

PROCEDURE NewCheckItem*(text:e.STRPTR;cut:CHAR;checked:BOOLEAN);

BEGIN
  menus[menucount].type:=gt.item;
  menus[menucount].label:=text;
  IF cut#0X THEN
    cutstr[0]:=cut;
    cutstr[1]:=0X;
    menus[menucount].commKey:=AllocName(cutstr);
  ELSE
    menus[menucount].commKey:=NIL;
  END;
  menus[menucount].flags:=SET{I.itemText,I.highComp,I.checkIt,I.menuToggle};
  IF checked THEN
    INCL(menus[menucount].flags,I.checked);
  END;
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  Item(text,"",cut,TRUE,checked);*)
END NewCheckItem;

PROCEDURE NewCheckItem2*(text,cut:e.STRPTR;checked:BOOLEAN);

BEGIN
  menus[menucount].type:=gt.item;
  menus[menucount].label:=text;
  menus[menucount].commKey:=cut;
  menus[menucount].flags:=SET{I.itemText,I.highComp,gt.commandString,I.checkIt,I.menuToggle};
  IF checked THEN
    INCL(menus[menucount].flags,I.checked);
  END;
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  Item(text,cut,0X,TRUE,checked);*)
END NewCheckItem2;

PROCEDURE NewSubItem*(text:e.STRPTR;cut:CHAR);

BEGIN
  menus[menucount].type:=gt.sub;
  menus[menucount].label:=text;
  IF cut#0X THEN
    cutstr[0]:=cut;
    cutstr[1]:=0X;
    menus[menucount].commKey:=AllocName(cutstr);
  ELSE
    menus[menucount].commKey:=NIL;
  END;
  menus[menucount].flags:=SET{I.itemText,I.highComp};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  SubItem(text,"",cut,FALSE,FALSE);*)
END NewSubItem;

PROCEDURE NewSubItem2*(text,cut:e.STRPTR);

BEGIN
  menus[menucount].type:=gt.sub;
  menus[menucount].label:=text;
  menus[menucount].commKey:=cut;
  menus[menucount].flags:=SET{I.itemText,I.highComp,gt.commandString};
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  SubItem(text,cut,0X,FALSE,FALSE);*)
END NewSubItem2;

PROCEDURE NewSubCheckItem*(text:e.STRPTR;cut:CHAR;checked:BOOLEAN);

BEGIN
  menus[menucount].type:=gt.sub;
  menus[menucount].label:=text;
  IF cut#0X THEN
    cutstr[0]:=cut;
    cutstr[1]:=0X;
    menus[menucount].commKey:=AllocName(cutstr);
  ELSE
    menus[menucount].commKey:=NIL;
  END;
  menus[menucount].flags:=SET{I.itemText,I.highComp,I.checkIt,I.menuToggle};
  IF checked THEN
    INCL(menus[menucount].flags,I.checked);
  END;
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  SubItem(text,"",cut,TRUE,checked);*)
END NewSubCheckItem;

PROCEDURE NewSubCheckItem2*(text,cut:e.STRPTR;checked:BOOLEAN);

BEGIN
  menus[menucount].type:=gt.sub;
  menus[menucount].label:=text;
  menus[menucount].commKey:=cut;
  menus[menucount].flags:=SET{I.itemText,I.highComp,gt.commandString,I.checkIt,I.menuToggle};
  IF checked THEN
    INCL(menus[menucount].flags,I.checked);
  END;
  menus[menucount].mutualExclude:=LONGSET{};
  menus[menucount].userData:=NIL;
  INC(menucount);
(*  SubItem(text,cut,0X,TRUE,checked);*)
END NewSubCheckItem2;

PROCEDURE EndMenu*():I.MenuPtr;

BEGIN
  menus[menucount].type:=gt.end;
  firstmenu:=gt.CreateMenus(menus^,gt.fullMenu,I.LTRUE,
                                  u.done);
  DISPOSE(menus);
(*  IF firstitem#NIL THEN
    DoStrip(firstitem,screen.height-(screen.barHeight+4),actmenu.leftEdge);
  END;*)
  RETURN firstmenu;
END EndMenu;

(*PROCEDURE FreeName(VAR point:UNTRACED POINTER TO ARRAY OF CHAR);

BEGIN
  DISPOSE(point);
END FreeName;*)

PROCEDURE FreeIntuiText(VAR intui:I.IntuiTextPtr);

BEGIN
  DISPOSE(intui.iText);
  IF intui.nextText#NIL THEN
    FreeIntuiText(intui.nextText);
  END;
  DISPOSE(intui);
END FreeIntuiText;

PROCEDURE FreeItem(VAR item:I.MenuItemPtr);

BEGIN
  IF I.itemText IN item.flags THEN
    FreeIntuiText(item.itemFill);
  ELSE
    DISPOSE(item.itemFill);
  END;
  DISPOSE(item);
END FreeItem;

PROCEDURE FreeMenu*(VAR menu:I.MenuPtr);

VAR freemenu          : I.MenuPtr;
    item,sub,freeitem : I.MenuItemPtr;

BEGIN
  WHILE menu#NIL DO
    item:=menu.firstItem;
    WHILE item#NIL DO
      sub:=item.subItem;
      WHILE sub#NIL DO
        freeitem:=sub;
        sub:=sub.nextItem;
        FreeItem(freeitem);
      END;
      freeitem:=item;
      item:=item.nextItem;
      FreeItem(freeitem);
    END;
    freemenu:=menu;
    menu:=menu.nextMenu;
    DISPOSE(freemenu.menuName);
    DISPOSE(freemenu);
  END;
END FreeMenu;

END MenuManager.
