/* */
portname = "AMIFTP"

address value portname
options results
/*
if ~show('P',portname) then do
	address command 'Run dh1:tcp/amiftp/AmiFTP ICONIFIED'
	address command 'WaitForPort' portname
	if RC~=0 then do
		exit 20
	end
end

'SETATTR HOST ftp.lysator.liu.se PORT 21'
'CONNECT'

if RC=0 then do
	GETATTR dong FILELIST
	say 'Number of files: 'dong.FILELIST.COUNT
	i=0
	do while i<dong.FILELIST.COUNT
		say dong.FILELIST.i.TYPE ': 'dong.FILELIST.i.NAME 'Size: 'dong.FILELIST.i.SIZE
		i=i+1
	end
end

'DISCONNECT'
*/

'SETATTR HOST localhost PORT 21'
'CONNECT'
'LCD T:'
file = 'TREE'
'GET 'file
/*'GETATTR FICHIER FILELIST'

SAY 'Number of files: ' FICHIER.FILELIST.COUNT

DO i=0 TO FICHIER.FILELIST.COUNT-1
    SAY 'FileName: 'FICHIER.FILELIST.i.NAME' Size:'FICHIER.FILELIST.i.SIZE' FileType:' FICHIER.FILELIST.i.TYPE
END
*/
