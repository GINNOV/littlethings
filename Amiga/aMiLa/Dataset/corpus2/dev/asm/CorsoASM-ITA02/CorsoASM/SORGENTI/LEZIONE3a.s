
; Lezione3a.s	- COME SI ESEGUE UNA ROUTINE DEL SISTEMA OPERATIVO

Inizio:
	move.l	$4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
mouse:
	move.w	$dff006,$dff180	; metti VHPOSR in COLOR00 (lampeggio!!)
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	4.w,a6		; Execbase in a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	rts

	END

Questo e' il primo listato in cui usiamo una routine del sistema operativo!
E guarda caso proprio quella che disabilita il sistema operativo stesso!
Infatti noterete che durante l'esecuzione la freccia controllata dal mouse si
blocca, premendo il tasto destro non appaiono i menu a tendina, i disk drive
smettono di fare click. E state attenti che anche il comando AD, ossia il
debugger, che usa il sistema operativo, viene disabilitato, rimanendo bloccato!
ricordatevi quindi che quando disabilitiamo il sistema operativo, o addirittura
puntiamo una nostra copperlist, il debugger serve fino a che il sistema
operativo e' vivo!
Provate comunque a fare "AD", premendo il tasto cursore con la freccia verso
destra (con questo tasto infatti si "penetra" dentro i BSR e JSR, mentre col
tasto cursore con la freccia verso il basso si salta il debug di BSR e JSR).
Passata la prima istruzione, il MOVE.L 4.w,a6, comparira' nel registro A6
l'indirizzo che era contenuta nela long composta dai 4 bytes $4,$5,$6,$7.
Premete ESC e veririficate facendo un "M 4", premendo 4 volte return: troverete
infatti lo stesso indirizzo. Questo indirizzo e' messo in quel punto dal kick
ogni volta che si resetta o si accende l'amiga.
Riprendete il debug, passate il MOVE.L 4.w,a6, ed "entrate" nel JSR -$78(a6)
con i cursore: per seguire la subroutine dovete osservare la linea disassembly
in fondo allo schermo, infatti noterete una istruzione JMP $fcxxxx o $f8xxxx,
a seconda se avete un kick 1.3 o 2.0/3.0. Siete all'indirizzo che era in $4
meno $78, e vi trovate nella memoria RAM del vostro Amiga ancora, dove pero'
trovate un JMP che vi fara' saltare nella ROM. Infatti, ogni volta che
l'Amiga perde quel secondo o due durante il RESET, o l'accensione, crea in
memoria una TABELLA DI JMP, il cui indirizzo finale e' messo in $4.
Ogni JMP salta all'indirizzo di quel particolare kickstart dove si trova la
routine corrispondente alla posizione di quel JMP rispetto alla sua fine.
Infatti facendo JSR -$78(a6) si disabilita il multitasking sia su un kick 1.2
che su un kick 1.3, o 2.0 o 3.0, cosi' pure per quelli futuri.
Se per esempio nel kick 1.3 la routine nel ROM si trovasse a $fc12345, il
JMP posto a $78 bytes sotto l'indirizzo base sara' JMP $fc12345, mentre
se su un kick 2.0 la routine in questione fosse a $f812345, il JMP in questione
sara' a $f812345. Questo sistema permette anche di caricare un kickstart in
RAM: bastera' poi che faccia una TABELLA DI JMP che puntino alle sue routines.
Fermate il debug con ESC dopo esservi annotati a che indirizzo era il JMP,
e provate a fare un "D quell'indirizzo" (l'indirizzo dell'istruzione e' il
primo numero a sinistra in fondo allo schermo! oppure lo trovate anche in
fondo alla lista dei registri sulla destra, e' il registro PC, ossia Program
Counter, che registra l'indirizzo in esecuzione, basta che gli aggiungiate un
$ davanti). Verificherete che c'e una fila di JMP; questo e' un esempio:

	JMP	$00F817EA	; -$78(a6), ossia il DISABLE
	JMP	$00F833DC	; -$72(a6) un'altra routine
	JMP	$00F83064	; -$6c(a6) un'altra routine...
	JMP	$00F80F74	; ....
	JMP	$00F80F0C
	JMP	$00F81B74
	JMP	$00F81AEC
	JMP	$00F8103A
	JMP	$00F80F3C
	JMP	$00F81444
	JMP	$00F813A0
	JMP	$00F814F8
	JMP	$00F82842
	JMP	$00F812F8
	JMP	$00F812D6
	JMP	$00F80B38
	JMP	$00F82C24
	JMP	$00F82C24
	JMP	$00F82C20
	JMP	$00F82C18

Per inserire pezzi di disassemblato nel sorgente ho usato il comando "ID",
in cui bisogna dire l'inizio e la fine della zona da inserire:

BEG> qua mettete l'indirizzo o la label, provate con l'indirizzo del JMP
END> mettete l'indirizzo finale, oppure $xxxxx+$80, intendendo per $xxxxx
     l'indirizzo di partenza: in questo caso si otterra' il disassemblato
     a partire dall'indirizzo $xxxxx fino a $80 bytes dopo.

REMOVE UNUSED LABELS? (Y/N)	; QUA METTETE UN "Y". Se non lo mettete sara'
				; messa una label recante l'indirizzo ad
				; ogni linea di codice, anziche' solo dove
				; serve la label. Provate a fare un "ID"
				; di questo listato per verificare la
				; differenza.

Esempio: se l'indirizzo era $32123

ID

BEG> $32123
END> $32123+$80		; NOTA: per riavere i vecchi indirizzi premete
			; il tasto cursore verso l'alto varie volte.
			; (Infatti premendo la freccia verso l'alto ritornano
			; le cose che avete scritto prima come nello SHELL)

e apparira', a partire dal punto dove eravate col cursore l'ultima volta nel
testo, il disassemblato richiesto.

Ora vi potete immaginare quanti JSR e JMP deve eseguire il processore quando
un programma gli chiede di eseguire delle routine. E tutto questo saltare fa
perdere tempo, e' per questo che useremo il sistema operativo solo il minimo
indispensabile.

Se continuate con il DEBUG dopo il JMP, vi ritroverete nella ROM, cioe'
all'indirizzo del JMP: di solito il DISABLE e' cosi':

	MOVE.W	#$4000,$dff09a	; INTENA - Ferma gli interrupt
	ADDQ.B	#1,$126(a6)	; Ferma il sistema operativo
	RTS

Se ci entrate premendo la freccia verso destra le istruzioni saranno viste,
ma non eseguite (per sicurezza il debug quando esegue delle subroutine fuori
dal listato, ossia di solito nella ROM, le scorre e basta), infatti potete
continuare e andare nel loop del mouse e noterete che la freccia del mouse
si puo' muovere e i drive fanno il click, cioe' non sono state eseguite
quelle 2 operazioni. Potrete passare anche dal JSR -$7e(a6) e uscire.

Provate invece a scendere usando il tasto cursore con la freccia verso il
basso: questa volta passando dal JSR -$78(a6) il programma vi scappera' di
mano, perche' viene eseguita (senza pero' essere mostrata).
Potrete comunque uscire con il tasto sinistro, dopodiche' dovrete premere
da ESC per uscire dal DEBUG.

Provate ora a fare queste modifiche:

1) Assemblate, fate un "D inizio" e vedrete questo:

	MOVE.L	$0004.W,A6

Provate ora a togliere il .w al 4 nel listato, assemblate e ripetete il "D":

	MOVE.L	$00000004,A6

Come vedete, in questo caso sono stati usati tutti i 4 byte dell'indirizzo,
mentre prima con l'opzione .w abbiamo risparmiato 2 bytes. L'opzione .w
puo' essere usata su tutti gli indirizzi linghi una sola word o meno.

2) Provate a sostituire la linea

	JSR	-$78(a6)

con le linee

	MOVE.W	#$4000,$dff09a	; INTENA - Ferma gli interrupt
	ADDQ.B	#1,$126(a6)	; Ferma il sistema operativo

O comunque quello che trovate nella ROM dopo il JMP (senza l'RTS finale!).

Noterete che il funzionamento e' lo stesso.

Potete fare la stessa cosa con il JSR -$7e(a6).

