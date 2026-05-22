#define RKMMOD_CurrVal  (TAG_USER + 1)
#define RKMMOD_Up       (TAG_USER + 2)
#define RKMMOD_Down     (TAG_USER + 3)
#define RKMMOD_Limit    (TAG_USER + 4)

extern Class  *initRKMModClass(void);
extern BOOL   freeRKMModClass(Class *);
