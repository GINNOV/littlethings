/* Ftpget.rexx */

parse arg sitename ' ' file

say 'Site' sitename
say 'file' file

if sitename = "" | file = "" then do
  say 'Usage: ftpget.rexx site file'
  exit 10
end

portname = "AMIFTP"

address value portname
options results

if ~show('P',portname) then do
	address command 'Run dh1:tcp/amiftp/AmiFTP ICONIFIED'
	address command 'WaitForPort' portname
	if RC~=0 then do
		exit 20
	end
end
'GETATTR STEM STAT'
if stat.connected then
	'DISCONNECT'

'SETATTR HOST ' sitename ' ANONYMOUS LOCALDIR ram: USEPROXY'
'CONNECT NOSCAN'
if RC~=0 then do
	say 'Could not connect to 'sitename
	'QUIT'
	exit 10
end

'GET BIN ' file
if RC~=0 then do
	say 'Error downloading file'
	'DISCONNECT'
	'QUIT'
	exit 10
end
say 'Got 'file 'successfully'
'DISCONNECT'

'QUIT'
