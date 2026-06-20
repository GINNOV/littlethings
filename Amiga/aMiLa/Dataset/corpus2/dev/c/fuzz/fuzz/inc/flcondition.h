#ifndef FLCONDITION_H
#define FLCONDITION_H

struct FL_condition       *FL_Condition(char *);
struct FL_condition       *FL_Clone_Condition(struct FL_condition *);
struct FL_condition       *FL_Clone_Conditions(struct FL_condition *, int);
double                     FL_Condition_Evaluate(struct FL_condition *);
double                     FL_Condition_XEvaluate(struct FL_condition *);
int                        FL_Add_Condition(struct FL_system *, char *, char *, char *,
					    char *, char *, enum FL_operator, char *);
int                        FL_Write_Condition(FILE *, struct FL_condition *, int);
int                        FL_Read_Condition(FILE *, struct FL_condition *);

#endif
