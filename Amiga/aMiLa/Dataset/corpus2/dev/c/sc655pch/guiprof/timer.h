/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1992 Doug Walker                                 *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          405 B3 Gooseneck Drive                               *
* |  . |//           Cary, NC 27513                                       *
* ------                                                                  *
* USENET: walker@unx.sas.com        PORTAL: djwalker      BIX: djwalker   *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */



/* Functions defined in timer.c */
long OpenTimer(void);
void _STDCloseTimer(void);
#define CloseTimer() _STDCloseTimer()
void PostTimerReq(long time);
void GetTimerPkt(long time, int wait);
