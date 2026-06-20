; Library offsets for:  DOS, EXEC, GFX, INTITUITION.
; Offsets MMeany, data tables SKnipe.
; Set Devpac tab setting to 16 for a readable list


; dos.library

mode_newfile	equ $3ee
mode_oldfile	equ $3ed

open	equ -30	d1 d2	name accessmode
close	equ -36	d1	name
read	equ -42	d1 d2 d3	file buffer length
write	equ -48	d1 d2 d3	file buffer length
input	equ -54
output	equ -60
seek	equ -66
deletefile	equ -72	d1	name
rename	equ -78	d1 d2	oldname newname
lock	equ -84	d1 d2	name type
unlock	equ -90	d1	lock
duplock	equ -96	d1	lock
examine	equ -102	d1 d2	lock fileinfoblock
exnext	equ -108	d1 d2	lock fileinfoblock
info	equ -114	d1 d2	lock parameterblock
createdir	equ -120	d1	name
currentdir	equ -126	d1	lock
ioerr	equ -132
createproc	equ -138	d1 d2 d3 d4	name pri seglist stacksize
exit	equ -144	d1	returncode
loadseg	equ -150	d1	filename
unloadseg	equ -156	d1	segment
getpacket	equ -162	d1	wait
quepacket	equ -168	d1	packet
deviceproc	equ -174	d1	name
setcomment	equ -180	d1 d2	name comment
setprotection	equ -186	d1 d2	name mask
datestamp	equ -192	d1	date
delay	equ -198	d1	timeout
waitforchar	equ -204	d1 d2	file timeout
parentdir	equ -210	d1	lock
isinteractive	equ -216	d1	file
execute	equ -222	d1 d2 d3	string file file


; exec.library

execbase	equ 4

supervisor	equ -30
exitintr	equ -36
schedule	equ -42
reschedule	equ -48
switch	equ -54
dispatch	equ -60
exception	equ -66
initcode	equ -72	d0 d1	startclass version
initstruct	equ -78	d0 a1 a2	size inittable memory
makelibrary	equ -84	d0 d1 a0 a1 a2	datasize codesize funcinit structinit libinit
makefunctions	equ -90	a0 a1 a2	target functionarray funcdispbase
findresident	equ -96	a1	name
initresident	equ -102	d1 a1	seglist resident
alert	equ -108	d7 a5	alertnum parameters
debug	equ -114
disable	equ -120
enable	equ -126
forbid	equ -132
permit	equ -138
setsr	equ -144	d0 d1	newsr mask
superstate	equ -150
userstate	equ -156	d0	stackbytes
setintvector	equ -162	d0 a1	intnumber interupt
addintserver	equ -168	d0 a1	intnumber interupt
remintserver	equ -174	d0 a1	intnumber interupt
cause	equ -180	a1	interupt
allocate	equ -186	d0 a0	bytesize freelist
deallocate	equ -192	d0 a0 a1	bytesize freelist memoryblock
allocmem	equ -198	d0 d1	bytesize requirements
allocabs	equ -204	d0 a1	bytesize location
freemem	equ -210	d0 a1	bytesize memoryblock
availmem	equ -216	d1	requirements
allocentry	equ -222	a0	entry
freeentry	equ -228	a0	entry
insert	equ -234	a0 a1 a2	list node pred
addhead	equ -240	a0 a1	list node
addtail	equ -246	a0 a1	list node
remove	equ -252	a1	node
remhead	equ -258	a0	list
remtail	equ -264	a0	list
enqueue	equ -270	a0 a1	list node
findname	equ -276	a0 a1	list name
addtask	equ -282	a1 a2 a3	task initpc finalpc
remtask	equ -288	a1	task
findtask	equ -294	a1	name
settaskpri	equ -300	d0 a1	priority task
setsignal	equ -306	d0 d1	newsignals signallist
setexcept	equ -312	d0 d1	newsignals signallist
wait	equ -318	d0	signalset
signal	equ -324	d0 a1	signalset task
allocsignal	equ -330	d0	signalnum
freesignal	equ -336	d0	signalnum
alloctrap	equ -342	d0	trapnum
freetrap	equ -348	d0	trapnum
addport	equ -354	a1	port
remport	equ -360	a1	port
putmsg	equ -366	a0 a1	port message
getmsg	equ -372	a0	port
replymsg	equ -378	a1	message
waitport	equ -384	a0	port
findport	equ -390	a1	name
addlibrary	equ -396	a1	library
remlibrary	equ -402	a1	library
oldopenlibrary	equ -408	a1	libname
closelibrary	equ -414	a1	library
setfunction	equ -420	d0 a0 a1	funcentry funcoffset library
sumlibrary	equ -426	a1	library
adddevice	equ -432	a1	device
remdevice	equ -438	a1	device
opendevice	equ -444	d0 d1 a0 a1	unit flags devname iorequest
closedevice	equ -450	a1	iorequest
doio	equ -456	a1	iorequest
sendio	equ -462	a1	iorequest
checkio	equ -468	a1	iorequest
waitio	equ -474	a1	iorequest
abortio	equ -480	a1	iorequest
addrescource	equ -486	a1	resource
remrescource	equ -492	a1	resource
openrescource	equ -498	d0 a1	version resname
rawioinit	equ -504
rawmaygetchar	equ -510
rawputchar	equ -516	d0	char
rawdofmt	equ -522	a0 a1 a2 a3
getcc	equ -528
typeofmem	equ -534	a1	address
procedure	equ -540	a0 a1	semaport bidmsg
vacate	equ -546	a0	semaport
openlibrary	equ -552	d0 a1	version libname


; graphics.library


startlist	equ	38


bltbitmap	equ	-30
blttemplate	equ	-36
cleareol	equ	-42
clearscreen	equ	-48
textlength	equ	-54
text	equ	-60
setfont	equ	-66
openfont	equ	-72
closefont	equ	-78
asksoftstyle	equ	-84
setsoftstyle	equ	-90
addbob	equ	-96
addvsprite	equ	-102
docollision	equ	-108
drawglist	equ	-114
initgels	equ	-120
initmasks	equ	-126
remibob	equ	-132
remvsprite	equ	-138
setcollision	equ	-144
sortglist	equ	-150
addanimobj	equ	-156
animate	equ	-162
getgbuffers	equ	-168
initgmasks	equ	-174
gelsfunce	equ	-180
gelsfuncf	equ	-186
loadrgb4	equ	-192
initrastport	equ	-198
initvport	equ	-204
mrgcop	equ	-210
makevport	equ	-216
loadview	equ	-222
waitblit	equ	-228
setrast	equ	-234
move	equ	-240
draw	equ	-246
areamove	equ	-252
areadraw	equ	-258
areaend	equ	-264
waittof	equ	-270
qblit	equ	-276
initarea	equ	-282
setrgb4	equ	-288
qbsblit	equ	-294
bltclear	equ	-300
rectfill	equ	-306
bltpattern	equ	-312
readpixel	equ	-318
writepixel	equ	-324
flood	equ	-330
polydraw	equ	-336
setapen	equ	-342
setbpen	equ	-348
setdrmd	equ	-354
initview	equ	-360
cbump	equ	-366
cmove	equ	-372
cwait	equ	-378
vbeampos	equ	-384
initbitmap	equ	-390
scrollraster	equ	-396
waitbovp	equ	-402
getsprite	equ	-408
freesprite	equ	-414
changesprite	equ	-420
movesprite	equ	-426
locklayerrom	equ	-432
unlocklayerrom	equ	-438
syncsbitmap	equ	-444
copysbitmap	equ	-450
ownblitter	equ	-456
disownblitter	equ	-462
inittmpras	equ	-468
askfont	equ	-474
addfont	equ	-480
remfont	equ	-486
allocraster	equ	-492
freeraster	equ	-498
andrectregion	equ	-504
orrectregion	equ	-510
newregion	equ	-516
clearregion	equ	-528
disposeregion	equ	-534
freevportcoplists equ	-540
clipblit	equ	-552
xorrectregion	equ	-558
freecprlist	equ	-564
getcolormap	equ	-570
freecolormap	equ	-576
getrgb4	equ	-582
scrollvport	equ	-588
ucopperlistinit	equ	-594
freegbuffers	equ	-600
bltbitmaprastport equ	-606


; intuition.library

openintuition	equ	-30
intuition	equ	-36
addgadget	equ	-42
cleardmrequest	equ	-48
clearmenustrip	equ	-54
clearpointer	equ	-60
þclosescreen	equ	-66
closewindow	equ	-72
closeworkbench	equ	-78
currenttime	equ	-84
displayalert	equ	-90
displaybeep	equ	-96
doubleclick	equ	-102
drawborder	equ	-108
drawimage	equ	-114
endrequest	equ	-120
getdefprefs	equ	-126
getprefs	equ	-132
initrequester	equ	-138
itemaddress	equ	-144
modifyidcmp	equ	-150
modifyprop	equ	-156
movescreen	equ	-162
movewindow	equ	-168
offgadget	equ	-174
offmenu	equ	-180
ongadget	equ	-186
onmenu	equ	-192
openscreen	equ	-198
openwindow	equ	-204
openworkbench	equ	-210
printitext	equ	-216
refreshgadgets	equ	-222
removegadgets	equ	-228
reportmouse	equ	-234
request	equ	-240
screentoback	equ	-246
screentofront	equ	-252
setdmrequest	equ	-258
setmenustrip	equ	-264
setpointer	equ	-270
setwindowtitles	equ	-276
showtitle	equ	-282
sizewindow	equ	-288
viewaddress	equ	-294
viewportaddress	equ	-300
windowtoback	equ	-306
windowtofront	equ	-312
windowlimits	equ	-318
setprefs	equ	-324
intuitextlength	equ	-330
wbenchtoback	equ	-336
wbenchtofront	equ	-342
autorequest	equ	-348
beginrefresh	equ	-354
buildsysrequest	equ	-360
endrefresh	equ	-366
freesysrequest	equ	-372
makescreen	equ	-378
remakedisplay	equ	-384
rethinkdisplay	equ	-390
allocremember	equ	-396
alohaworkbench	equ	-402
freeremember	equ	-408
lockibase	equ	-414
unlockibase	equ	-420

