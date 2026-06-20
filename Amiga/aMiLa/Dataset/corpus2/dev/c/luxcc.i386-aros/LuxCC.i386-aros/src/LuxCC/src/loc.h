#ifndef LOC_H_
#define LOC_H_

typedef struct Location Location;

void location_init(void);
void location_new(char *id, int offset);
int location_get_offset(char *id);
void location_pop_scope(void);
void location_push_scope(void);

#endif
