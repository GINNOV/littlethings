
struct instruction {
  unsigned opcode:  4;
  unsigned destreg: 3;
  unsigned extend:  3;
  unsigned srcmode: 3;
  unsigned srcreg:  3;
  };

struct shiftbits {
  unsigned opcode:  4;
  unsigned count:   3;
  unsigned direct:  1;
  unsigned optype:  2;
  unsigned opmode:  1;
  unsigned shift:   2;
  unsigned dest:    3;
  };

struct testbits {
  unsigned opcode:  4;
  unsigned ccode:   4;
  unsigned offset:  8;
  };

union {
  struct instruction iview;
  struct shiftbits s;
  struct testbits tview;
  short sview; } cheat;

char opline[120], *opp, *valp;

startline()
{
  valp=opline; opp=opline+34;
}

displayline()
{
  while (valp<(opline+34)) *valp++=' ';
  *opp='\0';
  printf("%s\n",opline);
}

padd()
{
  while (opp<(opline+42)) opchar(' ');
}

opchar(c)
char c;
{
  *opp++=c;
}

opstring(s)
char *s;
{
  while (*s!='\0') *opp++=*s++;
}

opcode(s)
char *s;
{
  int n=5;
  while (*s!='\0' & n-- >0) *opp++=*s++;
}

opint(v)
int v;
{
  int t;
  if (v<=0) *opp++='0';
  else { if ((t=v/10)>0) opint(t); *opp++ = v%10+'0'; };
}

ophex(v,n)
int v,n;
{
  char c;
  while (n-- > 0)
    *opp++ = (c=(v>>(n<<2)) & 0xF) <= 9 ? c+'0' : c-10+'A';
}

lefthex(v,b)
int v,b;
{
  int n=4;
  char c;
  while (b-->0) *valp++ = ' ';
  while (n-->0)
    *valp++ = (c=(v>>(n<<2)) & 0xF) <= 9 ?c+'0':c-10+'A';
}

mynext(b)
int b;
{
  int v;
  lefthex(v=nextcodeword(),b);
  return v;
}

invalid()
{
  opstring(".WORD"); padd(); ophex(cheat.sview,4);
}

int srckind;

sourcekind(k)
int k;
{
  opchar('.');
  switch (k) {
    case 0: case 4:         opchar('B'); srckind=0; break;
    case 1: case 5: case 3: opchar('W'); srckind=1; break;
    case 2: case 6: case 7: opchar('L'); srckind=2; break;
    }
}

shiftinstruction()
{
  int t;
  static char *mnemonics[8] =
       { "ASR",  "ASL",  "LSR", "LSL",
         "ROXR", "ROXL", "ROR", "ROL" };
  if (cheat.s.optype==3) {
    opstring(mnemonics[(cheat.s.count<<1)+cheat.s.direct]);
    padd();
    operand(cheat.iview.srcmode,cheat.iview.srcreg);
    }
  else {
    opstring(mnemonics[(cheat.s.shift<<1)+cheat.s.direct]);
    sourcekind(cheat.s.optype);
    padd();
    if (cheat.s.opmode==0) {
      opchar('#');
      opint( (t=cheat.s.count)==0 ? 8 : t );
      }
    else
      operand(0,cheat.s.count);
    opchar(',');
    operand(0,cheat.s.dest);
    }
}

operand(mode,reg)
int mode,reg;
{
  struct indexword {
    unsigned dora :1;
    unsigned ireg :3;
    unsigned size :1;
    unsigned junk :3;
    unsigned disp :8;
    };
  union {
    short sh;
    struct indexword ind;
    } mycheat;
  switch (mode) {
    case 0: opchar('D'); opint(reg); break;
    case 1: opchar('A'); opint(reg); break;
    case 2: opstring("(A"); opint(reg); opchar(')'); break;
    case 3: opstring("(A"); opint(reg); opstring(")+");
            break;
    case 4: opstring("-(A"); opint(reg); opchar(')'); break;
    case 5: ophex(mynext(1),4);
            opstring("(A"); opint(reg); opchar(')'); break;
    case 6: mycheat.sh=mynext(1);
            ophex(mycheat.ind.disp,2);
            opstring("(A"); opint(reg); opchar(',');
            opchar(mycheat.ind.dora==0 ? 'D' : 'A');
            opint(mycheat.ind.ireg);
            opchar('.');
            opchar(mycheat.ind.size==0 ? 'W' : 'L');
            opchar(')'); break;
    case 7: switch (reg) {
      case 0: ophex(mynext(1),4); break;
      case 1: ophex(mynext(1),4); ophex(mynext(0),4); break;
      case 2: opchar('+'); ophex(mynext(1),4); break;
      case 3: mycheat.sh=mynext(1);
              opchar('+');
              ophex(mycheat.ind.disp,2);
              opchar('(');
              opchar(mycheat.ind.dora==0 ? 'D' : 'A');
              opint(mycheat.ind.ireg);
              opchar('.');
              opchar(mycheat.ind.size==0 ? 'W' : 'L');
              opchar(')');
              break;
      case 4: opchar('#');
              switch (srckind) {
                case 0: ophex(mynext(1),2); break;
                case 1: ophex(mynext(1),4); break;
                case 2: ophex(mynext(1),4); ophex(mynext(0),4); break;
                };
              break;
      }
    }
}

conditioncode(cc)
int cc;
{
  char *codes = "RASRHILSCCCSNEEQVCVSPLMIGELTGTLE";
  if (cc>1 || cheat.iview.opcode==6) {
    opchar(codes[cc<<1]);
    opchar(codes[(cc<<1)+1]);
    }
  else if (cc==0) opchar('T'); else opchar('F');
}

handlezero()
{
  int ext =  cheat.iview.extend;
  int dreg = cheat.iview.destreg;
  int smod = cheat.iview.srcmode;
  int sreg = cheat.iview.srcreg;
  static char *opzero[] = {"OR","AND","SUB","ADD","","EOR","CMP",""};
  static char *opone[] = {"BTST","BCHG","BCLR","BSET"};
  if (ext<=2 & dreg!=4) {
    opstring(opzero[dreg]); sourcekind(ext); padd();
    operand(7,4); opchar(',');
    if (smod==7 && sreg==4)
      if (srckind==0) opstring("CCR"); else opstring("SR");
    else operand(smod,sreg);
    }
  else if (ext<=3 & dreg==4) {
    opstring(opone[ext]); padd();
    srckind = 0; operand(7,4); opchar(','); operand(smod,sreg);
    }
  else if (ext>=4) {
    if (smod!=1) {
      opstring(opone[ext-4]); padd();
      operand(0,dreg); opchar(','); operand(smod,sreg);
      }
    else {
      opstring("MOVEP"); sourcekind(1+(ext&1)); padd();
      if (ext<=5) {
        operand(5,sreg); opchar(','); operand(0,dreg);
        }
      else {
        operand(0,dreg); opchar(','); operand(5,sreg);
        }
      }
    }
  else opstring("Invalid");
}

breakfurther(base)
char *base;
{
  int ext =  cheat.iview.extend;
  int dreg = cheat.iview.destreg;
  int smod = cheat.iview.srcmode;
  int sreg = cheat.iview.srcreg;
  int comm,t;

  if ( ( (comm=*(base+ext)) & 0xF0 ) == 0x40 )
    comm = *( base+(8+(t=comm&0xF)+(t<<2)+(smod==0 ? 1 :(smod==1 ? 2 : 0))));
  if (comm==0)
    opstring("Invalid");
  else {
    opcode(base+(8+(t=comm&7)+(t<<2)));
    if (comm & 8) sourcekind(ext);
    if ((t=(comm>>4)&0xF)>=13) conditioncode(cheat.tview.ccode);
    padd();
    switch (t) {
      case 0: opstring("Invalid"); break;
      case 1: operand(smod,sreg); opchar(','); operand(0,dreg); break;
      case 2: operand(smod,sreg); opchar(','); operand(1,dreg); break;
      case 3: operand(0,dreg); opchar(','); operand(smod,sreg); break;
      case 4: opstring("Internal check fail"); break;
      case 5: operand(3,sreg); opchar(','); operand(3,dreg); break;
      case 6: operand(4,sreg); opchar(','); operand(4,dreg); break;
      case 7: opchar('#'); opint(dreg); opchar(','); operand(smod,sreg);
              break;
      case 8: opchar('#'); ophex(cheat.tview.offset,2); opchar(',');
              operand(0,dreg); break;
      case 9: operand(1,dreg); opchar(','); operand(smod,sreg); break;
      case 13: operand(smod,sreg); break;
      case 14: operand(0,sreg); opchar(','); operand(7,2); break;
      case 15: if (cheat.tview.offset==0)
                 operand(7,2);
               else {
                 opchar('+');
                 ophex(cheat.tview.offset,2);
                 };
               break;
      }
    }
}

moveinstruction(kind)
int kind;
{
  opstring("MOVE");
  sourcekind(kind==1 ? 0 : (kind==2 ? 2 : 1));
  padd();
  operand(cheat.iview.srcmode,cheat.iview.srcreg);
  opchar(',');
  operand(cheat.iview.extend,cheat.iview.destreg);
}

startrange(bit)
int bit;
{
  operand(bit<=7 ? 0 : 1, bit%8);
}

endrange(first,bit)
int first,bit;
{
  if (first<=7 && bit>7) {
    endrange(first,7);
    opchar('/');
    startrange(8);
    first=8;
    };
  if (bit>first) {
    opchar('-');
    startrange(bit);
    }
}

registerlist(kkkk,mask)
int kkkk,mask;
{
  int bit=0; int inrange=-1; int some=0;
  while (bit <= 15) {
    if ( ( kkkk ? (mask>>(15-bit)) : (mask>>bit) ) & 1 ) {
      if (inrange<0) {
        if (some) opchar('/');
        startrange(bit);
        some=1; inrange=bit;
        }
      }
    else {
      if (inrange>=0) {
        endrange(inrange,bit-1);
        inrange=-1;
        }
      };
    bit++;
    };
  if (inrange>=0) endrange(inrange,15);
}

specialbits()
{
  int smod = cheat.iview.srcmode;
  int sreg = cheat.iview.srcreg;
  switch (smod) {
    case 0: opstring("TRAP"); padd(); opchar('#'); opint(sreg); break;
    case 1: opstring("Invalid"); break;
    case 2: opstring("LINK"); padd(); operand(1,sreg);
            opchar(','); srckind=1; operand(7,4); break;
    case 3: opstring("UNLK"); padd(); operand(1,sreg); break;
    case 4: opstring("MOVE"); padd(); operand(1,sreg);
                                      opstring(",USP"); break;
    case 5: opstring("MOVE"); padd(); opstring("USP,");
                                      operand(1,sreg); break;
    case 6: switch (sreg) {
      case 0: opstring("RESET"); break;
      case 1: opstring("NOP"); break;
      case 2: opstring("STOP"); padd(); srckind=1; operand(7,4); break;
      case 3: opstring("RTE"); break;
      case 4: opstring("Invalid"); break;
      case 5: opstring("RTS"); break;
      case 6: opstring("TRAPV"); break;
      case 7: opstring("RTR"); break;
      }; break;
    case 7: opstring("Invalid"); break;
    }
}

handlefour()
{
  int ext =  cheat.iview.extend;
  int dreg = cheat.iview.destreg;
  int smod = cheat.iview.srcmode;
  int sreg = cheat.iview.srcreg;
  int reglist;
  static char *unaryA[] = {"NEGX","CLR","NEG","NOT","","TST"};
  static char *cross4[] = {"NBCD","PEA", "MOVEM.W","MOVEM.L",
                           "NBCD","SWAP","EXT.W",  "EXT.L"};
  static char *jumps[] = {"JSR","JMP"};

  if (ext<=2 && (dreg<=3 || dreg==5)) {
    opstring(unaryA[dreg]); sourcekind(ext); padd(); operand(smod,sreg);
    }
  else if (dreg==4 && ext<=3) {
    opstring(cross4[smod==0 ? ext+4 : ext]); padd();
    if (ext>=2 && smod!=0) {
      registerlist(smod==4,mynext(1)); opchar(',');
      };
    operand(smod,sreg);
    }
  else if (ext==2 || ext==3) {
    if (dreg==6) {
      opstring(cross4[ext]); padd(); reglist=mynext(1);
      operand(smod==4 ? 3: smod ,sreg); opchar(','); registerlist(0,reglist);
      }
    else if (dreg==7) {
      opstring(jumps[ext-2]); padd(); operand(smod,sreg);
      }
    else if (ext==3) {
      switch (dreg) {
        case 0: opstring("MOVE"); padd(); opstring("SR,");
                operand(smod,sreg); break;
        case 1: opstring("Invalid"); break;
        case 2: opstring("MOVE"); padd(); srckind=0;
                operand(smod,sreg); opstring(",CCR"); break;
        case 3: opstring("MOVE"); padd(); srckind=1;
                operand(smod,sreg); opstring(",SR");  break;
        case 5: opstring("TAS"); padd(); operand(smod,sreg); break;
        }
      }
    }
  else if (ext==7) {
    opstring("LEA"); padd(); operand(smod,sreg);
    opchar(','); operand(1,dreg);
    }
  else if (ext==6) {
    opstring("CHK"); padd(); srckind=1;
    operand(smod,sreg); opchar(','); operand(0,dreg);
    }
  else if (ext==1 && dreg==7) specialbits();
  else opstring("Invalid");
}

char *interpret[16] = {
/*0*/ "\0\0\0\0\0\0\0\0",
/*1*/ "",
/*2*/ "",
/*3*/ "",
/*4*/ "\0\0\0\0\0\0\0\0",
/*5*/ "\170\170\170\104\173\173\173\104ADDQ\0S\0\0\0\0DB\0\0\0SUBQ\0\321\321\342",
/*6*/ "\360\360\360\360\360\360\360\360B",
/*7*/ "\200\200\200\200\200\200\200\200MOVEQ",
/*8*/ "\30\30\30\21\104\105\105\22OR\0\0\0DIVU\0DIVS\0SBCD\0\70\23\143\0\0\70\0\0",
/*9*/ "\30\30\30\50\102\102\102\50SUB\0\0SUBX\0\70\31\151",
/*a*/ "\0\0\0\0\0\0\0\0",
/*b*/ "\30\30\30\50\103\103\103\50CMP\0\0EOR\0\0CMPM\0\71\71\132",
/*c*/ "\30\30\30\21\105\106\107\22AND\0\0MULU\0MULS\0ABCD\0EXG\0\0\70\23\143\0\0\70\64\224\0\0\70\0\64",
/*d*/ "\30\30\30\50\102\102\102\50ADD\0\0ADDX\0\70\31\151",
/*e*/ "",
/*f*/ "\0\0\0\0\0\0\0\0"
  };



	decode(addr)

int addr;

{
  startline();
  lefthex(addr>>16,0); lefthex(addr,0);
  cheat.sview=mynext(1);
  switch (cheat.iview.opcode) {
    case 1:
    case 2:
    case 3:  moveinstruction(cheat.iview.opcode); break;
    case 0:  handlezero(); break;
    case 4:  handlefour(); break;
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 15: breakfurther(interpret[cheat.iview.opcode]); break;
    case 14: shiftinstruction(); break;
    };
  displayline();
}
