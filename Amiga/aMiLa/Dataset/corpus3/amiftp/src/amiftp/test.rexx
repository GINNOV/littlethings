/* */
portname = "AMIFTP"

options results
address value portname

/*
if ~show('P',portname) then do
	address command 'Run dh1:tcp/amiftp/AmiFTP ICONIFIED'
	address command 'WaitForPort' portname
	if RC~=0 then do
		exit 20
	end
end

'SETATTR HOST tomcat'
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
file = 'RECENT'
'CONNECT 127.0.0.1'
'LCD T:'
SAY file
'GET 'file

