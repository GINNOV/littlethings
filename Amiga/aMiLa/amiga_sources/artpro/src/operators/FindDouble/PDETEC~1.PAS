unit PDetector;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  THSV = record
    h,s,v : integer;
  end;

type
  TSensitivity = 0..100;

type
  TPDetector = class(TComponent)
  private
    FBitmap: Graphics.TBitmap;
    FBitmapInfo: TBitmapInfo;
    FExcludeBanners: boolean;
    FExcludeThumbnails: boolean;
    FScanSize: integer;
    FSensitivity: TSensitivity;
    FStream: TMemoryStream;
  protected
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    SPixel(x,y: integer): TColor;
    function    RGBtoHSV(r,g,b : integer): THSV;
    procedure   GetBBs;
  public
    function Detect: boolean;
  published
    property Bitmap: TBitmap read FBitmap write FBitmap;
    property ExcludeBanners: boolean read FExcludeBanners write FExcludeBanners default true;
    property ExcludeThumbnails: boolean read FExcludeThumbnails write FExcludeThumbnails default true;
    property Sensitivity: TSensitivity read FSensitivity write FSensitivity default 50;
  end;

implementation

// div. Hilfsroutinen

function max(b1,b2,b3 : integer) : integer;
begin
  if (b1>=b2) and (b1>=b3) then max:=b1
  else if (b2>=b3) then max:=b2 else max:=b3;
end;

function min(b1,b2,b3 : integer) : integer;
begin
  if (b1<=b2) and (b1<=b3) then min:=b1
  else if (b2<=b3) then min:=b2 else min:=b3;
end;

// PDetector

constructor TPDetector.Create(AOwner: TComponent);
begin
  inherited Create(Aowner);
  FBitmap := nil;
  FExcludeBanners := true;
  FExcludeThumbnails := true;
  FScanSize := 0;
  FSensitivity := 50;
  FStream := nil;
end;

destructor TPDetector.Destroy;
begin
  if FStream <> nil then FStream.Free;
  inherited Destroy;
end;

function TPDetector.SPixel(x,y: integer): TColor;
var
  a: pchar;
begin
  a:= PChar(FStream.memory)+x*3+FScansize*y;
  Result:= ((pbyte(a)^ ) shl 16) or ((pbyte(a+1)^ ) shl 8) or pbyte(a+2)^;
end;

function TPDetector.RGBtoHSV(r,g,b : integer): THSV;
var
  mi,diff, rhue,bhue,ghue : integer;
  hsv: THSV;
begin
  r := (r and $00ff) shr 2;
  g := (g and $00ff) shr 2;
  b := (b and $00ff) shr 2;
  hsv.v := max(r,g,b);
  mi := min(r,g,b);
  diff := hsv.v-mi;
  if hsv.v > 0 then hsv.s := (63*diff) div hsv.v
  else hsv.s:=0;
  if hsv.s > 0 then begin
    rhue := (60*(hsv.v-r)) div diff;
    ghue := (60*(hsv.v-g)) div diff;
    bhue := (60*(hsv.v-b)) div diff;
    if hsv.v = r then begin
      if mi = g then hsv.h := (300+bhue) mod 360
      else hsv.h := 60-ghue
    end else if hsv.v = g then begin
      if mi = b then hsv.h := 60+rhue
      else hsv.h := 180-bhue
    end else begin
      if mi = r then hsv.h := 180+ghue
      else hsv.h := 300-rhue;
    end;
  end else hsv.h := 0;
  Result := hsv;
end;

procedure TPDetector.GetBBs;
var
  res: integer;
begin
  with FBitmapInfo.bmiheader do begin
    bisize:= sizeof(FBitmapInfo.bmiheader);
    biwidth:= FBitmap.width;
    biheight:= -FBitmap.height;
    biplanes:= 1;
    biBitcount:= 24;
    biCompression:= bi_rgb;
  end;
  FScansize:= (FBitmap.width * 3);
  if ((FBitmap.width * 3) mod 4) <> 0 then FScanSize:= FScanSize+(4-(FBitmap.width * 3) mod 4);
  res := GetDIBits(FBitmap.canvas.handle, FBitmap.handle, 0, FBitmap.height, nil, FBitmapInfo, dib_rgb_colors);
  if res > 0 then begin
     FStream := TMemoryStream.Create;
     FStream.SetSize(FScanSize*FBitmap.height);
     GetDIBits(FBitmap.canvas.handle, FBitmap.handle, 0, FBitmap.height, FStream.memory, FBitmapInfo, dib_rgb_colors);
  end;
end;

function TPDetector.Detect: boolean;
var
  x,y: integer;
  col,counter:longint;
  rr,gg,bb:integer;
  count : array [1..9] of real;
  sum1,sum2:real; s:string;
  hsv: THSV;
  a1:boolean;
begin
  if (FExcludeThumbnails and (FBitmap.Height < 130) and (FBitmap.Width > 420)) or
     (FExcludeBanners and (FBitmap.Height < 150) and (FBitmap.Width < 150))
  then begin
    Result := false;
    exit;
  end;
  if FExcludeThumbnails=true then begin
     a1:= (Fbitmap.width>=120) and (Fbitmap.height>=120);
     if a1=false then begin
        a1:=(Fbitmap.height>=120) and (Fbitmap.width<=120);
        if a1 =false then begin
           result:=false;
           exit;
        end;
     end;
  end;
  getbbs;
  application.processmessages;
  application.processmessages;
  counter:=0;
  for y:=0 to FBitmap.height div 3  do begin
      for x:=0 to FBitmap.width div 3 do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          hsv := RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[1]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=0 to FBitmap.height div 3  do begin
      for x:=FBitmap.width div 3 to 2*(FBitmap.width div 3) do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[2]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=0 to FBitmap.height div 3  do begin
      for x:=2*(FBitmap.width div 3) to FBitmap.width do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[3]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=FBitmap.height div 3 to 2*(FBitmap.height div 3) do begin
      for x:=0 to FBitmap.width div 3 do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[4]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=FBitmap.height div 3 to 2*(FBitmap.height div 3) do begin
      for x:=FBitmap.width div 3 to 2*(FBitmap.width div 3) do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[5]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=FBitmap.height div 3 to 2*(FBitmap.height div 3) do begin
      for x:=2*(FBitmap.width div 3) to FBitmap.width do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[6]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=2*(FBitmap.height div 3) to FBitmap.height do begin
      for x:=0 to FBitmap.width div 3 do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[7]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=2*(FBitmap.height div 3) to FBitmap.height do begin
      for x:=FBitmap.width div 3 to 2*(FBitmap.width div 3) do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[8]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));
  counter:=0;
  for y:=2*(FBitmap.height div 3) to FBitmap.height do begin
      for x:=2*(FBitmap.width div 3) to FBitmap.width do begin
          col:=spixel(x,y);
          bb:=(col and $ff0000) shr 16;
          gg:=(col and $00ff00) shr 8;
          rr:=(col and $0000ff);
          RGBtoHSV(rr,gg,bb);
          if ((hsv.h>=15) and (hsv.h<=48)) then begin
             if (hsv.s>4) and (hsv.v>6) and (hsv.v<58) then
                inc(counter);
          end;
      end;
  end;
  count[9]:=round(100 * counter / ((FBitmap.height div 3) * (FBitmap.width div 3)));

  sum1:=max(round(count[1]*10),round(count[2]*10),round(count[3]*10))/10+max(round(count[4]*10),round(count[5]*10),round(count[6]*10))/10+max(round(count[7]*10),round(count[8]*10),round(count[9]*10))/10;
  sum2:=max(round(count[1]*10),round(count[4]*10),round(count[7]*10))/10+max(round(count[2]*10),round(count[5]*10),round(count[8]*10))/10+max(round(count[3]*10),round(count[6]*10),round(count[9]*10))/10;
  if (sum1+sum2)/6>=50 then s:=s+'+' else s:=s+' ';
  s:=s+floattostr(round((sum1+sum2)/6*10)/10)+'%'+#9+#9+floattostr(round(sum1/3*10)/10)+#9+floattostr(round(sum2/3*10)/10)+#9+#9+
                                floattostr(max(round(count[1]*10),round(count[2]*10),round(count[3]*10))/10)+#9+
                                floattostr(max(round(count[4]*10),round(count[5]*10),round(count[6]*10))/10)+#9+
                                floattostr(max(round(count[7]*10),round(count[8]*10),round(count[9]*10))/10)+#9+#9+
                                floattostr(max(round(count[1]*10),round(count[4]*10),round(count[7]*10))/10)+#9+
                                floattostr(max(round(count[2]*10),round(count[5]*10),round(count[8]*10))/10)+#9+
                                floattostr(max(round(count[3]*10),round(count[6]*10),round(count[9]*10))/10);
  Fstream.setsize(0);
  result := (round((sum1+sum2)/6*10)/10) >= FSensitivity div 2;
end;

end.
