/* */

parse arg file

address value "AMIFTP.1"

options results

/*'SETATTR HOST ftp.lysator.liu.setomcat PORT 21 LOCALDIR T:' */
say 'plink'
'SITE ftp.luth.se2'

say 'Connecting...'
'CONNECT NOSCAN'
say 'Connected'
/*'GET FILE LOCAL LOCAL T/RECENT2'
'DISCONNECT'
'DELETE RECENT'*/
if RC~=0 then do
  say 'Error2'
end 
/*
say 'AMIFTP VERSION    :' AMIF.VERSION
say 'Current screen    :' AMIF.SCREEN
say 'Current host      :' AMIF.HOST
say 'Proxy host        :' AMIF.PROXYHOST
say 'Proxy port        :' AMIF.PROXYPORT
say 'Current remote dir:' AMIF.REMOTEDIR
say 'Current local dir :' AMIF.LOCALDIR
say 'Connected status  :' AMIF.CONNECTED

do i=0 to AMIF.HOTLIST.COUNT - 1
  say ' '
  say 'Name:     ' AMIF.HOTLIST.i.NAME
  say 'Address:  ' AMIF.HOTLIST.i.ADDRESS
  say 'Port:     ' AMIF.HOTLIST.i.PORT
  say 'Loginname:' AMIF.HOTLIST.i.USERNAME
  say 'Password: ' AMIF.HOTLIST.i.PASSWORD
  say 'Anonymous:' AMIF.HOTLIST.i.ANONYMOUS
  say 'RemoteDir:' AMIF.HOTLIST.i.REMOTEDIR
  say 'LocalDir: ' AMIF.HOTLIST.i.LOCALDIR
  say 'Proxy:    ' AMIF.HOTLIST.i.USEPROXY
  end i
*/

