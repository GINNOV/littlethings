

                              Chunky 2 Planar
                         ( for 020-030 & 040-060 )

                                    by

                                Seb/SCOOPEX


You will find two chunky to planar in 256 colors in this package.
The first one is better for 020 & 030 and the second one is for 040 & 060.

Size of each plan in copperlist must be 320*256 and modulo must be set to 0
if you want to use this file without modifying anything.

* NOTE : the 040 & 060 one needs a size that must be a multiple of 128 pixels.


                            To initialize C2P:

For the first one you must use a variable called "Size" (it's a word) with
the size of the chunky screen divided by 32 and you subtract 2 after that.

 Exemple for a 320*220 screen :
	move.w	#320*220/32-2,Size

For the second one put the size in d0 (by long word) and
call Init.C2P.040 060.1.1.256c

 Exemple for a 320*220 screen :

	move.l	#320*220,d0
	bsr	Init.C2P.040 060.1.1.256c

To use the C2P, during each VBL, call

	bsr	C2P.020 030.1.1.256c
or
	bsr	C2P.040 060.1.1.256c


On 030, it takes around 1.23 VBL to convert a 320*256 screen in 256c and on
060, it takes less than 0.8 VBL to convert the same screen.

               ********************************************
               *                                          *
               *      Watch the included intro called     *
               *          "Scoopex-Effusion.exe"          *
               *   to see what is the speed of this C2P   *
               *                                          *
               ********************************************

Have nice coding time !!!

To contact me:

	Sebastien Spagnolo
	8 residence les peupliers
	42300 Roanne
	France

	email : spagnolo@int-evry.fr


 <<< If you want to put it in a game or demo just greet and contact me >>>



