      ____ ___ _____  ___  ___  ___  ___
     (_,  V   ),  . \|,  ~]   |(___)|   |
..-----|o      |o  |  )o  7o  | \o  /o|  |------.    ^    ^    ^    ^   ^
|  ___|___Y___|_____/|___!_____/___L____|____  |   +----------------------+
| ( , !   )___)/,___)(___),  . \|,  \  \/,___) |   |Feel the DEATH inside!|
`--\o    /|o  (___  \|o  |o  |  )o      )__  \-'   `----------------------'
.p.\___/ |___(______)___!_____/|___!___|_____)       v    v    v    v   v

 WHQ: Extrema +39-861-413362
 IHQ: DoWn ToWn +39-2-48000352


Tutto il materiale presente in questa directory e` ***COPYDEATH*** Morbid
Visions.  I Morbid Visions (o alcuno degli autori) non assumono alcuna
responsabilita` circa eventuali danni, diretti o indiretti causati dall'uso
del suddetto materiale, ivi compresa la cottura del monitor!

NOTE SUI SORGENTI
I sorgenti sono stati scritti per l'ASM-One 1.29 dei T.F.A.  Tutti i sorgenti
hanno all'inizio una INCDIR "Infamia:MV_Code/".  Per assemblare e` quindi
necessario eseguire un "ASSIGN INFAMIA:" alla directory che contiene la
directory MV_Code, oppure dovete modificare gli INCDIR nei sorgenti.  Tutti i
sorgenti fanno uso del medesimo codice di startup, contenuto nel file
MVStartup.S.  Si tratta di un codice di startup MOLTO semplice de usare solo
per le prove.  Non usatelo per le vostre demo!

Nei sorgenti utilizziamo le Oscure Regole stabilite dai Testi Oscuri
Del Coding Mortale, i libri in cui viene espressa la filosofia del coding
dei Morbid Visions. Per favorire la lettura a chi e` abituato ai sorgenti del
corso di Randy, elenchiamo alcune delle Oscure Regole che differiscono dalle
convenzioni seguite nel corso:

- La dimensione degli operandi viene indicata solo quando essa e` diversa
da quella di default. (Ricordiamo che per default, se non viene specificata
la dimensione l'ASMOne assume che la dimensione sia WORD, tranne che per
quelle istruzioni a dimensione fissa, come Scc (che ha dimensione BYTE),
BTST (che ha dimensione BYTE se la destinazione e` in memoria e LONG se
la destiazione e` un registro), ecc.
Ad esempio:
 move	d0,d1		indica		move.w	d0,d1
 btst	#6,$bfe001	indica		btst.b	#6,$bfe001.
 btst	#14,d0		indica		btst.l	#14,d0
 lea	label,a0	indica		lea.l	label,a0).

- NON viene fatto il doppio test di attesa del blitter: per aspettare
il blitter effettuiamo una semplice:

.wait
	btst	#6,dmaconr(a5)		;aspetta il blitter
	bne.s	.wait

il famoso BUG di Agnus e` presente solo in pochissimi esemplari montati
sui primi A1000, ed inoltre si manifesta in circostanze paricolari.
Questo BUG e` diventato un luogo comune, ma in realta` nessuno l'ha
mai visto. I test che abbiamo effettuato sull'A1000 di The Hobbit / MV
non hanno riscontrato il BUG. TUTTE le nostre routines OCS funzionano su
TUTTI gli Amiga OCS SENZA il doppio test. Quando ormai anche l'era dell'AGA
volge al tramonto non ha senso portarsi appresso queste inutili BTST aggiuntive
che rovinano l'estetica dei sorgenti.

- Vengono usate spesso MACRO e label locali, che rendono il codice piu`
ordinato e leggibile.

 Morbid Visions
