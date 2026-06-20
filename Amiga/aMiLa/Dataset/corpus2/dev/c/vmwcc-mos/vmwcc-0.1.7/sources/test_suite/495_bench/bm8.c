#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;


const long maxsyms = 8;
long original[8];
long noriginals;

long input[16];
long pos;
long ret;
long cnt;

const long nlinks = 16;
long link[16];

const long nentries = 16;
struct Entry {
  long sym;
  long prev, next;
  long rule;
  long flink, blink;
} ent[16];
long freeentries;


const long nrules = 8;
struct Rule {
  long prev, next;
  long first, last;
  long ref;
} rule[8];
long S, freerules;


void InitEntry(long e, long sym, long prev, long next, long rule, long flink, long blink)
{
  ent[e].sym = sym;
  ent[e].prev = prev;
  ent[e].next = next;
  ent[e].rule = rule;
  ent[e].flink = flink;
  ent[e].blink = blink;
}


void InitRule(long r, long prev, long next, long first, long last, long ref)
{
  rule[r].prev = prev;
  rule[r].next = next;
  rule[r].first = first;
  rule[r].last = last;
  rule[r].ref = ref;
}


void Init()
{
  long i;

  noriginals = 0;

  i = 0;
  while (i < nlinks) {
    link[i] = 0;
    i = i + 1;
  }

  ent[0].sym = 0;
  ent[0].prev = 0;
  ent[0].next = 0;
  ent[0].rule = 0;
  ent[0].flink = 0;
  ent[0].blink = 0;
  i = 1;
  while (i < nentries) {
    InitEntry(i, 0, 0, i+1, 0, 0, 0);
    i = i + 1;
  }
  ent[nentries-1].next = 0;
  freeentries = 1;

  rule[0].prev = 0;
  rule[0].next = 0;
  rule[0].first = 0;
  rule[0].last = 0;
  rule[0].ref = 0;
  i = 1;
  while (i < nrules) {
    InitRule(i, 0, i+1, 0, 0, 0);
    i = i + 1;
  }
  rule[nrules-1].next = 0;
  freerules = 1;
}


void GetUniqueSym(long data)
{
  long i, j;

  i = 1;
  j = 1;
  if (i > noriginals) {j = 0;}
  if (original[i] == data) {j = 0;}
  while (j != 0) {
    i = i + 1;
    j = 1;
    if (i > noriginals) {j = 0;} else {if (original[i] == data) {j = 0;}}
  }
  if (i > noriginals) {
    original[i] = data;
    noriginals = i;
  }
  ret = i;
}


void Hash(long sym)
{
  ret = sym % nlinks;
  while (ret < 0) {
    ret = ret + nlinks;
  }
}


void NewEntry()
{
  long e;

  e = freeentries;
  freeentries = ent[e].next;
  ent[e].next = 0;

  ret = e;
}


void FreeEntry(long e)
{
  InitEntry(e, 0, 0, freeentries, 0, 0, 0);
  freeentries = e;
}


void NewRule()
{
  long r;

  r = freerules;
  freerules = rule[r].next;
  rule[r].next = 0;

  ret = r;
}


void FreeRule(long r)
{
  InitRule(r, 0, freerules, 0, 0, 0);
  freerules = r;
}


void RemoveRule(long r)
{
  if (rule[r].next != 0) {rule[rule[r].next].prev = rule[r].prev;}
  if (rule[r].prev != 0) {rule[rule[r].prev].next = rule[r].next;}
  FreeRule(r);
}


void RemoveFromLink(long e)
{
  long hash, fwd, bwd;

  Hash(ent[e].sym);
  hash = ret;
  fwd = ent[e].flink;
  bwd = ent[e].blink;
  if (fwd != 0) {ent[fwd].blink = bwd;}
  if (bwd != 0) {ent[bwd].flink = fwd;}
  if (link[hash] == e) {link[hash] = fwd;}
  ent[e].flink = 0;
  ent[e].blink = 0;
}


void RemoveEntry(long e)
{
  long r;

  RemoveFromLink(e);
  r = ent[e].rule;
  if (rule[r].first == e) {rule[r].first = ent[e].next;}
  if (rule[r].last == e) {rule[r].last = ent[e].prev;}
  if (ent[e].next != 0) {ent[ent[e].next].prev = ent[e].prev;}
  if (ent[e].prev != 0) {ent[ent[e].prev].next = ent[e].next;}
  FreeEntry(e);
}


void ElimDupl(long self)
{
  long sym1, sym2, cur, e1, e2, hash, rul, e, j;

  cnt = cnt + 1;
  sym1 = ent[self].sym;
  sym2 = ent[ent[self].next].sym;
  Hash(sym1);
  cur = link[ret];
  
  j = 0;
  if (cur != 0) {
    if (ent[cur].sym != sym1) {j = 1;}
    if (ent[cur].next == 0) {j = 1;} else {if (ent[ent[cur].next].sym != sym2) {j = 1;}}
    if (cur == self) {j = 1;}
    if (ent[cur].next == self) {j = 1;}
  }
   
  while (j != 0) {
    cur = ent[cur].flink;
    j = 0;
     
    if (cur != 0) {
      if (ent[cur].sym != sym1) {j = 1;}
      if (ent[cur].next == 0) {j = 1;} else {if (ent[ent[cur].next].sym != sym2) {j = 1;}}
      if (cur == self) {j = 1;}
      if (ent[cur].next == self) {j = 1;}
    }
  }
  
   
  if (cur != 0) {
    j = 0;
    if (ent[cur].rule == ent[self].rule) {j = 1;}
    if (rule[ent[cur].rule].first != cur) {j = 1;}
    if (rule[ent[cur].rule].last != ent[cur].next) {j = 1;}
    
         
    if (j != 0) {
      NewRule();
      rul = ret;
      NewEntry();
      e1 = ret;
      NewEntry();
      e2 = ret;

      InitRule(rul, S, rule[S].next, e1, e2, 2);
      rule[S].next = rul;
      if (rule[rul].next != 0) {rule[rule[rul].next].prev = rul;}

      Hash(sym1);
      hash = ret;
      InitEntry(e1, sym1, 0, e2, rul, link[hash], 0);
      if (link[hash] != 0) {ent[link[hash]].blink = e1;}
      link[hash] = e1;

      Hash(sym2);
      hash = ret;
      InitEntry(e2, sym2, e1, 0, rul, link[hash], 0);
      if (link[hash] != 0) {ent[link[hash]].blink = e2;}
      link[hash] = e2;

      RemoveFromLink(self);
      RemoveFromLink(cur);
      ent[self].sym = -rul;
      ent[cur].sym = -rul;
      Hash(-rul);
      hash = ret;
      if (link[hash] != 0) {ent[link[hash]].blink = cur;}
      ent[cur].flink = link[hash];
      ent[cur].blink = self;
      ent[self].flink = cur;
      ent[self].blink = 0;
      link[hash] = self;
      RemoveEntry(ent[self].next);
      RemoveEntry(ent[cur].next);

      if (sym1 < 0) {
        rule[-sym1].ref = rule[-sym1].ref - 1;
        if (rule[-sym1].ref == 1) {
          RemoveEntry(e1);
          e = rule[-sym1].first;
          while (e != 0) {
            ent[e].rule = rul;
            e = ent[e].next;
          }
          ent[rule[-sym1].last].next = e2;
          ent[e2].prev = rule[-sym1].last;
          rule[rul].first = rule[-sym1].first;
          RemoveRule(-sym1);
          ElimDupl(ent[e2].prev);
        }
      }
      if (ent[e2].sym == sym2) {
        if (sym2 < 0) {
          rule[-sym2].ref = rule[-sym2].ref - 1;
          if (rule[-sym2].ref == 1) {
            e1 = ent[e2].prev;
            RemoveEntry(e2);
            e = rule[-sym2].first;
            while (e != 0) {
              ent[e].rule = rul;
              e = ent[e].next;
            }
            ent[rule[-sym2].first].prev = e1;
            ent[e1].next = rule[-sym2].first;
            rule[rul].last = rule[-sym2].last;
            RemoveRule(-sym2);
            ElimDupl(e1);
          }
        }
      }

      if (ent[self].sym == -rul) {
        if (ent[self].prev != 0) { ElimDupl(ent[self].prev);}
      }
      if (ent[self].sym == -rul) {
        if (ent[self].next != 0) {ElimDupl(self);}
      }
      if (ent[cur].sym == -rul) {
        if (ent[cur].prev != 0) {ElimDupl(ent[cur].prev);}
      }
      if (ent[cur].sym == -rul) {
        if (ent[cur].next != 0) {ElimDupl(cur);}
      }
    } else {
      rul = ent[cur].rule;
      rule[rul].ref = rule[rul].ref + 1;
      RemoveFromLink(self);
      ent[self].sym = -rul;
      Hash(-rul);
      hash = ret;
      if (link[hash] != 0) {ent[link[hash]].blink = self;}
      ent[self].flink = link[hash];
      ent[self].blink = 0;
      link[hash] = self;
      RemoveEntry(ent[self].next);
      if (ent[self].prev != 0) {ElimDupl(ent[self].prev);}
      if (ent[self].sym == -rul) {
        if (ent[self].next != 0) {ElimDupl(self);}
      }
    }
  }
}


void Decode(long r)
{
  long cur, sym;

  if (r == 0) {cur = 0;} else {cur = rule[r].first;}
  while (cur != 0) {
    sym = ent[cur].sym;
    if (sym > 0) {
      if (original[sym] != input[pos]) {WriteLong(99999);}
      pos = pos + 1;
    } else {
      Decode(-sym);
    }
    cur = ent[cur].next;
  }
}


void main()
{
  long dummy, sym, new, hash;
  long cur, tot, i, j, max;

  ReadLong(tot);
  if (tot <= 0) {
    tot = 1;
  }
  i = 0;
  max = 1;
  while (i < tot*2) {
    max = max*2;
    i = i + 1;
  }
  WriteLong(max);
   
  i = 0;
  while (i < max) {
    cur = i;
    j = 0;
     
    while (j < tot) {
      input[j] = cur % 4;
      cur = cur / 4;
      j = j + 1;
    }
    input[tot] = 0;

    Init();

    NewEntry();
    dummy = ret;
          
    InitEntry(dummy, 0, 0, 0, 0, 0, 0);
    NewRule();
    S = ret;
     
    InitRule(S, 0, 0, dummy, dummy, 1);

    cur = 0;
     
    while (cur < tot) {
      GetUniqueSym(input[cur]);
      sym = ret;
      Hash(sym);
      hash = ret;
      NewEntry();
      new = ret;

      InitEntry(new, sym, rule[S].last, 0, S, link[hash], 0);
      ent[rule[S].last].next = new;
      rule[S].last = new;
      if (link[hash] != 0) {ent[link[hash]].blink = new;}
      link[hash] = new;

      ElimDupl(ent[new].prev);
      cur = cur + 1;
    }

    pos = 0;
    Decode(S);
 
    i = i + 1;
  }

  WriteLong(cnt);
  WriteLine();
}
