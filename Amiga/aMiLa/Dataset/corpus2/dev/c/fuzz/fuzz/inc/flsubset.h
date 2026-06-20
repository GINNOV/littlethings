#ifndef FLSUBSET_H
#define FLSUBSET_H


struct FL_subset       *FL_Subset(char *);
struct FL_subset       *FL_Clone_Subset(struct FL_subset *);
struct FL_subset       *FL_Clone_Subsets(struct FL_subset *, int);
int                     FL_Subset_Init(struct FL_subset *, enum FL_subsettype,double,double,double,double);
double                  FL_Subset_Memship(struct FL_subset *, double);
int                     FL_Add_Subset(struct FL_system *, char *, char *, enum FL_subsettype,double,double,double,double);
struct FL_subset       *FL_Get_Subset(struct FL_system *, char *, char *);
void                    FL_Write_Subset(FILE *, struct FL_subset *, int);
int                     FL_Read_Subset(FILE *, struct FL_subset *);

#endif
