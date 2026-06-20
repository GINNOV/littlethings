#ifndef CLIB_REMOTE_PROTOS_H
#define CLIB_REMOTE_PROTOS_H

/*
** $VER: remote_protos.h 1.0 (6.10.97)
**
** C prototypes.
**
** (C) Copyright 1997 Dietmar Eilert
** All Rights Reserved
*/

#define LibCall __geta4 __regargs

extern LibCall int   RemoteInit(void);
extern LibCall int   RemoteAdd(char *config);
extern LibCall int   RemoteRemove(char *appname);
extern LibCall int   RemoteOpen(char *class, char *appname, char *file, int flags);
extern LibCall char *RemoteError(int error);
extern LibCall int   RemoteValidate(char *folder, int flags);

#endif
