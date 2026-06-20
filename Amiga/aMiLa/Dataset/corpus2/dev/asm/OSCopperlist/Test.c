
#include <intuition/screens.h>
#include <graphics/copper.h>
#include <hardware/intbits.h>
#include <hardware/dmabits.h>
#include <graphics/gfxmacros.h>
#include <hardware/custom.h>
#include <exec/interrupts.h>
#include <exec/memory.h>
#include <graphics/gfxbase.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

__far extern struct Custom custom;

extern void initCopperlist(); /* Inicjuje Copperlistë */
extern void myCopperInt();    /* Obsîuga przerwania Coppera */

extern struct GfxBase *GfxBase;

int main()
{
    struct Screen *s;
    struct UCopList *ucl;
    struct Interrupt irq;
    struct myData
        {
        struct Task *thisTask;
        ULONG sigmask;
        } mydata;
    ULONG signal;
    struct View *oldview;

    /* Inicjujemy Copperlistë (ustawiamy wskaúniki do bitplanów) */
    initCopperlist();


    /* Otwieramy ekran */
    if (s = OpenScreenTags(NULL,
        SA_Left,        0,
        SA_Top,         0,
        SA_Width,       320,
        SA_Height,      256,
        SA_Depth,       1,
        SA_Quiet,       TRUE,
        SA_Exclusive,   TRUE,
        TAG_DONE))
        {

        /* Szukamy zadania */
        mydata.thisTask = FindTask(NULL);

        /* Rezerwujemy sygnaî */
        if ((signal = AllocSignal(-1)) != -1)
            {
            mydata.sigmask = 1L << signal;

            /* Inicjujemy strukturë przerwania */
            irq.is_Node.ln_Pri = 0;
            irq.is_Code = myCopperInt;
            irq.is_Data = &mydata;

            /* Dodajemy obsîugë przerwania Coppera */
            AddIntServer(INTB_COPER, &irq);

            /* Tworzymy Copperlistë uûytkownika */
            if (ucl = AllocMem(sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CLEAR))
                {
                CINIT(ucl, 2);
                CWAIT(ucl, 0, 0);

                /* Wywoîujemy przerwanie w linii 0, gdy nasz ekran (Copperlista) staje sië aktywny */
                CMOVE(ucl, custom.intreq, INTF_SETCLR|INTF_COPER);
                CEND(ucl);

                /* Ustawiamy Copperlistë uûytkownika */
                Forbid();
                s->ViewPort.UCopIns = ucl;
                Permit();
                RethinkDisplay();

                oldview = GfxBase->ActiView;
                WORD i;
                for (i = 0; i < 5; i++)
                    {

                    /* Czekamy na sygnaî */
                    SetSignal(0L, mydata.sigmask);
                    Wait(mydata.sigmask);

                    /* Zaîadowujemy copperlistë */
                    if (i < 4)
                        loadCopperlist();
                    }

                /* Odtwarzamy oryginalna copperlistë */
                WaitTOF();
                WaitTOF();
                LoadView(oldview);
                custom.cop1lc = (ULONG)GfxBase->copinit;
                }

            /* Usuwamy obsîugë przerwania */
            RemIntServer(INTB_COPER, &irq);

            /* Zwalniamy sygnaî */
            FreeSignal(signal);
            }

        /* Zamykamy ekran */
        CloseScreen(s);
        }
    return(0);
}
