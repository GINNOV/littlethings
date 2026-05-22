#include <sge.h>

SGELIST *sgeListNew() {
	SGELIST *ret;
	sgeNew(ret, SGELIST);
	ret->numberOfEntries=0;
	ret->first=NULL;
	ret->last=NULL;
	ret->entries=NULL;
	return ret;
}

SGELISTENTRY *sgeListAdd(SGELIST *l, const char *id, void *data) {
	SGELISTENTRY *ret;

	sgeNew(ret, SGELISTENTRY);
	l->numberOfEntries++;
	if (l!=NULL) {
		ret->prev=l->last;
	} else {
		ret->prev=NULL;
	}
	if (l!=NULL && l->last!=NULL) {
		l->last->next=ret;
	}
	ret->next=NULL;
	ret->id=strdup(id);
	ret->data=data;

	if (l==NULL) return ret;

	if (l->first==NULL) l->first=ret;
	l->last=ret;

	return ret;
}

static void sgeListFreeList(SGELISTENTRY *l) {
	sgeFree(l->id);
	sgeFree(l);
}

SGELISTENTRY *sgeListInsert(SGELIST *l, SGELISTENTRY *le, const char *id, void *data) {
	SGELISTENTRY *ret=sgeListAdd(NULL, id, data);
	SGELISTENTRY *tmp;

	l->numberOfEntries++;
	if (le->prev==NULL) {
		ret->next=le;
		le->prev=ret;
		l->first=ret;
		return ret;
	}

	tmp=le->prev;
	tmp->next=ret;
	ret->prev=tmp;
	ret->next=le;
	le->prev=ret;

	return ret;
}

SGELISTENTRY *sgeListSearch(SGELIST *l, char *id) {
	SGELISTENTRY *act=l->first;

	while (act!=NULL) {
		if (strcmp(act->id,id)==0) return act;
		act=act->next;
	}
	return NULL;
}

void sgeListRemove(SGELIST *l, char *id) {
	SGELISTENTRY *i=sgeListSearch(l, id);
	SGELISTENTRY *other=NULL;
	if (i==NULL) return;

	l->numberOfEntries--;
	if ((i->prev==NULL) && (i->next==NULL)) {
		sgeListFreeList(i);
		return;
	}

	if (i->prev!=NULL) {
		other=i->prev;
		other->next=i->next;
	}
	if (i->next!=NULL) {
		other=i->next;
		other->prev=i->prev;
	}
	sgeListFreeList(i);
	return;
}

void sgeListForEach(SGELIST *l, SGELISTFUNCTION function) {
	SGELISTENTRY *iter=l->first;
	do {
		function(iter->id, iter->data);
		iter=iter->next;
	} while (iter!=NULL);
}

void sgeListDestroy(SGELIST *l) {
	SGELISTENTRY *iter=l->first;
	SGELISTENTRY *tmp;
	do {
		tmp=iter;
		iter=iter->next;
		sgeListFreeList(tmp);
	} while (iter!=NULL);
	sgeFree(l);
}
