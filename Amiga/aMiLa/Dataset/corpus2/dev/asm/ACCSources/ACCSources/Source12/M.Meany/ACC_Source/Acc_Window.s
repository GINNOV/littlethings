*****************************************************************************
; Main window data definition

a68k_window	dc.w		0,15	
		dc.w		640,185	
		dc.b		0,1	
		dc.l		NEWSIZE+MOUSEBUTTONS+GADGETDOWN+GADGETUP+MENUPICK+CLOSEWINDOW+RAWKEY
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+SIZEBRIGHT+ACTIVATE+NOCAREREFRESH
		dc.l		0	
		dc.l		0	
		dc.l		WindowName
		dc.l		0	
		dc.l		0	
		dc.w		50,50	
		dc.w		640,256	
		dc.w		WBENCHSCREEN

WindowName	dc.b		'A68K Front End v2.10 © M.Meany 1990',0
		even

ScreenName	dc.b		'ACC v2.10 Programmed by S.Marshall and M.Meany.',0
		even
		
; Main menu data defenition

main_menu	dc.l		SearchMenu		
		dc.w		10,0		
		dc.w		80,10		
		dc.w		MENUENABLED	
		dc.l		ProjectName	
		dc.l		Project1	
		dc.w		0,0,0,0		

ProjectName	dc.b		'Project',0
		even

Project1	dc.l		Project2	
		dc.w		0,0		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		
		dc.l		ClearStruct		
		dc.l		0		
		dc.b		'C'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Clear

ClearStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		ClearText	
		dc.l		0		

ClearText	dc.b		'Clear',0
		even

Project2	dc.l		Project3	
		dc.w		0,10		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP		Item flags
		dc.l		0		
		dc.l		LoadStruct	
		dc.l		0		
		dc.b		'L'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Load

LoadStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		LoadFText
		dc.l		0		

LoadFText	dc.b		'Load',0
		even

Project3	dc.l		Project4	
		dc.w		0,22		
		dc.w		160,8		
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		SaveStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Save

SaveStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		SaveFText
		dc.l		0		

SaveFText	dc.b		'Save',0
		even

Project4	dc.l		Project5	
		dc.w		0,32		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		SaveAsStruct
		dc.l		0		
		dc.b		'S'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		SaveAs

SaveAsStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		SaveAsText
		dc.l		0		

SaveAsText	dc.b		'Save As',0
		even

Project5	dc.l		Project6	
		dc.w		0,44		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		InsertFStruct
		dc.l		0		
		dc.b		'I'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		InsertFile

InsertFStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		InsertFileText
		dc.l		0		

InsertFileText	dc.b		'Insert file',0
		even

Project6	dc.l		Project7	
		dc.w		0,54		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		PrintStruct	
		dc.l		0		
		dc.b		0
		dc.b		0		
		dc.l		Project6a	
		dc.w		MENUNULL	
		dc.l		DoNothing

PrintStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		PrintText
		dc.l		0		

PrintText	dc.b		'Print',0
		even

Project6a	dc.l		Project6b	
		dc.w		145,-8		
		dc.w		64,8		
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP	
		dc.l		0		
		dc.l		PrintFStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		PrintFile

PrintFStruct	dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0		
		dc.l		0		
		dc.l		PrintFText
		dc.l		0		

PrintFText	dc.b		' File   ',0
		even

Project6b	dc.l		0		
		dc.w		145,0		
		dc.w		64,8		
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP	
		dc.l		0		
		dc.l		PrintPStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		PrintPage

PrintPStruct	dc.b		3,1,RP_COMPLEMENT,0		
		dc.w		0,0		
		dc.l		0		
		dc.l		PrintPText
		dc.l		0		

PrintPText	dc.b		' Page   ',0
		even

Project7	dc.l		Project8	
		dc.w		0,64		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		AboutStruct
		dc.l		0		
		dc.b		'O'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		About

AboutStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		AboutText
		dc.l		0		

AboutText	dc.b		'About',0
		even

Project8	dc.l		0		
		dc.w		0,76		
		dc.w		160,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		QuitStruct
		dc.l		0		
		dc.b		'Q'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		QuitReq

QuitStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		QuitText
		dc.l		0		

QuitText	dc.b		'Quit',0
		even

SearchMenu	dc.l		OptionsMenu		
		dc.w		100,0		
		dc.w		72,10		
		dc.w		MENUENABLED	
		dc.l		SearchName	
		dc.l		Search1
		dc.w		0,0,0,0		

SearchName	dc.b		'Search',0
		even

Search1		dc.l		Search2
		dc.w		0,0		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		FindStruct
		dc.l		0		
		dc.b		'F'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Find

FindStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		FindText
		dc.l		0		

FindText	dc.b		'Find',0
		even

Search2		dc.l		Search3
		dc.w		0,10		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		FindNStruct
		dc.l		0		
		dc.b		'N'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		FindN

FindNStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		FindNText
		dc.l		0		

FindNText	dc.b		'Find Next',0
		even

Search3		dc.l		Search4
		dc.w		0,20		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		FindPStruct
		dc.l		0		
		dc.b		'P'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		FindP

FindPStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		FindPText
		dc.l		0		

FindPText	dc.b		'Find Previous',0
		even

Search4		dc.l		Search5
		dc.w		0,30		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		ReplaceStruct
		dc.l		0		
		dc.b		'R'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Replace

ReplaceStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		ReplaceText
		dc.l		0		

ReplaceText	dc.b		'Replace',0
		even

Search5		dc.l		0		
		dc.w		0,40		
		dc.w		176,8		
		dc.w		ITEMTEXT+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		ReplaceAllStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		Search6	
		dc.w		MENUNULL	
		dc.l		DoNothing

ReplaceAllStruct dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		ReplaceAllText
		dc.l		0		

ReplaceAllText	dc.b		'Replace All',0
		even

Search6		dc.l		0		
		dc.w		132,6		
		dc.w		128,8		
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		CheckStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		ReplaceAll


CheckStruct	dc.b		2,2,RP_JAM1,0	
		dc.w		0,0		
		dc.l		0		
		dc.l		CheckText
		dc.l		0		

CheckText	dc.b		'Are you sure?',0
		even

OptionsMenu	dc.l		ProgramMenu		
		dc.w		182,0		
		dc.w		80,10		
		dc.w		MENUENABLED	
		dc.l		OptionsName	
		dc.l		Options1
		dc.w		0,0,0,0		

OptionsName	dc.b		'Options',0
		even

Options1	dc.l		Options2
		dc.w		0,0		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		GoLineStruct
		dc.l		0		
		dc.b		'G'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		GoLine

GoLineStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		GoLineText
		dc.l		0		

GoLineText	dc.b		'Goto line',0
		even

Options2	dc.l		Options3
		dc.w		0,10		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		GoTopStruct
		dc.l		0		
		dc.b		'T'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		GoTop

GoTopStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		GoTopText
		dc.l		0		

GoTopText	dc.b		'Goto Top',0
		even

Options3	dc.l		Options4
		dc.w		0,20		
		dc.w		176,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		GoBotStruct
		dc.l		0		
		dc.b		'B'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		GoBot

GoBotStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		GoBotText
		dc.l		0		

GoBotText	dc.b		'Goto Bottom',0
		even

Options4	dc.l		0		
		dc.w		0,35		
		dc.w		176,8		
		dc.w		ITEMTEXT+HIGHCOMP+ITEMENABLED
		dc.l		0		
		dc.l		PrefsStruct
		dc.l		0		
		dc.b		0		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Prefs

PrefsStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		PrefsText
		dc.l		0		

PrefsText	dc.b		'Preferences',0
		even

ProgramMenu	dc.l		0		
		dc.w		272,0		
		dc.w		80,10		
		dc.w		MENUENABLED	
		dc.l		ProgramName	
		dc.l		Program1
		dc.w		0,0,0,0		

ProgramName	dc.b		'Program',0
		even

Program1	dc.l		Program2
		dc.w		0,0		
		dc.w		194,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		AssembleStruct
		dc.l		0		
		dc.b		'A'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Assemble

AssembleStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		AssembleText
		dc.l		0		

AssembleText	dc.b		'Assemble',0
		even

Program2	dc.l		Program3
		dc.w		0,10		
		dc.w		194,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		RunStruct
		dc.l		0		
		dc.b		'X'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Run

RunStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		RunText
		dc.l		0		

RunText		dc.b		'Run',0
		even

Program3	dc.l		0		
		dc.w		0,60		
		dc.w		194,8		
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0		
		dc.l		HelpStruct
		dc.l		0		
		dc.b		'H'		
		dc.b		0		
		dc.l		0		
		dc.w		MENUNULL	
		dc.l		Help

HelpStruct	dc.b		0,0,RP_JAM1,0	
		dc.w		8,0		
		dc.l		0		
		dc.l		HelpText
		dc.l		0		

HelpText	dc.b		'Help',0
		even
