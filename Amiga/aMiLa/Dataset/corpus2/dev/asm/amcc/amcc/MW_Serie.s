Introduction
	01 - Amiga Machine Code
	02 - Amiga Machine Code Setup
Letter I
	03 - Amiga Machine Code Letter I
	04 - Amiga Machine Code Letter I - Deep Dive
	05 - Amiga Machine Code Letter I - Debugger
	06 - Amiga Machine Code Letter I - Hint
Letter II
	07 - Amiga Machine Code Letter II - Part 1
	08 - Amiga Machine Code Letter II - Part 2
	09 - Amiga Machine Code Detour - Reverse Engineering
Letter III
	10 - Amiga Machine Code Letter III - Copper Revisted
	11 - Amiga Machine Code Letter III - Branching
Letter IV
	12 - Amiga Machine Code Letter IV
	13 - Amiga Machine Code Letter IV - DMA Revisted
	14 - Amiga Machine Code Letter IV - More Code
Letter V
	15 - Amiga Machine Code Letter V
	16 - Amiga Machine Code Letter V - Sprites
Letter VI
	17 - Amiga Machine Code Letter VI - Blitter
	18 - Amiga Machine Code Letter VI - Blitter 2
	19 - Amiga Machine Code Letter VI - Blitter 3
	20 - Make Your Own Graphic Assets
Letter VII
	21 - Amiga Machine Code Letter VII - Blitting and Scrolling
	22 - Amiga Machine Code Letter VII - Colorcycling
Letter VIII
	23 - Amiga Machine Code Letter VIII - Audio
	24 - Amiga Machine Code Letter VIII - Wavetable Synthesis
Letter IX
	25 - Amiga Machine Code Letter IX - Interrupts
Letter X
	26 - Amiga Machine Code Letter X - Memory
	27 - Amiga Machine Code Letter X - Files
	28 - Amiga Machine Code Letter X - CLI
	29 - Amiga Machine Code Letter X - More CLI
	30 - Amiga Machine Code Letter X - Trackdisk
Letter XI
	31 - Amiga Machine Code Letter XI - The Mouse
	32 - Amiga Machine Code Letter XI - The Printer
	33 - Amiga Machine Code Letter XI - Fizzle Fade
Letter XII
	34 - Amiga Machine Code Letter XII- HAM
	35 - Amiga Machine Code Letter XII- Vertical Scalling Using the Copper
	36 - Amiga Machine Code Letter XII- The Starfield Effect
	37 - Amiga Machine Code Letter XII- Horizontal Sine Shifting
	Other posts comming soon

;------------------------------------------------------------------------------
01 - Amiga Machine Code

Amiga-Maschinencode
28. Dezember 2018  2 min lesen
Bill Bertram 2006, CC-BY-2.5

In den frühen neunziger Jahren hatte meine Mutter die große Voraussicht, mir
einen Amiga 500 und einen Kurs in Amiga-Maschinencode zu kaufen. Das war lange
bevor Marc Andressens berühmter Aufsatz Warum Software die Welt isst, deutlich
machte, dass Software tatsächlich die Welt frisst.

http://www.aberdeeninvestment.com/wp-content/uploads/2009/11/Why-Software-Is-Eating-The-World-8-20-111.pdf

Meine Mutter hoffte, dass ich den Amiga zum Programmieren verwenden könnte und
versuchte wirklich, mich zu motivieren. Sie brachte mir sogar das 
Binärzahlensystem bei und machte Übungsblätter für mich.

Abbildung 01-1: Blatt für Binärzahlen

Schließlich haben die Spiele gewonnen und ich habe den Amiga-Maschinencode
nicht gelernt. Später im Leben hatte ich das Gefühl, etwas verpasst zu haben,
zumal ich viel Code für meinen Lebensunterhalt geschrieben habe.

Kürzlich habe ich den alten Amiga-Maschinencode-Kurs wiederentdeckt, der
jahrelang in einer Box versteckt war. Es waren zwölf Briefe, die jeden Monat
per Post verschickt wurden, und es gab sogar eine Hotline, die man anrufen
konnte, wenn man feststeckte.

Abbildung 01-2:	Dataskolen

Die Buchstaben wurden auf rotes Papier gedruckt. Dies war ein Kopierschutzschema
der alten Schule, da fotokopierte Seiten schwarz erscheinen würden. Damals hieß
es auf der Straße, es könne mit einer gelben transparenten Folie besiegt werden.

Heute kann jeder diese Briefe kostenlos bekommen und sie wurden sogar ins
Englische übersetzt. Sie können die Briefe und die Disketten hier bekommen:

http://palbo.dk/dataskolen/maskinsprog/

In den nächsten Beiträgen werde ich die zwölf Briefe durchgehen und den Kurs
abschließen, den ich vor langer Zeit hätte machen sollen, und Sie können auch
mitkommen!

;------------------------------------------------------------------------------
02 - Amiga Machine Code Setup

Amiga Machine Code Setup
1. Januar 2019  4 min lesen

Abbildung 02-01: Gute Zeiten - aber nicht viel Codierung ;-)

In diesem Beitrag werde ich kurz die Entwicklungsumgebung beschreiben, die ich
auf der Reise durch den Amiga Machine Code-Kurs verwenden werde.

Es ist Jahre her, seit ich meinen Amiga 500 das letzte Mal benutzt habe und
alle Teile sind jetzt in Kartons aufbewahrt. Ohne die Hardware und die
Disketten schien es praktisch unmöglich, Amiga-Maschinencode zu lernen.

Es stellt sich jedoch heraus, dass es viele Amiga-Enthusiasten gibt, die Tools,
Spiele und sogar Bücher digitalisiert haben. Es ist alles da draußen im
Internet! Ich habe auch den ultimativen Ultimate Amiga Emulator (UAE) entdeckt,
der alle Arten von Amiga-Hardwarekonfigurationen emulieren kann.

Es ist ein enormes Geschenk, das diese Leute uns allen gegeben haben, und das
Lesen ihrer persönlichen Blogs lässt den Amiga fast wieder zum Leben erwecken.
Ich fühle mich wie ein digitaler Archäologe, der alte Schätze wiederentdeckt.

Ich habe den Amiga Machine Code-Kurs bereits 1990 als Geschenk erhalten. Der
Kurs wurde nicht im Voraus bezahlt, sondern im Laufe der Zeit. Um den gesamten
Kurs abzuschließen, war Folgendes erforderlich.

Ein Assembler. Sie empfehlen die K-SEKA. Preis 760 DKK
Letter I-XII: Preis 148 DKK pro Brief
Datenträger I: 97 DKK
Datenträger II: 97 DKK
(Summe: 2.730DKK)
Alle Preise sind ab 1990 und im Jahr 2019 würde es sich auf 4.836 DKK
belaufen, also war es nicht billig! Heute können Sie ganz einfach eine Sony
Playstation 4 mit Zubehör kaufen.

Erstaunlicherweise hat sich jemand die Mühe gemacht, ein digitales Archiv für
die Briefe und Datenträger zu erstellen. Die Briefe wurden sogar ins Englische
übersetzt. Der ursprüngliche Inhaber des Urheberrechts hat zugestimmt, alles
kostenlos zur Verfügung zu stellen.  

http://palbo.dk/dataskolen/maskinsprog/

Beim Emulator werde ich mit WinUAE fortfahren, da ich auf einem Windows-
System arbeiten werde. Wenn Sie unter Mac oder Linux arbeiten, sollten Sie
FS-UAE in Betracht ziehen.

Unabhängig vom Emulator benötigen Sie ein Kickstart 1.3 ROM. Amiga Forever hat
diese ROM-Datei zu einem vernünftigen Preis.

Der empfohlene Assembler ist der K-Seka, aber ich weiß nicht, welche Version.
Ich entdeckte, dass Demogruppen den Seka-Assembler an ihre Bedürfnisse
angepasst und erweitert hatten, und schließlich etablierten sie sich als
eigenständige Versionen.

Boushh von The Flame Arrows (TFA) beschreibt die Entwicklung von K-Seka zu
AsmOne. Es ist eine inspirierende Lektüre, die den Eindruck hinterlässt, dass
alles möglich war. Die Tools konnten optimiert werden und wurden von Leuten
optimiert, die eine Art Beherrschung der Amiga-Plattform erreicht hatten.

Von den vielen Geschmacksrichtungen werde ich mit dem Seka v2.1 von Megaforce
fortfahren.

Die Briefe enthalten Hinweise zur Verwendung des Seka-Assemblers, aber ich habe
einen kleinen Spickzettel geschrieben, um alles an einem Ort zu haben.

Ich habe auch eine solide Dokumentation in Kapitel 3.3 der Amiga Machine
Language von Stefan Dittrich (ISBN 1-55755-025-5) gefunden. Genau wie viele
Amiga-Bücher und -Magazine ist es auf archive.org verfügbar. Es ist
erstaunlich, dass all dieses Zeug noch erhalten ist. Hier ist ein Bild meiner
dänischen Version des Buches.

Abbildung 02-2: Maskinsprog

Nehmen wir das Setup für eine Probefahrt!
Ich möchte ein Setup, das dem sehr ähnlich ist, was ich damals hatte: Ein Amiga
500 mit zwei Diskettenlaufwerken und einer RAM-Erweiterung. Ich hatte auch eine
Action Replay-Karte, die hier aber nicht benötigt wird.

Ich habe die UAE-Standardkonfiguration für einen Amiga 500 verwendet und ein
zusätzliches Diskettenlaufwerk hinzugefügt. Sie heißen DF0: und DF1:, was
Standard-Amiga-Jargon ist. WinUAE-Konfiguration

Abbildung 02-3: WinUAE Configuration

Oft habe ich mich gefragt, ob das System noch am Leben ist, da das Lesen von
einem Diskettenlaufwerk einige Zeit in Anspruch nimmt. Dann erinnerte ich mich
daran, dass wir damals das Diskettenlaufwerk hören konnten. Das Audio-Feedback
spielte eine subtile, aber wichtige Rolle für die Benutzerfreundlichkeit.

Abbildung 02-4: WinUAE Floppy Drive Emulation

WinUAE kann den Sound des Diskettenantriebsmotors emulieren und die Lautstärke
kann individuell eingestellt werden.

Abbildung 02-5: WinUAE Sound

In der WinUAE-Konfiguration habe ich das Diskettenlaufwerk DF0: so eingestellt,
dass es die Seka-Disk enthält. Wenn das System hochfährt, liest es von der
Diskette und startet den Seka-Assembler.

Das andere Diskettenlaufwerk DF1: kann für die Sicherungsdiskette für den Code
verwendet werden. Seka

Abbildung 02-6: Seka-Screenshot

Im nächsten Beitrag werden wir uns eingehend mit dem ersten Brief des
Maschinencode-Kurses befassen.

weblinks:
https://www.winuae.net/
https://www.oldmoney.dk/?belob=2730&index=Index1&fra_aar=1990&til_aar=2019&submit=OMREGN
https://fs-uae.net/
https://www.amigaforever.com/
theflamearrows.info/documents/asminfo.html		; Asmone
http://www.pouet.net/prod.php?which=48006		; Seka V2.1
https://archive.org/details/Amiga_Machine_Language_1991_Abacus/page/n59
http://amiga.resource.cx/exp/actionreplay		; ActionReplay Doc

;------------------------------------------------------------------------------
03 - Amiga Machine Code Letter I

Amiga Machine Code Letter I.
3. Januar 2019  4 min lesen

In diesem Beitrag werfen wir einen Blick auf den ersten Brief des Amiga-
Maschinencode-Kurses. Der Brief ist hier frei erhältlich:

http://palbo.dk/dataskolen/maskinsprog/

Der Brief beginnt mit einer Einführung in die Binär- und Hex-Zahlensysteme. Uns
wird gesagt, dass es sehr wichtig ist, diese Zahlensysteme zu lernen, und dass
sie später von großem Nutzen sein werden.

Als Kind war ich ein bisschen faul (wer war das nicht?), also kannte ich die
Konzepte, aber ich kam nie wirklich an den Punkt, an dem ich Binär und Hex für
irgendetwas nützliches verwendete. Außerdem konnte ich nicht überprüfen, ob
das, was ich tat, richtig war. Ich musste nur einen Monat warten, bis der
nächste Brief, mit den Lösungen für die Aufgaben im vorherigen Brief kam.

Im ersten Brief wird die Umrechnung zwischen den Zahlensystemen beschrieben.
Die Konvertierung zwischen Dezimal, Hex und Binär ist eine mühsame Aufgabe,
und der Autor schlägt vor, dass Sie einen Taschenrechner kaufen, um die Aufgabe
zu erledigen. Ich finde das ein wenig rätselhaft, da der Seka-Assembler solche
Funktionen eingebaut hat!

Mit dem Fragezeichen-Operator "?" gefolgt von einer Zahl im Seka-Befehlsbereich
oder im Code-Editor ist es möglich, durch Seka die Konvertierung schnell
durchführen zu lassen. Es is kein dedizierter Taschenrechner erforderlich.
Beachten Sie, dass "$" und "%" vor der Zahl Hex- und Binärzahlen bezeichnen.

Abbildung 03-1: Seka Umwandlung von Zahlen

>? 10
>? $10
>? %10

Der Autor weist darauf hin, dass die Konvertierung zwischen hexadezimal und
binär sehr einfach ist. Es wird ein kleiner Algorithmus vorgestellt, mit dem
sie die Konvertierung in Ihrem Kopf weitaus schneller als mit jedem
Taschenrechner durchführen können.

Am Ende des Briefes erhalten wir eine Erklärung des Chipspeichers und des Fast
RAMs. Um den Unterschied zu erklären, müssen wir uns ein wenig mit der Hardware
des Amigas befassen. Der Amiga besteht aus einer CPU, einem Motorola 68000 und
drei Zusatzchips namens Paula, Agnus und Denise.

Auf den Chip RAM können alle vier Chips zugreifen, was ihn langsam macht.
Andererseits kann kein Chip außer der CPU auf den Fast RAM zugreifen. Da nur
ein Chip Zugriff hat, wird der Speicherzugriff schneller.

Es gibt eine gute Illustration des Speichers auf Fabien Sangalards Website.
Schauen Sie sich unbedingt seine Bücher an, während Sie dort sind.

Nun zum lustigen Teil. Einen aktuellen Code schreiben. Bevor wir beginnen,
erstellen wir eine Sicherungsdiskette für den Code. Starten Sie WinUAE, gehen
Sie zu den Einstellungen des Diskettenlaufwerks und erstellen Sie eine
Sicherungsdiskette. Legen Sie dann diese Sicherungsdiskette in DF1: damit wir
später von Seka darauf zugreifen können.

Abbildung 03-2: WinUAE - Erstellen Sie eine Sicherungsdiskette

Das erste Codebeispiel heißt MC0101 und ich habe nur eine kleine Ahnung, was es
tut.

; file mc0101.s
	move.w    #$4000,$DFF09A
	move.w    #$03A0,$DFF096
loop:
	move.w    $DFF006,$DFF180
	btst      #6,$BFE001
	bne.s     loop
	move.w    #$83A0,$DFF096
	move.w    #$C000,$DFF09A
	rts

Es stellt sich heraus, dass das Programm ausgeführt wird, bis die linke
Maustaste gedrückt wird. Dann geht es weiter zu rts (Rückkehr vom
Unterprogramm), wodurch der 68k an der Rücksprungadresse weiterlesen kann.

Bevor wir in das Programm eintauchen, müssen wir es auf der Diskette speichern.
Dies erfolgt durch Eingabe von "w" in der seka-Befehlszeile.

SEKA>w
FILENAME>df1:mc0101
Geben Sie "r" ein, um das Programm zu lesen.

SEKA>r
FILENAME>df1:mc0101
Geben Sie "v" gefolgt vom Laufwerksnamen ein, um zu sehen, was sich auf der
Sicherungsdiskette befindet.

SEKA>vdf1:
Nachdem wir nun wissen, wie Programme gespeichert und geladen werden, können
wir uns ansehen, was der Assembler tut.

Die Aufgabe des Assemblers besteht darin, den Maschinencode in seine numerische
Darstellung im Speicher zu übersetzen. Eine solche Darstellung wird als
Objektcode bezeichnet.

Um das Programm auszuführen, rufen Sie die Seka-Befehlszeile auf

SEKA>a
OPTIONS>
No Errors
SEKA>j

Abbildung 03-2: Lauf von Seka

Der Bildschirm zeigt einige zyklische Farben und der Amiga friert ein.
Um vom Programm zurückzukehren, drücken Sie die linke Maustaste.

In der Seka- Dokumentation fehlt der Befehl, mit dem der Objektcode auf der
Diskette gespeichert wird.

SEKA>wo
MODE>f
FILENAME>mc0101

Dadurch wird der Objektcode als mc0101 auf der Diskette gespeichert. Der
Quellcode wird nicht überschrieben, da er wie in mc0101.s mit einem
angehängten "s" gespeichert wird.

Wir können diesen Code tatsächlich in der Amiga Workbench ausführen!

Abbildung 03-3: Führen Sie von Workbench aus

Und das ist es. Im nächsten Beitrag werden wir tiefer in das Programm 
eintauchen.

weblinks:
https://fabiensanglard.net/learning_legendary_hardware/index.php	; Schema Amiga
https://archive.org/details/Amiga_Machine_Language_1991_Abacus/page/n59/mode/2up	; Seka

cli-command: list

;------------------------------------------------------------------------------
04 - Amiga Machine Code Letter I - Deep Dive

Amiga Machine Code Buchstabe I - Deep Dive
4. Januar 2019  7 min lesen

Brief 1 erklärt das Programm nicht im Detail. Es ist nur als kleiner Test
gedacht, um zu sehen, ob Sie den Code zum Laufen bringen und erklären können,
was ein Assembler tut. Schauen wir uns das Programm genauer an.

Übrigens. Viele Details im Folgenden werden in den anderen Amiga-Maschinencode-
Briefen offenbart, daher ist es etwas früh, diesen Weg zu beschreiten.

Der Seka kann die Programmübersetzung in Objektcode zeilenweise anzeigen, indem
er die Option "v" erhält.

Abbildung 04-1: Maschinencode übersetzen

Beachten Sie, dass sich die Bezeichnung "loop" in der Symboltabelle mit dem
Wert 10 befindet. Dies bedeutet, dass die Schleife in Zeile 6 durch den Wert
aus der Symboltabelle im Objektcode ersetzt wird. Wenn sich der Test in Zeile 5
als falsch herausstellt, springt der bedingte Sprung (bne) in Zeile 6 zur
Adresse $1A, wenn 10 vom Programmzähler abgezogen wird. Dies entspricht
Zeile 5, und somit haben wir eine Schleife!

Die zeilenweise Ansicht gibt uns nicht die richtige Ansicht des Speichers.
Etwas fehlt. ZB zeigt Zeile 1 im obigen Bild die Hexadezimalzahl, die auf $DF
endet, aber der Quellcode endet auf $DFF09A. Wo ist das fehlende $F09A?

Um das vollständige Bild des Speichers zu sehen, können wir "h" drücken, um
einige Statistiken über unser Programm zu erhalten. Beachten Sie, dass der Code
an der Adresse $C2847C beginnt. Wir können dann "q" verwenden, um einen
Speicherauszug des Speichers ab der angegebenen Adresse zu erhalten.

Abbildung 04-2: Speicherauszug

Versuchen wir, die Übersetzung in 68k-Binärcode von Hand durchzuführen, damit
wir den obigen Hex-Dump überprüfen können. Es gibt eine sehr gute Erklärung
der 68k - Architektur und der Adressierungsmodi hier.

Und wir brauchen auch die 68k-Opcodes, dh die Maschinencodedarstellung in
Bytes. Es sieht etwas komplex und beängstigend aus!

Abbildung 04-3: Opcodes

Das Bild oben zeigt die Details aus der verknüpften PDF-Datei. Ich kann mir
vorstellen, dass der 68k-Befehlsdecoder eine gewisse Komplexität aufweist.

Werfen wir einen Blick auf das Programm aus dem ersten Brief. Hier
zusammen mit seiner hexadezimalen Darstellung, dh der Ausgabe des Assemblers.
Das "-" wird verwendet, um die Opcodes von den Operanden zu trennen.

; file mc0101.s
	move.w    #$4000,$DFF09A	; 33 FC - 40 00 - 00 DF F0 9A
	move.w    #$03A0,$DFF096	; 33 FC - 03 A0 - 0D FF 00 96
loop:
	move.w    $DFF006,$DFF180	; 33 F9 - 00 DF F0 06 - 00 DF F1 80
	btst      #6,$BFE001		; 08 39 - 00 06 - 00 BF E0 01
	bne.s     loop              ; 66 EC
	move.w    #$83A0,$DFF096	; 33 FC - 83 A0 - 00 DF F0 96
	move.w    #$C000,$DFF09A	; 33 FC - C0 00 - 00 DF F0 9A
	rts                         ; 4E 75

Das erste, was zu beachten ist, ist, dass jede Zeile des Assembler-Codes eine
binäre Darstellung variabler Länge hat. Wie der 68k-Befehlsdecoder mit der
variablen Länge umgeht, erfordert, dass wir einige der Befehle durchgehen.

Inspiriert vom Opcode-PDF habe ich eine Tabelle mit Adressierungsmodi erstellt

Abbildung 04-4: Adressierungsmodi und Betriebsgröße

Schauen wir uns die erste Zeile im Code genauer an:

	move.w    #$4000,$DFF09A   ; 33 FC - 40 00 - 00 DF F0 9A

Die ersten beiden Bytes sind der Opcode, gefolgt von zwei Operanden. Die
Operanden sind nicht gleich groß. Eines ist zwei Bytes und das andere ist
vier Bytes. Schauen wir uns den Opcode genauer an.

Abbildung 04-5:	opcode

Der Größenteil gibt an, dass ein Wort (zwei Bytes) verschoben wird. Aus den
Modus- und Registerfeldern sehen wir, dass die Quelle ein unmittelbarer Wert
ist und das Ziel eine absolut lange, dh eine Speicheradresse. Ein Long besteht
aus vier Bytes oder zwei Wörtern.

Der Opcode benötigt zwei Bytes für den move, der erste Operand benötigt
zwei Bytes und der zweite Operand benötigt vier Bytes. Das sind insgesamt acht
Bytes, genau das zeigt der Hex-Dump!

Fahren wir mit einer anderen move Anweisung fort, die keine
unmittelbaren Werte verwendet.

	move.w    $DFF006,$DFF180  ; 33 F9 - 00 DF F0 06 - 00 DF F1 80

Die ersten zwei Bytes sind der move-Befehl, gefolgt von zwei
Vier-Byte-Operanden.

Abbildung 04-7:	opcode

Der Größenteil zeigt, dass wir ein Wort kopieren. Die Felder mode und register
geben an, dass sowohl Quelle als auch Ziel absolut long sind. Wir kopieren
den unter der Adresse $DFF006 gespeicherten Wortwert in die Adresse bei
$DFF180.

Fahren wir mit dem Bittest fort

	btst      #6,$BFE001       ; 08 39 - 00 06 - 00 BF E0 01

Dieser ist interessant. Wenn Sie $BFE001 im Amiga Hardware Reference Manual
nachschlagen, heißt es, dass die linke Taste der Amiga-Maus mit CIAAPRA
($BFE001) verbunden ist. Die Taste für Port 1 ist mit Bit 6 verbunden. Unser
Bittest prüft, ob Bit 6 gesetzt ist, dh ob die linke Maustaste gedrückt wird.

Abbildung 04-8:	opcode Bittest
 
Der Bittest hat verschiedene Betriebsarten. Eine davon ist der obige, bei der
wir einen Wert in einer Adresse testen, um festzustellen, ob Bit 6 gesetzt ist.
Wenn wir eine Adresse testen, kann nur ein Byte (8 Bit) getestet werden. Ich
werde nicht auf Details über den anderen Modus eingehen - er muss in einem
späteren Beitrag erscheinen. Das Modus- und Registerfeld besagt, dass wir einen
Wert testen, der in einer absoluten Länge gespeichert ist, dh der angegebenen
Adresse.

Wir haben also wieder einen Zwei-Byte-Opcode, gefolgt von einem Zwei-Byte-Wert,
mit dem wir vergleichen, und enden dann mit einem Vier-Byte-Operand für die zu
testende Adresse. Genau das zeigt auch der Hex-Dump.

In unserer Konfiguration des Bittest-Opcodes wissen wir, dass wir nur mit einem
Byte testen können. Warum verwenden wir also zwei Bytes? Das gleiche Argument
gilt für den zweiten Operanden. Hier könnten wir nur drei Bytes verwenden,
haben aber vier Bytes zugewiesen.

Ich kenne die genaue Antwort noch nicht, aber ich denke, es hat etwas mit der
Wortzuweisung im Speicher zu tun. Beachten Sie auch, dass jede Assembler-Zeile
mit einer geraden Adresse beginnt. Mehr dazu in einem anderen Beitrag.

Gehen wir weiter zu dem Zweig, der nicht dem Opcode entspricht. Diese Anweisung
sagt uns, was zu tun ist, abhängig vom Ergebnis des vorherigen Bittests.

	move.w    $DFF006,$DFF180	; 33 F9 - 00 DF F0 06 - 00 DF F1 80
	btst      #6,$BFE001		; 08 39 - 00 06 - 00 BF E0 01
	bne.s     loop              ; 66 EC

Hier ist ein genauerer Blick auf den Opcode.

Abbildung 04-9:	opcode Zweig nicht gleich

Die acht höchstwertigen Bits zeigen, dass wir einen bne-Opcode haben, einen
Zweig ungleich, gefolgt von einer Abstand. Dieser Abstand erfolgt im
Zweierkomplement, wodurch negative Zahlen binär angezeigt werden können. Der
Wert $EC ist -20 als Dezimalzahl und weist den Programmzähler an, 20 Bytes
rückwärts zu gehen.

Stellen Sie sich vor, der Programmzähler steht kurz nach $66EC. Dann zähle
20 Wörter rückwärts und wir erreichen den Anfang von $33F9. Das ist die
Schleife! Wir beschäftigen den Amiga in dem wir prüfen, ob die linke Maustaste
gedrückt ist. Wenn die Maustaste nicht gedrückt wird, wird das Programm weiter
wiederholt.

Nach dem Drücken der Maustaste wird das Programm beendet. Der Programmzähler
läuft von der Absenderadresse aus weiter.

Voila! Wir haben jetzt ein besseres Verständnis dafür, was das Programm tut.
Ich schätze auch die Hilfe des Assemblers bei der Übersetzung des
Maschinencodes in den nicht trivialen Befehlssatz. Der Assembler leistet
hervorragende Arbeit, um den Programmierer gesund zu halten, insbesondere für
einen CISC-Mikroprozessor wie den 68k.

seka>a
Options>v

seka>h
seka>q $c2847c	; q-query (liefert Hex-Dump)

weblinks:
http://ocw.utm.my/pluginfile.php/1305/mod_resource/content/0/02-68k-Architecture.ppt.pdf	; 68k
http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf											; Op-Codes
https://archive.org/details/Amiga_Hardware_Reference_Manual_1985_Commodore_a/page/n233/mode/2up	; HRM

;------------------------------------------------------------------------------
05 - Amiga Machine Code Letter I - Debugger

Amiga Machine Code Letter I - Debugger
6. Januar 2019  3 min lesen

Bevor wir mit Brief 2 des Amiga-Maschinencode-Kurses fortfahren, möchte ich den
Debugger in WinUAE zeigen. Es ist ein echtes Juwel und erleichtert Ihnen das
Leben als Programmierer erheblich.

Früher hatte ich eine Action Replay-Karte, die fast das Gleiche wie der
WinUAE-Debugger konnte. Ich habe die Action Replay verwendet, um endlose
Zeilen von Hex-Dumps zu analysieren, damit ich in Spielen Leben oder Power-
Booster hinzufügen kann. Wer sagt, dass man aus Spielen nichts lernen kann?

Starten wir die Workbench und verwenden Sie den Debugger für das kleine
Testprogramm aus Brief 1 mit dem Namen mc0101. Hier ist der Maschinencode, der
zusammen mit den Hex-Werten im Speicher aufgelistet ist. Wie ich das gemacht
habe, wird hier beschrieben.

; file mc0101.s
	move.w    #$4000,$DFF09A	; 33 FC - 40 00 - 00 DF F0 9A
	move.w    #$03A0,$DFF096	; 33 FC - 03 A0 - 0D FF 00 96
loop:
	move.w    $DFF006,$DFF180	; 33 F9 - 00 DF F0 06 - 00 DF F1 80
	btst      #6,$BFE001		; 08 39 - 00 06 - 00 BF E0 01
	bne.s     loop              ; 66 EC
	move.w    #$83A0,$DFF096	; 33 FC - 83 A0 - 00 DF F0 96
	move.w    #$C000,$DFF09A	; 33 FC - C0 00 - 00 DF F0 9A
	rts                         ; 4E 75

Öffnen Sie in der Workbench die CLI (Command Line Interface).

Abbildung 05-1: Workbench-Startprogramm über CLI

Warten Sie, bevor Sie das Programm mc0101 starten. Wir müssen zuerst einen
Haltepunkt im Debugger setzen. Sie rufen den WinUAE-Debugger auf, indem Sie
Shift-F12 drücken.

Abbildung 05-2: Setzen Sie den Haltepunkt im Debugger

Die letzte Zeile im Debugger-Fenster dient zur Eingabe von Debugger-Befehlen.
Ich habe eine grüne Box um die Gegend gezeichnet. Es gibt eine Liste von
Debuggerkommandos hier. Geben Sie nun Folgendes ein:

fp "mc0101"
Der Debugger tritt nun hervor, bis der Prozess "mc0101" aktiv ist. Das heißt,
wir fahren fort, bis unser Programm mc0101 ausgeführt wird.

Gehen Sie zurück zur Workbench und schreiben Sie in die CLI mc0101. Wenn sich
ihre Sicherungsdiskette z.B. in df1 befindet, schreiben Sie df1:mc0101. Der
Amiga startet nun die Ausführung des Programms als Prozess mit dem Namen
"mc0101", wodurch der Haltepunkt im Debugger ausgelöst wird.

Der Debugger sieht nun folgendermaßen aus:

Abbildung 05-3: Ausgelöster Haltepunkt

In der oberen grünen Box sehen wir unser Programm sowohl in hexadezimaler Form
als auch in Assembler! Das untere grüne Feld zeigt die aktuelle und nächste
Position des Programmzählers an.

Beachten Sie, dass unser Loop-Label fehlt. Das Label wurde durch einen Versatz
ersetzt. Der Debugger ist sogar so freundlich, dass er die resultierende
Adresse des mit dem Offset hinzugefügten Programmzählers druckt.

0001DD9A  66ec           BNE.B  #$ec == $0001dd88 (T)

Dies bedeutet, dass das Programm auf $01dd88 springt, wenn der vorherige
Bittest nicht erfüllt wurde. Dies ist die Schleife, die das Warten ausführt, 
bis der Benutzer die linke Maustaste drückt.

Sie können das Programm mit "t" in der Debugger-Befehlszeile durchlaufen. Um
den Amiga wieder laufen zu lassen, geben Sie einfach "g" ein, ebenfalls in der
Debugger-Befehlszeile.

Die Verwendung des Debuggers zum Durchlaufen eines Programms ist eine
großartige Möglichkeit, den Amiga kennenzulernen. Im Debugger können wir alle
möglichen Dinge sehen, wie die Daten- und Adressregister, den Programmzähler
und die folgenden Schleifen im Programm.

weblinks:
http://amiga.resource.cx/exp/actionreplay
https://www.amigacoding.com/index.php/WinUAE_debugger

;------------------------------------------------------------------------------
06 - Amiga Machine Code Letter I - Hint

Amiga Machine Code Letter I - Hinweis
6. Januar 2019  5 min lesen

Hier ist ein wichtiger Hinweis, um die richtige emulierte Amiga-Grafik zu
erhalten.

Während ich mir den Youtube-Kanal von ScoopexU über Amiga-Programmierung
ansah, sah ich diesen sehr interessanten Text in der Videobeschreibung:

HINWEIS: Klicken Sie im Feld WinUAE auf den Link Erste Schritte mit WinUAE.
Verwenden Sie die Standard-Schnellstartkonfiguration und aktivieren Sie
Chipsatz - Cycle-Exact, damit sich der Emulator wie ein echter Amiga verhält.

Was ist zyklusgenau? Nun, es stellt sich heraus, dass Cycle-Exact Wunder
für das Programm mc0101 bewirkt! Lassen Sie uns den mc0101-Code mit seiner
Schleife erneut betrachten, die darauf wartet, dass die linke Maustaste 
gedrückt wird.

; file mc0101.s
	move.w    #$4000,$DFF09A
	move.w    #$03A0,$DFF096
loop:
	move.w    $DFF006,$DFF180	; Set background color to VHPOSR
	btst      #6,$BFE001		; Check left mouse button 
	bne.s     loop              ; If not pressed go to loop
	move.w    #$83A0,$DFF096
	move.w    #$C000,$DFF09A
	rts

Ohne zyklusgenau sehen wir nur diesen Bildschirm.

Abbildung 06-1: mc0101 Screenshot

Dies ist eher statisch und überhaupt nicht das, was Sie erwarten würden,
wenn Sie wissen, was das Programm tut. Besonders diese Zeile ist eine
Erklärung wert.

move.w    $DFF006,$DFF180		; Set background color to VHPOSR

Aus dem Amiga Hardware-Referenzhandbuch erhalten wir die folgenden
Informationen

DFF006  VHPOSR    Read vert and horiz position of beam
DFF180  COLOR00   Color table 0 (background color)

Der move-Befehl kopiert also tatsächlich die Position des VHPOSR-Strahls in
Color0, das die Hintergrundfarbe ist. Mit anderen Worten, wir sollten im
Hintergrund etwas dynamischeres sehen. Wenn Cycle-Exact aktiviert ist, sieht
das Programm mc0101 folgendermaßen aus:

Abbildung 06-2: mc0101 Animation

Dramatischer Unterschied - n'est-ce pas? Cycle-Exact ist in den Einstellungen
des WinUAE-Chipsatzes aktiviert.

Abbildung 06-3: zyklusgenaue Einstellung

Beachten Sie, dass das Programm mc0101 bei eingeschaltetem Zyklus genau 30% CPU
benötigt, verglichen mit 0-1% beim Ausschalten.

Auf der ScoopexUS-Homepage unter coppershade.org gibt es jede Menge
Amiga-Sachen. Wenn Sie beim Assemblen sind, dann besuchen Sie es.

Update 2019-01-13
Ein Freund von mir hatte eine interessante Frage.

Ein Amiga 500 hat eine Bildschirmauflösung von 640 x 512 und eine CPU mit
7,14 MHz. Das sind ungefähr 23 Zyklen pro Pixel. Wenn wir einen Befehl pro
Zyklus annehmen, haben wir 23 Befehle pro Pixel, was mehr als genug Zeit ist,
um die VHPOSR-Position in die Color0 zu kopieren. Warum sehen wir also ein 
Flackern?

Da ich gerade mit dieser Amiga-Reise anfange, konnte ich diese Frage nicht
beantworten, aber ich habe sie im englischen Amiga-Board veröffentlicht. Es ist
ein tolles Board und einen Besuch wert. Die Vorstandsmitglieder roondar und
Toni Wilen waren sich einig, dass dies etwas damit zu tun hat, dass die
Schleife nicht den DMA-Zyklusgrenzen zugeordnet ist. Beide Antworten sind
ein Zitat wert:

Roondar:
Ich habe eine Hypothese, warum sich Ihr Programm so verhält. Tatsächlich denke
ich, dass es auf einem echten Amiga (Interlaced oder nicht) dasselbe tun würde.
Die Schreibaktion, die Sie mit move.w $DFF006,$DFF180 ausführen wird in jedem
verfügbaren Zyklus ausgeführt. Und der Code, den Sie geschrieben haben, stimmt
wahrscheinlich nicht vollständig mit den DMA-Zyklusgrenzen überein. Dies kann
dazu führen, dass sich die Position der Farbänderung von Bild zu Bild
verschiebt.

Oder anders ausgedrückt: Das Timing des von Ihnen geschriebenen Codes ist
möglicherweise nicht gut genug für eine stabile Anzeige. Ohne cycle-exact
Modus an dieser Front ist möglicherweise einfach "entspannter" und
funktioniert somit so, wie Sie es möchten.

Wenn Sie ein stabiles Timing für Farbänderungen usw. wünschen, würde ich
empfehlen, sich mit dem Copper auseinanderzusetzen. Die Verwendung von Copper
garantiert die Rasterposition von Registeränderungen. Was mit der CPU viel
schwieriger zu erreichen ist.

Hinweis: Dies ist eine ungetestete Hypothese, ich kann mich irren.

Toni Wilen:
Ja, vom Code verwendete Zyklen sind keine Ganzzahl, die durch in einem Frame
verfügbare Zyklen teilbar ist. Es gibt auch einen CIA-Zugriff, der durch DMA
nicht verlangsamt wird und nicht mit DMA-Zyklen synchronisiert ist.

Nur der zyklusgenaue Modus emuliert DMA-Diebstahlzyklen von der CPU. Dies ist
normalerweise kein Problem, da fast alle Programme copper verwenden, das in
allen Modi genau ist.

Im nächsten Amiga-Maschinencode (Brief 2) werden wir uns mit dem Copper
befassen.

Überschrift: Einige Gedanken

Der Amiga-Maschinencode-Kurs bestand aus zwölf Briefen, einen jeden Monat. Ich
habe mich gefragt, warum es zwischen den Briefen so viele Probleme gibt, da ich
an einem Tag einen Brief durchkauen kann.

Wie Sie dem obigen Update entnehmen können, braucht das Wissen Zeit, um zu
gären. Manchmal ist es gut, einfach von der Piste zu gehen und sich die Zeit
zu nehmen, um zu experimentieren und zu untersuchen, was Sie gelernt haben,
damit es Wurzeln schlagen kann.

In der Woche, seit ich diesen Beitrag und jetzt dieses Update gepostet habe,
habe ich versucht, über das Copper in Brief zwei nachzudenken und mich mit dem
in diesem Beitrag beschriebenen Flackern zu beschäftigen. Und ich hatte das
Glück, einen Freund zu haben, der die richtige Frage stellen konnte.

Als ich sah, wie schnell einige sehr kompetente Mitglieder, die ich hinzufügen
könnte, Antworten auf meine Frage im englischen Amiga-Board hatten, war ich
beeindruckt.

Spiele, Programme und Bücher wurden digitalisiert, und echte Menschen stehen
bereit, um Fragen zu beantworten. Es ist, als ob der Amiga eine Plattform ist,
die nicht sterben wird.

weblinks:
https://www.youtube.com/watch?v=p83QUZ1-P10&list=PLc3ltHgmiidpK-s0eP5hTKJnjdTHz0_bW	; Scoopex
http://amiga-dev.wikidot.com/information:hardware
http://coppershade.org/
http://eab.abime.net/showthread.php?t=95854

;------------------------------------------------------------------------------
07 - Amiga Machine Code Letter II - Part 1

Amiga Machine Code Letter II - Teil 1
22. Januar 2019  6 min lesen

Wir haben den Brief II des Amiga-Maschinencode-Kurses erreicht. In diesem Brief
werden einige grundlegende, aber sehr wichtige Dinge vorgestellt - die
DMA-Kanäle und das Copper.

Ich werde diesen Brief ein wenig außer Betrieb setzen. Für mich ist es
logischer, mit der Einführung in die Assembler-Anweisungen move, add, sub und
lea zu beginnen.

Während des tiefen Tauchgangs von Brief I haben wir gesehen, wie der Opcode für
move aussah.

Abbildung 07-01: opcode

Die Zielbits bestimmen die Operationsgröße des move, dh welche Datengröße
kopiert werden soll. Wir können ein Byte, ein Wort (zwei Bytes) und ein langes
(vier Bytes) kopieren.

Abbildung 07-02: Betriebsgröße

Und für das Register und den Modus können wir aus dieser Liste von
Adressierungsmodi auswählen.

Abbildung 07-03: Adressierungsmodi

Wenn meine Kombinationen mich nicht enttäuschen, sind das 432 verschiedene
Opcodes nur für die move-Anweisung. Allerdings sind einige Kombinationen
illegal, zB können wir nicht einen unmittelbaren Wert auf einen unmittelbaren
Wert kopieren.

	move.w    #$4000, #$10   ; illegal operand

Es ist gut, dass wir den Assembler haben, der die Opcodes verfolgt. Das
Betrachten der Opcodes ist jedoch keine sinnlose Übung, da es einen Sinn für
die Konzepte auf der untersten Ebene des Amiga-Programmierstapels gibt.

Nehmen Sie zum Beispiel die obige Tabelle der Adressierungsmodi mit ihren
zwölf Adressierungsmodi. In Brief II werden zwei der Adressierungsmodi
vorgestellt: unmittelbare Adressierung und direkte Adressierung.

Überschrift: unmittelbare Adressierung

Bei der unmittelbaren Adressierung weist der move-Opcode die CPU an, den
Wert im ersten Operanden des Befehls an das im zweiten Operanden definierte
Ziel zu kopieren. Der unmittelbare Operand wird mit einem # angegeben und
ist immer der Quelloperand.

Hier ist ein Beispiel:

	move.w    #$FF,D0

Die Nummer $FF wird in das Register D0 kopiert. Diese Anweisung kann
vollständig innerhalb der CPU ausgeführt werden.

Abbildung 07-04: Adressierungs Beispiel: unmittelbare Adressierung

Ein anderes Beispiel:

	move.w    #$FF,$DFF006

Der Befehl kopiert den Wert in eine Adresse im Speicher. Dies erfordert, dass
die CPU den Wert in den Speicher schreibt, was über einen nur 16 Bit breiten
Datenbus erfolgen muss. In diesem Fall kopieren wir nur ein Wort , aber ein
Long würde zwei Schreibvorgänge erfordern. Dieser Vorgang ist etwas langsamer
als im vorherigen Beispiel.

Abbildung 07-05: Adressierungs Beispiel: unmittelbare Adressierung

Überschrift: Direkte Adressierung

Der Amiga Brief II führt das Konzept der direkten Adressierung ein. Der Modus
ist in der obigen Adressierungsmodustabelle nicht enthalten, was etwas
verwirrend ist.

Ich denke, dass direkte Adressierung die folgenden Adressmodi aus der Tabelle
bedeutet, wenn sie für den Quelloperanden verwendet wird.

Datenregister
Adressregister
Absolut kurz
Absolut lang

Eine gute Beschreibung der verschiedenen Adressierungsmodi finden Sie in
Kapitel 4 des Buches Amiga Assembly Language Programming (Seite 26).

Das erste Beispiel ist eine Variante, die ein Adressregister- Modus auf der
Quelleoperand des move-Befehls verwendet.

	move.w    D0,D5

Das obige Beispiel kopiert ein Wort von einem Register in ein anderes, ohne
aus dem Speicher zu lesen. Eine ziemlich schnelle Anweisung.

Abbildung 07-06: Adressierungs Beispiel: direkte Adressierung

Das zweite Beispiel verwendet den Absolut-Long- Adressierungsmodus für den
Quelloperanden des move-Befehls.

	move.w    $DFF006,D0

Der unter der Speicheradresse $DFF006 gespeicherte Wert wird abgerufen und in
das Datenregister D0 innerhalb der CPU kopiert. Beachten Sie, wie Daten über
den 16-Bit-Datenbus zwischen Speicher und CPU kopiert werden. Wenn wir uns
long bewegt hätten, hätte diese Operation zwei Abrufe aus dem Speicher
erfordert.

Abbildung 07-07: Adressierungs Beispiel: direkte Adressierung

Das dritte Beispiel verwendet auch den Absolut-Long- Modus für den
Zieloperanden der move-Anweisung.

Abbildung 07-08: Adressierungs Beispiel: direkte Adressierung

Der unter der Speicheradresse $DFF006 gespeicherte Wert wird abgerufen und dann
in die Speicheradresse $DFF180 geschrieben. Dieser Befehl erfordert, dass der
16-Bit-Datenbus zwischen Speicher und CPU zweimal gekreuzt wird, wodurch dieser
Befehl langsamer als im vorherigen Beispiel ist.

Überschrift: Add and Sub

Die nächsten Anweisungen sind add und sub. Wie der Name schon sagt, addieren
und subtrahieren sie Zahlen. Die Opcode-Konstruktion ist etwas komplex und ich
werde sie hier nicht durchgehen. Schauen Sie sich hier das 68k-Opcode-Blatt an.

Überschrift: Lea

Diese Anweisung steht für Load Effective Address (effektive Adresse laden) und
kann eine Adresse in ein Adressregister laden. Werfen wir einen Blick auf ein
nicht funktionierendes Programm, dessen Hex-Codes in den Kommentaren
hinzugefügt wurden. Die Hex-Codes können durch Zusammenstellen des Codes mit
der Option v angezeigt werden.

	lea.l  copperlist, a1	; 43 F9 - 00 00 00 08
	rts						; 4E 75

copperlist:
	dc.w   $2C01,$FFFE		; 2C 01 - FF FE

Aus der Opcode-Tabelle sehen wir, dass die lea- Anweisung folgendermaßen
aufgebaut ist:

Abbildung 07-09: lea opcode

Dies sagt uns, dass lea Adressberechnungen für jeden Modus in der Adresstabelle
oben durchführen kann - Adressen mit Nachinkrement und Vorinkrement sind 
ausgeschlossen (Quelle). Keine Sorge, der Assembler erkennt Fehler und weigert
sich, das Programm zu assemblieren.

Wir sehen auch, dass lea 32 Bit in ein Adressregister kopiert -
Datenregister können nicht verwendet werden. Amiga-Speicheradressen sind
24 Bit, daher wird das höchstwertige Bit des Adressregisters nicht verwendet.

Also, was macht Lea? In unserem obigen Programm wird die Adresse des Labels
verwendet und in das Adressregister a1 eingetragen. Beachten Sie, dass dem
Label ein Delta von der aktuellen Adresse hinzugefügt wird, nämlich $000008.

Der Wert $08 ist ein besitzunabhängiges Delta zur Adresse der copperliste. Da
das Programm zur Laufzeit an verschiedenen Speicherplätzen abgelegt werden
kann, addiert der Befehl lea auch den Programmzähler zum Delta-Wert, um die
genaue Speicheradresse zu erhalten.

Hier ist ein Hex-Auszug aus dem Seka-Assembler des Programms, wenn er im
Speicher abgelegt wird.

Abbildung 07-10: Lea Assembler

Ich habe die Adresse hervorgehoben, die lea in das a1-Register lädt. Die
Adresse lautet $02544C und nicht $000008, wie in der Codeliste angegeben. Dies
liegt daran, dass in der Codeliste der Delta-Wert angezeigt wird, bevor der
Wert des Programmzählers hinzugefügt wird.

Der Programmzähler befindet sich bei $025444 und wenn wir $000008 hinzufügen,
erhalten wir genau $02544C, wo die Copperliste im Speicher beginnt. Dies ist
die festgelegte Laufzeit, da wir vorher nicht genau wissen, wo das
Betriebssystem das Programm platzieren wird.

Einige zusätzliche Erklärungen zu lea finden Sie hier.

Überschrift: Wrap up

Dieser Beitrag war bereits lang genug und wir haben viel unternommen, aber wir
haben Brief II noch nicht abgeschlossen. Wir müssen uns noch mit dem sehr
wichtigen Konzept des direkten Speicherzugriffs (DMA) befassen, mit dem die
Hilfschips Paula, Agnus und Denise auf den Speicher zugreifen und ohne CPU
arbeiten können. Dies war eine wesentliche Hardware-Konstruktion, die den
Erfolg des Amigas ermöglichte.

weblinks:
https://computerarchive.org/files/computer/manufacturers/computers/Commodore/
books/amiga/Amiga_Assembly_Language_Programming.pdf
http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf
http://blog.thedigitalcatonline.com/blog/2018/05/28/exploring-the-amiga-1/ ; Serie über Adressierung

;------------------------------------------------------------------------------
08 - Amiga Machine Code Letter II - Part 2					
Amiga Machine Code Letter II - Teil 2
22. Januar 2019  6 min lesen

Wir fahren dort fort, wo wir im vorherigen Beitrag aufgehört haben. Brief II
finden Sie hier.

Überschrift: DMA-Kanäle

DMA steht für Direct Memory Access und die Kanäle ermöglichen es den
Coprozessoren Paula, Agnus und Denise, mit dem Speicher zu kommunizieren, ohne
die CPU einzubeziehen. Dieses Hardware-Design ist ein wesentliches Merkmal des
Amigas, der ihn zur Multimedia-Maschine der späten achtziger und frühen
neunziger Jahre machte.

Eine wichtige Einschränkung von DMA besteht darin, dass die Coprozessoren nur
auf Chip-RAM im Speicherbereich von $000000 bis $07FFFF (Amiga 500) zugreifen
können. Auf Hi-Mem kann daher nur die CPU zugreifen. Hi-Mem wird auch als
Fast-RAM bezeichnet, da die CPU den Zugriff auf diesen Speicherbereich nicht
mit den anderen Co-Prozessoren teilen muss.

Die CPU wird zum Einrichten und Starten der DMA-Kanäle benötigt, bevor die
Coprozessoren die Kommunikation über DMA starten können. In diesem Fall kann
die CPU andere Aufgaben ausführen. Das ist der Grund, warum beispielsweise das
Abspielen von Sound die CPU nicht belastet, da diese Arbeit vom Audio-Chip
namens Paula erledigt wird.

Die DMA-Kanäle des Amiga

Art		Anzahl der Kanäle
Diskette		1
Audio			4
Sprite			8
Bitebene		6
copper			1
Blitter			4

Das Lesen von Daten von einer Diskette kann in die folgenden Schritte
unterteilt werden.

 - Die CPU weist einen Puffer zu und startet den Diskettennmotor. 
 - Die CPU initialisiert die Disk-DMA. 
 - Paula verwendet seinen Diskettencontroller zum Lesen von Daten.
   Die CPU ist jetzt frei, andere Dinge zu tun.
 - Paula setzt einen Interrupt, wenn sie fertig ist. 
 
Der Amiga kann alle 24 DMA-Kanäle gleichzeitig nutzen, wodurch die CPU von viel
Arbeit entlastet wird.

Überschrift: DMA-Zeit-Slotzuweisung pro horizontaler Zeile

Der Zugriff auf Chip-Mem von der CPU und allen Coprozessoren wird vom
Agnus-Coprozessor gesteuert. Er teilt den Zugriff auf Chip-Mem anhand der
Position des Videostrahls zu. Für jede auf dem Monitor gezeichnete Zeile wird
eine bestimmte Anzahl von Zyklen für die verschiedenen DMA-Kanäle zugewiesen.

Die Agnus-Zugriffsrichtlinie für Chip-Mem ist etwas komplex und priorisiert
einige DMA-Kanäle gegenüber anderen. Brief II enthält eine Abbildung der
Funktionsweise der Zeitfensterzuweisung.

Abbildung 08-01: DMA-Zugang

Die einfache Regel ist, dass Agnus den Coprozessoren die ungeraden Taktzyklen
zuweist, während die geraden Zyklen der CPU zugewiesen werden. Dies bedeutet,
dass die Verwendung von DMA-Kanälen die CPU normalerweise nicht daran hindert,
auf Chip-Mem zuzugreifen. Es können jedoch spezielle Regeln angewendet werden,
bei denen einige DMA-Kanäle priorisiert werden und die CPU blockiert wird. Mehr
dazu in einem späteren Beitrag.

Laut Brief II stehen die geraden Taktzyklen nicht nur der CPU, sondern auch
dem Blitter und dem Copper zur Verfügung. Wenn der Audio-DMA nicht verwendet
wird, stehen die ungeraden Zyklen auch der CPU, dem Blitter und dem Copper zur
Verfügung. Aber auf diese Komplexität werde ich jetzt nicht eingehen.

Überschrift: Der Copper

Der Copper ist die Abkürzung für Co-Prozessor und gehört zu Agnus. Es ist eine
endliche Zustandsmaschine, die unter Verwendung eines Befehlsstroms
programmiert werden kann, der als Copperliste bezeichnet wird. Die Copperliste
enthält drei Anweisungen zum Kopieren, Warten und Überspringen.

Der Seka-Assembler unterstützt keine Mnemonik für Copperanweisungen, daher
müssen die Opcodes manuell in die Copperliste geschrieben werden. Werfen wir
einen Blick auf das Copperprogramm aus Brief II und erläutern es anschließend.

; file mc0201.s
start:
	move.w	#$01A0,$DFF096
	lea.l	copperlist, A1
	move.l	A1,$DFF080
	move.w	#$8080,$DFF096

wait:
	btst	#6,$BFE001
	bne	wait

	move.w	#$0080,$DFF096
	move.l	$04, A6
	move.l	156(A6), A1
	move.l	38(A1),$DFF080
	move.w	#$81A0,$DFF096
	rts

copperlist:
	dc.w	$9001,$FFFE		; wait for line 144
	dc.w	$0180,$0F00		; move red color to $DFF180
	dc.w	$A001,$FFFE		; wait for line 160
	dc.w	$0180,$0FFF		; move white color to $DFF180
	dc.w	$A401,$FFFE		; wait for line 164
	dc.w	$0180,$000F		; move blue color to $DFF180
	dc.w	$AA01,$FFFE		; wait for line 170
	dc.w	$0180,$0FFF		; move white color to $DFF180
	dc.w	$AE01,$FFFE		; wait for line 174 
	dc.w	$0180,$0F00		; move red color to $DFF180
	dc.w	$BE01,$FFFE		; wait for line 190
	dc.w	$0180,$0000		; move black color to $DFF180
	dc.w	$FFFF,$FFFE		; end of copper list

Das Programm initialisiert den Copper-DMA-Kanal und sendet die Copperliste an
den Copper. Es wartet darauf, dass der Benutzer die Maus drückt. Wenn die linke
Maustaste gedrückt wird, wird die Copperliste des Betriebssystems
wiederhergestellt und beendet. Es wird die folgende Ausgabe erzeugt.

Abbildung 08-02: Copperausgang

Der Copper ist eine Zustandsmaschine, die ihre Copperliste jedes Mal ausführt,
wenn der Bildschirm neu gezeichnet wird. Es merkt sich den Status der
vorherigen Bildschirmzeichnung, weshalb das Setzen des Hintergrunds auf
Schwarz am Ende der Copperliste oben auf dem Bildschirm gespeichert wird.

Wir können dies überprüfen, indem wir die Zeile entfernen, die die Farbe in
der Copperliste auf schwarz setzt. Die schwarzen Bereiche sollten rot werden.

Die Registeradresse $DFF180 heißt COLOR00 und legt den Wert der Farbtabelle 0
fest, bei der es sich um die Hintergrundfarbe handelt.

Überschrift: Copper move

Die move-Anweisung besteht aus zwei Anweisungswörtern. Es kopiert Daten aus dem
Speicher zu einem Registerziel.

Abbildung 08-03: Copper move

Das Registerziel wird als Offset zu $​​DFF000 angegeben. Dies ist der Adressraum
für benutzerdefinierten Chipregister. Eine Erklärung dazu finden Sie auch auf
coppershade.org.

Überschrift: Copper wait

Die Warteanweisung besteht ebenfalls aus zwei Anweisungswörtern. Das erste
Befehlswort weist den Copper an, zu warten, bis der angegebene
Videostrahlzähler erreicht oder größer ist. Das zweite Befehlswort gibt eine
Maske an, die dem Copper mitteilt, welche Bits des Strahlzählers beim Vergleich
verwendet werden sollen.

Wenn der Copper wartet, wird der Datenbus nicht verwendet, wodurch
Speicherzyklen für die CPU oder den Blitter frei werden.

Abbildung 08-04: Copper wait

In der obigen Abbildung warten wir auf Zeile 150 und vergleichen nur mit allen
Bits für den vertikalen (und horizontalen) Strahlzähler, wie in der Maske
angegeben.

Im obigen Programm verwenden wir Copper Waits, bei denen nur die vertikale
Strahlposition angegeben wird, und eine Maske, die besagt, dass alle Bits im
Vergleich verwendet werden sollen.

Brief II befasst sich nicht mit der Verwendung von Masken, und es gibt viele
Dinge, die nicht erklärt werden, wie z.B. das BFD-Bit im zweiten Befehlswort
des Wartebefehls.

Der Brief schließt mit der Bemerkung, dass wir nur die Oberfläche angekratzt
haben, was der Copper kann. Um mehr zu verstehen, müssen wir warten, bis die
nächsten Briefe eingehen.

Hier ist ein optionaler Umweg vom Kurs, der sich mit Reverse Engineering
befasst.

Fühlen Sie sich frei ihn zu überspringen. Es ist nicht erforderlich, zum
Lesen der nächsten Briefe.

weblinks:
https://www.amigacoding.com/index.php/Amiga_memory_map
http://palbo.dk/dataskolen/maskinsprog/
http://amiga-dev.wikidot.com/information:hardware
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node004A.html
http://coppershade.org/articles/Code/Reference/Custom_Chip_Register_List/
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node004B.html

;------------------------------------------------------------------------------
09 - Amiga Machine Code Detour - Reverse Engineering			

Amiga Machine Code Detour - Reverse Engineering
28. Dezember 2020  12 min lesen

Die Geschichte hat immer wieder gezeigt, dass ein Reverse Engineering von
Programmen erforderlich ist. Die Gründe sind vielfältig, manche unschuldig
und manche nicht. In jedem Fall ist es eine interessante Fähigkeit, die Sie zu
einem besseren Programmierer macht. Die Werkzeuge mögen einfach sein, aber die
erforderlichen Kenntnisse sind etwas anspruchsvoller.

Mittlerweile kennen wir genug Maschinencode, um einen Abstecher in das Land des
Reverse Engineering zu machen. Diese Reise wird zeigen, wie schockierend
einfach es ist, das Verhalten eines Programms mit relativ einfachen Werkzeugen
zu ändern. Ich nenne diesen Beitrag einen Umweg, da der Amiga Machine Code
Kurs dieses Thema nicht behandelt.

Lassen Sie mich das klarstellen: Reverse Enginering ist meistens eine lange und
langwierige Herausforderung, und es ist schwierig, von einem binären zu einem
100%-igen Endergebnis zu gelangen.

Da die gesamte Software schließlich zu maschinenlesbarem Code wird, können wir
uns ein Bild davon machen, was ein Programm tut, indem wir uns die binären
Hex-Werte ansehen und die entsprechenden Opcodes finden. Wir könnten das
manuell machen, aber das wird schnell super langweilig. Viel besser für unsere
Gesundheit ist es, einen Disassembler zu verwenden, ein Tool, das die binären
Opcodes in Assembly-Code umwandelt.

Es ist keine Überraschung, dass Disassembler die Zielhardwarearchitektur sehr
gut kennen, und die besseren kennen sogar die benutzerdefinierten Chipflags
und Bibliotheksversätze.

Überschrift: Die Werkzeuge

In diesem Beitrag werden wir den Capstone-Disassembler verwenden, der relativ
neu ist. Er ist interessant, weil es viele Plattformen unterstützt, aber auch,
weil er die enorme Dynamik der LLVM-Compiler-Infrastruktur nutzt. Es verwendet
TableGen aus diesem Projekt, um die Definitionen einer Vielzahl von
Plattformarchitekturen abzurufen. Dies ist wirklich eine geheime Quelle, da die
ständige Aktualisierung der Hardwarearchitekturen ein Alptraum für die Wartung
ist.

Ein weiteres Tool ist nur ein einfacher Hex-Editor. Einer, der die Werte in die
ausführbare Binärdatei einfügen und löschen kann. Dies ist auch ein als
Patching bezeichneter Prozess.

Überschrift: Die Mission

Wir werden das Programm mc0201 zurückentwickeln, das den Copper verwendet, um
die norwegischen Farben auf dem Bildschirm zu zeichnen. Das Programm ist sehr
einfach und kurz, daher ist es ideal für diesen Beitrag.

Das Programm mc0201 wird hier ausführlich erläutert: Amiga Machine Code
Letter II - Teil 2
Laden Sie zuerst die ausführbare Binärdatei auf Ihre Amiga-Diskette herunter
und führen Sie es aus, oder kompilieren Sie das Programm aus dem Quellcode und
führen Sie es dann aus. Sie sollten die Farben der norwegischen Flagge sehen:

Abbildung 09-01: mc0201_norway

Unsere Mission ist es, dieses Programm so zu ändern, dass es die russische
Flagge anzeigt, indem wir die ausführbare Datei patchen.

Schauen wir uns die ausführbare Datei mit xxd oder einem Hex-Editor an.

>xxd -g 1 mc0201
00000000: 00 00 03 f3 00 00 00 00 00 00 00 02 00 00 00 00  ................
00000010: 00 00 00 01 40 00 00 21 00 00 00 01 00 00 03 e9  ....@..!........
00000020: 00 00 00 21 33 fc 01 a0 00 df f0 96 43 f9 00 00  ...!3.......C...
00000030: 00 4c 23 c9 00 df f0 80 33 fc 80 80 00 df f0 96  .L#.....3.......
00000040: 08 39 00 06 00 bf e0 01 66 00 ff f6 33 fc 00 80  .9......f...3...
00000050: 00 df f0 96 2c 79 00 00 00 04 22 6e 00 9c 23 e9  ....,y...."n..#.
00000060: 00 26 00 df f0 80 33 fc 81 a0 00 df f0 96 4e 75  .&....3.......Nu
00000070: 90 01 ff fe 01 80 0f 00 a0 01 ff fe 01 80 0f ff  ................
00000080: a4 01 ff fe 01 80 00 0f aa 01 ff fe 01 80 0f ff  ................
00000090: ae 01 ff fe 01 80 0f 00 be 01 ff fe 01 80 00 00  ................
000000a0: ff ff ff fe 00 00 00 00 00 00 03 ec 00 00 00 01  ................
000000b0: 00 00 00 00 00 00 00 0a 00 00 00 00 00 00 03 f2  ................
000000c0: 00 00 03 eb 00 00 00 01 00 00 03 f2              ............

Wir könnten sofort mit dem Patchen der ausführbaren Datei beginnen, aber wo
sollen die Änderungen vorgenommen werden? Hier bietet sich der Disassembler an.

Ein naiver Ansatz besteht darin, den Capstone-Disassembler die Hex-Werte
durchkauen zu lassen, aber das funktioniert nicht, da ein executable mehr als
nur Programmcode ist.

Überschrift: Die Amiga-Binärdateistruktur

Unser Exectuable wird in einem Binärformat gespeichert, sodass es von einem
ausführbaren Loader verwendet werden kann. Die Aufgabe des Loaders besteht
darin, das Programm in den Speicher zu stellen, damit es direkt von der CPU
ausgeführt werden kann.

Es gibt eine Reihe von ausführbaren Dateiformaten für eine Vielzahl von
Betriebssystemen. Windows hat PE und Unix hat ELF, um nur einige zu nennen,
und der Amiga hat das Hunk-Format.

Um zu verstehen, was im Programm vor sich geht, müssen wir die Datei nicht als
einzelnen Datenblock betrachten, sondern als eine aus Fragmenten
zusammengesetzte Datei. Und dazu müssen wir etwas über das Hunk-Format wissen.
Eine frühe Version davon ist im AmigaDOS Technical Reference Manual
dokumentiert.

Abbildung 09-02: Codeblöcke

Überschrift: Der Hunk-Header-Block

Der mc0201 beginnt mit einem Hunk-Header-Block. Es enthält Informationen
darüber, welche Bibliotheken geladen werden sollen, wie viele Hunks vorhanden
sind und wie groß sie sind. Dies ermöglicht es dem Loader, den für das
Programm benötigten Speicher vorab zuzuweisen.

Abbildung 09-03: Hunk-Header

Der Hunk-Header beginnt immer mit dem Langwort $3F3 und es ist eine Art
magisches Cookie, das dem AmigaOS mitteilt, dass diese Datei eine ausführbare
Datei ist.

Die Datei wird mit einem Langwort von Null fortgesetzt, das dem Loader
mitteilt, dass das Programm nicht auf externe Bibliotheken angewiesen ist.

Der Loader wird dann angewiesen, eine Tabelle mit Platz für zwei Hunks
zuzuweisen, gefolgt vom ersten Hunk, Hunk 0, und dem letzten Hunk, Hunk 1.

Die Datei wird mit den Größe aller Hunks fortgesetzt. Hunk 0 erfordert $21
Longwords, und da Bit 30 gesetzt ist, muss der Loader Chip Mem zuweisen oder
fehlschlagen. Dies teilt dem Reverse Engineer mit, dass das Programm
wahrscheinlich auf DMA-Operationen der benutzerdefinierten Chips beruht.

Überschrift: Der Hunk-Codeblock

Dieser Block enthält den Programmcode. Außerdem wird angegeben, wie viel Code
vorhanden ist, und der Code selbst, der mit Nullen bis zur nächsten
Langwortgrenze aufgefüllt werden muss.

Abbildung 09-04: Hunk-Code

Unsere Datei teilt dem Loader mit, dass die Größe des Codes Langwörter,
gefolgt vom Code selbst ist. Dieser Code wird eventuell von der CPU und
den benutzerdefinierten Chips ausgeführt.

Überschrift: Der Hunk Relocation Block

Dieser Block gibt an, welche Teile des Codes verschoben werden müssen. Der
Loader entscheidet, wo das Programm geladen werden soll. Da der Code beliebig
im Speicher gespeichert werden kann, müssen alle Referenzen im Code verschoben
werden, damit sie auf die richtigen Speicherorte verweisen. Der Loader
verwendet den Verschiebungsblock, um zu bestimmen, welche Bytes verschoben
werden sollen.

Der Block enthält eine Liste von Offsets für jeden Hunk, die mit einem
0-Langwort beendet wird.

Abbildung 09-05: Hunk relock32

Unsere Binärdatei enthält einen Offset für Hunk 0, der sich am Offset $A 
Bytes im Code befindet.

Überschrift: Der Hunk BSS-Block

Dieser Block gibt eine Speichermenge an, die vom Loader zur Laufzeit zugewiesen
werden soll, anstatt die ausführbare Datei aufzublähen.

Abbildung 09-06: Hunk BSS

Die Binärdatei gibt an, dass der Loader 1 Langwort Speicher zuweisen soll.

Überschrift: Der Hunk-End-Block

Dieser Block markiert das Ende des Blocks.

Abbildung 09-07: Hunk Ende

Die Binärdatei enthält zwei Hunks, daher befinden sich zwei davon in der Datei.

Jetzt kennen wir die verschiedenen Fragmente in der Binärdatei und haben den
Code gefunden. Machen wir weiter mit dem disassemblieren! 🚀

Überschrift: Code disassemblieren

Zuerst müssen wir den Codeteil von mc0201 in eine eigene Datei kopieren.

>dd bs=4 skip=9 count=33 if=mc0201 of=mc0201_code
Stellen Sie dann sicher, dass der gesamte Code vorhanden ist

>xxd -p mc0201_code
33fc01a000dff09643f90000004c23c900dff08033fc808000dff0960839
000600bfe0016600fff633fc008000dff0962c7900000004226e009c23e9
002600dff08033fc81a000dff0964e759001fffe01800f00a001fffe0180
0fffa401fffe0180000faa01fffe01800fffae01fffe01800f00be01fffe
01800000fffffffe00000000

Der Code sieht gut aus. Lassen wir ihn Capstone zuführen. Aber wir müssen
die neuen Zeilenzeichen entfernen, da Capstones cstool daran erstickt.

>xxd -p mc0201_code | tr -d '\n' | xargs -I{} cstool m68k {}
 0  33 fc 01 a0 00 df f0 96  move.w	#$1a0,$dff096.l
 8  43 f9 00 00 00 4c        lea.l	$4c.l, a1
 e  23 c9 00 df f0 80        move.l	a1,$dff080.l
14  33 fc 80 80 00 df f0 96  move.w	#$8080,$dff096.l
1c  08 39 00 06 00 bf e0 01  btst.b	#$6,$bfe001.l
24  66 00 ff f6              bne.w	$1c
28  33 fc 00 80 00 df f0 96  move.w	#$80,$dff096.l
30  2c 79 00 00 00 04        movea.l	$4.l, a6
36  22 6e 00 9c              movea.l	$9c(a6), a1
3a  23 e9 00 26 00 df f0 80  move.l	$26(a1),$dff080.l
42  33 fc 81 a0 00 df f0 96  move.w	#$81a0,$dff096.l
4a  4e 75                    rts	
4c  90 01                    sub.b	d1, d0
4e  ff fe                    dc.w	$fffe
50  01 80                    bclr.b	d0, d0
52  0f 00                    btst.l	d7, d0
54  a0 01                    dc.w	$a001
56  ff fe                    dc.w	$fffe
58  01 80                    bclr.b	d0, d0

Ok, das ist nicht ganz fehlerfrei, aber es ist ziemlich nah. Wenn Sie die
Opcodes überprüfen möchten, verwenden Sie das 68K-Opcode-Blatt.

Am Versatz $8 gibt es ein lea $4c das in a1 gesetzt wird. In der nächsten Zeile
wird der Wert in das benutzerdefinierte Chipregister $dff080 (COP1LCH/ COP1LCL) 
kopiert, das einen Zeiger auf die Copperliste enthält. Dies bedeutet, dass
wir eine Copperliste haben, die mit dem Versatz $4c beginnt.

Übrigens. Aus dem Hunk-Relocation-Block haben wir gesehen, dass der Offset
$a verschoben werden muss. Dies ist die effektive Adresse, die lea in a1
setzen sollte. Da der Loader das Programm an einer beliebigen Stelle im
Chip-Mem platzieren kann, muss diese effektive Adresse kopiert werden.

Capstone ist etwas ahnungslos, wenn es um die Copperliste geht, daher hat
es eine große Auswahl an Opcodes gefunden, die alle falsch sind. Es schlägt
auch stillschweigend fehl, sodass ein wenig Eingabe fehlt.

Korrigieren wir die Copperliste von Hand und fügen einige Kommentare hinzu.

copperlist:
4c  90 01 ff fe		; wait for vpos >= $90 and hpos >= $0
50  01 80 0f 00		; COLOR00 = red
54  a0 01 ff fe		; wait for vpos >= $a0 and hpos >= $0
58  01 80 0f ff		; COLOR00 = white
5c  a4 01 ff fe		; wait for vpos >= $a4 and hpos >= $0
60  01 80 00 0f		; COLOR00 = blue
64  aa 01 ff fe		; wait for vpos >= $aa and hpos >= $0
68  01 80 0f ff		; COLOR00 = white 
6c  ae 01 ff fe		; wait for vpos >= $ae and hpos >= $0
70  01 80 0f 00		; COLOR00 = red
74  be 01 ff fe		; wait for vpos >= $be and hpos >= $0
78  01 80 00 00		; COLOR00 = black
7c  ff ff ff fe		; wait for vpos >= $ff and hpos >= $fe (end of copper)
80  00 00 00 00		; zero padding - not part of copper

Jetzt wissen wir, dass das Programm die Flagge mithilfe einer Copperliste malt,
und wir wissen sogar, bei welchen Offsets es dies tut. Wir können jetzt
fortfahren, die ausführbare Datei zu patchen, damit sie die russische Flagge
erzeugt!

Überschrift: Patchen der ausführbaren Datei

Erstellen Sie eine Kopie des Programms mc0201 und bearbeiten Sie es mit einem
Hex-Editor. Ich habe nur drei Änderungen an der ausführbaren Datei vorgenommen.

Am Versatz $76 geändert $0f00 (rot) bis $0fff (weiß)
Am Versatz $7e geändert $0fff (weiß) bis $000f (blau)
Am Versatz $8e geändert $0fff (weiß) bis $000f (blau)

Beachten Sie, dass die hier angegebenen Offsets vom Anfang der Datei stammen,
während die im disassemblierten Code angegebenen Offsets vom Anfang des
Codefragments stammen.

Hier ist ein Unterschied zwischen der ursprünglichen und der gepatchten
Version der ausführbaren Datei.

diff <(xxd mc0201) <(xxd mc0201_patched)
8,9c8,9
< 00000070: 9001 fffe 0180 0f00 a001 fffe 0180 0fff  ................
< 00000080: a401 fffe 0180 000f aa01 fffe 0180 0fff  ................
---
> 00000070: 9001 fffe 0180 0fff a001 fffe 0180 000f  ................
> 00000080: a401 fffe 0180 000f aa01 fffe 0180 000f  ................

Führen Sie nun das gepatchte Programm aus. Die Mission ist erfüllt, wenn die
russische Flagge angezeigt wird. Hier ist ein Screenshot

Abbildung 09-08: mc0201 Russland

Nun, das war schockierend einfach - es waren nur drei einfache Änderungen an
der Binärdatei erforderlich, die mit jedem Hex-Editor durchgeführt werden
können!

Überschrift: Abschließende Gedanken

Es ist sinnvoll, Retro-Tech zu studieren, da viele Konzepte, die zuerst auf
älteren Plattformen implementiert wurden, den Test der Zeit bestehen und in
heutigen Systemen in verfeinerter Form zu finden sind.

Beliebte Betriebssysteme werden auch durch die Sicherheitsauswirkungen von
binären Patches herausgefordert. Beispielsweise verfügt das PE-Format
(Windows Portable Executable) über Regionen für Authenticode, die vom Loader
verwendet werden, um den Code und nicht die ausführbare Datei auf Änderungen
zu überprüfen. Aber es kann laut einem Blog-Beitrag auch gespielt werden, die
einen unpraktischen Angriff beschreiben.

Es ist einfach, binäre Patches durchzuführen. Es erfordert nichts weiter als
einen Hex-Editor. Der schwierige Teil besteht darin, über das System
nachzudenken und die richtigen Werkzeuge für die binäre Analyse zu finden.
Tatsächlich weist die Copperliste in unserer Binärdatei ein erkennbares
Bitmuster auf, sodass das Zerlegen insgesamt übersprungen werden kann.

Es wäre noch schwieriger, Binärdateien zurückzuentwickeln, wenn der Code in
einer höheren Sprache geschrieben worden wäre. In diesem Fall wäre der
Assembler-Code die Ausgabe eines Compilers, der den Code auf diesem Weg auch
hätte optimieren können. So wie wir Disassembler haben, gibt es auch
Dekompilierer für genau diesen Job.

Wir können es jetzt einen Gewinn nennen. Wir haben unser Ziel erreicht, das
Programm so zu patchen, dass die russische Flagge angezeigt wird. Für
diejenigen, die wirklich interessiert sind, ist es tatsächlich möglich, ein
paar Bytes von der ausführbaren Datei zu entfernen, was Sie selbst ausprobieren
können.

Die ausführbare Datei enthält einen hunk_bss-Block, der den Loader anweist,
1 Langwort Speicher zuzuweisen. Dieser Speicher wird von unserem Code nicht
referenziert, da er im Block für die Neuzuordnung von Hunks nicht vorhanden
ist.

Entfernen Sie den Block hunk_bss wie folgt:

- Bearbeiten Sie den Block hunk_header so, dass nur der erste Block erhalten
  bleibt.
- Entfernen Sie den Block hunk_bss.
Führen Sie die ausführbare Datei aus, um sicherzustellen, dass sie
funktioniert. Die Datei sollte von 204 Byte auf 188 Byte verkleinert werden.

Viel Spaß beim Patchen

weblinks:
http://www.capstone-engine.org/
https://llvm.org/
https://llvm.org/docs/TableGen/index.html
https://www.markwrobel.dk/post/amiga-machine-code-detour-reverse-engineering/mc0201
https://en.wikipedia.org/wiki/Comparison_of_executable_file_formats
https://archive.org/details/AmigaDOS_Manual_The_2nd_Edition_1987_Bantam_Books/page/n263/mode/2up
https://github.com/aquynh/capstone/tree/master/cstool
http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf
http://amiga-dev.wikidot.com/hardware:cop1lch
https://en.wikipedia.org/wiki/Portable_Executable
https://blog.reversinglabs.com/blog/breaking-the-windows-authenticode-security-model

;------------------------------------------------------------------------------
10 - Amiga Machine Code Letter III - Copper Revisted

Amiga Machine Code Letter III - Copper überarbeitet
23. Januar 2019  5 min lesen

Durch das Schreiben der Brief II-Beiträge hatte ich das Gefühl, dass viele
Details unbeantwortet geblieben waren. Mit gemischten Gefühlen begann ich,
Brief III zu lesen.

Der Brief erwies sich als eine gute Lektüre und beantwortete viele der Fragen,
die ich aus dem vorherigen Brief hatte. Wohlgemerkt, dieser Brief III ist lang
und deckt viel Boden ab. Also fangen wir besser an.

Boolesche Arithmetik und Wahrheitstabellen werden eingeführt, und ich werde
hier nicht darauf eingehen, da dies wirklich grundlegende Dinge sind. Es gibt
jedoch zwei Konzepte, die einfach und dennoch sehr wichtig für das Setzen und
Löschen von Bitfeldern sind. Wir werden es oft tun, wenn wir uns mit den
benutzerdefinierten Amiga- Chip-Registern befassen.

Unset the 4th bit
Register value:   %0110 1011
AND to unset:     %1111 0111
                  ----------
Result:           %0110 0011
                  ==========

Set the 4th bit
Register value:   %0110 0011
OR to set:        %0000 1000
                  ----------
Result:           %0110 1011
                  ==========

Überschrift: Copperanweisungen überarbeitet

Brief III geht ausführlicher auf die Copper-Anweisungen move und wait ein. 
Die Anweisung zum Überspringen (skip) wird übersprungen, da sie nicht so
häufig verwendet wird. Das Amiga-Hardware-Handbuch enthält eine Tabelle mit
Anweisungen, die auch im Brief wiederholt wird.

Abbildung 10-01: Copperanweisungen

Beachten Sie, wie Bit 0 in beiden Befehlswörtern (IR1, IR2) verwendet wird, um
den Befehl move, wait und skip zu identifizieren. Ich habe dies mit dem grünen
Kästchen hervorgehoben.

Der move-Befehl wird dadurch identifiziert, dass Bit 0 in IR1 0 ist,  was
bedeutet, dass wir nur zu einer geraden Zieladresse kopieren können.
Glücklicherweise ist dies in Ordnung, da die benutzerdefinierten Chipregister
16 Bit oder ein Wort breit sind. Ein Wort besteht aus zwei Bytes, was bedeutet,
dass auf alle Register über gerade Adressen zugegriffen wird. Puh...

Wir stoßen jedoch auf eine Einschränkung hinsichtlich der Warteanweisung. Wir
können nur warten, bis der horizontale Strahlzähler eine ungerade Zahl
erreicht. (Anmerkung: ungerade, weil Bit 0 von IR1 '1' sein muss. Das ist 
bedingt dadurch, dass Bit 0 von IR '1' den Befehl move oder wait/skip
identifiziert. Daraus ergibt sich auch nur eine 2-Pixelgenauigkeit) Die
vertikalen und horizontalen Masken sind ebenfalls begrenzt, da sie jeweils nur
durch 7 Bits dargestellt werden.

Es gibt eine Mnemonik für die Anweisungen zum wait und skip, die es einfacher
macht, sich daran zu erinnern, was sie tun. Ersetzen Sie einfach wait mit
"Warten, bis" und überspringen (skip) mit "skip after".

Überschrift: Copper und die Chipregister

Die benutzerdefinierten Chipregister sind keine Register in der CPU, wie die
Adress- und Datenregister. Dies sind Register außerhalb der CPU, auf die über
Speicheradressen von $DFF000 bis $DFF200 zugegriffen wird.

Der Copper move - Befehl hat ein Ziel - Feld, das nicht 24 Bit breit als
Adressen ist, sondern nur 8 Bit breit. Trotzdem kann move in alle Chipregister
schreiben, da das Eingabeziel als Offset für $DFF000 angegeben wird.

(Anmerkung:
Es gibt ein spezielles Register COPCON mit Bit zum Schreiben in Blitterregister
von $040 bis $07F). Dadurch kann der Copper dann auch den Blitter benutzen. Ein
Zugriff auf die untersten Register ($000 bis $03F) ist allerdings immer
verboten.)

Einige der Register können beschrieben werden, während andere nur gelesen
werden können. Wenn sowohl Lesen als auch Schreiben benötigt werden, kann dies
unter Verwendung von zwei Registern erfolgen.

Ein Beispiel für ein solches Doppelregister ist die DMA-Steuerung. Das
Schreiben in DMACON erfolgt über $DFF096, und das Lesen erfolgt über DMACONR
bei $DFF002.

Der DMACON verwendet Bit 15, um anzuzeigen, ob die DMA-Kanäle gesetzt oder 
zurückgesetzt sind. Wenn wir die Bitebenen- und Sprite-DMAs löschen (oder
ausschalten) möchten, müssen wir die Bits 5 und 8 löschen. Denken Sie daran,
mit dem Zählen von 0 zu beginnen.

	move.w    %0000 0001 0010 0000,$DFF096
	move.w    $0120,$DFF096  ; same as above just using hex

Um die Bitplane- und Sprite-DMAs zu aktivieren, wiederholen Sie einfach die
obigen Schritte mit einer 1 bei Bit 15.

	move.w    %1000 0001 0010 0000,$DFF096
	move.w    $8120,$DFF096  ; same as above just using hex

Wie einfach ist das! 

Lassen Sie uns eine Codeliste aus Brief II mit einigen weiteren Kommentaren
erneut betrachten.

; file mc0201.s
start:
	move.w	#$01A0,$DFF096	; disable sprite, copper, and bitplane DMA's 
	lea.l	copperlist,A1	; put the address of the copperlist into a1
	move.l	A1,$DFF080		; move data in a1 into the copper first location register
	move.w	#$8080,$DFF096	; enable copper DMA

wait:
	btst	#6,$BFE001      ; busy wait until left mouse is pressed
	bne	wait

	move.w	#$0080,$DFF096	; disable the copper DMA
	move.l	$04,A6          ; ? ... Something with bringing back the workbench
	move.l	156(A6), A1     ; ? ... 
	move.l	38(A1),$DFF080	; ? ... 
	move.w	#$81A0,$DFF096	; enable sprite, copper and bitplane DMA's
	rts                     ; return from subroutine, go back to the call site

copperlist:
	dc.w	$9001,$FFFE		; wait for line 144
	dc.w	$0180,$0F00		; move red color to $DFF180
	dc.w	$A001,$FFFE		; wait for line 160
	dc.w	$0180,$0FFF		; move white color to $DFF180
	dc.w	$A401,$FFFE		; wait for line 164
	dc.w	$0180,$000F		; move blue color to $DFF180
	dc.w	$AA01,$FFFE		; wait for line 170
	dc.w	$0180,$0FFF		; move white color to $DFF180
	dc.w	$AE01,$FFFE		; wait for line 174 
	dc.w	$0180,$0F00		; move red color to $DFF180
	dc.w	$BE01,$FFFE		; wait for line 190
	dc.w	$0180,$0000		; move black color to $DFF180
	dc.w	$FFFF,$FFFE		; end of copper list

Beachten Sie, dass wir ein move.l verwenden, um eine Long-Wert nach $DFF080 zu
kopieren. Dies sollte nicht möglich sein, da die Chipregister nur ein Wort
breit sind. Was jedoch passiert, ist, dass sowohl $DFF080 als auch $DFF082
geschrieben werden. Diese werden auch als COP1LCH und COP1LCL bezeichnet. Um
einen Zeiger auf eine Speicheradresse (die Copperliste) zu speichern, die
24 Bit breit ist, müssen zwei Register verwendet werden.

Der Brief endet mit einem kleinen Teaser-Programm über Bitplanes. Ich nenne es
einen Teaser, weil es nur oberflächlich erklärt wird. Es scheint, als wäre es
nur hinzugefügt worden, um den Leuten etwas zum Codieren zu geben, während die
ausführliche Erklärung an einen späteren Brief delegiert wurde.

Okay, wir werden hier vorerst aufhören. Im nächsten Beitrag geht es um die
Verzweigung

weblinks:
http://amiga-dev.wikidot.com/information:hardware
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node005F.html
http://amiga-dev.wikidot.com/hardware:dmaconr
http://amiga-dev.wikidot.com/hardware:cop1lch

;------------------------------------------------------------------------------
11 - Amiga Machine Code Letter III - Branching

Amiga Machine Code Letter III - Verzweigung
24. Januar 2019  7 min lesen

In diesem Beitrag werden wir uns mit der Verzweigung befassen, wie sie in
Brief III erläutert wird.

Im einfachsten Fall ist die Verzweigung eine bedingte Sprunganweisung. Die
Amiga-Hardware bietet Opcodes für mehrere bedingte Sprünge an. Aber zuerst
müssen wir uns das 68K-Statusregister ansehen.

In Brief III wird erwähnt, dass wir das Statusregister nicht direkt lesen
werden. Vielmehr wird es indirekt von den Verzweigungsanweisungen verwendet.

Abbildung 11-01: Statusregister

Ich habe die Bedingungscodes C, V, Z, N und X auf das Bild gelegt.

In Brief III werden einige der Verzweigungscodes vorgestellt, die im Handbuch
The 68000's Instruction Set als Anweisung Bcc zu finden sind, was für
Branch on condition code steht.

Hier sind einige der Verzweigungsanweisungen. Die dritte Spalte zeigt, welche
Statusregister-Flags gesetzt sind, wenn die CC-Bedingung erfüllt ist.

Abbildung 11-02: Bedingungscodes

Wenn wir beispielsweise den BNE-Befehl verwenden, wird der Sprung nur
ausgeführt, wenn das Zero-Flag im Statusregister nicht auf 1 gesetzt ist.

Ich werde mir nicht die Mühe machen, die Opcodes anzuzeigen, sondern mich nur
auf die hervorragenden Seiten der 68K-Opcodes beziehen.

Wir werden später zur Verzweigung zurückkehren. Zuerst müssen wir uns die
CMP-Anweisung ansehen, die auch im 68K-Handbuch zu finden ist. Es subtrahiert
den Quelloperanden vom Zieloperanden und setzt die Bedingungscodes
N, Z, V und Z entsprechend.

Hier ist ein kleines Programm, das CMP verwendet.

; file mc0304.s
first:
	move.l  #2,d0		; put 2 into d0
	cmp.l   #0,d0		; does 0 compare with the value in d0?
	cmp.l   #2,d0		; does 2 compare with the value in d0?
	cmp.l   #4,d0		; does 4 compare with the value in d0?
	rts					; return from subroutine

Assemblieren Sie das Programm und schreiben Sie es mit dem Befehl "wo" in
Seka auf die Diskette. Beenden Sie dann Seka mit "!" und gehe in die CLI.
Drücken Sie Shift + F12, um den WinUAE-Debugger aufzurufen und schreiben sie

fp "mc0304"				; = fp "mc0301cmp" (umbenannt hier)

Dies löst einen Haltepunkt aus, wenn der Prozess ausgeführt wird. Zurück in der
CLI geben Sie "mc0301cmp" ein. Der Debugger wird ausgelöst und Sie können das
Programm mit "t" durchlaufen. Wenn Sie fertig sind, verwenden Sie "g", um die
Ausführung fortzusetzen.

Behalten Sie die Bedingungscodes im grünen Feld im Auge.

Abbildung 11-03: cmp im Debugger

Hier sind die Bedingungscodes für die drei Aufrufe von cmp, wenn d0 2 enthält.

	cmp.l #0,d0			; X:0, N: 0, Z: 0, V: 0, C: 0
	cmp.l #2,d0			; X:0, N: 0, Z: 1, V: 0, C: 0
	cmp.l #4,d0			; X:0, N: 1, Z: 0, V: 0, C: 1

Wenn wir die Zahl 2 von der Zahl in d0 subtrahieren, die ebenfalls 2 ist,
erhalten wir Null, und genau das sagen die Bedingungsflags in der zweiten
Zeile.

Überschrift: Adressierungsmodi

In Brief III werden zwei neue Adressierungsmodi eingeführt: Adresse und Adresse
mit Nachinkrementierung.

Abbildung 11-04: Adressmodi

Diese Adressierungsmodi dienen als Zeiger. Es bedeutet "die im Adressregister
gespeicherte Adresse verwenden". Ich werde nicht auf Details eingehen, weil der
Brief dies sehr gut erklärt.

Abbildung 11-04: Adressierung - Adresse indirekt 

Wenn eine Nachinkrementierung verwendet wird, wird nach dem Lesen des Werts
der Inhalt des Adressregisters erhöht. Nach dem Inkrementieren wird auch die
Breite der Daten berücksichtigt, die verschoben werden. Wenn also ein Byte 
verschoben wird, wird der Zeigerwert um 1 erhöht, und wenn es sich um ein
Wort oder eine Long handelt, wird es um 2 bzw. um 4 erhöht.

Überschrift: Block und deklarieren

Die nächsten Anweisungen sind blk und dc. Keiner von diesen hat äquivalente
68K-Opcodes und es sind keine Maschinencode-Befehle. Es sind jedoch
Anweisungen (Direktiven) für den Seka-Assembler.

Der DC kann Bytes, Wörter und Longs deklarieren, die Werte fest in den Speicher
codieren. Wir verwenden diese Anweisung beim Schreiben von Copperlisten.

Der Befehl blk weist einen Speicherblock zu und kann ihn auch auf einen
bestimmten Wert initialisieren. Schauen Sie sich Brief III an, in dem dies
sehr gut erklärt wird.

Überschrift: Alles zusammenbinden

Brief III verwendet das folgende Programm, um die neuen Adressierungsmodi und
Verzweigungstechniken zu demonstrieren. Die erste Version des Programms
funktioniert, verwendet jedoch nicht die neuen Techniken.

; file mc0305.s
first:
	move.l	#16,d0			; use d0 as a counter
	move.l	#$00,a0			; let a0 point to a source address
	lea.l	buffer,a1		; allocate a destination buffer
loop:
	move.b	(a0),d1			; copy the source into d1
	add.l	#1,a0			; increment source address
	move.b	d1,(a1)			; move data from source into destination bufffer
	add.l	#1,a1			; increment destination address
	sub.l	#1,d0			; subtract one from the counter
	cmp.l	#0,d0			; have the counter reached zero?
	bne	loop				; if not continue to loop.
	rts

buffer:
	blk.b	16,0			; allocate 16 bytes and intialize them to zero

Das Programm kopiert einfach 16 Byte Speicher ab der Adresse $000000 in einen
Puffer gleicher Länge.

In dem Brief wird erwähnt, dass die folgende Zeile überflüssig ist.

	cmp.l	#0,d0			; have the counter reached zero?

Der "Trick" ist, dass wir, wenn wir eins vom Zähler abziehen, schließlich Null
erreichen. In diesem Fall wird der Bedingungscode Z im Statusregister auf 1
gesetzt. Dieses Null-Flag ist genau das, was bne überprüft, wie wir oben in
diesem Beitrag gesehen haben. Daher müssen wir den Vergleich nicht durchführen.

Hier ist das überarbeitete und kompaktere Programm.

; file mc0306.s
first:
	move.l	#16,d0
	move.l	#$00,a0
	lea.l	buffer,a1
loop:
	move.b	(a0)+,(a1)+
	sub.l	#1,d0
	bne	loop
	rts

buffer:
	blk.b	16,0

Ich werde nicht darauf eingehen, wie diese Transformation stattgefunden hat, da
alles in dem Brief erklärt wird. Eines ist jedoch sicher, diese 68K-Opcodes
sind sicherlich sehr gut zusammengestellt. Ich mag das!

Überschrift: Die DBRA-Anweisung

Das Dekrementieren eines Schleifenzählers ist ein so wesentlicher Bestandteil
einer Schleife, dass sie über einen eigenen Satz von Maschinencode-Anweisungen
verfügt, die als DBcc bezeichnet werden.

Diese Befehlsfamilie kombiniert die üblichen Dekrementzähler-, Test- und
Verzweigungsbefehle eines Schleifenkonstrukts zu einem Maschinencodebefehl. Der
DBcc-Opcode befindet sich auch im 68K-Opcode-Blatt.

Der Befehl besteht aus einem Opcode und zwei Operanden. Der zu dekrementierende
Schleifenzähler und die Bezeichnung, zu der gesprungen werden soll, wenn der
Schleifenzähler nicht -1 ist.

Es gibt 14 Verzweigungsbedingungen, die von DBcc unterstützt werden. Wir werden
eine Variante namens DBRA (Dekrementieren und Verzweigen zurück) verwenden, der
DBF ähnelt.

Mithilfe des 68K-Opcode-Blattes können wir DBF finden, indem wir zuerst DBcc
suchen und dann die Konditionstabelle verwenden, um F zu finden. Dies bedeutet,
dass wir die Schleife fortsetzen sollten, solange die Bedingung falsch ist. Die
Bedingung ist, dass der Zähler gleich -1 sein sollte.

Verwenden wir DBRA im obigen Code und stellen fest, dass der Zähler von 16 auf
15 reduziert wird, da wir jetzt auf -1 herunterzählen.

; file mc0307.s
first:
	move.l	#15,d0
	move.l	#$00,a0			; could also written as: clr.l a0
	lea.l	buffer,a1
loop:
	move.b	(a0)+,(a1)+
	dbra	d0,loop
	rts

buffer:
	blk.b	16,0

Der Code kann durch Lesen der Anweisung clr.l zum Löschen von a0 etwas lesbarer
gemacht werden.

Am Ende von Brief III gibt es ein kleines Programm, das Bitebenen demonstriert,
und am Anfang von Brief IV gibt es ein Programm, das Verzweigungen
demonstriert. Ich bin der Meinung, dass diese Programme in umgekehrter
Reihenfolge hätten gegeben werden sollen.

Hier ist das Programm aus Brief IV .

; file mc0401.s
start:                
	clr.l    d0
	move.l   #$04,d1
	lea.l    table,a0

loop01:
	add.w    (a0)+,d0
	dbra     d1,loop01

	lea.l    result,a0
	move.l   d0,(a0)
	rts

result:
	blk.l    1,0

table:
	dc.w     2,4,6,8,10

Das Programm summiert die Zahlen in der Tabelle und speichert es im Ergebnis.
Es ist eine nette Verwendung von Labeln, die gut mit dem Seka-Assembler
zusammenarbeiten.

Assemblieren Sie das Programm mit "a" und verwenden Sie die Option "vh",
um das Scrollen in der Ausgabe anzuhalten. Verwenden Sie die Leertaste, um
fortzufahren. Das Programm kann mit "jstart" gestartet und das Ergebnis
mit "qresult" angezeigt werden.

Wir haben q schon einmal verwendet, um den Hex-Dump von einer bestimmten
Adresse zu sehen. Es funktioniert auch mit Labeln, da es sich nur um 
Adressen handelt.

Im nächsten Brief werden weitere Details zu Bitebenen beschrieben.

weblinks:
http://www.eeeguide.com/register-architecture-of-68000-microprocessor/
http://wpage.unina.it/rcanonic/didattica/ce1/docs/68000.pdf
http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf

;------------------------------------------------------------------------------
12 - Amiga Machine Code Letter IV

Amiga Machine Code Letter IV
2. Februar 2019  5 min lesen

Wir haben den Brief IV des Amiga Machine Code-Kurses erreicht.

Dieser Brief war der bisher härteste und ich denke, dass er auf meine
Besessenheit mit Details zurückzuführen ist. Die Autoren schreiben wiederholt,
dass wir die Details beschönigen müssen, da eine Erklärung in späteren Briefen
gegeben wird.

Übrigens. Diese Kritzeleien sind meine eigenen Notizen. Erwarten Sie also
nicht, dass ich erklären werde, was bereits in den Briefen erklärt wurde. Aber
hoffentlich werde ich etwas Licht auf einige der trüberen Sachen werfen.

Der Kern dieses Beitrags besteht darin, wie Grafiken auf dem Bildschirm
angezeigt werden. Dazu müssen wir uns Farbregister, Bitebenen und die
Anzeigeauflösung ansehen.

Überschrift: Farbregister

Der Amiga verfügt über 32 Farbregister, die die Farben Rot, Grün und Blau mit
jeweils 4 Bit darstellen.

Abbildung 12-01: Farbregister

Dadurch kann der Amiga (16*16*16) = 4.096 Farben anzeigen. Die Pixel auf dem
Bildschirm repräsentieren einen Indexwert in den Farbregistern. Wie viele
Farbregister adressierbar sind, hängt von der Anzahl der Bitebenen ab.

Die Farbregister finden Sie im Register für benutzerdefinierte Chips unter
$DFF180 - $DFF1BE, wo sie den Namen COLOR00 - COLOR31 tragen.

Überschrift: Bitebenen

Eine Bitebene ist ein fortgesetzter Speicherbereich in Chip-Mem, in dem jedes
Pixel durch ein einzelnes Bit dargestellt wird.

Die Verwendung einer Bitebene gibt uns zwei Indexwerte in das Farbregister oder
zwei Farben. Das Hinzufügen weiterer Bitebenen erhöht die Anzahl der
Farbregister, die wir adressieren können. Die Verwendung von 4 Bitebenen
ermöglicht beispielsweise die Adressierung von 16 Farbregistern.

Wir können bis zu 5 Bitebenen in einer Anzeige verwenden, wodurch wir alle
32 Farbregister adressieren können.

Der Index in das Farbregister wird unter Verwendung der Bitebene 0 als
niedrigstwertiges Bit und der Bitebene 5 als höchstwertiges Bit bestimmt.

(Anmerkung: Es gibt noch den EHB und HAM, bzw. Dual Playfield Mode bei denen
bis zu 6 Bitebenen verwendet werden.) 

Das Einrichten der Bitebenen erfolgt über die Bitebenensteuerregister
BPLCON0 , BPLCON1 , BPLCON2 und BPLCON3 .

Anzeigedaten werden in das Grafiksubsystem geladen, indem BPLxPTH / BLPxPTL
verwendet wird, um einen Zeiger auf den Start der Bitebene in Chip-Mem zu
geben. Wir müssen zwei Zeiger auf den oberen und unteren Teil der
Speicheradresse verwenden, da die benutzerdefinierten Chipregister 16 Bit und
eine Speicheradresse 24 Bit sind.

Überschrift: Bildschirmauflösung

Der Amiga kann mehrere Bildschirmauflösungen verarbeiten. Hier für PAL gezeigt.

Art				Auflösung	Bitebenen	Farben
LORES			320 * 256	1 - 6		2 - 64
HIGHRES			640 * 256	1 - 4		2 - 16
LORES-LACE		320 * 512	1 - 6		2 - 64
HIGHRES-LACE	640 * 512	1 - 4		2 - 16
HAM				320 * 256	6			4096
HAME-LACE		640 * 512	6			4096

Die Anzeigeauflösung wird mithilfe der obigen Bitplane-Steuerregister
eingestellt. HAM - Hold and Modify ist übrigens etwas Besonderes. Hier gibt es
ein gutes Video des Konzepts.

Abbildung 12-02: Video

Überschrift: Größe und Position des Anzeigefensters

Der Amiga verwendet die beiden Steuerregister DIWSTRT und DIWSTOP, um die obere
linke Ecke und die untere rechte Ecke des Anzeigefensters einzustellen.

Die Start- und Stoppwerte werden in Lowres-koordinaten angegeben, auch
wenn Sie einen Highres-modus wählen.

Bei der Herstellung von Monitoren und Fernsehgeräten wurde ein delibrierter
Overscan erstellt, um sicherzustellen, dass das Bild den Bildschirm ausfüllte.
Dieser Overscan kann vom Amiga verwendet werden, ich denke für Zwecke wie das
Scrollen.

Für den PAL-Modus stehen 312 Zeilen zur Verfügung, und wir müssen das
Anzeigefenster so einrichten, dass 256 dieser Zeilen verwendet werden. Wenn
Sie mehr Linien auswählen, landen einige davon im nicht sichtbaren Overscan-
Bereich.

DIWSTRT			Vertikale Position
Art				Von			Zu			Standard	Overscan
LORES / HIGHRES	$15 (21)	$FF (255)	$2C (44)	$1C (28)

DIWSTRT Horizontale Position
Art				Standard				Overscan
LORES			$81 (129)				$71 (113)
HIGHRES			$80 (128)				$70 (112)

Das Einrichten von DIWSTOP ist etwas schwieriger, da die untere rechte Ecke
Werte aufweist, die größer sind als die Werte, die in ein Byte passen. Für PAL
sind also einige Hardware-Tricks erforderlich. Dies wird in Brief IV sehr gut
erklärt.

Überschrift: DIWSTOP Vertikale Position

Für PAL benötigen wir 256 Zeilen, was $2C + $100 = $12C ergibt, was nicht in
ein Byte passt. Es wird also ein Hardware-Trick benötigt. Für NTSC gibt es
kein Problem, da es 200 Zeilen hat, sodass $2C + $C8 = $F4 in ein Byte passen.

Der PAL - Trick ist, die folgenden zwei Zeilen zu schreiben, sie müssen
aufeinander folgen.

	move.w  #$f4c1,$dff090
	move.w  #$38c1,$dff090  ; $F4 + $38 = $12C

(Anmerkung:
Hier gibt es keinen "PAL-Trick". Die Hardware wertet Bit 7 von DIWSTOP aus.
Bit V8 (vertikale Position) wird in Abhängigkeit von Bit V7 gesetzt.
bei Endpositionen von 256 bis 312 setzt man V7 auf 0 und damit V8 auf 1
bei Endpositionen von 128 bis 255 setzt man V7 auf 1 und damit V8 auf 0)

Überschrift: DIWSTOP Horizontale Position

Sowohl für den PAL- als auch für den NTSC-Modus werden 320 Pixel (LORES) auf
dem Bildschirm angezeigt. Da die horizontale Position $81 + $140 = $1C1 zu groß
ist, um in ein Byte zu passen, wird ein anderer Hardware-Trick verwendet. Die
Hardware addiert einfach $100 zur horizontalen Eingabe, und daher können wir
einen beliebigen Wert von $100 bis $1FF festlegen, indem wir nur ein Byte
verwenden.

(Anmerkung:
Da das fehlende Bit8 der horizontalen Position als 1 angesehen wird, sind wir
nur in der Lage die horizontale Endposition in den Bereich von 256 und 511 zu
legen. DIWSTOP  - H0 bis H7 von $0 bis $FF ist $100 bis $1FF)

Überschrift: Timing ist alles

Bisher haben wir nur gesehen, wie Farben, Bitebenen, Anzeigeauflösung und
Anzeigefenster eingerichtet werden. Wir müssen noch überlegen, wie die
Anzeigedaten an das Grafiksubsystem übertragen werden.

Die Übertragung von Grafikdaten erfordert ein genau abgestimmtes Timing
zwischen den benutzerdefinierten Chips und dem 68K unter Verwendung des
gemeinsam genutzten Speichers. Dies wird auch als DMA-Zeitfensterzuweisung
bezeichnet, auf die wir in Brief II kurz eingegangen sind und die wir im
nächsten Beitrag noch einmal wiederholen werden.

weblinks:
http://amiga-dev.wikidot.com/information:hardware
http://amiga-dev.wikidot.com/hardware:bplcon0
http://amiga-dev.wikidot.com/hardware:bplcon1
http://amiga-dev.wikidot.com/hardware:bplcon2
http://amiga-dev.wikidot.com/hardware:bplcon3
http://amiga-dev.wikidot.com/hardware:bplxpth
http://amiga-dev.wikidot.com/hardware:diwstrt
http://amigadev.elowar.com/read/ADCD_2.1/Libraries_Manual_guide/node0314.html

;------------------------------------------------------------------------------
13 - Amiga Machine Code Letter IV - DMA Revisted

Amiga Machine Code Letter IV - DMA überarbeitet
10. Februar 2019  6 min lesen

Wir haben den Brief IV des Amiga Machine Code-Kurses erreicht.

Die CPU des Amiga war der Motorola 68K. Die werksseitige Geschwindigkeitsstufe
betrug 8 MHz. Bei Verwendung im Amiga wurde sie jedoch bei der Ausgabe von
PAL-Video auf ungerade 7,09379 MHz getaktet. Warum war das?

Videosignale für das Fernsehen in Europa unterscheiden sich von Nordamerika.
Europa und viele andere Länder verwenden das PAL-System, während Nordamerika
das NTSC-System verwendet.

Der Amiga wurde so gebaut, dass die CPU mit dem Videosystem synchronisiert war.
Solche Computer werden als "Farbcomputer" bezeichnet, von denen der Amiga einer
der letzten und erfolgreichsten war. Es gibt eine große Beschreibung hier.

Zitat aus dem Link:

Warum arbeiteten diese Farbcomputer nicht einfach asynchron und ließen die CPU
mit maximaler Spezifikation laufen, während das Videosystem mit Farbtakt
betrieben wurde? Da der Speicher in jenen Tagen sehr knapp war, verwendeten sie
Videos mit Speicherzuordnung. Dies wurde im einfachstmöglichen Schema dual
portiert, wobei Speichertakte mit dem Videosystem synchronisiert werden
mussten.

Das speicherabgebildete Video im Amiga wird als Chip-RAM bezeichnet und mit der
CPU und den custom chips einschließlich des Videosystems geteilt. Das ist auch
der Grund, warum alle Copperlisten in Chip-RAM sein müssen. Dies macht den
Amiga zu einer synchronisierten Multiprozessor-Architektur.

Aufgrund der zeitlichen Unterschiede zwischen PAL und NTSC verfügt die
Amiga 500-Hardware über einen Quarzoszillator, der auf den Videomodus
abgestimmt ist.

Das Bild unten zeigt den Quarzoszillator auf dem Amiga 500-Motherboard. Für PAL
wird es auf 28.37516 MHz eingestellt, und so wissen Sie, dass Ihre Hardware
PAL unterstützt.

Abbildung 13-01: Amiga 500 PAL Oszillator

Beachten Sie, dass 28.37516 MHz geteilt durch 4 genau 7.09379 MHz ist - die
Taktfrequenz des Amiga 500 Motorola 68K für PAL. Dies hält die CPU und das
Videosystem synchron.

Überschrift: Interleaved-Zugriff

Der Amiga ist eine synchronisierte Multiprozessor-Architektur, bei der sich
alle Chips den Chip-RAM teilen. Wenn alle Chips mit dem Chip-RAM
kommunizieren würden, ohne synchronisiert zu sein, würde dies zu Buskonflikten
führen. Das Äquivalent dazu, wenn mehrere Personen gleichzeitig sprechen.

Der Amiga vermeidet Buskonflikte, indem er alle Teile des Systems mit einer
gemeinsamen Uhr synchronisiert. Dies löst jedoch nur einen Teil des Problems.
Was wäre, wenn der 68K gleichzeitig mit einigen benutzerdefinierten Chips
Speicher abrufen wollte? Das würde zu Buskonflikten führen und um diesen
zu lösen, verwendet der Amiga einen verschachtelten Zugriff auf den Speicher.

Die geraden Taktzyklen sind für den 68K verfügbar, während die ungeraden
Taktzyklen für die verschiedenen benutzerdefinierten Chips gelten. Dies ist
jedoch nur eine Faustregel, es gelten Abweichungen.

Agnus enthält den DMA-Controller, der für die Zeitschlitzzuweisung für den
Speicherzugriff auf den Chip-RAM verantwortlich ist. Es werden mehrere Register
als Eingabe verwendet und anhand dieser Register wird bestimmt, wie die
Zeitschlitze zugewiesen werden.

Hier ist ein Diagramm der Zeitfenster mit meinen Korrekturen aufgedruckt.

Abbildung 13-02: DMA-Timing

Das Diagramm zeigt die Zeitschlitzzuordnung für die Bitebenen 1 bis 6. Wenn wir
nur 4 Bitebenen haben, kann der 68K bei allen geraden Taktzyklen aus dem
Speicher abrufen. Wenn wir jedoch die Bitebene 5 und 6 aktivieren, stehlen die
Bitebene Zyklen der CPU. Für den Highresmodus mit 4 Bitebenen sind während des
Datenabrufs keine Zyklen für die CPU verfügbar.

Vielleicht etwas zu einfach, kann dies so formuliert werden: Je mehr Bitebenen,
desto langsamer der Prozessor.

Die Datenabrufperiode wird durch die Datenabrufregister DDFSTRT und DDFSTOP
bestimmt.

Diese Datenabrufregister werden indirekt durch die Anzeigefensterregister
DIWSTRT und DIWSTOP bestimmt.

In Brief IV sind folgende Regeln angegeben:

LORES:

DDFSTART: (HSTART / 2) - 8,5
		auf $0 oder $8 abrunden.

DFFSTOP: (( Breite in Pixel / 16) - 1) * 8 + DDFSTRT
		auf $0 oder $8 aufrunden.

HIRES:

DDFSTART: (HSTART / 2) - 4
		auf $4 oder $C abrunden.

DFFSTOP: (( Breite in Pixel / 16) - 2) * 4 + DDFSTRT
		auf $4 oder $C aufrunden.

HSTART ist der horizontale Wert von DIWSTRT. Die fest codierten Werte 8.5 und 4
für DDFSTART sind darauf zurückzuführen, dass die Videohardware einige Zyklen
benötigt, um die abgerufenen DMA-Daten zu verarbeiten.

Das Buch Mapping the Amiga auf Seite 510 enthält einige leicht unterschiedliche
Formeln.

Die Bitebenen sind fortlaufende Speicherarrays, die sich im Chip-RAM befinden,
so dass das Videosystem darauf zugreifen kann. Der Inhalt der Bitebenen wird
durch die Bitebenen-Datenregister BPLxDAT definiert.

Beachten Sie, dass im DMA-Zeitschlitzdiagramm die Bitebene 1 immer die letzte
ist, die abgerufen wird. In der Dokumentation heißt es, dass das Abrufen der
Bitebene 1 eine parallele zur seriellen Konvertierung auslöst, die den
Abschluss aller Bitebenen für dieses Wort der Bildschirmdaten markiert.

Dies erklärt auch, warum das Diagramm besagt, dass Daten, die für $38 abgerufen
wurden, erst für $45 verfügbar sind. Da der Abruf erst abgeschlossen wird,
wenn die Bitebene 1 abgerufen wird, müssen wir dem Videosystem etwas Zeit
geben, um die Daten zu "verdauen".

Abbildung 13-03: DMA-Timing-Zoom

Schauen wir uns einen Code an
Ab Brief III haben wir den folgenden Code, der eine Art Aufwärmübung für alle
neuen Erkenntnisse in Brief IV darstellt.

; file mc0301.s - Letter III initial bitplane program
start:
	move.w	#$01a0,$dff096	; DMACON, disable bitplane, copper, sprite

	move.w  #$1200,$dff100  ; BPLCON0, enable 1 bitplane, enable color
	move.w  #0,$dff102		; BPLCON1 (Scroll)
	move.w  #0,$dff104		; BPLCON2 (Sprites, dual playfields)
	move.w  #0,$dff108		; BPL1MOD (odd planes)
	move.w  #0,$dff10a		; BPL2MOD (even planes)

	move.w  #$2c81,$dff08e	; DIWSTRT
	;move.w  #$f4c1,$dff090  ; DIWSTOP (enable PAL trick)
	move.w  #$38c1,$dff090  ; DIWSTOP (PAL trick)
	move.w  #$0038,$dff092  ; DDFSTRT
	move.w  #$00d0,$dff094  ; DDFSTOP

	lea.l   copper,a1
	move.l  a1,$dff080      ; COP1LCH pointet to the copper list

	move.w  #$8180,$dff096  ; DMACON  enable bitplane, enable copper
wait:
	btst    #6,$bfe001		; wait for left mouse click
	bne     wait

	move.w  #$0080,$dff096	; restablish DMA's and copper

	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080

	move.w  #$80a0,$dff096

	rts

copper:
	dc.w    $2c01,$fffe		; wait for line $2c
	dc.w    $0100,$1200		; move to $DFF100 BPLCON0, use 1 bitplane, enable color

	dc.w    $00e0,$0000		; move to BPL1PTH, bitplane pointer high
	dc.w    $00e2,$0000		; move to BPL1PTL, bitplane pointer low

	dc.w    $0180,$0000		; move to COLOR00, black
	dc.w    $0182,$0ff0		; move to COLOR01, yellow

	dc.w    $ffdf,$fffe		; wait - enables waits > $ff vertical
	dc.w    $2c01,$fffe		; wait for line - $2c is $12c

	dc.w    $0100,$0200		; move to $DFF100 BPLCON0, disbale bitplanes, enable color
							; needed to support older PAL chips.

	dc.w    $ffff,$fffe		; end of copper

Der Brief erklärt den Code, daher werde ich nicht mehr Kommentare abgeben als
im Code. Der Kern dieses Codes besteht jedoch darin, ein Lowres-Bild mit einer
Bitebene zu zeichnen, die in eine Farbtabelle mit zwei Farben abgebildet wird -
Schwarz und Gelb.

Der Code weist der Bitebene keinen Speicherplatz zu, sondern zeigt den Zeiger
der Bitebene 1 auf $000000. Am Ende sehen wir also ein Bild des Speichers im
Adressraum von $000000 bis $002800, vorausgesetzt der Bildschirm ist 320 x 256.

Versuchen Sie, das Programm auszuführen, und bewegen Sie die Maus. Sie sollten
einige Änderungen in den gelben Punkten sehen, in denen die Maus dem Speicher
zugeordnet ist.

Abbildung 13-04: Ausgabe des Briefs III

Im nächsten Beitrag werden wir uns einige der anderen Programme in Brief IV
genauer ansehen.

weblinks:
https://en.wikipedia.org/wiki/Motorola_68000
https://en.wikipedia.org/wiki/PAL
https://en.wikipedia.org/wiki/NTSC
https://retrocomputing.stackexchange.com/questions/2146/reason-for-the-amiga-clock-speed/2149#2149
https://en.wikipedia.org/wiki/Crystal_oscillator
http://amiga.resource.cx/photos/photo2.pl?id=a500&pg=1&res=med&lang=en
https://retrocomputing.stackexchange.com/questions/5994/amiga-memory-bandwidth/6112#6112
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node012B.html
http://amiga-dev.wikidot.com/hardware:ddfstrt
http://amiga-dev.wikidot.com/hardware:diwstrt
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n519
http://amiga-dev.wikidot.com/hardware:bplxdat

;------------------------------------------------------------------------------
14 - Amiga Machine Code Letter IV - More Code

Amiga Machine Code Letter IV - Mehr Code
11. Februar 2019  5 min lesen

Wir haben den Brief IV des Amiga Machine Code-Kurses erreicht.

In diesem Beitrag geht es um die Codebeispiele in Brief IV. Ich werde nicht auf
Details eingehen, da Sie sie im Brief nachschlagen können.

Wir beginnen mit dem Programmbeispiel 0402, das ein Programm mit einer Bitebene
erstellt und auch Speicherplatz dafür reserviert.

; file mc0402.s
start:
	move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

	move.w #$1200,$dff100	; BPLCON0 enable 1 bitplane, color burst
	move.w #$0000,$dff102	; BPLCON1 (scroll)
	move.w #$0000,$dff104	; BPLCON2 (video)
	move.w #0,$dff108		; BPL1MOD
	move.w #0,$dff10a		; BPL2MOD
	move.w #$2c81,$dff08e	; DIWSTRT top right corner ($81,$2c)
	;move.w #$f4c1,$dff090	; DIWSTOP enable PAL trick
	move.w #$38c1,$dff090	; DIWSTOP buttom left corner ($1c1,$12c)
	move.w #$0038,$dff092	; DDFSTRT
	move.w #$00d0,$dff094	; DDFSTOP

	lea.l screen,a1			; address of screen into a1
	lea.l bplcop,a2			; address of bplcop into a2
	move.l a1,d1
	move.w d1,6(a2)			; first halve d1 into addr a2 points to + 6 words
	swap d1					; swap data register halves
	move.w d1,2(a2)			; first halve d1 into addr a2 points to + 2 words

	lea.l copper,a1			; address of copper into a1
	move.l a1,$dff080		; COP1LCH, move long, no need for COP1LCL

	move.w #$8180,$dff096	; DMACON enable bitplane, copper

wait:
	btst #6,$bfe001			; test left mouse button
	bne wait				; if not pressed go to wait

	move.w  #$0080,$dff096	; restablish DMA's and copper
	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080
	move.w  #$80a0,$dff096
	rts

copper:
	dc.w $2c01,$fffe		; wait for line $2c
	dc.w $0100,$1200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
	dc.w $00e0,$0000		; move to BPL1PTH
	dc.w $00e2,$0000		; move to BPL1PTL

	dc.w $0180,$0000		; move to COLOR00 black
	dc.w $0182,$0ff0		; move to COLOR01 yellow

	dc.w $ffdf,$fffe		; wait enable wait > $ff horiz
	dc.w $2c01,$fffe		; wait for line $12c
	dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
	dc.w $ffff,$fffe		; end of copper

screen:
	blk.b 10240,0			; allocate block of bytes and set to 0

Beachten Sie den Ort, an dem wir das Register d1 tauschen. Es ist eigentlich
ein Beispiel für selbstmodifizierenden Code. Der Zeiger BPL1PTH und BPL1PTL
der Bitebene 1 in der Copperliste wird auf die Adresse des Bildschirms gesetzt.

Das Programm zeichnet nur einen schwarzen Bildschirm, da wir im
Bildschirmbereich nichts tun. Brief IV ermutigt Sie zum Experimentieren, indem
Sie dem Bildschirm Punkte und Linien hinzufügen. ZB fügt dieser Code ein Pixel
hinzu.

screen:
	dc.b $80
	blk.b 10240,0

In Brief IV wird eine Diskette 1 erwähnt, die eine Datei mit dem Namen
"SCREEN" enthält. Diese Datei enthält ein Bild, das in den Bildschirmpuffer
geladen werden soll. In Seka machst du das so.

SEKA>ri
FILENAME>brev4/screen
BEGIN>screen
END>

Der Anfangsteil ist eine Adresse im Speicher - verwenden Sie einfach die
Bildschirmbezeichnung. Lass es uns versuchen!

Abbildung 14-01: Arcus

Überschrift: Versuchen wir es mit fünf Bitebenen

Wir sind jetzt bereit für Bilder mit mehr Farben und einer eigenen Farbtabelle.

; file mc0403.s
start:
	move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

	move.w #$5200,$dff100	; BPLCON0 enable 5 bitplanes, color burst
	move.w #0,$dff102		; BPLCON1 (scroll)
	move.w #0,$dff104		; BPLCON2 (video)
	move.w #0,$dff108		; BPL1MOD
	move.w #0,$dff10a		; BPL2MOD

	move.w #$1c71,$dff08e	; DIWSTRT top right corner ($71,$1c)
	;move.w #$f4d1,$dff090	; DIWSTOP enable PAL trick
	move.w #$48d1,$dff090	; DIWSTOP buttom left corner ($1d1,$13C)
							; overscan 352x288
	move.w #$0030,$dff092	; DDFSTRT overscan
	move.w #$00d8,$dff094	; DDFSTOP overscan

	lea.l screen,a1			; address of screen into a1
	move.l #$dff180,a2		; address of COLOR00 into a2
	moveq #31,d0			; color table counter
colorloop:
	move.w (a1)+,(a2)+		; update color table
	dbra d0,colorloop		; loop over all 32 colors registers

	move.l a1,d1			; a1 now points to image data. move to d1
	lea.l bplcop,a2			; address of bplcop into a2
	addq.l #2,a2			; increment address in a2 by 2.
	moveq #4,d0				; update bitplane counter

bplloop:					; setup bitplane pointers
	swap d1					; swap data register halves
	move.w d1,(a2)			; first halve d1 into addr a2 points to
	addq.l #4,a2			; increment address in a2 by 4.
	swap d1					; swap data register halves
	move.w d1,(a2)			; first halve d1 into addr a2 points to
	addq.l #4,a2			; increment address in a2 by 4.
	add.l #12320,d1			; increment d1 to point to next bitplane
	dbra d0,bplloop			; loop over all 5 bitplanes

	lea.l copper,a1			; address of copper into a1
	move.l a1,$dff080		; COP1LCH, move long, no need for COP1LCL

	move.w #$8180,$dff096	; DMACON enable bitplane, copper

wait:
	btst #6,$bfe001			; test left mouse button
	bne wait				; if not pressed go to wait

	move.w  #$0080,$dff096	; restablish DMA's and copper
	move.l  $4,a6
	move.l  156(a6),a1
	move.l  38(a1),$dff080
	move.w  #$80a0,$dff096
	rts

copper:
	dc.w $1c01,$fffe		; wait for line $1c
	dc.w $0100,$5200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
	dc.w $00e0,$0000		; move to BPL1PTH
	dc.w $00e2,$0000		; move to BPL1PTL
	dc.w $00e4,$0000		; move to BPL2PTH
	dc.w $00e6,$0000		; move to BPL2PTL
	dc.w $00e8,$0000		; move to BPL3PTH
	dc.w $00ea,$0000		; move to BPL3PTL
	dc.w $00ec,$0000		; move to BPL4PTH
	dc.w $00ee,$0000		; move to BPL4PTL
	dc.w $00f0,$0000		; move to BPL5PTH
	dc.w $00f2,$0000		; move to BPL5PTL

	dc.w $ffdf,$fffe		; wait enable wait > $ff horiz
	dc.w $3401,$fffe		; wait for line $134
	dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
	dc.w $ffff,$fffe		; end of copper

screen:
	blk.l $3c38,0			; allocate block of bytes and set to 0

Dieses Programm richtet fünf Bitebenen ein und weist 32 Farbregistern Platz zu.

Das Programm enthält zwei Schleifen. Die erste Schleife überträgt die
Farbpalette in die Farbregister. Die andere Schleife richtet die
Bitebenenzeiger so ein, dass sie auf die Bilddaten zeigen.

Wenn Sie das Programm starten, ist der Bildschirm nur schwarz. Um die Sache
interessanter zu machen, laden Sie screen2 von Disk 1 in Seka.

SEKA>ri
FILENAME>brev4/screen2
BEGIN>screen
END>

Führen Sie dann das Programm aus. Voila, es entsteht ein PAL-Testmuster!

weblinks:
http://amiga-dev.wikidot.com/hardware:bplxpth
https://en.wikipedia.org/wiki/Philips_PM5544

;------------------------------------------------------------------------------
15 - Amiga Machine Code Letter V

Amiga Machine Code Letter V.
14. Februar 2019  7 min lesen

Wir haben den Brief V des Amiga Machine Code-Kurses erreicht.

In diesem Brief geht es um Sprites und einige zusätzliche Maschinencode 
Anweisungen sowie um die Einführung des Stacks. Beginnen wir mit den
zusätzlichen Maschinencode Anweisungen und schauen uns dann einen Code an.

Überschrift: Eine neue Art, sich zu bewegen

Der Brief führt einen neuen Adressierungsmodus ein, der als indirekte
Adressierung mit Indizierung und Verschiebung bezeichnet wird. Der
Adressierungsmodus ist im 68K-Opcode-Blatt aufgeführt und kann von
verschiedenen Anweisungen verwendet werden, z.B. move.

	move.w (A1,D1),D2		; fetch data in address A1+D1 and put it in D2

Diese Anweisung ruft die Daten in der Adresse A1 + D1 ab und legt sie in D2 ab.

Es gibt auch eine Variante mit einer Verschiebung.

	move.w 10(A1,D1),D2		; fetch data in address A1+D1+10 and put it in D2

Diese Anweisung ruft die Daten in der Adresse A1 + D1 + 10 ab und legt sie in
D2 ab.

Im 68K- Handbuch und im Opcode-Blatt ist die Syntax etwas anders.

(d, An, Xi) Address register indirect with displacement, and address 
            register indirect with indexing and displacement.

Ich werde mir nicht die Mühe machen, zu zeigen, wie man den Opcode ableitet,
wie ich es zuvor getan habe, da es nur mehr vom selben Zeug ist.

Es ist jedoch eine gute Übung, die binäre Ausgabe von Seka zu sehen und
herauszufinden, wie sie mit den Opcodes zusammenhängt.

Hinweis: Berücksichtigen Sie im Opcode-Blatt das kurze Erweiterungswort
zusammen mit der Verschiebungsanweisung. Das kurze Erweiterungswort wird für
zwei der Adressierungsmodi des 68K verwendet, von denen der oben genannte
einer ist.

Als ich die Anweisung mit dem Opcode verband, bemerkte ich, dass ich die
Verschiebung auf $FF beschränken sollte, da alles oben Genannte abgeschnitten
wird. Der Brief erwähnte dies nicht, ich denke, um nicht im Kaninchenbau der
Details stecken zu bleiben.

Ok, mach weiter (Wortspiel beabsichtigt)

Überschrift: Logische Verschiebung nach links / rechts

Dieser doppelte Befehlssatz verschiebt Bits des Operanden nach links oder
rechts. Einzelheiten finden Sie im Motorola 68000 Referenzhandbuch auf
Seite 4-91. Das Bit, das verschoben wird, ist immer 0.

	move.b #%00101100,d0
	lsl.b #1,d0				; shifts the byte 1 position to the left
							; %01011000

Die Anweisung kann auch im Opcode Blatt als LSd gefunden werden wo
d = L / R ist. Natürlich funktioniert eine Rechtsverschiebung in die
entgegengesetzte Richtung von links.

Das Übertragsbit im Statusregister empfängt das aus dem Operanden verschobene
Bit. Überprüfen Sie das Referenzhandbuch. Der Umgang mit Daten im Speicher ist
im Vergleich zu Daten in Registern begrenzt.

	move.l #%‭0110 0100 0101 1010 0100 0011 0110 0100‬,d0
	lsl.w #1,d0 ; shifts the bits in the first word 1 position to the left
				; %‭0110 0100 0101 1010 1000 0110 1100 1000‬

Wenn Sie den Opcode wirklich sehen möchten, lesen Sie das Opcode-Blatt oder
das Referenzhandbuch Seite 4-192. Letzteres erklärt es mit mehr Kontext.

Überschrift: Der Stack

Der nächste Maschinencodebefehl ist BSR oder Branch to Subroutine. Um einen
Sinn daraus zu machen, müssen wir wissen, was ein Stack ist.

Der Stack ist wie ein Stapel von Platten in einem Plattenausteiler. Die erste
Platte, die auf den Stack drückt, ist auch die erste, die Sie vom Stack
entfernen. Wir nennen dies auch einen LIFO-Puffer last in first out.

Im Kontext des Amiga verwenden wir den Stack, um den Status zu speichern und
etwas Neues zu tun, das seinen eigenen Status erfordert. Wenn wir mit dem, was
wir getan haben, fertig sind, entfernen wir einfach den alten Zustand vom
Stack, um den alten Zustand wiederherzustellen.

Lesen Sie unbedingt Brief V und folgen Sie dem abgebildeten Beispiel.

Der Stack wird von einem Stackzeiger (SP) gesteuert, der auf die Oberseite des
Stacks zeigt. Dieser Stackzeiger befindet sich im Adressregister A7.

Um den Status zu speichern, möchten wir normalerweise viele Register auf den
Stack verschieben. Wir machen diesen Push, indem wir einen speziellen
Verschiebungsbefehl namens movem verwenden, der mehrere Register kopiert.

	movem.l	d0-d5,-(a7) ; push d0 to d5 onto the stack and predecrement SP

Das abgebildete Stackbeispiel in Brief V hat mich verwirrt, irgendwie wollte
ich, dass der Stackzeiger woanders ist.

Wenn Sie mit etwas Trübem konfrontiert werden, ist es die beste Strategie, es
in der Praxis auszuprobieren. Das folgende Programm ist ein solcher Versuch.

; file mc0504.s		; = mc05stack 
start:
	move.l a7,a0			; save SP in a0
	move.l #$10,d0			; move $10 into d0
	move.l #$20,d1			; move $20 into d1
	movem.l d0-d1,-(a7)		; push d0-d1 on stack
	move.l a7,a1			; save SP in a1
	clr.l d0				; clear d0
	clr.l d1				; clear d1
	movem.l (a7)+,d0-d1		; pop d0-d1 from stack
	move.l a7,a2			; save SP in a2

	rts						; return from subroutine

Der Code ist trivial, wir speichern unseren anfänglichen SP in a0 und
kopieren dann einige Werte in d0 und d1. Dann kopieren wir diese auf den
Stack und speichern den SP in a1. Wir löschen dann d0 und d1 und stellen den
Status wieder her, indem wir den Stack öffnen, der d0 und d1 auf ihre Werte
vor dem Löschen setzt. Wir speichern dann den SP in a2.

Ich habe dieses Programm in Seka ausgeführt und die folgende Ausgabe erhalten:

d0 = $10, d1 = $20
a0 = $c49bb0, a1 = $c49ba8, a2 = $c49bb0

Wir schieben zwei Longs auf den Stack, wodurch der Stackpointer um $8
verringert wird. Wir sehen, dass a0 - $8 = a1, was genau wie erwartet ist.

Aber auf welche Daten zeigt der Stackzeiger? Um dies zu überprüfen, starten Sie
den Debugger. Hier ist ein Bild des Debuggers, kurz bevor wir den Stackzeiger
in a1 speichern.

Abbildung 15-01: Debugger1

Die grünen Kästchen zeigen die Werte, die wir auf den Stack geschoben haben.
Das blaue Kästchen neben a7 zeigt unseren Stackzeiger SP und wird im
Speicherauszug wiederholt. Der SP zeigt auf $c32fe4, das $10 enthält, weil wir
d0 und d1 wie mit movem festgelegt zusammengeschoben haben. Wie hätte das
ausgesehen, wenn wir sie getrennt geschoben hätten? Sie finden es heraus

Tipp: Sie können einfach einen Zug verwenden, um einen einzelnen Wert auf dem
Stack zu verschieben oder zu platzieren.

Die roten Kästchen zeigen den Programmzähler - er hat eine Verbindung mit der
Purble-Box. Gehen Sie das Programm durch und sehen Sie, was passiert, wenn wir
d0 und d1 löschen und später den Stack öffnen.

Ok, weiter zur letzten Zeile im Programm, rts , Rückkehr vom Unterprogramm.

Abbildung 15-02: Debugger2

Beachten Sie, wie der SP von $C32FE4 auf $C32FF0 gestiegen ist, das ist ein
Unterschied von $C oder 12 Bytes oder 3 Longs. Zwei dieser Longs kamen von dem
Zeitpunkt an, als wir d0 und d1 auf den Stack geschoben haben. Das letzte long
ist die Absenderadresse, welches rts verwendet um uns zurück zu bringen, wo wir
herkommen. Das ist die Purble Box im ersten Bild. Das zweite Bild zeigt, dass
der Programmzähler-PC jetzt aktualisiert wurde, um auf diese Adresse zu zeigen.

Wenn wir unsere Stackarithmetik irgendwie vermasseln, könnten wir den
Programmzähler an Orte senden, an die er nicht gehen sollte, wenn wir rts
aufrufen. In höheren Sprachen wird das Wechseln zwischen Stackrahmen vom
Compiler durchgeführt. Hier auf Maschinenebene müssen wir es selbst tun.

Überschrift: Zum Unterprogramm verzweigen

Mit Kenntnis des Stacks können wir BSR jetzt besser verstehen. Wir verwenden
diese Anweisung, um zu einem Unterprogramm zu gelangen. Es ist das grundlegende
Äquivalent eines Funktionsaufrufs in höheren Sprachen. Der allgemeine Kern ist
der folgende

	bsr routine				; go to routine
	...						; code goes here
	rts						; return from subroutine

routine:					; label named routine
	...						; code goes here
	rts						; return from subroutine

Brief V ermutigt Sie, ein wenig mit BSR zu spielen, um ein Gefühl dafür zu
bekommen. Ich habe das getan, und du solltest es auch tun. Es ist ein guter
Rat, sich die Hände schmutzig zu machen.

Was ich fand, war, dass wir hier auf Stackarithmatik achten müssen. Wenn ich in
einer Unterroutine etwas auf den Stack schiebe, erinnere ich mich besser daran,
es zu öffnen, bevor ich RTS aufrufe. Denken Sie daran, dass der Stack auch die
Rücksprungadresse für den Programmzähler enthält.

In höheren Sprachen kümmern wir uns normalerweise nicht um den Stack oder den
Stackzeiger, da das gesamte Bookeeping vom Compiler durchgeführt wird.

Mit den Anweisungen BSR und RTS können wir Unterprogramme definieren, die
unseren Assembler-Code in allgemeine wiederverwendbare Teile unterteilen
können.

Überschrift: Nächster Beitrag

Im nächsten Beitrag werde ich mehr über Sprites schreiben und mir auch die
Programmbeispiele in Brief V ansehen.

weblinks:
http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf
http://wpage.unina.it/rcanonic/didattica/ce1/docs/68000.pdf
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n143
https://www.markwrobel.dk/post/amiga-machine-code-part1-debugger/
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n103

;------------------------------------------------------------------------------
16 - Amiga Machine Code Letter V - Sprites

Amiga Machine Code Letter V - Sprites
16. Februar 2019  7 min lesen

Wir haben den Brief V des Amiga Machine Code-Kurses erreicht.

Die Programmbeispiele sind jetzt so groß, dass wir sie von der Kursdiskette
Disk 1 lesen müssen

Unten finden Sie eine Liste des Programms mc0501, das ein Sprite einer
norwegischen Flagge zeigt, das den Bildschirm nach unten rollt. Ich habe
das Programm kommentiert und unter dem Listing werde ich auf einige Details
eingehen.

Abbildung 16-01: Norwegen Sprite

; file mc0501.s
	move.w	#$4000,$dff09a		; INTENA - clear external interrupt

	or.b	#%10000000,$bfd100	; CIABPRB stops drive motors
	and.b	#%10000111,$bfd100	; CIABPRB

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, sprite

	move.w	#$1200,$dff100		; BPLCON0 one bitplane, color burst
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$003f,$dff104		; BPLCON2 video
	move.w	#0,$dff108			; BPL1MOD bitplane modulo odd planes
	move.w	#0,$dff10a			; BPL2MOD bitplane modulo even planes
	move.w	#$2c81,$dff08e		; DIWSTRT upper left corner of display ($81,$2c)
	move.w	#$f4c1,$dff090		; DIWSTOP enable PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP lower right corner of display ($1c1,$12c)
	move.w	#$0038,$dff092		; DDFSTRT Data fetch start
	move.w	#$00d0,$dff094		; DDFSTOP Data fetch stop

	lea.l	sprite,a1			; put sprite address into a1
	lea.l	copper,a2			; put copper address into a2
	move.l	a1,d1				; move sprite address into d1
	move.w	d1,6(a2)			; transfer sprite address high to copper
	swap	d1					; swap
	move.w	d1,2(a2)			; transfer sprite address low to copper

	lea.l	blanksprite,a1		; put blanksprite address into a1
	lea.l	copper,a2			; put copper address into a2
	add.l	#10,a2				; add 10 to copper address in a2
	move.l	a1,d1				; move blanksprite address into d1
	moveq	#6,d0				; setup sprite counter

sprcoploop:						; set all 7 sprite pointers
	swap	d1					; high and low to point to blanksprite 
	move.w	d1,(a2)
	addq.l	#4,a2
	swap	d1
	move.w	d1,(a2)
	addq.l	#4,a2
	dbra	d0,sprcoploop		; loop trough all 7 sprite pointers

	lea.l	screen,a1			; put screen address into a1
	lea.l	bplcop,a2			; put bplcop address into a2
	move.l	a1,d1				; transfer screen address to bplcop
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	lea.l	copper,a1			; put copper address into a1
	move.l	a1,$dff080			; COP1LCH (also sets COP1LCL)
	move.w	$dff088,d0			; COPJMP1 
	move.w	#$81a0,$dff096		; DMACON set bitplane, copper, sprite

wait:							; wait until at beam line 0
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 places
	and.l	#$1ff,d0
	cmp.w	#0,d0
	bne	wait					; if not equal jump to wait

wait2:							; wait until at beam line 1
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0
	and.l	#$1ff,d0
	cmp.w	#1,d0
	bne	wait2					; if not equal jump to wait

	bsr	movesprite				; branch to subroutine movesprite

	btst	#6,$bfe001			; test left mouse left mouse click
	bne	wait					; if not pressed jump to wait

	move.w	#$0080,$dff096		; reestablish DMA's and copper

	move.l	$04,a6
	move.l	156(a6),a1
	move.l	38(a1),$dff080

	move.w	#$8080,$dff096
	move.w	#$c000,$dff09a
	rts

movesprite:						; movesprite subroutine
	lea.l	sprite,a1
	cmp.b	#250,2(a1)			; sprite bottom line at 250
	bne	notbottom				; if not go to notbottom

	move.b	#30,(a1)
	move.b	#44,2(a1)

notbottom:
	add.b	#1,(a1)				; move sprite top line by 1
	add.b	#1,2(a1)			; move sprite bottom line by 1
	rts							; return from subroutine

copper:
	dc.w	$0120,$0000			; SPR0PTH
	dc.w	$0122,$0000			; SPR0PTL
	dc.w	$0124,$0000			; SPR1PTH
	dc.w	$0126,$0000			; SPR1PTL
	dc.w	$0128,$0000			; SPR2PTH
	dc.w	$012a,$0000			; SPR2PTL
	dc.w	$012c,$0000			; SPR3PTH
	dc.w	$012e,$0000			; SPR3PTL
	dc.w	$0130,$0000			; SPR4PTH
	dc.w	$0132,$0000			; SPR4PTL
	dc.w	$0134,$0000			; SPR5PTH
	dc.w	$0136,$0000			; SPR5PTL
	dc.w	$0138,$0000			; SPR6PTH
	dc.w	$013a,$0000			; SPR6PTL
	dc.w	$013c,$0000			; SPR7PTH
	dc.w	$013e,$0000			; SPR7PTL

	dc.w	$2c01,$fffe
	dc.w	$0100,$1200

bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$0ff0			; COLOR01 yellow
	dc.w	$01a2,$0f00			; COLOR17 sprite0 red 
	dc.w	$01a4,$0fff			; COLOR18 sprite0 white
	dc.w	$01a6,$000b			; COLOR19 sprite0 blue

	dc.w	$ffdf,$fffe			; wait enables waits > $ff vertical
	dc.w	$2c01,$fffe			; wait for line - $2c is $12c
	dc.w	$0100,$0200			; BPLCON0 unset bitplanes, enable color burst
								; needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.b	10240,0				; allocate 1 kb of memory and set it to zero

sprite:
	dc.w	$1e8c,$2c00
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$0300,$FFFF ; %0000 0011 0000 0000, %1111 1111 1111 1111
	dc.w	$FFFF,$FFFF ; %1111 1111 1111 1111, %1111 1111 1111 1111
	dc.w	$FFFF,$FFFF ; %1111 1111 1111 1111, %1111 1111 1111 1111
	dc.w	$0300,$FFFF ; %0000 0011 0000 0000, %1111 1111 1111 1111
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$0000,$0000 ; %0000 0000 0000 0000, %0000 0000 0000 0000
	dc.w	$0000,$0000 ; %0000 0000 0000 0000, %0000 0000 0000 0000

blanksprite:
	dc.w	$0000,$0000			; an empty sprite

Das Sprite selbst ist als 16 Pixel breit definiert, während Sie die Länge
selbst definieren. Ein Sprite kann vier Farben haben, von denen eine
Farbe transparent ist. Ein Sprite kann an einer beliebigen Position auf dem
Bildschirm platziert werden. Das erste Farbregister in der Gruppe der
vier Farbregister wird ignoriert und ist somit die transparente Farbe.

Ein Sprite besteht aus einer Reihe von Longs.

long 1 ; position and height
long 2 ; sprite data 
long 3 ; sprite data
...
long N ; zeros denotes the last line of the sprite. (or again long 1)

Das erste Long eines Sprites definiert die Position und Höhe des Sprites. Es
ist ein bisschen kompliziert, weil wir keine Bildschirmposition in 8 Bits
packen können. Hier ist ein Schema.

Abbildung 16-02: Sprite erste Zeile

Das Schema zeigt, dass das Sprite bei Zeile $1e beginnt und bei Zeile $2c
endet. Die horizontale Position der linken Seite beginnt bei $8c * 2 = $118.
Wir multiplizieren mit zwei, weil das erste Steuerbit Bit 0 ist.

Die Sprite-Grafikdaten funktionieren genauso wie Bitebenen. Jede Zeile mit
Sprite-Grafikdaten besteht aus zwei Wörtern, wobei jedes Wort eine Bitebene
mit einer Breite von 16 Pixeln definiert. Mit diesem Setup können wir vier
Farben haben. (Anmerkung: 3 Farben und 1x transparent)

Die Zuordnungen der Farbregister finden Sie im Amiga Hardware-Referenzhandbuch.

Abbildung 16-03: Sprite-Farbregisterzuweisungen

Überschrift: Sprite-Welle

Das nächste Beispiel im Brief ist mc0502, das sich auch auf Disk1
befindet. Es ist doppelt so lang wie das obige Programm, daher werde ich es
hier nicht auflisten. Es ist auch im Prinzip dem ersten Beispiel fast ähnlich.

Das Programm mc0502 verfügt jedoch über mehr Sprites und ein Hintergrundbild.
Die Sprites bewegen sich nach einem in einer Tabelle definierten Muster. Sowohl
der Hintergrund als auch die Tabelle sollten in Seka geladen werden.

SEKA>ri
FILENAME>screen
BEGIN>screen
END>
SEKA>ri
FILENAME>movetable
BEGIN>movetable
END>

Hier ist ein Screenshot. Die Sprites buchstabieren "Brevkurs" auf Norwegisch.

Abbildung 16-04: Sprites bewegen sich

Das Bewegungsmuster wird in einer Tabelle gespeichert, da die Berechnung
ziemlich aufwendig ist.

Trigonomische Funktionen wie Sinus und Cosinus sind in Assembler ebenfalls
nicht trivial zu implementieren. Daher bestand ein Bedarf an
Wellengeneratorprogrammen, die solche Tabellen erzeugen konnten. Ein solches
Programm heißt Wavegen und befindet sich auf Disk1.

Heutzutage haben wir alle Zugriff auf Gleitkomma-Hardware, daher sehen wir die
Optimierungstechnik für Nachschlagetabellen nicht mehr so ​​oft. Funktionen wie
Sinus und Cosinus haben die interessante Eigenschaft, reine Funktionen zu sein.
Das heißt, eine Funktion, die bei gleicher Eingabe dieselbe Ausgabe erzeugt.
ZB Sinus bis 90 Grad ist immer gleich. Eine solche Funktionsklasse kann
vollständig durch Tabellensuche ersetzt werden.

Es gibt einen interessanten Hinweis zur Verwendung von Tabellen zum Speichern
von Bewegungen auf coppershade.org. Schauen Sie mal rein, es ist eine
fantastische Seite.

Es ist teuer, Sinus und Cosinus zu berechnen, aber nicht unmöglich. Viele
verwendeten einen Algorithmus aus dem Jahr 1959 namens CORDIC oder Volder's
Algorithmus, der sich nur auf Addition, Subtraktion, Bitshift und Tabellensuche
stützte. Dieser Algorithmus hat seinen Weg in viele Chips gefunden,
einschließlich der Gleitkomma-Coprozessoren von Motorola, 68881 und 68882.

weblinks:
https://archive.org/details/Amiga_Hardware_Reference_Manual_1985_Commodore_a/page/n107
http://coppershade.org/articles/Code/Articles/3._The_Year_of_the_Snake/
https://en.wikipedia.org/wiki/CORDIC

;------------------------------------------------------------------------------
17 - Amiga Machine Code Letter VI - Blitter

Amiga Maschine Code Letter VI - Blitter
02.03.2019  6 min lesen

Wir haben Letter VI des Amiga Machine Code Kurses erreicht. Ich werde nur die
Details in diesem Beitrag überspringen. Achten Sie darauf, den Brief zu lesen,
um ein Verständnis der Dinge zu bekommen.

Das Hauptthema dieses Briefes ist das Verschieben von Bytes von einem Array von
Speicher zu einem anderen. Im Amiga kann dies mit Hardware-Unterstützung durch
eine Technik namens Blitting erfolgen.

Das Wort Blitting leitet sich von der BitBLT-Routine für den Xerox Alto
Computer in Verbindung mit Smalltalk ab und steht für Bitblockübertragung.

Durch die Verwendung einer Kombination von benutzerdefinierten Chipregistern
ist es möglich, auf arrays des Speichers hinzuweisen, die in einen anderen Teil
des Speichers übertragen werden sollen - in der Regel den Bildschirmspeicher.

Das Verschieben von Daten könnte eine CPU-intensive Aufgabe sein, aber nicht im
Amiga. Blitting wird durch den Agnus-Chipsatz gehandhabt, der eine schnelle
Speicherübertragung ohne Einbeziehung der 68K CPU ermöglicht.

Das Konzept des Blittings unterscheidet sich von Sprites. Während Sprites
getrennt vom Bildschirmspeicher gespeichert werden, schreibt blitting direkt
in den Bildschirmspeicher.

Der Amiga hat drei Speicherquellen, die mit einer booleschen Funktion
kombiniert und in das Speicherziel geschrieben werden können.

Das Blitting wird durch die Steuerregister BLTCON0 und BLTCON1 gesteuert, was
auch die boolesche Übertragungsfunktion definiert.

Die Speicherbereiche werden definiert, indem Zeiger auf die
BLTxPTH / BLTxPTL-Steuerregister vergeben werden.

Ebenso wird der Modulo für jede Quelle durch die BLTxMOD-Steuerregister
gesteuert. Der Modulo ist in Bytes angegeben.

Schließlich wird die Größe des Blittings in Breite und Höhe durch das
BLTSIZE-Steuerregister festgelegt. Die Höhe wird in Linien angegeben, und die
Breite in Wörtern (16 Pixel).

Bei einem Bildschirm mit einer Breite von 40 Byte und einer Fläche von
4 Wörtern ist der Modulowert:

40 bytes-(4words*2) 0 (40-8)bytes=32bytes

In der Abbildung unten können wir die Situation visualisiert sehen. Wenn der
Blitter den Offset 134 vom Anfang des Bildschirmspeichers erreicht, fügt er
den Modulo von 32 Bytes hinzu, um zur nächsten zu blittenden Speicheradresse 
zu gelangen, die in diesem Fall 134 + 32 = 166 ist.

Abbildung 17-01: Blitter memory

Überschrift: Funktionsgenerator

Die drei Bitplanes A,B und C können mit einer booleschen Funktion kombiniert
werden, bevor sie an das Ziel geschrieben werden. Diese boolesche Funktion wird
durch das untere Byte im BLTCON0-Register definiert. Es gibt eine Erklärung
darüber, im Amiga Hardware Reference Manual.

Der Funktionsgenerator ist ziemlich motorisch in seiner Einfachheit.
Es verwendet sogenannte Minterms, jede boolesche Funktion kann als Summe
von Minterms geschrieben werden.

Pos				A	B   C	Minterm
0				0	0	0	A!B!C!	 
1				0	0	1	A!B!C	 
2				0	1	0	A!BC!	 
3				0	1	1	A!BC 
4				1	0	0	AB!C!	 
5				1	0	1	AB!C 
6				1	1	0	ABC!	 
7				1	1	1	ABC	

Es gibt eine große Einsicht in diese Einfachheit, die den Funktionsgenerator
wirklich schön in seiner Gestaltung macht. All dies wird durch einfache boolesche
Algebra ermöglicht, bei der jeder Teil eines Ausdrucks in einen Minterm
umgewandelt werden kann, indem die folgende Regel verwendet wird:

1 = A + A! = B + B! = C + C!

Verwenden wir diese Einsicht, um den folgenden Ausdruck in seine äquivalenten
Minterms zu erweitern.

D=AC! + B
 =A(1)C! +  (1)B(1)
 =A(B+B!)C! + (A+A!)B(C+C!)
 =ABC! + AB!C! + ABC + ABC! + A!BC + A!BC!
 =ABC! + AB!C! + ABC + A!BC + A!BC!
 
Wenn wir jedes der fünf Minterms in der Tabelle oben haben, zeigt sich, dass
wir die Bits 6, 4, 7, 3 und 2 des BLTCON0-Registers setzen müssen, was der
Einstellung des unteren Bytes auf %11011100 = $dc entspricht.

Die obige Methode ist eine ziemlich umständliche Möglichkeit, den
Funktionsgenerator einzustellen, so dass sowohl Brief VI als auch das
Amiga Hardware Reference Manual eine schnellere Alternative bieten, indem
sie vorberechnete Minterms verwendet.

Ausdruck	BLTCON0 LF		Ausdruck		BLTCON0 LF
D=A			$f0				D=AB			$c0
D=A!		$0f				D=AB!			$30
D=B			$cc				D=A!B			$0c
D=B!		$33				D=A!B!			$03
D=C			$aa				D=BC			$88 
D=C!		$55				D=BC!			$44
D=AC		$a0				D=B!C			$22
D=AC! 		$50				D=B!C!			$11 
D=A!C		$0a				D=A + B!		$f3 
D=A!C!		$05				D=(A + B)!		$3f
D=A +B		$fc				D=A + C!		$f5
D=A!+B		$cf				D=(A + C)!		$5f
D=A +C		$fa				D=B + C!		$dd
D=A!+C		$af				D=(B + C)!		$77
D=B +C		$ee				D=AB + A!C		$ca 
D=B!+C		$bb				D=AB! + AC		$ac

Wir können uns schnell versichern, dass die vorberechneten Minterms einen
schnelleren Prozess ermöglichen. Wenn wir das Beispiel von früher betrachten.

D=AC!+B
  AC!=$50	= %0101.0000
    B=$cc	= %1100.1100	; (+) = or
AC!+B=$dc   = %1101.1100	; result

Wir betrachten das Ergebnis, indem wir jeden Term in der vorberechneten
Tabelle nachsehen. Verwenden Sie dann ein oder (wegen der +), um das
Endergebnis zu erhalten.

Wenn es schwer zu verstehen ist, warum der boolesche Funktionsgenerator
nützlich ist, lesen Sie das Beispiel für Autoanimation im Amiga Hardware
Reference Manual.

Überschrift: Die Cookie-Cut-Funktion

Der Blitter wäre viel weniger nützlich, wenn nicht sein boolescher
Funktions Generator wäre. Durch sorgfältiges Einrichten einer booleschen
Funktion kann der Blitter verwendet werden, um Objekte auf dem Bildschirm
zu bewegen, ähnlich wie Sprites.

Allerdings werden Blitter-Objekte, oder BOB's, wie sie genannt werden, direkt
in den Bildschirmspeicher geschrieben, im Gegensatz zu Sprites, die in ihrem 
eigenen Speicher gespeichert sind. Dies setzt voraus, dass der Hintergrund
kontinuierlich als Teil des Blitts neu gezeichnet wird.

Zur Veranschaulichung habe ich einen Grafiktest von Master484 gefunden,
der Blitter-Objekte in einem Street Fighter-Spiel verwendet.

Abbildung 17-02: Street Fighter

Im obigen Screenshot wird der Sumo-Wrestler in den Bildschirm geblittet. Da
aber der Blitter nur einen rechteckigen Bereich zeichnen kann, müssen wir auch
den Hintergrund als Teil des Blitts zeichnen. Hier zeichnet sich der
boolesche Funktionsgenerator aus.

Definieren wir den Speicher, in dem sich der Sumo-Wrestler befindet als B und
eine entsprechende Maske als A und den Hintergrund als C. Wenn die Maske
gesetzt ist, passieren die Wrestler-Daten, und wenn die Maske nicht gesetzt
ist, passieren wir den Hintergrund. Genau das macht die Cookie-Cut-Funktion.

D=AB + A!C

Abbildung 17-03: cookie-cut

Es ist wichtig, den Blitter in der richtigen Reihenfolge einzurichten.
Die empfohlene Reihenfolge ist:

1. Daten
2. BLTCONx
3. Maske
4. Modulos
5. BLTSIZE

Vor allem der BLTSIZE muss als letztes kommen, da er den Blitter beim nächsten
Speicherzyklus auslöst.

Im nächsten Beitrag werden wir einen Blick auf den Programmcode werfen!

weblinks:
https://www-user.tu-chemnitz.de/~heha/viewchm.php/hs/petzold.chm/petzoldi/ch14d.htm
http://amiga-dev.wikidot.com/information:hardware
http://amiga-dev.wikidot.com/hardware:bltcon0
http://amiga-dev.wikidot.com/hardware:bltxpth
http://amiga-dev.wikidot.com/hardware:bltxmod
http://amiga-dev.wikidot.com/hardware:bltsize
https://archive.org/details/Amiga_Hardware_Reference_Manual_1985_Commodore_a/page/n175
http://eab.abime.net/showthread.php?t=84957
http://coppershade.org/articles/AMIGA/Agnus/Programming_the_Blitter/

;------------------------------------------------------------------------------
18 - Amiga Machine Code Letter VI - Blitter 2
Amiga Maschine Code Letter VI - Blitter 2
22.03.2019  4 min lesen

Wir haben Brief VI des Amiga Machine Code Kurses erreicht. Ich überspringe
die Details in diesem Beitrag. Achten Sie darauf, den Brief zu lesen, um ein
Verständnis der Dinge zu bekommen.

In diesem Beitrag werden wir uns den Code des mc0601-Programms ansehen, das
auf Disk 1 zu finden ist.

Das Programm zeichnet ein Blitterobjekt, das sanft auf schwarzem Hintergrund 
auf dem Bildschirm scrollt. Es ist ein sehr einfaches Blitting, das ein
grundlegendes Verständnis bietet, das uns gut dienen wird, wenn wir zu
komplexeren Formen des Blittings übergehen.

Abbildung 18-01: mc0601 screenshot

Um das Objekt zu blitten müssen wir es von Disk 1 in den Speicher an das
richtige Label laden. Verwenden Sie in Seka "v", um in den Ordner BREV06 zu
wechseln, und führen Sie das Programm dann durch Schreiben aus:

SEKA>r
FILENAME>mc0601
SEKA>a
OPTIONS>
No errors
SEKA>ri
FILENAME>object
BEGIN>object
END>
SEKA>j

Achten Sie darauf, Informationen über die benutzerdefinierten Chipregister
zu suchen, während Sie mitlesen.

; file mc0601.s
start: 
	move.w	#$4000,$dff09a		; INTENA clear master interupt
								; turn off disk
	or.b	#%10000000,$bfd100	; CIABPRB Disk
	and.b	#%10000111,$bfd100	; CIABPRB Disk

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter

	move.w	#$1200,$dff100		; BPLCON0 1 bitplane and color burst
	move.w	#$0000,$dff102		; BPLCON1 scroll value
	move.w	#$0000,$dff104		; BPLCON2 video priority control
	move.w	#0,$dff108			; BPL1MOD
	move.w	#0,$dff10a			; BPL2MOD
	move.w	#$2c81,$dff08e		; DIWSTRT
	move.w	#$f4c1,$dff090		; DIWSTOP enable PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP
	move.w	#$0038,$dff092		; DDFSTRT 
	move.w	#$00d0,$dff094		; DDFSTOP

	;----write screen pointer into bplcop
	lea.l	screen,a1			; put screen address into a1
	lea.l	bplcop,a2			; put bplcop address into a2
	move.l	a1,d1				; transfer screen to bitplane 1 pointer in bplcop
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	;-----transfer copper pointer to custom chip register
	lea.l	copper,a1			; put copper address into a1
	move.l	a1,$dff080			; COP1LCH (and COP1LCL)
	move.w	#$8180,$dff096		; DMACON set bitplane, copper

mainloop:
	;-----busy wait for line 300
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 positions
	andi.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0
	bne	mainloop				; if not at line 300 goto mainloop

	;-----now at line 300---
	bsr	clear					; branch to subroutine clear

	bsr	blitin					; branch to subroutine blitin

	btst	#6,$bfe001			; test left mouse button
	bne	mainloop				; if not pressed goto mainloop

	;-----exit program---
	move.w	#$0080,$dff096		; DMACON clear copper

	move.l	$4,a6				; reestablish DMA's and copper
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts							; exit program

clear:
	lea.l	screen,a1			; put screen address into a1

waitblit1:						; wait for blitter to finish
	btst	#6,$dff002			; DMACONR test blitter
	bne	waitblit1
	;-----blitter finished---

	;-----because no source only 0's are written to D---
	move.l	a1,$dff054			; BLTDPTH (and BLTDPTL) set to screen
	move.w	#0,$dff066			; BLTDMOD
	move.w	#$0100,$dff040		; BLTCON0 Use D channel - no source, no bool fun
	move.w	#$0000,$dff042		; BLTCON1
	move.w	#$4014,$dff058		; BLTSIZE %0100 0000 0001 0100 (256, 20)
	rts
	;-----end clear subroutine---

pos:
	dc.l	0					; allocate line position counter

blitin:							; blit
	lea.l	pos,a1				; put pos address into a1
	move.l	(a1),d1				; move line position to d1
	addq.l	#1,(a1)				; increment line position

	cmp.w	#216,d1				; blitting 40 lines. 216 + 40 = 256
	bne	notbottom				; if line pos is not 216 goto notbottom

	clr.l	d1
	clr.l	(a1)

notbottom:
	lea.l	screen,a1			; put screen address into a1
	mulu	#40,d1				; unsigned multiply - a line has 40 bytes (320/8)
	add.l	d1,a1				; add lines as number of bytes to start of screen (a1)
	add.l	#12,a1				; center blitting on screen (12 + 16 + 12 = 40)
								; the blit is 16 bytes wide
	lea.l	object,a2			; put object address into a2

waitblit2:						; wait for blitter to finish
	btst	#6,$dff002			; DMACONR test blitter
	bne	waitblit2
	;-----blitter finished---

	move.l	a1,$dff054          ; BLTDPTH (and BLTDPTL)
	move.l	a2,$dff050          ; BLTAPTH (and BLTAPTL)
	move.w	#24,$dff066         ; BLTDMOD (12 + width of blit + 12 = 40)
	move.w	#0,$dff064          ; BLTAMOD
	move.l	#$ffffffff,$dff044  ; BLTAFWM (and BLTALWM) blitter mask
	move.w	#$09f0,$dff040      ; BLTCON0
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0a08,$dff058      ; BLTSIZE %0000 1010 0000 1000 
								; height = 40 lines, width = 8 words -> 128 pixel
	rts                         ; return from blitin
	;-----end blitin subroutine

copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$1200			; BPLCON0 enable 1 bitplane, color burst

	bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$00ff			; COLOR01 cyan

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait > $ff horiz

	dc.w	$2c01,$fffe			; wait($01,$12c)
	dc.w	$0100,$0200			; BPLCON0 disable bitplanes - older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	2560,0				; allocate 10kb and set to zero

object:
	blk.l	160,0				; allocate 640 bytes and set to zero

Das Warten auf die Blitter-Routine wird auch hier beschrieben.

weblinks:
http://amiga-dev.wikidot.com/information:hardware
http://coppershade.org/articles/AMIGA/Agnus/Programming_the_Blitter/

;------------------------------------------------------------------
19 - Amiga Machine Code Letter VI - Blitter 3

Amiga Maschine Code Letter VI - Blitter 3
22.03.2019  12 min lesen

Wir haben Brief VI des Amiga Machine Code Kurses erreicht. Ich werde nur die
Details in diesem Beitrag überspringen. Achten Sie darauf, den Brief zu lesen,
um ein Verständnis der Dinge zu bekommen.

In diesem Beitrag werde ich durch den Code des mc0602-Programms gehen, der auf
Disk 1 gefunden werden kann. Ich habe den Code mit vielen Kommentaren ergänzt,
so dass es möglich sein sollte, einen Überblick über Dinge zu bekommen, die
diesen Beitrag allein lesen.

Um die Dinge zum Laufen zu bringen, müssen Sie den Befehl "ri" von Seka
verwenden, um die Assets an ihren angegebenen Bezeichnungen in den Speicher zu
laden. Ich habe diese Demo mit 300kb Chip-Mem in Seka laufen lassen. Denken
Sie daran, dass wir Chip-Mem wollen, denn das ist der einzige Speicher, den
die benutzerdefinierten Chips lesen können.

Öffnen Sie Seka und wechseln Sie zu dem Ordner, in dem sich Disk 1 befindet.
Das Buch Amiga Machine Language enthält bei Bedarf einige Dokumentationen
über Seka. Schreiben Sie nun etwas in dieser Richtung:

SEKA>r
FILENAME>mc0602
SEKA>a
OPTIONS>
No Errors
SEKA>ri
FILENAME>screen
BEGIN>screen
END>
SEKA>ri
FILENAME>fig
BEGIN>fig
END>
SEKA>ri
FILENAME>mask
BEGIN>mask
END>

Wie oben zu sehen ist, haben wir Assets für den Hintergrundbildschirm und für
die Abbildung und die entsprechende Maske. Wir müssen diese Assets an den
dafür vorgesehenen Labeln in den Speicher laden, damit diese Demo funktioniert.
Beginnen wir mit einem Screenshot

Abbildung 19-01: mc0602 screenshot

Dieses Programm baut auf den gleichen allgemeinen Prinzipen wie das vorherige
mc0601-Programm auf. Aber es verwendet viel mehr Unterroutinen, um die Dinge
organisiert zu halten.

Der allgemeine Ansatz ist, dass wir jetzt 5 Bitplanes und damit 32 Farben
haben, sowohl für Hintergrund- als auch für die Blitter-Objekte. Das
Blitter-Objekt wird mit der Maus auf dem Bildschirm verschoben.

Wir verwenden auch eine erweiterte Blitter-Logik-Funktion, die
Cookie-Cut-Funktion, die wir in einem früheren Beitrag untersucht haben.

Die Shiftblit Subroutine ist auch ein bisschen interessant, so dass ich ein
paar Notizen dazu am Enden dieses Beitrags schreiben werde.

; file mc602.s
	move.w	#$4000,$dff09a		; INTENA clr master interrupt

	;----Stop disk drives
	or.b	#%10000000,$bfd100	; set CIABPRB MTR
	and.b	#%10000111,$bfd100	; clr CIABPRB SEL3, SEL2, SEL1, SEL0

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter

	;-----Setup bitplanes, display and DMA data fetch---
	;-----Resolution 320*256 with 5 bitplanes
	move.w	#$5200,$dff100		; BPLCON0 use 5 bitplanes (32 colors)
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$0000,$dff104		; BPLCON2 video
	move.w	#0,$dff108			; BPL1MOD modulus odd planes
	move.w	#0,$dff10a			; BPL2MOD modulus even planes
	move.w	#$2c81,$dff08e		; DIWSTRT upper left corner ($81,$2c)
	move.w	#$f4c1,$dff090		; DIWSTOP enaple PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP lower right corner ($1c1,$12c)
	move.w	#$0038,$dff092		; DDFSTRT data fetch start at $38
	move.w	#$00d0,$dff094		; DDFSTOP data fetch stop at $d0

	;-----Transfer colors from screen to the color table registers
	lea.l	screen,a1			; write screen address into a1
	move.l	#$dff180,a2			; move address of COLOR00 into a2
	moveq	#31,d0				; set color counter to 31
		
colorloop:
	move.w	(a1)+,(a2)+			; move color from screen to color table
	dbra	d0,colorloop		; if not -1 then go to colorloop

	;-----Set bitplane pointers in bplcop---
	lea.l	bplcop,a2			; write bplcop address into a2
	addq.l	#2,a2				; add two bytes so a2 can set BPL1PTH
	move.l	a1,d1				; move a1 (points to screen data) into d1
	moveq	#4,d0				; set bitplane counter to 4

bplcoploop:
	swap	d1					; perform swap of words 
	move.w	d1,(a2)				; move bit 0-15 into what a2 points to (sets BPLxPTH)
	addq.l	#4,a2				; make a2 point to indput for PBLxPTL    
	swap	d1					; perform swap of words
	move.w	d1,(a2)				; move bit 0-15 into what a2 points to (sets BPLxPTL)
	addq.l	#4,a2				; make a2 point to the next BPLxPTH input
	add.l	#10240,d1			; make d1 point to next bitplane
	dbra	d0,bplcoploop		; decrement d0. if > -1 goto bplcoploop

	;-----Start copper---
	lea.l	copper,a1			; put address of copper into a1
	move.l	a1,$dff080			; set COP1LCH and COP1LCL to address in a1
	move.w	$dff088,d0			; start copper by read of strobe address COPJMP1

	move.w	#$8580,$dff096		; DMACON set BLTPRI, PBLEN, COPEN

	bsr	readmouse				; read mouse coordinates to determine blit area
	bsr	storeback				; store background to blit in backbuffer

mainloop:
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 poositions
	and.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0
	bne	mainloop				; if not at line 300 goto mainloop

	bsr	recallback				; recall blitted background from backbuffer
	bsr	readmouse				; read mouse coordinates to determine blit area
	bsr	storeback				; store background to blit in backbuffer
	bsr	shiftblit				; blit pixelwise horisontal
	bsr	blitin					; do the actual blit using cookie-cut

	btst	#6,$bfe001			; CIAAPRA FIR0 check mouse button
	bne	mainloop				; if not pressed goto mainloop

	move.w	#$0080,$dff096		; DMACON clear copper

	move.l	$4,a6				; reestablish DMA's and copper
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096
	move.w	#$0400,$dff096

	move.w	#$c000,$dff09a
	rts							; return from mainloop

	;-----blitin is blitting in the data from A, B, and C into D 
	;-----using the cookie-cut logic function
blitin:
	lea.l	maskbuffer,a1		; store maskbuffer address in a1
	lea.l	backbuffer,a3		; store backbuffer address in a3
	lea.l	figbuffer,a2		; store figbuffer address in a2
	lea.l	screen,a4			; store screen in a4
	add.l	#64,a4				; skip first 64 bytes of color data

	lea.l	mousex,a0			; store mousex address in a0
	move.l	(a0),d0				; move mousex value into d0
	lea.l	mousey,a0			; store mousey address in a0
	move.l	(a0),d1				; move mousey value into d1

	;-----find first blit position
	lsr.l	#4,d0				; mouse x shift right 4 bits  
	lsl.l	#1,d0				; mouse x shift left 1 bit
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a4				; add mousex to screen address in a1
	add.l	d1,a4				; add mousey to a1

	moveq	#4,d7				; initialize loop counter (5 bitplanes)
		
blitinloop:
	btst	#6,$dff002          ; wait for blitter
	bne	blitinloop

	move.l	a4,$dff054			; BLTDPTH and BLTDPTL points to screen
	move.l	a1,$dff050          ; BLTAPTH and BLTAPTL points to maskbuffer
	move.l	a2,$dff04c          ; BLTBTPH and BLTBPTL points to figbuffer
	move.l	a3,$dff048          ; BLTCPTH and BLTAPTL points to backbuffer
	move.w	#32,$dff066         ; BLTDMOD set modulus to 32 bytes on D 40-(64/8)
	move.w	#0,$dff064          ; BLTAMOD set modulus to 0 bytes on A
	move.w	#0,$dff062          ; BLTBMOD set modulus to 0 bytes on B
	move.w	#0,$dff060          ; BLTCMOD set modulus to 0 bytes on C
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$0fca,$dff040      ; BLITCON0 use A,B,C, and D, with cookie-cut
	move.w	#$0000,$dff042      ; BLITCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words (64 pixels)

	add.l	#360,a2             ; point to next bitpane in figbuffer
	add.l	#360,a3             ; point to next bitplane in backbuffer
	add.l	#10240,a4           ; point to next bitplane in screen

	dbra	d7,blitinloop       ; if d7 > -1 goto blitinloop
	rts                         ; return from blitin

	;----shiftblit enables us to blit 
	;----pixelwise instead of wordwise horizontal
shiftblit:
	lea.l	fig,a1				; put fig address into a1
	lea.l	figbuffer,a2		; put figbuffer address into a2

	lea.l	mousex,a0			; put mousex address into a0
	move.l	(a0),d1				; put mousex value into d1

	;-----preparing a value for BLTCON0 by first setting up
	;-----the shift value (byte 12-15) and then use A and D
	;-----with the logic function D=A
	andi.l	#$f,d1				; clear all but first byte of mousex in d1
	lsl.l	#8,d1				; shift left 8 bits (max allowed)
	lsl.l	#4,d1				; shift left another 4 bits
	add.w	#$09f0,d1			; value for using A and D with logic function D=A

	moveq	#4,d7				; intialize loop counter (5 bitplanes)

shiftfigloop:
	btst	#6,$dff002			; wait for blitter to finish
	bne	shiftfigloop

	move.l	a2,$dff054          ; set BLTDPTH and BLTDPTL to figbuffer
	move.l	a1,$dff050          ; set BLTAPTH and BLTAPTL to fig
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	d1,$dff040          ; BLTCON0 see above for settings
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words (64 pixels)

	add.l	#360,a1             ; point to next bitplane in fig
	add.l	#360,a2             ; point to next bitplane in figbuffer

	dbra	d7,shiftfigloop     ; if d7 > -1 goto shiftfigloop

	lea.l	mask,a1             ; put mask address into a1
	lea.l	maskbuffer,a2       ; put maskbuffer address into a2

shiftmaskloop:
	btst	#6,$dff002          ; wait for blitter (BLTSIZE triggers the blitter)
	bne	shiftmaskloop

	move.l	a2,$dff054          ; set BLTDPTH and BLTDPTL to maskbuffer
	move.l	a1,$dff050          ; set BLTAPTH and BLTAPTL to mask
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	d1,$dff040          ; BLTCON0 see above for settings
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels

	rts                         ; return from shiftblit

	;-----subroutine read mouse x, y---
	;-----store result in mousex and mousey---
readmouse:
	move.w	$dff00a,d0			; move JOY0DAT into d0
	move.l	d0,d1				; move d0 value into d1
	lsr.w	#8,d1				; shift right 8 bits
	andi.l	#$ff,d0				; clean with and - d0 holds mouse x value
	andi.l	#$ff,d1				; clean with and - d1 holds mouse y value

	lea.l	mousex,a1			; store mousex result address into a1
	move.l	d0,(a1)				; write mouse x value into result address
	lea.l	mousey,a1			; same stuff for mouse y
	move.l	d1,(a1)

	rts							; return from readmouse

	;-----Store screen in backbuffer---
storeback:
	lea.l	screen,a1			; store screen address in a1
	add.l	#64,a1				; move address past color data
	lea.l	backbuffer,a2		; store backbuffer address in a2

	lea.l	mousex,a0			; store mousex address in a0
	move.l	(a0),d0				; move mouse x value into d0
	lea.l	mousey,a0			; store mousey address in a0
	move.l	(a0),d1				; move mouse y value into d1

	;-----find first blit position
	lsr.l	#4,d0				; mouse x shift right 4 bits 
	lsl.l	#1,d0				; mouse x shift left 1 bit
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a1				; add mousex to screen address in a1
	add.l	d1,a1				; add mousey to a1

	moveq	#4,d7				; initializer loop counter (5 bitplanes)

storebackloop:
	btst	#6,$dff002          ; wait for blitter
	bne	storebackloop

	move.l	a2,$dff054			; set BLTDPTH and BLTDPTL to backbuffer
	move.l	a1,$dff050			; set BLTAPTH and BLTAPTL to mouse pos on screen
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#32,$dff064         ; set BLTAMOD modulus to 32 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$09f0,$dff040      ; BLTCON0 use A and D, set logic function D=A
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels

	add.l	#10240,a1           ; point to next bitplane in screen
	add.l	#360,a2             ; point to next bitplane in backbuffer (45 * 8 bytes)

	dbra	d7,storebackloop	; if d7 > -1 goto storebackloop
	rts                         ; return from storeback

	;-----Write backbuffer to screen
recallback:
	lea.l	screen,a1			; store screen address in a1
	add.l	#64,a1				; move address past color data
	lea.l	backbuffer,a2		; store backbuffer address in a2

	lea.l	mousex,a0			; store address of mousex in a0
	move.l	(a0),d0				; move mousex value into d0
	lea.l	mousey,a0			; store address of mousey in a0
	move.l	(a0),d1				; move mousey value into d1 

	;-----find first blit position
	lsr.l	#4,d0				; mouse x is shifted 4 bits right  
	lsl.l	#1,d0				; mouse x is shifted 1 bit left
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a1				; add mousex to screen address in a1
	add.l	d1,a1				; add mousey to a1

	moveq	#4,d7				; initialize counter for the loop (5 bitplanes)

recallbackloop:
	btst	#6,$dff002          ; wait for blitter
	bne	recallbackloop          
                            
	move.l	a1,$dff054          ; set BLTDPTH and BLTDPTL to mouse pos on screen
	move.l	a2,$dff050          ; set BLTAPTH and BLTAPTL to backbuffer
	move.w	#32,$dff066         ; set BLTDMOD modulus to 32 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM mask for A
	move.w	#$09f0,$dff040      ; BLTCON0 use A and D, set logic function D=A
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels
                            
	add.l	#10240,a1           ; point to next bitplane in screen
	add.l	#360,a2             ; point to next bitplane in backbuffer (45 * 8 bytes)

	dbra	d7,recallbackloop   ; if d7 > -1 goto recallbackloop
	rts                         ; return from recallback

	copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$5200			; (move) set BPLCON0 use 5 bitplanes, enable color burst

	bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL
	dc.w	$00e4,$0000			; BPL2PTH
	dc.w	$00e6,$0000			; BPL2PTL
	dc.w	$00e8,$0000			; BPL3PTH
	dc.w	$00ea,$0000			; BPL3PTL
	dc.w	$00ec,$0000			; BPL4PTH
	dc.w	$00ee,$0000			; BPL4PTL
	dc.w	$00f0,$0000			; BPL5PTH
	dc.w	$00f2,$0000			; BPL5PTL

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait < $ff horiz
	dc.w	$2c01,$fffe			; wait($01,$12c) for PAL
	dc.w	$0100,$0200			; (move) set BPLCON0 disable bitplanes
								; needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	12816,0				; allocate 64 + 320/8*256*5 = 51264 bytes = 12816 longs

fig:
	blk.l	450,0				; 45 lines * 64 pixels * 5 bitplanes = 14400 bits = 450 longs

mask:
	blk.l	90,0				; allocate 45 lines * 64 pixels = 2880 bits = 90 longs

figbuffer:
	blk.l	450,0

maskbuffer:
	blk.l	90,0

backbuffer:
	blk.l	450,0

mousex:
	dc.l	0
mousey:
	dc.l	0

Überschrift: Shiftblit-Unterroutine

Bisher haben wir ein Objekt geblittet, das vertikal auf dem Bildschirm
scrollte. Diese einfache Animation wurde durch Verschieben der Startadresse
des Blit auf dem Bildschirm erreicht.

Da wir jedoch jetzt die Maus als Bewegungseingabe verwenden, sind wir
gezwungen, auch horizontale Bewegungen in Betracht zu ziehen. Dies stellt ein
Problem dar, da der Beginn des Blit immer als Adresse angegeben wird. Wenn wir
es dabei belassen würden, würden wir eine sehr klobige Bewegung bekommen, indem
wir das Blitter-Objekt nach einem Zeitpunkt nach Worten bewegen.

Was wir wollen, ist, das Blitter-Objekt zu verschieben, indem wir ein paar
Pixel und nicht ganze Wörter blitten. Um dies zu erreichen, verwenden wir die
Verschiebungswerte in BLTCON0, die im d1-Register in der shiftblit-Unterroutine
gespeichert sind.

Um mehr über pixelweise horizontale Bewegung zu lesen, werfen Sie einen Blick
auf die Amiga Hardware Reference Manaual. Sie haben ein Beispiel für ein
animiertes Auto, das die Straße hinunterfährt.

Auch, wenn Sie einige Probleme haben, die Unterschiede zwischen logischen und
arithmetischen Verschiebeoperationen zu verstehen, wie LSL und ASL, dann werfen
Sie einen Blick auf dieses Youtube-Video von Padraic Edgington.

Ein Leser schrieb, dass er ein wenig Probleme damit hatte, etwas anderes als
einen Donut zu blitten. Glücklicherweise kann es getan werden - lesen Sie hier:
Erstellen Sie Ihre eigenen grafischen Assets

weblinks:
https://archive.org/details/Amiga_Machine_Language_1991_Abacus/page/n59
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n143
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n89
https://www.youtube.com/watch?v=rJfiD67D5VI

;------------------------------------------------------------------
20 - Make Your Own Graphic Assets

Erstellen Sie Ihre eigenen grafischen Assets
14. Juli 2020  8 Minuten lesen
Amiga-Maschinencode - Buchstabe VI - Bonusmaterial

Der Amiga Machine Code Course enthält viele Beispiele mit Grafiken, aber wir
haben nie unsere eigenen Grafiken erstellt. In diesem Beitrag werden wir dies
ausgleichen, indem wir zeigen, wie Sie benutzerdefinierte Grafiken erstellen
und in einem Format speichern, das mit den Programmbeispielen funktioniert.
Lasst uns anfangen!

Dieser Beitrag ist eine Fortsetzung von Amiga Machine Code Letter VI -
Blitter 3.

Überschrift: Die Werkzeugkette

Wie immer berücksichtige ich gerne Tools, die zur Zeit der Kurserstellung
verfügbar waren. In diesem Fall ist das Jahr 1989 und Deluxe Paint III war
damals das unangefochtene Zeichenprogramm. Deluxe Paint wurde von Dan Silva
entwickelt, zunächst als hauseigenes Produkt bei EA, genannt Prism. Da immer
mehr Funktionen hinzugefügt wurden, wurde die Marktfähigkeit erhöht und voila,
Deluxe Paint war geboren.

Es gibt eine schöne Hommage-Seite zu Deluxe Paint drüben im Computer History
Museum. Die Seite enthält auch ein Handbuch und eine Referenzkarte, aber
besonders cool ist das Video, Profesional Techniques for Deluxe Paint III,
bei dem mir klar wurde, dass ich damals ein n00b im Umgang mit dem Programm
war. Das Video ist auch mit Kommentaren von Dan Silva gespickt.

Abbildung 20-01: Tolles Video.

Deluxe Paint III war auch der letzte in der Serie, an der Dan Silva arbeitete,
bevor er EA verließ, um an 3D Studio zu arbeiten – hergestellt von der Yost
Group, die 1997 die Rechte an AutoDesk verkaufte.

Das zweite Programm in unserer Toolchain ist Deluxe IFF Converter 1.0,
geschrieben von Christian Haller. Das Programm zeichnet sich durch die
Konvertierung von IFF in RAW und RAW in IFF aus, was genau das ist, was wir
brauchen. Das Programm ist auf DISK1 im Ordner c verfügbar und heißt IFFCon.

Christian Haller, hat eine Reihe von Tools und Spielen entwickelt, von denen
viele auf seiner Homepage aufgeführt sind. Einige davon sind auf seinem
Youtube-Kanal zu sehen. Er führt IFFCon zwar nicht als eines seiner Tools auf,
aber ich denke, seine Liste ist unvollständig, da er auch seinen
Insanity-Fight-Editor nicht erwähnt. Übrigens. die Assembler-Quelle für
Insanity Fight kann auf seiner Seite heruntergeladen werden! Nun, das ist eine
Geschichte für einen anderen Tag.

Unsere Toolchain besteht also aus Deluxe Paint III - aka. dpaint und IFFCon.
Diese Toolchain ermöglicht es uns, von IFF in RAW zu konvertieren, was wir
benötigen, um unsere Grafiken von dpaint in ein Format zu konvertieren, das
unser Programm lesen kann. Wir müssen jedoch auch von RAW in IFF konvertieren,
da wir, wie wir gleich sehen werden, eine Farbpalette in dpaint bekommen
müssen.

Abbildung 20-02: Amiga-Toolchain

Ich habe einige der Disketten im obigen Diagramm weggelassen. Der Kern
besteht darin, dass Dateien verwendet werden, um Daten zwischen DPaint und
IFFCon zu übertragen.

Bevor wir weitermachen - schauen wir uns das Endergebnis an. Der Donut wurde
durch einige Quadrate ersetzt.

Abbildung 20-03: Endergebnis

Lassen Sie uns nun die schmutzigen Details durchgehen.

Überschrift: Übertragen der Palette auf DPaint

Da unser Ziel darin besteht, mc0602 mit den neuen Grafiken zum Laufen zu
bringen, müssen wir berücksichtigen, dass alle Farben aus der Bildschirmdatei
stammen. Irgendwie müssen diese Farben in dpaint eingelesen werden, damit wir
mit derselben Palette neue Grafiken erstellen können.

Die Bildschirmdatei kann nicht direkt in dpaint eingelesen werden, da sie im
RAW-Format gespeichert ist. Wir können dies leicht beheben, indem wir IFFCon
verwenden, um das Bild von RAW in IFF zu konvertieren. Hier hilft es
aufzulisten, was wir über die Bildschirmdatei wissen:

Es hat ein Auflösung von 320 x 256 Pixel
Es hat 5 Bitplanes
Es hat 32 Farben, die am Anfang der Datei gespeichert sind

Verwenden Sie nun die CLI, um IFFCon zu starten, das Sie im c-Ordner von DISK1
zu finden ist. Gehen Sie in das Menü Other/colormap und wählen Sie before Pic.
Dies teilt IFFCon mit, wo nach der Colormap gesucht werden soll. Als nächstes
gehen Sie in das Menü Project/Load und wählen Bitmap, wodurch ein Dialog
geöffnet wird.

Abbildung 20-04: IFFCon-Ladebildschirm

Füllen Sie die Details aus. Setzen Sie die Breite auf 320, die Höhe auf 256 und
PL (bitPLanes) auf 5. Geben Sie zu guter Letzt an, wo sich die Bildschirmdatei
befindet. Die Datei sollte nun in IFFCon korrekt angezeigt werden.

Speichern Sie anschließend die Datei als IFF über das Menü Project/Save
und wählen Sie Bitmap. Es erscheint ein Speichern-Dialog. Geben Sie der Datei
einen Namen - ich habe sie SCREEN_ORG genannt und drücke den Speichern-Button.

Abbildung 20-05: IFFCon-Speicherbildschirm

Jetzt haben wir eine Bilddatei, die dpaint lesen kann.

Öffnen Sie dpaint und wählen Sie das Standard-Bildschirmformat (Lo-Res 320x200)
und 32 Farben. Beachten Sie nicht, dass die Auflösung falsch ist. Über das Menü
Picture wählen Sie Load und laden die Datei SCREEN_ORG. Antworten Sie mit Ja,
wenn dpaint fragt, ob Sie das Format in das der Datei ändern möchten.

Wir haben nun das Bild geladen und dabei auch die Palette so modifiziert, dass
sie mit der in der Bildschirmdatei übereinstimmt. Wir können jetzt anfangen,
ein paar Kunstwerke zu machen!

Überschrift: Grafiken erstellen

In dpaint müssen Sie mit der richtigen Palette zunächst das Bild löschen, damit
wir von vorne beginnen können. Der Einfachheit halber gehe ich davon aus, dass
das neue Kunstwerk die gleichen Abmessungen wie der alte Donut hat, den wir
ersetzen. Sonst müsste ich das Programm mc0602 umschreiben. Hier ist, was wir
über den Donut BOB wissen.

Es wird in zwei Dateien gespeichert	; FIG und MASKE
FIG hat 5 Bitebenen
MASK hat 1 Bitplane
Sowohl FIG als auch MASK haben eine Auflösung von 64 x 45 Pixel.

Die Grafiken, die ich erstellt habe, sind nur ein paar Quadrate, die einem
8 x 8-Raster zugeordnet sind, das durch 0,0 geht. Auf diese Weise kann ich
leicht sicherstellen, dass die Zeichnung innerhalb der 64 x 45-Pixel-Grenze
liegt.

Abbildung 20-06: dpaint machen BOB

Als nächstes speichere ich das Bild über das Menü Picture und wähle Save. Ich
habe ihm den Dateinamen FIG2_ORG gegeben.

Bevor wir dpaint beenden, sollten wir auch eine Maske erstellen. Dies kann
erreicht werden, indem das vorhandene Bild beibehalten wird, jedoch nur
1 Bitebene verwendet wird. Wählen Sie im Menü Picture Screen Format...
und stellen Sie die Anzahl der Farben auf 2 ein, dann drücken Sie Ok.

Abbildung 20-07: dpaint Maske machen

Voila, du hast jetzt eine Maske gemacht. Speichern Sie das Bild - ich habe ihm
den Dateinamen MASK2_ORG gegeben. Die Maske teilt dem Blitter mit, welche Pixel
transparent sind, indem sie die Cookie-Cut-Funktion verwendet.

Der letzte Schritt besteht darin, FIG2_ORG und MASK2_ORG mithilfe von IFFCon in
RAW Daten zu konvertieren. Öffnen Sie IFFCon und laden Sie FIG2_ORG als IFF.
Verwenden Sie dann das Menü Other/Colormap und wählen Sie "no cmap". Wir
brauchen keine Colormap, da diese aus der Bildschirmdatei geholt wird.

Verwenden Sie das Menü Project/Save und wählen Sie Bitmap und nennen Sie
die Datei FIG2, dann drücken Sie die Schaltfläche "frame+save".

Abbildung 20-08: IFFCon-Dialog zum Speichern von fig2

Zeichnen Sie einen Rahmen von (0,0) bis (64,45). Dadurch wird nur der Teil des
Bildes gespeichert, der sich innerhalb des Rahmens befindet.

Abbildung 20-09: IFFCon fig2-Rahmen speichern

Um zu überprüfen, ob es gut gelaufen ist, versuchen Sie es erneut als Bitmap
mit Breite 64, Höhe 45 und 5 Bitebenen zu laden. Die Farben sind aus, da es
keine Colormap gibt, aber das ist kein Problem.

Führen Sie die gleiche Konvertierung von IFF in RAW für die MASK2_ORG-Datei
durch, und Sie können das neue Bildmaterial verwenden.

Sie können das mc0602- Programm kompilieren, indem Sie den Anweisungen in
Amiga Machine Code Letter VI - Blitter 3 folgen und die Dateinamen fig und mask
durch fig2 und mask2 ersetzen.

Überschrift: Das Vermächtnis der Deluxe-Paint

Deluxe Paint war DAS Malprogramm auf dem Amiga. Es hat ein weites Erbe und war
für viele eine Inspiration. Das Bushy Tree-Diagramm, das ich kürzlich
kennengelernt habe, listet Deluxe Paint sogar als den Vorgänger von Photoshop
auf. Ich konnte keine Bestätigung dafür finden, von Thomas Knoll oder John
Knoll, den Brüdern, die Photoshop geschaffen haben. Aber wenn man bedenkt, wie
riesig Deluxe Paint war, muss es so gewesen sein.

Eine Sache, die für mich in den 80er Jahren wirklich zauberhaft war, war der
Farbwechsel, bei dem die Palette über einen festen Bereich animiert werden
konnte. Dieser Effekt konnte ein ansonsten stehendes Bild animiert erscheinen
lassen.

Ein Künstler, der Color Cycling auf die nächste Stufe gehoben hat, ist Mark
Ferrari, der Schöpfer einiger sehr großen Spiele auf dem Amiga, die alle in
Deluxe Paint erstellt wurden. Es gibt eine sehr schöne HTML5-Simulation des
Farbwechsels mit seinem Artwork, die einen Besuch wert ist. Mark Ferrari hat 
wie Dan Silva bei Lucasfilm gearbeitet.

Als ich mir das obige Deluxe Paint-Anleitungsvideo ansah, bemerkte ich, dass
Dan Silva vielleicht von Deluxe Paint wegging. Gegen 17:34 sagt er:

Was mich wieder für die Arbeit an Deluxe Paint interessierte, war die Idee, wie
es wäre, ein Malprogramm zu haben, mit dem man einzelne Frames einer
Animation malen könnte.

Dan Silva brauchte eineinhalb Jahre Arbeit, um die Animationsfunktionen zu
programmieren, um Deluxe Paint III zu entwickeln. Seine letzte Arbeit an
Deluxe Paint, bevor er EA verließ.

Es macht Spaß, wie eine Erweiterung eines Tools, wie die Animation eines 
Malprogramms, weitreichende Konsequenzen haben kann. Drüben in Großbritannien
konnte sich eine Gruppe von Jungs nicht auf die richtige Größe für kleine
Männer in einem Spiel einigen. Mike Dailly sagte, dass 8 x 8 Pixel ausreichen,
und sie bewiesen es, indem sie es in Deluxe Paint animierten. Es hat großen
Spaß gemacht und sie haben auch kleine Fallen animiert - und so wurde das
äußerst beliebte Spiel Lemmings geboren. Lesen Sie mehr darüber in Jimmy Mahers
Blog The Digital Antiquarian.

Bis heute wird Deluxe Paint von Enthusiasten auf der ganzen Welt verwendet.
Hier ist ein Beispiel vom Kunstkollektiv Shynola - ein Musikvideo animiert
in Deluxe Paint! Junior Senior - Bewege deine Füße.

weblinks:
https://computerhistory.org/blog/electronic-arts-deluxepaint-early-source-code/
https://en.wikipedia.org/wiki/Newbie
http://dallashodgson.info/articles/dpaint.htm
https://www.linkedin.com/in/dan-silva-350ba8b
http://amiga.haller.ch/
https://www.youtube.com/channel/UCJZdv6VBdj37TSjQAjUUy4g
https://wiki.c2.com/?BushyTreeDiagram
https://www.markferrari.com/about
http://www.effectgames.com/demos/canvascycle/
https://en.wikipedia.org/wiki/Mike_Dailly_%28game_designer%29
http://www.shynola.com/jrsr_move_your_feet.html
https://youtu.be/SPlQpGeTbIE

;------------------------------------------------------------------------------
21 - Amiga Machine Code Letter VII - Blitting and Scrolling

Amiga Maschine Code Letter VII - Blitting und Scrolling
17.04.2019  10 min lesen

Wir haben Brief VII des Amiga Machine Code Kurses erreicht. Es hat eine Weile
gedauert, hier her zu kommen.

In diesem Beitrag werden wir eine weitere Runde mit dem Blitter nehmen. Dieses
Mal, um zu zeigen, wie Scrolling funktioniert! Es gibt ein paar Konzepte, die
ein wenig schwer zu verstehen sind, aber der Brief macht einen tollen Job bei
der Erklärung. Allerdings gibt es einige dunklere Flecken, also lassen Sie uns
eintauchen!

Überschrift: Absteigender Modus

Bisher haben wir den Blitter nur im aufsteigenden Modus verwendet. Wir haben
separate Speicherbereiche in das Ziel - den Bildschirmspeicher - geblittet.

Dieses Mal werden wir jedoch vom Bildschirm auf den Bildschirm blitten. Wenn
sich Quelle und Ziel überschneiden, laufen wir Gefahr, Daten zu überschreiben,
bevor der Blitter die Möglichkeit hatte, sie an das Ziel zu kopieren.

Im Buch Mapping the Amiga gibt es ein einfaches Beispiel dafür, wie eine solche
Datenüberschreibung passieren könnte.

Angenommen, der Speicherort 102 enthält einen $FEDC, und der Speicherort 104
enthält einen $BA98. Wenn Sie diese beiden Wörter in die Positionen 104 und 106
kopieren möchten, nimmt der Blitter zuerst die $FEDC von 102 und verschiebt sie
in 104. Wenn es dann das Wort in 104 verschieben möchte, würde es $FEDC finden
und nicht $BA98, da dieses Wort durch den ersten Move Operation zerstört worden
war.

Abbildung 21-01: data loss

Um Datenverlust zu vermeiden, kann der Blitter im absteigenden Modus ausgeführt
werden, wo er umgekehrt arbeitet. Es beginnt am Ende und arbeitet zurück zum
Anfang der Quelle und Ziel. Der Absteigende Modus wird aktiviert, indem Bit 1
des BLTCON1-Registers gesetzt wird.

Schauen wir uns das Beispiel noch einmal an, jetzt mit aktiviertem
Absteigendmodus (descending mode).

Beginnen Sie mit dem letzten Wort der Quelle, und blitte es zum letzten Wort
des Ziels. 

Abbildung 21-02: Descending mode step 1

Fahren Sie rückwärts fort, bis der Anfang der Quelle erreicht ist, und blitten
es ins erste Wort des Ziels. 

Abbildung 21-03: Descending mode step 2

Voila! Es gingen keine Quelldaten verloren.

Mapping the Amiga bietet die folgende Regel für die Auswahl zwischen
aufsteigendem und absteigendem Modus.

Wenn das Ende der Quelle den Anfang des Ziels überlappt, verwenden Sie den
absteigenden Modus. Wenn der Anfang der Quelle das Ende des Ziels überlappt,
verwenden Sie den aufsteigenden Modus. Wenn sich Quelle und Ziel überhaupt
nicht überlappen, verwenden Sie bitte einen der beiden Modi.

In der Abbildung unten überlappt das Ende der Quelle den Anfang des Ziels.
Verwenden Sie in diesem Fall den absteigenden Modus.

Abbildung 21-04: Descending rule

In der Abbildung unten überlappt der Anfang der Quelle das Ende des Ziels.
Verwenden Sie in diesem Fall den aufsteigenden Modus.

Abbildung 21-05: Ascending rule

Im absteigenden Modus wird das Modulo von BLTxMOD subtrahiert und nicht
hinzugefügt. Auch das Verschieben arbeitet umgekehrt, so dass die in BLTCON0
und BLTCON1 definierten Verschiebungen nach links und nicht nach rechts
erfolgen.

Wie wir später sehen werden, ermöglicht das Verschieben nach links das
Scrollen von Text von rechts nach links.

Überschrift: Ein einfacher Textscroller

Die erste Codeliste, mc0701, in Brief VII, zeigt, wie man einen einfachen
Text-Scroller macht. Der Code wird mithilfe von Unterroutinen organisiert,
aber ab und zu erscheinen gelegentlich magische Zahlen, die den Code ein
wenig schwer lesbar machen.

Der Brief macht eine gute Arbeit der Erklärung des Codes, so werde ich nur
Erläuterungen zu dem, was ich ein wenig trübe gefunden habe hinzufügen.

Beginnen wir mit einem Screenshot des Programms in Aktion.

Abbildung 21-06: Screenshot mc0701

Überschrift: Was für eine Schriftart!

Die Zeichen in der Schriftart sind alle 20 Zeilen hoch und 16 Pixel breit. Da
jedoch nicht jedes Zeichen die gleiche Breite hat, erhalten wir einige eher
unattraktive Lücken im Textabstand. Schauen Sie sich einfach die Lücke zwischen
"I" und "G" an, wenn Sie "AMIGA" im Screenshot oben buchstabieren.

Eine der Übungen im Brief besteht darin, zeichenabhängige Schriftbreiten 
einzuführen.

Die Schriftart wird in einer Binärdatei gespeichert, die als font (Schriftart)
bezeichnet wird, und enthält 32 Zeichen, einschließlich Komma, Satzzeichen
und Leerzeichen. Die Schriftart wird als Bitmap von 512 * 20 in einer
Bitebene gespeichert.

Abbildung 21-07: Font set

Der Screenshot des Schriftart-Satzes wird mit IFFCon erstellt. Das Programm 
befindet sich auf disk1 im Ordner c.

Starten Sie IFFCon über die CLI. Drücken Sie in IFFCon die rechte Maustaste und
wählen Sie Bitmap aus dem Projektmenü laden. Im Pop-up Type in 512 als Breite,
20 als Höhe und 1 Bitplane. Speicherort des Assets auf meinem System ist 
amigahd:disk1/brev07/font

Überschrift: Machen Sie es scrollen

Das Scrollen erfolgt, indem die Zeichen in den Speicher übertragen und dann
nach links verschoben werden. Daher müssen wir im absteigenden Modus blitten,
um den Text von rechts nach links zu scrollen.

Der Bildschirmspeicher ist so eingerichtet, wie wir ihn noch nicht gesehen
haben. Der sichtbare Bildschirm ist 22 Wörter mal 256 Zeilen,
d.h. 353 * 256 Pixel. Wir setzen das Bitplane-Modulo auf 2, so dass jede
Zeile am Ende 16 Pixel hat, die nicht sichtbar sind. Hier platzieren wir die
zu scrollenden Zeichen und verschieben sie dann nach links in den sichtbaren
Bildschirm. Dadurch wird es so aussehen, als würden die Zeichen in den
Bildschirm fließen.

Abbildung 21-08: Screen area

Im Code haben wir einige magische Zahlen. Zwei davon sind Punkt A und B,
die in der Abbildung oben dargestellt sind.

Punkt A definiert den Offset vom Anfang des Bildschirms, in dem die
Grafikzeichen aus der Schriftart geschrieben werden sollen. Die Zeichen
sind alle 20 Zeilen hoch und 16 Pixel breit (1 Wort). Wir beginnen, das
Zeichen in der 150. Zeile am Anfang von Wort 23 (Byte 44) zu schreiben.

Punkt A: 46 * 150 + 44 = 6944

Da der Blitter auf den decending modus eingestellt ist, müssen wir ihm einen
Zeiger auf die letzte zu blittende Adresse zur Verfügung stellen. Punkt B
definiert den Offset vom Anfang des Bildschirms und wird am Ende der letzten
Zeile gesetzt, in der wir das Zeichen platziert haben.

Punkt B: 46 * (150 + 20) = 7820

Das Programm, mc0701, ist ziemlich einfach, sobald das oben gesagte
verstanden wird. Hier ist der Quellcode

; file mc0701.s
	move.w	#$4000,$dff09a      ; INTENA clear master interupt
	;-----stop disk drives---
	or.b	#%10000000,$bfd100  ; set CIABPRB MTR
	and.b	#%10000111,$bfd100  ; clr CIABPRB SEL3, SEL2, SEL1, SEL0

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter
	;-----Setup bitplanes, display and DMA data fetch. Resolution 352*256 with 1 bitplane
	move.w	#$1200,$dff100		; BPLCON0 use 1 bitplanes (2 colors)
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$0000,$dff104		; BPLCON2 video
	move.w	#$0002,$dff108		; BPL1MOD modulus odd planes
	move.w	#$0002,$dff10a		; BPL2MOD modulus even planes
	move.w	#$2c71,$dff08e		; DIWSTRT upper left corner ($71,$2c)
	move.w	#$f4d1,$dff090		; DIWSTOP enaple PAL trick
	move.w	#$38d1,$dff090		; DIWSTOP lower right corner ($1d1,$12c)
	move.w	#$0030,$dff092		; DDFSTRT data fetch start at $30
	move.w	#$00d8,$dff094		; DDFSTOP data fetch stop at $d8
	;-----set BPL1PTH/BPL1TPL in bplcop---
	lea.l	screen,a1			; write screen address into a1
	lea.l	bplcop,a2			; write bplcop address into a2
	move.l	a1,d1				; move a1 to d1
	swap	d1					; swap words
	move.w	d1,2(a2)			; write first word into a2+2 (BPL1PTH)
	swap	d1					; swap words
	move.w	d1,6(a2)			; write first word into a2+6 (BPL1PTL)
	;-----setup copper---
	lea.l	copper,a1			; put address of copper into a1
	move.l	a1,$dff080			; set COP1LCH and COP1LCL to address in a1
	move.w	#$8180,$dff096		; DMACON set PBLEN, COPEN

mainloop:
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 poositions
	and.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0    
	bne	mainloop				; if not at line 300 goto mainloop

	bsr	scroll					; scroll letters

	btst	#6,$bfe001			; CIAAPRA FIR0 check mouse button
	bne	mainloop				; if not pressed goto mainloop

	move.w	#$0080,$dff096 ; DMACON clear copper
	;-----reestablish DMA's and copper---
	move.l	$04,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts							; return from mainloop

scrollcnt:
	dc.w	$0000

charcnt:
	dc.w	$0000
	;-----scroll subroutine---
	scroll:
	lea.l	scrollcnt,a1		; move scrollcnt address into a1
	cmp.w	#8,(a1)				; compare scrollcnt with 8
	bne	nochar					; if not equal goto nochar

	clr.w	(a1)				; set scrollcnt to 0

	lea.l	charcnt,a1			; move charcnt address into a1
	move.w	(a1),d1				; move charcnt value into d1
	addq.w	#1,(a1)				; add 1 to charcnt value - d1 unaffected

	lea.l	text,a2				; move text address into a2
	clr.l	d2					; set d2 to 0 - d2 points to current char
	move.b	(a2,d1.w),d2		; move value in address text+charcnt into d2

	cmp.b	#42,d2				; check if d2 equals 42 (termination sign "*")
	bne	notend					; if not equal goto notend

	clr.w	(a1)				; set charcnt to 0
	move.b	#32,d2				; move 32 into d2 (space " " = 32)

notend:
	lea.l	convtab,a1			; move address of char convertion table into a1
	move.b	(a1,d2.b),d2		; d2 is an offset in the table. Store result in d2
	asl.w	#1,d2				; multiply d2 by two - font is 2 bytes wide - 16 pixels

	lea.l	font,a1				; move font address into a1
	add.l	d2,a1				; add offset d2 to a1 so it points to current letter

	lea.l	screen,a2			; move screen address into a2
	add.l	#6944,a2			; 46 * 150 + 44

	moveq	#19,d0				; use d0 as counter. Font is 20 lines heigh

putcharloop:					; loop over each horiz line in font
	move.w	(a1),(a2)			; move 16 pixels of current letter into a2
	add.l	#64,a1				; go to next line in current letter font
	add.l	#46,a2				; go to the next line on screen
	dbra	d0,putcharloop		; if d0 > -1 goto putcharloop

nochar:
	btst	#6,$dff002			; DMACONR test bit 6 BLTEN
	bne	nochar					; if blitter enabled goto nochar

	lea.l	screen,a1			; move screen address into a1
	add.l	#7820,a1			; add 46*(150+20) end of line 170
	; setup blitter
	move.l	a1,$dff050          ; BLTAPTH and BLTAPTL set to end of line 170
	move.l	a1,$dff054          ; BLTDPTH and BLTDPTL set to end of line 170
	move.w	#0,$dff064          ; BLTAMOD set modulo to 0 bytes on A
	move.w	#0,$dff066          ; BLTDMOD set modulo to 0 bytes on D
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$29f0,$dff040      ; BLTCON0 shift two bits on A, use A,D with D=A
	move.w	#$0002,$dff042      ; BLTCON1 enable decending mode
	move.w	#$0517,$dff058      ; BLTSIZE height 20 lines, width 23 words. 20 * 64 + 23

	lea.l	scrollcnt,a1        ; move scrollcnt address into a1
	addq.w	#1,(a1)             ; add 1 to scrollcnt value

	rts							; return from scroll subroutine

copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$1200			; BPLCON0 use 1 bitplane, enable color burst

bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$0ff0			; COLOR01 yellow

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait < $ff horiz
	dc.w	$2c01,$fffe			; wait($01,$12c) for PAL
	dc.w	$0100,$0200			; (move) set BPLCON0 disable bitplanes needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	$b80,0

font:
	blk.l	$140,0

convtab:
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$1b ;Ø
	dc.b	$1c ;Å
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1d ;,
	dc.b	$00 ;-
	dc.b	$1e ;.
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1a ;Æ
	dc.b	$00 ;A
	dc.b	$01 ;B
	dc.b	$02 ;C
	dc.b	$03 ;...
	dc.b	$04
	dc.b	$05
	dc.b	$06
	dc.b	$07
	dc.b	$08
	dc.b	$09
	dc.b	$0a
	dc.b	$0b
	dc.b	$0c
	dc.b	$0d
	dc.b	$0e
	dc.b	$0f
	dc.b	$10
	dc.b	$11
	dc.b	$12
	dc.b	$13
	dc.b	$14
	dc.b	$15
	dc.b	$16 ;....
	dc.b	$17 ;X
	dc.b	$18 ;Y
	dc.b	$19 ;Z
	dc.b	$00
	dc.b	$00
	dc.b	$00

text:
	dc.b	"DETTE ER EN TEST AV EN SCROLL P$ AMIGA....    *"

weblinks:
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n493
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0120.html
http://amiga-dev.wikidot.com/hardware:bltxmod
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node001A.html

;------------------------------------------------------------------------------
22 - Amiga Machine Code Letter VII - Colorcycling
Amiga Maschine Code Letter VII - Colorcycling
Apr 21, 2019  5 min lesen

Wir haben Brief VII des Amiga Machine Code Kurses erreicht. Wie immer, achten
Sie darauf, den Brief zu lesen, da ich nicht durch alle Details gehen.

Das Thema dieses Beitrags ist es, einen Farbzyklus zu verwenden, um den Text
des Scrolling-Programms aus dem vorherigen Beitrag ein wenig interessanter zu
machen. Das Endergebnis sieht so aus.

Abbildung 22-01: screenshot

Der Screenshot zeigt viele schöne Farben, die wir in dem Bildlauftext haben.
Es ist eine Art unintuitives Ergebnis auf der ersten Bitplane, da das Programm
nur eine Bitplane verwendet, die nur zwei Farben bietet. Allerdings sehen wir
viel mehr Farben, und das alles dank des Coppers, der mehr Farben als eine Art
Nachbearbeitung hinzufügt. Es ist ziemlich gut, wenn man darüber nachdenkt.

Die Codeliste, mc0702, aus Disk1 fügt dem Programm, mc0701, eine kleine
Zyklusroutine hinzu, die im vorherigen Beitrag gezeigt wurde. Werfen wir
einen Blick darauf!

Überschrift: Die Zyklusroutine

Die Zyklusroutine erweitert die Copperliste, sodass COLOR01 für jede Zeile der
Zeichen festgelegt werden kann. Auf diese Weise erhält jede Zeile eine andere
Farbe, obwohl es nur eine einzige Bitebene gibt.

Die Farben für jede Linie werden durch eine Suche in eine Farbtabelle bestimmt.

cyclecnt:
	dc.w	$0000				; allocate for cycle counter

cycle:							; The cycle routine
	lea.l	cyclecnt,a1			; move cyclecnt address into a1
	move.w	(a1),d1				; move cyclecnt value into d1

	addq.w	#2,(a1)				; add 2 to cyclecnt, but not to d1!

	cmp.w	#96,d1				; compare 96 with cyclecnt value in d1
	bne	notround				; if not 96 then go to notround

	clr.w	(a1)				; set cyclecnt value to zero
	clr.w	d1					; set d1 to zero

notround:
	lea.l	cycletable,a2		; move cycletable address into a2
	lea.l	cyclecop,a3			; move cyclecop address into a3

	moveq	#19,d0				; move 19 into d0 - cycleloop counter

cycleloop:						; do this loop 20 times
	move.w	(a2,d1.w),6(a3)		; put value in cycletable address + cycle counter
								; into the 6th word of the cyclecop setting the $DFF182 COLOR01
	addq.w	#2,d1				; increment cycle counter by 2
	addq.l	#8,a3				; increment cyclecop address by 8
	dbra	d0,cycleloop		; if not d0 < -1 then goto cycleloop

	rts							; return from cycle routine

Die cyclecnt fungiert als Offset in die Farbsuchtabelle, die jedes Mal erhöht
wird, wenn die Zyklusroutine aufgerufen wird. Der cyclecnt wird zurückgesetzt,
wenn es den Wert 96 wieder gibt. Der Grund dafür ist, dass die Farbsuchtabelle
nur 136 Byte lang ist, und wenn wir die letzten 20 Farben (40 Bytes)
subtrahieren, erhalten wir 96 Bytes.

Innerhalb der Zyklusroutine selbst gibt es eine Schleife, die 20 Mal iteriert.
Bei jeder Iteration wird eine Farbe in der Copperlist Cyclecop festgelegt, die
aus der Farbsuchtabelle entnommen wird, mit einem Offset, der durch cyclecnt
definiert wird.

cyclecop:						; visible screen starts at line 2c
	dc.w	$c201,$fffe			; wait for line 194 ($c2-$2c = $96 = 150 visible line)
	dc.w	$0182,$0000
	dc.w	$c301,$fffe			; wait for line 195
	dc.w	$0182,$0000
	dc.w	$c401,$fffe			; wait for line 196
	dc.w	$0182,$0000
	dc.w	$c501,$fffe			; wait for line 197
	dc.w	$0182,$0000
	dc.w	$c601,$fffe			; wait for line 198
	dc.w	$0182,$0000
	dc.w	$c701,$fffe			; wait for line 199
	dc.w	$0182,$0000
	dc.w	$c801,$fffe			; wait for line 200
	dc.w	$0182,$0000
	dc.w	$c901,$fffe			; wait for line 201
	dc.w	$0182,$0000
	dc.w	$ca01,$fffe			; wait for line 202
	dc.w	$0182,$0000
	dc.w	$cb01,$fffe			; wait for line 203
	dc.w	$0182,$0000
	dc.w	$cc01,$fffe			; wait for line 204
	dc.w	$0182,$0000
	dc.w	$cd01,$fffe			; wait for line 205
	dc.w	$0182,$0000
	dc.w	$ce01,$fffe			; wait for line 206
	dc.w	$0182,$0000
	dc.w	$cf01,$fffe			; wait for line 207
	dc.w	$0182,$0000
	dc.w	$d001,$fffe			; wait for line 208
	dc.w	$0182,$0000
	dc.w	$d101,$fffe			; wait for line 209
	dc.w	$0182,$0000
	dc.w	$d201,$fffe			; wait for line 210
	dc.w	$0182,$0000
	dc.w	$d301,$fffe			; wait for line 211
	dc.w	$0182,$0000
	dc.w	$d401,$fffe			; wait for line 212
	dc.w	$0182,$0000
	dc.w	$d501,$fffe			; wait for line 213
	dc.w	$0182,$0000
	; copper end sequence
	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait > $ff horiz
	dc.w	$2c01,$fffe			; wait($01,$12c)
	dc.w	$0100,$0200			; BPLCON0 disable bitplanes - older PAL chips
	dc.w	$ffff,$fffe			; end of copper

Der Copperliste cyclecop wartet auf Screenlinien, die an der Linie 194
beginnen und an der Linie 213 enden. Dies entspricht den sichtbaren
Bildschirmlinien 150 bis Zeile 169. Das ist genau eine Zeile für jede Zeile
der Schriftzeichen. Nach jeder Wartezeit wird die Farbe für diese Linie
festgelegt. Die Zyklusroutine schreibt verschiedene Farben in diese Liste,
die aus der Tabelle cycletable entnommen wird.

cycletable:
	dc.w	$0f00,$0e01,$0d02,$0c03,$0b04,$0a05,$0906,$0807
	dc.w	$0708,$0609,$050a,$040b,$030c,$020d,$010e,$000f
	dc.w	$000f,$011e,$022d,$033c,$044b,$055a,$0669,$0778
	dc.w	$0887,$0996,$0aa5,$0bb4,$0cc3,$0dd2,$0ee1,$0ff0
	dc.w	$0ff0,$0fe0,$0fd0,$0fc0,$0fb0,$0fa0,$0f90,$0f80
	dc.w	$0f70,$0f60,$0f50,$0f40,$0f30,$0f20,$0f10,$0f00

	dc.w	$0f00,$0e01,$0d02,$0c03,$0b04,$0a05,$0906,$0807
	dc.w	$0708,$0609,$050a,$040b,$030c,$020d,$010e,$000f
	dc.w	$000f,$011e,$022d,$033c

Überschrift: Alles zusammenbringen

Das mc0702 Programm kann auf Disk1 gefunden werden, also werde ich hier nicht
das vollständige Listing anzeigen. Das Programm ist auch sehr ähnlich
zu mc0701 aus dem vorherigen Beitrag.

Mit einer Basis im mc0701-Programm ist das Hinzufügen von Colorcycling eine
einfache Operation.

Beginnen Sie, indem Sie einen Aufruf der cycle-Unterroutine direkt nach dem
Aufruf der scroll-Unterroutine hinzufügen. Als nächstes fügen Sie dem Programm
die cycle-Unterroutine hinzu, z.B. direkt nach der Scroll-Unterroutine.

Als nächstes fügen Sie cyclecop am Ende der Copperliste ein, aber knapp über
der Copper-Endsequenz, die ich in dieses Listing aufgenommen habe. Last,
but not least, fügen Sie die cycletable am Ende des Codes hinzu.

In der mc0702-Codeliste wurde der Text wie folgt geändert:

text:
	dc.b	"DETTE ER EN TEST AV EN SCROLL MED"
	dc.b	" COLORCYCLING P$ AMIGA....    *"

weblinks:
http://amiga-dev.wikidot.com/hardware:colorx

;------------------------------------------------------------------------------
23 - Amiga Machine Code Letter VIII - Audio

Amiga Maschine Code Letter VIII - Audio
Mai 11, 2019  7 min lesen

Wir haben Brief VIII des Amiga Machine Code Kurses erreicht. Wie immer, achten
Sie darauf, den Brief zu lesen, da ich nicht durch alle Details gehen werde.

In diesem Beitrag werden wir uns Audio auf dem Amiga 500 ansehen und ein wenig
Maschinencode durchgehen, der zeigt, wie man einem Looped-Sample einen schönen
kleinen Öffnungs- und Schließeffekt liefert.

Der Amiga 500 liefert Sound über vier 8-Bit-Mono-Audiokanäle. Die Kanäle können
kombiniert werden, um Stereo zu liefern. Im Gegensatz zu früheren
Computergenerationen liefert der Amiga pulscodemodulierten Klang, d.h. Sound
basierend auf Samples. So ist der Amiga ein digitaler Soundprozessor und war
damals ein wichtiger Teil der digitalen Klangrevolution.

Einer der größten Erzrivalen der Amigas war der Atari ST, der mit einheimischen
MIDI-Ports kam. Aus diesem Grund bekam es mehr Zugkraft in der Musikszene als
der Amiga, was einen interessanten Punkt aufwirft: Dass Software oft nicht
geschrieben wird, um zusätzliche Hardware zu benötigen.

Allerdings war es möglich, MIDI auf dem Amiga zu tun. Für Interessierte, werfen
Sie einen Blick auf dieses Video von RetroManCave:

Abbildung 23-01: Video

Wie im Video zu sehen, braucht es zusätzliche Hardware, um MIDI auf dem Amiga
arbeiten zu lassen. MIDI funktionierte nicht out-of-the-box, und das war ein
echtes Unterscheidungsmerkmal zum Atari ST.

Man kann sich nur vorstellen, was für eine Maschine der Amiga hätte werden
können, wenn er auch mit eingebautem MIDI und Input für Samples ausgeliefert
worden wäre. Ich sitze hier und schreibe dies, mit dem Gefühl, dass der Amiga
viel mehr hätte sein können.

Der Amiga 500 wird mit dem Paula-Audiochip ausgeliefert, der auch andere
Aufgaben wie Laufwerk, Maus und Joysticks erledigt.

Paula unterstützt vier 8-Bit-Audiokanäle, in denen Lautstärke und
Wiedergabegeschwindigkeit für jeden einzelnen Kanal eingestellt werden können.
Da sich alle Sounds um die Wiedergabe von Samples drehen, sollen die Kanäle
Pulscode moduliert sein. Diese Technik war eine Abkehr von der alten Schule
legendärer Chips wie dem MOS SID Chip für den Commodore 64, die auf
Wellenformen basiert.

Im C64 sind Wellenformen die Bausteine des Schalls, während im Amiga die
Bausteine Samples sind. Samples, ermöglicht es dem Amiga, einen sehr
reichhaltigen Klang zu erzeugen, der mit Wellenformen schwer zu emulieren ist.
Zum Beispiel zupfen einer Saite auf einer Gitarre, wird seine Grundfrequenz
offenbaren, sondern auch verschiedene Obertöne. All dies kann durch Probenahme
erfasst werden, kann aber sehr kompliziert sein, um mit einer Mischung von
Wellenformen zu reproduzieren.

Abbildung 23-02: Amiga audio

Als Nächstes werfen wir einen Blick darauf, wie man Audio im Maschinencode
manipuliert!

Überschrift: Programmierung des digitalen Soundprozessors

Der Paula Sound Chip wird durch das Setzen einer Reihe von Registern
programmiert. Es ist ein ziemlich einfaches Design, aber sehr ausdrucksstark.
Werfen wir einen Blick auf die Register, einer nach dem anderen.

Die AUDxLCH und AUDxLCL teilt jedem Audiokanal mit, wo er die Beispieldaten
finden kann, und AUDxLEN definiert die Länge des Samples.

Für jeden Kanal wird die Wiedergabegeschwindigkeit durch AUDxPER festgelegt,
wobei kleine Werte zu einer schnelleren Wiedergabegeschwindigkeit führen.
Last, but not least, kann das Volumen auf einen von 65 Schritten eingestellt
werden, indem AUDxVOL festgelegt wird.

Es wird erwartet, dass die Stichprobendaten zeichengebundene Werte haben,
d.h. positive oder negative, und es wird eine Technik namens Zweier-Kompliment
verwendet, um dies zu erreichen. Zweier-Kompliment wird auf den meisten, wenn
nicht allen, Hardware heute verwendet. Das alles wird in Brief VIII erklärt.

Die Werte für die 8-Bit-Beispieldaten gehen von -128 bis 127, und das bedeutet,
dass wir stichprobenartigen Stichproben mit einheitlicher Quantisierung
erstellen. Je nach Signal können wir einige Informationen in der Stichprobe
durch einen so genannten Quantisierungsfehler vermissen. Dies kann sich auf
die Klangqualität auswirken.

Abbildung 23-03: quantization error

Hier ist ein Beispiel für eine einfache Sinuswelle, ausgedrückt als Beispiel.
Samples sind nicht auf Sinusoide beschränkt, sondern können komplexe Klänge
sein, wie Klaviere oder Sprache. Wir werden diese spezielle Probe in einem
späteren Beitrag noch einmal überprüfen.

sample:
dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40
Lassen Sie uns nun all diese Dinge zu einem Arbeitsprogramm kombinieren.

Überschrift: Der Plattenspieler-Soundeffekt

Das erste Programm in Buchstabe VIII heißt mc0801. Wenn das Programm gestartet
wird, spielt es eine Sample-Schleife ab, während die Lautstärke und
Wiedergabegeschwindigkeit langsam erhöht wird, bis die gewünschte Lautstärke
und normale Wiedergabegeschwindigkeit erreicht ist. Wenn die linke Maustaste
gedrückt wird, verringert sie die Wiedergabegeschwindigkeit und verringert die
Lautstärke. Es erinnert mich irgendwie an eine alte Drehscheibe, die beginnt
und anhält.

Hier ist eine Vorschau, wie es klingt: 

Dieser Plattenspielereffekt ist im Maschinencode sehr einfach zu machen. Nach
der Ersteinrichtung der Soundregister tritt das Programm in eine aufgerufene
Schleife ein, die die Lautstärke und die Wiedergabebeschleunigung beschleunigt.
Dann spielt es einfach die Probe immer und immer wieder. Wenn die Maustaste
gedrückt wird, tritt das Programm in eine Schleife namens downein, die
umgekehrt der Up-Schleife funktioniert. Voila - das war's!

Ich habe den Quellcode für mc0801 unten mit Anmerkungen angezeigt.

; file mc0801.s
	move.w	#$0001,$dff096		; DMACON disable audio channel 0

	lea.l	sample,a1			; move sample address into a1
	move.l	a1,$dff0a0			; AUD0LCH/AUD0LCL set audio channel 0 location to sample address
	move.w	#48452,$dff0a4		; AUD0LEN set audio channel 0 length to 48452 words
	move.w	#700,$dff0a6		; AUD0PER set audio channel 0 period to 700 clocks (less is faster)
	move.w	#0,$dff0a8			; AUD0VOL set audio channel 0 volume to 0

	move.w	#$8001,$dff096		; DMACON enable audio channel 0

	moveq	#0,d1				; quick move 0 into d1 (volume level)
	move.l	#700,d2				; move 700 into d2 (period clock)
	moveq	#64,d7				; quick move 64 into d7 (loop counter)

up:								; begin up loop
	bsr	wait					; branch to subroutine wait 1/50th of a second
	bsr	wait					; branch to subroutine wait 1/50th of a second
	move.w	d1,$dff0a8			; AUD0VOL set to volume level stored in d1
	move.w	d2,$dff0a6			; AUD0PER set to period clock stored in d2
	addq.l	#1,d1				; increment volume level in d1 by 1
	subq.l	#8,d2				; decrease period clock in d2 by 8 (makes it play faster)
	dbra	d7,up				; check loop counter - if > -1 goto up

waitmouse:						; wait for mouse button press
	btst	#6,$bfe001			; test CIAAPRA FIR0 is pressed
	bne	waitmouse				; if not goto waitmouse

	moveq	#64,d7				; set loop counter d7 to 64

down:							; begin down loop
	bsr	wait					; branch to subroutine wait 1/50th of a second
	bsr	wait					; branch to subroutine wait 1/50th of a second
	move.w	d1,$dff0a8			; AUD0VOL set to volume level stored in d1
	move.w	d2,$dff0a6			; AUD0PER set to period clock stored in d2
	subq.l	#1,d1				; decrease volume level in d1 by 1
	addq.l	#8,d2				; increase period clock in d2 by 8 (makes it play slower)
	dbra	d7,down				; check loop counter - if > -1 goto up

	move.w	#$0001,$dff096		; DMACON disable audio channel 0
	rts							; return from subroutine

wait:							; wait subroutine - waits 1/50th of a second
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0			; add mask - preserve 9 LSB
	cmp.w	#200,d0				; check if we reached line 200
	bne	wait					; if not goto wait

wait2:							; second wait - part of the wait subroutine
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0			; add mask - preserve 9 LSB
	cmp.w	#201,d0				; check if we reached line 201
	bne	wait2					; if not goto wait2

	rts							; return from wait subroutine

sample:
	blk.w	48452,0				; allocate 48452 words and set them to zero

Um das Programm zum Laufen zu bringen, müssen Sie Disk1 abrufen und den Ordner
brev08 suchen. In diesem Ordner finden Sie das programm mc0801 und das
Beispiel. Das Beispiel muss in den Speicher geladen werden, bevor das Programm
ausgeführt wird. Geben Sie Folgendes in Seka Assembler ein:

SEKA>r
FILENAME>brev08/mc0801
SEKA>a
OPTIONS>
No Errors
SEKA>ri
FILENAME>brev08/sample
BEGIN>sample
END>
SEKA>j

Im nächsten Beitrag werden wir uns ein anderes Programm ansehen, das einen
gesampelten periodischen Sinus verwendet, um eine Wavetable-Synthese zu 
erzeugen!

weblinks:
https://en.wikipedia.org/wiki/Digital_sound_revolution				; digital sound revolution 
https://www.polynominal.com/atari-st/atari-st-ym2149f-yamaha.html	; AtariST
https://youtu.be/YM04scs4MSk										; youtube - Amiga MIDI Myth Busting
http://www.polynominal.com/Commodore-Amiga/commodore-amiga-500-paula.htm	; Paula
https://en.wikipedia.org/wiki/MOS_Technology_6581					; MOS SID chip
http://amiga-dev.wikidot.com/hardware:audxlch						; AUDxLCH and AUDxLCL 
http://amiga-dev.wikidot.com/hardware:audxlen						; AUDxLEN
http://amiga-dev.wikidot.com/hardware:audxper						; AUDxPER
http://amiga-dev.wikidot.com/hardware:audxvol						; AUDxVOL

;------------------------------------------------------------------------------
24 - Amiga Machine Code Letter VIII - Wavetable Synthesis

Amiga Maschine Code Letter VIII - Wavetable Synthesis
Mai 19, 2019  8 min lesen

Wir haben Brief VIII des Amiga Machine Code Kurses erreicht. Wie immer, achten
Sie darauf, den Brief zu lesen, da ich nicht durch alle Details gehen werde.

In diesem Beitrag werden wir einen Blick auf das mc0802 Programm werfen. Es
spielt eine einfache Melodie und endet dann. Das ist alles, was es gibt,
aber es ist irgendwie interessant in seiner Einfachheit.

Wie im vorherigen Beitrag erwähnt, dreht sich das Amiga Soundsystem um Samples,
die durch seine vier PCM-Audiokanäle abgespielt werden. Dies ist eine etwas
dramatische Abkehr von der alten Art, Schall zu erzeugen, durch
Wellengeneratoren.

Obwohl Samples das Herzstück des Amiga-Soundsystems sind, kann es ganz einfach
Sound erzeugen, als ob es Wellengeneratoren verwendet hätte. Um dies zu
erreichen, müssen Sie einfach eine einstufige Sample-Welle in Ihrer Musik
verwenden. Diese Technik wird auch Wavetable-Synthese genannt.

Die im mc0802-Programm verwendete Stichprobe zeigt eine einstufige Sinuswelle,
die durch 16 Datenpunkte definiert ist. Durch die Manipulation der Audioperiode
AUDxPER können alle Arten von Noten erzeugt werden.

sample:
	dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40

Hier ist eine Aufnahme der mc0802 Programm-Soundausgabe: 

Das programm mc0802 ist unten geschrieben, mit meinen Kommentaren hinzugefügt.
Die Warteroutine wird im Folgenden näher erläutert.

; file mc0802.s
	move.w	#$0001,$dff096  ; DMACON disable audio channel 0
                        
	lea.l	sample,a1       ; move sample address into a1
	move.l	a1,$dff0a0      ; AUD0LCH/AUD0LCL set audio channel 0 location to sample address
	move.w	#8,$dff0a4      ; AUD0LEN set audio channel 0 length to 48452 words
	move.w	#0,$dff0a6      ; AUD0PER set audio channel 0 period to 700 clocks (less is faster)
	move.w	#0,$dff0a8      ; AUD0VOL set audio channel 0 volume to 0
                        
	move.w	#$8001,$dff096  ; DMACON enable audio channel 0

	lea.l	music,a1        ; move music address into a1

mainloop:					; begin mainloop
	bsr	wait				; branch to subroutine wait

	move.w	(a1)+,d1        ; move value pointed to by a1 into d1 and increment a1 (word)
	move.w	d1,$dff0a6      ; set AUD0PER to d1
	move.w	(a1)+,d2        ; move value pointed to by a1 into d2 and increment a1 (word)
	move.w	d2,$dff0a8      ; set AUD0VOL to d2

	cmp.w	#0,d1           ; compare 0 with value in d1
	bne	mainloop			; if d1 != 0 goto mainloop
	cmp.w	#0,d2           ; compare 0 with value in d2
	bne	mainloop			; if d2 != 0 goto mainloop

	move.w	#$0001,$dff096  ; DMACON disable audio channel 0
	rts                     ; return from subroutine (exit program)

wait:						; wait subroutine - waits 5/50th of second
	moveq	#4,d1			; set wait counter to 4

wait2:						; wait subroutine - waits 1/50th of a second 
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#200,d0			; check if we reached line 200
	bne	wait2				; if not goto wait
                      
wait3:						; second wait - part of the wait subroutine
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	andi.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#201,d0			; check if we reached line 201
	bne	wait3				; if not goto wait2

	dbra	d1,wait2		; if wait counter > -1 goto wait2

	rts						; return from wait subroutine

sample:						; sample of a sine wave defined by 16 values
	dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40

music:                ; pairs of period and volume - wait 1/10th second between pairs
	dc.w	428,64,428,64         ; C2, C2 at max volume
	dc.w	428,0                 ; C2 at min volume
	dc.w	381,64,381,64         ; D2, D2 at max volume
	dc.w	381,0                 ; D2 at min volume
	dc.w	339,64,339,64         ; E2, E2 at max volume
	dc.w	339,0                 ; E2 at min volume 
	dc.w	320,64,320,64         ; F2, F2 at max volume
	dc.w	320,0                 ; F2 at min volume
	dc.w	285,64,285,64         ; G2, G2 at max volume
	dc.w	285,0                 ; G2 at min volume
	dc.w	254,64,254,64         ; A2, A2 at max volume
	dc.w	254,0                 ; A2 at min volume
	dc.w	226,64,226,64         ; H2, H2 at max volume
	dc.w	226,0                 ; H2 at min volume
	dc.w	214,64,214,64,214,64  ; C3, C3, C3 at max volume
	dc.w	214,0,214,0,214,0     ; C3, C3, C3 at min volume

	dc.w	214,64                ; C3 at max volume
	dc.w	226,64                ; H2 at max volume
	dc.w	254,64                ; A2 at max volume
	dc.w	285,64                ; G2 at max volume
	dc.w	320,64                ; F2 at max volume
	dc.w	339,64                ; E2 at max volume
	dc.w	381,64                ; D2 at max volume
	dc.w	428,64,428,64,428,64  ; C2, C2, C2 at max volume

	dc.w	428,0,428,0,428,0     ; C2, C2, C2 at min volume
	dc.w	856,64,856,64,856,64  ; C1, C1, C1 at max volume 

	dc.w	0,0				; end of music is set by the zero pair

Überschrift: Interpolation

Nach einer (sehr) detaillierten Beschreibung des Amiga-Sounds von
Antti S. Lankila macht der Soundchip - Paula - überhaupt keine Interpolation.
Paula erzeugt nur Pulswellen.

Die Amiga-Perioden Werte, in der Regel irgendwo zwischen 120 und 800, werden
durch Paula Ticks gezählt. Beispielsweise bedeutet ein Periodenwert von 400,
dass Paula 400 Ticks wartet, und die Ausgabewer konstant hält, und dann zum
nächsten Sample wechselt.

Wenn Sie, wie ich, keinen Zugriff auf die Amiga 500 Hardware haben, dann
versuchen Sie, die Soundinterpolation in WinUAE zu deaktivieren. Das Signal
wird wie eine stufenweise Single-Zyklus-Sinuswelle aussehen, die im
mc0802-Programm durch 16 Werte definiert wurde.

sample:
	dc.b	0,40,90,110,127,110,90,40,0,-40,-90,-110,-127,-110,-90,-40

Abbildung 24-01: sample unfiltered

Der ungefilterte Ausgang von Paula hat viel härtere Kanten und klingt fast
unangenehm metallisch, was ein Nebenprodukt des stufenweisen Signals ist. Diese
Verzerrung wird Aliasing genannt, und wir können sie im Beispiel unten hören.
Das Bild wurde mit Audacity aufgenommen - einem Open-Source-Audio-Editor.

Soundbeispiel: Paula ungefilterte Ausgabe (emuliert) 

Wenn das Signal den Paula-Chip verlässt, geht es durch einen Filter, der das
Aliasing entfernt und einen angenehmeren Klang erzeugt.

Abbildung 24-02: sample filtered

Soundbeispiel: Emulierter Amiga 500 Sound, wie von WinUAE 

Der Filter ist ein Tiefpassfilter, der auf allen vier Audiokanälen verwendet
wird und auf der Amiga 500-Hauptplatine platziert wird. Hier ist ein Bild von
Polynomial.com.

Abbildung 24-03: Amiga audio filter

Dieser "hartcodierte" Filter ist nicht dynamisch, und diese technische
Entscheidung wird von Antti S. Lankila, der auch erwähnt, dass einige
Atari ST Modelle eine bessere Lösung hatten, kritisiert.

Überschrift: Warten Unterprogramm

Wir haben die Warteschleife schon einmal gesehen, aber nie wirklich genauer
hingeschaut. Eines der Dinge, die auf den ersten Blick verwirrend erscheinen
können, ist, dass wir, wenn wir VPOSR lesen, tatsächlich auch VHPOSR lesen,
indem wir ein langes Wort in d0 verschieben.

Abbildung 24-04: vposr vhposr

Nachdem wir die beiden Register in d0 kopiert haben, verschieben wir sie
8 Bit nach rechts, und verwenden dann ein AND um alle außer den ersten 9 Bits
zu maskieren. Der Wert in d0 entspricht nun der vertikalen Position des
Elektronenstrahls, die wir dann mit einer gegebenen Scanliniennummer
vergleichen.

Der Grund, warum wir auf die Scanzeile 200 und dann auf 201 warten, ist, dass
die assemblierte Warteroutine schnell genug ist, um mehrmals auf derselben
Scanzeile ausgeführt zu werden. Wenn wir auf beide Scan-Leitungen warten,
können wir mehrmals warten und trotzdem das richtige Timing finden. Ungefähr
1/50stel Sekunde, was der PAL-Bildwiederholrate von 50 Hz entspricht.

Ich habe ein kleines Testprogramm gemacht, das zählt, wie oft wir die
Warteschleife zwischen den Scanzeilen 200 und 201 ausführen können. Die
Schleifenanzahl wird in d1 gespeichert, und auf einem emulierten Amiga können
wir die Schleife 5 bis 6 Mal ausführen, bis die Scanzeile 201 erreicht ist.

; file mc0803.s
start:
	clr.l d1				; clear d1

wait1:						; wait subroutine - waits 1/50th of a second
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	and.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#200,d0			; check if we reached line 200
	bne	wait1				; if not goto wait
                    
wait2:						; second wait - part of the wait subroutine
	addq.l  #1,d1			; increment d1 by 1
	move.l	$dff004,d0		; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0			; algorithmic shift right d0 8 bits
	andi.l	#$1ff,d0		; add mask - preserve 9 LSB
	cmp.w	#201,d0			; check if we reached line 201
	bne	wait2				; if not goto wait2

	rts						; return from wait subroutine

Die Warteroutine kann schneller gemacht werden. Eine Variation der Warteroutine
speichert eine Anweisung, indem keine Rechtsverschiebung verwendet wird.
Werfen Sie einen Blick darauf, es ist ein einfacher Trick.

Es ist schwer vorstellbar, wie schnell der Amiga ist, wenn er 5 Iterationen
der Warteschleife während des Zeichnens einer Scanlinie durchführen kann.
Das folgende Video zeigt, wie wenig Zeit es dauert, bis ein CRT-Monitor eine
einzelne Zeile aktualisiert.

Abbildung 24-05: Video

Der Amiga 500 für PAL ist nur mit 7.09379 MHz getaktet und kann mehrere
Berechnungen pro Scanlinie durchführen. Das ist ziemlich schnell, aber nichts
im Vergleich zu modernen Computern. Es ist wirklich schwer zu ergründen,
wie schnell Computer heute sind.

weblinks:
https://en.wikipedia.org/wiki/Pulse-code_modulation
http://www.lemonamiga.com/forum/viewtopic.php?t=14385
http://amiga-dev.wikidot.com/hardware:audxper
https://bel.fi/alankila/modguide/interpolate.txt
http://www.polynominal.com/Commodore-Amiga/commodore-amiga-500-paula.htm
https://www.audacityteam.org/
http://www.polynominal.com/Commodore-Amiga/commodore-amiga-500-paula.htm
https://bel.fi/alankila/modguide/interpolate.txt
http://amiga-dev.wikidot.com/hardware:vposr
http://amiga-dev.wikidot.com/hardware:vhposr
https://en.wikipedia.org/wiki/PAL
https://www.reaktor.com/blog/crash-course-to-amiga-assembly-programming/
https://en.wikipedia.org/wiki/Cathode-ray_tube

;------------------------------------------------------------------------------
25 - Amiga Machine Code Letter IX - Interrupts

Amiga Maschine Code Letter IX - Interrupts
Mai 31, 2019  11 min lesen

Wir haben Brief IX des Amiga Machine Code Kurses erreicht. Wie immer, achten
Sie darauf, den Brief zu lesen, da ich nicht durch alle Details gehen werde.

In diesem Beitrag werden wir einen genaueren Blick auf Interrupts werfen. Wenn
Sie noch nie davon gehört haben, dann zeigt es nur, wie erstaunlich gut
Abstraktionen auf einem Computer funktionieren. Sie können Ihre gesamte
Programmierkarriere in einer Sprache auf hohem Niveau verbringen, ohne jemals
unter die Oberfläche schauen zu müssen, um zu entdecken, wie ein Computer auf
seiner grundlegendsten Ebene funktioniert. Interrupts sind eines dieser
Konzepte, mit denen sich die meisten Programmierer nie auseinandersetzen
müssen, aber sie sind sehr wichtig.

Interrupts werden ausgelöst, wenn wir auf Tastaturen tippen oder z.B. mit
externen Geräten kommunizieren. Interrupts sind unglaublich nutzbringend und
halten den Prozessor frei, andere Dinge zu tun, wissend, dass er "unterbrochen"
wird, wenn etwas Wichtiges passiert.

Am Ende des Beitrags schreiben wir einen Interrupt-Handler, der die Amiga Power
LED ein- und ausschalten lässt, jedes Mal, wenn F10 gedrückt wird. Das Programm
heißt mc0901 in Brief IX.

Überschrift: Die Ausnahmevektortabelle (The Exception Vector Table)

Wenn ein Interrupt auftritt, verarbeitet das System ihn, indem es seinen
Interrupthandler aufruft. Der Handler wird im Arbeitsspeicher platziert, und
seine Speicherposition wird der Ausnahmevektortabelle hinzugefügt, indem er
einem bestimmten Interruptvektor zugewiesen wird.

Schon jetzt scheint die Terminologie ein wenig seltsam. Warum wird sie als
Ausnahmevektortabelle bezeichnet, wenn wir uns mit Interrupts befassen? Was
ist der Unterschied zwischen den beiden?

Der Gesamtkern ist, dass Interrupts asynchrone Ereignisse sind, die z.B. durch
externe Geräte wie ein Tastendruck auf einer Tastatur ausgelöst werden und nicht
mit der Ausführung von Prozessoranweisungen synchronisiert sind. Diese werden
auch als Hardware-Interrupts bezeichnet.

Ausnahmen (Exceptions) sind hingegen synchrone Ereignisse, die mit der
Ausführung von Prozessoranweisungen synchronisiert sind, und auftreten, wenn
der Prozessor einen Fehlermodus erkennt, während er eine Anweisung ausführt.
Ein Fehlermodus kann z.B. die Division durch Null sein.

Die Amiga CPU, der Motorola 68000, hat 256 zweiunddreißig Bit Interrupt-
Vektoren. Die Tabelle belegt 256 * 4 Bytes = 1024 Bytes im Arbeitsspeicher, von
der Adresse  $000000 bis $0003FF.

Gemäß dem 68k Referenzhandbuch besteht die Tabelle aus 64 vom Prozessor
definierten Vektoren und 192 benutzerdefinierten Vektoren.

Im Folgenden finden Sie eine Liste einiger Vektoren, die wir im
Interrupt-Handler für die Tastatur verwenden werden.

Vektor	Adresse	Ausnahme
1		RESET-Initial PC
...	...	...
25		Level 1 Interrupt-Autovector
26		Level 2 Interrupt-Autovector
27		Level 3 Interrupt-Autovector
28		Level 4 Interrupt Autovector
29		Level 5 Interrupt-Autovector
30		Level 6 Interrupt Autovector
31		Level 7 Interrupt Autovector
...	...	...
255		bom Benutzer definierte Vektoren (192)

Die Interrupts sind in sieben Ebenen gruppiert, wobei Ebene 1 die unterste
Priorität ist. Ein Interrupt mit höherer Priorität kann immer einen
Interrupthandler auf niedrigerer Ebene "unterbrechen" und seinen eigenen
Handler aufrufen. Der Interrupthandler der unteren Ebene muss dann warten, bis
der Interrupthandler der höheren Ebene die Ausführung abgeschlossen hat.

Überschrift: Verwenden von Bibliotheksfunktionen

Das Aufrufen von Bibliotheksfunktionen aus dem Computercode entspricht fast
dem Aufrufen von Unterroutinen. Beim Aufrufen einer Unterroutine verwenden wir
die BSR-Anweisung (Verzweigung zur Unterroutine), die einen realtiven Offset
zu einem Label generiert, die dann zur Laufzeit dem Programmzähler hinzugefügt
wird, wodurch ein Sprung innerhalb des Programms gemacht wird.

Beim Aufrufen einer Bibliotheksfunktion verwenden wir die JSR-Anweisung (zur
Unterroutine springen), die eine absolute Adresse als Eingabe annimmt. Zur
Laufzeit wird der Programmzähler auf die angegebene Adresse gesetzt. Dies
ermöglicht es uns, eine Funktion außerhalb unseres Programms anzurufen.

Auf Amiga-Bibliotheken wird über ihren Basiszeiger zugegriffen. Unterhalb des
Basiszeigers befinden sich Zeiger auf die verschiedenen Bibliotheksfunktionen,
die über dem Basiszeiger definiert sind. Es ist wichtig, diese Zeiger immer zu
verwenden, da Funktionsimplementierungen zwischen Versionen der Bibliothek
wechseln können, während die Zeiger garantiert gleich bleiben.

Abbildung 25-01: library

Auf den Bibliotheks-Basiszeiger sollte konventionell immer über a6 zugegriffen
werden, da Bibliotheksfunktionen auch andere Bibliotheksfunktionen aufrufen.
Lesen Sie mehr darüber hier.

Der Amiga verfügt über eine spezielle Bibliothek, die exec.library, die
Funktionen für systembezogene Dinge wie die Speicherverwaltung bietet. Das
Besondere an dieser Bibliothek ist, dass ihr Basiszeiger, ExecBase genannt,
immer an der festen Adresse $4 zu finden ist. Im Vergleich dazu werden in allen
anderen Bibliotheken Basiszeiger an beliebigen Speicherorten gespeichert.
Mit anderen Worten, die exec.library fungiert als Einstiegspunkt für alle
Amiga-Bibliotheken, durch ihre OpenLibrary- und CloseLibrary-Funktionen.

Überschrift: Zuweisen von Speicher

Wir haben uns noch nie mit der Speicherzuweisung befasst. Normalerweise
schließen wir nur Zuordnungen für Assets wie Bitplanes und Sound in das
Programm ein, indem wir Label definieren und von K-Seka die pseudo-op's dc und
blk verwenden. Der Nachteil dieser Strategie ist, dass sie ziemlich große
ausführbare Dateien produziert. Dies kann vollständig vermieden werden, indem
Speicher zur Laufzeit zugewiesen wird.

Die exec.library enthält eine Funktion namens AllocMem, die Speicher zuweisen
kann. Beachten Sie, dass diese Funktion veraltet ist, aber das war nicht der
Fall, als Brief IX geschrieben wurde, zurück in den späten 80er Jahren.

AllocMem
Description: allocates memory
Library:     exec.library
Offset:      -$C6 (-198)
Syntax:      memoryBlock = AllocMem(byteSize, attributes)
ML:          d0 = AllocMem(d0,d1)
Arguments:   byteSize = number of bytes required
             attributes = type of memory
             MEMF_ANY      ($00000000)
             MEMF_PUBLIC   ($00000001)
             MEMF_CHIP     ($00000002)
             MEMF_FAST     ($00000004)
             MEMF_LOCAL    ($00000008)
             MEMF_24BITDMA ($00000010)
             MEMF_CLEAR    ($00010000)
Result:      memoryBlock = allocated memory block

Wenn wir 100 Byte öffentlichen (public) Speicher zuweisen möchten, müssen wir
die Anzahl der Bytes in d0 und den Speichertyp in d1 eintragen. Im
Maschinencode würde es wie folgt aussehen:

	moveq  #100,d0			; byteSize
	move.l #$1000,d1		; attributes
	move.l $4,a6			; ExecBase of exec.library
	jsr -198(a6)			; jump to subroutine AllocMem

Nach dem Ausführen dieses Codes hält d0 einen Zeiger auf den zugewiesenen
Speicherblock.

Nach dem Sprung wird der Programmzähler die AllocMem-Unterroutine ausführen,
aber wie findet der Programmzähler den Weg zurück zum aufrufenden Code?

Der Programmzähler wird bei Unterroutineaufrufen auf dem Systemstack
gespeichert und bei Rückgaben wiederhergestellt. Aus diesem Grund ist es
wichtig, RTS aufzurufen, wenn die Unterroutine endet, da sonst der
Programmzähler nicht auf den Aufrufer der Unterroutine zurückzeigt.

Werfen wir einen Blick auf JSR, nach dem Motorola 68000 Referenzhandbuch.

Operation: SP - 4 => SP		; PC => (SP)
           Destination Address => PC

Dies bedeutet: Legen Sie ein neues Element auf den Stack, und speichern Sie
den Programmzähler in der Adresse, auf die der dekrementierte Stapelzeiger
zeigt. Legen Sie dann den Programmzähler auf die Zieladresse fest. Beachten
Sie, dass der Stack von höheren zu niedrigeren Adressen wächst.

Sehen wir uns den Vorgang für RTS an.

Operation: (SP) => PC		; SP + 4 => SP

Was übersetzt bedeutet: Stellen Sie den Programmzähler-PC auf den Wert ein, der
in der Adresse des Stack-Zeiger-SP gespeichert ist. Erhöhen Sie dann den
Stackpointer, was mit dem Erhöhen des Stacks identisch ist.

Der Programmzähler wird nun auf die aufrufende Stelle (Call-Site) zurückzeigen!

Überschrift: Codierung für Geschwindigkeit

Ich fand diesen Link, den ich hier einfach notieren werde. Er erwehnt den
Punkt, dass die Kosten für das Ablegen der Rückgabeadresse auf dem Stack
erheblich ist. Wenn wir uns also in einer Hauptschleife befinden, möchten wir
den Programmzähler vielleicht selbst behandeln, indem wir JMP verwenden,
wodurch der Stack vollständig vermieden wird.

Dies erfordert jedoch, dass die Unterroutine nicht RTS aufruft, sondern JMP
aufruft, sodass wir dies natürlich nicht für Bibliotheksfunktionen verwenden
können, da Konventionen verlangen, dass sie mit RTS zurückgegeben werden.

Überschrift: Ein Tastatur-Interrupt-Handler

Auf disk1 finden wir das Programm mc0901, das einen Interrupt-Handler für die
Tastatur aufruft, der die LED ein- und ausschaltet, jedes Mal, wenn F10
gedrückt wird.

Das Programm beginnt mit dem Kopieren der Adresse des vorhandenen
Tastaturhandlers in den neuen Tastaturhandler. Auf diese Weise verketten wir
unseren eigenen Handler mit dem aktuellen Handler, so dass die Tastatur
weiterhin ordnungsgemäß funktioniert.

Anschließend weisen wir Speicher für den neuen Tastatur-Interrupthandler zu und
kopieren dann den Handlercode an den neuen Speicherort. Schließlich legen wir
den Eintrag für Interrupt 2 in der Ausnahmevektortabelle fest, um auf unseren
neuen Handler zu verweisen.

Bevor wir den Handler zu Interrupt 2 zuweisen, stellen wir sicher, dass die
Interrupts deaktiviert sind. Nach dem Einsatz schalten wir die Interrupts
wieder ein. Es folgt der Programmabschluss.

Das Programm kann jedoch beendet werden, aber unser Tastatur-Interrupt-Handler
ist noch am Leben und gut. Jedes Mal, wenn wir F10 drücken, auch außerhalb von
K-Seka, schaltet die POWER-LED ein und aus.

; file mc0901.s
	lea.l	jump,a1				; move address of jump into a1
	move.l	$68,2(a1)			; move value in address $68 (interupt 2)
								; into memory pointed to by a1+2

	moveq	#100,d0				; move 100 into d0

	moveq	#1,d1				; move 1 into d1
	swap	d1					; swap words in d1, value is now $10000 
	move.l	$4,a6				; move value (ExecBase of exec.library) in address $4 into a6
	jsr	-198(a6)				; Jump to subroutine AllocMem in exec.library, d0 = AllocMem(d0, d1),
								; allocate 100 bytes with type of memory MEMF_CLEAR.
	move.l	d0,a1				; put address of allocated memory stored in d0 into a1
	move.l	d0,d7				; put address of allocated memory stored in d0 into d7

	lea.l	interrupt,a0		; move address of interrupt into a0
	moveq	#24,d0				; set d0 to 24. Use d0 as a copyloop counter

copyloop:
	move.l	(a0)+,(a1)+			; copy value pointed to by a0 into address pointed to by a1.
								; Increment both with 4 bytes (1 long word)
	dbra	d0,copyloop			; if d0 > -1 goto copyloop

	move.w	#$4000,$dff09a		; INTENA Interupt enable bits - disable all interrupts
	move.l	d7,$68				; move value in d7 that points to our allocated memory into $68 (interupt 2)
	move.w	#$c000,$dff09a		; INTENA Interupt enable bits - enable all interrupts

	rts							; return from subroutine (main program)

interrupt:						; begin interrupt handler routine
	move.l	d0,-(a7)			; push value in d0 onto the stack
	move.b	$bfec01,d0			; read a byte from CIAA serial data register connected to keyboard into d0
	not.b	d0					; negate a byte in d0
	ror.b	#1,d0				; rotate right 1 bit

	cmp.b	#$59,d0				; compare F10 key value with d0
	bne.s	wrongkey			; if not F10 pressed - goto wrongkey

	bchg	#1,$bfe001			; Test bit and change. Bit 1 is power LED

wrongkey:
	move.l	(a7)+,d0			; pop the stack and put value into d0 - 
								; reestablish d0 to it's previous value

jump:
	jmp	$0						; the jump was previously set to the value in address $68 (interrupt 2)
								; so this interupt function is linked together with the previous one

Das Interrupt-Programm selbst ist nur 32 Bytes groß, so dass die 100 Bytes, die
wir zugewiesen haben, mehr als genug sind. Hier ist der Hex-Dump von Seka.

Abbildung 25-02: interrupt program

In WinUAE ist das Power LED toggeln in der unteren Statusleiste zu sehen, wenn
der Text "Power" zwischen schwarzem und grauem Text umschaltet, jedes Mal, wenn
F10 gedrückt wird.

Beachten Sie, wenn Sie das mc0901-Programm zweimal ausführen, wird das
Power LED toggeln gestoppt. Das liegt daran, dass das Programm die Handler
verkettet, so dass der neue Tastaturhandler der ersten Ausführung nach
dem neuen Tastaturhandler des zweiten Durchlaufs aufgerufen wird. Effektiv
schalten sie beide die LED-Anzeige um und löschen sich dadurch gegenseitig aus.

Überschrift: Einige letzte Gedanken

Nach der Veröffentlichung dieses Beitrags erhielt ich einige wertvolle
Rückmeldungen, die ich hier hervorheben möchte.

Auf der anderen Hand sieht der Code für einen Tastaturhandler etwas seltsam
aus. Es gibt einen Sprung zu $0 am Ende, und es gibt auch keinen Handshake mit
der Tastatur.

Unser Tastatur-Interrupt-Handler kann nicht alleine stehen, da es keinen
Handshake gibt. Alles in allem ist es sehr hackish.

In Bezug auf diesen Sprung $0 am Ende des Codes. Es sieht so aus, als ob der
Code zu $0 springt, aber das ist nicht der Fall, da sich das Programm in den
ersten beiden Zeilen neu schreibt:

	lea.l	jump,a1		; move address of jump into a1
	move.l	$68,2(a1)	; move value in address $68 into memory pointed to by a1+2

Wenn der Programmzähler die letzte Zeile des Codes erreicht, wäre $0 vom
Programm selbst überschrieben worden, mit dem Wert in $68.

jump:
	jmp	$0

Die Adresse $68 ist ein Eintrag für Interrupt 2 in der Ausnahmevektortabelle.
Dieser Sprung, verkettet unseren Interrupt-Handler mit dem System-Tastatur-
Interrupt-Handler. Unser Handler ist nur ein Relais, das die Power-LED
umschaltet und alles andere, einschließlich des Handshakes, an den
Systemtastaturhandler delegiert.

Nachdem sich das Programm selbst umschreibt, kopiert es einen Teil des
Programms in einen zugewiesenen Speicherbereich, der dann in die
Ausnahmevektortabelle eingehängt wird.

Zuerst dachte ich, dass dies eine interessante Technik war, und es ist es
sicherlich, aber es ist sehr problematisch. Hier ist ein Zitat von Mike Morton
geschrieben in BYTE Magazin, September 1986.

Selbstmodifizierender Code ist besonders schlecht für 68000-Programme, die
eines Tages auf dem 68020 ausgeführt werden können, da der Anweisungscache des
68020 normalerweise davon ausgeht, dass Code rein ist.

Die 68020 führte einen L1-Cache von 256 Bytes ein, und ich kann mir vorstellen,
dass jedes Programm, das auf Selbstmodifikation basiert, Gefahr läuft, große
Probleme mit Speicher und Cache zu verursachen, die nicht mehr synchron sind.

Das Codebeispiel ist vielleicht nicht das beste, aber ich denke, die
Kursautoren entscheiden sich dafür, die Dinge einfach und ein wenig hackish
zu halten. Das Codebeispiel ist sehr einfach zu folgen, und es hätte ohne
Zweifel einem jungen Leser ein Erfolgserlebnis gegeben, wenn die LED mit jedem
Drücken auf F10 ein- und ausgeschaltet wurde.

weblinks:
https://stackoverflow.com/questions/7295936/what-is-the-difference-between-interrupt-and-exception-context
https://stackoverflow.com/questions/45485093/signal-vs-exceptions-vs-hardware-interrupts-vs-traps
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n263
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n103
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n139
https://amigasourcecodepreservation.gitlab.io/total-amiga-assembler/
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n173
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n57
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n33
https://wiki.amigaos.net/wiki/Obsolete_Exec_Memory_Allocation
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n49
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n195
http://www.easy68k.com/paulrsm/doc/trick68k.htm
https://www.ppa.pl/forum/programowanie/41427/-asm-ciekawy-kurs-asm
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0198.html
http://www.easy68k.com/paulrsm/doc/trick68k.htm
https://en.wikipedia.org/wiki/Motorola_68020

;------------------------------------------------------------------------------
26 - Amiga Machine Code Letter X - Memory
Amiga Maschine Code Letter X - Speicher
04.07.2019  14 min lesen

Der Computercodekurs nähert sich dem Ende, und jetzt ist es an der Zeit, sich
die Bibliotheken und das Betriebssystem des Amiga anzusehen. Diese Kathedrale
der Software ist eigentlich ziemlich schön und legte ein Multitasking-System in
die Hände des Hobby-Nutzers in den späten 80'ern. Multitasking, das früher
zum Reich der teuren Unix-Maschinen gehörte, betrat nun das Wohnzimmer.

Die nächste Reihe von Beiträgen dreht sich um Brief X, und der gesamte
Quellcode kann auf Disk1 gefunden werden. Wir werden einen Blick auf die
Speicherzuweisung, das Lesen und das Schreiben von Dateien werfen. Wir
verwenden die Befehlszeilenschnittstelle (CLI) zum Lesen von Argumenten des
Benutzers und zum Lesen und Schreiben des Diskettenlaufwerks.

Die Arbeit an diesen Beiträgen hat mir ein paar Augenöffner hinterlassen, die
mir viel mehr Einblick in die Funktionsweise von Computern gegeben haben -
auch die modernen.

Im vorherigen Beitrag haben wir uns Interrupts angesehen und wie Speicher für 
ein kleines Programm zugewiesen wird, das jedes Mal aufgerufen wurde, wenn der
Tastatur-Interrupt empfangen wurde. In diesem Beitrag werden wir ein bisschen
mehr auf Speicherzuweisung schauen.

Überschrift: Suchen der Dokumentation

Bevor wir eintauchen, braucht es ein kleines Wort über die Dokumentation. Es
gibt mehrere Quellen im Web. Eine der besten kompletten Kollektionen, die ich
gefunden habe, ist bei Archive.org. Der Reichtum an Zeitschriften, Disketten
und Büchern ist einfach unglaublich. Wenn Sie, wie ich, diese Arbeit wichtig
finden, dann denken Sie bitte an eine Spende!

Ich habe mich stark auf das Buch Mapping the Amiga verlassen, um Informationen
über die Bibliotheksfunktionen zu erhalten, das mit Kickstart 1.3 kam. Der
Kickstart ist ein ROM, das alle Amiga-Bibliotheken enthält.

Ich habe auch eine große Online-Referenz für die Include-files und Autodocs
gefunden, über amigadev.elowar.com. Diese Dokumentation ist sehr reichhaltig,
aber ich konnte nicht die lebenswichtigen Offsets für die Bibliotheksfunktionen
in ihnen finden, also hier habe ich auf die von Mapping the Amiga zur Verfügung
gestellten zurückgegriffen.

Nachtrag: Die Offsets in den Includes- und Outdocs gefunden

Die Dokumentation ist von entscheidender Bedeutung, da Brief X im Machine Code
Kurs sehr kurz über die Offsets und auch darüber spricht, wie die Strukturen
aufgebaut werden können, die für die fortgeschritteneren Dinge benötigt werden.
Ich denke, das ist ein Ziel, um den Leser nicht zu überfordern.

Ich habe jedoch keine Angst, jemanden zu überwältigen, also werde ich
versuchen, all den magischen Zahlen, die um den Code in Disk1 herum verstreut
sind, eine Erklärung zu geben.

Überschrift: Zuweisen und Freiwerden von Speicher

Das Amiga OS kommt mit einem Speicher-Manager, der über die Exec-Bibliothek
aufgerufen wird. Das Betriebssystem ist ein sogenanntes Multitasking-System,
bei dem verschiedene Aufgaben unterschiedliche Speicheranteile halten. Wenn
eine Aufgabe nur Speicher verwendet, wie es ihm gefiel, ohne ihn über den
Speicher-Manager zuzuweisen, könnten schlechte Dinge passieren. Wie das
Überschreiben von Speicher, das zu anderen Aufgaben gehört. Deshalb verwenden
wir einen Speicher-Manager.

Im Folgenden werden wir umfangreiche Funktionen der aufrufenden Bibliothek
verwenden, also, wenn Sie nicht wissen, wie das gemacht wird, werfen Sie einen
Blick auf den vorherigen Beitrag.

Im nächsten Codeteil wird genauer erläutert, wie die
Speicherbibliotheksroutinen zum Zuweisen und Verteilen von Arbeitsspeicher
verwendet werden. Sie finden das programm mc1001 auf disk1.

Das Programm ist eine Parade verschiedener Speicherunterroutinen, die um die
Amiga Exec Bibliothekfunktionen AllocMem und FreeMem handelt.

Bevor wir beginnen, werfen wir einen genaueren Blick auf ihre Aufrufensyntax.
Diese stammen aus dem Buch Mapping the Amiga. Beachten Sie vor allem den
bereitgestellten Offset, der für das Springen zur Routine unerlässlich ist,
wenn wir den Basiszeiger der Bibliothek kennen.

AllocMem wird verwendet, um Speicher zuzuweisen, der eine Größe und Attribute
als Eingabe erhält. Die Attribute steuern, ob Speicher in Chip- oder Fast RAM
zugewiesen werden soll. Wenn nichts explizit angegeben wird, wird die Funktion
Chip RAM zuerst versuchen und sich dann zu Fast RAM bewegen.

Die Funktion durchsucht den Speicher nach einem "Loch" mit nicht genutztem
Speicher, das groß genug ist, um die angeforderte Größe zu halten. Der Zeiger
auf den Speicherblock wird in d0 gespeichert. Wenn kein Speicher gefunden
wurde, enthält d0 Null - also denken Sie daran, das zu überprüfen!

Beachten Sie auch, dass Speicher im Chipspeicher zugewiesen werden muss, wenn
die Co-Prozessoren in der Lage sein sollten, ihn zu verwenden.

AllocMem
Description: allocates memory
Library:     exec.library
Offset:      -$C6 (-198)
Syntax:      memoryBlock = AllocMem(byteSize, attributes)
ML:          d0 = AllocMem(d0,d1)
Arguments:   byteSize = number of bytes required
             attributes = type of memory
             MEMF_ANY      ($00000000)
             MEMF_PUBLIC   ($00000001)
             MEMF_CHIP     ($00000002)
             MEMF_FAST     ($00000004)
             MEMF_LOCAL    ($00000008)
             MEMF_24BITDMA ($00000010)
             MEMF_CLEAR    ($00010000)
Result:      memoryBlock = allocated memory block

Beim Zuweisen von Speicher ist es auch wichtig, einige Bereinigungen zu tun.
Jede Aufgabe (task), der Speicher zugewiesen bekommt, muss in später wieder
freigeben, andernfalls wird der task dafür Sorgen, das weniger Speicher 
vorhanden ist.

Der Aufrufer reserviert Speicher, indem er FreeMem aufruft und einen
Zeiger auf einen Speicherblock und eine Größe bereitstellt.

FreeMem
Description: deallocates memory
Library:     exec.library
Offset:      -$D2 (-210)
Syntax:      FreeMem(memoryBlock, byteSize)
ML:          FreeMem(a1,d0)
Arguments:   memoryBlock = the memory block to free
             byteSize = the size of the desired block in bytes;
             this will be rounded to a multiple of the system memory chunk size
Result:      none

Sie können tatsächlich einen Zeiger bereitstellen, der auf beliebige
Speicherorte verweist, da der Amiga 500 keine Hardwarespeicherpartitionierung
hat. Im Vergleich zu modernen Computern und Betriebssystemen schmeckt das ein
bisschen wie der wilde Westen.

Das Programm mc1001 ist unten angegeben und mit meinen Kommentaren ergänzt.
Der Teil des Programms ist nur, Ihnen einige einfach zu bedienende
Unterroutinen zu bieten, die in Ihren eigenen Programmen praktisch werden.

Für jede Unterroutine beginnen wir damit, den Inhalt der Register auf den
Stack zu schieben. Dann, kurz vor der Rückkehr mit RTS, geben wir den Inhalt
in die Register, um den Programmstatus vor dem Subroutineaufruf
wiederherzustellen.

Wir verwenden eine Maschinencodeanweisung namens MOVEM, um mehrere Register
zum und vom Stack zu verschieben.

Das Programm ist sehr einfach; Speicher wird zugeordnet und dann freigegeben.
Es sind auch einige grundlegende Fehlerbehandlungen hinzugefügt, in der
Situation, in der Speicher nicht zugewiesen werden kann.

; file mc1001.s
	move.l	#100000,d0			; set d0 input to allochip to 100.000 bytes
	bsr	allocchip				; branch to subroutine allocchip

	cmp.l	#0,d0				; compare output from allocchip with 0
	beq	nomem					; if 0 goto nomem (could not allocate memory)

	lea.l	buffer,a0			; put address of buffer into a0
	move.l	d0,(a0)				; store d0 (pointer to allocated memory) into the address in a0
	
	move.l	#100000,d0			; set d0 input to freemem to 
	lea.l	buffer,a0			; move address of buffer into a0)
	move.l	(a0),a0				; put the pointer to the allocated memory into a0
	bsr	freemem					; branch to subroutine freemem to free the alocated memory
	rts							; return from subroutine

nomem:
	rts							; return from subroutine

buffer:
	dc.l	0					; buffer for holding a pointer to allocated memory


allocdef:						; subroutine for allocating memory - first fast then chip. ML: d0 = allocdef(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	moveq	#1,d1               ; trick to quickly get $#10000
	swap	d1                  ; set d1 to MEMF_CLEAR initialize memory to all zeros
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

allocchip:						; subroutine for allocating chip memory. ML: d0 = allocchip(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	#$10002,d1          ; set d1 to MEMF_CHIP
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

allocfast:						; subroutine for allocating fast memory. ML: d0 = allocfast(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	#$10004,d1          ; set d1 to MEMF_FAST
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

freemem:						; subroutine for deallocating. ML: freemem(a1,d0).
	movem.l	d0-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	a0,a1               ; set a1 to the memory block to free
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-210(a6)				; call FreeMem. FreeMem(a1,d0)
	movem.l	(a7)+,d0-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

Hier ist einige nicht sehr interessante Dokumentation der Unterroutinen.

allocdef
Description: allocate memory and initialize it to zero 
             tries fast memory first and then chip memory
Syntax:      memoryBlock = allocdef(byteSize)
ML:          d0 = allocdef(d0)
Arguments:   byteSize = the size of the desired block in bytes;
             this will be rounded to a multiple of the system memory chunk size
Result:      memoryBlock = allocated memory block

allocchip
Description: allocates chip memory             
Syntax:      memoryBlock = allocchip(byteSize)
ML:          d0 = allocchip(d0)
Arguments:   byteSize = the size of the desired block in bytes;
             this will be rounded to a multiple of the system memory chunk size
Result:      memoryBlock = allocated memory block

allocfast
Description: allocates fast memory             
Syntax:      memoryBlock = allocfast(byteSize)
ML:          d0 = allocfast(d0)
Arguments:   byteSize = the size of the desired block in bytes;
             this will be rounded to a multiple of the system memory chunk size
Result:      memoryBlock = allocated memory block

freemem
Description: deallocates memory
Syntax:      freemem(memoryBlock, byteSize)
ML:          freemem(a0,d0)
Arguments:   memoryBlock = the memory block to free
             byteSize = the size of the desired block in bytes;
             this will be rounded to a multiple of the system memory chunk size
Result:      none

Die Aufruf-Syntax der Unterroutinen, sind den Bibliotheksfunktionen sehr
ähnlich und fügen jedes Mal, wenn wir auf den Stack ablegen und holen, einen
gewissen Overhead hinzu. Es ist schwer, die Vorteile der Unterroutinen zu
sehen, abgesehen von der leichten Zunahme an Einfachheit.

Überschrift: Wilder Westen

Zurück im obigen Text habe ich FreeMem ein bisschen als Wild West-Funktion
bezeichnet, da wir beliebige Speicherpositionen einfach zuordnen konnten.
Sie können dies selbst ausprobieren, indem Sie das programm mc1001 ein wenig
neu schreiben. Hier habe ich einen Offset von 1000 zur Adresse in a0
hinzugefügt, so dass wir Speicher frei machen, den wir nicht haben sollten.

move.l	1000(a0),a0 ; put the pointer to the allocated memory into a0
bsr	freemem         ; branch to subroutine freemem to free the alocated memory

Ich habe das Programm geändert und als ich es durchführte, bekam ich die
folgende Guru Meditation - mit anderen Worten, ich durfte das System verwüsten.

Abbildung 26-01: Guru Meditation

Im Guide to Guru Meditation Error Codes wird das Format wie folgt angegeben:

Subsystem-ID	Allgemeiner Fehler	Spezifischer Fehler	Adressat der Aufgabe
81				00			0005	48454C50

Der Fehlercode, den ich erhalten habe, ist ein bestimmter Warnungscode in der
Exec-Bibliothek, der eine beschädigte Speicherliste angibt. Ein sehr passender
Fehler in diesem Fall. Der letzte Teil könnte die Adresse einer Aufgabe sein,
aber wenn die Ursache nicht bekannt ist, dann wird nur "HELP" angezeigt, die
in ASCII 48 45 4C 50 ist. Verwenden Sie FreeMem mit Sorgfalt!

Überschrift: Aufwärtskompatibilität

Haftungsausschluss: Dieser Abschnitt ist ein bisschen sketchy - ich würde gerne
Feedback erhalten. Nehmen Sie folgendes mit einem Körnchen Salz.

Das Programm mc1001 enthielt drei Unterroutinen zum Zuweisen von
Arbeitsspeicher. Alle von ihnen scheinen Attribute zu verwenden, die die Flagge
MEMF_PUBLIC weglassen, was laut den Autodocs Folgendes tut:

Speicher, der nicht zugeordnet, ausgetauscht oder anderweitig nicht
adressierbar gemacht werden darf. ALLE MEMORY, DIE AUF DER VIA INTERRUPTS
UND/ODER VON ANDEREN AUFGABEN IST, MÜSSEN ENTWEDER PUBLIC ODER LOCKED INTO
MEMORY SEIN! Dazu gehören sowohl Code als auch Daten.

Beachten Sie das Geschrei, das ist natürlich wichtig! Vielleicht ist ein Grund
für die Nichtverwendung von MEMF_PUBLIC in mc1001, dass es nur dazu gedacht
ist, Speicher zu sein, auf den innerhalb des tasks selbst verwiesen wird,
und nicht von anderen geteilt wird? Wenn wir uns jedoch das
mc0901-Programm im vorherigen Beitrag ansehen, sehen wir genau den gleichen
Ausschluss von MEMF_PUBLIC. Dies ist noch rätselhafter, da es ein Programm
ist, das Speicher für ein anderes Programm zuweist, das über einen Interrupt
referenziert wird. Es passt perfekt zum Anwendungsfall MEMF_PUBLIC.

So wie ich es verstehe, ist der in mc0901 zugewiesene Speicher in den Speicher
"gesperrt", z.B. erlauben wir dem Betriebssystem nicht, ihn zu verschieben,
indem wir ihn z.B. auf die Festplatte tauschen oder anderweitig verschieben,
um das Speicherlayout zu optimieren. Diese Sperrung erfolgt jedoch nicht
explizit, was ein bisschen "geheim" ist. Ich muss zugeben, dass mein Wissen
über das Amiga-Speichersystem in Exec etwas skizzenhaft ist. Ein modernes
Betriebssystem macht Programme fast nie an einer physischen Adresse aus,
sondern verwendet eine Speicherzuordnung, sodass die Speichernutzung auf
viele Arten optimiert werden kann.

Was mich in dieses Kaninchenloch hinabgeführt hat, war das ansonsten
ausgezeichnete Buch The Kickstart Guide to the AMIGA, auf das ich in einem
zukünftigen Beitrag zurückkommen werde. Es hat folgendes über MEMF_PUBLIC
zu sagen.

... Datenstrukturen (z.B. Nachrichten), auf die mehr als eine Aufgabe zugreifen
wird, sollten AllocMem MEMF_PUBLIC sein - dies dient der
Aufwärtskompatibilität mit zukünftigen Produkten, die
hardwarespeicherübergreifende Partitionierung unterstützen können.

Ignorieren Sie den Kommentar "wie Nachrichten" vorerst. Was dieses Zitat sagt,
ist, dass wir MEMF_PUBLIC verwenden sollten, weil einige zukünftige
AMIGA-Produkte die partionierte Allokation erhalten werden. Code, der in
einem Teil ausgeführt wird, kann den Speicher außerhalb seiner Partition nicht
ändern, es sei denn, er ist MEMF_PUBLIC. Dies wäre eigentlich eine große
Durchsetzung der Codequalität, da FreeMem nicht frei herumlaufen darf, wie wir
oben gesehen haben.

Überschrift: Speichersysteme

Bis in die heutigen Tage wird AmigaOS kontinuierlich geupdatet, also müssen wir
ein kleine Zeitreise machen, um herauszufinden, was mit MEMF_PUBLIC - oder
besser gesagt, was mit MEMF_PUBLIC war.

Heute haben wir ein AmigaOS, das ab diesem Schreiben in Version 4.1 ist. Es
wird von Hyperion Entertainment entwickelt.

Für diesen Beitrag werden wir Execs moderne Speicherzuweisungssystem ignorieren
und uns auf Execs Legacy Memory Allcoation System konzentrieren, das vor
AmigaOS 4.0 verwendet wurde.

Hier ist, was über die jetzt veraltete MEMF_PUBLIC gesagt wird, was wohl die
richtige Dokumentation für Exec ist, als Kickstart 1.3 entschied.

MEMF_PUBLIC handelt von einer der am häufigsten missbrauchten Funktionen von
AmigaOS. MEMF_PUBLIC wurde mehr oder weniger als "Speicher beschrieben, der
nicht ausgetauscht, verschoben oder anderweitig nicht verfügbar gemacht werden
kann". Leider wurde dies mehr oder weniger auf jeden Speicher im klassischen
AmigaOS angewendet. Daher haben viele Leute einfach das MEMF_PUBLIC-Flag
zu fast jeder Zuweisung hinzugefügt.

MEMF_PUBLIC geht davon aus, dass ein Speicherblock zugewiesen wird, der
physisch nicht verschoben werden kann, zusammenhängend ist und nicht
ausgetauscht wird. Wenn man es so betrachtet, sind diese Anforderungen fast
immer unnötig. Eine normale Anwendung muss sich nicht um die physische Adresse
eines Speicherblocks kümmern, noch muss sie darüber nachdenken, dass der Block
nicht zusammenhängend ist, solange die virtuellen Adressen sind. Die einzige
Voraussetzung für eine Anwendung ist es, einen Speicherblock anzuheften, um zu
verhindern, dass er aus Leistungsgründen ausgetauscht wird. Der ausgewechselte
Speicher kann viel länger dauern, um zur Verfügung gestellt zu werden, was je
nach Anwendung ein Problem sein kann.

MEMF_PUBLIC bedeutet aufgrund seines Entwurfs, dass der Speicherblock für alle
Aufgaben und Entitäten im System verfügbar ist. Dies ist z.B. für das Senden
von Nachrichten wichtig. Im Moment gibt es nichts im System, das den Zugriff
auf den Speicher einer anderen Aufgabe tatsächlich verhindert, aber semantische
Semantik schreibt vor, dass Nachrichten global freigegeben werden sollten und
ein zukünftiges Speichersystem diese Semantik erzwingen wird.

Was ich also aus all dem entnehme, ist, dass, was das Buch The Kickstart Guide
to the AMIGA meint, dass wir explizit über MEMF_PUBLIC sprechen sollten, es
liegt daran, dass es eine Erwartung gibt, dass eines Tages ein Amiga-Produkt
gibt, das tatsächlich die Speicherpartionierung erzwingt, und damit
MEMF_PUBLIC Sinn machen wird. Wenn dieser Tag eintrifft, müssen Ihre Programme
nicht umgeschrieben werden, da Sie bereits MEMF_PUBLIC verwenden.

Aus dem obigen Zitat, was tatsächlich passiert war, dass viele MEMF_PUBLIC ohne
Rücksicht auf den tatsächlichen Anwendungsfall verwendet. Dies ist schlecht, da
gesperrter Speicher Speicheroptimierungsalgorithmen eine harte Zeit gibt - 
vor allem, wenn sie nicht benötigt wird, und ausgiebig verwendet wird.

Um es noch einmal zusammenzufassen; Wie ich es sehe, weist das programm mc1001
den Speicher korrekt zu, da der Speicher vom Programm selbst verbraucht werden
soll.

Das programm mc0901 macht jedoch einen Fehler, indem es MEMF_PUBLIC auslässt,
da es Speicher zuweisen muss, der an eine Adresse gesperrt werden muss, da
diese Adresse im Interruptvektor für den Tastaturinterrupt platziert wird. Das
Programm wird auf kickstart 1.3 arbeiten, ist aber nicht zunkunftskompatibel
und muss neu geschrieben werden, wenn ein AmigaOS mit Speicherpartionierung kommt.

Überschrit: Bonusmaterial

Wenn Sie mehr über das Speichermanagement erfahren möchten, gibt es eine Reihe
von ausgezeichneten Videos zu diesem Thema auf Jacob Schrums Youtube-Kanal. Es
ist nicht Amiga-spezifisch, sondern allgemeine Informatik, auf einem
Whiteboard erklärt. Es gibt viele Videos, aber ich kann besonders empfehlen:

Speicherpartitionierung 1: Feste Partitionierung
Speicherpartitionierung 2: Dynamische Partitionierung
Speicherpartitionierung 3: Buddy-System
Paging und Segmentierung 1: Einfaches Paging
Paging und Segmentierung 2: Einfache Segmentierung
Paging und Segmentierung 3: Virtuelles Speicher-Paging
Paging und Segmentierung 4: Segmentierung des virtuellen Speichers

Der nächste Beitrag wird über das Lesen und Schreiben von Dateien sein.
Bleiben Sie dran.

weblinks:
https://archive.org/
https://archive.org/donate/
https://archive.org/details/1993-thomson-randy-rhett-anderson		; Mapping the Amiga
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0000.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0550.html
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n33			; AllocMEM
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n101			; FreeMEM
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n195	; RTS
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n155	; MOVEM
http://www.amigahistory.plus.com/guruguide.html						; Guide to Guru Meditation Error Codes
https://en.wikipedia.org/wiki/Guru_Meditation 
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0332.html
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software	;
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n49/mode/2up
https://en.wikipedia.org/wiki/Memory_management_%28operating_systems%29#Partitioned_allocation
https://www.amigaos.net/
https://www.hyperion-entertainment.com/
https://wiki.amigaos.net/wiki/Exec_Memory_Allocation
https://wiki.amigaos.net/wiki/Obsolete_Exec_Memory_Allocation
https://www.youtube.com/channel/UCCKhH1p0tj1frvcD70tEyDg			; Youtube Jörg Schrum
https://www.youtube.com/watch?v=Aq_apMR31Kw
https://www.youtube.com/watch?v=GNzUL200Fko
https://www.youtube.com/watch?v=1pCC6pPAtio
https://www.youtube.com/watch?v=5ioo7ezWn1U
https://www.youtube.com/watch?v=TvzLWy6ZhMM
https://www.youtube.com/watch?v=KqHNaOrxttM
https://www.youtube.com/watch?v=TvzLWy6ZhMM

;------------------------------------------------------------------------------
27 - Amiga Machine Code Letter X - Files
Amiga Maschine Code Letter X - Dateien
07.07.2019  10 min lesen

Dies ist der zweite Teil einer mehrteiligen Serie über die Systembibliotheken.
Der vorherige Beitrag befasste sich mit der Speicherzuweisung.

Wir schauen uns immer noch Brief X des Amiga Machine Code Kurses an, und wie
immer, stellen Sie sicher, dass Sie den Brief lesen, da ich nicht alle Details
durchgehen werde.

Überschrift: Lesen von Dateien

Das Lesen von Dateien von einer Amiga-Diskette ist ziemlich einfach, wenn
Sie die DOS-Bibliothek verwenden. Für den Neuling gibt es nur ein Problem, wie
öffnen wir diese Bibliothek?

Die Systemmasterbibliothek ist Exec und ist immer geöffnet und kann unter
Speicheradresse $4 gefunden werden. Die Exec-Bibliothek ist dafür
verantwortlich, alle Bibliotheken zu verfolgen und zu öffnen und zu schließen.
Dazu enthält die Exec-Bibliothek eine Funktion namens OpenLibrary, mit der wir
den Basiszeiger der Bibliothek abrufen können, die wir öffnen möchten.

Die folgende Abbildung stammt aus dem Amiga ROM Kernel Reference Manual:
Libraries, 3rd edition.

Abbildung 27-01: Amiga Libraries

Der Grund, warum die anderen Bibliotheken keine festen Adressen wie die
Exec-Bibliothek haben, besteht darin, dass das Amiga-Betriebssystem sie in
zufällige Speicherorte laden darf. Die einzige Ausnahme ist der Basiszeiger
für die Exec-Bibliothek. Die Geschichte muss irgendwo beginnen, wie sie
sagen.

Hier ist eine Dokumentation zu OpenLibrary, aus dem Buch Mapping The Amiga.

OpenLibrary
Description: gains access to a library
Library:     exec.library
Offset:      -$198 (-408)
Syntax:      library = OpenLibrary(libName, version)
ML:          d0 = OpenLibrary(a1, d0)
Arguments:   libName = the name of the library to open             
Result:      library = the library base address; zero if unsuccessful

Ein Punkt der Frustration ist, dass ich keine Dokumentation (Autodocs und
includes) für Kickstart 1.3 finden kann. Die Dokumentation zu Kickstart 2.0
finde ich jedoch bei amigadev.elowar.com. Andere haben das gleiche Problem.

Sie können einen Blick auf OpenLibrary in den Autodocs werfen, da es dort mehr
Dokumentation gibt. Denken Sie daran, dass kickstart 1.3 System Library
Version Number 33 hat.

Im autodoc können Sie dies nachlesen:

Alle Aufrufe von OpenLibrary sollten übereinstimmende Aufrufe an CloseLibrary
haben!

Der übereinstimmende Aufruf von CloseLibrary wird benötigt, damit das System
den Speicher zurückgewinnen kann, wenn niemand die Bibliothek verwendet. Wenn
OpenLibrary aufgerufen wird, lädt es die Bibliothek und richtet die
Sprungtabelle ein, sodass die Offsets auf die richtigen Speicherorte verweisen.
Anschließend wird die Open-Methode der Bibliothek aufgerufen, die eine offene
Anzahl erhöht. Das klingt nach einfacher Referenzzählung, die auch z.B.
in .COM verwendet wird.

Wie wir später sehen werden, scheint im mc1002-Programmbeispiel, das auf disk1
gefunden wurde, der Aufruf von CloseLibrary weggelassen zu werden. Es wird auch
nicht in Brief X erwähnt, was ein bisschen rätselhaft ist...

Das programm mc1002 zeigt, wie man aus einer Datei in einen Puffer liest. Bevor
wir beginnen, sollten wir einen Blick auf die folgenden Funktionen aus der
DOS-Bibliothek werfen, die wir benötigen werden, wenn wir eine Datei von der
Diskette lesen.

Um eine Datei zu öffnen, müssen wir die Open-Methode verwenden und einen
Dateinamen und Zugriffsmodus angeben. Sehen Sie das Autodoc hier.

Open
Description: opens a file for input or output
Library:     dos.library
Offset:      -$1E (-30)
Syntax:      fh = Open(name, accessMode)
ML:          d0 = Open(d1, d2)
Arguments:   name = filename of file to open
             accessMode = type of file access desired
             MODE_READWRITE $000003EC
             MODE_OLDFILE   $000003ED
             MODE_NEWFILE   $000003EE
Result:      fh = filehandle of open file; zero if unsuccessful

Um den Inhalt der Datei zu lesen, müssen wir die Read-Methode aufrufen und ein
Dateihandle, einen Eingabepuffer und eine Länge bereitstellen. Siehe das
Autodoc hier.

Open
Description: reads bytes of data from a file
Library:     dos.library
Offset:      -$2A (-42)
Syntax:      actualLength = Read(fh, buffer, length)
ML:          d0 = Read(d1, d2, d3)
Arguments:   fh = filehandle of file from which to read
             buffer = input buffer to receive data
             length = number of bytes to read; may not exceed buffer size
Result:      actualLength = actual number of bytes read

Wenn Sie das Dateihandle "besitzen", können Sie Close darauf aufrufen. Ein
Dateihandle darf nur einmal geschlossen werden! Sehen Sie das Autodoc hier.

Close
Description: closes an open file
Library:     dos.library
Offset:      -$24 (-36)
Syntax:      success = Close(fh)
ML:          d0 = Close(d1)
Arguments:   fh = filehandle of file to close
Result:      success = zero if unsuccessful (return value valid only in
			 Revision 2.0)

Hier ist die Codeliste für das programm mc1002, das auf Disk1 des
Maschinencodekurses zu finden ist. Ich habe meine Kommentare dem Listing
hinzugefügt.

Das Programm liest eine Datei namens "Testfil" und wird dann beendet. Nicht
viel eh? Wenn das Programm ausgeführt wurde, werfen Sie einen Blick auf den
Puffer, indem Sie die Seka-Befehlszeile verwenden.

SEKA>qbuffer

Voila, es wird den Inhalt von "Testfil" offenbaren - und ich sage nicht, was
es ist

; file mc1002.s
	move.l	#24,d0				; move 24 into d0 (length)
	lea.l	filename,a0			; move address of filename into a0
	lea.l	buffer,a1			; move address of buffer into a1

	bsr	readfile				; branch to subroutine readfile

	cmp.l	#0,d0				; check if value of d0 is zero
	beq	error					; if d0 is zero then goto error

	rts							; return from subroutine

error:
	rts							; return from subroutine

filename:
	dc.b	"Testfil",0			; the filename terminated by a zero

buffer:
	blk.b	50,0				; allocate 50 bytes of buffer


readfile:
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a4               ; move a0 into a4
	move.l	a1,a5               ; move a1 into a5
	move.l	d0,d5               ; move d0 into d5
	move.l	$4,a6               ; move base pointer of exec.library into a6
	lea.l	r_dosname,a1        ; move pointer to library name into a1
	jsr	-408(a6)			    ; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	move.l	d0,a6               ; move base pointer to dos.library into a6
	move.l	#1005,d2            ; move 1005 into d2 (accessMode = MODE_OLDFILE)
	move.l	a4,d1               ; move a4 into d1 (name of filename to open)
	jsr	-30(a6)				    ; call Open in dos.library. d0 = Open(d1,d2)
	cmp.l	#0,d0               ; compare value of d0 with zero
	beq	r_error				    ; if d0 is zero goto r_error
	move.l	d0,d1               ; move d0 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7
	move.l	a5,d2               ; move a5 into d2 (buffer)
	move.l	d5,d3               ; move d5 into d3 (length)
	jsr	-42(a6)				    ; call Read in dos.library. d0 = Read(d1,d2,d3)
	move.l	d7,d1               ; move d7 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7 (number of bytes read)
	jsr	-36(a6)				    ; call Close in dos.library. d0 = Close(d1)
	move.l	d7,d0               ; move d7 into d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
r_error:					    ; handle read error
	clr.l	d0                  ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
r_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero

Hier ist die Dokumentation für die obige Lesedatei-Unterroutine.

readfile
Description: reads a file
Syntax:      actualLength = readfile(name, buffer, length)
ML:          d0 = readfile(a0, a1, d0)
Arguments:   name = filename of the file to read
             buffer = input buffer to receive data
             length = number of bytes to read
Result:      actualLength = actual number of bytes read
			 
Überschrift: Kommentare zur Readfile Subroutine

Ich denke, es gibt ein potenzielles Problem mit der Readfile-Unterroutine, in
Bezug auf die Art und Weise, wie die Länge in d0 gehandhabt wird.

Wenn das programm mc1002 die Länge auf 24 Bytes festlegt und den Wert in d0
speichert, enthält dieser d0 immer noch 24, wenn wir OpenLibrary aufrufen, wo
es als angeforderte Bibliotheksversionsnummer verwendet wird. Ich glaube nicht,
dass dies beabsichtigt ist. Aus der Dokumentation:

Wenn die angeforderte Bibliothek vorhanden ist und die Bibliotheksversion
größer oder gleich der angeforderten Version ist, ist das Öffnen erfolgreich.

In mc1002 geht der Aufruf von OpenLibrary gut, da wir nur 24 Bytes von readfile
angefordert haben, das diese Nummer verwendet, um das DOS-Libarary mit einer
angeforderten Bibliotheksversion von 24 zu öffnen. Das geht gut, denn es gibt
Versionen der DOS-Bibliothek mit höheren Versionsnummern.

Was ist jedoch, wenn wir die Readfile-Unterroutine aufgerufen und 64 Bytes
angefordert wurden? Es gibt derzeit keine DOS-Bibliothek mit einer
Versionsnummer, die höher oder gleich 64 ist, und das Ergebnis wäre ein
Fehlladen der Bibliothek.

Ich habe das mc1002-Programm so geändert, dass wir eine Version von 64 Bytes
anfordern und es wieder mit Kickstart 1.3 ausführen. Keine Probleme - 
OpenLibrary hat glücklicherweise einen Zeiger auf die DOS-Bibliothek(!?)
zurückgegeben. Es ist fast so, als ob die Versionsnummer ignoriert wird... Nun,
leider habe ich keine Zeit, dies zu untersuchen.

Ein weiteres potenzielles Problem mit der Readfile-Unterroutine ist, dass wir
OpenLibrary nicht mit einer übereinstimmenden CloseLibrary aufrufen. Dies ist
ein Problem, da es die Referenzzählung in der Bibliothek ruiniert und
Speicherverluste verursacht.

Ok, jetzt können wir Dateien lesen, also gehen wir weiter.

Überschrift: Schreiben von Dateien

Es stellt sich heraus, dass das Schreiben von Dateien auch ziemlich einfach ist
- vorausgesetzt, dass Sie die DOS-Bibliothek verwenden. Die Bibliothek enthält
eine Funktion namens Write, die wie ein geeigneter Name zum Schreiben von
Dateien erscheint. Hier ist die Autodoc-Dokumentation dafür.

Write
Description: writes bytes of data to a file
Library:     dos.library
Offset:      -$30 (-48)
Syntax:      actualLength = Write(fh, buffer, length)
ML:          d0 = Write(d1, d2, d3)
Arguments:   fh = filehandle of file to write to
             buffer = buffer containing data to write
             length = number of bytes to write
Result:      actualLength = number of bytes successfully written; -1 if unsuccessful

Das programm mc1003 zeigt, wie man eine Datei schreibt. Es kann auf Disk1
gefunden werden und ich habe einige Kommentare hinzugefügt. Das Programm ist in
der Tat sehr einfach. Es schreibt nur einen Puffer in eine Datei namens
"Testfil", und das ist es.

; file mc1003.s
	move.l	#24,d0				; move 24 into d0 (length)
	lea.l	filename,a0			; move filename address into a0
	lea.l	buffer,a1			; move buffer address into a1

	bsr	writefile				; branch to subroutine writefile

	cmp.l	#0,d0				; compare d0 with zero
	bne	error					; if d0 is zero goto error

	rts							; return from subroutine

	error:						; writefile error handling
	rts							; return from subroutine

filename:
	dc.b	"Testfil",0			; filename terminated by zero

buffer:
	dc.b	"Hallo, dette er en test!"  ; contents of the buffer


writefile:						; writefile subroutine
	movem.l	d1-d7/a0-a6,-(a7)   ; push register values onto the stack
	move.l	a0,a4               ; move a0 into a4 (filename)
	move.l	a1,a5               ; move a1 into a2 (buffer)
	move.l	d0,d5               ; move d0 into d5 (length)
	move.l	$4,a6               ; move base pointer of exec.library into a6
	lea.l	w_dosname,a1        ; move pointer to library name into a1
	jsr	-408(a6)				; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	move.l	d0,a6               ; move base pointer to dos.library into a6
	move.l	#1006,d2            ; move 1006 into d2 (accessMode = MODE_NEWFILE)
	move.l	a4,d1               ; move a4 into d1 (name of filename to open)
	jsr	-30(a6)					; call Open in dos.library. d0 = Open(d1,d2)
	cmp.l	#0,d0               ; compare value of d0 with zero
	beq	w_error				    ; if d0 is zero goto w_error
	move.l	d0,d1               ; move d0 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7
	move.l	a5,d2               ; move a5 into d2 (buffer)
	move.l	d5,d3               ; move d5 into d3 (length)
	jsr	-48(a6)					; call Write in dos.library. d0 = Write(d1,d2,d3)
	move.l	d7,d1               ; move d7 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7 (actualLength from Write)
	jsr	-36(a6)					; call Close in dos.library. d0 = Close(d1)
	move.l	d7,d0               ; move d7 into d0 (actualLength)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
w_error:						; write error handling
	clr.l	d0                  ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
w_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero

Die Schreibdateiunterroutine hat dieselben Probleme wie die zuvor beschriebene
Readfile-Unterroutine. Insbesondere der Aufruf von CloseLibrary fehlt, was zu
einem Speicherverlust führt.

Im nächsten Beitrag werden wir uns ansehen, wie E/A zwischen einem Programm und
der Befehlszeilenschnittstellen-CLI behandelt wird. Bleiben Sie dran!

weblinks:
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n173
https://archive.org/details/1990-beats-steve-amiga-rom-kernel-ref-3rd/page/n11
https://archive.org/details/1993-thomson-randy-rhett-anderson
http://amigadev.elowar.com/
http://eab.abime.net/showthread.php?t=91455
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0367.html
http://amigadev.elowar.com/read/ADCD_2.1/Libraries_Manual_guide/node028E.html
http://wiki.c2.com/?ReferenceCounting
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n169
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node02D6.html
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n185
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node02E0.html
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n55
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node028A.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0367.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0340.html
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n249
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0310.html

;------------------------------------------------------------------------------
28 - Amiga Machine Code Letter X - CLI
Amiga Maschine Code Letter X - CLI
08.07.2019  11 min lesen

Dies ist der dritte Teil einer mehrteiligen Serie über die Systembibliotheken.
Im vorherigen Beitrag ging es darum, die DOS-Bibliothek zum Lesen und Schreiben
von Dateien zu verwenden.

Wir schauen uns immer noch Brief X des Amiga Machine Code Kurses an, und wie
immer, stellen Sie sicher, dass Sie den Brief lesen, da ich nicht alle Details
durchgehen werde.

In diesem Beitrag und im nächsten Beitrag werden wir uns erarbeiten, wie
sie die DOS-Bibliothek verwenden, um mit der Befehlszeilenschnittstelle des
AmigaOS zu interagieren.

Überschrift: CLI-Argumente und -Ausgabe

Der Amiga wird mit einer Befehlszeilenschnittstelle, der CLI, ausgeliefert. In
diesem Abschnitt sehen wir uns an, wie E/A von und zu der CLI funktioniert.

Brief X beginnt damit, nur das wesentliche über die CLI zu erklären, um Sie
dazu zu bringen, das erste Beispielprogramm mc1004 in Gang zu bringen.

Wenn die CLI ein Programm ausführt, weist sie diesem Programm einen Stack zu
und legt den Zeiger auf die Argumentzeile in Register a0. Der Zeiger auf die
Argumentzeile befindet sich im CLI-Stack und bleibt während der
Programmausführung gültig. Die CLI fügt auch die Länge der Argumentzeile in d0
ein. Beachten Sie, dass das letzte Zeichen in der Regel eine Rückgabe ist, die
wir im programm mc1004 ignorieren.

Das programm mc1004 nimmt ein Argument aus der Befehlszeile und gibt es wieder
zurück. Dazu benötigen wir ein Dateihandle für die Ausgabe. Die
DOS-Bibliotheksfunktion Output gibt ein Dateihandle zurück, das sich in der
Regel auf das CLI-Terminal bezieht, es sei denn, die Ausgabe wurde in der
Befehlszeile umgeleitet, durch ">" und "<", wie wir es von unix kennen.

Output
Description: finds the program´s initial output filehandle
Library:     dos.library
Offset:      -$3C (-60)
Syntax:      fh = Output()
ML:          d0 = Output()
Arguments:   none
Result:      fh = program´s output filehandle

Die Output-Funktion wird auch in den autodocs beschrieben, wo uns gesagt wird,
dass wir den Filehandle niemals schließen sollen. Das Filehandle wurde für uns
von der CLI geöffnet und sollte auch von der CLI geschlossen werden.

Werfen wir einen Blick auf mc1004, das auch auf disk1 zu finden ist. Das
Programm liest ein Argument aus der Befehlszeile und gibt es wieder in
dieselbe Befehlszeile zurück.

; file mc1004.s
	cmp.w	#1,d0				; compare 1 with d0 (argument length from CLI)
	ble	noarg					; if d0 <= 1, then goto noarg

	lea.l	argbuffer,a1		; move argbuffer address into a1
	move.l	d0,d7				; move d0 into d7

copyarg:						; copy argument
	move.b	(a0)+,(a1)+			; move value pointed to by a0 into argbuffer and post increment both
	subq.w	#1,d0				; subtract 1 from argument length
	cmp.w	#0,d0				; compare d0 with zero - we leave the last argument character since it's just a return
	bne	copyarg					; if d0 != 0 then goto copyarg

	bsr	opendos					; branch to subroutine opendos
	move.l	d7,d0				; move d7 into d0 (restore argument length)
	lea.l	argbuffer,a0		; move argbuffer address into a0
	bsr	writechar				; branch to subroutine writechar

	rts							; return from subroutine

noarg:							; handling that no arguments was entered in CLI
	rts							; return from subroutine

argbuffer:
	blk.b	80,0				; allocate 80 bytes to argbuffer

writechar:					   ; writechar subroutine. writechar(a0,d0)
	movem.l	d1-d7/a0-a6,-(a7)  ; push register values onto the stack
	move.l	a0,a5              ; move a0 (argbuffer) into a5
	move.l	d0,d5              ; move d0 (arg length) into d5
	lea.l	txt_dosbase,a0     ; move txt_dosbase address into a0 (contains base address of dos.library)
	move.l	(a0),a6            ; move base address of dos.library into a6
	jsr	-60(a6)				   ; call Output in dos.library. d0 = output()
	move.l	d0,d1              ; move d0 (filehandle) into d1
	move.l	a5,d2              ; move a5 (argbuffer) into d2
	move.l	d5,d3              ; mvoe d5 (arg length) into d3
	jsr	-48(a6)				   ; call Write in dos.library. d0 = Write(d1,d2,d3)
	movem.l	(a7)+,d1-d7/a0-a6  ; pop values from the stack into the registers
	rts                        ; return from subroutine

opendos:					   ; opendos subroutine. opendos()
	movem.l	d0-d7/a0-a6,-(a7)  ; push register values onto the stack
	clr.l	d0                 ; clear d0
	move.l	$4,a6              ; move base pointer of exec.library into a6
	lea.l	txt_dosname,a1     ; move pointer to library name into a1
	jsr	-408(a6)			   ; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	lea.l	txt_dosbase,a5     ; move address of txt_dosbase into a5
	move.l	d0,(a5)            ; move dos.library base address into txt_dosbase
	movem.l	(a7)+,d0-d7/a0-a6  ; pop values from the stack into the registers
	rts                        ; return from subroutine

txt_dosname:
	dc.b	"dos.library",0    ; library name terminated by zero
txt_dosbase:
	dc.l	$0                 ; allocation for holding the base address of dos.library


Es ist wichtig, dieses Programm über die CLI auszuführen, da es sonst nicht
funktioniert. Um das Programm zu kompilieren und eine ausführbare Datei zu
erstellen, schreiben Sie Folgendes in Seka.

SEKA>a
OPTIONS>
No Errors
SEKA>W
FILENAME>mc1004

Gehen Sie dann in die CLI und führen Sie das Programm aus und sehen Sie, wie es
die Argumente wiedergibt.

1.amigahd:DISK1/BREV10>mc1004 cheers mate
cheers mate
1.amigahd:DISK1/BREV10>
Es funktioniert! Prost!

Als nächstes werden wir alles in einem größeren Programm zusammenbinden.

Überschrift: Scroller überarbeitet

Jetzt ist es zeit, die Unterroutinen zu kombinieren, so dass das Scroller-
Programm, das wir in einen früheren Beitrag gemacht haben, aktualisiert werden
kann, um unser neues Wissen zu nutzen.

Das mc1005-Programm aktualisiert mc0701, sodass jetzt erwartet wird, dass es
von der CLI ausgeführt wird und einen Dateinamen als Argument verwendet. Die
Datei enthält den Text, der über den Bildschirm gescrollt werden soll.
Keine Neukompilierung mehr wegen Rechtschreibfehlern - yay

Ich werde nicht den gesamten Code kommentieren. Vieles davon wurde bereits
beschrieben. Für den Orignal Scroller, schauen Sie sich den Beitrag zu mc0701
wie in Brief VII beschrieben an.

Hier ist der Code für mc1005 mit meinen Kommentaren hinzugefügt, wo der Code
sich von mc0701 unterscheidet. Der Code befindet sich auch auf disk1.

; file mc1005.s
	cmp.w	#1,d0         ; compare d0 (CLI argument lenght) with 1
	bgt	argok			  ; if d0 > 1 then go to argok (we ignore carriage return)

	rts                   ; return from subroutine (no arguments)

argok:					  ; arguments present
	lea.l	filename,a1   ; move filename address into a1

copyargloop:			  ; copy arguments to a1 (filename)
	move.b	(a0)+,(a1)+   ; move arguments that a0 points at, to what a1 points at, then post increment
	subq.w	#1,d0         ; subtract d0 (argumnent length) by 1
	cmp.w	#1,d0         ; compare d0 with 1 (have we reached the end?)
	bne	copyargloop		  ; if d0 > 1 go to copyargloop

	move.l	#50000,d0     ; move 50000 to d0 (number of bytes to allocate)
	bsr	allocdef		  ; branch to subroutine allocdef. d0 = allocdef(d0)

	cmp.l	#0,d0         ; compare d0 with 0 (check return value from allocdef)
	bne	memok			  ; if d0 != 0 then goto memok

	rts                   ; return from subroutine (memory error)

memok:					  ; memory ok
	lea.l	buffer,a1     ; move buffer address into a1
	move.l	d0,(a1)       ; move d0 (points to allocated memory) into address pointed to by a1 (buffer)

	lea.l	filename,a0   ; move filename address into a0
	move.l	d0,a1         ; move d0 (points to allcoated memory) into a1
	move.l	#50000,d0     ; move 50000 into d0

	bsr	readfile		  ; branch to subroutine readfile. d0 = readfile(a0,a1,d0)

	cmp.l	#0,d0         ; compare d0 with 0 (check return value from readfile)
	beq	freeup			  ; if d0 = 0 then goto freeup (no bytes were read)

	move.w	#$4000,$dff09a        

	or.b	#%10000000,$bfd100
	and.b	#%10000111,$bfd100

	move.w	#$01a0,$dff096

	move.w	#$1200,$dff100
	move.w	#0,$dff102
	move.w	#0,$dff104
	move.w	#2,$dff108
	move.w	#2,$dff10a
	move.w	#$2c71,$dff08e
	move.w	#$f4d1,$dff090
	move.w	#$38d1,$dff090
	move.w	#$0030,$dff092
	move.w	#$00d8,$dff094

	lea.l	screen,a1
	lea.l	bplcop,a2
	move.l	a1,d1
	swap	d1
	move.w	d1,2(a2)
	swap	d1
	move.w	d1,6(a2)

	lea.l	copper,a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

mainloop:
	move.l	$dff004,d0
	asr.l	#8,d0
	and.l	#$1ff,d0
	cmp.w	#300,d0
	bne	mainloop

	bsr	scroll

	btst	#6,$bfe001
	bne	mainloop

freeup:					   ; free memory
	move.l	#50000,d0      ; move 50000 into d0 (50000 bytes)
	lea.l	buffer,a0      ; move buffer address into a0
	move.l	(a0),a0        ; move value in a0 (points to allocated memory) into a0
	bsr	freemem			   ; branch to subroutine freemem. freemem(a1,d0)

	move.w	#$0080,$dff096

	move.l	$04,a6
	move.l	156(a6),a1
	move.l	38(a1),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts

scrollcnt:
	dc.w	$0000

charcnt:
	dc.w	$0000

scroll:
	lea.l	scrollcnt,a1
	cmp.w	#8,(a1)
	bne	nochar

	clr.w	(a1)

	lea.l	charcnt,a1
	move.w	(a1),d1
	addq.w	#1,(a1)

	lea.l	buffer,a2     ; move buffer address into a2
	move.l	(a2),a2       ; move value in a2 (points to allocated memory) into a2
	clr.l	d2
	move.b	(a2,d1.w),d2

	cmp.b	#42,d2
	bne	notend

	clr.w	(a1)
	move.b	#32,d2

notend:
	lea.l	convtab,a1
	move.b	(a1,d2.b),d2
	asl.w	#1,d2

	lea.l	font,a1
	add.l	d2,a1

	lea.l	screen,a2
	add.l	#6944,a2

	moveq	#19,d0

putcharloop:
	move.w	(a1),(a2)
	add.l	#64,a1
	add.l	#46,a2
	dbra	d0,putcharloop

nochar:
	btst	#6,$dff002
	bne	nochar

	lea.l	screen,a1
	add.l	#7820,a1

	move.l	a1,$dff050
	move.l	a1,$dff054
	move.w	#0,$dff064
	move.w	#0,$dff066
	move.l	#$ffffffff,$dff044
	move.w	#$29f0,$dff040
	move.w	#$0002,$dff042
	move.w	#$0517,$dff058   ; changed from #$0523 to #$0517 by me (I suspect an error)

	lea.l	scrollcnt,a1
	addq.w	#1,(a1)

	rts

readfile:				     ; the readfile subroutine (described elsewhere)
	movem.l	d1-d7/a0-a6,-(a7)
	move.l	a0,a4
	move.l	a1,a5
	move.l	d0,d5
	move.l	$4,a6
	lea.l	r_dosname,a1
	jsr	-408(a6)
	move.l	d0,a6
	move.l	#1005,d2
	move.l	a4,d1
	jsr	-30(a6)
	cmp.l	#0,d0
	beq	r_error
	move.l	d0,d1
	move.l	d0,d7
	move.l	a5,d2
	move.l	d5,d3
	jsr	-42(a6)
	move.l	d7,d1
	move.l	d0,d7
	jsr	-36(a6)
	move.l	d7,d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

r_error:						  ; handle readfile error
	clr.l	d0                    ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6     ; pop values from the stack into the registers
	rts                           ; return from subroutine
r_dosname:
	dc.b	"dos.library",0       ; library name terminated by zero

allocdef:						  ; the allocdef subroutine (described elsewhere)
	movem.l	d1-d7/a0-a6,-(a7)
	moveq	#1,d1
	swap	d1
	move.l	$4,a6
	jsr	-198(a6)
	movem.l	(a7)+,d1-d7/a0-a6
	rts

freemem:                          ; the freemem subroutine (described elsewhere)
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a0,a1
	move.l	$4,a6
	jsr	-210(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rts

copper:
	dc.w	$2c01,$fffe
	dc.w	$0100,$1200

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$0180,$0000
	dc.w	$0182,$0ff0

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe

screen:
	blk.l	$b80,0

font:
	blk.l	$140,0

convtab:
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$1b ;Ø
	dc.b	$1c ;Å
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1d ;,
	dc.b	$00 ;-
	dc.b	$1e ;.
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1a ;Æ
	dc.b	$00 ;A
	dc.b	$01 ;B
	dc.b	$02 ;C
	dc.b	$03 ;...
	dc.b	$04
	dc.b	$05
	dc.b	$06
	dc.b	$07
	dc.b	$08
	dc.b	$09
	dc.b	$0a
	dc.b	$0b
	dc.b	$0c
	dc.b	$0d
	dc.b	$0e
	dc.b	$0f
	dc.b	$10
	dc.b	$11
	dc.b	$12
	dc.b	$13
	dc.b	$14
	dc.b	$15
	dc.b	$16 ;....
	dc.b	$17 ;X
	dc.b	$18 ;Y
	dc.b	$19 ;Z
	dc.b	$00
	dc.b	$00
	dc.b	$00

buffer:
	dc.l	0      ; holds the pointer to the allocated buffer (holds contents of file)

filename:
	blk.b	50,0   ; the filename

Um das Programm zu kompilieren und eine ausführbare Datei zu erstellen,
schreiben Sie Folgendes in Seka.

SEKA>a
OPTIONS>
No Errors
SEKA>ri
FILENAME>font
BEGIN>font
END>
SEKA>wo
MODE>c
FILENAME>scroll
SEKA>

Beachten Sie, dass der Modus auf c eingestellt ist, was ich für Chip-RAM steht.
Ich habe auch f versucht, was ich denke, für Fast-RAM steht, aber das wird
nicht funktionieren, da wir einen Bildschirmpuffer im Programm haben, der sich
in Chip RAM befindet.

Ich habe die ausführbare Datei für scroll aufgerufen. Verwenden Sie es nun in
der CLI wie folgt:

amigahd:DISK1/BREV10>scroll text

Sie sollten jetzt einen schönen Scroll-Text sehen. Denken Sie daran, dass das
Drücken der linken Maustaste das Programm beendet.

Überschrift: Etwas Seltsames über die Größe

Beim Blick auf den ORDNER BREV10 in disk1 fiel mir auf, dass die ausführbare
Datei mc1005 nur 2.304 Bytes betrug, während meine ausführbare Scroll-Datei
satte 14.076 Bytes betrug.

Abbildung 28-01: file size

Ich denke, dass die Leute, welche disk1 vorbereiteten musste sparen, wegen der
knappen 880kB Platz, diees auf einer Amiga Diskette gibt. Es sieht so aus, als
hätten sie den Bildschirmpuffer nicht im Programm zugewiesen, sondern nur z.B.
die allocchip-Unterroutine verwendet.

screen:
	blk.l	$b80,0

Diese Zuordnung des Bildschirmpuffers innerhalb des Programms beträgt
11.776 Bytes. Aus dem Brief VII Beitrag, wissen wir, dass der Bildschirm
23 Wörter mal 256 Zeilen ist, und das ist exakt die Größe des
Bildschirmpuffers.

23 Wörter *2*256 Linien = 11.776 Bytes

Lustig genug, denn das ist fast der Unterschied zwischen den Größen der
ausführbaren Dateien.

14.076 Bytes - 2.304 Bytes = 11.772 Bytes

Ich hätte nicht erwartet, dass es genau zusammenpasst, da wir einige
zusätzliche Aufrufe benötigen, um Speicher für den Bildschirm zuzuweisen.

Da es so einfach ist, Speicher zuzuweisen, sollten wir wirklich keine großen
Puffer innerhalb des Programms zuweisen, da es nur aufgeblähte ausführbare
Dateien erzeugt. Ein weiterer Vorteil ist, dass wir unser Programm in
Fast RAM platzieren können, während wir Puffer in Chip Ram zuteilen, die von
den benutzerdefinierten Chips zugegriffen werden können. Auf diese Weise sparen
wir einen Teil des knappen Chip-RAMs.

weblinks:
https://archive.org/details/1993-thomson-randy-rhett-anderson/page/n175
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node02D8.html

;------------------------------------------------------------------------------
29 - Amiga Machine Code Letter X - More CLI

Amiga Maschine Code Letter X - Mehr CLI
08.07.2019  6 min lesen

Dies ist der vierte Teil einer mehrteiligen Serie über die Systembibliotheken.
Wir schauen uns immer noch Brief X des Amiga Machine Code Kurses an, und wie
immer, stellen Sie sicher, dass Sie den Brief lesen, da ich nicht alle Details
durchgehen werde.

In diesem Beitrag setzen wir unsere Erkundung der CLI aus dem vorherigen
Beitrag fort. Wir verwenden immer noch die DOS-Bibliothek, um mit der
Befehlszeilenschnittstelle des AmigaOS zu interagieren.

Überschrift: CLI-Eingang

Wenn die CLI ein Programm ausführt, werden zwei Dateihandles eingerichtet,
eines für die Eingabe und eines für die Ausgabe. Diese beiden Dateihandles
stehen dem Programm über die DOS-Bibliotheksmethoden Input und Output zur
Verfügung.

Normalerweise beziehen sich die Eingabe- und Ausgabedateihandles auf das
CLI-Terminal, es sei denn, sie wurden von ">" und "<" umgeleitet, in diesem
Fall beziehen sie sich auf etwas anderes.

Um vernünftig zu bleiben, werde ich die Dokumentation hier nicht wiederholen,
sondern nur erwähnen, dass Sie auf die Links klicken können, und wenn Sie die
Offsets benötigen, dann schauen Sie hier oder in das Buch Mapping the Amiga.

Wir werden uns das Programm mc1007 ansehen, das im Brief X zu finden ist.
Im Listing unten können Sie den Code mit meinen Kommentaren sehen. Wenn Sie das
Programm über die CLI ausführen, wartet es auf die Benutzereingabe über das
CLI-Terminal. Die Eingabe endet, wenn die Eingabe gedrückt wird, und wird dann
mit dem Präfix "Hello, " in das CLI-Terminal zurückgesetzt.

; file mc1007.s
	bsr	opendos					; go to opendos() to open the DOS library

	moveq	#40,d0				; move 40 into d0
	lea.l	input,a0			; move input address into a0
	bsr	readchar				; go to subroutine d0 = readchar(a0, d0)

	addq.l	#7,d0				; add 7 to actual length read by readchar, where 7 is for "Hallo, "
	lea.l	output,a0			; put output address into a0
	bsr	writechar				; go to subroutine d0 = writechar(a0, d0)
	rts							; exit program

output:
	dc.b	"Hallo, "			; fill some bytes with charecters

input:
	blk.b	40,0				; reserves 40 bytes for input
	even						; pseudo-op for Seka. Makes the current address
								;  even by sometimes inserting a fill byte


readchar:						; subroutine (d0=actualLength) = readchar(a0=input,d0=length)
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a5				; move a0 into a5 (input)
	move.l	d0,d5				; move d0 into d5 (length)
	lea.l	txt_dosbase,a0		; move txt_dosbase address into a0
	move.l	(a0),a6				; move base pointer to DOS library into a6
	jsr	-54(a6)					; call (d0=file) = Input() in DOS library
	move.l	d0,d1				; move d0 (file) into d1
	move.l	a5,d2				; move a5 (input) into d2
	move.l	d5,d3				; move d5 (length) into d3
	jsr	-42(a6)					; call (d0=actualLength) = Read(d1=file,d2=buffer,d3=length)
	movem.l	(a7)+,d1-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine

writechar:						; subroutine (d0=returnedLength) = writechar(a0=buffer, d0=length)
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a5				; move a0 into a5 (buffer)
	move.l	d0,d5				; move d0 into d5 (length)
	lea.l	txt_dosbase,a0		; move txt_dosbase address into a0
	move.l	(a0),a6				; move base pointer to DOS library into a6
	jsr	-60(a6)					; call (d0=file) = Output()
	move.l	d0,d1				; move d0 (file) into d1
	move.l	a5,d2				; move a5 (buffer) into d2
	move.l	d5,d3				; move d5 (length) into d3
	jsr	-48(a6)					; call (d0=returnedLength) = Write(d1=file,d2=buffer,d3=length)
								; in DOS library
	movem.l	(a7)+,d1-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine

opendos:					    ; opens the dos library. opendos()
	movem.l	d0-d7/a0-a6,-(a7)   ; push register values onto the stack
	clr.l	d0
	move.l	$4,a6
	lea.l	txt_dosname,a1
	jsr	-408(a6)			    ; call exec.library method d0 = OpenLibrary(a1,d0)
	lea.l	txt_dosbase,a1
	move.l	d0,(a1)
	movem.l	(a7)+,d0-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine

txt_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero
txt_dosbase:
	dc.l	$0                  ; allocation for holding the base address of dos.library

Es ist wichtig, dieses Programm über die CLI auszuführen, sonst funktioniert es
nicht. Um das Programm zu kompilieren und eine ausführbare Datei zu erstellen,
schreiben Sie Folgendes in Seka.

SEKA>a
OPTIONS>
No Errors
SEKA>wo
MODE>c
FILENAME>mc1007

Gehen Sie dann in die CLI und führen Sie das Programm aus und sehen Sie, wie es
die Argumente wiedergibt.

1.amigahd:DISK1/BREV10>mc1007
how are you doing!
Hello, how are you doing!
1.amigahd:DISK1/BREV10>

Wie auch in der Dokumentation erwähnt, sollten wir mit Ausrufezeichen die
Dateihandles aus Input und Output nicht schließen, da sie im Besitz der
CLI-Umgebung sind, die sie schließt, wenn das Programm beendet wird.

Allerdings sollten wir ein guter Bürger sein und die DOS-Bibliothek schließen,
aber das geschieht nicht in mc1007, mit dem Ergebnis, dass der AmigaOS nicht
in der Lage sein wird, den Speicher zurückzugewinnen.

Überschrift: Speicherbehandlung im AmigaOS

Der AmigaOS ist eine Microkernel-Architektur, bei der der Kernel Executive oder
einfach die Exec-Bibliothek genannt wird. Sein Hauptarchitekt war Carl
Sassenrath, dem Commodore freie Hände gab, um ein neues Betriebssystem für den
Amiga zu entwerfen. Über seine Rolle sagt er:

Einführung von Multitasking in die Welt der PCs im Jahr 1985 mit dem Amiga
Operating System Executive.

Der Microkernel könnte dann andere Bibliotheken nach Bedarf laden und sie
freigeben, wenn sie nicht benötigt werden, wodurch der begrenzte Speicher
erhalten bleibt.

Eine der Implikationen der begrenzten Hardware ist, dass der AmigaOS keinen
Speicherschutz hat. Jedes Programm kann frei in jede Speicheradresse schreiben,
die es möchte.

Im vorherigen Beitrag, zeigten wir, wie das Freihalten des falschen Speichers,
das ganze System zum Absturz bringen könnte!

Motorola fügte später der 68K-Familie eine MMU hinzu, die 68030 genannt wurde.
An diesem Punkt hätte der AmigaOS Speicherschutz auf Systemen mit dem 68030
erzwingen und es auf den älteren Plattformen belassen können, da ich bezweifle,
dass die Maschinen schnell genug waren, um es in der Software zu tun.

Leider habe ich keine Zeit, um AmigaOS zu überprüfen, um zu sehen, ob es
irgendwann Speicherschutz erhalten hat. Das letzte AmigaOS für die alte
Amiga 500 Hardware war AmigaOS 3.9.

Das Buch The Future Was Here schreibt, dass viele Programmierer zu der Zeit
nach den drei Eigenschaften programmierten: 
- ein Benutzer, ein Programm und ein Computer.
Sie kamen aus einer Welt der bare metal Codierung. Für sie war das Multitasking
in AmigaOS etwas, das sie lernen mussten, und viele haben es falsch gemacht,
mit dem Ergebnis, dass der Amiga abstürzen würde. Ein Amiga-Benutzer lernte,
seine Arbeit früh und oft zu speichern.

Ich denke, dass einige dieser hackishen Haltung durch den Maschine Code-Kurs
scheint, da sie den Punkt der Freigabe von Ressourcen nicht betonen, wie
das Schließen der DOS-Bibliothek, wenn es nicht mehr benötigt wird.

Allerdings ermöglichte diese entspannte Verzierung der Systemintegrität im
AmigaOS auch Hackern, einige wirklich beeindruckende Sachen zu machen, die
die Amiga-Hardware an ihre Grenzen brachten.

Das Buch The Future Was Here geht in Kapitel 6 viel ausführlicher auf die
Ursprünge des AmigaOS ein. Der Autor Jimmy Maher, beschreibt sich selbst als
digitalen Antiquar, und das ist wirklich eine gute Beschreibung. Er hat viele
Kriegsgeschichten ausgegraben, das sorgt für eine interessante Lektüre. Sein 
Blog ist kostenlos verfügbar, aber seien Sie gewarnt, unzählige Stunden können
sie dort verbringen. Wenn Ihnen gefällt, was Sie sehen, sollten Sie ihn auf
Patreon unterstützen.

Im nächsten Beitrag werden wir einen Blick auf das Lesen und Schreiben auf die
Diskette werfen. Bleiben Sie dran

weblinks:
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node02BF.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node02D8.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0550.html
https://archive.org/details/1993-thomson-randy-rhett-anderson
http://www.sassenrath.com/
https://en.wikipedia.org/wiki/Memory_management_unit
https://en.wikipedia.org/wiki/Motorola_68030
https://en.wikipedia.org/wiki/AmigaOS#AmigaOS_3.5,_3.9
https://www.goodreads.com/book/show/13488507-the-future-was-here
https://www.filfre.net/about-me/
https://www.filfre.net/
https://www.patreon.com/DigitalAntiquarian

;------------------------------------------------------------------------------
30 - Amiga Machine Code Letter X - Trackdisk

Amiga Maschine Code Letter X - Trackdisk
13.07.2019  23 min lesen

Bevor wir eintauchen, gibt es eine kleine Warnung. Dies ist das härteste Stück
Maschinencode, das ich entziffern musste, und es besteht kein Zweifel, dass wir
uns in Bezug auf den 68K-Assembler fast an der Grenze der Lesbarkeit befinden.
Der Code wäre viel lesbarer gewesen, wenn er in C wäre.

Wir müssen sanft beginnen, mit einer Erklärung der physischen Diskette, und
dann fortsetzen nmit einer kurzen Einführung in das AmigaOS und das Trackdisk-
device. Später schauen wir auf das mc1006 Programm von Disk1, die liest
und schreibt auf Diskette.

Übrigens, wir haben Brief X des Amiga Machine Code Kurses erreicht. Wie immer,
achten Sie darauf, den Brief zu lesen, da ich nicht durch alle Details
gehen werde... Nun, in diesem Fall werde ich eine Ausnahme machen, mehr darüber
später.

Überschrift: Die physische Diskette

Die Amiga-Diskette besteht aus 80 Zylindern, wobei sich Zylinder 0 auf dem
äußersten Ring und Zylinder 79 auf dem Innersten befindet. Jeder Zylinder hat
zwei tracks, eine auf der Oberseite und eine auf der unteren Seite. Die tracks
auf der oberen Seite haben gerade Zahlen, während die tracks auf der unteren
Seite ungerade Zahlen haben. Die Spur (track) ist in 11 Sektoren unterteilt, die
512 Bytes speichern können. Eine einfache Berechnung zeigt den Speicherplatz
einer Amiga-Diskette.

Speicher = 80 Zylinder * 2 Spuren * 11 Sektoren * 512 Bytes = 880 Kb

Bei der Kommunikation mit dem Laufwerk verwenden wir Blocknummern, um die
Speicherorte auf dem Datenträger festzulegen. Dies ist viel einfacher, als
Track und Sektor anzugeben. Die Blocknummer wird wie folgt berechnet:

Block = 2 * 11 * Zylinder + 11 * Seite + Sektor

Zylinder	Seite	Sektor	Block
0			0		0		0
0			0		1		1
0			1		0		11
0			1		1		12
79			0		0		1.738
79			0		1		1.739
79			1		0		1.749
79			1		1		1.750

Es gibt eine gute Beschreibung von Amiga Diskettenlaufwerken in dem Buch Amiga
Disk Drives Inside and Out. Werfen Sie auch einen Blick auf Gary Browns
Walktrough von How Floppy Disk Drives Work. Tolle Sachen.

Die Mechanik des Laufwerks ist so, dass es einen Motor zum Drehen des Antriebs
und einen Schrittmotor zum Bewegen der Lese- und Schreibköpfe über die Zylinder
hat. Die Lese- und Schreibköpfe für die untere und obere Seite der Scheibe sind
physisch an die gleiche Mechanik angeschlossen. Wenn z.B. track 0 auf der
Oberseite gelesen wird, kann das Laufwerk auch track 1 auf der Unterseite lesen,
ohne die Köpfe zu bewegen. Dies ist ein geniales Design, da Daten oft
sequenziell gespeichert werden.

Überschrift: AmigaOS und das Trackdisk-device

Das AmigaOS ist ein Mikrokernel-Betriebssystem, bei dem sich der Kernel um
Dinge wie Speicher, Laden von Hilfsbibliotheken und die Bereitstellung eines
Nachrichtensystems kümmert. Der Kernel des AmigaOS ist die Exec-Bibliothek
und wurde von Carl Sassenrath um 1985 geschrieben. Auf seiner Hompage schreibt
er:

Einführung Multitasking in die Welt der PCs im Jahr 1985 mit dem Amiga Operating
System Executive.

Der AmigaOS war eine dramatische Abkehr von früheren Heimcomputersystemen, da
es Multitasking ermöglichte. Das war damals etwas ganz Neues für Heimcomputer.

Wie in dem Buch The Future Was Here (Kapitel 6) erwähnt wird, erhielt Carl
Sassenrath freie Hände, um ein Betriebssystem für den Amiga zu entwickeln. Er
wählte die Mikrokernel Architektur, weil sie besser für die begrenzte Hardware
des ersten Amiga geeignet war. Z.B. konnte das AmigaOS Bibliotheken, Geräte und
Ressourcen laden, wenn sie benötigt wurden, und diese Flexibilität ermöglichte
es dem AmigaOS, seinen Platzbedarf gering zu halten.

Da wir es jedoch mit einer Mikrokernel-Architektur zu tun haben, können wir
nicht einfach mit der Diskette kommunizieren, da der Kernel nicht weiß, wie
wir das tun sollen. Stattdessen müssen wir einen Gerätetreiber namens
Trackdisk öffnen, der sich um Diskettenvorgänge kümmert.

Das AmigaOS kommuniziert mit Geräten (devices) über Nachrichten, die über das
Nachrichtensystem in der Exec-Bibliothek geleitet werden. Eine Nachricht kann
in anderen Aufgaben an messageports gesendet werden, wodurch ein Anforderungs-/
Response-Kommunikationsfluss zwischen tasks möglich ist. Das Nachrichtensystem
ermöglicht auch die Erweiterung der Kommunikation mit zusätzlichen Daten.

Das AmigaOS ist eine wirklich faszinierende Konstruktion, und Sie sollten es
selbst nachlesen. Es gibt eine wirklich gute Beschreibung, wie das AmigaOS
funktioniert in Teil II des Buches The Kickstart Guide to the Amiga, über
Archive.org. Es deckt den AmigaOS ab, wie es war, als Kickstart 1.2 den Tag
regierte. Es ist eine Lektüre, die Ihre Zeit wert ist.

Überschrift: Das Trackdisk-Programm

In diesem Abschnitt werfen wir einen genaueren Blick auf das programm mc1006.
Das Programm enthält eine Unterroutine namens Sector, die das Trackdisk-Gerät
zum Lesen und Schreiben auf die Diskette verwendet. Der Code kann auch auf
Disk 1 gefunden werden.

Die Sektor-Unterroutine soll in Ihren eigenen Programmen verwendet werden,
aber die Unterroutine selbst ist sehr schwer zu lesen, ohne die AmigaOS -
insbesondere die Exec-Bibliothek - zu verstehen. Hier ist die Dokumentation für
die Sektor-Unterroutine.

sector
Description: reads and writes to disk
Syntax:      sector(buffer, diskStation, block, length, mode)
ML:          d0 = mc1006(a0, d0, d1, d2, d3)
Arguments:   buffer = pointer to input or output buffer
             diskStation = the disk station to read from or to write to
             block = the start block
             length = the length in number of blocks
             mode = The mode. 1 = READ, 2 = WRITE, 3=UPDATE
Result:      no result is given

Bevor wir uns den Code ansehen, ist es wichtig, sich mit einigen der Methoden
aus der Exec-Bibliothek zu verankern, die den Code verwendet. Die Unterroutine
beginnt mit einem Aufruf von AllocSignal, um eine Signalnummer zu erhalten.
Diese Signalnummer wird verwendet, wenn wir mit dem Trackdisk-Gerät
kommunizieren.

AllocSignal
Library:     exec.library
Offset:      -$14A (-330)
Description: allocates a signal bit
Syntax:      signalNum = AllocSignal(signalNum)
ML:          d0 = AllocSignal(d0)
Arguments:   signalNum = the desired signal number		; 0-31, or -1 for no preference
Result:      signalNum = the signal bit number allocated; 0-31, or -1 if no signals are available

Als Nächstes müssen wir FindTask aufrufen, das einen Zeiger auf unsere Aufgabe
(task) zurückgibt. Dieser Zeiger wird verwendet, um die Aufgabe zu bestimmen,
die signalisiert werden muss.

FindTask
Library:     exec.library
Offset:      -$126 (-294)
Description: finds a task by name, og finds oneself
Syntax:      task = FindTask(name)
ML:          d0 = FindTask(a1)
Arguments:   name = name of the task to find				; 0 to find oneself
Result:      task = the task (or process) matching the name	; zero if unsuccessful

Wir müssen auch OpenDevice aufrufen. Auf diese Weise öffnet der AmigaOS ein
Gerät, das in unserem Fall das Trackdisk-Gerät sein wird.

OpenDevice
Library:     exec.library
Offset:      -$1BC (-444)
Description: gains access to a device
Syntax:      error = OpenDevice(devName, unitNumber, iORequest, flags)
ML:          d0 = OpenDevice(a0, d0, a1, d1)
Arguments:   devName = name of the device requested
             unitNumber = number of unit to be accessed (0 to 3)
             iORequest = The IORequst structure
             flags = set to zero for opening
Result:      error = zero if successful

Wenn wir das Gerät geöffnet haben, müssen wir mit ihm kommunizieren. Dies
geschieht durch Aufrufen von DoIO. Beachten Sie, dass diese Methode darauf
wartet, dass eine E/A-Anforderung vollständig abgeschlossen ist, d.h. es
blockiert.

DoIO
Library:     exec.library
Offset:      -$1C8 (-456)
Description: executes an I/O command and waits for its completion
Syntax:      error = DoIO(iORequest)
ML:          d0 = DoIO(a1)
Arguments:   iORequest = an IORequest initialized by OpenDevice()
Result:      error = a sign-extended copy of the io_Error field of the IORequest
             Most device commands require that the error return be checked.

Hier ist die Quelle für mc1006, mit meinen Kommentaren hinzugefügt. Das
Programm verwendet Sektor, um vom internen Laufwerk df0 zu lesen, wo der
Lesebeginn von Block 0 für eine Länge von 195 Blöcken, was 99.840 Bytes
entspricht.

; file mc1006b.s		; part b - read from disk
	lea.l	buffer,a0			; move buffer address into a0
	move.l	#0,d0				; move 0 into d0 (diskStation = internal drive)
	move.l	#0,d1				; move 0 into d1 (block = block 0)
	move.l	#195,d2				; move 195 into d2 (length = 195)
	move.l	#1,d3				; move 1 into d3 (mode = READ)

	bsr	sector
	rts							; return from subroutine

sector:							; sector(a0,d0,d1,d2,d3)
	movem.l	d0-d7/a0-a6,-(a7)	; push register values onto the stack
	lsl.l	#8,d1				; left shift d1 8 bit. convert to offset in bytes
	add.l	d1,d1				; add d1 to d1. convert to offset in bytes
	lsl.l	#8,d2				; left shift d2 8 bit. convert to length in bytes
	add.l	d2,d2				; add d2 to d2. convert to length in bytes
	move.l	d1,-(a7)			; push d1 onto the stack (block)
	move.l	d2,-(a7)			; push d2 onto the stack (length)
	move.l	a0,-(a7)			; push a0 onto the stack (buffer)
	move.l	d0,-(a7)			; push d0 onto the stack (diskStation)
	move.l	$4,a6				; move base of exec.library into a6
	lea.l	ws_diskport,a2		; move ws_diskport address into a2
	moveq	#-1,d0				; move -1 into d0 (no preference for signal number)
	jsr	-330(a6)				; call AllocSignal. d0 = AllocSignal(d0)
	moveq	#-1,d1				; move -1 into d1
	move.b	d0,15(a2)			; move d0 (signal number) into address a2+15
	clr.b	14(a2)				; clear byte at address a2+14
	move.b	#4,8(a2)			; move 4 into address 8+a2
	move.b	#120,9(a2)			; move 120 into address 9+a2
	sub.l	a1,a1				; set a1 to 0 (find oneself)
	jsr	-294(a6)				; call FindTask. d0 = FindTask(a1)
	move.l	d0,16(a2)			; move task into address 16+a2
	lea.l	20(a2),a0			; move value in address 20+a2 into a0
	move.l	a0,(a0)				; move a0 into address a0
	addq.l	#4,(a0)				; add 4 to value in address a0
	clr.l	4(a0)				; clear long in address 4+a0
	move.l	a0,8(a0)			; move a0 into address 8+a0
	lea.l	ws_diskreq,a1		; move ws_diskreq address into a1 (IOStdReq)
	move.b	#$05,8(a1)			; move 5 into address 8+a1. NT_MESSAGE indicates message currently pending
	move.l	a2,14(a1)			; move a2 into address 14+a1. Pointer to MsgPort
	lea.l	ws_devicename,a0	; move ws_devicename address into a0 (devName)
	move.l	(a7)+,d0			; pop stack into register d0 (diskStation)
	clr.l	d1					; clear d1 (flags, 0 for opening)
	jsr	-444(a6)				; call OpenDevice. d0 = OpenDevice(a0,d0,a1,d1)
	move.l	(a7)+,40(a1)		; pop stack into address 40+a1 (buffer)
	andi.l	#3,d3				; preserve first 3 bits in d3. Map mode to command
	addq.w	#1,d3				; add 1 to d3. Map mode to command
	move.w	d3,28(a1)			; move d3 into address 28+a1. Set the command
	move.l	(a7)+,36(a1)		; pop stack into address 36+a1 (length)
	move.l	(a7)+,44(a1)		; pop stack into address 44+a1 (block)
	jsr	-456(a6)				; call DoIO. d0 = DoIO(a1)
	move.l	d0,d7				; move d0 (error) into d7
	move.l	#0,36(a1)			; move 0 into address 36+a1
	move.w	#$9,28(a1)			; move 9 into address 28+a1
	jsr	-456(a6)				; call DoIO. d0 = DoIO(a1)
	movem.l	(a7)+,d0-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine
ws_diskport:
	blk.l	100,0
ws_diskreq:
	blk.l	15,0
ws_devicename:
	dc.b	"trackdisk.device",0,0


buffer:
	blk.w	49920,0				; allocate buffer for 195 blocks

Brief X wird mit einem Test des Programms fortgesetzt. Folgen wir diesem
Test hier.

Zuerst müssen wir einen Diskette formatieren. In WinUAE kann dies durch
Erstellen einer Standarddiskette erfolgen, indem Sie Diskettenlaufwerke
in der Baumansicht auswählen.

Abbildung 30-01: create standard disk

Nehmen Sie den neuen Datenträger und fügen Sie ihn in df0: ein, und ändern Sie
das programm mc1006, indem Sie den folgenden Code verwenden.

; part of file mc1006a.s		; part a - write on disk
	lea.l	buffer,a0			; move buffer address into a0
	move.l	#0,d0				; move 0 into d0 (diskStation = internal drive)
	move.l	#100,d1				; move 100 into d1 (block = block 100)
	move.l	#1,d2				; move 1 into d2 (length = 1)
	move.l	#2,d3				; move 2 into d3 (mode = WRITE)
	bsr	sector
	move.l	#3,d3				; move 3 into d3 (mode = UPDATE)
	bsr	sector
	rts							; return from subroutine

	...

buffer:
	dc.b	"This is a test"
	blk.b 512,0

Was hier passiert, ist, dass wir zuerst der Sektor-Unterroutine sagen, dass
sie mit dem Schreiben bei Block 100 für eine Länge von 1 Block (512 Bytes)
beginnen soll. Die zu schreibenden Daten sind "This is a test". Nach dem
Schreiben müssen wir eine Aktualisierung durchführen, um Daten auf den
Datenträger zu übertragen. Kompilieren Sie das Programm und führen Sie es von
Seka aus aus. Sie werden feststellen, dass sich die Scheibe dreht.

Als Nächstes ändern wir das programm mc1006 erneut, indem wir den folgenden
Code verwenden:

; part of file mc1006b.s		; part b - read from disk
	lea.l	buffer,a0  ; move buffer address into a0
	move.l	#0,d0      ; move 0 into d0 (diskStation = internal drive)
	move.l	#100,d1    ; move 100 into d1 (block = block 100)
	move.l	#1,d2      ; move 1 into d2 (length = 1)
	move.l	#1,d3      ; move 1 into d3 (mode = READ)

	bsr	sector
	rts                ; return from subroutine

	...

buffer:
	blk.b 512,0

Das Programm wurde geändert, so dass wir die Sektor-Unterroutine verwenden, um
die Daten vom Datenträger zurückzulesen.

Kompilieren und führen Sie das Programm von Seka aus aus. Sie werden
feststellen, dass sich kein Datenträger dreht. Dies liegt daran, dass AmigaOS
den Disketteninhalt zwischenspeichert. Versuchen Sie, die Diskette
auszuwerfen und dann erneut einzufügen, nachdem Sie das Programm kompiliert
haben und ausführen. Jetzt dreht sich die Diskette.

Die Autoren von Brief X schreiben, dass wir nicht mit den Details dieses
Programms belastet werden sollten. Es ist kein triviales Programm und Details
werden in späteren Briefen folgen. Wenn Sie jedoch wie ich sind und Sie
nicht auf eine Erklärung warten können, dann lesen Sie weiter

Überschrift: Trackdisk-Tieftauchgang

Um zu verstehen, was in der Sektor-Unterroutine vor sich geht, müssen wir die
Autodocs and includes für den AmigaOS konsultieren. Es ist auch eine
wirklich gute Idee, Teil II des Buches The Kickstart Guide to the Amiga
zu lesen, um sich mit der Funktionsweise des AmigaOS zu verankern.

Die Sektor-Unterroutine ist übersät mit magischen Zahlen, was den Code schwer
lesbar macht. Der erste Hinweis darauf, was vor sich geht, ist im Aufruf
von OpenDevice, der ein IORequest als Eingabe verwendet.

Als ich anfing, diesen Text zu schreiben, habe ich mir die C-Definitionen für
die Strukturen wie z.B. IORequest angesehen, weil ich C kenne. Aber da ich
einen Walktrough eines Maschinencodekurses schreibe, schaue ich mir viel lieber
die Assemblerdarstellung der Strukturen an. Der Trick, um die 
Baugruppenstrukturen zu verstehen, besteht darin, zu erkennen, dass sie
Assemblermakros ausgiebig verwenden.

Überschrift: Das STRUCTURE-Makro

Es gibt eine gute Erklärung des STRUCTURE-Makros im Online-Dokument bei
github namens Total AMIGA Assembler.

Werfen wir zunächst einen Blick auf die folgende C-Definition von IORequest.
Ich habe auch die Byte-Offsets hinzugefügt, weil sie die Bedeutung der
magischen Zahlen im Code offenbaren werden.

struct IORequest
{                               /* Offsets                        */
  struct Message  io_message;   /*  0  $00                        */
  struct Device  *io_Device;    /* 20  $14  device node pointer   */
  struct Unit    *io_Unit;      /* 24  $18  unit (driver private) */
         UWORD    io_Command;   /* 28  $1C  device command        */
         UBYTE    io_Flags;     /* 30  $1E                        */
         BYTE     io_Error;     /* 31  $1F error or warning num   */
};
Sehen wir uns nun die entsprechende Assemblerdefinition von IORequest an.

STRUCTURE  IO,MN_SIZE
    APTR    IO_DEVICE			; device node pointer
    APTR    IO_UNIT				; unit (driver private)
    UWORD   IO_COMMAND			; device command
    UBYTE   IO_FLAGS			; special flags
    BYTE    IO_ERROR			; error or warning code
    LABEL   IO_SIZE

Auf der Oberfläche sieht die Baugruppenstruktur ähnlich wie die C-Struktur aus,
aber es benutzt Makros stark. STRUCTURE, APTR, UWORD, UBYTE, BYTE und LABEL
sind Makros.

Hinter der Baugruppenstruktur verbirgt sich eine ordentliche Logik, die sich
mit Offsets befasst. Wenn wir STRUCTURE schreiben, geben wir ihm zwei Eingaben
IO und MN_SIZE. Der erste ist nur ein Name, und der zweite ist ein
Größenversatz. In diesem Fall ist es die Größe einer Nachricht. Ich muss
zugeben, dass die C-Definition hier etwas expliziter ist.

Die Definition wird mit Typen wie APTR, UWORD, UBYTE, BYTE fortgesetzt, die
alle den Offset erhöhen.

Am Ende der Strukturdefinition haben wir das LABEL-Makro, das die Summe aller
Offsets, d.h. die Größe der Struktur, IO_SIZE zuweist. Wir können IO_SIZE
verwenden, wenn wir z.B. Speicher zuordnen und damit eine magische Zahl
vermeiden. In der Tat, wenn wir die Assemblerstrukturen verwenden, könnten 
wir magische Zahlen völlig vermeiden!

Hier ist ein Beispiel für den Code aus dem programm mc1006.

move.w	d3,28(a1)         ; move d3 into address 28+a1. Set the command

Und jetzt wurde derselbe Code mit dem Offset aus der Baugruppenstruktur
bereinigt.

move.w	d3,IO_COMMAND(a1) ; move d3 into address 28+a1. Set the command

OMG - keine magischen Zahlen! So viel lesbarer. Warum wurde dieser Ansatz nicht
mit mc1006 verwendet? Meine Vermutung ist, dass es darum ging, die Dinge
einfach zu halten und die Schüler nicht an die Verknüpfung von Assemblerdateien
heranzuführen. Nun, vielleicht ein guter Aufruf, aber der Code ist als
Ergebnis wirklich unlesbar.

UPDATE: Ein weiterer Grund könnte sein, dass der K-Seka-Assembler nicht mit
den Makros kompatibel ist, die in den Include-Dateien verwendet werden.

Ok, lassen Sie uns mit der Erkundung von mc1006 fortfahren.

Überschrift: Weitere Exploration

Wir müssen ein wenig tiefer graben, um Kopf oder Schwänze des Codes zu machen.
Beginnen wir mit dem, was wir wissen	; die IORequest-Struktur.

; IO Request Structures     Offsets
STRUCTURE  IO,MN_SIZE     ;  0  $00  
    APTR    IO_DEVICE     ; 20  $14  device node pointer
    APTR    IO_UNIT       ; 24  $18  unit (driver private)
    UWORD   IO_COMMAND    ; 28  $1C  device command
    UBYTE   IO_FLAGS      ; 30  $1E  special flags
    BYTE    IO_ERROR      ; 31  $1F  error or warning code
    LABEL   IO_SIZE       ; 32  $20

    ;------ Standard IO request extension:

    ULONG   IO_ACTUAL     ; 32  $20  actual # of bytes transfered
    ULONG   IO_LENGTH     ; 36  $24  requested # of bytes transfered
    APTR    IO_DATA       ; 40  $28  pointer to data area
    ULONG   IO_OFFSET     ; 44  $2C  offset for seeking devices
    LABEL   IOSTD_SIZE    ; 48  $30

Beachten Sie die E/A-Anforderungserweiterung. Nach dem Buch Amiga Disk Drives
Inside and Out.

Die normale IORequest ist für das Trackdisk-Gerät nicht verwendbar und aus
diesem Grund ist eine erweiterte Version vorhanden.

Diese erweiterte Version ist die IOStdReq-Struktur, die auch in mc1006
verwendet wird.

Lassen Sie uns weiter machen, bis wir alle Typen definiert haben.
MN_SIZE bezieht sich auf die Nachrichtenstruktur. Dies ist nicht leicht
aus der Assemblydefinition zu erkennen, aber es ist ganz klar aus der
C-Definition der IOStdReq-Struktur.

; Message Structure         Offsets
STRUCTURE  MN,LN_SIZE		;  0  $00
    APTR    MN_REPLYPORT	; 14  $0E  message reply port
    UWORD   MN_LENGTH		; 18  $12  total message length in bytes (include MN_SIZE in the length)
    LABEL   MN_SIZE			; 20  $14

Der LN_SIZE bezieht sich auf den Knoten.

; Node Structrue    Offsets
STRUCTURE	LN,0			;   0  $00  List Node
	  APTR	LN_SUCC			;   0  $00  Pointer to next (successor)
	  APTR	LN_PRED			;   4  $04  Pointer to previous (predecessor)
	  UBYTE	LN_TYPE			;   8  $08
	  BYTE	LN_PRI			;   9  $09  Priority, for sorting
	  APTR	LN_NAME			;  10  $0A  ID string, null terminated
	  LABEL	LN_SIZE			;  14  $0E  Note: word aligned

Wir können nun erahnen, wie mc1006 die IOStdReq-Struktur auffüllt, die im
Diagramm unten dargestellt wird.

Abbildung 30-02: IORequest

Wie aus dem obigen Diagramm zu erkennen ist, handelt es sich um eine ziemlich
komplexe Datenstruktur, die wir auffüllen. Kein Wunder, dass der Code schwer
zu lesen ist!

Wenden wir uns dem Antwortport in der Nachrichtenstruktur zu. Wenn eine
Nachricht gesendet wird, verwendet der Reciever den Antwortanschluss, um
zurückzuantworten. Der Antwortportzeiger ist eine MsgPort-Struktur.

; Message Port Structure           Offsets
STRUCTURE  MP,LN_SIZE            ;  0  $00
    UBYTE   MP_FLAGS             ; 14  $0E
    UBYTE   MP_SIGBIT            ; 15  $0F  signal bit number
    APTR    MP_SIGTASK           ; 16  $10  object to be signalled
    STRUCT  MP_MSGLIST,LH_SIZE   ; 20  $14  message linked list
    LABEL   MP_SIZE              ; 34  $22

Das STRUCT-Makro definiert eine Unterstruktur, die eine zusätzliche Eingabe
ermöglicht, die den Offset erhöht. In diesem Fall LH_SIZE, bezieht sich dies
auf die Listenstruktur.

; List Structure				Offsets  
STRUCTURE	LH,0				;  0  $00
    APTR	LH_HEAD				;  0  $00
    APTR	LH_TAIL				;  4  $04
    APTR	LH_TAILPRED			;  8  $08
    UBYTE	LH_TYPE				; 12  $0C
    UBYTE	LH_pad				; 13  $0D padding
    LABEL	LH_SIZE				; 14  $0E word aligned

Das folgende Diagramm zeigt, wie das Programm die MsgPort-Struktur festlegt.

Abbildung 30-03: MsgPort

Jetzt haben wir mehr oder weniger die magischen Zahlen in mc1006 erklärt.
Aber es bleibt abzuwarten, wie viel lesbarer der Code mit 
Offset-Variablen eingefügt wird. Probieren wir es aus!

; file mc1006b.s
start:
;----- Library Vector Offsets
LVOAllocSignal=-330
LVOFindTask=-294
LVOOpenDevice=-444
LVODoIO=-456
;----- Node structure offsets
LN_TYPE=8
LN_PRI=9
;----- Message type for LN_TYPE
NT_MSGPORT=4
NT_MESSAGE=$05
;----- List structure offsets
LH_HEAD=0
LH_TAIL=4
LH_TAILPRED=8
;----- MsgPort structure offsets
MP_FLAGS=14
MP_SIGBIT=15
MP_SIGTASK=16
MP_MSGLIST=20
;----- Message structure offset
MN_REPLYPORT=14
;----- IOStdRequest structure offsets
IO_COMMAND=28
IO_LENGTH=36
IO_DATA=40
IO_OFFSET=44
;----- Command type for IO_COMMAND
CMD_FLUSH=$9

;----- Begin program
	lea.l	buffer,a0  ; move buffer address into a0
	move.l	#0,d0      ; move 0 into d0 (diskStation = internal drive)
	move.l	#0,d1      ; move 0 into d1 (block = block 0)
	move.l	#195,d2    ; move 195 into d2 (length = 195)
	move.l	#1,d3      ; move 1 into d3 (mode = READ)

	bsr	sector
	rts                ; return from subroutine
  
  
sector:								 ; sector(a0=buffer,d0=diskStation,d1=block,d2=length,d3=mode)
	movem.l	d0-d7/a0-a6,-(a7)        ; push register values onto the stack
	lsl.l	#8,d1                    ; convert d1=block from blocks to offset in bytes
	add.l	d1,d1                    ; convert d1=block from blocks to offset in bytes
	lsl.l	#8,d2                    ; convert d2=length from blocks to bytes
	add.l	d2,d2                    ; convert d2=length from blocks to bytes
	move.l	d1,-(a7)                 ; push d1=block onto the stack
	move.l	d2,-(a7)                 ; push d2=length onto the stack
	move.l	a0,-(a7)                 ; push a0=buffer onto the stack
	move.l	d0,-(a7)                 ; push d0=diskStation onto the stack
	move.l	$4,a6                    ; move base of exec.library into a6
	lea.l	ws_diskport,a2           ; move ws_diskport address into a2 (MsgPort)
	moveq	#-1,d0                   ; move -1 into d0 (no preference for signal number)
	jsr	LVOAllocSignal(a6)		     ; call AllocSignal. d0 = AllocSignal(d0)
	moveq	#-1,d1                   ; move -1 into d1
	move.b	d0,MP_SIGBIT(a2)         ; set signal number in MsgPort
	clr.b	MP_FLAGS(a2)             ; clear flags in MsgPort
	move.b	NT_MSGPORT,LN_TYPE(a2)   ; set message type in MsgPort.Node
	move.b	#120,LN_PRI(a2)          ; set priority in MsgPort.Node
	sub.l	a1,a1                    ; set a1 to 0 (find oneself)
	jsr	LVOFindTask(a6)				 ; call FindTask. d0 = FindTask(a1)
	move.l	d0,MP_SIGTASK(a2)        ; set object to be signaled in MsgPort to result of FindTask
	lea.l	MP_MSGLIST(a2),a0        ; Initialize MsgPort.List
	move.l	a0,LH_HEAD(a0)           ; Initialize MsgPort.List
	addq.l	#LH_TAIL,(a0)            ; Initialize MsgPort.List
	clr.l	LH_TAIL(a0)              ; Initialize MsgPort.List
	move.l	a0,LH_TAILPRED(a0)       ; Initialize MsgPort.List
	lea.l	ws_diskreq,a1            ; move ws_diskreq address into a1 (IOStdReq)
	move.b	#NT_MESSAGE,LN_TYPE(a1)  ; set node type in IOStdReq.Message.Node
	move.l	a2,MN_REPLYPORT(a1)      ; set reply port a2 in IOStdReq.Message
	lea.l	ws_devicename,a0         ; set a0=devName
	move.l	(a7)+,d0                 ; set d0=diskStation by popping stack
	clr.l	d1                       ; set d1=flags (0 for opening)
	jsr	LVOOpenDevice(a6)            ; call OpenDevice. (d0=returnCode) = OpenDevice(a0=devName,d0=unitNumber,a1=IORequest,d1=flags)
	move.l	(a7)+,IO_DATA(a1)        ; set data in IOStdReq.Data to buffer by popping stack
	andi.l	#3,d3                    ; convert subroutine input mode to command 
	addq.w	#1,d3                    ; convert subroutine input mode to command 
	move.w	d3,IO_COMMAND(a1)        ; set IOStdReq.Command to d3
	move.l	(a7)+,IO_LENGTH(a1)      ; set IOStdReq.Length to length by popping stack
	move.l	(a7)+,IO_OFFSET(a1)      ; set IOStdReq.Offset to block by popping stack
	jsr	LVODoIO(a6)                  ; call DoIO. (d0=returnCode) = DoIO(a1=IORequest)
	move.l	d0,d7                    ; move d0=returnCode into d7
	move.l	#0,IO_LENGTH(a1)         ; set IOStdReq.Length to 0
	move.w	#CMD_FLUSH,IO_COMMAND(a1); set IOStdReq.Command to CMD_FLUSH
	jsr	LVODoIO(a6)                  ; call DoIO. (d0=returnCode) = DoIO(a1)
	movem.l	(a7)+,d0-d7/a0-a6        ; pop values from the stack into the registers
	rts                              ; return from subroutine
ws_diskport:  
	blk.l	100,0  
ws_diskreq:
	blk.l	15,0
ws_devicename:
	dc.b	"trackdisk.device",0,0


buffer:
	blk.w	49920,0					 ; allocate buffer for 1.560 blocks

Der obige Code ist identisch mit mc1006, mit dem Unterschied, dass ich alle
magischen Zahlen durch Variablen ersetzt habe. Ich habe die Namenskonvention
in den Include-Dateien befolgt.

Die Include-Dateien enthält auch eine Menge von Makros, die es zum Kinderspiel
machen, die Variablen automatisch zu generieren. Lassen Sie uns dies
weiter untersuchen.

Überschrift: Library Vector Offsets

Beachten Sie, wie ich in der oben verbesserten Version von mc1006 alle
Library Vector Offsets (LVO) durch Variablen ersetzt habe, z.B. wie folgt:

jsr	-330(a6)            ; library offset vector
jsr	LVOAllocSignal(a6)  ; the same but with a variable

Dies kann mit einigen Makrotricks erfolgen. Es wird zum Teil auf diesem
deutschen Board oder bei The Digtial Cat (meow) erklärt.

Da ich den K-Seka Assembler verwende, wird es anders laufen. Normalerweise
würde man ein Präfix "_LVO" auf die Variablen setzen, aber K-Seka mag keine
führenden Unterstriche. Eine andere Sache ist, dass K-Seka nicht kompatibel
zu sein scheint mit den Pseudo-Ops und Makro-Syntax die in den
Include-Dateien verwendet werden, was richtig schade ist.

Der K-Seka Assmbler ist im Amiga Machine Language Online-Dokument
dokumentiert.

Da K-Seka so unterschiedlich ist, habe ich die Variablen aus dem folgenden
Verfahren handgeschrieben.

Sehen Sie sich die Datei exec_lib.i an, sie enthält eine Reihe von
FUNCDEF-Makros

FUNCDEF	Supervisor
FUNCDEF	ExitIntr
FUNCDEF	Schedule
...
FUNCDEF	OpenDevice
FUNCDEF	CloseDevice
FUNCDEF	DoIO
...

Das FUNCDEF-Makro ist nicht durch das AmigaOS definiert, Sie müssen dies selbst
tun. Glücklicherweise es ist eine einfache Sache es zu tun (aber nicht in
K-Seka). Sehen wir uns zunächst das Ergebnis der Ausführung des Makros an.

LVOSupervisor:equ -30
LVOExitIntr:equ -42
LVOSchedule:equ -48
...
LVOOpenDevice:equ -444
LVOCloseDevice:equ -450
LVODoIO:equ -456
...

Der erste Offset -30 wird auch als Bias bezeichnet. Diese finden Sie in den
Systemreferenzen, in der Datei Function.offs. Diese Datei zeigt auch alle
Library Vector Offsets an. Beachten Sie, dass alle Funktionen 6 Byte
von einander entfernt sind.

Wir können nun das FUNCDEF-Makro definieren. Es gibt ein Beispiel für das
FUNCDEF-Makro in libraries.i, aber wieder wird es in K-Seka nicht
funktionieren.

FUNC_CNT  EQU  -30
FUNCDEF MACRO
 _LVO\1    EQU  FUNC_CNT
 FUNC_CNT  SET  FUNC_CNT-6	* Standard offset-6 bytes each
ENDM

Überschrift: Diskussion

Es besteht kein Zweifel, dass dieser Code schwierig aussah. Ein bisschen tiefer
zu graben machte Spaß und enthüllte ein schönes Multitasking-Betriebssystem,
bei dem Geräte bei Bedarf geladen werden können und die Kommunikation durch
das Senden von Nachrichten erfolgt.

Die Autoren haben davor gewarnt, dass dies ein fortgeschrittenes Thema war,
das nicht in Brief X behandelt werden würde, also ist die Berieselung des
Codes mit magischen Zahlen aus dieser Perspektive ok. Es ist einfach so viel
weniger, dass man erklären muss, indem man es so macht.

Auch habe ich es ein bisschen frustrierend gefunden, mit dem K-Seka zu
arbeiten, vor allem in Bezug auf Makros und Pseudo-Ops. Es scheint nicht
konform zu sein mit der Art Include-Dateien zu verwenden. 
K-Seka ist der empfohlene Assembler für diesen Maschinencodekurs, aber wenn
ich frei wählen könnte, würde ich Asm-One, AsmTwo oder Asm-Pro ausprobieren,
die neuer sind.

Um mich auf diesen Beitrag vorzubereiten, las ich Teil II von The Kickstart
Guide To Amiga. Ich kann dieses Buch sehr empfehlen, wenn Sie sich für das
AmigaOS aus der Kickstart 1.2 / 1.3 Ära interessieren.

Nach der Lektüre von Teil II dämmerte mir auch, dass der mc1006 einige
gravierende Mängel hat. Lassen Sie uns sie durchgehen.

Im Code weisen wir Platz für die Strukturen IOStdReq und MsgPort direkt zu,
ohne AllocMem zu verwenden. Dies wird nicht als Stil empfohlen, da diese
Strukturen zwischen Aufgaben aufgeteilt werden. Bei einem Amiga, der die
Speicherpartitionierung unterstützt, würde dies nicht funktionieren, da sich
die Strukturen im Speicher für unser Programm befinden und dieser Speicherplatz
für andere Aufgaben nicht zugänglich wäre. Datenstrukturen, die zwischen
Aufgaben gemeinsam genutzt werden, sollten AllocMem mit MEMF_PUBLIC sein.

Es wird auch der Stil empfohlen, in der Tat ist es in den Dokumenten geschrieben,
dass, wenn wir OpenDevice aufrufen, sollten wir es mit einem Aufruf von
CloseDevice beenden. Dies geschieht nicht in mc1006 mit dem Ergebnis, dass
wir Lücken lassen.

Das gleiche Problem wird bei AllocSignal gefunden, wo wir keinen passenden
Aufruf zu FreeSignal tätigen.

Die Exec-Bibliotheksversion 36 kommt mit der Funktion CreateMsgPort, die das
Einrichten der MsgPort-Struktur vereinfachen könnte. Diese Funktion war jedoch
zuerst mit Kickstart 2.0 verfügbar.

Eine weitere merkwürdige Sache ist, dass wir nicht die Länge der Nachricht
festlegen, wenn wir die IOStdReq vorbereiten. Ich hätte es auf 48 Bytes
gesetzt, aber der Code scheint ohne ihn gut zu funktionieren.

Es gibt eine ordentliche Schlussbemerkung aus The Kickstart Guide To Amiga
S.37, wo sie das Senden von Nachrichten zwischen einer Haupt- und einer
untergeordneten Aufgabe kommentieren.

Es gibt eine letzte Subtilität zu diesem Geschäft, die erwähnenswert ist. Dies
ist, dass sehr wenig tatsächlich im Speicher bewegt wird, wenn eine Nachricht
gesendet wird. Die Nachrichtendaten bleiben tatsächlich am gleichen Ort,
werden jedoch durch gerissene Verwendung von Zeigern an den Nachrichtenport
des Kindes angefügt. Aus diesem Grund muss die Hauptaufgabe sehr vorsichtig
sein, die Nachrichtendaten nicht zu berühren oder den Nachrichtenspeicher
zu zuweisen usw., bis die untergeordnete Aufgabe die Nachricht beantwortet
hat. Eine andere Möglichkeit, dies zu betrachten, ist zu sagen, dass die
Hauptaufgabe, indem sie die Botschaft sendet, der Aufgabe des Kindes eine
vorübergehende Lizenz erteilt, um mit ein wenig Speicher der Hauptaufgabe
herumzuwirbeln. Durch Antworten auf die Nachricht gibt das untergeordnete
Tasks diesen Speicher an die Hauptaufgabe zurück.

Ich mag diese alternative Ansicht des Sendens von Nachrichten als eine
temporäre Lizenz für den Speicher an die Reciever. Der Speicher muss noch
MEMF_PUBLIC werden, aber es gibt einen impliziten Besitz, z.B. ist es die
Hauptaufgabe, die den Speicher für die Nachricht aufteilt.

weblinks:
https://archive.org/details/Amiga_Disk_Drives_Inside_and_Out_1989_Abacus/page/n143
http://www.mindpride.net/root/Extras/how-stuff-works/how_floppy_disk_drives_work.htm
http://www.sassenrath.com/
https://www.goodreads.com/book/show/13488507-the-future-was-here
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node051E.html
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n31
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0333.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0352.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0366.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node034B.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0000.html
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n31
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0366.html
https://amigasourcecodepreservation.gitlab.io/total-amiga-assembler/#the-structure-macro
https://amigasourcecodepreservation.gitlab.io/total-amiga-assembler/
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0094.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0098.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009A.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0001.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0098.html
https://archive.org/details/Amiga_Disk_Drives_Inside_and_Out_1989_Abacus/page/n145
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009D.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0094.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0095.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0098.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009D.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009A.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009D.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0001.html
https://amiga-news.de/en/forum/thread.php?id=35523&BoardID=7
https://www.thedigitalcatonline.com/blog/2018/05/28/exploring-the-amiga-2/
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0080.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0550.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node009F.html
http://eab.abime.net/showthread.php?t=87716
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n31
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n49
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0366.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node04CC.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0333.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0356.html
http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0345.html
http://amigadev.elowar.com/read/ADCD_2.1/Libraries_Manual_guide/node028E.html
https://archive.org/details/Kickstart_Guide_to_the_Amiga_The_1987_Ariadne_Software/page/n45

;------------------------------------------------------------------------------
31 - Amiga Machine Code Letter XI - The Mouse

Amiga Maschine Code Letter XI - Die Maus
20.09.2019  9 min lesen

In diesem Beitrag werden wir einen genaueren Blick auf die Amiga-Maus werfen
und ein kleines Programm durchgehen, das die Maus-X- und Y-Zähler liest und
sie in x- und y-Koordinaten transformiert.

Für diejenigen unter euch, die mitgelaufen sind, haben wir jetzt den
Brief XI des Amiga Machine Code Kurses erreicht. Wie immer achten Sie
darauf, den Brief zu lesen, da ich nicht durch alle Details hier gehen werde.

Überschrift: Die Hardware

Die Amiga-Maus, auch bekannt als Tankmaus, ist ein mechanisches Gerät, das die
Drehung eines Balles verwendet, um die Bewegung zu bestimmen. Der Ball wird
gegen zwei senkrechte Rollen gedrückt, die senkrecht zueinander platziert sind
und mit Encoder-Rädern verbunden sind, die sich dreht, wenn die Maus bewegt
wird.

Auf der einen Seite des Geberrades befindet sich ein Infrarotstrahler und auf
der anderen Seite ein Paar Infrarotdetektoren. Das Detektorpaar ist leicht
versetzt und erzeugt zwei Pulszüge, mit denen die Drehrichtung mittels
Quadraturcodierung bestimmt werden kann.

Abbildung 31-01: Wheel and sensors

Die beiden Pulszüge V und VQ sind auch im Amiga Hardware Referenzhandbuch in
Abbildung 8-2 dargestellt.

Glücklicherweise müssen wir uns um diese Pulszüge keine Sorgen machen, da die
Amiga-Hardware sich um die Analyse des Eingangs kümmert und das Ergebnis bequem
in einem x- und y-Zähler liefert.

Die x- und y-Zähler werden in JOY0DAT gespeichert, was ein 16-Bit-Register bei
$DFF00A ist. Das obere Byte hält den y-Zähler und das untere Byte den x-Zähler.
Diese Zähler haben die besondere Eigenschaft, das sie umrunden, wenn sie
überlaufen. Ein Zähler kann daher nur Werte von 0 bis 255 halten.

Überschrift: Lesen der Zähler

Die Maus erzeugt etwa 200 Zählimpulse pro Zoll. Das sind etwa 79 Zählimpulse
pro Zentimeter. Da die Zähler umschließen, sollten wir die Mauseingabe oft
lesen, um ein gutes Verständnis von Richtung und Bewegung zu erhalten.

Wenn wir die Mauszähler bei jedem vertikalen Ausblenden lesen, liegt der
wahrscheinlichste Zählunterschied unter 127. Unterhalb dieser Schwelle 
behaupten wir, dass keine Umrundung abgeschlossen wurde.

Um diese Behauptung zu testen, berechnen wir die maximale Geschwindigkeit der
Maus, da die Zähldifferenz 127 zwischen vertikalen Ausblenden beträgt. In
Europa, wo der Amiga im PAL-Modus läuft, wird das vertikale Ausblenden alle
1/50 Sekunden erfolgen.

V-Maus = 127counts/((79counts/cm)*(1 second/50 )) = 80cm/second

Die Behauptung, dass keine Umhüllung für Zählunterschiede unter 127 auftritt,
gilt, wenn die Maus nicht schneller als etwa 3 Kilometer pro Stunde bewegt
wird. Für die meisten Anwendungsfälle sollte diese Behauptung halten, aber
sie kann scheitern, für schnelle Spiele. Die naheliegende Lösung besteht
darin, die Zähler öfter als einmal pro vertikalem Ausblenden zu lesen.

Brief XI umreißt einen Algorithmus, um die Richtung und Bewegung der Maus
zu bestimmen. Es ist ein relatives Maß, das der letzten bekannten absoluten
Position der Maus hinzugefügt werden sollte, und es sieht wie folgt aus:

// Pseudo code to determined signed counter_diff

counter_diff = counter_new - counter_old

	if ( counter_diff > 127 )
	   return counter_diff -= 256
	else if ( counter_diff < -128 )
	   return acounter_diff += 256
	else
	   return counter_diff

Die Bewegung wird als numerische Größe berechnet, die Länge bezeichnet, während
das Vorzeichen die Richtung bezeichnet. Für den x-Zähler ist links negativ und
rechts positiv. Für den y-Zähler ist hoch negativ und nach unten ist positiv.

Lassen Sie uns dies mit einigen Beispielen aus Brief XI veranschaulichen. Im
ersten Beispiel lesen wir zuerst den Wert 100 aus dem x-Zähler, und beim
nächsten Lesen erhalten wir den Wert 250. Durch die Verwendung des Algorithmus
erhalten wir

(250 - 100) - 256 = -106

Die Bewegung ist 106 Mauszähler zur linken Seite.

Abbildung 31-02: graf1

Im nächsten Beispiel lesen wir den x-Zählerwert 250, und beim nächsten Lesen
erhalten wir den Wert 10. Das Setzen dieser Zahlen in den Algorithmus zeigt

(10 - 250) + 256 = 16

Abbildung 31-03: graf2

Die Bewegung ist 16 Mauszähler zur rechten Seite.

Beachten Sie, dass wir nichts darüber gesagt haben, was Mauszähler in Pixeln
ist. Die Mausanzahl zur Pixeltransformation ist in der Regel eine Funktion der
bevorzugten Mausempfindlichkeit. Die Mausgeschwindigkeit kann z.B. in den
Workbench-Einstellungen eingestellt werden.

Abbildung 31-04: preferences

Die Maus-Unterroutine
Brief XI enthält das Programm mc1101, das die Verwendung der
Mausunterroutine demonstriert. Die Idee ist, dass Sie die Maus-Unterroutine in
Ihren eigenen Projekten verwenden sollten.

Das programm mc1101 ist in zwei Hauptunterroutinen unterteilt; Maus und
															 ; calc Maus

Die Mausunterroutine erfordert, dass Sie zwei Label mit je einem Byte
im Code platzieren, damit die x- und y-Pixelkoordinaten zurückgegeben werden
können. Dies hätte vielleicht etwas eleganter geschehen können, indem man die
Datenregister benutzte hätte...

mouse
Description: calculates mouse x and y pixel coordinate. Requires the labels
             mousex and mousey each allocated with one word.
Syntax:      calcmouse()
ML:          calcmouse()
Arguments:   
Result:      Stores the mouse x and y pixel coordinate at the labels mousex
             and mousey.

Die Maus-Unterroutine ruft calcmouse zweimal auf, um die relativen
Richtungsbewegungen der x- und y-Zähler zu erhalten. Diese Bewegungen werden
dann von der Mausunterroutine den Pixelkoordinaten zugeordnet.

Calcmouse ist ziemlich komplex und hat eine konvexierte Aufrufsyntax. Diese
Unterroutine sollte jedoch nur von der Mausunterroutine aufgerufen werden, die
wiederum vom Clientcode aufgerufen wird. Hier ist eine Beschreibung von calcmouse.

calcmouse
Description: calculates mouse x or y coordinate, given old and new 
             x or y count values, subject to lower and upper coordinate bounds.
Syntax:      calcmouse(oldCountPtr, 
                       newCoordinatePtr, 
                       newCount, 
                       lowerBound, 
                       upperBound)
ML:          calcmouse(a1, a2, d0, d2, d3)
Arguments:   oldCountPtr = The old x or y count value 
             newCoordinatePtr = The new coordinate value
             newCount = x or y mouse count
             lowerBound = coordinate lower bound
             upperBound = coordinate upper bound 
Result:      x or y coordinate is written to address of newCoordinatePtr

Hier ist die komplette Auflistung von mc1101 aus Letter XI. Der Code kann ein
wenig schwer zu folgen sein, also habe ich ihn mit Kommentaren besprüht, die
es hoffentlich ein wenig einfacher zu verstehen machen.

; file mc1101.s
main:							; just a label
	bsr	mouse					; branch to subroutine mouse

	lea.l	mousex,a1			; move mousex address into a1
	lea.l	mousey,a2			; move mousey address into a2

	move.w	(a1),d1				; move value at mousex address into d1
	move.w	(a2),d2				; move value at mousey address into d2



	btst	#6,$bfe001			; test left mouse button
	bne	main					; if not pressed goto main
	rts							; return from subroutine - exit program


mouse:							; subroutine (mousex, mousey) = mouse()
	movem.l	d0-d7/a0-a6,-(a7)	; save registers on stack
	move.w	$dff00a,d0			; move value in JOY0DAT to d0
	andi.l	#255,d0				; keep lower byte in d0 (mouse x counter) using immidiate AND
	moveq	#0,d2				; move 0 into d2 (lower bound on x)
	move.l	#639,d3				; move 639 into d3 (upper bound on x)
	lea.l	oldx,a1				; move oldx address into a1
	lea.l	mousex,a2			; move mousex address into a2
	bsr.s	calcmouse			; branch to subroutine calcmouse
	move.w	$dff00a,d0			; move value in JOY0DAT to d0
	lsr.w	#8,d0				; shift left 8 bits
	andi.l	#255,d0				; keep lower byte in d0 (mouse y counter) using immidiate AND 
	moveq	#0,d2				; move 0 into d2 (lower bound on y)
	move.l	#511,d3				; move 511 into d3 (upper bound on y)
	lea.l	oldy,a1				; move address of oldy into a1
	lea.l	mousey,a2			; move address of mousey into a2
	bsr.s	calcmouse			; branch to subroutine calcmouse
	movem.l	(a7)+,d0-d7/a0-a6	; load registers from stack
	rts							; return from subroutine
calcmouse:						; subroutine calcmouse(a1=oldCountPtr,a2=newCoordinatePtr,
								; d0=newCount,d2=lowerBound,d3=upperBound)
	moveq	#0,d1				; move 0 into d1
	move.w	(a1),d1				; move value from address in a1 (oldCount) to d1
	move.w	d0,(a1)				; move d0 (newCount) into address pointed to by a1
	move.l	d0,d5				; move d0 (newCount) into d5
	move.l	d1,d6				; move d1 (oldCount) into d6
	sub.w	d0,d1				; subtract word d0 (newCount) from d1 (oldCount) and
								; store result in d1 (countDiff)
	cmp.w	#-128,d1			; compare -128 with d1 (countDiff)
	blt.s	mc_less				; if d1 < -128 goto mc_less
	cmp.w	#127,d1				; compare 127 with d1 (countDiff)
	bgt.s	mc_more				; if d1 > 127 goto mc_more
	cmp.w	#0,d1				; compare 0 with d1 (countDiff)
	blt.s	mc_chk2				; if d1 < 0 goto mc_chk2
mc_chk1:						; label
	cmp.w	d5,d6				; compare d5 (newCount) with d6 (oldCount)
	bge.s	mc_chk1ok			; if d6 > d5 goto mc_chk1ok
	neg.w	d1					; negate d1 (countDiff)
	mc_chk1ok:					; label
	bra.s	mc_storem			; branch always to mc_storem
mc_chk2:						; label
	cmp.w	d5,d6				; compare d5 (newCount) with d6 (oldCount)
	ble.s	mc_chk2ok			; d6 < d5 goto mc_chk2ok
	neg.w	d1					; negate d1 (countDiff)
mc_chk2ok:						; label
	bra.s	mc_storem			; branch always to mc_storem
mc_less:						; label
	add.w	#256,d1				; add 256 to d1 and store in d1 (countDiff)
	bra.s	mc_storem			; branch always to mc_storem
mc_more:						; label
	sub.w	#256,d1				; subtract 256 from d1 and store in d1 (countDiff)
mc_storem:						; label
	neg.w	d1					; negate d1 (countDiff)
	add.w	d1,(a2)				; add d1 (countDiff) to the value pointed to by a2 (newCoordinatePtr)
	move.w	(a2),d0				; move value from address in a2 (newCoordinatePtr) to d0
	cmp.w	d2,d0				; compare d2 (lowerBound) with d0
	blt.s	mc_toosmall			; if d0 < d2 goto mc_toosmall
	cmp.w	d3,d0				; compare d3 (upperBound) with d0
	bgt.s	mc_toolarge			; if d0 > d3 goto mc_toolarge
	rts							; return from subroutine
mc_toosmall:					; label
	move.w	d2,(a2)				; move value in d2 (lowerBound) to address
								; pointed to by a2 (newCoordinatePtr)
	rts							; return from subroutine
mc_toolarge:					; label
	move.w	d3,(a2)				; move value in d3 (upperBound) to address
								; pointed to by a2 (newCoordinatePtr)
	rts							; return from subroutine
oldx:       
	dc.l	$0000				; allocate space for oldx (mouse x counter)
oldy:       
	dc.l	$0000				; allocate soace for oldy (mouse y counter)
mousex:       
	dc.w	$0000				; allocate space for mousex (mouse x coordinate)
mousey:       
	dc.w	$0000				; allocate space for mousey (mouse y coordinate)


Überschrift: Maus-Debugging

Um mehr ein Gefühl zu bekommen, wie die Maus funktioniert, lohnt es sich zu
untersuchen, wie sich die Zähler ändern und überlaufen, wenn die Maus bewegt
wird. Wir brauchen keinen Amiga, um dies zu tun, da der WinUAE Emulator den
Inhalt von JOY0DAT ausgeben kann.

Laut einem Beitrag auf dem englischen Amiga Board ist es ganz einfach, das
Debuggen der Maus einzuschalten.

Bevor Sie den Amiga starten, stellen Sie sicher, dass Sie die
Debugprotokollierung in WinUAE unter Eigenschaften aktivieren. Ich habe
"Log window" ausgewählt, damit ich die Updates in einem separaten Fenster sehen
kann.

Abbildung 31-05: logging

Starten Sie dann in die Workbench und drücken Sie shift+F12, um in den Debugger
zu gelangen. Verwenden Sie im Debugger den Befehl dj zusammen mit einer
Bitmaske. Im Folgenden habe ich den Hilfetext und die Bitmaskenoptionen hinzugefügt.

dj [<level bitmask>] Enable joystick/mouse input debugging. 

// 01 = host events
// 02 = joystick
// 04 = cia buttons
// 16 = potgo r/w
// 32 = vsync
// 128 = potgo write
// 256 = cia buttons write

Schreiben Sie noch im Debugger die erste Zeile. Die anderen drei Zeilen werden
gedruckt, wenn Sie die Eingabetaste drücken.

dj 2
Input logging level 2
JOY0DAT=f84a 00fc0f94
JOY1DAT=0000 00fc0f94

Die Ausgabe ist nur eine Momentaufnahme von JOY0DAT. Schließen Sie den
Debugger, damit das Protokollfenster Live-Daten schreibt

Abbildung 31-06: arabuusimiehet

Das Protokollfenster hat einen seltsamen Namen " Arabuusimiehet". Es sieht so
aus, als ob Toni Wilen wissen könnte, was es ist.

weblinks:
http://palbo.dk/dataskolen/maskinsprog/	
https://www.analogictips.com/rotary-encoders-part-1-optical-encoders/	; quadrature encoding
https://archive.org/details/Amiga_Hardware_Reference_Manual_1985_Commodore_a/page/n231
http://amiga-dev.wikidot.com/hardware:joy0dat							; joy0dat
https://www.winuae.net/			
http://eab.abime.net/showthread.php?t=98511
http://arabuusimiehet.com/break/amiga/faq.php
http://eab.abime.net/showthread.php?p=623706

;------------------------------------------------------------------------------
32 - Amiga Machine Code Letter XI - The Printer

Amiga Maschine Code Letter XI - Der Drucker
22.11.2019  10 min lesen

Zurück in den Amiga 500 Glory Days, war der Drucker einer dieser wesentlichen
Add-ons, die es Ihnen ermöglichte, etwas Physisches aus Ihrem
Textverarbeitungsprogramm oder Zeichenprogramm zu produzieren. Es war noch eine
Zeit, in der physische Drucke die einzige allgemein akzeptable Form der
nonverbalen Kommunikation waren.

In diesem Beitrag werden wir einen Blick auf ein Assemblercode werfen, der
eine Zeichenfolge auf den Drucker druckt, mit dem parallelen Anschluss. Der
Code stammt aus Brief XI des AMIGA Programming in Machine Code Kurses, und der
Code kann auf Disk1 gefunden werden. Wie immer, denken Sie daran, die Briefe
zu lesen, da ich nicht alle Details hier wiederholen werde.

Amiga-Drucker gab es in zwei Varianten, die einen mit dem seriellen Anschluss
und die anderen mit dem parallelen Anschluss. Die Drucker waren weniger für
einen allgemeinen Zweck, als sie heute sind. Einige Drucker waren gut darin,
viel Text und Zahlen schnell zu drucken, während andere auch gut im Drucken
von Grafiken waren. Einige Drucker konnten nur schwarzweiß machen, während
andere auch Farben drucken konnten.

Vor allem Laserdrucker waren sehr teuer, und einige konnten auch PostScript-
Druck machen. PostScript ist eine Skriptsprache für Grafiken, die viel
Computerleistung zum Interpretieren und Rastern erforderte. Daher kamen einige
frühe PostScript-Drucker auch mit einer eigenen CPU, wie der Motorola 68K. Es
gibt sogar Beispiele für Drucker mit Mikroprozessoren, die schneller liefen,
als die Computer, die auf sie druckten.

Damals konnten sich nur Profis Laser-PostScript-Drucker leisten. Wir, die nur
Sterblichen, mussten billigere Alternativen für den Druck von Grafiken
verwenden, wie den Okimate 20 Colour Drucker, der Teil meines Setups war, als
ich ein Kind war.

Der Okimate 20 war ein Thermodrucker, der einen 24 x 24-poligen Kopf benutzte,
um drei Farbpunkte von einem dreifarbigen Wachsband auf das Papier zu
übertragen. Die kleinen Punkte würden dann durch das Auge gemischt, um
eine Fülle von reichen Farben zu schaffen, mit einem glänzenden Finish. Hier
ist ein Rückblick auf den Okimate 20 von 1986.

Und so sah der Drucker aus. Bild von Pintrest.

Abbildung 32-01: Okimate 20

Sie brauchten das Band eigentlich nicht, da dieser Thermodrucker schwarzweiß
direkt auf das Thermopapier drucken konnte. Ich mochte das Thermopapier nicht,
welches für eine kontinuierliche Zufuhr, auf einer Rolle geliefert wurde, da
es dünn und schrecklich gealtert war, so dass ich es in der Regel danach auf
Standard-Papier fotokopiert habe.

Da ich keinen Zugriff mehr auf die physische Hardware habe, muss ich mich beim
Drucken auf WinUAE verlassen. Das schränkt meine Optionen ein wenig auf das
ein, was die Windows-Drucker verstehen können.

Ich hätte wirklich gerne einige Grafiken in diesem Beitrag gedruckt, aber ich
bezweifle, dass es PostScript-Treiber für Workbench 1.3 gibt.

Überschrift: Drucken aus WinUAE

Bevor wir mit der Betrachtung des eigentlichen Codes beginnen, müssen wir
sicherstellen, dass unser Setup richtig konfiguriert ist, um den einfachsten
Druckvorgang zu tätigen.

Schalten Sie WinUAE aus, und gehen Sie in die IO-Porteinstellungen, und stellen
Sie sicher, dass der parallele Port für einen Microsoft XPS Document Writer
konfiguriert ist und der Typ Epson Matrix Printer Emulation ist. Ich habe die
48-Polige-Version verwendet.

Abbildung 32-02: WinUAE printer setup

Bei dieser Konfiguration geht es um die grundlegendste Konfiguration, die Sie
erhalten können. Dies bringt Sie nicht weiter als Rohtextdruck. Vergessen Sie
das Drucken stilvoller Schriftarten oder Grafiken. Der Kern davon ist, dass die
Epson Matrixdrucker-Emulation eine sehr einfache Druckersteuerungssprache
bietet, die von fast allen Windows-Druckern universell unterstützt wird. Meine
Vermutung ist, dass es PCL 1 oder ESC/P ist, aber ich habe dies nicht überprüft.

Überschrift: Testdruck

Ein einfacher Test der Druckeinrichtung kann über die CLI durchgeführt werden.
Wechseln Sie in die CLI, und leiten Sie die Ausgabe des List-Befehls an den
parallelen Port um.

Abbildung 32-03: List redirect output to parallel port

Auf diese Weise umgehen wir den Druckertreiber im AmigaOS, indem wir direkt an
den Parallelport ausgeben. Außerhalb von WinUAE wird dadurch der
Windows-Drucker ausgelöst.

Hier ist ein Teil meiner Ausgabe aus dem Listenbefehl, der im C-Ordner von
Workbench 1.3 ausgeführt wird.

Abbildung 32-04: Output from list

Wenn dies funktioniert, dann versuchen Sie, die Ausgabe an PRT: umzuleiten, was
der Drucker ist. Diese Umleitung erfolgt über den Druckertreiber. In
Workbench 1.3 habe ich den generischen Druckertreiber verwendet, und ich konnte
eine Ausgabe erhalten, die mit der oben genannten übereinstimmt.

Überschrift: Drucken über den Parallelport

Die später beschriebene Druckunterroutine verwendet die 8520 Complex Interface
Adapter (CIA) Chips des Amiga, die CIAA und CIAB genannt werden.

Die CIA-Chips verarbeiten u.a. E/A-Aktivitäten über die Tastatur, den seriellen
und den parallelen Anschluss. Wir werden den parallelen Anschluss verwenden,
um mit dem Drucker zu kommunizieren.

Der parallele Port ist mit dem CIAA-Chip verbunden und kann sowohl für die
Eingabe als auch für den Ausgang verwendet werden. In unserem Fall werden wir
Zeichen an den Drucker senden, also müssen wir Daten ausgeben.

Wir sagen CIAA, welche Zeichen gesendet werden sollen, indem wir acht Bits an
den prb-Port ($BFE101) schreiben und die Datenrichtung ddrb ($BFE301) für jeden
der acht Pins in prb auf 1 setzen.

Der De-facto-Standard für Drucker in den späten achtziger Jahren war die
Verwendung eines Centronics-Steckers auf der Druckerseite und verschiedener
Anschlüsse auf der Hostseite. Der Amiga verwendete den DB25-Buchsenstecker.

Hier ist ein Pinout, die den DB25-Stecker zeigt, mit den 8 Pins von prb
hervorgehoben.

Abbildung 32-05: db25 pinout data

Überschrift: Druckerstatuscodes

Der Drucker kann das Hostsystem über seinen Status informieren, indem er
separate Pins am parallelen Anschluss setzt. Der Status dieser Pins kann über
das pra-Register auf dem CIA-B-Chip ($BFD100) abgerufen werden.

Das pra-Register ist 8 Bit breit, aber nur die ersten drei Bits beziehen sich
auf Statuscodes für den Drucker. Es ist SEL, POUT und BUSY, die für
ausgewähltes Papier und beschäftigt steht. Hier ist die Pinbelegung.

Abbildung 32-06: db25 pinout control lines

Drucker der späten achtziger Jahre, arbeiteten ein bisschen anders als
heutige Drucker. Hinweise hierfür finden Sie im Druckerhandbuch für den Drucker
Centronics Model 101 (PDF), das 1978 geschrieben wurde.

Der Drucker muss angeschlossen oder ausgewählt sein, bevor er Daten empfangen
kann. Wenn der Drucker deaktiviert ist, wird er ebenfalls beschäftigt. Im
deaktivierten Zustand kann der Operator das Papier mit den Schaltflächen für
Formular- und Zeilenvorschub laden oder andere Anpassungen vornehmen.

Drucker verwendeten häufig kontinuierliches Vorschubpapier, und die
Schaltfläche Formularvorschub würde das Papier zum nächsten Blatt führen.
Linienvorschub funktioniert ähnlich, aber nur eine Linie.
Sowohl Formularvorschub als auch Zeilenvorschub sind Steuercodes in der
ASCII-Tabelle.

Abbildung 32-07: Hier ist ein Video, das einen alten Epson-Drucker in Aktion
				 zeigt.

Beachten Sie, dass die Schaltflächen Zeilenvorschub und Formularzuführung
nicht bedient werden können, während der Drucker ausgewählt ist.
Druckerpuffer haben auch einen großen Einfluss auf die Druckgeschwindigkeit.
Z.B. der vorhin erwähnte Centronics 101 Drucker, besitzt einen Puffer, der
nur 132 Zeichen enthält. Dies reicht gerade aus, um eine Textzeile zu
enthalten, wie sie von den meisten Zeilendruckern definiert wird. Dadurch
konnte der Drucker eine ganze Zeile gleichzeitig schreiben. Wenn der Puffer
z.B. einen Carriage Return-Code (auch in der ASCII-Tabelle) enthält, würde
der Drucker in der Dauer des Verschiebens des Papiers ausgelastet sein.

Ich konnte dieses Verhalten auf einem modernen Drucker nicht nachstellen,
wahrscheinlich aufgrund einer Mischung aus ihren großen Puffern und
modernen Betriebssystemen mit einer Druckerwarteschlange.

Überschrift: Der Code

Werfen wir einen Blick auf das programm mc1102 von Disk1. Das Programm
druckt einen Null-Beendeten-Puffer mit Zeichen auf dem Drucker, indem es
den parallelen Anschluss verwendet.

Die Signatur für die Druckunterroutine sieht so aus.

Subroutine:  print
Description: Prints characters stored in a buffer
Syntax:      status = print(buffer)
ML:          d0 = print(a0)
Arguments:   buffer = zero terminated array of characters
Result:      status code
             0 = OK
             1 = POWER OFF
             2 = OFFLINE
             3 = PAPER OUT

Der Code beginnt damit, dass alle Interrupts für die Dauer des Aufrufs an die
Druckunterroutine deaktiviert werden.

Die Druckunterroutine beginnt mit der Einstellung der Datenrichtung für
Port b, ddrb ($BFE301), um $FF, so dass alle Pins auf prb ($BFE101)
Ausgabepins sind. Dies geschieht auf dem CIAA-Chip.

Wenn der Drucker druckbereit ist, d. h. ausgewählt ist, wird die
Druckunterroutine mit dem Drucken aller Zeichen im Eingabepuffer fortgesetzt,
bis der Nullabschluss erreicht ist.

Die Druckunterroutine überprüft auch die Statuscodes des Druckers und wird
beendet, wenn der Drucker nicht mehr auf Papier oder nicht online ist oder
ausgeschaltet ist. Die Statuscodes sind die drei am wenigsten signifikanten
Bits von pra ($BFD 000): SEL, POUT, BUSY. Dies geschieht auf dem CIAB-Chip.

; file mc1102.s
	lea.l	buffer,a0			; store address of buffer into a0

	move.w	#$4000,$dff09a		; INTENA clear master interrupt
	bsr	print					; branch to subroutine print
	move.w	#$c000,$dff09a		; INTENA set master interrupt

	rts							; return from subroutine

buffer:							; label for the buffer
	dc.b	"Dette er en test av en printer-rutine.",10  ; text to be printed with added linefeed
	dc.b	0                                            ; null termination of the string


print:							; label for the print subroutine
	move.b	#$ff,$bfe301		; ddrb set all pins to output for the parallel port prb

wait:
	move.b	$bfd000,d0			; move data in pra into d0
	andi.b	#%111,d0			; only keep 3 first bits in d0 - control lines SEL, POUT, BUSY
	cmp.b	#%100,d0			; compare 4 with d0 - SEL=1, POUT=0, BUSY=0
	beq.s	ready				; if equal, goto label ready
	cmp.b	#%001,d0			; compare 1 with d0 - SEL=0, POUT=0, BUSY=1
	beq.s	offline				; if equal, goto label offline 
	cmp.b	#%111,d0			; compare 7 with d0 - SEL=1, POUT=1, BUSY=1
	beq.s	poweroff			; if all bits are set high, goto subroutine poweroff
	cmp.b	#%001,d0			; compare 1 with d0 - SEL=0, POUT=0, BUSY=1
	beq.s	wait				; if equal, goto label wait
	cmp.b	#%011,d0			; compare 3 with d0 - SEL=0, POUT=1, BUSY=1
	beq.s	paperout			; if equal, goto label paperout
	bra.s	wait				; branch always to wait

ready:							; label
	move.b	(a0)+,d0			; move value a0 points to into d0 and then increment a0 by a byte
	cmp.b	#0,d0				; compare 0 with d0 - we could use tst here
	beq.s	stop				; if the zero termination of the string is reached then goto stop
	move.b	d0,$bfe101			; move value in d0 into the parallel port prb
	bra.s	wait				; goto wait

stop:							; label
	moveq	#0,d0				; move quick 0 into d0
	rts							; return from subroutine

poweroff:						; label
	moveq	#1,d0				; move quick 1 into d0
	rts							; return from subroutine

offline:						; label
	moveq	#2,d0				; move quick 2 into d0
	rts							; return from subroutine

paperout:						; label
	moveq	#3,d0				; move quick 3 into d0
	rts							; return from subroutine

Auch wenn es ein einfaches Programm ist, kann es ein bisschen schwer sein, zu
folgen. Also habe ich ein Diagramm davon gemacht.

Abbildung 32-08: diagram

Nachdem ich das Programm in Seka ausgeführt hatte, bekam ich diesen "netten"
Ausdruck.

Abbildung 32-09: The printed document

Überschrift: Multitasking - was ist damit?

Das programm mc1102 beginnt mit der Deaktivierung aller Interrupts, was auf
einem Multitasking-System wie dem AmigaOS "nicht so gut" wäre. Ich denke, dass
die Autoren des Amiga Machine Code Kurses die Dinge einfach halten wollten,
aber die Folge ist, dass das ganze System einfrieren wird, während unser
Programm läuft.

Was sie hätten tun sollen, war, die Ressource, in diesem Fall den Drucker, in
den Griff zu bekommen. Dann müssten alle anderen Aufgaben, die den Drucker
angefordert haben, warten, bis wir damit fertig sind.

Überschrift: Bonusmaterial

Ich fragte mich, warum, das Senden von Daten an den Drucker und das Abrufen
seiner Steuercodes, sowohl CIAA als auch CIAB erforderte.

Um diese Frage zu beantworten, fand ich die Hardware-Schemas des Amiga 500
bei amigawiki (PDF) und es enthält auch den Schaltplan für die seriellen und
parallelen Ports.

Wie unten zu sehen, verbindet sich die blaue Datenlinie prb ($BFE101) mit CIAA,
während die roten Linien, pra ($BFD000), mit CIAB verbunden sind.

Ich habe mich auch gefragt, wie die Datenrichtung, ddrb ($BFE301), auf CIAA
funktioniert hat. Ich fand die Spezifikationen (PDF) für die CIA 6526 / 8520,
entschied mich aber dagegen, in dieses Kaninchenloch zu gehen. Dieser Beitrag
ist bereits lang genug.

Abbildung 32-10: cia schematics

Während ich die Schaltpläne las, sah ich den Namen B52/ROCK LOBSTER. Es stellt
sich heraus, dass dieser mysteriöse Text auf allen Amiga 500-Platinen
geschrieben ist. Laut dem Amiga-History Guide wurde dies von George Robbins
eingeführt, der für die meisten Low-End-Amiga-Systeme verantwortlich war. Der
Amiga 500 wurde unter dem Arbeitstitel B52 entwickelt.

weblinks:
http://palbo.dk/dataskolen/maskinsprog/						; Disk1
https://en.wikipedia.org/wiki/PostScript					; PostScript
https://www.atarimagazines.com/v5n6/Okimate20.html			; OKIMATE 20
https://www.pinterest.de/pin/237494580319618602/			; 
https://www.winuae.net/										; WinUAE
http://eab.abime.net/showthread.php?p=1352597				; PostScript drivers 
https://en.wikipedia.org/wiki/Page_description_language		; printer control language
https://en.wikipedia.org/wiki/Printer_Command_Language		; PCL1
https://en.wikipedia.org/wiki/ESC/P							; ESC/P
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node012E.html	; CIA
https://en.wikipedia.org/wiki/Parallel_port					; Centronics
http://www.bitsavers.org/pdf/centronics/
37400010H_Centronics_Model_101_Printer_Technical_Manual_May1978.pdf	; Centronics Model 101 printer
https://www.computerhope.com/jargon/f/formfeed.htm			; Form Feed
https://www.asciitable.com/									; ASCII Tabelle
https://youtu.be/y6uhqwOID0Q								; Video Dot Matrix Drucker
https://en.wikipedia.org/wiki/Line_printer					; Line Printer
https://www.amigawiki.org/dnl/schematics/A500_R6.pdf		; A500 Schaltplan
http://archive.6502.org/datasheets/mos_6526_cia_recreated.pdf	; CIA specs
https://en.wikipedia.org/wiki/MOS_Technology_CIA			; MOS Technology CIA
http://www.amigahistory.plus.com/b52board.html				; ?
https://www.amigawiki.org/doku.php?id=de:history:robbins	; George Robbins

;------------------------------------------------------------------------------
33 - Amiga Machine Code Letter XI - Fizzle Fade

Amiga Maschine Code Letter XI - Fizzle Fade
01.01.2020  9 min lesen

In diesem Beitrag werden wir uns eine ordentliche Technik ansehen, um
schnelle Multiplikationen zu machen. Die Technik wird im letzten Kapitel des
Briefes XI ausführlich beschrieben und beinhaltet Bitshifting anstelle einer
naiven Multiplikation.

Beim Aufrufen von 68K-Anweisungen dauert die Ausführung einiger Anweisungen
länger als andere. Eine der teureren Aufrufe ist die Multiplikationsanweisung
MULU.

Werfen wir einen Blick auf eine naive Implementierung einer Unterroutine, die
ein Pixel auf den Bildschirm zeichnet. Es verwendet MULU, um den Offset in
Bytes für die y-Koordinate relativ zur Startadresse des Bildschirmpuffers zu
finden.

Der Code geht davon aus, dass der Bildschirm 320 Pixel breit ist, was 40 Bytes
entspricht. Wir finden den Offset für die y-Koordinate relativ zum Anfang des
Bildschirmpuffers, indem wir mit 40 multiplizieren.

Als nächstes finden wir den Offset in Bytes für die x-Koordinaten, indem wir
sie durch 8 dividieren. Die ersten drei Bits der x-Koordinate werden bearbeitet,
um ihre Bitposition anzuzeigen, so dass wir dieses Bit festlegen und das Pixel
zeichnen können.

; pixel subroutine
; Draws a pixel on the screen given an x and y coordinate. There must be 
; a label named "screen" at the beginning of a 320 * 256 pixel screen buffer.
; Syntax: pixel(x=d0, y=d1)
; Arguments: x = The x coordinate
;            y = The y coordinate
; Result: A single pixel is drawn to the screen.
pixel:
    ; ----------------------- finding x and y offsets
    mulu    #40,d1          ; multiply y with 40. 320 pixels / 8 bits = 40 bytes
    move.w  d0,d2           ; move x into d2
    lsr.w   #3,d0           ; divide x with 8 by shifting right
    ; ----------------------- finding the bit to set
    not.b   d2              ; invert d2
    andi.w  #7,d2           ; just keep the 3 first bits
    ; ----------------------- finding the combined offset of x and y
    add.w   d1,d0           ; add and store the result in d0
    lea.l   screen,a1       ; put the address of screen in a1
    bset    d2,(a1,d0.w)    ; set the d2'th bit of a1 + d0.w
    rts                     ; return from subroutine

Beachten Sie, dass wir im obigen Code die x-Koordinate durch 8 teilen, indem
wir die Bits drei Schritte nach rechts verschieben. Die gleiche Technik kann
für die Multiplikation verwendet werden, indem die Bits nach links verschoben
werden.

Anstatt die y-Koordinaten mit 40 zu multiplizieren, können wir dasselbe mit
einer Reihe von Linksverschiebungsoperationen erreichen.

offset_y = 40*y
	     = (8+32)*y
		 = (8+8*4)*y

Das Endergebnis sieht wie folgt aus:

pixel:
    lsl.w   #3,d1			; multiply d1 with 8 and store in d1
    move.w  d1,d3			; move d1 into d3
    lsl.w   #2,d1			; multiply d1 with 4 and store in d1
    add.w   d3,d1			; store (y*8)+(y*32)=y*40 in d1
    move.w  d0,d2			; move d0 into d2
    lsr.w   #3,d0			; divide d0 with 8 and store in d0
    not.b   d2				; invert d2
    andi.w  #7,d2			; keep 3 least significant bits
    add.w   d1,d0			; add the offsets from x and y
    lea.l   screen,a1		; store address of screen in a1
    bset    d2,(a1,d0.w)	; set the d2'th bit of a1 + d0.w
    rts

Die Pixelroutine bietet keine Begrenzungsprüfungen für x und y. Wir müssen
diese Prüfungen an den aufrufenden Stellen durchführen.

Als nächstes testen wir die Pixelroutine mit einer speziellen Funktion, die
sicherstellt, dass alle Pixel in einem scheinbar zufälligen Muster erstellt
werden.

Überschrift: Fizzle Fade

Der Fizzle Fade-Effekt zeichnet scheinbar zufällige Pixel auf dem Bildschirm,
bis der Bildschirm vollständig bedeckt ist. Dies macht den Effekt zu einem
perfekten Kandidaten für das Testen einer Routine, die Pixel zeichnet.

Ich habe den Effekt zum ersten Mal im Spiel Wolfenstein 3D gesehen, aber erst
als ich auf Fabien Sanglards Seite davon las, verstand ich das Innenleben
wirklich. Übrigens, Sie können das Spiel hier versuchen.

Abbildung 33-01: Fizzle fade

Der überraschendste Aspekt des Effekts ist, dass es keine Buchführung dazu
erfordert, welche Pixel bereits gezeichnet wurden. Es wird einfach über eine
Folge von Zahlen wiederholt, bis es wieder auf den ursprünglichen Ausgangswert
trifft. Es ist eine einfache Do-while-Schleife, und die Magie, die dies möglich
macht, ist etwas, das als lineares Feedback-Shift-Register (LFSR) bezeichnet
wird.

Das LFSR hat eine bestimmte Länge m und eine Reihe von Registerkarten, die als
Rückmeldungen in die LFSR dient, wenn eine 1 aus dem Register verschoben wird.
Es erzeugt eine periodische Sequenz, die jeden möglichen Zustand des Registers
von 2^m-1- Zahlen erzeugen kann, aber nur für eine spezielle Konfiguration von
Registerkarten. Eine solche Sequenz wird als maximale Längensequenz (MLS)
bezeichnet.

Ein LFSR, der als Maximallängengenerator konfiguriert ist, kann zwei Sequenzen
erzeugen. Eine ist die triviale Sequenz der Länge 1, die auftritt, wenn ein
Satz nur Nullen verwendet wird. In diesem Fall wird der Generator nur Null
produzieren. Die andere Sequenz erzeugt die gewünschten 2^m-1 Zahlen für jeden
Satz, mit Ausnahme von Null. Zusammengenommen sind die Sequenzen für alle
Zustände der LFSR 2^m.

Mit der MLS-Konfiguration können wir die Sequenz Pixeln zuordnen, und da wir
wissen, dass alle Zustände in der LFSR abgedeckt wurden, wissen wir auch, dass
der gesamte Bildschirm mit Pixeln gefüllt wird. Das ist überraschend schön.

Wenn Sie mehr über die LFSR und ihre Funktionsweise erfahren möchten, werfen
Sie einen Blick auf die Website von Fabien Sanglard oder diese archivierte
Seite.

Überschrift: Fizzle Fade auf dem Amiga

Der folgende Code testet die Pixelroutine, indem Pixel gezeichnet werden, die
durch den Effekt Fizzle Fade bestimmt werden. Auf dem Amiga sieht der Effekt
wie dieser aus.

Abbildung 33-02: Fizzle fade

Der Code beginnt, indem der Bildschirm mit gelben Pixeln in einer Schleife
gefüllt wird. Wenn der ursprüngliche LFSR-Status erkannt wird, wissen wir, dass
der Bildschirm gefüllt wurde. Ich kehre dann den Effekt um, indem ich Pixel
lösche, so dass wir einen pulsierenden Effekt erhalten, der so lange anhält,
bis die linke Maustaste gedrückt wird.

Die Bildschirmauflösung beträgt 320 * 256, was bedeutet, dass wir die LFSR so
konfigurieren müssen, dass der maximale Längengenerator mindestens 81.920
Zustände erzeugen kann. Mit diesen Informationen finden wir die LFSR-Länge m.

Mit m=16, erhalten wir 2^16 = 65536 Zustände, was nicht ausreicht, um den
Bildschirm zu füllen, also müssen wir m=17 verwenden, was zu den Zuständen
von 2^17 = 131.072 führt, was mehr als genug ist.

Die nächste Herausforderung besteht darin, die MLS-Konfigruation von Tabs zu
finden. Ich habe dies nicht selbst herausgefunden, aber eine Tabelle mit
MLS-Konfigurationen verwendet, die hier zu finden sind. Die Tabelle zeigt, dass
wir zwei Registerkarten verwenden sollten. Eine Registerkartean Position 17
und eine weitere Registerkarte an Position 14.

Das komplette Programm ist unten zu sehen. Beachten Sie, dass ich eine
Begrenzungsprüfung auf der x-Koordinate (x < 320) habe, aber keine für die
y-Koordinate, da ich den y-Wert so maskiert habe, dass er nur ein Byte von
Daten enthält, so dass er nie größer als die Bildschirmhöhe von 256 Pixeln sein
kann.

; file mc1219.s
initial_fizzle_state = 1
pixel_value = 1

start:
    move.w #$01a0,$dff096	; DMACON disable bitplane, copper, sprite

    ; set up 320x256
    move.w #$1200,$dff100	; BPLCON0 enable 1 bitplane, color burst
    move.w #$0000,$dff102	; BPLCON1 (scroll)
    move.w #$0000,$dff104	; BPLCON2 (video)
    move.w #0,$dff108		; BPL1MOD
    move.w #0,$dff10a		; BPL2MOD
    move.w #$2c81,$dff08e	; DIWSTRT top right corner ($81,$2c)
    ;move.w #$f4c1,$dff090	; DIWSTOP enable PAL trick
    move.w #$38c1,$dff090	; DIWSTOP buttom left corner ($1c1,$12c)
    move.w #$0038,$dff092	; DDFSTRT
    move.w #$00d0,$dff094	; DDFSTOP

    lea.l screen,a1			; address of screen into a1
    lea.l bplcop,a2			; address of bplcop into a2
    move.l a1,d1
    move.w d1,6(a2)			; first halve d1 into addr a2 points to + 6 words
    swap d1					; swap data register halves
    move.w d1,2(a2)			; second halve d1 into addr a2 points to + 2 words

    lea.l copper,a1			; address of copper into a1
    move.l a1,$dff080		; COP1LCH, move long, no need for COP1LCL

    move.w #$8180,$dff096	; DMACON enable bitplane, copper
    
    move.w #initial_fizzle_state,d0 ; initial fizzle state
    move.w #pixel_value,d2	; initial pixel value
    lea.l screen,a1			; address of screen into a1
main:        
    bsr fizzle
    cmp.l #initial_fizzle_state,d0
    bne do_not_toggle_pixel_value
    eor.b #1,d2
do_not_toggle_pixel_value:    
    btst #6,$bfe001			; test left mouse button
    bne main				; if not pressed go to main

exit_main:
    move.w  #$0080,$dff096  ; restablish DMA's and copper
    move.l  $4,a6
    move.l  156(a6),a1
    move.l  38(a1),$dff080
    move.w  #$80a0,$dff096
    rts

; fizzle subroutine
; Fills the screen with pseudo random pixels using LFSR.
; Syntax: (d0=state) = fizzle(d0=state, d2=set_or_clear, a1=screen)
; Arguments: state = state of the LFSR
;            screen = address of the screen buffer 320*256
; Result: d0: state of the LFSR
fizzle:
    movem.l d1/d5/d6,-(a7)
    move.l d0,d5
    and.l  #$1ff00,d0		; mask x value
    lsr.l  #8,d0

    move.l d5,d1
    and.l #$ff,d1			; mask y value

    move.l d5,d6    
    lsr.l #1,d5
    btst #0,d6
    beq lsb_is_zero
    eor.l #$12000,d5		; %0001 0010 000 000 000 - tabs on 17 and 14 length 17
lsb_is_zero:
    cmp.l #320,d0
    bge exit_fizzle
    bsr pixel
exit_fizzle:
    move.l d5,d0
    movem.l (a7)+,d1/d5/d6
    rts

; pixel subroutine
; Draws a pixel on the screeen given an x and y coordinate
; Syntax: pixel(d0=x, d1=y, d2=set_or_clear, a1=screen)
; Arguments: x = The x coordinate
;            y = The y coordinate
;            set_or_clear = If 0 clear pixel, otherwise set pixel
;            screen = address of the screen buffer
pixel:
    movem.l d0-d1/d3-d4,-(a7)
    lsl.w   #3,d1			; multiply d1 with 8 and store in d1
    move.w  d1,d3			; move d1 into d3
    lsl.w   #2,d1			; multiply d1 with 4 and store in d1
    add.w   d3,d1			; store (y*8)+(y*32)=y*40 in d1
    move.w  d0,d4			; move d0 into d4
    lsr.w   #3,d0			; divide d0 with 8 and store in d0
    not.b   d4				; invert d4
    andi.w  #7,d4			; keep 3 least significant bits
    add.w   d1,d0			; add the offsets from x and y 
    tst		d2
    beq     clear_pixel
    bset    d4,(a1,d0.w)	; set the d4'th bit of a1 + d0.w
    bra     cont
clear_pixel:
    bclr    d4,(a1,d0.w)	; set the d4'th bit of a1 + d0.w
cont:
    movem.l (a7)+,d0-d1/d3-d4
    rts						; return from subroutine

copper:
    dc.w $2c01,$fffe		; wait($01,$2c)
    dc.w $0100,$1200		; move to BPLCON0 enable 1 bitplane, color burst

bplcop:
    dc.w $00e0,$0000		; move to BPL1PTH
    dc.w $00e2,$0000		; move to BPL1PTL

    dc.w $0180,$0000		; move to COLOR00 black
    dc.w $0182,$0ff0		; move to COLOR01 yellow

    dc.w $ffdf,$fffe		; wait($df,$ff) enable wait > $ff horiz
    dc.w $2c01,$fffe		; wait($01,$12c)
    dc.w $0100,$0200		; move to BPLCON0 disable bitplane
							; needed to support older PAL chips.
    dc.w $ffff,$fffe		; end of copper

screen:
    blk.b 10240,0			; allocate block of bytes and set to 0

Im nächsten Beitrag werde ich mir den Brief XII anschauen - den letzten Brief
des Amiga Machine Code Kurses.

weblinks:
https://archive.org/details/bitsavers_motorola68nualRev1Dec90_10671468/page/n167/mode/2up	; MULU
https://en.wikipedia.org/wiki/Wolfenstein_3D					; Wolfenstein_3D
https://www.fabiensanglard.net/fizzlefade/index.php				; Fabien Sanglard’s website
https://classicreload.com/wolfenstein-3d.html					; play wolfenstein-3d
https://en.wikipedia.org/wiki/Linear-feedback_shift_register	; LFSR
https://web.archive.org/web/20040203192542/http://www.newwaveinstruments.com/
resources/articles/m_sequence_linear_feedback_shift_register_lfsr.htm	; LFSR
https://docs.google.com/spreadsheets/d/
1hnFigZpPEBg9hdFjImPzOgRsgZWAYupFBaTePN0BuAw/edit?hl=en&hl=en#gid=0		; LFSR Tabelle

;------------------------------------------------------------------------------
34 - Amiga Machine Code Letter XII- HAM

Amiga Machine Code Letter XII - HAM
Feb 22, 2020  15 min lesen

Der Amiga hatte einen der fotorealistischsten Bildmodi in den späten 80er
Jahren, der massive 4096 Farben zur gleichen Zeit zeigen konnte - etwas, das 
noch nie zuvor in einem Heimcomputer-System gesehen wurde. Der Bildmodus heißt
HAM, was kurz für Hold and Modify steht, und wenn Sie bei mir bleiben, werde
ich Ihnen sagen, worum es geht, und auch ein kleines Assemblerprogramm
demonstrieren, das dieses Zeug ermöglicht.

Dieser Beitrag ist inspiriert von Letter XII des Amiga Programming in Machine
Code Kurses, und der Code, den ich später präsentiere, stammt von Disk2 aus
demselben Kurs.

Überschrift: Festlegen der Szene

Der Amiga war der erste Multimedia-Computer für zu Hause, und er war in der
Lage, Stereo-Sound zu liefern und fotorealistische Bilder anzuzeigen. So etwas
hatte man in den 80er Jahren noch nicht gesehen und dadurch eroberte er die
Welt im Sturm.

Der Amiga basiert auf planar anstatt chunky Grafik. Jay Miner, der auch bekannt
als der Vater des Amigas ist, erwähnte dies in dem Buch The Future Was Here,
als eines seiner großen Amiga Design. 

Planare Grafiken verwenden Bitebenen, um jedem Pixel einen Wert zur Verfügung
zu stellen, der einem Farbindex zugeordnet ist. Diese Technik spart
Speicher, da die Anzahl der Farben im Bild von der Anzahl der verwendeten
Bitebenen abhängt. Wenn Sie nur zwei Farben benötigen, verwenden Sie eine
Bitebene, und wenn mehr Farben benötigt werden, fügen Sie einfach weitere
Bitebenen hinzu. Mit dieser Methode können Sie 32 Farben erreichen, die
5 Bitebenen verwendet.

Chunky-Grafiken stellen Pixel mit einer festen Farbtiefe dar. Der Amiga
verwendet einen 12-Bit-Farbraum mit 16 Ebenen für Rot, Grün und Blau, und wenn
der Amiga chunky Grafik hätte, würde jedes Pixel 12 Bit Speicher aufnehmen,
unabhängig davon, wie viele Farben Sie wirklich benötigten. In Wirklichkeit
würde ein chunky System 16 Bit pro Pixel aufnehmen, da jedes Pixel im
Speicher wortorientiert sein muss. Chunky Grafik ist verschwenderisch, aber
eine leistungsstarke einfache Abstraktion.

Da der Amiga ein planares System mit höchstens 32 Farbindizes verwendete, wie
auf der Erde war der Amiga in der Lage, 4096 Farben gleichzeitig anzuzeigen?
Nun, es war ein Trick erforderlich.

Überschrift: Halten und Ändern

HAM steht für Hold And Modify, was für diesen Farbmodus sehr aufschlussreich
ist. Ein Pixel enthält eine Farbe, und die nächsten Pixel entlang der Scanlinie
werden dann jeweils eine Primärfarbe geändert. Es kann bis zu drei Pixel
dauern, um die gewünschte Farbe zu erhalten.

Schauen wir uns ein Beispiel an. Wir haben eine originale Pixelsequenz mit
einer 12-Bit-RGB-Farbe, die wir in HAM konvertieren möchten. Im HAM-Modus
können wir nur eine Primärfarbe in jedem Pixel konvertieren, so dass es drei
Pixel dauert, bis wir die grüne Farbe (0,15,0) in die Ziel-Purpurfarbe
(12,9,14) konvertieren können.

Abbildung 34-01: ham pixels

Ok, jetzt, da wir gesehen haben, wie Pixel geändert werden, was ist dann mit
der Haltefarbe? Im obigen Beispiel ist die Haltefarbe die grüne, und es ist ein
Indexwert, der von den ersten vier Bitebenen gemacht wird, der durch
Farbrichtung auf eines der ersten 16 Farbregister COLORxx zeigt. Diese Farben
sollen auch Grundfarben sein.

Da die Farben geändert werden, indem sie von einer Grundfarbe beginnend sind,
muss jede Linie in einem HAM-Bild mit einer Grundfarbe beginnen. Gelingt dies
nicht, wird der Amiga nicht abstürzen, aber die Ausgabe wird unvorhersehbar
sein.

Werfen wir einen genaueren Blick auf die kniffligen Details. Der HAM-Modus
erfordert 6 Bitebenen, die ersten vier Bitebenen sind entweder die Farbrichtung
oder eine Änderung der roten, grünen oder blauen Farbe des vorherigen Pixels.
Die fünfte und sechste Bitebene definiert die Interpretation der ersten vier
Bitebenen, z.B. ist es eine Farbrichtung oder eine rote, grüne oder blaue
Farbänderung.

Bitplane 1-4 Farbregister oder Farbpegel (0 - 15)
Bitplane 5-6 Interpretation von Bitplane 1-4

Die Interpretation ist:
Wenn Bit 6 und 5 %00 ist, ist Bits 1-4 ein Farbregister
Wenn Bit 6 und 5 %01 ist, ist Bits 1-4 eine blaue Farbänderung
Wenn Bit 6 und 5 %10 ist, ist Bits 1-4 eine rote Farbänderung
Wenn Bit 6 und 5 %11 ist, ist Bits 1-4 eine grüne Farbänderung

Die Farbänderung funktioniert, indem die Farbe vom linken Pixel zuerst
zu diesem Pixel dupliziert wird und dann geändert wird. Beachten Sie,
dass je höher die Bitebene, desto bedeutsamer (more significant) ist das Bit.

Abbildung 34-02: HAM bitplanes

Es gibt eine Änderung des HAM-Modus, der nur fünf Bitebenen erfordert. In
diesem Fall ist der Wert des Bits aus der fehlenden sechsten Bitebene 0.

Wie wir im vorherigen Beispiel gesehen haben, kann es bis zu zwei Zwischenpixel
dauern, um die gewünschte Zielfarbe zu erreichen. HAM hat diesen unglücklichen
Nebeneffekt, dass scharfe Kontraste entlang der Scanlinie zu Farbfransen führen
können - z.B. neigen die Farben dazu, verschmiert zu werden. Eine der
Erkenntnisse der Bildanalyse ist jedoch, dass fotografische Bilder sich 
entlang einer Scanlinie nur selten viel verändern. Wie wir als nächstes sehen
werden, rettet dies den Tag.

Überschrift: Fotorealismus und Artefakte

Amiga HAM Bilder mit ihren 4096 Farben, brachte Fotorealismus in den Griff der
gewöhnlichen Menschen. Aber da HAM eine Art Trick ist, welche Art von
Artefakten führt es ein?

Um diese Frage zu beantworten, brauchte ich etwas, um das HAM-Bild zu
vergleichen, aber viele der alten Amiga HAM Bilder, kamen ohne Originalbild,
also was tun?

Mir wurde klar, dass ich meine eigenen HAM-Bilder machen musste, damit ich ein
Original haben konnte, mit dem ich vergleichen konnte. Der erste Teil der
HAM-Reise wurde durch das Anschauen dieses Videos und die Folge von The
Guru Meditation auf Youtube gemacht.

Um ihre Schritte nachzuvollziehen, fand ich zuerst ein passendes Bild mit viel
Kontrast, um das HAM-Farbfransenartefakt sichtbar zu machen. Ich fand ein Bild
von einem Oldtimer-Rennwagen, der viel Text auf dem Körper mit hohem Kontrast
hatte.

Das Originalbild wurde von einem JPEG in ein 24-Bit-BMP konvertiert und auf
320*256 heruntergesampelt, um in einen Amiga PAL-Bildschirm zu passen. Das
folgende gezeigte Bild, ist dass BMP das in ein PNG konvertiert wurde.

Abbildung 34-03: bmp 24 bit

Nun, da ich das BMP hatte, war der nächste Schritt, Art Department Pro zu
starten und das BMP in HAM umzuwandeln. Dies erforderte einen emulierten
Amiga 500 mit Tonnen RAM, die damals ein kleines Vermögen gekostet hätten.

Das Bild unten ist das nach HAM-konvertierte Bild, das als PNG angezeigt wird,
da der Browser HAM nativ nicht anzeigen kann. Ich habe kein Zaudern der
Endausgabe hinzugefügt, also war es eine saubere Umwandlung, und deshalb sehen
wir ein wenig Farbbandierung auf der Karosserie.

Abbildung 34-04: ham 16 color palette

Versuchen Sie, die beiden Bilder des Autos zu vergleichen. Sie sind fast
ähnlich, aber beachten Sie die Farbfransen an Stellen mit scharfen Kontrasten
entlang der horizontalen Scanlinien. Zum Beispiel dort, wo die gelbe Front des
Autos auf die schwarzen Buchstaben trifft. Hier ist eine Nahaufnahme.

Abbildung 34-05: Nahaufnahme

Die Farbsäume sind ein Artefakt von HAM mit nur 16 Grundfarben und im
schlimmsten Fall mit zwei Zwischenpixeln, um die gewünschte Farbe zu erreichen.
Dieses Artefakt ist besonders in Bildern vorhanden, in denen große horizontale
Bildverläufe vorhanden sind.

Das nächste Bild ist ein animiertes PNG, das zwischen dem 24-Bit-BMP-Bild
wechselt und es ist eine HAM-Konvertierung. Es gibt einige Unterschiede
zwischen den beiden Bildern, aber sie sind subtil.

Abbildung 34-06: animiertes png 

Weil HAM nur auf 16 Grundfarben angewiesen ist und diese modifiziert werden, um
4096 Farben zu erreichen kann es auch als verlustbehaftete Kompressionstechnik
angesehen werden, genau wie JPEG.

Bei der Überprüfung von HAM-Bildern sollten wir wirklich auch etwas über das
Anzeigesystem sagen. Sie lesen dies wahrscheinlich auf einem LCD-Bildschirm,
der eine sehr klare Pixeldarstellung im Vergleich zu den alten
CRT-Bildschirmen hat. Die Pixel an einem CRT-Bildschirm sind viel mehr
verschmiert, und es ist tatsächlich ein Effekt. Die Bilder sehen im Vergleich
zu LCD-Bildschirmen weniger pixelig aus.

Hier ist ein Beispielbild, das die gleiche Grafik auf einer CRT zeigt, links:
und ein modernes Display auf der rechten Seite. Dieses CRT-Artefakt machte HAM
noch mehr fotorealistisch!

Abbildung 34-07: CRT vs LCD

Das CRT-Gefühl ist eine große Sache im Retro-Gaming, weil LCD tendenziell zu
scharfe Pixel haben. WinUAE ermöglicht auch einige Optimierungen des Displays,
um näher an diesen alten CRT-Look zu kommen. Versuchen Sie, die
Filtereinstellungen zu optimieren. Sie können wirklich einen großen Unterschied
machen!

Überschrift: Zeige mir den Code

Sie finden den Code auf Disk2 im Ordner Ham. Lesen Sie den Assemblercode in
K-Seka ein und führen Sie ihn aus, indem Sie diese Schritte ausführen.

SEKA>r
FILENAME>ham
SEKA>a
OPTIONS>
No Errors
SEKA>ri
FILENAME>screen
BEGIN>screen
END>
SEKA>j

Als nächstes wird der Amiga das HAM-Bild auf dem Display servieren. Es sieht
so aus. 

Abbildung 34-08: screen

Das Programm geht davon aus, dass sich die HAM-Daten bereits an dem label
screen im Speicher befinden. Das macht das Programm einfach, da
wir uns nicht mit Dateien beschäftigen müssen, und deshalb geben wir oben den
Befehl "ri" ein, um ein Bild in den Speicher zu lesen und es an dem
Label "Screen" zu platzieren.

Das Programm funktioniert, indem es zuerst alle Interrupts deaktiviert, um
das gesamte System zu übernehmen. Dann liest es die ersten 16 Grundfarben aus
dem Speicher und setzt die COLORxx-Register entsprechend. Es macht dann einen
Sprung von 96 Wörtern, um zu den 6 Bitplanes zu gelangen, deren Adressen an die
BPLxPTH/BPLxPTL-Register gebunden sind. Allerdings nicht direkt, sondern über
die Copperliste. Dies macht dieses Programm zu einem selbstmodifizierenden
Programm.

Das Programm richtet dann die Copperliste ein und wartet weiterhin, bis die
linke Maustaste gedrückt wird. Wenn es gedrückt wird, stellt das Programm das
Workbench Copper wieder her und geht raus.

Die Copperliste übernimmt die Einrichtung der Bitplanes, DMA und des
Anzeigefensters.

; file mc1201.s
	move.w	#$4000,$dff09a	; INTENA  - disable all interrupts
	move.w	#$01a0,$dff096	; DMACON - disable bitplane, copper, sprite

	lea.l	screen(pc),a1	; move address of screen into a1
	move.l	#$dff180,a2		; move COLOR00 adress into a2
	moveq	#15,d0			; move 15 into d0 (loop counter)
colloop:					; begin loop that copy the 16 color palette
	move.w	(a1)+,(a2)+		; copy from screen into the color register
	dbra	d0,colloop		; if d0 >= 0 goto collop

	lea.l	bplcop+2(pc),a2 ; move address of bplcop + 2 + pc into a2
	add.w	#96,a1          ; point a1 to the first bitplane
	move.l	a1,d1           ; move a1 into d1
	moveq	#5,d0           ; move 5 into d0 (loop counter)
bplloop:					; Loop over 6 bitplanes and set bitplane pointers
	swap	d1
	move.w	d1,(a2)         ; set BPLxPTH in bplcop
	swap	d1
	move.w	d1,4(a2)        ; set BPLxPTL in bplcop
	addq.l	#8,a2           ; move to next bitplane pointers in bplcop
	add.l	#10240,d1       ; move d1 to point at the next bitplane
	dbra	d0,bplloop      ; if d0 >= 0 goto bplloop

	lea.l	copper(pc),a1   ; move address of copper into a1
	move.l	a1,$dff080      ; set COP1LCH and COP1LCL to address of a1

	move.w	#$8180,$dff096  ; DMACON - enable bitplane, copper

wait:
	btst	#6,$bfe001      ; busy wait until left mouse button is pressed
	bne.s	wait

	move.l	$04.w,a6        ; make a6 point to ExecBase of exec.library, which is also a struct
	move.l	156(a6),a6      ; IVBLIT points to GfxBase
	move.l	38(a6),$dff080  ; copinit ptr to copper start up list restore workbench copperlist 

	move.w	#$8020,$dff096  ; DMACON - enable sprite
	rts                     ; return from subroutine

copper:
	dc.w	$2001,$fffe		; wait for line $20
	dc.w	$0102,$0000		; move $0000 to $dff102 BPLCON1 scroll
	dc.w	$0104,$0000		; move $0000 to $dff104 BPLCON2 video
	dc.w	$0108,$0000		; move $0000 to $dff108 BPL1MOD modulus odd planes
	dc.w	$010a,$0000		; move $0000 to $dff10a BPL2MOD modulus even planes
	dc.w	$008e,$2c81		; move $2c81 to $dff08e DIWSTRT upper left corner ($81,$2c)
	dc.w	$0090,$f4c1		; move $f4c1 to $dff090 DIWSTOP (enable PAL trick)
	dc.w	$0090,$38c1		; move $38c1 to $dff090 DIWSTOP (PAL trick) lower right corner ($1c1,$12c)
	dc.w	$0092,$0038		; move $0038 to $dff092 DDFSTRT data fetch start at $38
	dc.w	$0094,$00d0		; move $00d0 to $dff094 DDFSTOP data fetch stop at $d0

	dc.w	$2c01,$fffe		; wait for line $2c
	dc.w	$0100,$6a00		; move $6a00 to $dff100 BPLCON0 - use 6 bitplanes, HAM, enable color burst 

bplcop:
	dc.w	$00e0,$0000		; BPL1PTH
	dc.w	$00e2,$0000		; BPL1PTL
	dc.w	$00e4,$0000		; BPL2PTH
	dc.w	$00e6,$0000		; BPL2PTL
	dc.w	$00e8,$0000		; BPL3PTH
	dc.w	$00ea,$0000		; BPL3PTL
	dc.w	$00ec,$0000		; BPL4PTH
	dc.w	$00ee,$0000		; BPL4PTL
	dc.w	$00f0,$0000		; BPL5PTH
	dc.w	$00f2,$0000		; BPL5PTL
	dc.w	$00f4,$0000		; BPL6PTH
	dc.w	$00f6,$0000		; BPL6PTL

	dc.w	$ffdf,$fffe		; wait - enables waits > $ff vertical
	dc.w	$2c01,$fffe		; wait for lien - $2c is $12c 
	dc.w	$0100,$0a00		; move $0a00 to $dff100 BPLCON0 - HAM, enable color burst
	dc.w	$ffff,$fffe		; end of copper list

screen:
	blk.w	61568/2,0		; allocate (320*256 pixels * 6 bitplanes) / 8 + 128 bytes = 61.568 bytes 

Wie ich bereits erwähnte, gibt es einen speziellen HAM-Modus, der nur fünf
Bitplanes erfordert. Das Bit aus der fehlenden sechsten Bitplane wird auf 0
gesetzt, und das wird vollständig mit den Farbmodifikatoren geschraubt. Wenn
das sechste Bit auf 0 gesetzt ist, kann man nur die blaue Farbe ändern, und
ich frage mich, ob das überhaupt nützlich ist.

Sie können diesen HAM-Modus mit fünf Bitebenen ausprobieren, indem Sie diese
Zeile in der Copperliste ändern.

dc.w	$0100,$6a00  ; move $6a00 to $dff100 BPLCON0 - use 6 bitplanes
zu diesem

dc.w	$0100,$5a00  ; move $5a00 to $dff100 BPLCON0 - use 5 bitplanes

Aber ich warne Sie, es sieht nicht hübsch aus. Zumal das Bild nicht für fünf
Bitplanes ausgelegt war.

Überschrift: HAM-Modus in Spielen

Der HAM-Modus wurde in Spielen nicht für mehr als Standbilder verwendet, bei
denen es sich um Titelbilder oder Bilder handelt, die zwischen Ebenen angezeigt
werden.

Der Grund, warum HAM nicht viel für Ingame-Animation verwendet wurde, war, dass
BOBs, wenn sie auf dem Bildschirm bewegt wurden, sehr wahrscheinlich
Farbfransen einführten. In einem Standbild ist ein Farbrand akzeptabel, aber
in einer dynamischen bewegten Szene kann es schnell ärgerlich werden.

Es gibt eine große Diskussion über stackexchange über HAM in Spielen. Von dort
aus habe ich die beiden folgenden Spiele gefunden, die im HAM-Modus des Spiels
verwendet werden!

Beide Spiele funktionieren, indem Hintergründe, die innerhalb der ersten
16 Grundfarben in der Farbtabelle vorhanden sind. Sie blitten dann den BOB auf
dem Bildschirm, die in modifizierten Farben sind. Beachten Sie auch den dicken
schwarzen Umriss um die BOBs, die da sind, um Farbsäume von den
Hintergrundpixeln zu verhindern.

Pioneer Plague, war das erste Spiel für den Amiga, das im Spiel HAM-Modus
verwendet, und es wurde von Bill Williams gemacht.

Knights of the Crystallion, wurde auch von Bill Williams gemacht, und es war
sein letztes Spiel für die Amiga Plattform.

Der HAM-Modus wurde nie ein Erfolg für die Ingame-Action, aber das bedeutet
nicht, dass der HAM-Modus ein Fehler war. Wie wir als nächstes sehen werden,
hat es eine neue Szene für digitalisierte Bilder geschaffen.

Überschrift: HAM-Modus und Video-Digitalisierung

Ein paar Monate nachdem der Amiga 1985 in den Läden erschien, begannen die
ersten fotorealistischen Bilder zu zirkulieren. Die Bilder waren nicht nur
atemberaubend, sondern ein Hauch einer Revolution. Diese Bilder wurden durch
den HAM-Modus ermöglicht, ein glücklicher Unfall, den Jay Miner aus dem Amiga
entfernen wollte. Sie können darüber im Buch The Future Was Here lesen.

Viele Leute hatten ihren ersten Enconter mit den fotorealistischen HAM-Bildern,
indem sie die NewTek Demo Reel von 1987 sahen. Es war nach heutigem Standard
mehr oder weniger eine Diashow der wildesten Bilder, die auf einem
Heimcomputersystem zu sehen waren.

Die Demo Reel beginnt mit Maxine Headroom, deren richtiger Name Laura
Longfellow ist, eine NewTek-Mitarbeiterin. Dies war eine Hommage an die fiktive
Figur Max Headroom, ein künstlicher TV-Moderator der 80er.

Als ich die Demo-Rolle in den 80er Jahren zum ersten Mal sah, war ich völlig
weggeblasen. Ich war gerade von einem 8-Bit ZX Spectrum zum Amiga 500
gewechselt, also war das WILDEST Ding überhaupt!

Eines der ersten erschwinglichen Systeme zur Digitalisierung von Farbbildern
war Digi-View von NewTek. Dieses System verwendet ein Videosignal, um ein
Standbild zu scannen und erforderte eine Schwarzweiß-Videokamera und ein
Farbfilterrad mit transparenten, roten, grünen und blauen Filtern. Das
aufgenommene Bild wurde dann durch die farbigen Filter gescannt und vom Amiga
zu einem Farbbild kombiniert. Der transparente Filter war für
Schwarzweißbilder.

Das System digitalisierte das Bild immer jeweils eine Pixelspalte. Die
Digitalisierung eines 320*200 (NTSC) großen Bildes (320/30 Bilder pr. Sekunde)
benötigte = 10,67 Sekunden. Für ein Farbbild mussten alle Farbkanäle
digitalisiert werden, was insgesamt 32 Sekunden erforderte. Jede Bewegung oder
Änderung der der Beleuchtung während dieses Prozesses würde das Ergebnis
ruinieren.

Das Digi-View-System war einfach zu bedienen, erforderte aber eine sorgfältige
Einrichtung der Kamerahalterung und -beleuchtung. Hier ist ein Video, das den
Prozess zeigt.

Abbildung 34-09: Video NeTek DgiView

Das digitalisierte Bild konnte dann später in Digi-Paint aufgebürstet werden
- einem Malprogramm, das HAM-Bilder malen und bearbeiten könnte.

Eine interessante Nebengeschichte ist, dass Dan Silva - Schöpfer von Deluxe
Paint - sein Programm nicht HAM-Modus unterstützen ließ. Ham-Unterstützung
wurde in Deluxe Paint IV hinzugefügt, nachdem Dan Silva Electronic Arts
verlassen hatte.

Das Bild unten zeigt meinen Versuch, ein HAM-Bild in Digi-Paint zu zeichnen.
Beachten Sie, dass die Farbpalette nur 16 Farben hat. Das sind die Grundfarben
über die wir vorher gesprochen haben. Das Bild nach links wird nur mit den
Grundfarben gezeichnet. Das Bild auf der rechten Seite, ist mit den
hinzugefügten grünen und blauen Farben. Da sich weder grün noch blau in der
Palette befindet, müssen die gewünschten Farben durch ändern von Pixelfarben
erreicht werden, was zu einem Farbrand führt. Möglicherweise müssen Sie zoomen,
um es zu sehen.

Abbildung 34-10: Digi-Paint v.3

Das obige Beispiel zeigt, dass der HAM-Modus keine offensichtliche Wahl für
handgezeichnete Bilder ist, es sei denn, Sie achten auf Farbsäumungen.
Programme wie Digi-Paint eignen sich aufgrund ihrer oft kleinen horizontalen
Bildverläufe viel besser für die Bearbeitung digitalisierter Fotos. Vielleicht
ist das der Grund, warum Dan Silva den HAM-Modus für Deluxe Paint nicht
priorisiert hat?

Das Video unten zeigt, wie man Digi-Paint verwendet und geht auch viel mehr in
Details über die Farbfransen Probleme und freie Hand Zeichnung.
Es ist auch eine gute Grundlage, wenn Sie lernen möchten, wie man Digi-Paint
verwendet.

NewTek hat seitdem seine Amiga-Ursprünge verlassen. Die Produkte, die sie in
den Amiga-Tagen hergestellt haben, haben das Unternehmen bis heute stark
geprägt. Sie machen immer noch Videobearbeitung mit dem TriCaster-System und
aktualisieren auch LightWave 3D.

Wir haben einen langen Weg auf dieser HAM-Modus-Reise zurückgelegt. Ich hoffe,
Sie haben es genossen, es zu lesen, so sehr ich es geschrieben habe. Als
nächstes folgt der Highres-Modus der Amiga.

weblinks:
https://en.wikipedia.org/wiki/Planar_%28computer_graphics%29
https://en.wikipedia.org/wiki/Packed_pixel
https://theamigamuseum.com/amiga-people/jay-miner/
https://www.goodreads.com/book/show/13488507-the-future-was-here
http://amiga-dev.wikidot.com/hardware:colorx
https://www.youtube.com/watch?v=eQmkOhFzzak		; Video
https://www.youtube.com/watch?v=_dHV_Lcbxjo		; Video
https://www.youtube.com/channel/UCYt9E2d_GCrPzquW-5MZwmQ
https://www.flickr.com/photos/42220226@N07/22945487532/in/photostream/
https://www.youtube.com/channel/UCYt9E2d_GCrPzquW-5MZwmQ
https://www.youtube.com/watch?v=mpkLHh9RFjI
https://en.wikipedia.org/wiki/Colour_banding
https://en.wikipedia.org/wiki/Hold-And-Modify
https://en.wikipedia.org/wiki/Lossy_compression
https://old.reddit.com/r/gaming/comments/anwgxf/here_is_an_example_of_old_graphics_on_crt_vs/
https://www.maketecheasier.com/emulate-crt-displays-with-retropie-shaders/
https://www.youtube.com/watch?v=IiOzfYHvkWY		; Video
http://amiga-dev.wikidot.com/hardware:bplxpth
https://retrocomputing.stackexchange.com/questions/151/
did-any-amiga-500-games-or-programs-apart-from-paint-programs-use-more-than-32
https://en.wikipedia.org/wiki/Bill_Williams_%28game_designer%29
https://www.pouet.net/prod.php?which=10762
https://en.wikipedia.org/wiki/Max_Headroom_%28character%29
http://amiga.resource.cx/exp/digiview
https://www.newtek.com/tricaster/
https://www.newtek.com/lightwave/2019/features/

;------------------------------------------------------------------------------
35 - Amiga Machine Code Letter XII- Vertical Scalling Using the Copper

Amiga Machine Code Letter XII - Vertikale Skalierung mit dem Copper
12.06.2020  22 min lesen

Die Amiga-Demoszene produzierte eine breite Palette von cleveren Effekten, die
in Assemblersprache geschrieben wurden. Von vielen genossen, und von wenigen
verstanden, schoben sie den Umschlag dessen, was auf einem Heimcomputersystem
für möglich gehalten wurde.

Die meisten Demos wurden durch mehrere Effekte zusammengestellt, und einige von
ihnen haben ihren Weg in Brief XII des Amiga Programming in Machine Code Kurs
gefunden.

Ein solcher Effekt heißt rotate und kann auf DISK2 gefunden werden. Es erzeugt,
was wie ein rotierendes Bild aussieht, indem es vertikal mit dem Copper
skaliert wird. Lassen Sie uns eintauchen und sehen, wie es zusammengestellt
wird.

Abbildung 35-01: Rotate

Sie können die Demo von K-Seka aus ausführen, indem Sie sie es assemblieren und
den Bildschirm und die Sinusdaten in den Speicher laden. Geben Sie Folgendes
in K-Seka ein:

SEKA>r
FILENAME>rot
SEKA>a
OPTIONS>
No errors
SEKA>ri
FILENAME>sin
BEGIN>sin
END>
SEKA>ri
FILENAME>screen
BEGIN>screen
END>
SEKA>j

Sehen wir uns nun die Datendateien genauer an.

Überschrift: Die Bilddatendatei

Die Bilddaten werden in einer Datei namens screen gespeichert. Das Bild ist
320 * 256 Pixel mit 8 Farben und wurde für diesen Effekt durch Hinzufügen einer
schwarzen Linie an der Oberseite und Boden des Bildes präpariert. 
Mehr dazu später

Abbildung 35-02: Screen

Die Bilddaten haben das folgende Layout:

16 Bytes für 8 Farben
10240 Bytes für Bitebene 1
10240 Bytes für Bitebene 2
10240 Bytes für Bitebene 3

Daraus folgt, dass die Dateigröße 30.736 Byte beträgt.

Überschrift: Die Sinus-Datendatei

Beim Drehen des Bildes möchten wir, dass es etwas glatt und realistisch
aussieht. Eine Möglichkeit, dies zu tun, ist eine Sinuswelle zu verwenden.
Die Berechnung von Sinus ist jedoch eine ziemlich teure Operation, also was die
meisten taten, war, vorberechnete Sinuswerte in einer Tabelle zu speichern.

Die Sinusdatendatei ist 2048 Byte lang und besteht aus 1024 Word-Dateneinträgen
mit dem folgenden Layout.

1 Byte für einen Sinuswert.
1 Byte für einen Offset.

Die Sinusdaten sind nicht vorzeichenbehaftet und sollten über den 512. Eintrag
hinaus als negativ interpretiert werden.

Abbildung 35-03: Sinus

Die Offsetdaten sind eine Eingabe für einen Algorithmus, der beim Erstellen des
vertikal skalierten Bildes auswählt, welche Linien aus dem Originalbild
abgetastet werden sollen.

Abbildung 35-04: offset

Wenn Sie daran interessiert sind, wie Sinus ohne Gleitkomma berechnet wird,
dann schauen Sie sich CORDIC oder Volders Algorithmus an. Und während Sie
dabei sind - schauen Sie sich dieses Video an. Und wenn Sie nicht genug haben,
dann fand ich eine Implementierung von CORDIC in 68K-assembly (pdf) mit
festen Punkten.

Überschrift: Das Drehprogramm

In breiten Strichen skaliert das Programm das Bild vertikal, indem es die
Copperliste verwendet, um eine Illusion eines rotierenden Bildes zu erzeugen.
Das Programm wird durch Drücken der linken Maustaste beendet.

Zuerst initialisiert das Programm die Copperliste und erstellt ein Gerüst von
Einträgen, um die Bitplane-Modulos zu manipulieren, mit Werten, die in der
Hauptschleife festgelegt sind. Die 8 Farbwerte werden auch als Teil der
Initialisierung festgelegt.

Wie wir später sehen werden, spielen die Bitplane-Modulos eine Schlüsselrolle
in diesem Effekt.

In der Hauptschleife wird ein neuer Sinuswert aus der Sinustabelle
nachgeschlagen und als Eingabe verwendet, um eine Rotationstabelle, gentab,
mit 256 Einträgen, einer für jede Bildzeile, zu generieren.

Wenn der Strahl Zeile 300 erreicht, aktualisiert das Programm die Copperliste,
indem die Bitebenenzeiger und Modulos aus der zuvor generierten
Rotationstabelle gesetzt werden.

Der Code für das Programm rotate, kann auf DISK2 gefunden werden, aber ich habe
es auch unten aufgelistet und meine Kommentare hinzugefügt.

; file 1205.s = rotate.s
start:
    move.w	#$4000,$dff09a	; INTENA disable interrupts

    bsr	initcop             ; branch to subroutine initcop
    bsr	setcolor            ; branch to subroutine setcolor

    move.w	#$01a0,$dff096  ; DMACON clear bitplane, copper, blitter

    lea.l	copper(pc),a1   ; store copper pointer in a1
    move.l	a1,$dff080      ; set COP1LCH/COP1LCL to address of copper

    move.w	#$8180,$dff096  ; DMACON set bitplane, copper

main:
    lea.l	pos(pc),a1		; store pos pointer in a1
    addq.w	#7,(a1)			; increment pos 
                            ; larger step - higher rotation speed
    bsr	genrot              ; branch to subroutine genrot

bpos:                       ; beam position check
    move.l	$dff004,d0		; store VPOSR and VHPOSR value in d0 (move long)
    asr.l	#8,d0			; algorithmic shift right 8 places
    andi.w	#$1ff,d0		; keep v8,v7,...,v0 in d0
    cmp.w	#300,d0			; compare
    bne.s	bpos			; if d0 != 300 goto bpos

    bsr.s	genpt			; set bitplane pointers in copper list
    bsr.s	gencop			; set bitplane modulo values in copper list

    btst	#6,$bfe001		; test if left mouse button is pressed
    bne.s	main			; if not, then go to main

    move.l	4.w,a6          ; reestablish workbench
    move.l	156(a6),a6
    move.l	38(a6),a6
    move.l	a6,$dff080
    move.w	#$8020,$dff096
    rts

gencop:                     ; generate copper list
    lea.l	cop+6(pc),a1    ; store BPL1MOD data pointer in a1
    lea.l	gentab(pc),a2   ; store gentab pointer in a2
    move.w	#255,d0         ; set loop counter
gencoploop:                 ; loop over 256 lines and set modulus
    move.w	(a2),(a1)       ; set BPL1MOD in copper list
    addq.l	#4,a1           ; increment pointer 4 bytes
    move.w	(a2)+,(a1)      ; set BPL2MOD in copper list, increment pointer
    addq.l	#8,a1           ; increment pointer 8 bytes
    dbra	d0,gencoploop   ; if d0 >= 0 goto gencoploop
    rts                     ; return from subroutine

genpt:                      ; generate bitplane pointers in copper list
    lea.l	pos(pc),a1      ; store pos pointer in a1
    move.w	(a1),d1         ; store pos value in d1
    andi.w	#$7fe,d1        ; make d1 an even number <= 2046
    lea.l	screen+16(pc),a1; store pointer to first bitplane
    cmp.w	#1024,d1        ; have we reached negative sine numbers?
    ble.s	genpt2          ; if d1 <= 1024 (sine is positive) goto genpt2
    add.w	#10240,a1       ; increment screen pointer to next bitplane
genpt2:
    lea.l	bplcop(pc),a2   ; store bplcop pointer in a2
    move.l	a1,d1           ; store screen pointer in d1
    moveq	#2,d0           ; set loop counter 
bplcoploop:                 ; loop over 3 bitplanes
    swap	d1              ; swap screen pointer
    move.w	d1,2(a2)        ; set BPLxPTH
    swap	d1              ; swap screen pointer
    move.w	d1,6(a2)        ; set BPLxPTL
    addq.l	#8,a2           ; increment bplcop pointer to next entry
    add.l	#10240,d1       ; increment screen pointer to next bitplane
    dbra	d0,bplcoploop   ; if d0 >= 0 goto bplcoploop
    rts                     ; return from subroutine
pos:
    dc.w	0               ; position in sine table

genrot:                     ; generate rotation table
    lea.l	pos(pc),a1      ; store pos pointer in a1
    move.w	(a1),d1         ; store pos value in d1
    andi.w	#$7fe,d1        ; make d1 and even number <= 2046
    cmp.w	#1024,d1        ; have we reached negative sine numbers?
    bgt.s	type2           ; if d1 > 1024 (sine is negative) goto type2
    lea.l	sin(pc),a1      ; store sin pointer in a1
    moveq	#0,d2           ; clear d2 (alternative to clr.l)
    move.w	(a1,d1.w),d2    ; store data from sin table in d2
    move.l	d2,d3           ; store sin data in d3 
    move.l	d2,d5           ; store sin data in d5
    lsr.w	#8,d2           ; keep sine value of sin data in d2
    andi.w	#255,d5         ; keep offset value of sin data in d5
    lsl.w	#8,d5           ; logical shift left d5 by 8 bits
    move.w	#256,d1         ; move #256 into d1
    sub.w	d2,d1           ; subtract sine value from d1
    lsr.w	#1,d1           ; divide d1 by 2
    add.w	d1,d2           ; add d1 to sine value in d2
    moveq	#0,d0           ; clear loop counter d0
    lea.l	gentab(pc),a1   ; store gentab pointer in a1
loop1:                      ; loop d1 times
    cmp.w	d0,d1           ; compare loop counter d0 to number of loops d1
    beq.s	loop1ok         ; if equal exit loop by goto loop1ok
    move.w	#-40,(a1)+      ; insert -40 into gentab and increment pointer
    addq.w	#1,d0           ; increment loop counter d0
    bra.s	loop1           ; branch always to loop1
loop1ok:
    moveq	#0,d4           ; clear d4
    sub.l	d5,d4           ; subtract first byte of sine data
    moveq	#0,d5           ; clear d5
loop2:                      ; loop d2-d1 times (squeezed image loop)
    cmp.w	d0,d2           ; compare loop counter d0 with d2
    beq.s	loop3           ; if equal goto loop3
    addq.w	#1,d0           ; increment loop counter d0
    moveq	#-1,d6          ; set d6 to -1
loop2x:                     ; inner loop - determine lines to sample
    add.l	d3,d4           ; add d3 to d4
    move.l	d4,d7           ; move sine value into d7
    swap	d7              ; swap words of d7
    addq.w	#1,d6           ; increment d6 - the line to sample
    cmp.w	d5,d7           ; compare d5 with d7
    ble.s	loop2x          ; if d5 <= d7 goto loop2x
    move.w	d7,d5           ; move d7 to d5
    mulu	#40,d6          ; multiply d6 with 40 - image width in bytes
    move.w	d6,(a1)+        ; insert d6 into gentab and increment pointer
    bra.s	loop2           ; branch always to loop2
loop3:                      ; loop 256-d0 times
    cmp.w	#256,d0         ; compare loop counter d0 to #256
    beq.s	loop3ok         ; if equal exit loop by goto loop3ok 
    move.w	#-40,(a1)+      ; write -40 into gentab
    addq.w	#1,d0           ; increment loop counter d0
    bra.s	loop3           ; branch always to loop3
loop3ok:
    rts                     ; return from subroutine
type2:                      ; generate rotation table - negative sine 
    lea.l	sin(pc),a1      ; won't repeat almost identical comments here
    moveq	#0,d2
    move.w	(a1,d1.w),d2
    move.l	d2,d3
    move.l	d2,d5
    lsr.w	#8,d2
    andi.w	#255,d5
    lsl.w	#8,d5
    move.w	#256,d1
    sub.w	d2,d1
    lsr.w	#1,d1
    add.w	d1,d2
    moveq	#0,d0
    lea.l	gentab(pc),a1
loop1b:
    cmp.w	d0,d1
    beq.s	loop1okb
    move.w	#-40,(a1)+
    addq.w	#1,d0
    bra.s	loop1b
loop1okb:
    moveq	#0,d4
    sub.l	d5,d4
    moveq	#0,d5
loop2b:
    cmp.w	d0,d2
    beq.s	loop3b
    addq.w	#1,d0
    moveq	#1,d6
loop2bx:
    add.l	d3,d4
    move.l	d4,d7
    swap	d7
    addq.w	#1,d6
    cmp.w	d5,d7
    ble.s	loop2bx
    move.w	d7,d5
    muls	#-40,d6
    move.w	d6,(a1)+
    bra.s	loop2b
loop3b:
    cmp.w	#256,d0
    beq.s	loop3okb
    move.w	#-40,(a1)+
    addq.w	#1,d0
    bra.s	loop3b
loop3okb:
    rts

initcop:                        ; construct copper list
    lea.l	cop(pc),a1			; store address of cop into a1
    move.l	a1,a2				; store copy of a1 in a2
    move.w	#255,d0				; set loop counter d0 to 255
    moveq	#$2c,d1				; set d1 to $2c i.e first line to wait for
initcoploop:
    move.b	d1,(a1)+            ; set byte to d1
    move.b	#$01,(a1)+          ; set byte to $01 -> $xx01 = wait
    move.w	#$fffe,(a1)+        ; set wait mask -> dc.w $xx01,$fffe
    move.l	#$01080000,(a1)+    ; BPL1MOD
    move.l	#$010a0000,(a1)+    ; BPL2MOD
    addq.w	#1,d1               ; increment line to wait for
    dbra	d0,initcoploop      ; if d0 >= 0 goto initcoploop
    move.w	#$ffdf,2544(a2)     ; enables waits > $ff vertical (2544=212*12)
    rts                         ; return from subroutine

setcolor:                       ; set colors via copper list
    lea.l	screen(pc),a1		; store address of screen in a1
    lea.l	colcop+2(pc),a2		; store address of colorcop + 2 in a2
    moveq	#7,d0				; set loop counter d0
colorloop:
    move.w	(a1)+,(a2)			; copy color from screen to colorcop
    addq.l	#4,a2				; go to next color entry in colorcop
    dbra	d0,colorloop		; if d0 >= 0 goto colorloop
    rts                         ; return from subroutine

copper:
    dc.w	$2001,$fffe			; wait for line #32
    dc.w	$0100,$0200			; BPLCON0 disable bitplanes
    dc.w	$008e,$2c81			; DIWSTRT top right corner ($81,$2c)
    dc.w	$0090,$f4c1			; DIWSTOP enable PAL trick
    dc.w	$0090,$38c1			; DIWSTOP buttom left corner ($1c1,$12c)
    dc.w	$0092,$0038			; DDFSTRT
    dc.w	$0094,$00d0			; DDFSTOP
    dc.w	$0102,$0000			; BPLCON1 (scroll)
    dc.w	$0104,$0000			; BPLCON2 (video)
    dc.w	$0108,$0000			; BPL1MOD
    dc.w	$010a,$0000			; BPL2MOD

colcop:
    dc.w	$0180,$0000			; COLOR00
    dc.w	$0182,$0000			; COLOR01
    dc.w	$0184,$0000			; COLOR02
    dc.w	$0186,$0000			; COLOR03
    dc.w	$0188,$0000			; COLOR04
    dc.w	$018a,$0000			; COLOR05
    dc.w	$018c,$0000			; COLOR06
    dc.w	$018e,$0000			; COLOR07

    dc.w	$2b01,$fffe			; wait for line #43 ($2B)

bplcop:
    dc.w	$00e0,$0000			; BPL1PTH
    dc.w	$00e2,$0000			; BPL1PTL
    dc.w	$00e4,$0000			; BPL2PTH
    dc.w	$00e6,$0000			; BPL2PTL
    dc.w	$00e8,$0000			; BPL3PTH
    dc.w	$00ea,$0000			; BPL3PTL

    dc.w	$0100,$3200			; BPLCON0 enable bitplanes

cop:
    blk.w	1536,0				; allocate 1536 words (256 * 6w)

    dc.w	$2c01,$fffe			; wait for line $12c (waits > $ff enabled)
    dc.w	$0100,$0200			; BPLCON0 disable bitplanes
    dc.w	$ffff,$fffe			; end of copper list

gentab:							; generated table
    blk.w	256,0				; store bitplane modulo values foreach screen line 

sin:							; sine and offset data
    blk.w	1024,0				; allocate 1024 words and set to 0

screen:							; image data (320*256*3)/16+8
    blk.w	15388,0				; allocate 15388 words and set to 0

Wenn du das Programm verstehst kannst du den Rest des Beitrags überspringen.
Ansonsten, lassen sie uns in die Details eintauchen.

Copperliste initialisieren
Der Speicherplatz für die Copperliste wird auf der Bezeichnung cop
zugewiesen.

cop:
    blk.w	1536,0				; allocate 1536 words (256 * 6w)
    dc.w	$2c01,$fffe			; wait for line $12c (waits > $ff enabled)
    dc.w	$0100,$0200			; BPLCON0 disable bitplanes
    dc.w	$ffff,$fffe			; end of copper list

Zuerst weisen wir Platz für die Einstellung der Bitplane-Modulos für alle 256
Linien des sichtbaren Bildschirms zu. Wenn dann der Strahl die Zeile $12c = 300
erreicht, werden die Bitebenen deaktiviert, und es wird eine spezielle Sequenz
hinzugefügt, um das Ende der Copperliste anzuzeigen.

Das Festlegen der Bitebenenmodulo für eine Linie im Bild erfordert 6 Wörter
Arbeitsspeicher. Wir könnten es 256 Mal wie folgt im Code schreiben:

    dc.w	$xx01,$fffe			; wait for line $xx
    dc.w	$0108,$0000			; BPL1MOD
    dc.w	$010a,$0000			; BPL2MOD

Wobei $xx die Bildschirmzeilennummer ist. Die Bitlane-Modulos werden auf
Null initialisiert, aber später vom Programm im Unterprogramm gencop geändert.
Es ist ein klassisches Beispiel für selbstmodifizierenden Code.

Es würde schnell mühsam werden, all dies von Hand zu schreiben. Stattdessen
initialisiert die initcop-Subroutine den Copper, indem ein Gerüst von 256
Einträgen von BPLxMOD-Einträgen in der Schleife initcoploop erstellt wird.

initcop:                        ; construct copper list
    lea.l	cop(pc),a1			; store address of cop into a1
    move.l	a1,a2				; store copy of a1 in a2
    move.w	#255,d0				; set loop counter d0 to 255
    moveq	#$2c,d1				; set d1 to $2c i.e first line to wait for
initcoploop:
    move.b	d1,(a1)+            ; set byte to d1
    move.b	#$01,(a1)+          ; set byte to $01 -> $xx01 = wait
    move.w	#$fffe,(a1)+        ; set wait mask -> dc.w $xx01,$fffe
    move.l	#$01080000,(a1)+    ; BPL1MOD
    move.l	#$010a0000,(a1)+    ; BPL2MOD
    addq.w	#1,d1               ; increment line to wait for
    dbra	d0,initcoploop      ; if d0 >= 0 goto initcoploop
    move.w	#$ffdf,2544(a2)     ; enables waits > $ff vertical (2544=212*12)
    rts                         ; return from subroutine

Die Routine enthält zwei Zeilen mit magischen Zahlen

    ...
    moveq	#$2c,d1				; set d1 to $2c i.e first line to wait for
    ...
    move.w	#$ffdf,2544(a2)		; enables waits > $ff vertical (2544=212*12)
    ...

Die Bedeutung von $2c und 2544 wird deutlicher, wenn man die
Bildschirmeinrichtung betrachtet.

Zuerst stellen wir sicher, dass die erste Wartezeit in der Zeile $2c
stattfindet, da dies die erste Zeile des sichtbaren Bildschirms ist.

Abbildung 35-05: screen enable pal

Als Nächstes müssen wir die Wartezeiten für Zeilen mit y-Werten aktivieren, die
größer als $ff sind, da wir an einem PAL-Bildschirm arbeiten. Wir tun dies,
indem wir den Wert $ffdf mit einem Offset von 2544 - Bytes vom Anfang der
Copperliste schreiben. 

offset =(($ff-$2c)+1)*12bytes
	   =($d3+1)*12bytes
	   =2544btes

Überschrift: Farbe setzen

Die Unterroutine setcolor arbeitet mit dem Speicherraum, der am Label Colcop
definiert ist und der wie folgt initialisiert wird.

colcop:
    dc.w	$0180,$0000			; COLOR00
    dc.w	$0182,$0000			; COLOR01
    dc.w	$0184,$0000			; COLOR02
    dc.w	$0186,$0000			; COLOR03
    dc.w	$0188,$0000			; COLOR04
    dc.w	$018a,$0000			; COLOR05
    dc.w	$018c,$0000			; COLOR06
    dc.w	$018e,$0000			; COLOR07

Alle Farben werden auf Null initialisiert, und die Setcolor-Unterroutine ändert
dies in die Farben, die in den ersten 16 Bytes des Bildes definiert sind und
lädt sie an die Stelle in den Speicher auf welches das Label screen zeigt.

setcolor:                       ; set colors via copper list
    lea.l	screen(pc),a1		; store address of screen in a1
    lea.l	colcop+2(pc),a2		; store address of colorcop + 2 in a2
    moveq	#7,d0				; set loop counter d0
colorloop:
    move.w	(a1)+,(a2)			; copy color from screen to colorcop
    addq.l	#4,a2				; go to next color entry in colorcop
    dbra	d0,colorloop		; if d0 >= 0 goto colorloop
    rts                         ; return from subroutine

Der Loop Colorloop iteriert über die 8 Farben und legt die colcop-Einträge
entsprechend fest. Auch hier sehen wir ein Beispiel für selbstmodifizierenden
Code.

Überschrift: Rotationstabelle generieren

Die Rotationstabelle enthält die Modulo-Werte, die von der genrot-Unterroutine
berechnet werden. Diese Werte sind dafür verantwortlich, das Bild beim Drehen
vertikal zu schieben. Es gibt 256 Einträge in der Tabelle, ein Modulo-Wert für
jede sichtbare Bildschirmlinie.

gentab:							; generated table
    blk.w	256,0				; store bitplane modulo values foreach screen line 

Die Werte aus der gentab-Tabelle werden später von der gencop-Unterroutine in
die Copperliste übertragen, indem die Werte für BPLxMODgesetzt werden.

Für jeden Durchlauf der Hauptschleife wird die gentab-Tabelle zusammen mit der
Copperliste aktualisiert. Um nachzuverfolgen, welchen Sinuswert aus der
Sinustabelle gelesen werden soll, wird eine Positionsvariable eingeführt und an
dem Label pos gespeichert.

pos:
    dc.w	0					; position in sine table

Der Positionswert wird als Teil der Hauptschleife erhöht. Je größer das
Inkrement, desto schneller die Rotationsgeschwindigkeit.

main:
    lea.l	pos(pc),a1			; store pos pointer in a1
    addq.w	#7,(a1)				; increment pos 
    bsr	genrot					; branch to subroutine genrot

Der Positionswert kann jedoch nicht als Ist verwendet werden, sondern muss
einer gewissen Filtration unterzogen werden. Der Grund dafür ist die Art und
Weise, wie die Sinusdaten in der Sinustabelle gespeichert werden. Die Daten
sind wie folgt strukturiert:

1 Byte für einen Sinuswert.
1 Byte für einen Offset.

Um sicherzustellen, dass wir nur Sinuswerte lesen, müssen wir den Positionswert
filtern, damit er bei einer geraden Zahl beginnt. Diese Filterung erfolgt in
der genrot-Unterroutine

    ...
    lea.l	pos(pc),a1			; store pos pointer in a1
    move.w	(a1),d1				; store pos value in d1
    andi.w	#$7fe,d1			; make d1 and even number <= 2046
    ...
    lea.l	sin(pc),a1			; store sin pointer in a1
    moveq	#0,d2				; clear d2 (alternative to clr.l)
    move.w	(a1,d1.w),d2		; store data from sin table in d2
    ...

Der Filter stellt sicher, dass die Position nie über 2046 erhöht werden kann,
in diesem Fall läuft es einfach über und beginnt wieder bei Null.
Ziemlich raffiniert...

Bevor wir in den Rest der genrot-Unterroutine eintauchen, müssen wir einen
Blick darauf werfen, wie das Bitplane-Modulo BPLxMOD funktioniert.

Das Bitplane-Modulo ist eine Zahl, die automatisch der Adresse am Ende jeder
Zeile hinzugefügt wird. Es hilft, den Bitplane-Speicher als etwas getrennt
von dem zu sehen, was schließlich auf den Bildschirm gezogen wird.

Im folgenden Beispiel habe ich das Bitebenenmodulo für die zweite, dritte und
vierte Zeile für ein Bild mit einer Breite von 40 Bytes oder 320 Pixeln auf
-38 gesetzt.

Abbildung 35-06: bitplane modulo

Die erste Zeile auf dem Bildschirm wird von Adresse 0 in der Bitebene gelesen.
Am Ende der Zeile wird eine neue Startadresse für Zeile 2 auf dem Bildschirm
mit dem Modulo für Zeile 2 berechnet.

Die zweite Zeile auf dem Bildschirm wird von Adresse 2 in der Bitebene gelesen.
Am Ende von Zeile 2 wird eine neue Startadresse für Zeile 3 auf dem Bildschirm
mit dem Modulo für Zeile 3 usw. berechnet.

Ein interessanter Effekt tritt auf, wenn das Modulo auf -40 eingestellt ist.
Da das Modulo mit der gesamten Breite des Bildes identisch ist, ist die neue
Linie, die auf den Bildschirm gezeichnet wird, ein exaktes Duplikat der
vorherigen Bildlinie.

Abbildung 35-07: bitplane modulo

Dieser Duplizierungseffekt wird von der genrot-Unterroutine verwendet, um die
gentab-Tabelle mit -40 zu füllen, um den oberen und unteren Teil des Bildes
schwarz zu malen. Das ist auch der Grund, warum das Bild eine schwarze Linie
an der Spitze und am Boden haben muss, damit wir eine schwarze Linie zum 
Duplizieren haben.

Die genrot-Unterroutine besteht aus einer Reihe von Schleifen, die die gentab-
Tabelle mit 256 Modulo-Werten füllen, wobei ein Sinuswert als Eingabe
verwendet wird.

loop1: Legt das Modulo auf -40 fest (dupliziert die vorherige Zeile)
loop2: Legt das Modulo auf eine Zeile aus dem Bild fest
loop2x: Verwendet den Offset aus der Sin-Tabelle, um eine Linie im Bild zu
	   finden
loop3: Stellen Sie das Modulo auf -40 (dupliziert die vorherige Zeile).

Zunächst wird die Intitial-Schleifenanzahl d1 mithilfe der Sinuseingabe
bestimmt.

genrot:                         ; generate rotation table
    ...
    move.w	(a1,d1.w),d2		; store data from sin table in d2
    lsr.w	#8,d2				; keep sine value of sin data in d2
    ...
    move.w	#256,d1				; move #256 into d1
    sub.w	d2,d1				; subtract sine value from d1
    lsr.w	#1,d1				; divide d1 by 2

Der Code für loop1 legt die ersten d1-Zeilen in der gentab-Tabelle auf -40 fest
und dupliziert somit die schwarze Linie oben im Bild d1-mal.

loop1:                          ; loop d1 times
    cmp.w	d0,d1				; compare loop counter d0 to number of loops d1
    beq.s	loop1ok				; if equal exit loop by goto loop1ok
    move.w	#-40,(a1)+			; insert -40 into gentab and increment pointer
    addq.w	#1,d0				; increment loop counter d0
    bra.s	loop1				; branch always to loop1

Die nächste Schleife, loop2, findet, welche Linien in ihrer inneren Schleife,
loop2x, und dann in der äußeren Schleife, loop2, diesen Wert mal 40 in die
gentab-Tabelle setzen.

Die äußere loop2-Schleife für x-zeiten, wobei x dem Sinuswert entspricht. Dies
bedeutet auch, dass das gequetschte Bild eine Höhe der Sinusanzahl von Linien
auf dem Bildschirm hat.

loop2:                          ; loop d2-d1 times (squeezed image loop)
    cmp.w	d0,d2				; compare loop counter d0 with d2
    beq.s	loop3				; if equal goto loop3
    addq.w	#1,d0				; increment loop counter d0
    moveq	#-1,d6				; set d6 to -1
loop2x:                         ; inner loop - determine lines to sample
    add.l	d3,d4				; add d3 to d4
    move.l	d4,d7				; move sine value into d7
    swap	d7					; swap words of d7
    addq.w	#1,d6				; increment d6 - the line to sample
    cmp.w	d5,d7				; compare d5 with d7
    ble.s	loop2x				; if d5 <= d7 goto loop2x
    move.w	d7,d5				; move d7 to d5
    mulu	#40,d6				; multiply d6 with 40 - image width in bytes
    move.w	d6,(a1)+			; insert d6 into gentab and increment pointer
    bra.s	loop2				; branch always to loop2

Die innere Schleife loop2x bestimmt, welche Linien vom Originalbild zum
Beispiel beim Erstellen des gequetschten Bildes unter Verwendung eines Offsets
als Eingabe verwendet werden.

Ich hatte echte Schwierigkeiten, mir den Versatzteil der Sinustabellendaten zu
erklären. Es hat einen Effekt auf welche Linien aus dem Bild zu proben, aber es
ist kein dramatischer Effekt.

Beachten Sie auch, wie die Sterne im Hintergrund zu funkeln scheinen, wenn sich
das Bild dreht. Das Funkeln wird dadurch erklärt, wie die Linien abgetastet
werden. Ein Stern mit einer Höhe von einem Pixel wird nur auf einer Linie
vorhanden sein. Dadurch entsteht das Augenzwinkern, wenn die Linie gewählt
wird, und dann nicht gewählt wird, wenn sich das Bild dreht.

Der funkelnde Effekt hätte vermieden werden können, wenn wir eine Probemitnahme
mit einer Art Interpolationsschema durchgeführt hätten.

Die letzte Schleife, loop3, durchläuft die verbleibenden Linien und setzt sie
auf -40. So wird die letzte schwarze Linie des Bildes auf dem Rest des
sichtbaren Bildschirms dupliziert.

loop3:                          ; loop 256-d0 times
    cmp.w	#256,d0				; compare loop counter d0 to #256
    beq.s	loop3ok				; if equal exit loop by goto loop3ok 
    move.w	#-40,(a1)+			; write -40 into gentab
    addq.w	#1,d0				; increment loop counter d0
    bra.s	loop3				; branch always to loop3

Schauen wir uns einige Beispiele an. Im Folgenden habe ich zwei Bilder für
verschiedene Werte des Sinus gezeigt. Ich habe den Teilen des Bildschirms, in
denen die schwarzen Linien synchronisiert sind, eine hellgraue Farbe
hinzugefügt.

Das erste Bild zeigt den Ausgabebildschirm für Sinus = 25. Der obere schwarze
Bereich ist die Linie (256-25)/2=115 Linien. Der gequetschte Bildteil hat die
gleiche Anzahl von Zeilen wie der Sinuswert, in diesem Fall 25 Zeilen. Der
untere schwarze Bereich füllt die verbleibenden Linien
256 - (115 + 25) = 116 Zeilen.

Abbildung 35-08: genrot1

Das zweite Bild zeigt den Ausgabebildschirm für Sinus = 152. Die Anzahl der
Linien für den oberen schwarzen Bereich ist (256-152)/2=52 Linien. Der
gequetschte Teil verwendet 152 Zeilen - das gleiche wie der Sinuswert. Der
schwarze Bodenbereich füllt die restlichen 256 - (52 + 152) = 52 Zeilen.

Abbildung 35-09: genrot2

Wenn der Positionswert größer als 1024 wird, sollten die Sinuswerte als negativ
interpretiert werden und werden bei der Type2-Label behandelt.

genrot:                         ; generate rotation table
    lea.l	pos(pc),a1			; store pos pointer in a1
    move.w	(a1),d1				; store pos value in d1
    andi.w	#$7fe,d1			; make d1 and even number <= 2046
    cmp.w	#1024,d1			; have we reached negative sine numbers?
    bgt.s	type2				; if d1 > 1024 (sine is negative) goto type2

Die Schleifen, die die negativen Sinuswerte an der Type2-Beschriftung
verarbeiten, sind fast identisch mit den Schleifen, die die positiven
Sinuswerte verarbeiten. Der einzige Unterschied besteht in Bezug auf d6, das
auf 1 anstelle von -1 initialisiert und später mit -40 anstelle von 40
multipliziert wird.

type2:                          ; generate rotation table - negative sine 
    ...
loop2b:
    ...
    moveq	#1,d6
    ...
    muls	#-40,d6
    ...

Der Unterschied ist darauf zurückzuführen, dass der gequetschte Teil des Bildes
rückwärts oder auf den Kopf gestellt wird, wenn sinus negativ ist. Dies ist
jedoch nur möglich, wenn die Bitebenenzeiger aktualisiert werden, um diese
Rückwärtsdrehung widerzuspiegeln.

Überschrift: Generieren von Bitplane-Zeigern

Die Zeiger auf die drei Bildbitebenen werden von der genpt-Unterroutine
generiert.

Es beginnt mit dem Suchen des Zeigers auf die erste Bitebene von der
Bildschirmbeschriftung und durchläuft dann die Bitebenen in bplcoploop, wo die
Bitplane-Zeiger in die Copperliste auf der Bezeichnung bplcop geschrieben
werden.

genpt:                          ; generate bitplane pointers in copper list
    lea.l	pos(pc),a1			; store pos pointer in a1
    move.w	(a1),d1				; store pos value in d1
    andi.w	#$7fe,d1			; make d1 an even number <= 2046
    lea.l	screen+16(pc),a1	; store pointer to first bitplane
    cmp.w	#1024,d1			; have we reached negative sine numbers?
    ble.s	genpt2				; if d1 <= 1024 (sine is positive) goto genpt2
    add.w	#10240,a1			; increment screen pointer to next bitplane
genpt2:
    lea.l	bplcop(pc),a2		; store bplcop pointer in a2
    move.l	a1,d1				; store screen pointer in d1
    moveq	#2,d0				; set loop counter 
bplcoploop:                     ; loop over 3 bitplanes
    swap	d1					; swap screen pointer
    move.w	d1,2(a2)			; set BPLxPTH
    swap	d1					; swap screen pointer
    move.w	d1,6(a2)			; set BPLxPTL
    addq.l	#8,a2				; increment bplcop pointer to next entry
    add.l	#10240,d1			; increment screen pointer to next bitplane
    dbra	d0,bplcoploop		; if d0 >= 0 goto bplcoploop
    rts                         ; return from subroutine

Wenn sich die Position über 1024 bewegt, sollten die Sinuswerte als negativ
interpretiert werden. Auf diese Weise wird etwas Platz gespart, indem das
Zeichenbit eliminiert wird.

genpt:
    ...
    cmp.w	#1024,d1			; have we reached negative sine numbers?
    ble.s	genpt2				; if d1 <= 1024 (sine is positive) goto genpt2
    add.w	#10240,a1			; increment screen pointer to next bitplane
genpt2:
    ...

Aber warum wird 10240 zu a1 hinzugefügt, wenn die Position über 1024 liegt?

Das Ausführen des Programms für Positionen über und unter 1024 ergab die
folgende Tabelle der Bitplane-Zeiger BPLxPTH/BPLxPTL. Die Adressen können
variieren, je nachdem, wo das Programm im Speicher platziert wird.

Bitplane			Position <= 1024	Position > 1024
Bitplane-pointer 1	$258dc				$280dc
Bitplane-pointer 2	$280dc				$2a8dc
Bitplane pointer 3	$2a8dc				$2d0dc

Der Grund für den Unterschied bei den Bitebenenzeigern, abhängig von der
Position, liegt in der genrot-Unterroutine, die die Modulos für die
Rotationstabelle generiert.

Für Position <= 1024 werden die Linien für den gedrückten Teil des Bildes
mithilfe positiver Bitplane-Modulos gefunden. Dies funktioniert nur, wenn
die Bitplane-Zeiger am Anfang der Bitplanes platziert werden.

Bei Position > 1024 sollte der gequetschte Teil des Bildes auf dem Kopf
angezeigt werden. Dies geschieht durch die Verwendung negativer Bitplane-
Modulos, und deshalb werden die Bitplane-Zeiger am Ende der Bitplanes
platziert.

Überschrift: Lassen Sie uns es einpacken

Beim Durchsuchen der Interwebs habe ich im Amiga Demoscene Archive einen Thread
gefunden, der den vertikalen Skalierungseffekt beschreibt. In diesem Thread
gibt es einen Link zur Fullmoon-Demo von Virtual Dreams und Fairlight.

Die Demo verwendet die Amiga Advanced Graphics Architecture (AGA), aber wie wir
hier gesehen haben, kann etwas Ähnliches mit dem Amiga Original Chipset (OCS)
gemacht werden.

Nun, das war ein langer Beitrag - ich habe viel gelernt, ich hoffe, du auch.

weblinks:
https://en.wikipedia.org/wiki/CORDIC
https://www.youtube.com/watch?v=TJe4RUYiOIg
https://www.mikrocontroller.net/attachment/31117/cordic1.pdf
http://amiga-dev.wikidot.com/hardware:bplxmod
http://amiga-dev.wikidot.com/hardware:bplxpth
https://ada.untergrund.net/?p=boardthread&id=903
http://theamigamuseum.com/the-hardware/the-aga-chipset/
http://theamigamuseum.com/the-hardware/the-ocs-chipset/
https://youtu.be/yVyw_qHIvBk

;------------------------------------------------------------------------------
36 - Amiga Machine Code Letter XII- The Starfield Effect

Der Starfield-Effekt
22.08.2020  20 min lesen

In diesem Beitrag werden wir einen Blick auf den Starfield-Effekt werfen -
einer der klassischen grafischen Effekte aller Zeiten. Wenn Sie erfahren
möchten, wie ein Sternenfeld auf dem Amiga programmiert ist, mit einfachen
Pixelzeichnungen und Doppelpufferung und einer Reihe von Festkomma-Arithmetik
- Sie sind an der richtigen Stelle.

Dieser Beitrag wurde vom Amiga Machine Code Course, Brief XII, inspiriert und
wir werden uns das STAR-Programm genauer ansehen, das nur kurz erwähnt wurde.
Den Code finden Sie auf DISK2.

Einer der ersten Fälle eines Sternenfeldes, den ich finden konnte, stammt aus
dem Jahr 1962 und ist Teil des Hintergrunds für ein Spiel namens Spacewar! Es
wurde in Assemblersprache für die PDP-1 geschrieben und ist eines der frühesten
Videospiele. Im Spiel würden zwei Raumschiffe um den Gravitationsbrunnen eines
Sterns kämpfen.

Das Spiel wurde auch eine Inspiration für Nolan Bushnell, der zusammen mit
Ted Dabney Atari gründen wollte.

Hier sehen wir Spacewar! läuft auf den Welten nur PDP-1. Foto von
Kenneth Lu. 

Abbildung 36-01: Spacewar

Zwei Männer spielen Spacewar! (Bildquelle)

Abbildung 36-02: Two men playing spacewar

Sie können Spacewar! sogar selbst in dieser Online-Version ausprobieren.

Genug Geschichte, werfen wir einen Blick auf das STAR-Programm für den Amiga.
Das Programm zeigt ein sich bewegendes und rotierendes Sternenfeld an. Es
verfügt über eine schnelle Unterroutine für die Pixelzeichnung und verwendet
doppelte Pufferung, um Bildschirmflackern zu vermeiden.

So sieht das Sternenfeld auf einem emulierten Amiga 500 aus. Ich habe das
Programm ein wenig verändert, so dass sich das Sternenfeld schneller
wiederholt.

Abbildung 36-03: starfield

Das Programm liest Sterndaten, Sinusdaten und Beschleunigungsdaten aus externen
Dateien. So können Sie das Programm in K-Seka zum Laufen bringen:

SEKA>r
FILENAME>star
SEKA>a
OPTIONS>
No Errors
SEKA>ri
FILENAME>acc
BEGIN>acc
END>
SEKA>ri
FILENAME>sin
BEGIN>sin
END>
SEKA>ri
FILENAME>stars
BEGIN>stars
END>
SEKA>j

Werfen wir einen genaueren Blick auf die Datendateien.

Überschrift: Sinusdaten

Damit das STAR-Programm funktioniert, müssen wir trigonometrische Berechnungen
durchführen. Da sowohl Sinus als auch Kosinus ziemlich teure Berechnungen sind,
wurde damals eine Technik verwendet, die Werte aus einer vorberechneten Tabelle
liefert.

Die Sinusdaten werden in der Datei SIN gespeichert, die Daten für eine Tabelle
mit 1280 Einträgen mit jeweils einem Wort länge enthält.

Die Periode des Sinus wird mit 1024 Einträgen modelliert, also was ist mit den
zusätzlichen 256 Einträgen? Die zusätzlichen Einträge sind eine bequeme
Möglichkeit, dieselbe Tabelle zu verwenden, um die Kosinuswerte zu halten, indem
sie die Beziehung

cos(theta) = sin(theta + pi/2) nutzt.

Dies impliziert auch, dass der Eintrag 256 dem Eintrag pi/2 entspricht,
der mit dem von 90° identisch ist. Ein kurzer Überblick gibt also

sin-Daten haben 1024 Einträge
cos-Daten haben 1024 Einträge

Die Datei hat die Größe von 1280 * 2 bytes = 2560 bytes.
Man könnte sagen, dass die Sinusdaten 1280 Einträge haben, aber im Grunde sind
es nur 1024 Einträge, da das Programm den Index umschließt.

Abbildung 36-04: Sine graph

Die Motorola 68000 CPU, die im Inneren des Amiga 500 sitzt, hat keine
Gleitkomma-Fähigkeiten, so verwenden wir stattdessen eine Technik namens
Festkomma-Arithmetik. Die Idee hinter Festkomma-Arithmetik ist es, die Daten
mit einer bestimmten Zahl zu multiplizieren und dann später mit der gleichen
Zahl zu teilen, so dass alle Berechnungen mit ganzen Zahlen durchgeführt
werden.

Wie im obigen Diagramm zu sehen ist, sind die Extreme +/-4095, bei denen
negative Werte als Zweier-Kompliment repräsentiert werden. Jede Berechnung, die
wir mit diesen Zahlen machen, muss irgendwann durch 4095 geteilt werden.

Überschrift: Star-Daten

Das Sternenfeld besteht aus Sternen, die in der Datei STARS definiert sind. Die
Daten sind als Tabelle mit 256 Einträgen strukturiert.

Jeder Sterneintrag wird als Polarkoordinaten angegeben, wobei die Radialkoordinate
"r" und die Winkelkoordinate "Theta" mit der Größe eines Wortes angegeben werden.
Bevor wir diese auf dem Amiga zeichnen können, müssen wir Polarkoordinaten den
kartesischen Koordinaten zuordnen, was wie folgt geschieht:

x = r cos("theta")
y = r sin("theta"),

wobei r der radiale Abstand vom Ursprung ist, und "Theta" der Winkel ist.
Positive Winkel sind eine Drehung gegen den Uhrzeigersinn um den Ursprung.

Abbildung 36-05: Star data

Das obige Diagramm der Daten zeigt, dass der Winkelwert im Allgemeinen doppelt
so groß ist wie der radiale Entfernungswert. Die Daten sehen irgendwie zufällig
aus, was das Sternenfeld realistischer erscheinen lässt.

Die GRÖßE der Datei STARS beträgt 256 * 4 bytes = 1024 bytes.

Überschrift: Beschleunigungsdaten

Der Sternenfeldeffekt kann überzeugender werden, wenn sich die Sterne in der 
Nähe der Mitte des Bildschirms langsamer bewegen, während sie sich nach außen
hin schneller bewegen.

Die Beschleunigungsfunktion kann mit dem Abstand vom Mittelpunkt des
Sternfeldes als Eingabe berechnet werden. Die Funktion hat die ordentliche
Eigenschaft, dass sie immer das gleiche Ergebnis liefert, wenn die gleiche
Eingabe gegeben wird. Mit anderen Worten, die Funktion soll rein sein - genau
wie die Sinus- und Kosinusfunktionen - und kann so durch eine
Nachschlagentabelle ersetzt werden, aufgrund der Referenztransparenz.

Da das Sternenfeld viele Sterne enthält, die beschleunigt werden müssen, können
wir viele verschwenderische Berechnungen vermeiden, indem wir eine
Nachschautabelle (lookup table) verwenden.

Die Tabelle ist in der ACC-Datei gespeichert und enthält 512 Einträge mit
Beschleunigungsdaten im Wortformat. Die Datei hat die Größe von
512 * 2 bytes = 1024 bytes.

Abbildung 36-06: Acceleration graph

Die Beschleunigungsdaten werden auch mit einer bestimmten Zahl multipliziert,
so dass sie für Festkomma-Arithmetik geeignet sind. Der extreme Wert ist 2001,
aber es ist nicht so offensichtlich, wie es mit Sinus war, was der
Skalierungsfaktor ist. Wir werden später darauf zurückkommen, wenn wir uns das
Programm ansehen.

Überschrift: Zeichnen des Sternenfeldes

Bevor wir in das Programm eintauchen, nehmen wir uns eine Minute Zeit, um die
Mathematik zu überprüfen, wie es funktioniert. Hoffentlich wird es danach
einfacher sein, den Assemblercode zu verstehen.

Das Sternenfeld wird von einem zentralen Punkt in der Mitte des Bildschirms
gezeichnet. Der Bildschirm ist 320 x 256 Pixel, und der Ursprungspunkt ist

(x_c, y_c) = (160, 128)

Das Sternenfeld besteht aus 256 Sternen, wobei jeder Stern durch seinen Winkel
"Theta" und seiner radialen Entfernung r gegeben ist. Bei jedem Frame-Update
werden sowohl das "Theta" als auch das r für alle Sterne aus denen das
Sternenfeld besteht aktualisiert.

Um einen Stern von der Mitte nach außen zu bewegen, wird bei jeder
Frameaktualisierung eine konstante "Delta r" zur radialen Entfernung
hinzugefügt.

r_n+1 = r_n + "Delta r"

Das Sternenfeld selbst dreht sich, und dies geschieht, indem man auch bei jeder
Frame-Aktualisierung eine Konstante "Delta Theta" zum Winkel "Theta" hinzufügt.

theta_n+1 = theta_n + "Delta theta"

Aus dem Ursprung des Koordinatensystems wird die Sterneposition in kartesischen
Koordinaten anhand dieser Formel berechnet.

x = x_c + acc(r_n+1) * sin(theta_n+1) 
y = y_c + acc(r_n+1) * cos(theta_n+1)

Wir können die Formeln visualisieren, indem wir uns ein Diagramm von r und
Theta ansehen und wie es auf dem Bildschirm aussieht.

Die "Theta" Einträge werden als Offset in Bytes angegeben, aber denken Sie
daran, dass "theta" die Wortgröße hat, sodass ein Offset von 512 korespondiert
zu 256 Einträgen in der Sinus- und Kosinustabelle.
Die Punkte erhalten Zahlen, um die Frame-nummer zu veranschaulichen.

Abbildung 36-07: Fixed angle

Wenn der Winkel "Theta" fixiert bleibt und der radiale Abstand r bei jeder
Frame-Aktualisierung erhöht wird, zeigt der Bildschirm einen Stern an, der an
den unteren Rand des Bildschirms "fällt". Der radiale Abstand kommt zurück
zu 0, wenn er größer als ein bestimmter Wert ist.

Abbildung 36-08: Fixed distance

Wenn wir den radialen Abstand r festhalten, während wir den Winkel "Theta"
erhöhen, dreht sich der Stern um die Mitte des Bildschirms, wenn sich der
frame aktualisiert.

Abbildung 36-09: Free angle and distance

Wenn wir bei jedem Frame-Update sowohl die "Theta" als auch die r erhöhen,
bewegt sich der Stern in einer Spirale um die Mitte des Bildschirms. Dies ist
das Verhalten, im STAR-Programm.

Die obigen Zahlen zeigen eine Flugbahn für einen Stern. Im Sternenfeld haben
wir 256 Sterne, jeder mit seiner eigenen Bahn.

Überschrift: Das STAR-Programm

Das STAR-Programm kann auf DISK2 gefunden werden, und ich habe den
Assemblercode unten aufgelistet und meine Kommentare hinzugefügt.

Der Code kann schwer zu verstehen sein, also überspringen Sie ihn, und lesen
Sie die detaillierten Folgeabschnitte.

Die allgemeine Umrisslinie des Programms ist es, eine Renderschleife
einzurichten, in der wir den Bildschirm löschen, Sternentfernungen
aktualisieren, Sterne zeichnen und dann Sternwinkel aktualisieren. Schließlich
wird der Bildschirm getauscht, um eine doppelte Pufferung zu ermöglichen,
d.h. auf einem Bildschirm zu zeichnen und den anderen anzuzeigen.

; file 1211.s = stars.s
start:
    move.w	#$4000,$dff09a  ; INTENA disable interrupts
    move.w	#$01a0,$dff096  ; DMACON disable bitplanes, blitter, and sprites
    
    lea.l	screen(pc),a1   ; store screen address in a1
    lea.l	bplcop(pc),a2   ; store bplcop address in a2

; start set screen address via copper list
    move.l	a1,d1           ; move screen address into d1
    move.w	d1,6(a2)        ; set BPL1PTH via the copper
    swap	d1              ; swap words in d1
    move.w	d1,2(a2)        ; set BPL1PTL via the copper
; end set screen address via copper list

    lea.l	copper(pc),a1   ; store copper address in a1
    move.l	a1,$dff080      ; set COP1LCH and COP1LCL
    
    move.w	#$8180,$dff096  ; DMACON enable bitplanes and copper

wait:
    move.l	$dff004,d0      ; read VPOSR and VHPOSR store in d0
    asr.l	#8,d0           ; right shift 8 places 
    andi.w	#$1ff,d0        ; keep 9 least significant bits, so
                            ; that d0 contains vertical beam position
    bne.s	wait            ; if vertical beam is not 0 goto wait                                

    bsr.s	clear           ; branch to subroutine clear
    bsr	    star			; branch to subroutine star
    bsr.s	rotate          ; branch to subroutine rotate
    bsr.s	swapscr         ; branch to subroutine swapscr

    btst	#6,$bfe001      ; test left mouse button
    bne.s	wait            ; if not pressed goto wait

; start restore workbench copper
    move.l	4.w,a6          ; move ExecBase of exec.library into a6
    move.l	156(a6),a6      ; IVBLIT points to GfxBase
    move.l	38(a6),$dff080  ; copinit ptr to copper start up list 
                                ; restore workbench copperlist 
; end restore workbench copper

    move.w	#$8020,$dff096  ; DMACON - enable sprite
    rts                     ; exit program

scr:                        ; screeen counter
    dc.w	0

; swap screens using the copper
swapscr:
    lea.l	scr(pc),a1      ; store scr address in a1
    addq.w	#1,(a1)         ; add 1 to scr value
    move.w	(a1),d1         ; move scr value into d1
    andi.w	#1,d1           ; keep first bit of d1
    mulu	#10240,d1       ; multiply d1 with a 320x256 bitplane
    lea.l	screen(pc),a1   ; store screen address in a1
    lea.l	bplcop(pc),a2   ; store bplcop address in a2
    add.l	a1,d1           ; add screen address to bitplane offset
    move.w	d1,6(a2)        ; set BPL1PTH via the copper
    swap	d1              ; swap words in d1
    move.w	d1,2(a2)        ; set PBL1PTL via the copper
    rts                     ; return from subroutine

; sets the rotation speed of the starfield
rotate:
    lea.l	stars(pc),a1    ; store stars address in a1
    move.w	#255,d0         ; initialize counter d0
rotloop:
    addq.w	#3,(a1)         ; increment value pointed to by a1 with 3
							; (rotation speed - change direction use subq.w)
    addq.l	#4,a1           ; add 4 to address pointer i.e. next value
    dbra	d0,rotloop      ; if counter > -1 goto rotloop
    rts                         ; return from subroutine

; clear the screen using the blitter
clear:
    btst	#6,$dff002          ; DMACONR test if blitter is enabled 
    bne.s	clear               ; if blitter not enabled goto clear
                                    ; this is a wait for blitter to finish

    lea.l	screen(pc),a1       ; store screen address in a1
    lea.l	scr(pc),a2          ; store scr address in a2
    move.w	(a2),d1             ; move scr counter value into d1
    not.w	d1                  ; invert d1
    andi.w	#1,d1               ; keep first bit - d1 is either 0 or 1
    mulu	#10240,d1           ; multiply d1 with a 320x256 bitplane
    add.l	d1,a1               ; add the bitplane offset to screen address
    move.l	a1,$dff054          ; set BLTDPTH / BLTDPTL to address a1 
    clr.w	$dff066             ; clear BLTDMOD
    move.l	#$01000000,$dff040  ; set BLTCON0 and BLTCON1 with use D=0
    move.w	#$4014,$dff058      ; BLTSIZE,height=256,width=20 words (320px)
cl2:
    btst	#6,$dff002          ; DMACONR, test if blitter is enabled
    bne.s	cl2                 ; if blitter not enabled goto cl2
                                ; this is a wait for blitter to finish
    rts                         ; return from subroutine

; draw stars and update their radial distance
star:
    lea.l	screen(pc),a0   ; store screen address in a0
    lea.l	scr(pc),a1      ; store scr address in a1
    move.w	(a1),d1         ; move scr value into d1
    not.w	d1              ; invert d1
    andi.w	#1,d1           ; keep first bit
    mulu	#10240,d1       ; multiply d1 with size of a 320x256 bitplane
    add.l	d1,a0           ; add bitplane offset to screen address
    lea.l	sin(pc),a1      ; store sin table address in a1
    lea.l	sin+512(pc),a2  ; store cos table address in a2
    lea.l	stars(pc),a3    ; store stars table address in a3
    lea.l	acc(pc),a4      ; store acc table address in a4
    move.w	#255,d7         ; initialize loop counter d7
starloop:
    move.w	(a3)+,d2        ; d2 = star.angle, a3 = star.dist
    andi.w	#$7fe,d2        ; star.angle offset must be even
    move.w	(a1,d2.w),d0    ; d0 = sin(star.angle)
    move.w	(a2,d2.w),d1    ; d1 = cos(star.angle) 
    addq.w	#4,(a3)         ; star.dist += 4
    move.w	(a3)+,d2        ; d2 = star.dist, a3 = star.angle
    andi.w	#$03fe,d2       ; star.dist offset must be even
    muls	(a4,d2.w),d0    ; d0 = acc(star.dist) * d0
    swap	d0              ; swap words in d0
    add.w	#160,d0         ; add 160 to d0
    muls	(a4,d2.w),d1    ; d1 = acc(star.dist) * d1
    swap	d1              ; swap words in d1
    add.w	#128,d1         ; add 128 to d1
    lsl.w	#3,d1           ; divide d1 with 32
    move.w	d1,d3           ; move d1 into d3
    lsl.w	#2,d3           ; divide d3 with 8
    add.w	d3,d1           ; add d3 to d1 (d1=40*d1=32*d1+8*d1)
    move.w	d0,d2           ; move d0 into d2
    lsr.w	#3,d0           ; divide d0 with 8
    add.w	d1,d0           ; add d1 to d0 - offset from screen in bytes
    not.b	d2              ; invert d2 - find bit number to set
    bset	d2,(a0,d0.w)    ; set bit number d2 at address of screen + d0
    dbra	d7,starloop     ; if d7 > -1 goto starloop
    rts                         ; return from subroutine

copper:
    dc.w	$2001,$fffe		; wait($01,$20)
    dc.w	$0102,$0000		; BPLCON1 set to $0
    dc.w	$0104,$0000		; BPLCON2 set to $0
    dc.w	$0108,$0000		; BPL1MOD set to $0
    dc.w	$010a,$0000		; BPL2MOD set to $0
    dc.w	$008e,$2c81		; DIWSTRT top right corner ($81,$2c)
    dc.w	$0090,$f4c1		; DIWSTOP enable PAL trick
    dc.w	$0090,$38c1		; DIWSTOP buttom left corner ($1c1,$12c)
    dc.w	$0092,$0038		; DDFSTRT data fetch start at $38
    dc.w	$0094,$00d0		; DDFSTOP data fetch stop at $d0
    dc.w	$0180,$0000		; COLOR00 black background
    dc.w	$0182,$0f8f		; COLOR01 light-magenta star color

    dc.w	$2c01,$fffe		; wait($01,$2c)
    dc.w	$0100,$1200		; BPLCON0 enable 1 bitplane, color burst

bplcop:
    dc.w	$00e0,$0000		; BPL1PTH set by start and swapscr
    dc.w	$00e2,$0000		; BPL1PTL set by start and swapscr

    dc.w	$ffdf,$fffe		; wait($df,$ff) enable wait > $ff horiz
    dc.w	$2c01,$fffe		; wait($01,$12c)
    dc.w	$0100,$0200		; move to BPLCON0 disable bitplane
                            ; needed to support older PAL chips.
    dc.w	$ffff,$fffe		; end of copper

stars:
    blk.l	256,0			; allocate 256 entries of star angles and postions

sin:
    blk.w	1280,0			; allocate 1280 entries of sine data

acc:
    blk.w	512,0

screen:
    blk.w	10240,0

Lassen Sie uns die Details ansehen.

Überschrift: Doppelte Pufferung

Doppelte Pufferung bedeutet, dass wir zwei Puffer für den Bildschirm halten.
Der Kern ist, dass wir einen Puffer ändern, während der Bitebenenzeiger auf
den anderen Puffer festgelegt ist. Diese Technik stellt sicher, dass wir nur
ein fertiges Bild zeigen, während das nächste Bild vorbereitet wird. In dem wir
das Zwischenbild nicht anzeigen, vermeiden wir auch Bildschirmflackern.

Der Bildschirm ist 320x256 (PAL) mit einer Bitebene, die 10.240 Bytes
Arbeitsspeicher benötigt. Wir brauchen das Doppelte, um einen doppelten Puffer
zu haben.

screen:
    blk.w	10240,0

Das Programm verwendet die Variable scr, um zu bestimmen, welche Puffer
angezeigt wird. Es wird in der Stern-Unterroutine erhöht und ein AND wird
verwendet, um alles außer dem ersten Bit zu filtern. Dies ist eine nette
Möglichkeit, einen Umschalter zu machen.

scr:                            ; screeen counter
    dc.w	0

In der Warteschleife löschen wir zuerst den Puffer, der nicht angezeigt wird,
und zeichnen dann die Sterne, mit aktualisierten Sternwinkel und tauschen dann
den Bildschirmpuffer aus.

    bsr.s	clear				; branch to subroutine clear
    bsr	    star				; branch to subroutine star
    bsr.s	rotate				; branch to subroutine rotate
    bsr.s	swapscr				; branch to subroutine swapscr

Doppelte Pufferung ist hier unerlässlich, da wir den Bildschirm löschen und das
Sternenfeld neu zeichnen. Die Verwendung eines einzelnen Puffers würde flackern
oder einen schwarzen gelöschten Bildschirm verursachen.

Die Routine clear wartet darauf, dass der Blitter beim Betreten bereit
ist. Es ist wichtig, auf den Blitter zu warten, da ein vorheriger Vorgang
möglicherweise noch ausgeführt wird. Wir tun dies, indem wir ein geschäftiges
Warten durchführen.

clear:
    btst	#6,$dff002          ; DMACONR test if blitter is enabled 
    bne.s	clear               ; if blitter not enabled goto clear
                                ; this is a wait for blitter to finish 
									   
Wenn der Blitter fertig ist, richten wir den Blitter ein, um den Puffer zu
löschen. Zuerst richten wir den Zeiger auf den Bildschirmpuffer und die
scr-Variable ein. Wir invertieren die scr-Variable, so dass wir den Puffer
löschen, der derzeit nicht angezeigt wird.

    lea.l	screen(pc),a1       ; store screen address in a1
    lea.l	scr(pc),a2          ; store scr address in a2
    move.w	(a2),d1             ; move scr counter value into d1
    not.w	d1                  ; invert d1
    andi.w	#1,d1               ; keep first bit - d1 is either 0 or 1
    mulu	#10240,d1           ; multiply d1 with a 320x256 bitplane
    add.l	d1,a1               ; add the bitplane offset to screen address
    move.l	a1,$dff054          ; set BLTDPTH / BLTDPTL to address a1 
    clr.w	$dff066             ; clear BLTDMOD
    move.l	#$01000000,$dff040  ; set BLTCON0 and BLTCON1 with use D=0
    move.w	#$4014,$dff058      ; BLTSIZE,height=256,width=20 words (320px)

Der Blitter wird über BLTCON0 und BLTCON1 so eingerichtet, dass D=0 ist d.h.
das Ziel des Blit mit Nullen geschrieben wird. Voila - der Puffer ist gelöscht.
Dies hat auch den zusätzlichen Vorteil der Freigabe der CPU, da die ganze
Arbeit durch den Blitter erledigt wird.

Wir verwenden den Blitter-Funktionsgenerator, um das Ziel D zu setzen. 
Lesen Sie hier: Amiga Machine Code Letter VI - Blitter

Wir beenden die Routine clear, indem wir darauf warten, dass der Blitter den
Puffer fertig gelöscht hat. 

cl2:
    btst	#6,$dff002          ; DMACONR, test if blitter is enabled
    bne.s	cl2                 ; if blitter not enabled goto cl2
                                ; this is a wait for blitter to finish
    rts                         ; return from subroutine

Wir haben jetzt den Puffer geräumt und sind bereit, einige Sterne zu zeichnen.

Überschrift: Starloop

Der Starloop ist der eigentliche Motor hinter dem Starfield-Effekt. Hier werden
die Sterne aktualisiert und auf den Bildschirm gezogen. Es ist alles ein
bisschen kompakt und erfordert eine detaillierte Beschreibung. Werfen wir einen
Blick darauf, Zeile für Zeile.

Bevor der Starloop eingegeben wird, werden einige Initialisierungsschritte
durchgeführt. Wir müssen Zeiger auf die Sinus-, Kosinus-, Sterne- und
Beschleunigungstabellen einrichten.

    lea.l	sin(pc),a1			; store sin table address in a1
    lea.l	sin+512(pc),a2		; store cos table address in a2
    lea.l	stars(pc),a3		; store stars table address in a3
    lea.l	acc(pc),a4			; store acc table address in a4

Als nächstes betreten wir den Starloop, wo jeder Stern zum Bildschirmpuffer
gezogen wird, der derzeit nicht angezeigt wird.

Zuerst holen wir den Winkel des aktuellen Sterns und nach dem Inkrement a3, so
dass er auf die aktuelle Stern-Radialdistanz zeigt.

    move.w	(a3)+,d2			; d2 = star.angle, a3 = star.dist
    andi.w	#$7fe,d2			; star.angle offset must be even

Der Sternwinkel in d2 wird dann mit einem AND gefiltert, so dass er als Index
in die Sinus- und Kosinustabellen verwendet werden kann. Die Einträge in diesen
Tabellen haben die Wortgröße und der größte Index ist 1023. Da der Index als
Offset in Bytes angegeben wird, sind nur Zahlen bis 2046 zulässig. Daher ist
das Zwischen AND

$7fe = %0000.0111.1111.1110

Der Sternwinkel d2 wird dann als Offset verwendet, um die Sinus- und
Kosinusdaten abzurufen. Die Ergebnisse werden in d0 und d1 gespeichert,
die die x- und y-Koordinaten enthält.

    move.w	(a1,d2.w),d0		; d0 = sin(star.angle)
    move.w	(a2,d2.w),d1		; d1 = cos(star.angle) 

Die Sterndistanz wird erhöht, so dass es aussieht, als käme der Stern auf uns
zu. Dies geschieht durch Hinzufügen von 4 zur Sternentfernung.

    addq.w	#4,(a3)				; star.dist += 4
    move.w	(a3)+,d2			; d2 = star.dist, a3 = star.angle
    andi.w	#$03fe,d2			; star.dist offset must be even

Der Sternabstand wird in d2 gespeichert, und der a3-Zeiger wird
post-inkrementiert, so dass er auf den Winkel des nächsten Sterns zeigt.

Der Sternabstand in d2 wird als Index in die Beschleunigungstabelle verwendet.
Diese Tabelle enthält 512 Einträge von Wortgrößendaten. Da der Index als Offset
in Bytes angegeben wird, sind nur Zahlen bis 1022 zulässig. Wir sorgen dafür
mit einem Zwischen AND

$3fe = %0000.0011.1111.1110

Als nächstes holen wir den Wert aus der Beschleunigungstabelle ab.

    muls	(a4,d2.w),d0		; d0 = acc(star.dist) * d0
    swap	d0					; swap words in d0
    add.w	#160,d0				; add 160 to d0
		
Der d0-Wert (die x-Koordinate) wird mit dem Ergebnis der Suche in der
Beschleunigungstabelle multipliziert. Dies erhöht die radiale Entfernung des
Sterns, so dass es scheint, wenn er auf uns zukommt,  macht er einen längeren
Weg wenn er von der Mitte kommt.

Der Swap ist eine sehr ordentliche Art der Teilung, um unsere
Fixpunkt-Arithmetik arbeit zu machen.

Da wir nur das am wenigsten bedeutsame Wort von d0 verwenden, ist der Swap im
Wesentlichen eine Division mit 65536. Der Winkel ist ein Faktor, der zu groß
ist, und die Beschleunigung ist vielleicht ein Faktor, der zu groß ist.
Zusammen ergeben sich dadurch eine Berechnung, die einen Faktor von
$1000 * $10 € = $10000 zu groß ist. Aus diesem Grund ist der Swap im
Wesentlichen dasselbe wie die Aufteilung mit dem Faktor $10000.

Das Programm fügt dann 160 zu d0 hinzu, so dass der Ursprung für die
x-Koordinate in die Mitte des 320 Pixel breiten Bildschirms verschoben wird.

Im Wesentlichen wird das gleiche für die y-Koordinate d1 getan.

    muls	(a4,d2.w),d1		; d1 = acc(star.dist) * d1
    swap	d1					; swap words in d1
    add.w	#128,d1				; add 128 to d1

Beachten Sie, dass 128 der y-Koordinate hinzugefügt wird, um ihn in die
Mitte des 256 Pixel hohen Bildschirms zu verschieben.

Als Nächstes beginnen wir, die Koordinate auf den Bildschirm zu zeichnen.

Die Unterroutine für das Erstellen von Pixelzeichnungen wurde erwähnt in: 
Amiga Machine Code Letter XI - Fizzle Fade
Das d1-Register muss von einer y-Koordinate zu einem Speicherversatz
zugeordnet werden, indem es mit 40 multipliziert wird, da jede Zeile 40 Bytes
oder 320 Pixel beträgt.

    lsl.w	#3,d1   ; logical shift d1 left 3 places (multiply with 8)
    move.w	d1,d3   ; move d1 into d3
    lsl.w	#2,d3   ; logical shift d3 left 2 places (multiply with 4)
    add.w	d3,d1   ; add d3 to d1 (now we have multiplied d1 with 40 = 32+8)

Als nächstes müssen wir die x-Koordinaten einem Speicherversatz zuordnen.

    move.w	d0,d2   ; move d0 into d2
    lsr.w	#3,d0   ; logical shift d0 right 3 places (divide with 8)
    add.w	d1,d0   ; add d1 to d0

Wir erstellen eine Kopie der x-Koordinaten und teilen sie durch 8 durch Bit-
Verschiebung um drei Stellen nach rechts. Dies gibt uns einen Offset im Speicher
für die x-Koordinate, die wir dem Speicheroffset für die y-Koordinate
hinzufügen und in d0 speichern können.

Wir kennen jetzt den Offset in Bytes, wo das Pixel gezeichnet werden soll. Wir
zeichnen das Pixel mithilfe der BSET-Anweisung, die das angegebene Bit im Ziel
festlegt, das entweder ein Datenregister oder ein Speicher sein kann.

Das angegebene n'te Bit wird gefunden, indem d2 - unsere Kopie der
x-Koordinaten - invertiert wird.

    not.b	d2					; invert d2
    bset	d2,(a0,d0.w)		; set bit number d2 at address of screen + d0

Hier ist etwas Magie los. Wie bestimmen wir das zu zeichnende Pixel? Nun, es
ist das NOT, das den Trick macht.

Hier ist ein Beispiel. Angenommen, x=3, welches Pixel sollte gezeichnet werden,
oder welches Bit im Byte sollte gesetzt werden?

x = 3 : %0000.0011
!x =  : %1111.1100
7&!x =: %0000.0100

In der letzten Zeile habe ich ein AND hinzugefügt, so dass die Position !x in
der Position eines Bytes gehalten wird.

Das Ergebnis von %0000.0100 zeigt an, dass BSET das 4. Bit festlegen
sollte, wobei Bit Null auf das am wenigsten signifikante Bit verweist.

Abbildung 36-10: bit to pixel

Es stellt sich heraus, dass wir das angegebene n'te Bit nicht innerhalb eines
Bytes halten müssen. Da es sich bei dem Ziel um einen Speicherort
handelt, geht BSET davon aus, dass die Bitnummer des Ziels (das n'te Bit)
Modulo 8 ist.

Überschrift: Weitere Dinge

Wir haben nicht viel über Rotation gesprochen, und die Aktualisierungen auf
den Winkel "Theta". Ich werde es vorerst auslassen, aber Sie könnten einige
Dinge auf eigene Faust versuchen.

Versuchen Sie, die Größe der Winkelinkremente zu ändern. Je größer die
Inkremente, desto spiralförmiger wird das Sternenfeld, und es wird auch
schneller rotieren.
Die Periodizität des Sternenfeldes, d.h. die Zeit, die vergehen wird, bevor
sich das Sternenfeld wiederholt, kann auch durch die Wahl eines
ungleichmäßigen Winkelinkrements erhöht werden.

Überschrift: Was ist mit Atari?

Schließlich haben Nolan Bushnell und Ted Dabney, herausgefunden, wie man einen
Spacewar macht! Wie ein Spiel auf benutzerdefinierter Hardware läuft, anstatt
mit einem teuren Computer.

Das Spiel wurde Computer Space genannt und es wurde das erste Arcade-Videospiel
der Welt. Es war kein kommerzieller Erfolg, aber es öffnete die Türen für das
was Atari werden sollte.

Hier ist eine Szene aus dem Filmklassiker Soylent Green, in der Leigh
Taylor-Young Computer Space spielt. Das Design war eher futuristisch und passte
hervorragend zum Film. Soylent Green ist People!!!

Abbildung 36-11: Computer Space

weblinks:
https://www.computerhistory.org/pdp-1/
https://www.flickr.com/photos/24226200@N00/364960084/
https://www.computerhistory.org/pdp-1/spacewar/
https://www.masswerk.at/spacewar/
https://en.wikipedia.org/wiki/Motorola_68000
http://amiga.resource.cx/mod/a500.html
https://www.cs.cornell.edu/~tomf/notes/cps104/twoscomp.html
https://mathworld.wolfram.com/PolarCoordinates.html
http://developingthoughts.co.uk/the-power-of-purity/
https://en.wikipedia.org/wiki/Referential_transparency
http://amiga-dev.wikidot.com/hardware:bltcon0
https://github.com/pong74ls/ComputerSpaceSchematics
https://en.wikipedia.org/wiki/Computer_Space

;------------------------------------------------------------------------------
37 - Amiga Machine Code Letter XII- Horizontal Sine Shifting

Horizontale Sinusverschiebung
Okt 11, 2020  18 min lesen

Einer der klassischen Demo-Effekte aller Zeiten ist die horizontale
Verschiebung mit einer Sinuswelle. Dieser Effekt ist einfach auf dem Amiga zu
codieren, mit Copper-Anweisungen, um zeitgesteuerte Updates an die
benutzerdefinierten Chip-Register zu liefern.

Im Folgenden werden wir uns ansehen, wie dies geschieht, und ein bisschen
erklären, wie der Amiga auf dem Weg funktioniert. Dieser Beitrag ist
inspiriert von Brief XII des Amiga Machine Code Kurs.

Der Amiga war einer der letzten Farbcomputer, bei denen alles mit dem
Video-Display-System im Einklang stand. Diese Synchronisierung spiegelt sich
bis hin zur DMA-Zeitfensterarchitektur wieder und ist ein wesentlicher
Bestandteil des horizontalen Sinusverschiebungseffekts.

Wenn Sie eine Aktualisierung dessen benötigen, was der DMA (Direct Memory
Access) ist, dann werfen Sie einen Blick auf den Beitrag DMA Revisited.
Durch den DMA-Bus werden alle Daten aus dem Chipspeicher zwischen den
verschiedenen Hardware-Abschnitten übertragen. Nur ein Master kann die
Datenübertragung über den Bus initiieren, wenn also zwei Master versuchen,
den Bus gleichzeitig zu benutzen, passieren schlimme Dinge. Um dies zu
verhindern, wird der Hardware ein Mechanismus hinzugefügt, der bestimmt,
welcher Master den Bus verwenden darf. Dieser Mechanismus wird
Bus-Schiedsverfahren (Bus arbitration) genannt.

Ohne andere Erweiterungsgeräte hat der Amiga 500 zwei Master. Ein Master
ist die 68000 CPU und der andere ist (Fat) Agnus, der sich im
benutzerdefinierten Chip-Bereich befindet. Der Buscontroller heißt Gary.

In gewisser Weise ist der Amiga nicht nur ein, sondern zwei Computer, mit dem
Bus arbitration Controller als Dirigent, der das Orchester leitet

Abbildung 37-01: Amiga block diagram

Dieses Design ermöglicht es der CPU, viel Arbeit an die benutzerdefinierten
Chips zu delegieren, und gab die außergewöhnliche Leistung, die der Amiga
an die Heimcomputerszene lieferte.

Der horizontale Scrolling-Effekt verwendet dieses Design ziemlich effektiv. Es
lässt die CPU Sinusdaten in die Copperliste schreiben, die in Chip-Ram
gespeichert sind, während die horizontale Verschiebung auf die
benutzerdefinierten Chips delegiert wird. Sehen wir uns nun an, wie es
funktioniert.

Überschrift: Das Wave-Programm

Der Code für diesen Effekt ist im Ordner wave von DISK2 gespeichert und das
Programm heißt wave. Es erzeugt eine horizontale Welle, indem der Copper
verwendet wird, um den horizontalen Bildlauf für ausgewählte Scanlinien
festzulegen.

Das Wellenprogramm erzeugt eine Ausgabe wie diese:

Abbildung 37-02: Wave effect animation

Wenn Sie es selbst ausprobieren möchten, geben Sie folgendes in K-Seka ein,
um das Programm zu assemblieren und die Datendateien in den Speicher zu
laden:

SEKA>r
FILENAME>wave
SEKA>a
OPTIONS>
No errors
SEKA>ri
FILENAME>sine
BEGIN>sine
END>
SEKA>ri
FILENAME>screen
BEGIN>screen
END>
SEKA>j

Werfen wir einen genaueren Blick auf die Datendateien.

Überschrift: Bildschirmdaten

Die Datei SCREEN enthält ein Lo-Res-Bild von 320 x 256 Pixeln mit 4 Farben,
d.h. zwei Bitebenen. Dieses Bild wurde speziell für diesen Effekt durch
Hinzufügen von schwarzen Rändern vorbereitet - ein wichtiges Detail, das wir
später sehen werden.

Die Datei enthält die Colormap gefolgt von den beiden Bitebenen.

Colormap: 4 Farben * 1 Wort = 8 Bytes
Bitplanes: 2 Bitplanes * (40 Bytes * 256 Zeilen ) = 20.480 Bytes
Die Datei enthält insgesamt 20.488 Bytes.

Überschrift: Sinusdaten

Um einen realistischen Welleneffekt zu erzeugen, verwenden wir oft eine
Sinusfunktion. Da die Berechnung des Sinus ziemlich teuer ist, bestand eine
gängige Technik damals darin, eine Tabelle mit vorberechneten Sinuswerten zu
verwenden. Das ist es auch, was wir hier tun.

Die Sinustabelle enthält 328 Einträge mit jeweils einem Wort, wobei die Werte
im Bereich von 0 bis 14 liegen. Die Daten werden in der Datei SIN mit einer
Größe von 656 Byte gespeichert.

Abbildung 37-03: Sinusdaten

Das Speichersystem ist etwas verschwenderisch, aber es ist wirklich einfach,
es innerhalb des Programms zu verwenden. Werfen wir einen Blick auf den ersten
Maximalwert.

Offset in Bytes		Byte1	Byte2
50					$00		$EE

Der Sinuswert ist in diesem Fall "$E", alles andere sind nur Anpassungen um
den Wert in BPLCON1 einzugeben, ein benutzerdefiniertes Chipregister, das
für die Einstellung von Horizonal-Scroll-Werten für beide playfields
verantwortlich ist. Es befindet sich bei $DFF102.

Abbildung 37-04: bplcon1

Diese Demo verwendet keine dual playfields, daher müssen wir für beide
playfields den gleichen horizontalen Bildlaufwert verwenden. Aus diesem Grund
wird die $E - wiederholt und wird zu $EE.

Überschrift: Das Programm

Ich habe meine eigenen Kommentare zum Code unten hinzugefügt, nur um einen
groben Überblick über das zu bekommen, was passiert.

Ich empfehle, dass Sie schnell durchlesen, und dann die tieferen Sachen unten
lesen, die folgen.

; file mc1204.s = wave.s
start:
  move.w  #$4000,$dff09a	; INTENA disable interrupts
  move.w  #$01a0,$dff096	; DMACON disable bitplane, copper, and sprites

  lea.l   screen(pc),a1		; move screen address into a1
  move.l  #$dff180,a2		; move COLOR00 address into a2
  moveq   #3,d0				; initialize loop counter d0 to 3
colloop:					; color loop
  move.w  (a1)+,(a2)+		; copy from a1 (screen) to a2 (color table)
  dbra    d0,colloop		; if d0 > -1 goto colloop

  lea.l   bplcop+2(pc),a2	; move bplcop+2 address into a2
  move.l  a1,d1				; move a1 (first bitplane in screen) into d1
  moveq   #1,d0				; initialize loop counter d0 to 1
bplloop:					; bitplane loop
  swap    d1				; swap words of d1
  move.w  d1,(a2)			; set BPL1PTH to high 3 bits of bitplane address
  swap    d1				; swap words of d1
  move.w  d1,4(a2)			; set BPL1PTL to low 15 bits of bitplane address
  addq.l  #8,a2				; increment bplcop pointer with 8
  add.l   #10240,d1			; increment d1 to point at next bitplane in screen
  dbra    d0,bplloop		; if d0 > -1 goto bplloop

  bsr.s	initcop				; branch to subroutine initcop

  lea.l   copper(pc),a1		; move copper address into a1
  move.l  a1,$dff080		; move a1 into COP1LCH and COP1LCL

  move.w  #$8180,$dff096	; DNACON enable bitplane, copper

wait:						; busy wait for beam
  move.l  $dff004,d0		; move VPOSR and VHPOSR into d0
  asr.l   #8,d0				; shift right 8 places
  andi.w  #$1ff,d0			; keep first 9 bits vertical position of beam
  cmp.w   #280,d0			; is beam at line 280?
  bne.s   wait				; if not goto wait

  bsr.s   wave				; branch to subroutine wave

  btst    #6,$bfe001		; test left mouse button
  bne.s   wait				; if not pressed goto wait

  move.l  $04.w,a6			; make a6 point to ExecBase of exec.library
  move.l  156(a6),a6		; IVBLIT points to GfxBase
  move.l  38(a6),$dff080	; copinit ptr to copper start up list restore workbench copperlist

  move.w  #$8020,$dff096	; DMACON enable sprite
  rts						; return from subroutine

initcop:					; initialize copper list
  lea.l	  wavecop(pc),a1	; move wavecop address into a1
  move.w  #$4adf,d1			; move copper wait for vpos >= $4a and hpos >= $de
  move.w  #199,d0			; initilize loop counter d0 to 199
initcoploop:				; add waits to wavecop
  move.w  d1,(a1)+			; set wait - post incr. a1
  move.w  #$fffe,(a1)+		; set wait mask - post incr. a1
  move.l  #$01020000,(a1)+	; set BPLCON1 - post incr. a1
  add.w   #$100,d1			; increment scanline by 1
  dbra    d0,initcoploop	; if d0 > -1 goto initcooloop
  rts						; return from subroutine

cont:
  dc.w	0					; index into the sine table

wave:
  lea.l   cont(pc),a1       ; move cont address into a1
  move.w  (a1),d1           ; move cont value into d1
  addq.w  #2,(a1)           ; cont += 2
  andi.w  #$fe,d1           ; keep first word and allign it to an equal number
  lea.l   sin(pc),a1        ; move sin address into a1
  add.w   d1,a1             ; add the offset to the sine table
  lea.l   wavecop+6(pc),a2  ; move wavecop+6 into a2
  move.w  #199,d0           ; loop counter d0 = 199
waveloop:                   ; loop over 200 scanlines in copper
  move.w  (a1)+,(a2)        ; copy sine value to copper (set DFF102)
  addq.l  #8,a2             ; move to next scanline in copper
  dbra    d0,waveloop       ; if d0 > -1 goto waveloop
  rts                       ; return from subroutine

copper:
  dc.w	$2001,$fffe  ; wait for vpos >= $20 and hpos >= 0
  dc.w	$0104,$0000  ; move $0000 to $dff104 BPLCON2 video
  dc.w	$0108,$0000  ; move $0000 to $dff108 BPL1MOD modulus odd planes
  dc.w	$010a,$0000  ; move $0000 to $dff10a BPL2MOD modulus even planes
  dc.w	$008e,$2c81  ; move $2c81 to $dff08e DIWSTRT upper left corner ($81,$2c)
  dc.w	$0090,$f4c1  ; move $f4c1 to $dff090 DIWSTOP (enable PAL trick)
  dc.w	$0090,$38c1  ; move $38c1 to $dff090 DIWSTOP (PAL trick) lower right corner ($1c1,$12c)
  dc.w	$0092,$0038  ; move $0038 to $dff092 DDFSTRT data fetch start at $38
  dc.w	$0094,$00d0  ; move $00d0 to $dff094 DDFSTOP data fetch stop at $d0

  dc.w	$2c01,$fffe  ; wait for vpos >= $2c and hpos >= 0
  dc.w	$0100,$2200  ; BPLCON0 enable 2 bitplanes, enable color burst

bplcop:
  dc.w	$00e0,$0000  ; BPL1PTH (high bit 16-31)
  dc.w	$00e2,$0000  ; BPL1PTL (low  bit 0-15)
  dc.w	$00e4,$0000  ; BPL2PTH (high bit 16-31)
  dc.w	$00e6,$0000  ; BPL2PTL (low bit 0-15)

wavecop:
  blk.w	1600/2,0     ; allocate 800 words

  dc.w	$2c01,$fffe  ; wait for vpos >= $12c and hpos >= 0 (explained later)
  dc.w	$0100,$0200  ; BPLCON0 disable bitplane - older PAL chips.
  dc.w	$ffff,$fffe  ; wait indefinitely - until next vertical blanking

sin:
  blk.w	656/2,0

screen:
  blk.w	20488/2,0

Lassen Sie uns das Programm in seine wichtigen Komponenten zerlegen.

Das Programm beginnt mit dem Kopieren der colormap in die Farbregister und
Bitplane-Pointer in die Copper-Liste. Es geht dann in eine Schleife, die
darauf wartet, dass der Strahl die Abtastzeile 280 erreicht. Dies stellt
sicher, dass das Wellenunterprogramm nur einmal pro frame aufgerufen wird.

Zu guter letzt überprüfen wir, ob die linke Maustaste gedrückt wurde. Ist
dies der Fall, wird die copperliste der Workbench wiederhergestellt und
das Programm beendet.

Schauen wir uns die Unterprogramme an.

Überschrift: Initialisieren von Copper

Die initcop-Unterroutine initialisiert horizontale Verschiebungen für
200 Scanlinien, indem Anweisungen in den Speicher eingefügt werden, der auf
dem Label wavecop zugewiesen ist.

initcop:					; initialize copper list
  lea.l	  wavecop(pc),a1	; move wavecop address into a1
  move.w  #$4adf,d1			; move copper wait for vpos >= $4a and hpos >= $de
  move.w  #199,d0			; initilize loop counter d0 to 199
initcoploop:				; add waits to wavecop
  move.w  d1,(a1)+			; set wait - post incr. a1
  move.w  #$fffe,(a1)+		; set wait mask - post incr. a1
  move.l  #$01020000,(a1)+	; set BPLCON1 - post incr. a1
  add.w   #$100,d1			; increment scanline by 1
  dbra    d0,initcoploop	; if d0 > -1 goto initcooloop
  rts						; return from subroutine

Für jede der 200 Scanlines wird eine Wartezeit hinzugefügt, gefolgt von einer
Verschiebung zum benutzerdefinierten Chipregister BPLCON1, mit dem Wert $0000.
Das wave Unterprogramm überschreibt sie später mit Sinuswerten.

Der horizontale Scrolling-Effekt erfordert ein reibungsloses Scrollen. Wir
können dies nicht erreichen, indem wir die Bitebenenzeiger und Modulo
verwenden, da er den Bildschirm horizontal in Schritten von 16 Pixeln
(1 Wort) bewegt.

Feines Scrollen in Schritten von einem Pixel erfolgt mit BPLCON1. Es
funktioniert durch Hinzufügen einer Verzögerung zur Ausgabe von Pixeldaten und
kann einen Wert von 0 bis 15 haben, wobei 0 keine Verschiebung ist. Beim
größten Wert werden die Pixel verzögert, so dass sie 15 Pixel später angezeigt
werden, als sie es sonst wären. Mit anderen Worten, die Pixel werden nach
rechts verschoben.

Es gibt einen guten Abschnitt über reibungsloses Scrollen im Amiga System
Programmer Guide.

Die horizontale Verschiebung beginnt bei der Scanlinie $4A und endet 200 Zeilen
später. Wir können berechnen, wo der Effekt beginnt und stoppt, indem wir
berücksichtigen, dass das Anzeigefenster bei $2C beginnt.

Der Effekt beginnt bei der Bildzeile (ab 0):
 start = $2C - $4A = $1E = 30

Und endet an der Bildzeile: 
 end = $1E + 200 = 230

Ich habe dem nächsten Bild einige Rasterlinien hinzugefügt, um zu
veranschaulichen, dass der obere und untere Teil des Bildes nicht durch den
horizontalen Verschiebungseffekt beeinflusst wird.

Abbildung 37-05: Wave grid

Aufgrund der Art und Weise, wie der Effekt codiert wurde, sieht es nur gut aus,
wenn das Bild dicke schwarze Ränder hat.

Überschrift: Sinuswelle aktualisieren

Das Wave Unterprogramm ist dafür verantwortlich, Sinuswerte in die Copperliste
einzutragen. Es wird einmal pro Frame aufgerufen und verwendet den
Zähler cont, um den Startindex in der Sinustabelle zu bestimmen.

wave:
  lea.l   cont(pc),a1       ; move cont address into a1
  move.w  (a1),d1           ; move cont value into d1
  addq.w  #2,(a1)           ; cont += 2
  andi.w  #$fe,d1           ; keep first word and allign it to an equal number
  lea.l   sin(pc),a1        ; move sin address into a1
  add.w   d1,a1             ; add the offset to the sine table
  lea.l   wavecop+6(pc),a2  ; move wavecop+6 into a2
  move.w  #199,d0           ; loop counter d0 = 199
waveloop:                   ; loop over 200 scanlines in copper
  move.w  (a1)+,(a2)        ; copy sine value to copper (set DFF102)
  addq.l  #8,a2             ; move to next scanline in copper
  dbra    d0,waveloop       ; if d0 > -1 goto waveloop
  rts                       ; return from subroutine

Der Startindex wird in d1 gespeichert und wird mit dem Wert $FE geAND'ed, um
ihn auf den Bereich von geraden Zahlen zwischen 0 und 254 zu beschränken.
Mithilfe des Startindex werden die Sinuswerte für jede der 200 Scanlinien
aus der Tabelle in die Copperliste kopiert.

Die Wellenunterroutine erfordert eine Sinustabelle, die Platz für 128 Einträge
möglicher Werte ab dem Startindex hat, gefolgt von 200 Einträgen für die
Scanlinien. Das ergibt eine Gesamtgröße von 328 Einträgen, was genau die Größe
der Sinustabelle ist.

Überschrift: Die Copperliste

Das Wellenprogramm verwendet den Copper, um den Bildschirm, den Abruf der
Anzeigedaten und andere Initialisierungssachen einzurichten. Darüber hinaus
fügt der Copper auch die horizontalen Verschiebungen hinzu.

Da sie teilweise hartcodiert sind und teilweise von den Subroutinen initcop
und wave generiert werden, ist es schwierig, die Coppperliste auszuwerten.
Warum also nicht erweitern, wie es zu einer gegebenen Zeit im Speicher aussehen
würde. Tauchen wir ein.

Wenn Sie eine Auffrischung der Copper-Befehle benötigen, dann werfen Sie einen
Blick auf den Beitrag: Copper Revisited
Es ist sehr lehrreich, die Copper-Anweisungen in Bezug auf die Scanlinien und
DMA-Buszyklen zu sehen, weil es hervor hebt, wie einfach es ist, den Strahl
mit dem Copper zu bewegen, und gibt auch einen genauen Hinweis darauf, was
passiert, wenn.

Ich habe die DMA-Zeitfensterzuweisungen mit Slots unterschiedlicher Breite
illustriert, nur damit genügend Platz zum Schreiben der Anweisungen vorhanden
ist. Die Breite hat nichts mit der Zeitlänge zu tun.

In der ersten Zeile der Copperliste wird der Copper angewiesen, darauf zu
warten, dass der Strahl die Scanlinie 20 erreicht, und bis zur horizontalen
Position zu warten.

copper:
  dc.w	$2001,$fffe  ; wait for vpos >= 20 and hpos >= 0
  ...

Beachten Sie die No-Op an der horizontalen Balkenposition 0 in der Abbildung
der DMA-Zeitfensterzuweisung unten.

Abbildung 37-06: DMA0

Beim English Amiga Board wiesen sie darauf hin, dass dieses No-op da ist, weil
der Copperstart einen zusätzlichen Zyklus vor dem ersten holen der Anweisung
benötigt. Der Copper wird dann angewiesen, zu warten, bis der Strahl die
Scanlinie 20 und den Steckplatz (Slot) 0 erreicht.

Die nächsten Copperanweisungen richten ein 320 x 256 Pixel Display ein.

  ...
  dc.w	$0104,$0000	 ; move $0000 to $dff104 BPLCON2 video
  dc.w	$0108,$0000  ; move $0000 to $dff108 BPL1MOD modulus odd planes
  dc.w	$010a,$0000  ; move $0000 to $dff10a BPL2MOD modulus even planes
  dc.w	$008e,$2c81  ; move $2c81 to $dff08e DIWSTRT upper left corner ($81,$2c)
  dc.w	$0090,$f4c1  ; move $f4c1 to $dff090 DIWSTOP (enable PAL trick)
  dc.w	$0090,$38c1  ; move $38c1 to $dff090 DIWSTOP (PAL trick) lower right corner ($1c1,$12c)
  dc.w	$0092,$0038  ; move $0038 to $dff092 DDFSTRT data fetch start at $38
  dc.w	$0094,$00d0  ; move $00d0 to $dff094 DDFSTOP data fetch stop at $d0
  dc.w	$2c01,$fffe  ; wait for vpos >= $2c and hpos >= 0
  ...

Aufgrund der vorherigen Wartezeit werden diese Anweisungen erst vom Copper
ausgeführt, wenn wir die Scanline Nr. 20 erreichen. Hier ist die
DMA-Zeitfensterzuweisung.

Abbildung 37-07: DMA20

Ich habe ein "W" auf Buszyklus 0 gesetzt, das zum Warten von Scanline 0 gehört.
Die Warteanweisung benötigt 3 Buszyklen - zwei für die Befehlswörter, die
Angabe der zu wartenden Strahlposition und einen zusätzlichen Zyklus, bevor die
Strahlposition erreicht wird.

Der dritte Wartezyklus sollte vor dem angeforderten Steckplatz (Slot) stehen.

Das Warten auf Slot 0 ist eine Ausnahme von der Regel. Da es keinen Steckplatz
vor Steckplatz 0 gibt, legt die Bus arbitration logik die Wartezeit auf Slot 0,
und packt den Abruf auf Steckplatz 2. In der Praxis hat das Warten auf Slot 0
oder Slot 2 einer bestimmten Linie den gleichen Effekt.

Die letzte Copperanweisung auf der Scanlinie ist eine Wartezeit, bis der Strahl
die Scanline $2C erreicht hat. Ohne das Wait würde der Copper nur seinen
Programmzähler erhöhen und die nächsten Anweisungen lesen.

Es ist wichtig, sich an die Wartezeiten zu erinnern, damit die Dinge an den
richtigen Strahlpositionen passieren, aber auch, weil während des Wartens der
copper aus dem Bus ist, und Zyklen für die CPU und den Blitter freigibt.

Wir aktivieren die beiden Bitebenen und legen deren Zeiger fest, mit den
folgenden Copperanweisungen unter der Scanline $2C.

  ...
  dc.w	$0100,$2200  ; BPLCON0 enable 2 bitplanes, enable color burst

bplcop:
  dc.w	$00e0,$0000  ; BPL1PTH (high bit 16-31)
  dc.w	$00e2,$0000  ; BPL1PTL (low  bit 0-15)
  dc.w	$00e4,$0000  ; BPL2PTH (high bit 16-31)
  dc.w	$00e6,$0000  ; BPL2PTL (low bit 0-15)

wavecop:
  dc.w  $4adf,$fffe  ; written by the initcop subroutine
  ...

Die Anweisungen aktiviert bitplane data fetch für diese und die folgenden
Scanlines. Die PTL-PTH-Chip-Speicherzeiger müssen nach dem vertikalen blank
neu geladen werden, und deshalb muss der Copper sie bei jedem Durchlauf der
Copperliste erneut einstellen. Der Grund für dieses Verhalten könnte sein,
dass diese Zeiger beim Zeichnen der Anzeige erhöht werden. Hier ist die
DMA-Zeitfensterzuweisung.

Abbildung 37-08: DMA2C

Wieder starten wir die Scanline mit dem letzten Zyklus aus dem vorherigen
Warten, gefolgt von den restlichen Copperanweisungen. Zum Abschluss weisen
wir den Copper an, darauf zu warten, dass der Balken die Scanlinie $4A
erreicht, und das unter hpos >= $DE zu erreichen.

Die letzte Wartezeit wird von der initcop subroutine auf den Copper
geschrieben. Für die nächsten 200 Scanlines wird eine Wartezeit gefolgt von
einem Aufruf von BPLCON1 eingefügt, der auf $0000. Dieser Wert wird später
kontinuierlich vom wave Unterprogramm, mit Daten aus der Sinustabelle
aktualisiert.

Hier sind einige dieser 200 Scanlines.

  ...
  dc.w  $0102,$0000  ; BPLCON1
  dc.w  $4BDF,$FFFE  ; wait for vpos >= $4B and hpos >= $DE
  dc.w  $0102,$0000  ; BPLCON1
  dc.w  $4CDF,$FFFE  ; wait for vpos >= $4C and hpos >= $DE
  dc.w  $0102,$0000  ; BPLCON1
  dc.w  $4DDF,$FFFE  ; wait for vpos >= $4D and hpos >= $DE
  dc.w  $0102,$0000  ; BPLCON1
  ...

Ich habe nur die Anfangswerte von BPLCON1 angezeigt, bevor sie vom
wave Unterprogramm aktualisiert werden. Hier ist die entsprechende
DMA-Zeitfensterzuweisung.

Abbildung 37-09: DMA4A

Der Wert für BPLCON1 wird am Ende der Scanlinie $4A festgelegt, was bedeutet,
dass die nächste Scanlinie $4B horizontal verschoben wird. Dieses Muster 
wiederholt sich für die nächsten 200 Scanlinien, um den Bildlaufeffekt
zu erstellen.

Die nächste Wartezeit wird am Anfang der Scanline $4B angezeigt, da an der
vorherigen Scanlinie keine Steckplätze mehr verfügbar waren.

Kann der Copper ungerade Slots verwenden? (nur PAL)

Der Copper kann nur gerade Slots verwenden, aber PAL Timing macht Slot $E0 zu
einem speziellen Slot, der nicht vom Copper verwendet werden kann. Wenn Sie
den Copper so einrichten, dass er verwendet wird, wird er ein No-Op eingeben
und weiter bei $E1 fortfahren, was ungerade ist. Der Zyklus bei $E0
wird verschwendet.

Der Steckplatz $E2 kann vom Cooper nicht verwendet werden, da er zum
Slot "-1" wird, was der Beginn der nächsten Scanlinie ist.

Wenn wir die Copperliste des Wellenprogramms ändern, um $E0 zu vermeiden,
würden wir 200 DMA-Zyklen pro Frame für andere Zwecke gewinnen.

Mehr dazu im English Amiga Board.

Der horizontale Scrolleffekt endet mit den folgenden Copperanweisungen.

  ...
  dc.w  $11DF,$FFFE  ; wait for vpos >= 111 and hpos >= $DE
  dc.w  $0102,$0000  ; BPLCON1
  dc.w	$2c01,$fffe  ; wait for vpos >= 12c and hpos >= 0
  ...

Der Effekt endet bei der Scanline $112, das als $12 angegeben wird, da der
"vpos"-Zähler über die Scanlinie "$FF" gelaufen ist.

Abbildung 37-10: DMA111

Auf der Scanline $112 wird der Copper angewiesen, auf die Scanline $12C
zu warten, die aufgrund des Zählerüberlaufs als $2C geschrieben wird.

Bei der Scanline $12C werden die bitplanes deaktiviert.

  ...
  dc.w	$0100,$0200  ; BPLCON0 disable bitplane - older PAL chips.
  dc.w	$ffff,$fffe  ; wait for vpos >= $FF and hpos >= $FE
                     ; wait indefinitely - until next vertical blanking

Die Anweisung stoppt bitplane Daten fetch, wodurch Buszyklen für die CPU und
den Blitter frei werden. Die Warteanweisung ist etwas Besonderes.

Abbildung 37-11: DMA12C

Der erste Zyklus auf der Scanline $2C ist der letzte Wartezyklus aus der
vorherigen Wartezeit. Nach dem Deaktivieren der Bitplanes endet die Scanlinie,
beim Wait bei Steckplatz $FE an Strahlposition $FF. Der Strahl wird diesen
Steckplatz nie erreichen, da der letzte mögliche Steckplatz $E2 ist und der
Copper gezwungen sein wird, auf unbestimmte Zeit zu warten.

Die Copperliste wird neu gestartet, wenn der Copper-Programmzähler auf seinen
Wert in COP1LC zurückgesetzt wird, der bei jedem vertikal blank auftritt,
unabhängig davon, ob der Copper mit seiner vorherigen Liste fertig war oder
nicht.

Überschrift: Zusätzliche Arbeit

Das Wellenprogramm kann nur zwei Bitebenen verarbeiten, wodurch die Palette
auf nur vier Farben reduziert wird. Es würde schön mit mehr Farben. so gehen
Sie vor und ändern Sie das Progam, um fünf Bitplanes zu verwenden.

Die Bildschirmgrafikdatei muss in ein Fünf-Bit-Ebenenbild geändert werden,
in dem die Colormap vor den Bitebenen gespeichert wird. Lesen Sie mehr dazu
hier: Make You Own Graphic Assets.
Hier ist ein Beispiel dafür, wie cool dieser Effekt mit der richtigen Grafik
aussehen kann!

Abbildug 37-12: KingTut

Das Bild ist von König Tutanchamun und gemalt von Avril Harrison. Es ist ein
ikonisches Amiga Kunstwerk, bekannt aus Deluxe Paint, wo es in Werbespots und
als Box Cover Art verwendet wurde.

Überschrift: Letzte Gedanken

Wir haben in diesem Beitrag viel Boden zurückgelegt. Am wichtigsten ist, dass
wir an der Oberfläche dessen gekratzt haben, was Bus-Schiedsverfahren ist und
wie es Bus-Streitigkeiten vermeidet, indem wir die "zwei Computer" im Inneren
des Amiga anweisen, beim Zugriff auf den gemeinsamen Chip zusammenzuarbeiten.

Es gibt einen ausgezeichneten DMA-Debugger in WinUAE / FS-UAE, den ich bei der
Visualisierung der DMA-Zeitfensterzuweisungen verwendet habe. Wenn es die Zeit
zulässt, werde ich darüber in einem zukünftigen Beitrag schreiben.

Viel Spass!

weblinks:
https://retrocomputing.stackexchange.com/questions/2146/reason-for-the-amiga-clock-speed
http://amiga-dev.wikidot.com/hardware:bplcon1
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node008B.html
https://archive.org/details/Amiga_System_Programmers_Guide_1988_Abacus/page/n115/mode/2up
https://scalibq.wordpress.com/2013/03/15/just-keeping-it-real-part-9/
http://eab.abime.net/showthread.php?p=1431584#post1431584
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0049.html
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node004B.html
http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0060.html
http://amiga-dev.wikidot.com/hardware:cop1lch
http://amiga.lychesis.net/artist/AvrilHarrison.html
