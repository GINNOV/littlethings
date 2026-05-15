## version $VER: AmiFTP.catalog 2.2 (12.6.96)
## language italiano
## codeset 0
; Catalog descriptor file for AmiFTP 
; Copyright (C) 1995 by Magnus Lilja, All Rights Reserved.
;
; e-mail: lilja@lysator.liu.se
;
; Some notes for translators:
;
; In order to create a hotkey to activate a gadget insert
; a _ in the string before the character that should be
; the hotkey. ('Te_st' would result in 's' being the hotkey
; for that particular gadget).
;
;
; Note that menu shortcuts are defined differently:
; A correct menu entry for 'Quit' with Amiga-Q as the
; shortcut should look like this:
; Q\000Quit
;
;
;
;
; SiteList window
;
SLW_SiteListWindow
Lista siti AmiFTP
;AmiFTP Sitelist
;
SLW_SiteList
Siti FTP
;FTP Sites
;
SLW_Connect
_Connetti
;_Connect
;
SLW_New
_Nuovo sito
;_New site
;
SLW_Edit
_Edita
;_Edit
;
SLW_Remove
_Rimuovi
;_Remove
;
SLW_Cancel
_Annulla
;C_ancel
;
SLW_OK
_OK
;_OK
;
SLW_Up
Su
;Up
;
SLW_Down
Giú
;Down
;
SLW_Top
Inizio
;Top
;
SLW_Bottom
Fine
;Bottom
;
SLW_Newstring
(Nuovo)
;(New)
;
SLW_Sort
_Ordina
;_Sort
;
; SiteConfiguration Window
;
SCW_SiteConfigurationWindow
Configurazione siti AmiFTP
;AmiFTP Site Configuration
;
SCW_Name
No_me
;Na_me
;
SCW_Site
_Sito
;_Site
;
SCW_Port
_Porta
;_Port
;
SCW_RemDir
Auto-cd nella directory
;_Auto-cd to drawer
;
SCW_LocDir
Directory di dl
;_Download path
;
SCW_Anonymous
Login a_nonimo?
;Anonymous lo_gin
;
SCW_LoginName
Nome _login
;_Login name
;
SCW_Password
Pass_word
;Pass_word
;
SCW_OK
_OK
;_OK
;
SCW_Cancel
A_nnulla
;Ca_ncel
;
SCW_OS
S_istema Operativo
;Operating S_ystem
;
SCW_Proxy
Pro_xy
;Pro_xy
;
SCW_HotList
_Hotlist
;_HotList
;
; Transfer window
;
TW_WinTitle
AmiFTP - %ld file rimasti (%ld %s)
;AmiFTP - %ld file(s) left (%ld %s)
;
TW_RemoteFile
File remoto
;Remote file
;
TW_LocalFile
File locale
;Local file
;
TW_Size
Dimensioni
;Size
;
TW_Cps
CPS
;CPS
;
TW_DataTransferred
Dati trasferiti
;Data transferred
;
TW_Abort
Annulla trasferimento
;Abort transfer
;
TW_FileExists
Il file '%s' già esiste.\nVecchia dimensione: %ld bytes (nuova %ld bytes).\n
;File '%s' already exists.\nOld filesize is: %ld bytes (new %ld bytes).\n
;
TW_Overwrite
Sovrascrivo
;Overwrite
;
TW_Resume
Riprendo trasferimento
;Resume transfer
;
TW_CancelTransfer
Annullo operazione
;Cancel transfer
;
TW_DownloadDir
Stai per ricevere un albero di dir.\nSei sicuro di volerlo fare?
;You are about to download a directory tree.\nAre you sure you want to do this?
;
TW_GetDir
Sì, procedi!|Salta questa parte
;Yes, download it!|Skip this entry
;
; Main preferences window
;
MPW_WinTitle
Preferenze globali AmiFTP
;AmiFTP Global Preferences
;
MPW_Password
Password _anonima
;_Anonymous password
;
MPW_ViewCommand
Comando _mostra
;_View command
;
MPW_ProxyHost
_Host proxy
;Proxy _host
;
MPW_ProxyPort
_Porta proxy
;Proxy _port
;
MPW_ProxyDefault
Uso pro_xy di default?
;Use pro_xy per default
;
MPW_DefDownloadDir
Directory di dl predefinita
;Default local drawer
;
MPW_IgnoreCase
_Ignoro maiuscole/minuscole?
;_Ignore case
;
; Main window
;
MW_SiteName
_Sito attuale:
;_Site
;
MW_DirName
D_irectory
;Drawer
;
MW_DownloadDir
Direct_ory di dl
;L_ocal drawer
;
MW_Parent
_Precedente
;_Parent
;
MW_Get
_Get
;_Get
;
MW_Put
P_ut
;P_ut
;
MW_View
_Mostra
;_View
;
MW_Connect
_Collegati a...
;_Connect to...
;
MW_Disconnect
_Sconnessione
;_Disconnect
;
MW_DeleteRequest
Sei sicuro di voler\ncancellare questi file?
;Are you sure you want to\ndelete these files?
;
MW_DeleteCancel
Cancella|Annulla
;Delete|Cancel
;
MW_Reload
_Riapri
;_Reload
;
; Connect window
;
CW_WinTitle
Finestra collegamento AmiFTP
;AmiFTP Connect window
;
CW_Abort
Annulla
;Abort
;
CW_Site
Sito:
;Site:
;
CW_Status
Stato:
;Status:
;
CW_Connecting
Collegamento...
;Connecting...
;
CW_ReadingDir
Leggo la directory...
;Reading drawer...
;
CW_SendingLogin
Trasmetto il login...
;Sending login...
;
CW_SendingPassword
Trasmetto la password...
;Sending password...
;
CW_ChangingDirectory
Cambio la directory...
;Changing drawer...
;
; Main menus
;
MENU_Project
Progetto
;Project
;
MENU_AddToSiteList
Aggiungi sito alla lista
;Add current to sitelist
;
MENU_Reconnect
Ricollega
;Reconnect
;
MENU_Iconify
I\000Iconifica
;I\000Iconify
;
MENU_About
?\000Informazioni...
;?\000About...
;
MENU_Quit
Q\000Esci
;Q\000Quit
;
MENU_Files
Files
;Files
;
MENU_TagAll
A\000Seleziona tutti
;A\000Tag all
;
MENU_UntagAll
U\000Deseleziona tutti
;U\000Untag all
;
MENU_TransferMode
Modo trasferimento
;Transfer mode
;
MENU_Binary
Binario
;Binary
;
MENU_ASCII
ASCII
;ASCII
;
MENU_ClearCache
Pulisci dir-cache
;Clear dir-cache
;
MENU_Delete
D\000Cancella
;D\000Delete
;
MENU_Move
M\000Muovi
;M\000Move
;
MENU_Sort
Ordina
;Sort
;
MENU_SortbyName
per nome
;by name
;
MENU_SortbyDate
per data
;by date
;
MENU_Settings
Settaggi
;Settings
;
MENU_Global
1\000Globali
;1\000Global...
;
MENU_Hostlist
2\000Hotlist
;2\000Sitelist...
;
MENU_LogWindow
Finestra di log?
;Log window
;
MENU_ToggleDotFiles
Mostro file punto?
;Show dot-files
;
MENU_LoadSettings
Carica settaggi...
;Load settings...
;
MENU_SaveSettings
Salva settaggi
;Save settings
;
MENU_SaveSettingsAs
Salva settaggi come...
;Save settings as...
;
MENU_HotList
HotList
;Hotlist
;
; Other strings
;
Str_ErrorReadingDir
Errore nel leggere la directory\n
;Error reading drawer!\n
;
Str_CannotDLDirs
Non si possono scaricare intere directory!\n
;Cannot download entire directories!\n
;
Str_SelectDLPath
Scegli directory di dl
;Select download path
;
Str_SelectULFiles
Scegli file da spedire
;Select file(s) to upload
;
Str_CDFailedTimedout
CD remoto fallito:\nConnessione fuori tempo
;Remote CD failed:\nConnection timed out
;
Str_CDFailed
CD remoto fallito.
;Remote CD failed.
;
Str_AmiFTPError
Errore AmiFTP
;AmiFTP error
;
Str_OK
OK
;OK
;
Str_CANCEL
Annulla
;Cancel
;
Str_PasswordRequest
Richiesta password AmiFTP
;AmiFTP Password request
;
Str_PasswordEntry
Inserire password per l'utente:\n%s
;Enter password for user:\n%s
;
Str_ServiceNotAvail
Servizio non disponibile
;Service not available.
;
Str_ConnectFailed
Connessione fallita.
;Connect failed.
;
Str_ConnectLoginFailed
Connessione fallita, login sconosciuto.
;Connect failed, login unknown.
;
Str_Putfailed
Il put di %s é fallito
;Put of %s failed
;
Str_RemoteWriteFailed
Scrittura fallita (file system remoto pieno?).
;Write failed (remote file system full?).
;
Str_GetFailed
Il get di %s e' fallito.
;Get %s failed.
;
Str_LocalfileError
Errore in apertura di %s.
;Error opening %s.
;
Str_LocalWriteFailed
Scrittura fallita: %s
;Write failed: %s
;
Str_NoSuchDir
%s: nessun file o dir con questo nome.
;%s: No such file or directory.
;
Str_DisconnectedTimeout
Sconnessione (timeout).
;Disconnected (timeout).
;
Str_Outofmem
Non c'é memoria
;Out of memory
;
Str_SelectSettingsFile
Scegli file di settaggi...
;Select settings file...
;
Str_NoRestart
Comando resume fallito.
;Resume command failed.
;
Str_ConnectionTimedOut
Connessione fuori tempo
;Connection timed out
;
Str_AmiFTPRequest
Richiesta AmiFTP
;AmiFTP Request
;
Str_AboutAmiFTP
Informazioni AmiFTP...
;About AmiFTP...
;
Str_UnknownHost
Host sconosciuto
;Unknown host
;
Str_ErrorBuildingDirList
Errore nel costruire la lista dei file.
;Error building filelist.
;
Str_Translator
Traduzione italiana di\nGiacomo Magnini\n<prometeo@flashnet.it>\n
;
; This string will show up in the about window telling the user who made 
; the translation. I suggest the string should look like this:
; 'English translation by\nMagnus Lilja\n' (and perhaps your emailaddress
; too). Ofcourse the above string should be in the same language as
; the rest of the translation.
SLW_NewGroup
Nuovo _gruppo
;New _group
;
SLW_AddBar
Aggiungi barra
;Add bar
;
MENU_ToggleADTFiles
Mostro l'intero RECENT?
;Show entire RECENT
;
MENU_ResetADT
Aggiorna data Aminet
;Reset Aminet-date
;
MW_ViewReadme
Mostra readme
;View readme
;
MPW_General
Generale
;General
;
MPW_ADT
Aminet
;Aminet
;
MPW_Proxy
Proxy
;Proxy
;
MPW_BufferSize
Dim. buffer
;Buffer size
;
MPW_DirCacheSize
Dim. cache della directory
;Directory cache size
;
MPW_DeleteViewed
Cancello file mostrati?
;Delete viewed files
;
MPW_Beep
Segnalo fine trasferimento?
;Beep after transfer
;
MPW_HideDirectories
Nascondo le directory
;Hide drawers
;
MPW_PreservePath
Mantengo il path del file?
;Preserve filepath
;
MPW_ShowMOTD
Mostro il file MOTD?
;Show MOTD-file
;
MPW_GetReadme
Ricevo i readme?
;Download readme
;
SCW_AminetMode
Modo Aminet?
;Aminet-mode
;
MPW_OK
_Ok
;_OK
;
MPW_Cancel
A_nnulla
;C_ancel
;
TW_TimeLeft
Tempo rimasto
;Time left
;
Str_NoNewAminetFiles
Nessun nuovo file dall'ultima visita ad Aminet
;No new files since last Aminet visit
;
Str_WindowTitle
AmiFTP - %ld files selezionati (%ld %s) %ld %s liberi su disco
;AmiFTP - %ld files selected (%ld %s) %ld %s free on disk
; This might look a bit strange, but when the fields are filled the
; string looks like:
; AmiFTP - 10 files selected (4 MB) 15 MB free on disk
MENU_Connect
C\000Collegati a...
;C\000Connect...
;
MENU_Disconnect
Sconnessione
;Disconnect
;
MENU_Get
G\000Get
;G\000Get
;
MENU_Put
U\000Put
;U\000Put
;
MENU_View
V\000Mostra
;V\000View
;
MENU_PatternSelect
Seleziona per pattern...
;Select by pattern...
;
MPW_Display
Interfaccia
;Display
;
Str_PatternRequest
Richiesta AmiFTP
;AmiFTP request
;
Str_SelectPattern
Inserire pattern AmigaDOS:
;Enter AmigaDOS pattern:
;
MENU_Parent
P\000Precedente
;P\000Parent
;
MPW_PublicScreen
Schermo pubblico
;Public screen
;
MPW_SystemFonts
Usa font di sistema
;Use system fonts
;
MPW_InterfaceFont
Font per l'interfaccia
;Interface font
;
MPW_FilelistFont
Font per la lista file
;Filelist font
;
MPW_ShowButtons
Mostra bottoni
;Show buttons
;
MPW_ShowToolbar
Mostra la barra strumenti
;Show toolbar
;
MENU_ViewReadme
Mostra il readme
;View readme

