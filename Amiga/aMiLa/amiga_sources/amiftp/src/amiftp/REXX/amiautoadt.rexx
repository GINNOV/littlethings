

/* Temp directory, where AutoADT will store some temporary files.  MUST END
IN / or :  */ 
temppath = 'T:'


/* Place where the unfilable files will go MUST END IN / or : */
badpath =  'T:'


/* AutoADT's logfile */
logfilename = 'ram:AutoADT.log'


/* Full path & filname of DaFTP */
Amiftp = 'dh1:tcp/amiftp/AmiFTP'


/* Give up after a failed transfer?  0=no, 1=yes */
giveup = 0


/* Give up after how many connect retries?  0=try forever (not reccomended */
retries = 5

/* Overwrite existing files?  0=no, 1=yes */
overwrite = 1

options results
                               
if ~show(l, 'rexxsupport.library') then
        if ~addlib('rexxsupport.library', 0, -30, 0) then do
		say 'error, can''t load rexxsupport.library'
                exit 50
	end


say '[1mAutoADT 2.00ß for AmiFTP[0m - by Dan Fraser'
say ''

if ~show('P','AMIFTP') then do /* run AmiFTP! */
	address command 'run >nil: 'amiftp
	address command 'waitforport AMIFTP'
end

address AMIFTP
'SITE aminet' 

'GETATTR STEM=DaSetup' 
RootPath = DaSetup.LocalDir 
say 'Rootpath: 'rootpath

if ~Connect() then do
	say 'Unable to connect!  Check yer config in AmiFTP''s hotlist.'
	exit 5
end


if ~exists(logfilename) then do
	say 'Creating new logfile...'
	if open(logfile,logfilename,'W') then do
		call writeln(logfile,'Logfile created on '||date('o')||'at '||time('c')||'.')
		call close(logfile)
		say 'Done!'
	end
	else do
		say 'oof! Couldn''t make a log, for some reason.'
		exit(5)
	end
end

if ~exists( "ENVARC:AutoADT" ) then do
	say 'Creating new config file...'
	if open(configfile,"ENVARC:AutoADT",'W') then do
                        call writeln(configfile,'0')
                        call close(configfile)
			say 'Done!'
	end
	else do
		say 'oof!  I couldn''t create a config file for some reason!'
		exit(5)
	end
end

if open(configfile,"ENVARC:AutoADT",'R') then do
	lastdate = readln(configfile)
	call close(configfile)
end
else do
        lastdate = 0
end

call dolog('**** AutoADT started successfully.  Wow!  Suprised?')

'SETATTR LOCALDIR '||temppath

'get bin /pub/aminet/info/adt/ADT_RECENT_7'
if result=0 then do
	call dolog('Zap!  Error getting recent file.')
	say 'bah!  I couldn''t get the ADT_RECENT_7 file, and I kinda need it.'
	exit 5
end

say 'Sorting...'
address command 'sort 'temppath'ADT_RECENT_7 'temppath'ADT_RECENT_SORT'

if ~open(recentfile,temppath'ADT_RECENT_SORT','R') then do
	call dolog('ERROR - Couldn''t open sorted RECENT file')
	say 'oof! Couldn''t open sorted RECENT file!'
	exit 10
end

say 'Picking up new files...'

line = readln(recentfile)
if line ~= "#adt-v2" then do
        call close(frecent)
        say 'Wrong ADT_RECENT version.  That''s unusual.'
	exit 5
end

do while left(line,1)="#"
        line=readln(recentfile)
end

line=readln(recentfile)
do while ~eof(recentfile) & left(line,1)~='#'
	
	parse var line file.date '@' file.dir '@' file.name '@'.'@'.'@'.'@'.'@' file.desc
	if file.date>lastdate then do
		if ~exists(rootpath||file.dir) then do
			localdir=left(badpath,length(badpath)-1)
			say 'Directory 'rootpath||file.dir' doesn''t exist!  Putting file in ''bad'' directory...'
		end
		else localdir=rootpath||file.dir

		if (~exists(localdir'/'file.name) | overwrite) & (pos('ArcsPack',file.name)=0) & (pos('dw-',file.name)=0) then do
			'setattr localdir='localdir'/'
			'get bin /pub/aminet/'file.dir'/'file.name
		end

	        stringpos = 1
        	do while stringpos < length(file.desc)+1
                	if substr(file.desc,stringpos,1)='"' then do
                        	file.desc=insert('*',file.desc,stringpos-1)
                                stringpos=stringpos+1
	                end
                	if substr(file.desc,stringpos,1)='*' then do
                        	file.desc=insert('*',file.desc,stringpos-1)
                                stringpos=stringpos+1
	                end
        	        stringpos=stringpos+1
                end
		
		if exists(localdir'/'file.name) then do
			if localdir=left(badpath,length(badpath)-1) then file.desc = file.dir': 'file.desc
			address command 'filenote '||localdir||'/'||file.name||' "'||file.desc||'"'
			say 'Added filenote: 'file.desc
			lastdate=file.date
			if open(configfile,'ENVARC:AutoADT','W') then do
                		call writeln(configfile,lastdate)
			        call close(configfile)
        		end; else say 'couldn''t write configfile!'
			say '' 
		end 
		else do
			say 'um, I don''t think that file made it.'
			call dolog('um, I don''t think that file made it.')
			if giveup then do
				say 'giving up...'
				exit 5
			end
		end	

	end

	line=readln(recentfile)			
end
say 'All done!'
call close(recentfile)
address command 'delete 'temppath'ADT_RECENT_7 QUIET'
address command 'delete 'temppath'ADT_RECENT_SORT QUIET'

'disconnect'
'quit'
exit 0

DoLog: procedure expose logfilename
   parse arg logstring
   if open(logfile,logfilename,'A') then do
          call writeln(logfile,date('O')||' 'time('N')||'  '||logstring)
          call close(logit)
   end
return 0

Connect: procedure expose retries
	DaSetup.Connected=0
	Count=0
	do while DaSetup.Connected=0 & (Count < Retries | Retries=0)
		'CONNECT noscan'
		Count=Count+1
		'GETATTR STEM=DaSetup'
	end
return DaSetup.Connected
