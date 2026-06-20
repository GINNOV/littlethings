/*  prints sections of Tru64 V5.1 executables  11-19-03  Martin Burtscher  */


#include <stdlib.h>
#include <stdio.h>
#include <filehdr.h>
#include <aouthdr.h>
#include <scnhdr.h>
#include <assert.h>


int main(int argc, char *argv[])
{
  int i, j;
  FILE *f;
  struct filehdr hdr;
  struct aouthdr aout;
  struct scnhdr scn;

  assert(2 == argc);
  printf("loading %s\n", argv[1]);
  f = fopen(argv[1], "r+b");
  assert(NULL != f);

  assert(1 == fread(&hdr, sizeof(struct filehdr), 1, f));
  printf("\n[file header]\n");
  printf("magic = %d\n", hdr.f_magic);
  printf("nscns = %d\n", hdr.f_nscns);
  printf("timdat = %d\n", hdr.f_timdat);
  printf("symptr = 0x%lx\n", hdr.f_symptr);
  printf("nsyms = %d\n", hdr.f_nsyms);
  printf("opthdr = %d\n", hdr.f_opthdr);
  printf("flags = 0x%x\n", hdr.f_flags);

  assert(ALPHAMAGIC == hdr.f_magic);  // normal file, not compressed, not old
  assert(sizeof(struct aouthdr) == hdr.f_opthdr);

  if (F_RELFLG & hdr.f_flags) printf("F_RELFLG\n");
  if (F_EXEC & hdr.f_flags) printf("F_EXEC\n");
  if (F_LNNO & hdr.f_flags) printf("F_LNNO\n");
  if (F_LSYMS & hdr.f_flags) printf("F_LSYMS\n");
  if (F_NO_SHARED & hdr.f_flags) printf("F_NO_SHARED\n");
  if (F_NO_CALL_SHARED & hdr.f_flags) printf("F_NO_CALL_SHARED\n");
  if (F_LOMAP & hdr.f_flags) printf("F_LOMAP\n");
  if (F_SHARABLE & hdr.f_flags) printf("F_SHARABLE\n");
  if (F_CALL_SHARED & hdr.f_flags) printf("F_CALL_SHARED\n");
  if (F_NO_REORG & hdr.f_flags) printf("F_NO_REORG\n");
  if (F_NO_REMOVE & hdr.f_flags) printf("F_NO_REMOVE\n");

  assert(F_EXEC & hdr.f_flags);  // file is executable

  assert(1 == fread(&aout, sizeof(struct aouthdr), 1, f));
  printf("\n[a.out header]\n");
  printf("magic = %d\n", aout.magic);
  printf("vstamp = %d\n", aout.vstamp);
  printf("bldrev = %d\n", aout.bldrev);
  printf("padcell = %d\n", aout.padcell);
  printf("tsize = 0x%lx\n", aout.tsize);
  printf("dsize = 0x%lx\n", aout.dsize);
  printf("bsize = 0x%lx\n", aout.bsize);
  printf("entry = 0x%lx\n", aout.entry);
  printf("text_start = 0x%lx\n", aout.text_start);
  printf("data_start = 0x%lx\n", aout.data_start);
  printf("bss_start = 0x%lx\n", aout.bss_start);
  printf("gprmask = %d\n", aout.gprmask);
  printf("fprmask = %d\n", aout.fprmask);
  printf("gp_value = 0x%lx\n", aout.gp_value);

  assert(ZMAGIC == aout.magic);  // text and data separated, text read only
  assert(aout.text_start <= aout.entry);
  assert(aout.entry < (aout.text_start + aout.tsize));
  assert(aout.bss_start = (aout.data_start + aout.dsize));
  assert(aout.text_start == 0x120000000);  // standard vaddr
  assert(aout.data_start == 0x140000000);  // standard vaddr

  for (i = 0; i < hdr.f_nscns; i++) {
    assert(1 == fread(&scn, sizeof(struct scnhdr), 1, f));
    printf("\n[section %ld]\n", i);
    for (j = 0; j < 8; j++) printf("%c", scn.s_name[j]);  printf("\n");
    printf("s_paddr = 0x%lx\n", scn.s_paddr);
    printf("s_vaddr = 0x%lx\n", scn.s_vaddr);
    printf("s_size = 0x%lx\n", scn.s_size);
    printf("s_scnptr = 0x%lx\n", scn.s_scnptr);
    printf("s_relptr = %ld\n", scn.s_relptr);
    printf("s_lnnoptr = %ld\n", scn.s_lnnoptr);
    printf("s_nreloc = %d\n", scn.s_nreloc);
    printf("s_nlnno = %d\n", scn.s_nlnno);
    printf("s_alignment = %ld\n", 1L << (scn.s_alignment+3));
    printf("s_reserved = %d\n", scn.s_reserved);
    printf("s_flags = 0x%x\n", scn.s_flags);

    assert(scn.s_paddr == scn.s_vaddr);
  }
  fclose(f);

  return 0;
}
