#ifndef FLCLAUSE_H
#define FLCLAUSE_H

extern struct FL_clause       *FL_Clause(char *);
struct FL_clause              *FL_Clone_Clauses(struct FL_clause *, int);
struct FL_clause              *FL_Clone_Clause(struct FL_clause *);
extern double                  FL_Clause_Evaluate(struct FL_clause *);
extern double                  FL_Clause_XEvaluate(struct FL_clause *);
extern struct FL_clause       *FL_Get_Clause(struct FL_system *, char *, char *, char *);
extern int                     FL_Add_Clause(struct FL_system *, char *, char *, char *);
extern int                     FL_Write_Clause(FILE *, struct FL_clause *, int);
extern int                     FL_Read_Clause(FILE *, struct FL_clause *);
extern void                    FL_Kill_Clause(struct FL_clause *);

#endif
