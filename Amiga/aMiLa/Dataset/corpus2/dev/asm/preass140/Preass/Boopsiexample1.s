
; BoopsiExample 1.4 (28-11-94)
; 
; SAS/C V6.51
;
; Copyright c 1994 , Carsten Ziegeler
;		     Augustin-Wibbelt-Str.8 , 33106 Paderborn, Deutschland
;
; Preassembler 1.24 / ASMONE 1.2 
;
; Copyright c 1994 , Marius Schwarz
;		     Gesemannstr. 4 , 38226 Salzgitter , Deutschland
;
; Beispielsource für BoopsiGadgets
;  

	IncDir 	"sys:coder/"
	Include "preass/startrek.inc"	 ; Sammelinclude (EXEC/DOS/INTUI)
					 ; SammelLVO3.0  (EXEC/DOS/INTUI)
	Include "preass/intuition.inc"; Intuition include
	Include "LVO3.0/GuiEnv_lib.i"	 ; Offsets für GUIenv
	Include "include/guienv.i"	 ; abgeändertes GUIenv.h Include
					 ; fuer ASMOne 1.2 (keine Structs)
	Include "Include/Libraries/gadtools.i"
					 ; ASMone fähiges Include
	Include "include/intuition/icclass.i"
					 ; siehe Gadtools.i
	
;---------------------------------------------------------------------------

Main:
	Include "preass/Startup.i"
	Jsr Openlibs
	Tst.l D0
	Beq Mainende
	Jsr START
Mainende:
	jsr Closelibs
	Move.l Error,d0
	Rts
					; Openlibs,Closelibs & Startup.i


dc.b 0,`$VER: BOOPSIEXample 1.4 (29.09.94) Preass version`,0

even
start:
; öffne Gui-Window
	Move.l GUIEnvBase,a6
	Move.l #50,D0
	Move.l #50,D1
	Move.l #150,D2
	Move.l #150,D3
	Move.l #GUIENVIRONMENT___BOOPSIExamplename,A0
	Move.l #IDCMP_Closewindow!IDCMP_newsize!IDCMP_REfreshwindow,D4
	Move.l #WFlg_Activate!WFlg_Sizegadget!WFlg_DepthGadget!WFLG_Closegadget!WFLG_Dragbar,D5
	Move.l #0,A1
	Move.l #Windowtags,A2
	Jsr openguiwindowA(a6)
	Move.l D0,window

	Tst.l window
	Beq .ende		; wenn Window = Dosfalse,ende
	Move.l IntuitionBase,a6
	Jsr Wbenchtofront(a6)
	Move.l GUIEnvBase,a6
	Move.l window,A0
	Move.l #GuiTaglist,A1
	Jsr createguiinfoA(a6)
	Move.l D0,gui
; Änderung zum Original:
; GUI_Creationfont nicht dabei!

; Proportional BoopsiGadget erstellen.
; Carsten hat auf jedweden Kommentar verzichtet,also nicht
; wundern ,wenns auch hier nichts gibt.
; GEG_Class ist ein Tag das einen Zeiger auf einen String
; haben möchte.Dieser String gibt die Klasse des Boopsis an.
; Nach zulesen in den Autodocs unter MAKECLASS().
; Neue Klassen müßen bei Commodore angemeldet werden.Ich frag
; mich nur wie ? Commodore gibts doch nicht mehr.
	
	Move.l gui,A0
	Move.l #10,D0
	Move.l #20,D1
	Move.l #-10,D2
	Move.l #-10,D3
	Move.l #GEG_BoopsipublicKind,D4
	Move.l #Gadget1tags,A1
	Jsr CreateGUIgadgetA(a6)

; Die Tagliste des zweiten gadget will wissen wo das erste
; Gadget untergebracht ist.

	Move.l gui,A0
	Move.l #0,D0
	Move.l #geg_Address,D1
	Jsr GETGuiGadgeta(a6)
	Move.l D0,GuiGadgetinfo0

; Das Boopsigadget das hier erstellt wird,enthält später
; die Zahl,die das Propgadget hat.Anfangswert ist (s.o.)
; 25 (PGA_TOP).Maximal passen in das Stringgadget 3 Zeichen
; rein,StringA_Maxchars!,das Stringgadget ist laut
; GEG_Description ,jaja,leicht unüblich das Hexzahl anzugeben,
; aber das liegt daran,dass der Editor von ASMone nicht nach
; rechts scrollt und so die Zeile leicht eingeschraenkt ist,
; kann man nicht ändern,es sei den man nimmt nen Texteditor.
; Preass ist das übrigens egal,wie lang die Zeile ist.
; Na jedenfalls ist das Stringgadget immer 10 Pixel rechts vom
; Propgadget ,10 Pixel von der oberen Windowgrenze , 10 Pixel 
; von der rechten Windowrand und garantierte 18 Pixel Hoch.

	Move.l gui,A0
	Move.l #10,D0
	Move.l #10,D1
	Move.l #-10,D2
	Move.l #18,D3
	Move.l #GEG_BoopsipublicKind,D4
	Move.l #Gadget2tags,A1
	Jsr CreateGUIgadgetA(a6)

; erstellen der Adresse des zweiten Gadgets.

	Move.l gui,A0
	Move.l #1,D0
	Move.l #geg_Address,D1
	Jsr GETGuiGadgeta(a6)
	Move.l D0,GuiGadgetinfo1

; Einfuegen der GuiGadgetinfo1 in die Tag-Liste von SETGUIGADGET()

	lea getgadget2tags,a0
	Move.l GuiGadgetinfo1,D0
	Move.l D0,4(a0)

; Set.. erweitert die Angaben zum ersten Gadget,das muss auch
; wissen wo das Partner Gadget untergebracht ist.
; Was mich wundert ist,dass ICA_Target beim ersten die 
; Variable GUIGADGETinfo0 in der Tagliste akzeptiert ,
; aber bei der zweiten klappt das nicht!

	Move.l gui,A0
	Move.l #0,D0
	Move.l #Getgadget2tags,A1
	Jsr SetGuigadgeta(a6)
; Gui erstellen
	Move.l gui,A0
	Move.l #0,A1
	Jsr drawguia(a6)
	Move.l D0,report
	Move.l report,d0
	Cmp.l #Ge_done,D0
	Beq .weiter
; Vergleiche ob DrawGui erfolgreich war.
.fehler:Move.l gui,A0
        Move.l #Fehlername,A1
        Move.l #Ger_OKKind,D0
        Move.l #0,A2
        Jsr GuiRequesta(a6)
.weiter:Move.l gui,A0
        Jsr WaitGuiMsg(a6)
	Clr.l D0
	Move.l gui,A0
	Move.l 36(A0),D0
	Move.l D0,MsgClass
	Move.l MsgClass,d0
	Cmp.l #IDcmp_CloseWindow,D0
	Beq .free
	Move.l MsgClass,d0
	Cmp.l #IDCMP_newsize,D0
	Beq .fehler
	Bra .weiter
.free:	Move.l gui,A0
      	Jsr freeguiinfo(a6)
	Move.l window,A0
	Jsr closeguiwindow(a6)
.ende:	RTS

; Interne Umrechnungstabelle, fragt mich nicht wofür.

int2propmap:	dc.l Stringa_longVal,Pga_top,0
prop2intmap:	dc.l PGA_top,Stringa_longval,0

Even
Openlibs:
	Move.l $4.w,a6
	Move.l #GUIEnvname,a1
	Moveq.l #0,d0
	Jsr Openlibrary(a6)
	Move.l d0,GUIEnvbase
	Tst.l D0
	Beq.w .ende
	Move.l #Intuitionname,a1
	Moveq.l #0,d0
	Jsr Openlibrary(a6)
	Move.l d0,Intuitionbase
	Tst.l D0
	Beq.w .ende
.ende:	Rts
Closelibs:
	Move.l $4.w,a6
	Tst.l GUIEnvbase
	Beq.w .ende00
	Move.l GUIEnvbase,a1
	Jsr Closelibrary(a6)
.ende00:Tst.l Intuitionbase
	Beq.w .ende01
	Move.l Intuitionbase,a1
	Jsr Closelibrary(a6)
.ende01:Rts
even
WBmessage:		dc.l 0
Laenge:		dc.l 0
Adresse:		dc.l 0
Error:		dc.l 0
Guierror:		dc.l 0
window:		dc.l 0
gui:		dc.l 0
GuiGadgetinfo0:		dc.l 0
GuiGadgetinfo1:		dc.l 0
report:		dc.l 0
MsgClass:		dc.l 0
GUIEnvBase:		dc.l 0
IntuitionBase:		dc.l 0
even
GUIENVIRONMENT___BOOPSIExamplename:
	dc.b `GUIENVIRONMENT - BOOPSIExample`,0
even
Windowtags:
	dc.l WA_Minwidth,250
	dc.l WA_MinHeight,120
	dc.l WA_MAxwidth,500
	dc.l WA_MaxHeight,200
	dc.l Tag_done,0
GuiTaglist:
	dc.l Gui_createerror,Guierror
	dc.l Tag_Done,0
Gadget1tags:
	dc.l GEG_class,propgclass
	dc.l GEG_Description,$21210101
	dc.l ICA_Map,prop2intmap
	dc.l PGA_total,100
	dc.l PGA_Top,25
	dc.l PGA_Visible,10
	dc.l PGA_newlook,Dostrue
	dc.l Tag_Done,0
Gadget2tags:
	dc.l ICA_target,guigadgetinfo0
	dc.l GEG_class,strgclass
	dc.l GEG_Description,$05210100
	dc.l ICA_Map,int2propmap
	dc.l StringA_longval,25
	dc.l StringA_Maxchars,3
	dc.l Tag_Done,0
Getgadget2tags:
	dc.l ICA_target,1
	dc.l Tag_Done,0
Fehlername:	dc.b `Fehler!`,0
even
GUIEnvname: dc.b "guienv.library",0
Intuitionname: dc.b "intuition.library",0
even
propgclass:	dc.b "propgclass",0,0
strgclass:	dc.b "strgclass",0

