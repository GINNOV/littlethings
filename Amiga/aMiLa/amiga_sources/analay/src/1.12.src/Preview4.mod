(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
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


MODULE Preview4;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       df : DiskFont,
       fr : FileReq,
       it : IntuitionTools,
       tt : TextTools,
       gt : GraphicsTools,
       gm : GadgetManager,
       wm : WindowManager,
       pi : PreviewImages,
       pt : Pointers,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       s6 : SuperCalcTools6,
       s7 : SuperCalcTools7,
       s8 : SuperCalcTools8,
       s9 : SuperCalcTools9,
       s10: SuperCalcTools10,
       s11: SuperCalcTools11,
       s12: SuperCalcTools12,
       s13: SuperCalcTools13,
       s14: SuperCalcTools14,
       p1 : Preview1,
       p2 : Preview2,
       p3 : Preview3,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR i,a,j       : INTEGER;
    class     * : LONGSET;
    code      * : INTEGER;
    address   * : s.ADDRESS;

PROCEDURE GetCommand*(string:ARRAY OF CHAR;VAR pos:INTEGER):INTEGER;

VAR ret : INTEGER;

BEGIN
  ret:=0;
  IF string[pos]="^" THEN
    INC(pos);
    ret:=1;
  ELSIF string[pos]="_" THEN
    INC(pos);
    ret:=2;
  ELSIF st.OccursPos(string,"\\frac",pos)=pos THEN
    INC(pos,5);
    ret:=3;
  ELSIF st.OccursPos(string,"\\sqrt",pos)=pos THEN
    INC(pos,5);
    ret:=4;
  END;
  RETURN ret;
END GetCommand;

PROCEDURE GetParameter*(string:ARRAY OF CHAR;VAR pos:INTEGER;VAR par:ARRAY OF CHAR);

VAR i,count : INTEGER;

BEGIN
  INC(pos);
  count:=1;
  i:=0;
  LOOP
    IF pos>=st.Length(string) THEN
      EXIT;
    END;
    IF (string[pos]="{") OR (string[pos]="[") THEN
      INC(count);
    ELSIF (string[pos]="}") OR (string[pos]="]") THEN
      DEC(count);
    END;
    IF count=0 THEN
      EXIT;
    END;
    par[i]:=string[pos];
    INC(pos);
    INC(i);
  END;
  par[i]:=0X;
END GetParameter;

PROCEDURE AddFuncSize*(font,size:l.Node);

VAR node : l.Node;
    bool : BOOLEAN;

BEGIN
  bool:=FALSE;
  node:=font(p1.Font).sizes.head;
  WHILE (node#NIL) AND NOT(bool) DO
    IF node(p1.FontSize).size=size(p1.FontSize).size THEN
      bool:=TRUE;
    END;
    node:=node.next;
  END;
  IF NOT(bool) THEN
    node:=font(p1.Font).fsizes.head;
    WHILE (node#NIL) AND NOT(bool) DO
      IF node(p1.FontSize).size=size(p1.FontSize).size THEN
        bool:=TRUE;
      END;
      node:=node.next;
    END;
    IF NOT(bool) THEN
      node:=NIL;
      NEW(node(p1.FontSize));
      node(p1.FontSize).size:=size(p1.FontSize).size;
      node(p1.FontSize).used:=TRUE;
      font(p1.Font).fsizes.AddTail(node);
    END;
  END;
END AddFuncSize;

PROCEDURE PrintFunc*(rast:g.RastPortPtr;text:ARRAY OF CHAR;VAR pos:INTEGER;font,size:l.Node;VAR x,y,width,height,overtop,underbottom:LONGREAL;print:BOOLEAN);

VAR oldzoom,
    xpos,ypos,
    command,i       : INTEGER;
    fact,oldsize,wi,
    he,top,bottom,
    x2,y2,wi2,he2,
    top2,bottom2,
    width2,height2,
    lastwi          : LONGREAL;
    string          : ARRAY 2 OF CHAR;
    par1,par2,paro  : UNTRACED POINTER TO ARRAY OF CHAR;
    newsize         : l.Node;

BEGIN
  IF print THEN
    AddFuncSize(font,size);
  END;
  oldzoom:=p1.zoom;
  p1.zoom:=100;
  p1.CorrectPageDimensions;
  oldsize:=size(p1.FontSize).size;
  fact:=p1.PointToCent(size(p1.FontSize).size)/p1.globals.pagewidth*p1.globals.pagepicx/50;
(*  fact:=p2.GetFontPixelSize(size(p1.FontSize).size)/50;*)
  size(p1.FontSize).size:=50;
  p2.SetFontRast(p1.fontrast,font,size);
  size(p1.FontSize).size:=oldsize;
  p1.zoom:=oldzoom;
  p1.CorrectPageDimensions;

  width:=0;
  height:=p1.PointToCent(size(p1.FontSize).size);
  overtop:=0;
  underbottom:=0;
  lastwi:=0;
  WHILE (text[pos]#"$") AND (pos<st.Length(text)) DO
    p2.SetFont(rast,font,size);
    command:=GetCommand(text,pos);
    IF (command#1) AND (command#2) AND (lastwi#0) THEN
      x:=x+lastwi;
      width:=width+lastwi;
      lastwi:=0;
    END;
    IF command=0 THEN
      string[1]:=0X;
      string[0]:=text[pos];
      wi:=fact*g.TextLength(p1.fontrast,string,1)(**p1.globals.factx*);
      oldzoom:=p1.zoom;
      p1.zoom:=100;
      p1.CorrectPageDimensions;
      wi:=wi/p1.globals.pagepicx*p1.globals.pagewidth;
      p1.zoom:=oldzoom;
      p1.CorrectPageDimensions;
  
      p1.PageToPagePicC(x,y,xpos,ypos);
      IF print THEN
        p2.PrintChar(rast,text[pos],xpos,ypos,font,size);
      END;
      x:=x+wi;
      width:=width+wi;
    ELSE
      IF command=4 THEN
        IF text[pos]="[" THEN
          NEW(paro,256);
          GetParameter(text,pos,paro^);
          INC(pos);
        END;
      END;
      NEW(par1,256);
      IF text[pos]="{" THEN
        GetParameter(text,pos,par1^);
      ELSE
        par1[0]:=text[pos];
        par1[1]:=0X;
      END;
      IF command=3 THEN
        NEW(par2,256);
        INC(pos);
        IF text[pos]="{" THEN
          GetParameter(text,pos,par2^);
        ELSE
          par2[0]:=text[pos];
          par2[1]:=0X;
        END;
      END;
      newsize:=NIL;
      NEW(newsize(p1.FontSize));
      newsize(p1.FontSize).size:=size(p1.FontSize).size*2/3;
      IF command=1 THEN
        i:=0;
        PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,FALSE);
        he2:=he*1/3+top;
        IF he2>overtop THEN
          overtop:=he2;
        END;
        IF print THEN
          x2:=x;
          y2:=y-he*1/3;
          i:=0;
          PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,TRUE);
        END;
        IF lastwi=0 THEN
          lastwi:=wi;
        ELSE
          IF lastwi>wi THEN
            wi:=lastwi;
          END;
          x:=x+wi;
          width:=width+wi;
          lastwi:=0;
        END;
      ELSIF command=2 THEN
        i:=0;
        PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,FALSE);
        he2:=he*1/3+bottom;
        IF he2>underbottom THEN
          underbottom:=he2;
        END;
        IF print THEN
          x2:=x;
          he2:=p1.PointToCent(size(p1.FontSize).size);
          y2:=y+he2-he*2/3;
          i:=0;
          PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,TRUE);
        END;
        IF lastwi=0 THEN
          lastwi:=wi;
        ELSE
          IF lastwi>wi THEN
            wi:=lastwi;
          END;
          x:=x+wi;
          width:=width+wi;
          lastwi:=0;
        END;
      ELSIF command=3 THEN
        i:=0;
        PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,FALSE);
        IF top+bottom>overtop THEN
          overtop:=top+bottom;
        END;
        i:=0;
        PrintFunc(rast,par2^,i,font,newsize,x2,y2,wi2,he2,top2,bottom2,FALSE);
        IF top+bottom>underbottom THEN
          underbottom:=top+bottom;
        END;
        IF wi>wi2 THEN
          width2:=wi;
        ELSE
          width2:=wi2;
        END;
        height2:=p1.PointToCent(size(p1.FontSize).size);
        IF print THEN
          p1.PageToPagePicC(x,y+height2/2,xpos,ypos);
          g.Move(rast,xpos,ypos);
          p1.PageToPagePicC(x+width2+height2/5,y+height2/2,xpos,ypos);
          g.Draw(rast,xpos-1,ypos);
          x2:=x+(width2/2-wi/2)+height2/10;
          y2:=y+height2/2-he-bottom;
          i:=0;
          PrintFunc(rast,par1^,i,font,newsize,x2,y2,wi,he,top,bottom,TRUE);
          x2:=x+(width2/2-wi2/2)+height2/10;
          y2:=y+height2/2+top2;
          i:=0;
          PrintFunc(rast,par2^,i,font,newsize,x2,y2,wi2,he2,top2,bottom2,TRUE);
        END;
        x:=x+width2+height2/5;
        width:=width+width2+height2/5;
        he:=p1.PointToCent(size(p1.FontSize).size);
        he2:=p1.PointToCent(newsize(p1.FontSize).size);
        he:=(2*he2-he)/2;
        IF he+top+bottom>overtop THEN
          overtop:=he+top+bottom;
        END;
        IF he+top2+bottom2>underbottom THEN
          underbottom:=he+top2+bottom2;
        END;
(*        IF 2*height2>height THEN
          height:=2*height2;
        END;*)
      ELSIF command=4 THEN
        i:=0;
        wi2:=0;
        top2:=0;
        height2:=p1.PointToCent(size(p1.FontSize).size);
        IF paro#NIL THEN
          PrintFunc(rast,paro^,i,font,newsize,x2,y2,wi2,he2,top2,bottom2,FALSE);
        END;
        IF 2*height2/10>wi2 THEN
          wi2:=2*height2/10;
        END;
        i:=0;
        PrintFunc(rast,par1^,i,font,size,x2,y2,wi,he,top,bottom,FALSE);
        p1.PagePicToPage(1,rast.txBaseline,x2,y2);
        y2:=y+y2/2-he2-bottom2;
        top2:=y-y2+top2;
        IF print THEN
          x2:=x+wi2-2*height2/10;
(*          y2:=y+height2/2;*)
          p1.PageToPagePicC(x2,y,xpos,ypos);
          ypos:=ypos+(rast.txBaseline DIV 2);
          g.Move(rast,xpos,ypos);
          x2:=x2+height2/10;
          p1.PageToPagePicC(x2,y,xpos,ypos);
          ypos:=ypos+(rast.txBaseline DIV 2);
          g.Draw(rast,xpos,ypos);
          x2:=x2+height2/10;
(*          y2:=y2+he/2+bottom+height2/10;*)
          p1.PageToPagePicC(x2,y+bottom+height2/10,xpos,ypos);
          ypos:=ypos+rast.txBaseline;
          g.Draw(rast,xpos,ypos);
          x2:=x2+height2/5;
(*          y2:=y2-he-bottom-top-height2/10;*)
          p1.PageToPagePicC(x2,y-top,xpos,ypos);
          g.Draw(rast,xpos,ypos);
          x2:=x2+wi+height2/5;
          p1.PageToPagePicC(x2,y-top,xpos,ypos);
          g.Draw(rast,xpos-1,ypos);

          x2:=x+5*height2/10+wi2-2*height2/10;
          y2:=y;
          i:=0;
          PrintFunc(rast,par1^,i,font,size,x2,y2,wi,he,top,bottom,TRUE);
          IF paro#NIL THEN
            p1.PagePicToPage(1,rast.txBaseline,x2,y2);
            y2:=y+y2/2-he2-bottom2;
            i:=0;
            PrintFunc(rast,paro^,i,font,newsize,x,y2,wi2,he2,top2,bottom2,TRUE);
            top2:=y-y2+top2;
            IF height2/10>wi2 THEN
              wi2:=height2/10;
            END;
          END;
        END;
        wi:=wi+6*height2/10+wi2-height2/10;
        he:=top+height2/5;
        IF he>overtop THEN
          overtop:=he;
        END;
        IF top2>overtop THEN
          overtop:=top2;
        END;
(*        he:=bottom+height2/5;*)
        IF bottom>underbottom THEN
          underbottom:=he;
        END;
(*        he2:=he+bottom+top+2*height2/5;
        IF he2>height THEN
          height:=he2;
        END;*)
        x:=x+wi;
        width:=width+wi;
      END;
      IF par1#NIL THEN
        DISPOSE(par1);
        par1:=NIL;
      END;
      IF par2#NIL THEN
        DISPOSE(par2);
        par2:=NIL;
      END;
      IF paro#NIL THEN
        DISPOSE(paro);
        paro:=NIL;
      END;
    END;

    INC(pos);
  END;
  x:=x+lastwi;
  width:=width+lastwi;
  p2.SetFont(rast,font,size);
END PrintFunc;

PROCEDURE PrintText*(rast:g.RastPortPtr;text:ARRAY OF CHAR;font,size:l.Node;x,y:LONGREAL);

VAR fact,oldsize,
    width,height,
    top,bottom   : LONGREAL;
    pos,oldzoom,
    xpos,ypos    : INTEGER;
    string       : ARRAY 2 OF CHAR;
    mask,style,
    savestyle    : SHORTSET;

BEGIN
  savestyle:=rast.algoStyle;
  oldzoom:=p1.zoom;
  p1.zoom:=100;
  p1.CorrectPageDimensions;
  pos:=-1;
  oldsize:=size(p1.FontSize).size;
  fact:=p1.PointToCent(size(p1.FontSize).size)/p1.globals.pagewidth*p1.globals.pagepicx/50;
(*  fact:=p2.GetFontPixelSize(size(p1.FontSize).size)/50;*)
  size(p1.FontSize).size:=50;
  p2.SetFontRast(p1.fontrast,font,size);
  size(p1.FontSize).size:=oldsize;
  p1.zoom:=oldzoom;
  p1.CorrectPageDimensions;
  p2.SetFont(rast,font,size);
  mask:=g.AskSoftStyle(rast);
  style:=g.SetSoftStyle(rast,savestyle,mask);
  WHILE pos<st.Length(text)-1 DO
    INC(pos);
    IF text[pos]="$" THEN
      INC(pos);
      PrintFunc(rast,text,pos,font,size,x,y,width,height,top,bottom,TRUE);
    ELSE
      string[1]:=0X;
      string[0]:=text[pos];
      width:=fact*g.TextLength(p1.fontrast,string,1)(**p1.globals.factx*);
      oldzoom:=p1.zoom;
      p1.zoom:=100;
      p1.CorrectPageDimensions;
      width:=width/p1.globals.pagepicx*p1.globals.pagewidth;
      p1.zoom:=oldzoom;
      p1.CorrectPageDimensions;
  
      p1.PageToPagePicC(x,y,xpos,ypos);
  (*    ypos:=ypos+rast.txBaseline;*)
      p2.PrintChar(rast,text[pos],xpos,ypos,font,size);
  (*    tt.Print(xpos,ypos,string,rast);*)
      x:=x+width;
    END;
  END;
END PrintText;

PROCEDURE GetTextLength*(text:ARRAY OF CHAR;font,size:l.Node):LONGREAL;

VAR fact,oldsize,
    width,wi,he,
    top,bottom,
    x,y          : LONGREAL;
    pos,oldzoom,
    xpos,ypos    : INTEGER;
    string       : ARRAY 2 OF CHAR;

BEGIN
  oldzoom:=p1.zoom;
  p1.zoom:=100;
  p1.CorrectPageDimensions;
  pos:=-1;
  width:=0;
  oldsize:=size(p1.FontSize).size;
  fact:=p1.PointToCent(size(p1.FontSize).size)/p1.globals.pagewidth*p1.globals.pagepicx/50;
(*  fact:=p2.GetFontPixelSize(size(p1.FontSize).size)/50;*)
  size(p1.FontSize).size:=50;
  p2.SetFontRast(p1.fontrast,font,size);
  size(p1.FontSize).size:=oldsize;
  WHILE pos<st.Length(text)-1 DO
    INC(pos);
    IF text[pos]="$" THEN
      INC(pos);
      PrintFunc(p1.previewrast,text,pos,font,size,x,y,wi,he,top,bottom,FALSE);
    ELSE
      string[1]:=0X;
      string[0]:=text[pos];
      wi:=fact*g.TextLength(p1.fontrast,string,1)(**p1.globals.factx*);
      wi:=wi/p1.globals.pagepicx*p1.globals.pagewidth;
    END;
    width:=width+wi;
  END;
  p1.zoom:=oldzoom;
  p1.CorrectPageDimensions;
  RETURN width;
END GetTextLength;

PROCEDURE PlotTextLine*(rast:g.RastPortPtr;text:l.Node;setfont:BOOLEAN);

VAR x,y,width,height : INTEGER;
    mask,style,
    savestyle        : SHORTSET;

BEGIN
  WITH text: p1.TextLine DO
(*    IF setfont THEN
      IF text.trans THEN
        g.SetDrMd(rast,g.jam1);
      ELSE
        g.SetDrMd(rast,g.jam2);
      END;
    END;*)
    text.width:=GetTextLength(text.string,text.font,text.fontsize);
    text.height:=p1.PointToCent(text.fontsize(p1.FontSize).size);
    p1.CorrectBoxPagePics(text);
    p1.PageToPagePicC(text.xpos,text.ypos,x,y);
    p1.PageToPagePic(text.width,text.height,width,height);
    IF (setfont) AND NOT(text.trans) THEN
      p3.SetColor(rast,text.colb,FALSE);
      p3.SetColor(rast,text.colb,TRUE);
      g.RectFill(rast,x,y,x+width,y+height);
    END;
    p3.SetColor(rast,text.colf,TRUE);
    savestyle:=rast.algoStyle;
    mask:=g.AskSoftStyle(rast);
    style:=g.SetSoftStyle(rast,text.style,mask);
    PrintText(rast,text.string,text.font,text.fontsize,text.xpos,text.ypos);
    mask:=g.AskSoftStyle(rast);
    style:=g.SetSoftStyle(rast,savestyle,mask);
(*    p2.SetFont(rast,text.font,text.fontsize);
    width:=tt.TextLength(text.string,rast,0,0,0,0,FALSE);
    height:=p2.GetFontPixelSize(text.fontsize(p1.FontSize).size);
    p1.PageToPagePicC(text.xpos,text.ypos,x,y);
    p1.PagePicToPage(width,height,text.width,text.height);
    INC(y,rast.txBaseline);
    tt.PrintText(x,y,text.string,rast,0,0,0,0,FALSE);*)
  END;
END PlotTextLine;

PROCEDURE GetNextTextChar*(VAR node:l.Node);

BEGIN
  WHILE (node#NIL) AND NOT(node IS p1.TextChar) DO
    node:=node.next;
  END;
END GetNextTextChar;

PROCEDURE GetPrevTextChar*(VAR node:l.Node);

BEGIN
  WHILE (node#NIL) AND NOT(node IS p1.TextChar) DO
    node:=node.prev;
  END;
END GetPrevTextChar;

PROCEDURE GetAbsatz*(text,char:l.Node):l.Node;

VAR node,node2,abs : l.Node;

BEGIN
  abs:=NIL;
  node:=text(p1.TextBlock).absatz.head;
  WHILE node#NIL DO
    node2:=node(p1.TextAbsatz).charlist.head;
    WHILE node2#NIL DO
      IF node2=char THEN
        abs:=node;
      END;
      node2:=node2.next;
      IF abs#NIL THEN
        node2:=NIL;
      END;
    END;
    node:=node.next;
    IF abs#NIL THEN
      node:=NIL;
    END;
  END;
  RETURN abs;
END GetAbsatz;

PROCEDURE GetDesigner*(text,char:l.Node):l.Node;

VAR abs : l.Node;

BEGIN
  abs:=GetAbsatz(text,char);
  WHILE (char#NIL) AND NOT(char IS p1.TextDesigner) DO
    char:=char.prev;
    IF char=NIL THEN
      abs:=abs.prev;
      IF abs#NIL THEN
        char:=abs(p1.TextAbsatz).charlist.tail;
      END;
    END;
  END;
  RETURN char;
END GetDesigner;

(*PROCEDURE RefreshCharWidth*(text,actchar:l.Node);

VAR abs,char : l.Node;
    fact     : LONGREAL;
    string   : ARRAY 2 OF CHAR;
    y        : LONGREAL;
    i        : INTEGER;

PROCEDURE SetNewDesign(node:l.Node);

VAR oldsize : LONGREAL;

BEGIN
  WITH node: p1.TextDesigner DO
    oldsize:=node.size(p1.FontSize).size;
    fact:=p2.GetFontPixelSize(node.size(p1.FontSize).size)/50;
    node.size(p1.FontSize).size:=50;
    p2.SetFontRast(p1.fontrast,node.font,node.size);
    node.size(p1.FontSize).size:=oldsize;
  END;
END SetNewDesign;

BEGIN
  string[1]:=0X;
  abs:=text(p1.TextBlock).absatz.head;
  WHILE abs#NIL DO
    char:=abs(p1.TextAbsatz).charlist.head;
    WHILE char#NIL DO
      IF (char IS p1.TextChar) AND (char=actchar) THEN
        string[0]:=char(p1.TextChar).char;
        char(p1.TextChar).width:=fact*g.TextLength(p1.fontrast,string,1);
        p1.PagePicToPage(SHORT(SHORT(SHORT(char(p1.TextChar).width))),i,char(p1.TextChar).width,y);
      ELSIF char IS p1.TextDesigner THEN
        SetNewDesign(char);
      END;
      char:=char.next;
    END;
    abs:=abs.next;
  END;
END RefreshCharWidth;*)

(*PROCEDURE RefreshTextWidths*(text:l.Node);

VAR abs,char : l.Node;
    fact     : LONGREAL;
    string   : ARRAY 2 OF CHAR;
    y        : LONGREAL;
    i        : INTEGER;

PROCEDURE SetNewDesign(node:l.Node);

VAR oldsize : LONGREAL;

BEGIN
  WITH node: p1.TextDesigner DO
    oldsize:=node.size(p1.FontSize).size;
    fact:=p2.GetFontPixelSize(node.size(p1.FontSize).size)/50;
    node.size(p1.FontSize).size:=50;
    p2.SetFontRast(p1.fontrast,node.font,node.size);
    node.size(p1.FontSize).size:=oldsize;
  END;
END SetNewDesign;

BEGIN
  string[1]:=0X;
  abs:=text(p1.TextBlock).absatz.head;
  WHILE abs#NIL DO
    char:=abs(p1.TextAbsatz).charlist.head;
    WHILE char#NIL DO
      IF char IS p1.TextChar THEN
        string[0]:=char(p1.TextChar).char;
        char(p1.TextChar).width:=fact*g.TextLength(p1.fontrast,string,1);
        p1.PagePicToPage(SHORT(SHORT(SHORT(char(p1.TextChar).width))),i,char(p1.TextChar).width,y);
      ELSIF char IS p1.TextDesigner THEN
        SetNewDesign(char);
      END;
      char:=char.next;
    END;
    abs:=abs.next;
  END;
END RefreshTextWidths;*)

PROCEDURE PlotTextBlock*(wind:I.WindowPtr;rast:g.RastPortPtr;text,startchar:l.Node;refrwidths,edit:BOOLEAN):BOOLEAN;

VAR x,y,width,height,
    xmax,ymax,cent,
    fillwidth,actcent,
    overtop,underbottom: LONGREAL;
    abs,char,start,end,
    node,font,size     : l.Node;
    actheight,maxheight: LONGREAL;
    exit,mark,active,
    realactive,
    underline          : BOOLEAN;
    xpos,ypos,x2,y2,
    oldzoom            : INTEGER;

PROCEDURE GetChangedAbsatz(text,char:l.Node):l.Node;

VAR node,node2,abs : l.Node;

BEGIN
  abs:=NIL;
  node:=text(p1.TextBlock).absatz.head;
  WHILE node#NIL DO
    node2:=node(p1.TextAbsatz).charlist.head;
    WHILE node2#NIL DO
      IF (node2=char) OR ((node2 IS p1.TextChar) AND (node2(p1.TextChar).changed)) THEN
        abs:=node;
      END;
      node2:=node2.next;
      IF abs#NIL THEN
        node2:=NIL;
      END;
    END;
    node:=node.next;
    IF abs#NIL THEN
      node:=NIL;
    END;
  END;
  RETURN abs;
END GetChangedAbsatz;

PROCEDURE GetNextLine(VAR charstart,charend:l.Node);

VAR length,top,bottom,
    actcent,lasttop,
    lastbottom        : LONGREAL;
    lastword,lastchar,
    des,font,size,node: l.Node;
    fact              : LONGREAL;
    string            : ARRAY 2 OF CHAR;
    x,y               : LONGREAL;
    i,pos             : INTEGER;
    mask,style        : SHORTSET;

PROCEDURE SetNewDesign(node:l.Node);

VAR oldsize : LONGREAL;

BEGIN
  WITH node: p1.TextDesigner DO
    p2.SetFont(rast,node.font,node.size);
    oldsize:=node.size(p1.FontSize).size;
    fact:=p1.PointToCent(node.size(p1.FontSize).size)/p1.globals.pagewidth*p1.globals.pagepicx/50;
(*    fact:=p2.GetFontPixelSize(node.size(p1.FontSize).size)/50;*)
    node.size(p1.FontSize).size:=50;
    font:=node.font;
    size:=node.size;
    p2.SetFontRast(p1.fontrast,node.font,node.size);
    node.size(p1.FontSize).size:=oldsize;
    actcent:=p1.PointToCent(oldsize);
    IF actcent>cent THEN
      cent:=actcent;
    END;
(*    IF oldsize>maxheight THEN
      maxheight:=oldsize;
    END;*)
    mask:=g.AskSoftStyle(rast);
    style:=node.style;
    IF g.underlined IN node.style THEN
      underline:=TRUE;
      EXCL(style,g.underlined);
    ELSE
      underline:=FALSE;
    END;
    style:=g.SetSoftStyle(rast,style,mask);
    p3.SetColor(rast,node.colf,TRUE);
  END;
END SetNewDesign;

BEGIN
  oldzoom:=p1.zoom;
  p1.zoom:=100;
  p1.CorrectPageDimensions;
  length:=0;
  lastword:=charstart;
  charend:=charstart;
  lastchar:=charend;
  des:=GetDesigner(text,start);
  SetNewDesign(des);
  LOOP
    IF charend=startchar THEN
      active:=TRUE;
    END;
    IF charend=NIL THEN
      charend:=lastchar;
      EXIT;
    END;
    IF charend IS p1.TextChar THEN
      IF charend(p1.TextChar).changed THEN
        active:=TRUE;
      END;
      IF NOT(charend IS p1.TextFunc) THEN
        IF refrwidths THEN
          string[1]:=0X;
          string[0]:=charend(p1.TextChar).char;
          charend(p1.TextChar).width:=fact*g.TextLength(p1.fontrast,string,1)(**p1.globals.factx*);
          charend(p1.TextChar).width:=charend(p1.TextChar).width/p1.globals.pagepicx*p1.globals.pagewidth;
  (*        p1.PagePicToPage(SHORT(SHORT(SHORT(charend(p1.TextChar).width))),i,charend(p1.TextChar).width,y);*)
        END;
        IF charend(p1.TextChar).char=" " THEN
          IF charend.prev#NIL THEN
            lastword:=charend.prev;
          ELSE
            lastword:=charend;
          END;
          lasttop:=overtop;
          lastbottom:=underbottom;
        ELSIF charend(p1.TextChar).char="-" THEN
          lastword:=charend;
          lasttop:=overtop;
          lastbottom:=underbottom;
        END;
      ELSE
        IF refrwidths THEN
          pos:=0;
          PrintFunc(rast,charend(p1.TextFunc).func,pos,font,size,x,y,charend(p1.TextChar).width,charend(p1.TextChar).height,top,bottom,FALSE);
(*          charend(p1.TextChar).width:=fact*charend(p1.TextChar).width*p1.globals.factx;
          charend(p1.TextChar).width:=charend(p1.TextChar).width/p1.globals.pagepicx*p1.globals.pagewidth;*)
          IF charend(p1.TextChar).height>cent THEN
            cent:=charend(p1.TextChar).height;
          END;
          IF top>overtop THEN
            overtop:=top;
          END;
          IF bottom>underbottom THEN
            underbottom:=bottom;
          END;
        END;
      END;
      length:=length+charend(p1.TextChar).width;
      IF length>width THEN
        IF lastword#charstart THEN
          node:=charend;
          GetNextTextChar(node);
          IF node#NIL THEN
            IF (node=startchar) OR (node(p1.TextChar).changed) THEN
              active:=TRUE;
            END;
          END;
          charend:=lastword;
          overtop:=lasttop;
          underbottom:=lastbottom;
          EXIT;
        END;
      END;
    ELSIF charend IS p1.TextDesigner THEN
      SetNewDesign(charend);
    END;
    lastchar:=charend;
    charend:=charend.next;
  END;
  p1.zoom:=oldzoom;
  p1.CorrectPageDimensions;
  SetNewDesign(des);
END GetNextLine;

PROCEDURE MakeType(start,end:l.Node;type:INTEGER);

VAR node,node2: l.Node;
    numspaces : INTEGER;
    width,fill: LONGREAL;

BEGIN
  numspaces:=0;
  width:=0;
  node:=start;
  LOOP
    IF node IS p1.TextChar THEN
      IF node(p1.TextChar).char=" " THEN
        INC(numspaces);
      END;
      width:=width+node(p1.TextChar).width;
    END;
    IF node=end THEN
      EXIT;
    END;
    node:=node.next;
  END;

  width:=text(p1.TextBlock).width-width;
  fillwidth:=width;
  node:=GetAbsatz(text,end);
  node:=node(p1.TextAbsatz).charlist.tail;
  GetPrevTextChar(node);
  node2:=end;
  GetNextTextChar(node2);
  IF (width>0) AND (node#node2) THEN
    IF (type=1) OR (type=2) THEN
(*      node:=start;
      GetNextTextChar(node);
      IF node#NIL THEN
        IF node(p1.TextChar).char#" " THEN
          node2:=NIL;
          NEW(node2(p1.TextChar));
          WITH node2: p1.TextChar DO
            node2.char:=" ";
            node2.x:=text(p1.TextBlock).xpos;
            node2.y:=node(p1.TextChar).y;
            IF type=1 THEN
              node2.width:=width;
            ELSIF type=2 THEN
              node2.width:=width/2;
            END;
            node2.height:=node(p1.TextChar).height;
          END;
          node.AddBefore(node2);
        END;
      END;*)
    ELSIF type=3 THEN
      fill:=width/numspaces;
      numspaces:=0;
      node:=start;
      LOOP
        IF node IS p1.TextChar THEN
          IF node(p1.TextChar).char=" " THEN
            node(p1.TextChar).width:=node(p1.TextChar).width+fill;
            INC(numspaces);
          END;
        END;
        IF node=end THEN
          EXIT;
        END;
        node:=node.next;
      END;
    END;
  END;
END MakeType;

PROCEDURE PrintText(start,end:l.Node;VAR x,y:LONGREAL;VAR maxheight:LONGREAL;type:INTEGER);

VAR xpos,ypos,x2,y2,
    col,pos         : INTEGER;
    string          : ARRAY 2 OF CHAR;
    mask,style      : SHORTSET;
    node            : l.Node;
    wi,he,top,bottom: LONGREAL;

PROCEDURE SetNewDesign(node:l.Node);

BEGIN
  WITH node: p1.TextDesigner DO
    font:=node.font;
    size:=node.size;
    p2.SetFont(rast,node.font,node.size);
    actheight:=node.size(p1.FontSize).size;
    actcent:=p1.PointToCent(actheight);
(*    IF actheight>maxheight THEN
      maxheight:=actheight;
    END;*)
    mask:=g.AskSoftStyle(rast);
    style:=node.style;
    IF g.underlined IN node.style THEN
      underline:=TRUE;
      EXCL(style,g.underlined);
    ELSE
      underline:=FALSE;
    END;
    style:=g.SetSoftStyle(rast,style,mask);
    p3.SetColor(rast,node.colf,TRUE);
    IF edit THEN
      IF mark THEN
        g.SetAPen(rast,2);
        g.SetBPen(rast,1);
      ELSE
        g.SetAPen(rast,1);
        g.SetBPen(rast,2);
      END;
(*      g.SetDrMd(rast,g.jam2);*)
    END;
  END;
END SetNewDesign;

BEGIN
(*  IF (edit) AND (active) THEN
(*    node:=start;
    GetNextTextChar(node);
    IF node#NIL THEN
      p1.PageToPagePicC(text(p1.TextBlock).xpos,y,xpos,ypos);
      p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+node(p1.TextChar).height,x2,y2);
      g.SetAPen(rast,2);
      p1.RectFill(rast,xpos,ypos,x2,y2-1);
      g.SetAPen(rast,1);
    END;*)
  END;*)
  string[1]:=0X;
  IF type=1 THEN
    x:=x+fillwidth;
  ELSIF type=2 THEN
    x:=x+fillwidth/2;
  END;
  IF (edit) AND ((type=1) OR (type=2)) THEN
    p1.PageToPagePicC(text(p1.TextBlock).xpos,y,xpos,ypos);
    p1.PageToPagePicC(x,y+cent,x2,y2);
    IF x2>=wind.width-wind.borderLeft THEN
      x2:=wind.width-wind.borderLeft-1;
    END;
    IF y2>=wind.height-wind.borderBottom THEN
      y2:=wind.height-wind.borderBottom-1;
    END;
    g.SetAPen(rast,2);
    IF (xpos<x2) AND (ypos<y2) THEN
      g.RectFill(rast,xpos,ypos,x2-1,y2-1);
    END;
    g.SetAPen(rast,1);
  END;
  IF (edit) AND (wind#NIL) AND NOT((startchar=NIL) AND (refrwidths)) THEN
    it.GetIMes(wind,class,code,address);
    IF (class#LONGSET{}) AND NOT(I.intuiTicks IN class) AND NOT(I.mouseMove IN class) AND NOT(I.rawKey IN class) THEN
      exit:=TRUE;
      start:=end.next;
    END;
  END;
  WHILE start#end.next DO
(*    IF start=text(p1.TextBlock).markstart THEN
(*      mark:=TRUE;
      g.SetAPen(wind.rPort,2);
      g.SetBPen(wind.rPort,1);*)
    END;*)
    IF start=startchar THEN
      realactive:=TRUE;
    END;
    IF (start IS p1.TextChar) THEN
      IF (active) OR (start(p1.TextChar).changed) THEN
        string[0]:=start(p1.TextChar).char;
        start(p1.TextChar).x:=x;
        start(p1.TextChar).y:=y-overtop;
        start(p1.TextChar).changed:=FALSE;
        IF edit THEN
          p1.PageToPagePicC(x,y,xpos,ypos);
          p1.PageToPagePicC(x+start(p1.TextChar).width,y+cent,x2,y2);
          col:=rast.fgPen;
          g.SetAPen(rast,2);
          IF (xpos<x2) AND (ypos<y2) THEN
            g.RectFill(rast,xpos,ypos,x2-1,y2-1);
          END;
          g.SetAPen(rast,col);
        END;
        p1.PageToPagePicC(x,y+(cent/2-actcent/2),xpos,ypos);
        IF underline THEN
          p1.PageToPagePicC(x+start(p1.TextChar).width,y+(cent/2-actcent/2)+actcent/10,x2,y2);
          g.Move(rast,xpos,y2+rast.txBaseline);
          g.Draw(rast,x2,y2+rast.txBaseline);
        END;
(*        ypos:=ypos+rast.txBaseline;*)
        IF NOT(start IS p1.TextFunc) THEN
          p2.PrintChar(rast,string[0],xpos,ypos,font,size);
          x:=x+start(p1.TextChar).width;
        ELSE
          pos:=0;
          PrintFunc(rast,start(p1.TextFunc).func,pos,font,size,x,y,wi,he,top,bottom,TRUE);
        END;
(*        tt.Print(xpos,ypos,string,rast);*)
      END;
    ELSIF start IS p1.TextDesigner THEN
      SetNewDesign(start);
    END;
(*    IF start=text(p1.TextBlock).markend THEN
      mark:=FALSE;
      g.SetAPen(rast,1);
      g.SetBPen(rast,2);
    END;*)
    start:=start.next;
    IF (edit) AND (wind#NIL) AND NOT((startchar=NIL) AND (refrwidths)) THEN
      it.GetIMes(wind,class,code,address);
      IF (class#LONGSET{}) AND NOT(I.intuiTicks IN class) AND NOT(I.mouseMove IN class) AND NOT(I.rawKey IN class) THEN
        exit:=TRUE;
        start:=end.next;
      END;
    END;
  END;
  IF (edit) AND (active) AND NOT(exit) THEN
    p1.PageToPagePicC(x,y,xpos,ypos);
    p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+cent,x2,y2);
    IF x2>=wind.width-wind.borderLeft THEN
      x2:=wind.width-wind.borderLeft-1;
    END;
    IF y2>=wind.height-wind.borderBottom THEN
      y2:=wind.height-wind.borderBottom-1;
    END;
    g.SetAPen(rast,2);
    IF (xpos<x2) AND (ypos<y2) THEN
      g.RectFill(rast,xpos,ypos,x2-1,y2-1);
    END;
(*    IF mark THEN
      g.SetAPen(rast,2);
    ELSE
      g.SetAPen(rast,1);
    END;*)
  END;
END PrintText;

PROCEDURE SetNewDesign(node:l.Node);

VAR mask,style : SHORTSET;

BEGIN
  WITH node: p1.TextDesigner DO
    font:=node.font;
    size:=node.size;
    p2.SetFont(rast,node.font,node.size);
    actheight:=node.size(p1.FontSize).size;
    actcent:=p1.PointToCent(actheight);
    mask:=g.AskSoftStyle(rast);
    style:=node.style;
    IF g.underlined IN node.style THEN
      underline:=TRUE;
      EXCL(style,g.underlined);
    ELSE
      underline:=FALSE;
    END;
    style:=g.SetSoftStyle(rast,style,mask);
  END;
END SetNewDesign;

PROCEDURE JumpSpaces(VAR char:l.Node;x,y,cent:LONGREAL);

BEGIN
  IF NOT(exit) THEN
    LOOP
      IF char=NIL THEN
        EXIT;
      END;
      IF char=text(p1.TextBlock).markstart THEN
        mark:=TRUE;
        g.SetAPen(rast,2);
        g.SetBPen(rast,1);
      END;
      IF char=startchar THEN
        realactive:=TRUE;
      END;
      IF char IS p1.TextChar THEN
        IF char(p1.TextChar).char#" " THEN
          EXIT;
        END;
        IF active THEN
          char(p1.TextChar).x:=x;
          char(p1.TextChar).y:=y;
          char(p1.TextChar).height:=cent;
          char(p1.TextChar).overtop:=overtop;
          char(p1.TextChar).underbottom:=underbottom;
          char(p1.TextChar).changed:=FALSE;
        END;
      ELSIF char IS p1.TextDesigner THEN
        SetNewDesign(char);
      END;
      IF char=text(p1.TextBlock).markend THEN
        mark:=FALSE;
        g.SetAPen(rast,1);
        g.SetBPen(rast,2);
      END;
      char:=char.next;
    END;
  END;
END JumpSpaces;

PROCEDURE QuickJumpToLine(VAR start,end:l.Node);

VAR linestart,lineend,
    lastchar,actline,
    lastdes,lastline : l.Node;
    lasty            : LONGREAL;

BEGIN
  lastchar:=start;
  lastdes:=NIL;
  actline:=start;
  lastline:=actline;
  lasty:=y;
  LOOP
    IF start=NIL THEN
      EXIT;
    END;
    IF start IS p1.TextChar THEN
      IF (start(p1.TextChar).y>y) AND NOT(start(p1.TextChar).changed) AND NOT(start=startchar) THEN
        actline:=start;
        y:=start(p1.TextChar).y;
      ELSIF (start(p1.TextChar).changed) OR (char=startchar) THEN
        EXIT;
      END;
      IF (start(p1.TextChar).char=" ") AND (NOT(start(p1.TextChar).changed) AND NOT(start=startchar)) THEN
        lastline:=actline;
        lasty:=y;
      END;
    ELSIF start IS p1.TextDesigner THEN
      lastdes:=start;
    END;
    start:=start.next;
  END;
  start:=lastline;
  y:=lasty;
  active:=TRUE;
  GetNextLine(start,end);
END QuickJumpToLine;

BEGIN
  WITH text: p1.TextBlock DO
    exit:=FALSE;
    IF (edit) AND (wind#NIL) AND NOT((startchar=NIL) AND (refrwidths)) AND NOT(exit) THEN
      it.GetIMes(wind,class,code,address);
      IF (class#LONGSET{}) AND NOT(I.intuiTicks IN class) AND NOT(I.mouseMove IN class) AND NOT(I.rawKey IN class) THEN
        exit:=TRUE;
        char:=NIL;
      END;
    END;
    IF NOT(exit) THEN
      x:=text.xpos;
      y:=text.ypos;
      width:=text.width;
      height:=text.height;
      xmax:=x+width;
      ymax:=y+height;
      maxheight:=0;
      actheight:=0;
      IF edit THEN
        class:=LONGSET{};
      END;
      mark:=FALSE;
      IF startchar=NIL THEN
        active:=TRUE;
      ELSE
        active:=FALSE;
      END;
      realactive:=active;
      g.SetAPen(rast,1);
      g.SetDrMd(rast,g.jam1);
      IF startchar=NIL THEN
        abs:=text.absatz.head;
      ELSE
        abs:=GetChangedAbsatz(text,startchar);
        node:=abs(p1.TextAbsatz).charlist.head;
        node:=GetDesigner(text,node);
        SetNewDesign(node);
        node:=abs(p1.TextAbsatz).charlist.head;
        GetNextTextChar(node);
(*        IF NOT(node(p1.TextChar).changed) THEN*)
          y:=node(p1.TextChar).y;
(*        END;*)
      END;
      WHILE abs#NIL DO
        char:=abs(p1.TextAbsatz).charlist.head;
        WHILE char#NIL DO
          x:=text.xpos;
          start:=char;
  (*        IF NOT(active) AND (start IS p1.TextChar) THEN
            y:=start(p1.TextChar).y;
          END;*)
  (*        active:=TRUE;*)
          cent:=actcent;
          overtop:=0;
          underbottom:=0;
  (*        maxheight:=actheight;*)
(*          REPEAT*)
          IF NOT(edit) OR (active) THEN
            GetNextLine(start,end);
          ELSE
            QuickJumpToLine(start,end);
          END;
(*            IF (edit) AND NOT(start(p1.TextChar).changed) THEN
              y:=start(p1.TextChar).y;
            END;
            IF (edit) AND NOT(active) THEN
              start:=end.next;
              JumpSpaces(start,x,0,0);
            END;
          UNTIL NOT(edit) OR (active);*)
  (*        cent:=p1.PointToCent(maxheight);*)
          IF (edit) AND (active) THEN
            p1.PageToPagePicC(x,y,xpos,ypos);
            p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+overtop,x2,y2);
            IF x2>=wind.width-wind.borderLeft THEN
              x2:=wind.width-wind.borderLeft-1;
            END;
            IF y2>=wind.height-wind.borderBottom THEN
              y2:=wind.height-wind.borderBottom-1;
            END;
            g.SetAPen(rast,2);
            IF (xpos<x2) AND (ypos<y2) THEN
              g.RectFill(rast,xpos,ypos,x2-1,y2-1);
            END;
            p1.PageToPagePicC(x,y+overtop+cent,xpos,ypos);
            p1.PageToPagePicC(text(p1.TextBlock).xpos+text(p1.TextBlock).width,y+overtop+cent+underbottom,x2,y2);
            IF x2>=wind.width-wind.borderLeft THEN
              x2:=wind.width-wind.borderLeft-1;
            END;
            IF y2>=wind.height-wind.borderBottom THEN
              y2:=wind.height-wind.borderBottom-1;
            END;
            g.SetAPen(rast,2);
            IF (xpos<x2) AND (ypos<y2) THEN
              g.RectFill(rast,xpos,ypos,x2-1,y2-1);
            END;
            g.SetAPen(rast,1);
          END;
          y:=y+overtop;
  (*        IF active THEN*)
    (*        RefreshWidths(start,end);*)
            MakeType(start,end,abs(p1.TextAbsatz).type);
            char:=end;
  (*          IF NOT(edit) OR (active) THEN*)
              PrintText(start,end,x,y,maxheight,abs(p1.TextAbsatz).type);
  (*          ELSE
            END;*)
            IF NOT(active) THEN
              node:=start;
              GetNextTextChar(node);
              IF node#NIL THEN
                cent:=node(p1.TextChar).height;
              END;
            END;
            y:=y+cent+underbottom;
            IF active THEN
              WHILE (start#end.next) AND (start#NIL) DO
                IF start IS p1.TextChar THEN
                  start(p1.TextChar).height:=cent;
                  start(p1.TextChar).overtop:=overtop;
                  start(p1.TextChar).underbottom:=underbottom;
                END;
                start:=start.next;
              END;
            END;
            char:=char.next;
  (*        ELSE
            cent:=start(p1.TextChar).height;
            y:=y+cent;
            char:=end.next;
          END;*)
          JumpSpaces(char,x,y-cent-overtop-underbottom,cent);
          IF y>=ymax THEN
            char:=NIL;
          END;
          IF (edit) AND (wind#NIL) AND NOT((startchar=NIL) AND (refrwidths)) AND NOT(exit) THEN
            it.GetIMes(wind,class,code,address);
            IF (class#LONGSET{}) AND NOT(I.intuiTicks IN class) AND NOT(I.mouseMove IN class) AND NOT(I.rawKey IN class) THEN
              exit:=TRUE;
              char:=NIL;
            END;
          END;
          IF exit THEN
            char:=NIL;
          END;
        END;
        abs:=abs.next;
        IF (y>=ymax) OR (exit) THEN
          abs:=NIL;
        END;
      END;
      IF (edit) AND NOT(y>=ymax) AND NOT(exit) THEN
        p1.PageToPagePicC(text.xpos,y,xpos,ypos);
        p1.PageToPagePicC(text.xpos+text.width,text.ypos+text.height,x2,y2);
        IF x2>=wind.width-wind.borderLeft THEN
          x2:=wind.width-wind.borderLeft-1;
        END;
        IF y2>=wind.height-wind.borderBottom THEN
          y2:=wind.height-wind.borderBottom-1;
        END;
        g.SetAPen(rast,2);
        IF (xpos<=x2) AND (ypos<=y2) THEN
          g.RectFill(rast,xpos,ypos,x2,y2);
        END;
        g.SetAPen(rast,1);
      END;
      text.theight:=y;
    END;
  END;
  RETURN exit;
END PlotTextBlock;

BEGIN
END Preview4.

