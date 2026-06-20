/* ********************************************************************** *\
** **                                                                  ** **
** ** FILE: copdis.h                                                   ** **
** **                                                                  ** **
** ** (C) 1997 by Thomas Nokielski. All rights reserved.               ** **
** **                                                                  ** **
** ** A little copper disassembler.                                    ** **
** **                                                                  ** **
** ** NOTE:                                                            ** **
** **     If you define the macro COP_DIS_NO_CTRL, no Ctrl-C checking  ** **
** **     will be done.                                                ** **
** **                                                                  ** **
\* ********************************************************************** */

#ifndef TJP_COP_DIS_H
#define TJP_COP_DIS_H

#ifdef COP_DIS_NO_CTRL_C

  #ifndef EXEC_TYPES_H
    #include <exec/types.h>
  #endif

#else

  #ifndef EXEC_EXEC_H
    #include <exec/exec.h>
  #endif

  #ifndef DOS_DOS_H
    #include <dos/dos.h>
  #endif

  #ifndef CLIB_EXEC_PROTOS_H
    #include <clib/exec_protos.h>
  #endif

#endif

#ifndef _STDIO_H_
  #include <stdio.h>
#endif

struct copper_reg
{
  STRPTR  name;
  UWORD   reg;
};

struct copper_reg copreg[] =
{
  (STRPTR)"bltcon0",0x040,
  (STRPTR)"bltcon1",0x042,
  (STRPTR)"bltafwm",0x044,
  (STRPTR)"bltalwm",0x046,
  (STRPTR)"bltcpth",0x048,
  (STRPTR)"bltcptl",0x04a,
  (STRPTR)"bltbpth",0x04c,
  (STRPTR)"bltbptl",0x04e,
  (STRPTR)"bltapth",0x050,
  (STRPTR)"bltaptl",0x052,
  (STRPTR)"bltdpth",0x054,
  (STRPTR)"bltdptl",0x056,
  (STRPTR)"bltsize",0x058,
  (STRPTR)"bltcon0",0x05a,
  (STRPTR)"bltsizv",0x05c,
  (STRPTR)"blzsizh",0x05e,
  (STRPTR)"bltcmod",0x060,
  (STRPTR)"bltbmod",0x062,
  (STRPTR)"bltamod",0x064,
  (STRPTR)"bltdmod",0x066,
  (STRPTR)"bltcdat",0x070,
  (STRPTR)"bltbdat",0x072,
  (STRPTR)"bltadat",0x074,
  (STRPTR)"sprhdat",0x078,
  (STRPTR)"bplhdat",0x07a,
  (STRPTR)"lisaid", 0x07c,
  (STRPTR)"dsksync",0x07e,
  (STRPTR)"cop1lch",0x080,
  (STRPTR)"cop1lcl",0x082,
  (STRPTR)"cop2lch",0x084,
  (STRPTR)"cop2lcl",0x086,
  (STRPTR)"copjmp1",0x088,
  (STRPTR)"copjmp2",0x08a,
  (STRPTR)"copins", 0x08c,
  (STRPTR)"diwstrt",0x08e,
  (STRPTR)"diwstop",0x090,
  (STRPTR)"ddfstrt",0x092,
  (STRPTR)"ddfstop",0x094,
  (STRPTR)"dmacon", 0x096,
  (STRPTR)"clxcon", 0x098,
  (STRPTR)"intena", 0x09a,
  (STRPTR)"intreq", 0x09c,
  (STRPTR)"adkcon", 0x09e,
  (STRPTR)"aud0lch",0x0d0,
  (STRPTR)"aud0lcl",0x0d2,
  (STRPTR)"aud0len",0x0d4,
  (STRPTR)"aud0per",0x0d6,
  (STRPTR)"aud0vol",0x0d8,
  (STRPTR)"aud0dat",0x0da,
  (STRPTR)"aud1lch",0x0b0,
  (STRPTR)"aud1lcl",0x0b2,
  (STRPTR)"aud1len",0x0b4,
  (STRPTR)"aud1per",0x0b6,
  (STRPTR)"aud1vol",0x0b8,
  (STRPTR)"aud1dat",0x0ba,
  (STRPTR)"aud2lch",0x0c0,
  (STRPTR)"aud2lcl",0x0c2,
  (STRPTR)"aud2len",0x0c4,
  (STRPTR)"aud2per",0x0c6,
  (STRPTR)"aud2vol",0x0c8,
  (STRPTR)"aud2dat",0x0ca,
  (STRPTR)"aud3lch",0x0d0,
  (STRPTR)"aud3lcl",0x0d2,
  (STRPTR)"aud3len",0x0d4,
  (STRPTR)"aud3per",0x0d6,
  (STRPTR)"aud3vol",0x0d8,
  (STRPTR)"aud3dat",0x0da,
  (STRPTR)"bpl1pth",0x0e0,
  (STRPTR)"bpl1ptl",0x0e2,
  (STRPTR)"bpl2pth",0x0e4,
  (STRPTR)"bpl2ptl",0x0e6,
  (STRPTR)"bpl3pth",0x0e8,
  (STRPTR)"bpl3ptl",0x0ea,
  (STRPTR)"bpl4pth",0x0ec,
  (STRPTR)"bpl4ptl",0x0ee,
  (STRPTR)"bpl5pth",0x0f0,
  (STRPTR)"bpl5ptl",0x0f2,
  (STRPTR)"bpl6pth",0x0f4,
  (STRPTR)"bpl6ptl",0x0f6,
  (STRPTR)"bpl7pth",0x0f8,
  (STRPTR)"bpl7ptl",0x0fa,
  (STRPTR)"bpl8pth",0x0fc,
  (STRPTR)"bpl8ptl",0x0fe,
  (STRPTR)"bplcon0",0x100,
  (STRPTR)"bplcon1",0x102,
  (STRPTR)"bplcon2",0x104,
  (STRPTR)"bplcon3",0x106,
  (STRPTR)"bpl1mod",0x108,
  (STRPTR)"bpl2mod",0x10a,
  (STRPTR)"bplcon4",0x10c,
  (STRPTR)"clxcon2",0x10e,
  (STRPTR)"bpl1dat",0x110,
  (STRPTR)"bpl2dat",0x112,
  (STRPTR)"bpl3dat",0x114,
  (STRPTR)"bpl4dat",0x116,
  (STRPTR)"bpl5dat",0x118,
  (STRPTR)"bpl6dat",0x11a,
  (STRPTR)"bpl7dat",0x11c,
  (STRPTR)"bpl8dat",0x11e,
  (STRPTR)"spr0pth",0x120,
  (STRPTR)"spr0ptl",0x122,
  (STRPTR)"spr1pth",0x124,
  (STRPTR)"spr1ptl",0x126,
  (STRPTR)"spr2pth",0x128,
  (STRPTR)"spr2ptl",0x12a,
  (STRPTR)"spr3pth",0x12c,
  (STRPTR)"spr3ptl",0x12e,
  (STRPTR)"spr4pth",0x130,
  (STRPTR)"spr4ptl",0x132,
  (STRPTR)"spr5pth",0x134,
  (STRPTR)"spr5ptl",0x136,
  (STRPTR)"spr6pth",0x138,
  (STRPTR)"spr6ptl",0x13a,
  (STRPTR)"spr7pth",0x13c,
  (STRPTR)"spr7ptl",0x13e,
  (STRPTR)"spr0pos",0x140,
  (STRPTR)"spr0ctl",0x142,
  (STRPTR)"spr0dat",0x144,
  (STRPTR)"spr0dat",0x146,
  (STRPTR)"spr1pos",0x148,
  (STRPTR)"spr1ctl",0x14a,
  (STRPTR)"spr1dat",0x14c,
  (STRPTR)"spr1dat",0x14e,
  (STRPTR)"spr2pos",0x150,
  (STRPTR)"spr2ctl",0x152,
  (STRPTR)"spr2dat",0x154,
  (STRPTR)"spr2dat",0x156,
  (STRPTR)"spr3pos",0x158,
  (STRPTR)"spr3ctl",0x15a,
  (STRPTR)"spr3dat",0x15c,
  (STRPTR)"spr3dat",0x15e,
  (STRPTR)"spr4pos",0x160,
  (STRPTR)"spr4ctl",0x162,
  (STRPTR)"spr4dat",0x164,
  (STRPTR)"spr4dat",0x166,
  (STRPTR)"spr5pos",0x168,
  (STRPTR)"spr5ctl",0x16a,
  (STRPTR)"spr5dat",0x16c,
  (STRPTR)"spr5dat",0x16e,
  (STRPTR)"spr6pos",0x170,
  (STRPTR)"spr6ctl",0x172,
  (STRPTR)"spr6dat",0x174,
  (STRPTR)"spr6dat",0x176,
  (STRPTR)"spr7pos",0x178,
  (STRPTR)"spr7ctl",0x17a,
  (STRPTR)"spr7dat",0x17c,
  (STRPTR)"spr7dat",0x17e,
  (STRPTR)"color00",0x180,
  (STRPTR)"color01",0x182,
  (STRPTR)"color02",0x184,
  (STRPTR)"color03",0x186,
  (STRPTR)"color04",0x188,
  (STRPTR)"color05",0x18a,
  (STRPTR)"color06",0x18c,
  (STRPTR)"color07",0x18e,
  (STRPTR)"color08",0x190,
  (STRPTR)"color09",0x192,
  (STRPTR)"color10",0x194,
  (STRPTR)"color11",0x196,
  (STRPTR)"color12",0x198,
  (STRPTR)"color13",0x19a,
  (STRPTR)"color14",0x19c,
  (STRPTR)"color15",0x19e,
  (STRPTR)"color16",0x1a0,
  (STRPTR)"color17",0x1a2,
  (STRPTR)"color18",0x1a4,
  (STRPTR)"color19",0x1a6,
  (STRPTR)"color20",0x1a8,
  (STRPTR)"color21",0x1aa,
  (STRPTR)"color22",0x1ac,
  (STRPTR)"color23",0x1ae,
  (STRPTR)"color24",0x1b0,
  (STRPTR)"color25",0x1b2,
  (STRPTR)"color26",0x1b4,
  (STRPTR)"color27",0x1b6,
  (STRPTR)"color28",0x1b8,
  (STRPTR)"color29",0x1ba,
  (STRPTR)"color30",0x1bc,
  (STRPTR)"color31",0x1be,
  (STRPTR)"htotal", 0x1c0,
  (STRPTR)"hsstop", 0x1c2,
  (STRPTR)"hbstrt", 0x1c4,
  (STRPTR)"hbstop", 0x1c6,
  (STRPTR)"vtotal", 0x1c8,
  (STRPTR)"vsstop", 0x1ca,
  (STRPTR)"vbstrt", 0x1cc,
  (STRPTR)"vbstop", 0x1ce,
  (STRPTR)"sprhstr",0x1d0,
  (STRPTR)"sprhsto",0x1d2,
  (STRPTR)"bplhstr",0x1d4,
  (STRPTR)"bplhsto",0x1d6,
  (STRPTR)"hhposw", 0x1d8,
  (STRPTR)"hhposr", 0x1da,
  (STRPTR)"beamcon",0x1dc,
  (STRPTR)"hsstrt", 0x1de,
  (STRPTR)"vsstrt", 0x1e0,
  (STRPTR)"hcenter",0x1e2,
  (STRPTR)"diwhigh",0x1e4,
  (STRPTR)"bplhmod",0x1e6,
  (STRPTR)"sprhpth",0x1e8,
  (STRPTR)"sprhptl",0x1ea,
  (STRPTR)"bplhpth",0x1ec,
  (STRPTR)"bplhptl",0x1ee,
  (STRPTR)"fmode",  0x1fc
};

ULONG num_cop_ins = sizeof(copreg)/sizeof(struct copper_reg);

BOOL cop_dis(UWORD *cprlst)
{
  UWORD t = 0;  // index of current copper instruction
  UWORD t0, t1; // current copper instruction

  ULONG idx;    // index in copper instructions structure

  BOOL done = FALSE;

  while (!done)
    {

#ifndef COP_DIS_NO_CTRL_C
      // CtrlC-Check
      if ( SetSignal(0,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C )
        {
          printf(" *** BREAK\n");
          return(FALSE);
        }
#endif

      // print offset
      printf("$%04x : ",t);

      // get one single copper instruction
      t0 = cprlst[t++];
      t1 = cprlst[t++];

      // print type of instruction
      if ( (t0 & 1) == 0 ) printf("(move)");
      else
        {
          if ( (t1 & 1) == 0 )
            {
              printf("(wait)");
              if (t0 == 0xffff) done = TRUE;
            }
          else
            printf("(skip)");
        }

      // print address and data
      printf(" $%04x,$%04x", t0, t1);

      // if move instruction, print register name
      if ( (t0 & 1) == 0 )
        {
          for (idx = 0; idx<num_cop_ins; idx++)
            {
              if (copreg[idx].reg == t0)
                {
                  printf("  ; %s",copreg[idx].name);
                  break;
                }
            }
        }

      printf("\n");

    }

  return(TRUE);

}

#endif

