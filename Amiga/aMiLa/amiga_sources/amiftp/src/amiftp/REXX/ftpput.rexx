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
	address command 'Run dh1:tcp/amiftp/AmiFTP'
	address command 'WaitForPort' portname
	if RC~=0 then do
		exit 20
	end
end
'SETATTR HOST ftp.lysator.liu.se USERNAME lilja PASSWORD oxygene'
'CONNECT NOSCAN'
'CD ftp NOSCAN'
'PUT ReadMe'
'DISCONNECT'

'QUIT'
