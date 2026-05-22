#ifndef _SGEMEM_H
#define _SGEMEN_H

typedef struct {
	void *prev;
	void *next;
	char *id;
	void *data;
} SGELISTENTRY;

typedef struct {
	Uint32 numberOfEntries;
	SGELISTENTRY *first;
	SGELISTENTRY *last;
	SGELISTENTRY *entries;
} SGELIST;

typedef void(SGELISTFUNCTION)(const char *id, void *data);

SGELIST *sgeListNew(void);
SGELISTENTRY *sgeListAdd(SGELIST *l, const char *id, void *data);
SGELISTENTRY *sgeListInsert(SGELIST *l, SGELISTENTRY *le, const char *id, void *data);
SGELISTENTRY *sgeListSearch(SGELIST *l, char *id);
void sgeListRemove(SGELIST *l, char *id);
void sgeListForEach(SGELIST *l, SGELISTFUNCTION function);
void sgeListDestroy(SGELIST *l);

#endif
