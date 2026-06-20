/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003
 *
 * $Id: conv.h,v 1.3 2021/07/28 14:40:30 phx Exp $
 */
#include <stddef.h>

char *__convert_path(const char *);
char *__make_ados_pattern(const char *,int);
size_t __path_from_ados(const char *path,char *buf,size_t bufsize);
