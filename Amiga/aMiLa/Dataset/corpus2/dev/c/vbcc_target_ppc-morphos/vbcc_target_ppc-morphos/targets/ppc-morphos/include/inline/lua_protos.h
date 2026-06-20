#ifndef _VBCCINLINE_LUA_H
#define _VBCCINLINE_LUA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LuaState* __LuaNewState(void *, LuaAlloc allocfunc, APTR allocdata) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaNewState(allocfunc, allocdata) __LuaNewState(LuaBase, (allocfunc), (allocdata))

void __LuaClose(void *, LuaState* state) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaClose(state) __LuaClose(LuaBase, (state))

LuaState* __LuaNewThread(void *, LuaState* state) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaNewThread(state) __LuaNewThread(LuaBase, (state))

LuaCFunction __LuaAtPanic(void *, LuaState* state, LuaCFunction panicfunc) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaAtPanic(state, panicfunc) __LuaAtPanic(LuaBase, (state), (panicfunc))

LONG __LuaGetTop(void *, LuaState* state) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetTop(state) __LuaGetTop(LuaBase, (state))

void __LuaSetTop(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetTop(state, index) __LuaSetTop(LuaBase, (state), (index))

void __LuaPushValue(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushValue(state, index) __LuaPushValue(LuaBase, (state), (index))

void __LuaRemove(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRemove(state, index) __LuaRemove(LuaBase, (state), (index))

void __LuaInsert(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaInsert(state, index) __LuaInsert(LuaBase, (state), (index))

void __LuaReplace(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaReplace(state, index) __LuaReplace(LuaBase, (state), (index))

LONG __LuaCheckStack(void *, LuaState* state, LONG extraslots) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckStack(state, extraslots) __LuaCheckStack(LuaBase, (state), (extraslots))

void __LuaXMove(void *, LuaState* state, LuaState* state2, LONG index) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaXMove(state, state2, index) __LuaXMove(LuaBase, (state), (state2), (index))

LONG __LuaIsNumber(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaIsNumber(state, index) __LuaIsNumber(LuaBase, (state), (index))

LONG __LuaIsString(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-106(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaIsString(state, index) __LuaIsString(LuaBase, (state), (index))

LONG __LuaIsCFunction(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-112(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaIsCFunction(state, index) __LuaIsCFunction(LuaBase, (state), (index))

LONG __LuaIsUserData(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-118(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaIsUserData(state, index) __LuaIsUserData(LuaBase, (state), (index))

LONG __LuaType(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-124(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaType(state, index) __LuaType(LuaBase, (state), (index))

const char* __LuaTypeName(void *, LuaState* state, LONG typeid) =
	"\tlwz\t0,-130(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaTypeName(state, typeid) __LuaTypeName(LuaBase, (state), (typeid))

LONG __LuaEqual(void *, LuaState* state, LONG index1, LONG index2) =
	"\tlwz\t0,-136(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaEqual(state, index1, index2) __LuaEqual(LuaBase, (state), (index1), (index2))

LONG __LuaRawEqual(void *, LuaState* state, LONG index1, LONG index2) =
	"\tlwz\t0,-142(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRawEqual(state, index1, index2) __LuaRawEqual(LuaBase, (state), (index1), (index2))

LONG __LuaLessThan(void *, LuaState* state, LONG index1, LONG index2) =
	"\tlwz\t0,-148(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaLessThan(state, index1, index2) __LuaLessThan(LuaBase, (state), (index1), (index2))

double __LuaToNumber(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-154(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToNumber(state, index) __LuaToNumber(LuaBase, (state), (index))

LONG __LuaToInteger(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-160(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToInteger(state, index) __LuaToInteger(LuaBase, (state), (index))

LONG __LuaToBoolean(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-166(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToBoolean(state, index) __LuaToBoolean(LuaBase, (state), (index))

const char* __LuaToLString(void *, LuaState* state, LONG index, LONG* length) =
	"\tlwz\t0,-172(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToLString(state, index, length) __LuaToLString(LuaBase, (state), (index), (length))

LONG __LuaObjLen(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-178(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaObjLen(state, index) __LuaObjLen(LuaBase, (state), (index))

LuaCFunction __LuaToCFunction(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-184(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToCFunction(state, index) __LuaToCFunction(LuaBase, (state), (index))

APTR __LuaToUserData(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-190(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToUserData(state, index) __LuaToUserData(LuaBase, (state), (index))

LuaState* __LuaToThread(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-196(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToThread(state, index) __LuaToThread(LuaBase, (state), (index))

CONST_APTR __LuaToPointer(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-202(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaToPointer(state, index) __LuaToPointer(LuaBase, (state), (index))

void __LuaPushNil(void *, LuaState* state) =
	"\tlwz\t0,-208(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushNil(state) __LuaPushNil(LuaBase, (state))

void __LuaPushNumber(void *, LuaState* state, double number) =
	"\tlwz\t0,-214(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushNumber(state, number) __LuaPushNumber(LuaBase, (state), (number))

void __LuaPushInteger(void *, LuaState* state, LONG number) =
	"\tlwz\t0,-220(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushInteger(state, number) __LuaPushInteger(LuaBase, (state), (number))

void __LuaPushLString(void *, LuaState* state, const char* string, LONG length) =
	"\tlwz\t0,-226(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushLString(state, string, length) __LuaPushLString(LuaBase, (state), (string), (length))

void __LuaPushString(void *, LuaState* state, const char* string) =
	"\tlwz\t0,-232(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushString(state, string) __LuaPushString(LuaBase, (state), (string))

const char* __LuaPushFString(void *, LuaState* state, const char* fmt, ...) =
	"\tlwz\t0,-244(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushFString(state, ...) __LuaPushFString(LuaBase, (state), __VA_ARGS__)

void __LuaPushCClosure(void *, LuaState* state, LuaCFunction cfunc, LONG numvals) =
	"\tlwz\t0,-250(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushCClosure(state, cfunc, numvals) __LuaPushCClosure(LuaBase, (state), (cfunc), (numvals))

void __LuaPushBoolean(void *, LuaState* state, LONG boolean) =
	"\tlwz\t0,-256(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushBoolean(state, boolean) __LuaPushBoolean(LuaBase, (state), (boolean))

void __LuaPushLightUserData(void *, LuaState* state, APTR udata) =
	"\tlwz\t0,-262(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushLightUserData(state, udata) __LuaPushLightUserData(LuaBase, (state), (udata))

LONG __LuaPushThread(void *, LuaState* state) =
	"\tlwz\t0,-268(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPushThread(state) __LuaPushThread(LuaBase, (state))

void __LuaGetTable(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-274(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetTable(state, index) __LuaGetTable(LuaBase, (state), (index))

void __LuaGetField(void *, LuaState* state, LONG index, const char* key) =
	"\tlwz\t0,-280(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetField(state, index, key) __LuaGetField(LuaBase, (state), (index), (key))

void __LuaRawGet(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-286(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRawGet(state, index) __LuaRawGet(LuaBase, (state), (index))

void __LuaRawGetI(void *, LuaState* state, LONG index, LONG key) =
	"\tlwz\t0,-292(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRawGetI(state, index, key) __LuaRawGetI(LuaBase, (state), (index), (key))

void __LuaCreateTable(void *, LuaState* state, LONG numelems, LONG numrecs) =
	"\tlwz\t0,-298(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCreateTable(state, numelems, numrecs) __LuaCreateTable(LuaBase, (state), (numelems), (numrecs))

APTR __LuaNewUserData(void *, LuaState* state, LONG size) =
	"\tlwz\t0,-304(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaNewUserData(state, size) __LuaNewUserData(LuaBase, (state), (size))

LONG __LuaGetMetaTable(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-310(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetMetaTable(state, index) __LuaGetMetaTable(LuaBase, (state), (index))

void __LuaGetFEnv(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-316(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetFEnv(state, index) __LuaGetFEnv(LuaBase, (state), (index))

void __LuaSetTable(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-322(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetTable(state, index) __LuaSetTable(LuaBase, (state), (index))

void __LuaSetField(void *, LuaState* state, LONG index, const char* key) =
	"\tlwz\t0,-328(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetField(state, index, key) __LuaSetField(LuaBase, (state), (index), (key))

void __LuaRawSet(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-334(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRawSet(state, index) __LuaRawSet(LuaBase, (state), (index))

void __LuaRawSetI(void *, LuaState* state, LONG index, LONG key) =
	"\tlwz\t0,-340(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRawSetI(state, index, key) __LuaRawSetI(LuaBase, (state), (index), (key))

LONG __LuaSetMetaTable(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-346(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetMetaTable(state, index) __LuaSetMetaTable(LuaBase, (state), (index))

LONG __LuaSetFEnv(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-352(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetFEnv(state, index) __LuaSetFEnv(LuaBase, (state), (index))

void __LuaCall(void *, LuaState* state, LONG numagrs, LONG numresults) =
	"\tlwz\t0,-358(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCall(state, numagrs, numresults) __LuaCall(LuaBase, (state), (numagrs), (numresults))

LONG __LuaPCall(void *, LuaState* state, LONG numargs, LONG numresults, LONG errfindex) =
	"\tlwz\t0,-364(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaPCall(state, numargs, numresults, errfindex) __LuaPCall(LuaBase, (state), (numargs), (numresults), (errfindex))

LONG __LuaCPCall(void *, LuaState* state, LuaCFunction func, APTR userdata) =
	"\tlwz\t0,-370(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCPCall(state, func, userdata) __LuaCPCall(LuaBase, (state), (func), (userdata))

LONG __LuaLoad(void *, LuaState* state, LuaReader reader, APTR rdata, const char* name) =
	"\tlwz\t0,-376(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaLoad(state, reader, rdata, name) __LuaLoad(LuaBase, (state), (reader), (rdata), (name))

LONG __LuaDump(void *, LuaState* state, LuaWriter writer, APTR data) =
	"\tlwz\t0,-382(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaDump(state, writer, data) __LuaDump(LuaBase, (state), (writer), (data))

LONG __LuaYield(void *, LuaState* state, LONG numresults) =
	"\tlwz\t0,-388(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaYield(state, numresults) __LuaYield(LuaBase, (state), (numresults))

LONG __LuaResume(void *, LuaState* state, LONG numargs) =
	"\tlwz\t0,-394(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaResume(state, numargs) __LuaResume(LuaBase, (state), (numargs))

LONG __LuaStatus(void *, LuaState* state) =
	"\tlwz\t0,-400(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaStatus(state) __LuaStatus(LuaBase, (state))

LONG __LuaGC(void *, LuaState* state, LONG action, LONG data) =
	"\tlwz\t0,-406(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGC(state, action, data) __LuaGC(LuaBase, (state), (action), (data))

LONG __LuaError(void *, LuaState* state) =
	"\tlwz\t0,-412(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaError(state) __LuaError(LuaBase, (state))

LONG __LuaNext(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-418(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaNext(state, index) __LuaNext(LuaBase, (state), (index))

void __LuaConcat(void *, LuaState* state, LONG numvals) =
	"\tlwz\t0,-424(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaConcat(state, numvals) __LuaConcat(LuaBase, (state), (numvals))

LuaAlloc __LuaGetAllocF(void *, LuaState* state, APTR* storage) =
	"\tlwz\t0,-430(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetAllocF(state, storage) __LuaGetAllocF(LuaBase, (state), (storage))

void __LuaSetAllocF(void *, LuaState* state, LuaAlloc allocfunc, APTR allocdata) =
	"\tlwz\t0,-436(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetAllocF(state, allocfunc, allocdata) __LuaSetAllocF(LuaBase, (state), (allocfunc), (allocdata))

LONG __LuaGetStack(void *, LuaState* state, LONG depth, struct LuaDebug* debug) =
	"\tlwz\t0,-442(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetStack(state, depth, debug) __LuaGetStack(LuaBase, (state), (depth), (debug))

LONG __LuaGetInfo(void *, LuaState* state, const char* itemname, struct LuaDebug* debug) =
	"\tlwz\t0,-448(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetInfo(state, itemname, debug) __LuaGetInfo(LuaBase, (state), (itemname), (debug))

const char* __LuaGetLocal(void *, LuaState* state, const struct LuaDebug* debug, LONG index) =
	"\tlwz\t0,-454(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetLocal(state, debug, index) __LuaGetLocal(LuaBase, (state), (debug), (index))

const char* __LuaSetLocal(void *, LuaState* state, const struct LuaDebug* debug, LONG index) =
	"\tlwz\t0,-460(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetLocal(state, debug, index) __LuaSetLocal(LuaBase, (state), (debug), (index))

const char* __LuaGetUpValue(void *, LuaState* state, LONG index, LONG upvalnum) =
	"\tlwz\t0,-466(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetUpValue(state, index, upvalnum) __LuaGetUpValue(LuaBase, (state), (index), (upvalnum))

const char* __LuaSetUpValue(void *, LuaState* state, LONG index, LONG upvalnum) =
	"\tlwz\t0,-472(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetUpValue(state, index, upvalnum) __LuaSetUpValue(LuaBase, (state), (index), (upvalnum))

LONG __LuaSetHook(void *, LuaState* state, LuaHook hook, LONG mask, LONG count) =
	"\tlwz\t0,-478(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetHook(state, hook, mask, count) __LuaSetHook(LuaBase, (state), (hook), (mask), (count))

LuaHook __LuaGetHook(void *, LuaState* state) =
	"\tlwz\t0,-484(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetHook(state) __LuaGetHook(LuaBase, (state))

LONG __LuaGetHookMask(void *, LuaState* state) =
	"\tlwz\t0,-490(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetHookMask(state) __LuaGetHookMask(LuaBase, (state))

LONG __LuaGetHookCount(void *, LuaState* state) =
	"\tlwz\t0,-496(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetHookCount(state) __LuaGetHookCount(LuaBase, (state))

void __LuaRegisterModule(void *, LuaState* state, const char* modname, const LuaLibReg* modtable) =
	"\tlwz\t0,-502(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaRegisterModule(state, modname, modtable) __LuaRegisterModule(LuaBase, (state), (modname), (modtable))

double __LuaCheckNumber(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-508(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckNumber(state, index) __LuaCheckNumber(LuaBase, (state), (index))

const char* __LuaCheckLString(void *, LuaState* state, LONG index, LONG* length) =
	"\tlwz\t0,-514(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckLString(state, index, length) __LuaCheckLString(LuaBase, (state), (index), (length))

LONG __LuaCheckInteger(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-520(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckInteger(state, index) __LuaCheckInteger(LuaBase, (state), (index))

LONG __LuaOptInteger(void *, LuaState* state, LONG index, LONG d0arg) =
	"\tlwz\t0,-526(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaOptInteger(state, index, d0arg) __LuaOptInteger(LuaBase, (state), (index), (d0arg))

void __LuaErrorF(void *, LuaState* state, const char* fmt, ...) =
	"\tlwz\t0,-532(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaErrorF(state, ...) __LuaErrorF(LuaBase, (state), __VA_ARGS__)

void __LuaCheckAny(void *, LuaState* state, LONG index) =
	"\tlwz\t0,-538(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckAny(state, index) __LuaCheckAny(LuaBase, (state), (index))

BOOL __LuaCallMeta(void *, LuaState* state, LONG index, const char* method) =
	"\tlwz\t0,-544(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCallMeta(state, index, method) __LuaCallMeta(LuaBase, (state), (index), (method))

void __LuaWhere(void *, LuaState* state, LONG level) =
	"\tlwz\t0,-550(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaWhere(state, level) __LuaWhere(LuaBase, (state), (level))

void __LuaCheckType(void *, LuaState* state, LONG index, LONG type) =
	"\tlwz\t0,-556(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckType(state, index, type) __LuaCheckType(LuaBase, (state), (index), (type))

const char* __LuaOptLString(void *, LuaState* state, LONG index, const char* def, LONG* length) =
	"\tlwz\t0,-562(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaOptLString(state, index, def, length) __LuaOptLString(LuaBase, (state), (index), (def), (length))

LONG __LuaArgError(void *, LuaState* state, LONG numarg, const char* msg) =
	"\tlwz\t0,-568(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaArgError(state, numarg, msg) __LuaArgError(LuaBase, (state), (numarg), (msg))

BOOL __LuaGetMetaField(void *, LuaState* state, LONG index, const char* field) =
	"\tlwz\t0,-574(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaGetMetaField(state, index, field) __LuaGetMetaField(LuaBase, (state), (index), (field))

LONG __LuaCheckOption(void *, LuaState* state, LONG numarg, const char* def, const char** list) =
	"\tlwz\t0,-580(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckOption(state, numarg, def, list) __LuaCheckOption(LuaBase, (state), (numarg), (def), (list))

APTR __LuaCheckUData(void *, LuaState* state, LONG numarg, const char* type) =
	"\tlwz\t0,-586(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaCheckUData(state, numarg, type) __LuaCheckUData(LuaBase, (state), (numarg), (type))

BOOL __LuaNewMetaTable(void *, LuaState* state, const char* type) =
	"\tlwz\t0,-592(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaNewMetaTable(state, type) __LuaNewMetaTable(LuaBase, (state), (type))

void __LuaSetLevel(void *, LuaState* state, LuaState* thread) =
	"\tlwz\t0,-598(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LuaSetLevel(state, thread) __LuaSetLevel(LuaBase, (state), (thread))

#endif /*  _VBCCINLINE_LUA_H  */
