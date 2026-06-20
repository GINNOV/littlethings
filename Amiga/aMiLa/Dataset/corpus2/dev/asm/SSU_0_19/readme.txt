Short:        Space Ship Assembly Example
Uploader:     alivemoon@grandpace.com (Dezsõ Bodor)
Author:       alivemoon@grandpace.com (Dezsõ Bodor)
Type:         dev/asm
Version:      0.19_4
Architecture: m68k-amigaos >= 2.0.4
Distribution: Aminet
Kurz:         Source and Build: Space Ship in Wormhole


Hello!
So I do not know English well enough, so no struggling!
Google Translate is your friend :)



;================-===--==---=---- ---  --   -   
;	SSU0.19 - 2014.jan.04.
;=============-===--==---=---- ---  --   -   

Végre akadt egy kis idõm és folytattam a munkát ezen a projekten is.


- GP_COLED:		egy kisérlet az ütközés vizsgálatra, még nem tökéletes
- GP_COLOR_IP_SET:	szin interpoláció
- GP_MAX_D:		y2-y1 vagy x2-x1 kozul a nagyobb az eredmény	
- GP_QD:		p2*p2+p1*p1 a távolság négyzete
- GP_LOD:		alulmintavételezi a távolabbi körvonalakat
- GP_SQRT_D0...D7:	négyzet gyök

több komment a forrásban.



;================-===--==---=---- ---  --   -   
;	SSU0.18 - 2013.apr.02
;=============-===--==---=---- ---  --   -   

Hozzám hasonló assembly tanulóknak jó lecke, ha össze hasonlíthatja, egy régebbi forrással
az újabbat, így követhetõ a fejlõdés, hol mi fejlõdõtt, vagy milyen hibákat javítottam!

- new shape draw
- more colors in wormholle
- filled shape
- debug switch in source
- bug fix



;================-===--==---=---- ---  --   -   
;	SSU0.15 - régen
;=============-===--==---=---- ---  --   -   
 
Ez egy játék gyök, alap!
De hasznos megoldásokat találsz!
Úgyan ilyet ne csinálj, de használd egészséggel, a sajátodhoz!
Esetleg kedved van csatlakozz, ennek a befejezéséhez!

alivemoon@grandpace.com

Írányítás:

JOYSTIC
elölre	:flsõ fuvoka (lefele bólint)
hátra	:alsó fuvoka (felfele bólint)
jobb - bal 	:döntés

tüz	:kilép (tovább macerálni a forrást)



Tisztelettel!

Bodor Dezsõ
Magyarország
