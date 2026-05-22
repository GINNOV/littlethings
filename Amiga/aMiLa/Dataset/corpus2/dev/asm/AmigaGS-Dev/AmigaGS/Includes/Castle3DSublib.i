;
; Castle3D.i sublib
;
TraceView         Equ   -30
      ;  In :  /
Set3d_MapBase     Equ   -36
      ;  In :  A0=Map Adress
Set3d_TextureBase Equ   -42
      ;  In :  A0=Texture Adress.
Set3d_PlayerPos      Equ   -48
      ;  In :  D0=Lr / D1=Ud / D2-3-4=PLX-Y-ZPOS / D5=CASE
Set3d_ScreenSize  Equ   -54
      ;  In :  D0=XSize / D1=YSize / D2=Pixel Size (trace size)
Set3d_ChunkyBase  Equ   -60
      ;  In :  A0=Chunky Base
Set3d_ChunkySize  Equ   -66
      ;  In :  D0-1=X-YSize   (Real chunky screen )
Set3d_CosTable    Equ   -72
      ;  In :  A0=Cosinus table adress.
Set3d_SinTable    Equ   -78
      ;  In :  A0=Sinus table adress.
CaseSize       Equ   -84
      ;  In :  D0=CaseNumber
      ;  Out   :  D0=X / D1=Y / D2=Z ( SIZES )
CheckPosition     Equ   -90
      ;  In :  D0=Case / D1=XPOS / D2=YPOS / D3=ZPOS
      ;  Out   :  D0=Case / D1=XPOS / D2=YPOS / D3=ZPOS
