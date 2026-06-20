{ Crt.i for PCQ-Pascal Copyright © 1995 by Andreas Tetzl }
{ Version 1.0 (15.04.1995) }

{
   Reworked, extended 4. July 1997 by Walter Weber-Groß.
   
   GetConSize is now substituted by MaxX and MaxY, which
   return the maximum number of chars in width and height depending
   on the current cli size.
   
   This is done without using intuitionbase. At this point i have and
   want to mention Hothelp by Hartmut Stein and Michael Berling that
   gave me a first kick about ConUnit. In Ralph Babels AMIGA Guru Book
   i found the information about the Lock() independent access to the
   InfoData structure, which made it possible to get the information
   about the current cli char postition.
   
   So, many useful functions and procedures are now available to gain
   full control over char cursor position including a boundary checking.
   
   Additionally you've got access to the window structure associated
   with the current cli window via the element cu_Window of the
   ConUnit structure.
   
   With that i could realize the function ReadKey, which allows to press
   a key without displaying it in the console window.
   
   Grateful thanks to Patrick Quaid for PCQ, Nils Sjoholm for keeping PCQ
   alive and last not least Andreas Tetzl who gave me a start with his crt!
}
 
const

   TS_PLAIN     = 0;
   TS_BOLD      = 1;
   TS_ITALIC    = 3;
   TS_UNDERLINE = 4;
   
   {  Eine Konstante für ConBackground, und sie besagt, daß die aktuelle Zeichen-
      hintergrundfarbe als Fenster-Hintergrundfarbe gesetzt werden soll;
      Pass this constant to ConBackground (s. b.) if you want to have set the new
      window background colour the same as the actual cell background colour }
   TEXT_BACKGROUND = -1;
   
{ Cursorpositionen }

function WhereX : integer;
 External;

function WhereY : integer;
 External;
 
function MaxX : integer;
 External;
 
function MaxY : integer;
 External;

{ Cursorpositionierungen }

procedure GotoXY(x, y : integer);
 External;

procedure GotoX(x : integer);
 External;

procedure GotoY(y : integer);
 External;

procedure GoUp(n : integer);
 External;

procedure GoDown(n : integer);
 External;

procedure GoLeft(n : integer);
 External;

procedure GoRight(n : integer);
 External;

{ Cursordarstellungen }

procedure CursorOff;
 External;

procedure CursorOn;
 External;

{ Spezielle Consolen-Aktionen }

procedure Bell;
 External;

procedure ClrScr;
 External;

procedure ConReset;
 External;

{ Tastatureingaben }

function Break : boolean;
 External;

function ReadKey : char;
 External;

{ Farben }

function GetTextColor : byte;
 External;

function GetTextBackground : byte;
 External;

procedure TextColor(fgpen : byte);
 External;

procedure TextBackground(bgpen : byte);
 External;

procedure ConBackground(bgpen : byte);
 External;

{ Textdarstellungen }

procedure TextReset;
 External;

procedure TextStyle(style : byte);
 External;

procedure TextMode(style, fgpen, bgpen : byte);
 External;

{ Text-Zentrierung }

procedure CenterText(txt : string);
 External;

{ Text-Grafiken }

procedure TextLine(x1, y1, x2, y2 : Integer; c : Char);
 External;

procedure TextRectFill(x, y, w, h : Integer; c : Char);
 External;
