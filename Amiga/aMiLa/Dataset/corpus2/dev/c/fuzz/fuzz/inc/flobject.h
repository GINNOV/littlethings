#ifndef FLOBJECT_H
#define FLOBJECT_H

extern struct FL_object       *FL_Object(char *);
struct FL_object              *FL_Clone_Object(struct FL_object *);
struct FL_object              *FL_Clone_Objects(struct FL_object *,int);
extern int                     FL_Add_Object(struct FL_system *,char *, enum FL_evalmethod);
extern int                     FL_Add_Objects(struct FL_system *, ...);
extern struct FL_object       *FL_Get_Object(struct FL_system *, char *);
extern int                     FL_Object_Run(struct FL_system *, char *);
extern int                     FL_Object_Evaluate(struct FL_object *);
extern int                     FL_Object_XEvaluate(struct FL_object *);
extern int                     FL_Revise_Objects(struct FL_system *);
extern void                    FL_Write_Object(FILE *, struct FL_object *, int);
extern int                     FL_Read_Object(FILE *, struct FL_object *);
extern void                    FL_Kill_Object(struct FL_object *);

#endif

