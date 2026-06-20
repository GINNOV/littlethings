#ifndef _LINEREAD_H
#define _LINEREAD_H

/***********************************************************************/

struct lineRead
{
    struct Library  *socketBase;
    char            *line;
    int             sock;
    int             type;
    int             startp;
    int             bufPtr;
    int             howLong;
    int             bufferSize;
    int             lineCompleted;
    int             selected;
    char            saved;
    char            buffer[0];
};

/***********************************************************************/

/* type */
enum
{
    LRV_Type_NotReq,
    LRV_Type_ReqLF,
    LRV_Type_ReqNul,
};

/***********************************************************************/

#endif /* _LINEREAD_H */
