
; Lezione2m.s

; Dimostrazione che lavorando con i registri indirizzi a0...a7 si opera sempre
; su tutta la longword, sia con il consueto .L che con il .W.


inizio:
	move.l	#$FFFFFF,d0
	ADDQ.W	#4,d0		; Aggiungi.w 4 a d0, ma lavora solo sulla word
				; perche' siamo su un registro DATI (lo stesso
				; farebbe su una label)
	lea	$FFFFFF,a0
	ADDQ.W	#4,a0		; Aggiungi.w 4 ad a0, ma lavorando su un
				; registro INDIRIZZI l'add coinvolge tutto
				; l'indirizzo, ossia la longword.
	rts

	end

Provate a fare un debug di questo listato (AD) e passo passo noterete la
differenza principale tra un registro indirizzi e un registro dati o qualsiasi
label. Questa differenza e' che su registri indirizzi si lavora sempre su tutto
l'indirizzo, ossia su tutta la longword, infatti non e' possibile operare con
istruzioni .B su tali registri, e quando si lavora col .W (possibile solo nel
caso che aggiungiamo/sottraiamo/muoviamo numeri piu' piccoli di una word) il
risultato e' lo stesso di un .L. Dunque potete anche sempre usare il .L, ma
nei casi in cui e' possibile conviene "OTTIMIZZARE" l'istruzione cambiandola
in .W, dato che e' piu' veloce di quella .L.
Facendo il DEBUG di questo listatino noterete che l'ADDQ.W #4,d0 opera solo
sulla word, appunto, di D0, e lo cambia in $00FF0003, dato che dopo $FFFF
riparte da capo la numerazione con $0000, poi arriva a $0003, ma non e'
coinvolta la parte alta del numero.
Se invece faceste un ADDQ.L #4,d0 (provate!) tale ADD coinvolgerebbe l'intera
LONG, trasformandola in $01000003, infatti dopo $00FFFFFF viene $01000000.
Invece operando su registri indirizzi l'ADD.W fa come l'ADD.L, solo che non
puo' essere usato sempre, ad esempio non puo' essere usato per un numero come
per esempio $123456. Nonostante non sia un errore, ricordatevi sempre di usare
il .W anziche' il .L in queste istruzioni con i registri indirizzi per fare
codice leggermente piu' veloce.

	ADD.L	#$123,a0	; ottimizzabile in ADD.W #$123,a0
	ADD.L	#$12345,a0	; non ottimizzabile

