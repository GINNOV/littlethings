#include "modPlay.h"
#include <exec/types.h>
#include <dos/dos.h>

void wait_for_ctrl_c(){
    BYTE SigBit;
    ULONG SigMask;

    if((SigBit=AllocSignal(-1))==-1){
        puts("couldn't allocate signal\n");
        exit(0);
    };

    puts("Press CTRL-C to quit\n");
    SigMask=Wait(SIGBREAKF_CTRL_C | 1L<<SigBit);
    FreeSignal(SigBit);
}

int main(){
    play_mod("enigma.mod");

    wait_for_ctrl_c();

    stop_mod();
    return 0;
}