
; Lezione2i.s

Inizio:
	lea	$dff000,a0	; metti $dff000 in a0
Waitmouse:
	move.w	6(a0),$180(a0)	; metti il valore .w di $dff006 nel color 0
				; 6(a0)=$dff000+6, $180(a0)=$dff000+$180
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti tutto
	rts			; esci

	END

In questa variazione del primo listato sono presenti delle distanze di
indirizzamento: in a0 viene messo l'indirizzo $dff000 (in questo caso si
sceglie perche' e' pari e quando si fanno le distanze di indirizzamento
si possono riconoscere a quali indirizzi si fa riferimento: per esempio
il color0, cioe' il $dff180, si puo' raggiungere con $180(a0), ed e'
evidente che si tratta del $dff180. Se per esempio in a0 avessi messo
l'indirizzo $dff013, per indicare il color0 la giusta distanza di
indirizzamento sarebbe stata $16d(a0), infatti $dff013+$16d=$dff180).
Da notare che il registro a0 non viene mai cambiato, rimane sempre
$dff000, e ogni volta il processore calcola a quale indirizzo ci stiamo
riferendo sommando la distanza di indirizzamento all'indirizzo in a0.
In quasi tutti i programmi che usano la grafica l'indirizzo $dff000 viene
messo in qualche registro per farci la distanza di indirizzamento (o OFFSET),
infatti in questo modo si possono raggiungere tutti i registri CUSTOM
(che finiscono a $DFF1fe).
Si puo' indicare un offset al massimo da -32768 a +32767, ossia da -$8000
a $7FFF.

NOTA:
fate attenzione alla differenza che c'e' tra il LEA ed il MOVE quando
si usa una distanza di indirizzamento:

	MOVE.L	$100(a0),a1

Copia la longword CONTENUTA nell'indirizzo che si trova piu' avanti di quello
in a0 di $100 bytes, nel registro a1. QUINDI: "FAI LA SOMMA TRA L'INDIRIZZO
IN A0 E IL NUMERO PRIMA DELLA PARENTESI; IL RISULTATO E' L'INDIRIZZO DA CUI
VERRA' COPIATA LA LONGWORD IN A1".

mentre:

	LEA	$100(a0),a1

Mette in a1 l'indirizzo risultante dalla somma di a0+$100, non il suo contenuto
infatti il comando LEA serve solo per caricare INDIRIZZI, non CONTENUTI.

Facciamo un esempio per chiarire: consideriamo gli indirizzi di memoria come
gli indirizzi di una lunga strada assolata con tante villette in fila, ognuna
con un numero civico. Se mettiamo in a0 l'indirizzo 0, ossia l'indirizzo della
prima casa, con l'istruzione MOVE.L $100(a0),a1, non facciamo altro che mettere
in a1 il tappeto e i mobili dell'ingresso della casa n.$100, ossia ne copiamo
il CONTENUTO per la lunghezza di una longword in a1.
Invece con LEA $100(a0),a1 mettiamo in a1 l'indirizzo della casa $100 senza
entrarci. La differenza sta che con il MOVE in a1 abbiamo messo i mobili,
con il lea invece l'indirizzo. Per CONTENUTO intendo cio' che e' negli
indirizzi, infatti in ogni indirizzo (ogni casa) c'e' sempre qualcosa: puo'
essere un numero (quando ci sono i mobili) oppure puo' essere vuoto (quando la
casa e' abbandonata, ma da cui si puo' prendere ZERO ($00) comunque).

Per esempio l'istruzione

	LEA	$100(a1),a1

E' equivalente all'istruzione:

	ADD.W	#$100,a1

Perche' in a1 viene messo, appunto, l'indirizzo in a1+$100.

NOTA: le distanze di indirizzamento le potere scrivere in decimale o in
esadecimale (col simbolo del $) a piacere, e potete anche mettere delle
moltiplicazioni o delle divisioni etc:

	lea	$10*3(a1),a2	; ovvero sara' assemblato LEA $30(a1),a2
				; infatti * significa MOLTIPLICA
	
