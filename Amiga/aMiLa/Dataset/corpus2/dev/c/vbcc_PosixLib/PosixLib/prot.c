/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003,2006
 *
 * $Id: prot.c,v 1.6 2022/01/16 14:27:09 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#ifdef __amigaos4__
#include <dos/dosextens.h>
#include <dos/obsolete.h>
#endif
#include <proto/dos.h>
#pragma default-align
#include <sys/stat.h>

static mode_t __umask = S_IWGRP|S_IWOTH;  /* default umask */


mode_t __prot2mode(unsigned long p)
{
  mode_t m = 0;

  /* User RWED bits are inverted, flip for clarity */
  p ^= (FIBF_READ|FIBF_WRITE|FIBF_EXECUTE|FIBF_DELETE);

  if (p & FIBF_READ)                           m |= S_IRUSR;
  if (p & (FIBF_WRITE | FIBF_DELETE))          m |= S_IWUSR;
  if (p & (FIBF_EXECUTE | FIBF_SCRIPT))        m |= S_IXUSR;
  if (p & FIBF_GRP_READ)                       m |= S_IRGRP;
  if (p & (FIBF_GRP_WRITE | FIBF_GRP_DELETE))  m |= S_IWGRP;
  if (p & FIBF_GRP_EXECUTE)                    m |= S_IXGRP;
  if (p & FIBF_OTR_READ)                       m |= S_IROTH;
  if (p & (FIBF_OTR_WRITE | FIBF_OTR_DELETE))  m |= S_IWOTH;
  if (p & FIBF_OTR_EXECUTE)                    m |= S_IXOTH;

  return m;
}


/*
 * Convert posix style filemode bits to amiga style protection bits.
 *
 * Write protection is typically used to prevent deletion so we set both
 * write protect and delete protect in that case.
 *
 * The user RWED bits are inverted, for clarity we flip them at the end.
 */
unsigned long __mode2prot(mode_t m)
{
  unsigned long p = 0;

  if (m & S_IRUSR)  p |= FIBF_READ;
  if (m & S_IWUSR)  p |= FIBF_WRITE | FIBF_DELETE;
  if (m & S_IXUSR)  p |= FIBF_EXECUTE;
  if (m & S_IRGRP)  p |= FIBF_GRP_READ;
  if (m & S_IWGRP)  p |= FIBF_GRP_WRITE | FIBF_GRP_DELETE;
  if (m & S_IXGRP)  p |= FIBF_GRP_EXECUTE;
  if (m & S_IROTH)  p |= FIBF_OTR_READ;
  if (m & S_IWOTH)  p |= FIBF_OTR_WRITE | FIBF_OTR_DELETE;
  if (m & S_IXOTH)  p |= FIBF_OTR_EXECUTE;

  return p ^ (FIBF_READ|FIBF_WRITE|FIBF_EXECUTE|FIBF_DELETE);
}


int __set_prot(char *name,mode_t mode)
{
  return SetProtection((STRPTR)name,__mode2prot(mode)) ? 0 : -1;
}


int __set_masked_prot(char *name,mode_t mode)
{
  return __set_prot(name,mode & ~__umask);
}


mode_t __get_masked_prot(mode_t mode)
{
  return (mode & ~__umask);
}


mode_t umask(mode_t new)
{
  mode_t old = __umask;

  __umask = new;
  return old;
}
