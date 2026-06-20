/* Name: FileWindow.h


  FFFFF III L     EEEEE     W     W III N   N DDD    OOO  W     W
  F      I  L     E         W     W  I  NN  N D  D  O   O W     W
  FFFF   I  L     EEE       W  W  W  I  N N N D   D O   O W  W  W
  F      I  L     E          W W W   I  N  NN D  D  O   O  W W W
  F     III LLLLL EEEEE       W W   III N   N DDD    OOO    W W


  
  FILE WINDOW   VERSION 1.10   89-08-31

  Yet another program dedicated to Sioe-Lin Kwik.
  

  FILE WINDOW was created by Anders Bjerin, and is distributed as
  public domain with NO RIGHTS RESERVED. That means that you can do
  what ever you want to do with the program.
  
  You may use FILE WINDOW in your own programs, commercial or not, and 
  do not even need to mention that you have used it. You may alter the
  source code to fit your needs, and you may spread it to anyone.

  Anders Bjerin






         III M   M PPPP   OOO  RRRR  TTTTT   AAA  N   N TTTTT
          I  MM MM P   P O   O R   R   T    A   A NN  N   T
          I  M M M PPPP  O   O RRRR    T    AAAAA N N N   T
          I  M   M P     O   O R  R    T    A   A N  NN   T
         III M   M P      OOO  R   R   T    A   A N   N   T

  IF YOU CHANGE THESE VALUES,  P L E A S E  CHANGE THE INSTRUCTIONS TOO:
  
*/

/* What file_window() will return: */
#define LOAD    500
#define SAVE    600
#define DELETE  700
#define CANCEL  800
#define QUIT    900
#define PANIC  1000

/* The minimum size of the strings: */
#define DRAWER_LENGTH 100 /*  100 characters including NULL. */
#define FILE_LENGTH    30 /*   30           -"-              */
#define TOTAL_LENGTH  130 /*  130           -"-              */

/* THE END */

