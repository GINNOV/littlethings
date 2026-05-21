* diskmaster2\_2.6.0_m68k.zip - OS3.x+OS4 (2005-12-11)
* diskmaster2-de-doc_1.98.0.zip (2001-10-30) Deutsche Version des DM2.guide von Nils Goers:
* diskmaster2\_2.5.30a_m68k.zip V 2.5.30a (2005-07-16) The last version that works on OS2:
* diskmaster2\_2.2.b2_m68k.zip V 2.2b2 (1997-03-20) The last version that works on OS1.3:
* diskmaster2\_1.4.0_m68k.zip
* diskmaster2\_2.0.0_m68k.zip 
* diskmaster2\_2.0.4_m68k.zip 
* diskmaster2\_2.1.0a_m68k.zip
* diskmaster2\_2.1.0a_m68k.zip 

Unzip these with:

AddAutoCmd ,#?.zip,StdIO "CON:0/11/700/280/Extract";Extern unzip -N %n -d ram:;StdIO CLOSE

And you will get all the version-numbers as file-comments!

