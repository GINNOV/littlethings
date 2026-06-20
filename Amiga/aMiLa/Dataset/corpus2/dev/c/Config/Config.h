/*
** Config.h
**
** $VER: Config.h 1.0 (25.5.96)
**
** Copyright (C) 1996, Adam Dawes
**
** Refer to accompanying documentation for further details
*/


extern int WriteConfig(char *filename, char *section, char *item, char *data);
extern int WriteConfigNumber(char *filename, char *section, char *item, long data);
extern int ReadConfig(char *filename, char *section, char *item, char *buffer, int bufsize, char *def);
extern long ReadConfigNumber(char *filename, char *section, char *item, long def);

void init_list(struct List *lst);
int add_list_item(struct List *lst, char *item);
void free_list(struct List *lst);


#define BUFFERSIZE 256


#define CFG_WRITE_SUCCESS 1
#define CFG_WRITE_FAIL 0

#define CFG_READ_SUCCESS 1
#define CFG_READ_FAIL 0


