#ifndef FLVARIABLE_H
#define FLVARIABLE_H

int                  FL_Variable_Set(struct FL_variable *, char *, double);
int                  FL_Variable_XSet(struct FL_variable *, char *, double);
struct FL_variable  *FL_Clone_Variable(struct FL_variable *);
struct FL_variable  *FL_Clone_Variables(struct FL_variable *, int);
int                  FL_Variable_Evaluate(struct FL_variable *, enum FL_evalmethod);
int                  FL_Variable_XEvaluate(struct FL_variable *, enum FL_evalmethod);
int                  FL_Add_Variable(struct FL_system *, char *, char *, double);
int                  FL_Add_Variables(struct FL_system *, ...);
struct FL_variable  *FL_Variable_Get(struct FL_system *, char *);
int                  FL_Variable_Index(struct FL_system *, char *);
int                  FL_Variable_Reset(struct FL_system *, char *);
int                  FL_Get_Variable(struct FL_system *, char *, double*);
int                  FL_Get_Variables(struct FL_system *, ...);
int                  FL_Set_VariableByIndex(struct FL_system *, int, double);
int                  FL_Set_Variable(struct FL_system *, char *, double);
int                  FL_Set_Variables(struct FL_system *, ...);
int                  FL_Revise_Variables(struct FL_system *);
void                 FL_Write_Variable(FILE *, struct FL_variable *, int);
int                  FL_Read_Variable(FILE *, struct FL_variable *);

#endif
