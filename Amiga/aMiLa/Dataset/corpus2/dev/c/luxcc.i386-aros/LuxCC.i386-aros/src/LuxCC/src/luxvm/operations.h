#ifndef OPERATIONS_H_
#define OPERATIONS_H_

typedef struct Operation Operation;
struct Operation {
    char *str;
    int opcode;
    int has_operand;
};

Operation *lookup_operation(char *op_str);

#endif
