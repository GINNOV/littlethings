FD2Pragma zu StormC

Dieser Pragmagenerator erzeugt amicall und tagcall pragmas, wie
sie zur Nutzung mit StormC benötigt werden. Um eine 100%ige
Kontrolle über das Resultat zu haben, kann ein neues Schlüssel-
wort genutzt werden, das eigens für die einfachere Erzeugung
von tagcalls eingeführt wurde.

Viele Pragmageneratoren erkennen lediglich anhand des Funktions-
namens (angehängtes A) und des letzten Parameters, daß es sich
um eine Funkion mit Taglist handelt und generieren automatisch
ein #pragma tagcall nach dem amigcall oder libcall pragma.

Sowohl unter StormC (bei der Erzeugung eigener Shared-Libraries)
als auch mit dem Programm fd2pragma könnne Sie ihren Funktion und
Tag-Parametern nach dem Schlüsselwort ##shadow beliebige Namen
geben.

Beispiel:

##base _WizardBase
##bias 30
##public
*------------------------------------------------
*---       functions in V 37 or higher        ---
*---   © 1996 HAAGE & PARTNER Computer GmbH   ---
*------------------------------------------------
*
* Public entries
*
WZ_OpenSurfaceA(name,memaddr,tagptr)(a0/a1/a2)
##shadow
WZ_OpenSurface(name, memaddr,tags)(a0/a1/a2)
WZ_CloseSurface(surface)(a0)
WZ_AllocWindowHandleA(screen,user_sizeof,surface,tagptr)(d0/d1/a0/a1)
##shadow
WZ_AllocWindowHandle(screen,user_sizeof,surface,tags)(d0/d1/a0/a1)
...

##end
