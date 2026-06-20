#ifndef _VBCCINLINE_NEURALNET_H
#define _VBCCINLINE_NEURALNET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

NEURALNET __NN_CreateA(void *, ULONG inputlayers, ULONG hiddenlayers, ULONG outputlayers, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define NN_CreateA(inputlayers, hiddenlayers, outputlayers, tags) __NN_CreateA(NeuralBase, (inputlayers), (hiddenlayers), (outputlayers), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
NEURALNET __linearvarargs __NN_Create(void *, ULONG inputlayers, ULONG hiddenlayers, ULONG outputlayers, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define NN_Create(inputlayers, hiddenlayers, outputlayers, ...) __NN_Create(NeuralBase, (inputlayers), (hiddenlayers), (outputlayers), __VA_ARGS__)
#endif

VOID __NN_Delete(void *, NEURALNET net) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define NN_Delete(net) __NN_Delete(NeuralBase, (net))

VOID __NN_Reset(void *, NEURALNET net) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define NN_Reset(net) __NN_Reset(NeuralBase, (net))

VOID __NN_Recall(void *, NEURALNET net) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define NN_Recall(net) __NN_Recall(NeuralBase, (net))

VOID __NN_SetInputNeuron(void *, NEURALNET net, ULONG id, NEURON value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define NN_SetInputNeuron(net, id, value) __NN_SetInputNeuron(NeuralBase, (net), (id), (value))

VOID __NN_SetOutputNeuron(void *, NEURALNET net, ULONG id, NEURON value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define NN_SetOutputNeuron(net, id, value) __NN_SetOutputNeuron(NeuralBase, (net), (id), (value))

NEURON __NN_GetOutputNeuron(void *, NEURALNET net, ULONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define NN_GetOutputNeuron(net, id) __NN_GetOutputNeuron(NeuralBase, (net), (id))

VOID __NN_SetInputLayer(void *, NEURALNET net, APTR array) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define NN_SetInputLayer(net, array) __NN_SetInputLayer(NeuralBase, (net), (array))

VOID __NN_SetOutputLayer(void *, NEURALNET net, APTR array) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define NN_SetOutputLayer(net, array) __NN_SetOutputLayer(NeuralBase, (net), (array))

VOID __NN_GetOutputLayer(void *, NEURALNET net, APTR array) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define NN_GetOutputLayer(net, array) __NN_GetOutputLayer(NeuralBase, (net), (array))

void * __NN_Clone(void *, NEURALNET net) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define NN_Clone(net) __NN_Clone(NeuralBase, (net))

BOOL __NN_LoadA(void *, NEURALNET net, STRPTR filename, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define NN_LoadA(net, filename, tags) __NN_LoadA(NeuralBase, (net), (filename), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __NN_Load(void *, NEURALNET net, STRPTR filename, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define NN_Load(net, filename, ...) __NN_Load(NeuralBase, (net), (filename), __VA_ARGS__)
#endif

BOOL __NN_SaveA(void *, NEURALNET net, STRPTR filename, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define NN_SaveA(net, filename, tags) __NN_SaveA(NeuralBase, (net), (filename), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __NN_Save(void *, NEURALNET net, STRPTR filename, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define NN_Save(net, filename, ...) __NN_Save(NeuralBase, (net), (filename), __VA_ARGS__)
#endif

VOID __NN_Train(void *, NEURALNET net, FLOAT * errorptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define NN_Train(net, errorptr) __NN_Train(NeuralBase, (net), (errorptr))

VOID __NN_SetAttrsA(void *, NEURALNET net, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define NN_SetAttrsA(net, tags) __NN_SetAttrsA(NeuralBase, (net), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __NN_SetAttrs(void *, NEURALNET net, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define NN_SetAttrs(net, ...) __NN_SetAttrs(NeuralBase, (net), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_NEURALNET_H  */
