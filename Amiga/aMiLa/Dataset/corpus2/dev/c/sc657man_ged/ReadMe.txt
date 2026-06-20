    AmigaGuide AutoDoc ARexx module for GoldEd v3.x+

    Author:     Manolis S. Pappas
                Thermopilon 24
                14231 Nea Ionia, Athens
                GREECE

    E-Mail:     mpappas@acropolis.net
    Telephone:  ++ 2757918


    Preface
    -------

    It all started when I got in my hands the excellent freeware version of GoldEd v3.1.4
from the GoldEd home page. Since then I used the nice, but a little slow, SAS/C SE editor
in order to write my programs. In order to help me with the task of writting Amiga
applications, I wrote a simple ARexx script for SE where everytime I pressed an assigned
key to that script, I got context sensitive help for that particular function. The
program was clever enough to distinguish when the requested function was part of the
SAS/C library and when it was an Amiga ROM function.
    But when I changed to GoldEd, the script could not be used anymore. So I rewrote it!


    Usage & Installation
    --------------------

    Provided you have a full set of Amiga AutoDocs in AmigaGuide format together with a
contents file for the Amiga functions and a xref file, simply install the script "man.ged"
to your GoldEd:ARexx directory. Then assign the script to a key or a menu (or whatever
you like) so that GoldEd can execute it (look in your GoldEd manual, on how to acomplish
this). Remember to check the specified paths in the "man.ged" file: SASFUNC is the path
for the C function autodocs and AMIGAFUNC the path for Amiga functions autodocs.
    If you want you can install the file "GoldEd.prefs" which is the GoldEd 3.x configuration
file that I use. The AutoDoc search facility has been assigned to the menu
"Macros/Macros C/AutoDocs Search" with the key combination "RIGHTAMIGA+\".

    Distribution
    ------------

    This program is FREEWARE. You can use it and distribute it freely (or modify it to
suit your needs).

    Remember to download the file "sc656man.lha" (from the same directory you got this file)
in order to ind out how you can convert your autodocs to AmigaGuide format.

    Send reports, comments, flames to the address above.

17/02/97    --  Manolis S. Pappas


