#ifndef FUZZTYPES_H
#define FUZZTYPES_H

#define FL_MAXNAMELENGTH        32

#define FL_SUBSETDEFAULTNAME    "FL_Subset"
#define FL_MEMFUNCDEFAULTNAME   "FL_Memfunc"
#define FL_VARIABLEDEFAULTNAME  "FL_Variable"
#define FL_CONDITIONDEFAULTNAME "FL_Condition"
#define FL_CLAUSEDEFAULTNAME    "FL_Clause"
#define FL_ACTIONDEFAULTNAME    "FL_Action"
#define FL_RULEDEFAULTNAME      "FL_Rule"
#define FL_OBJECTDEFAULTNAME    "FL_Object"
#define FL_SYSTEMDEFAULTNAME    "FL_System"

enum FL_subsettype {SINGLETON,TRIANGULAR,TRAPEZOID,GAUSSIAN};

typedef struct FL_subset {
  char                   name[FL_MAXNAMELENGTH+1];   /* Name of Subset */
  enum FL_subsettype     type;                       /* Typ of Subset */
  double                 value;                      /* Center of Subset */
  double                 left;                       /* Sigma, Width, etc. */
  double                 right;                      /* Sigma, Width, etc. */
  double                 degree;                     /* Peak value of Subset */
};

typedef struct FL_memfunc {
  char                   name[FL_MAXNAMELENGTH+1];   /* Name of Memfunc */
  int                    num_subsets;                /* Number of subsets belonging to this MF */
  struct FL_subset      *subset;                     /* Pointer to subsets */
};

typedef struct FL_variable {
  char                 name[FL_MAXNAMELENGTH+1];            /* Name of Variable */
  double               value;                               /* Crisp value of variable */
  double               def;                                 /* default value if no information */
  int                  set;
  char                 memfuncname[FL_MAXNAMELENGTH+1];     /* Name of Variable */
  struct FL_memfunc   *memfunc;
  double              *memship;
};  

enum FL_operator {OP_IS, OP_ISNOT};
enum FL_operand  {OPR_SUBSET, OPR_CONSTANT};

typedef struct FL_condition {
  char                name[FL_MAXNAMELENGTH+1];     /* Name of Condition */
  char                leftname[FL_MAXNAMELENGTH+1];
  struct FL_variable *left;
  enum FL_operator    operator;
  enum FL_operand     operand;
  char                rightname[FL_MAXNAMELENGTH+1];
  char                rightsubname[FL_MAXNAMELENGTH+1];
  double              rightvalue;
  struct FL_subset   *right;
  double              value;
};

typedef struct FL_clause {
  char                 name[FL_MAXNAMELENGTH+1];     /* Name of Clause */
  int                  num_conditions;
  struct FL_condition *condition;
};

typedef struct FL_action {
  char                name[FL_MAXNAMELENGTH+1];     /* Name of Condition */
  char                leftname[FL_MAXNAMELENGTH+1];
  struct FL_variable *left;
  enum FL_operand     operand;
  char                rightname[FL_MAXNAMELENGTH+1];
  char                rightsubname[FL_MAXNAMELENGTH+1];
  double              rightvalue;
  struct FL_subset   *right;
};  

typedef struct FL_rule {
  char                     name[FL_MAXNAMELENGTH+1];
  int                      num_clauses;              /* Number of clauses        */
  struct FL_clause        *clause;                   /* Clauses                  */
  int                      num_actions;              /* Number of assignments    */
  struct FL_action        *action;                   /* Assignments              */
  int                      fired;
  double                   belief;                   /* Degree of belief in rule */
};


enum FL_evalmethod {EVAL_COG,EVAL_AVERAGE,EVAL_MAX};  

typedef struct FL_object {
  char                     name[FL_MAXNAMELENGTH+1];
  enum FL_evalmethod       method;
  int                      num_rules;
  struct FL_rule          *rule;
};

typedef struct FL_system {
  char                     name[FL_MAXNAMELENGTH+1];
  int                      num_variables;
  struct FL_variable      *variable;
  int                      num_memfuncs;
  struct FL_memfunc       *memfunc;
  int                      num_objects;
  struct FL_object        *object;
};

#define FL_INDENTATION_STRING "                                                                "
#define FL_INDENTATION_OFFSET 4

#endif
