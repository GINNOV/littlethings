#ifndef FLRULE_H
#define FLRULE_H

extern int                 FL_Rule_Evaluate(struct FL_rule *);
extern int                 FL_Rule_XEvaluate(struct FL_rule *);
struct FL_rule            *FL_Clone_Rules(struct FL_rule *, int);
struct FL_rule            *FL_Clone_Rule(struct FL_rule *);
extern struct FL_rule     *FL_Rule(char *);
extern int                 FL_Add_Rule(struct FL_system *, char *, char *);
extern struct FL_rule     *FL_Get_Rule(struct FL_system *, char *, char *);
extern int                 FL_Write_Rule(FILE *, struct FL_rule *, int);
extern int                 FL_Read_Rule(FILE *, struct FL_rule *);
extern void                FL_Kill_Rule(struct FL_rule *);

#endif
