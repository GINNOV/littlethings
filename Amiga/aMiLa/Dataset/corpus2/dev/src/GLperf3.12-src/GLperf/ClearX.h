/*
 * File ClearX.h generated from ClearG (source file ClearG.c)
 */

void Clear1(TestPtr);
void ClearPoint1(TestPtr);
void Noop(TestPtr);
typedef void (*ExecuteFunc)(TestPtr);

ExecuteFunc ClearExecuteTable[] = {
    Clear1,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    ClearPoint1,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
    Noop,
};
