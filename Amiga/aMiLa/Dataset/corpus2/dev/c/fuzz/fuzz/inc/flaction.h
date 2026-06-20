#ifndef FLACTION_H
#define FLACTION_H

struct FL_action       *FL_Action(char *);
struct FL_action       *FL_Clone_Action(struct FL_action *);
struct FL_action       *FL_Clone_Actions(struct FL_action *,int);
int                     FL_Action_Execute(struct FL_action *, double);
int                     FL_Action_XExecute(struct FL_action *, double);
int                     FL_Add_Action(struct FL_system *, char *, char *, char *, char *, char *);
int                     FL_Write_Action(FILE *, struct FL_action *, int);
int                     FL_Read_Action(FILE *, struct FL_action *);

#endif

