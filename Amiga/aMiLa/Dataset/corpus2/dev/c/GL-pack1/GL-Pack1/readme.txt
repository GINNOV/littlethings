
English and french doc about the included examples.
Documentation anglaise et française pour les examples fournis.

Date : 08/06/03

-- English


* Hi all !

TinyGL is a small software renderer which used a subset of the OpenGL API.

You want to play with TinyGL but as a beginner you miss easy examples ?
Here they are !

More advanced examples will be given in another pack.

Some examples (lessonx.c) have a function (arrow_keys) put into comments.
The actual public version of TinyGL doesn't supports glutSpecialFunc().

Each program has a small comment at the top.


* How to compile these examples ?

You need a working C environment and the TinyGL static library available
on Aminet. With GCC, just compile with 'make'.
If you use SAS/C it will work but you have to change
the given makefiles (not too hard :).

Note : As the logo example contains several files, it has its own
directory and makefile.

If you don't want compile examples but try them for testing, please email
me at : mathias.p@wanadoo.fr


* Which examples ?

Try these programs which are given in a progressive way here :

o basicframework
Contains the basic structure of a TinyGL program, but doesn't show nothing.

o benchmark
Introduces the time measurement with a FPS count. It may be long before
ending, depending on the amount of loops.

o lesson3
The first given example from the famous NeHe tutorial (see gamedev.net).
It builds a blue square and a coloured triangle. This shapes are static
for the moment.

o lesson4
Let's move ! The same shapes are now moving ... or more exactly rotating.
See the display function to understand how the miracle runs ;)

o logo
A really nice example for the end ! Press spacebar to start again the logo
building.


* Contact

If you need information or other, please contact me at :
mathias.p@wanadoo.fr


-- Français

* Bonjour à tous !

TinyGL est un moteur 3D léger qui n'utilise pas le hardware. C'est une
sous-implémentation de l'API standard OpenGL.

Vous voulez jouez avec TinyGL mais vous débutez et vous ne manquez
d'exemples simples pour progresser ? Ils sont là !

Des exemples plus avancés sont en préparation pour un deuxième pack.

Certains exemples (lessonx.c) ont une fonction (arrow_kays) dont le
contenu a été mis en commentaire : la version publique actuelle de TinyGL
ne supporte pas glutSpecialFunc().

Vous trouverez une petite note explicative (en anglais) au début de chaque
programme.


* Comment compiler ces exemples ?

Vous avez besoin d'un environnement de compilation C et de la bibliothèque
statique TinyGL disponible sur Aminet. Avec GCC, compilez simplement avec
'make'.
Si vous utilisez SAS/C ça fonctionnera mais vous devrez modifier
les fichiers makefile ... ce qui n'est pas très difficile :)

Note : Comme l'exemple logo contient plusiers fichiers, il possède son
propre répertoire et son propre makefile.

Si vous ne souhaitez pas compiler ces exemples mais que vous souhaitez
les essayer pour tester, contactez-moi par email : mathias.p@wanadoo.fr


* Quels exemples ?

Essayez ces exemples qui sont proposés ici dans un ordre de difficulté
progressive :

o basicframework
Structure de base d'un programme TinyGL, mais rien n'apparaîtra (fenêtre
noire).

o benchmark
Introduction à la mesure du temps, avec un compteur de FPS. Ca peut être
long avant de rendre la main, cela dépend du nombre total de boucles (et
de la machine).

o lesson3
Le premier exemple qui provient du célèbre tutoriel OpenGL de NeHe (voir
gamedev.net). Il construit un carré bleu et un triangle coloré. Ces
formes géométriques sont statiques pour le moment.

o lesson4
En mouvement maintenant ! Les mêmes formes bougent, désormais ... ou
plutôt, se mettent en rotation. Regardez la fonction display pour
comprendre comment ce miracle arrive :)

o logo
A exemple vraiment sympa et joli pour la fin ! Appuyez sur la barre
espace pour recommencer l'animation du logo.

