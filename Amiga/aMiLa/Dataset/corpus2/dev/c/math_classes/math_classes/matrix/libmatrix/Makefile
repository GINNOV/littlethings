


CFLAGS= -O3 -g -ffast-math

CPU = -m68020 -m68881

objs = determinant.o lumat_getl.o lumat_getp.o lumat_getu.o \
	lumat_ludecomp.o lumat_op_assign.o lusolve.o mat_create.o \
	mat_create_int_int.o mat_create_int_int_ptr.o \
	mat_create_mat.o mat_create_pmat.o mat_destr.o \
	mat_getcol.o mat_getrow.o mat_inverse.o mat_print.o mat_op_add.o \
	mat_op_addassign.o mat_op_assign.o mat_op_eq.o mat_op_multassign.o \
	mat_op_mult_dbl_mat.o mat_op_mult_mat_dbl.o mat_op_mult_mat_mat.o \
	mat_op_mult_pmat_mat.o mat_op_neq.o mat_op_sub.o mat_op_subassign.o \
	mat_rxchg.o mat_setcol.o mat_setrow.o mat_setunity.o \
	mat_transpose.o mat_unity.o pmat_create.o \
	pmat_create_int.o pmat_create_pmat.o pmat_destr.o pmat_inverse.o \
	pmat_op_arr.o pmat_op_assign.o pmat_op_index.o \
	pmat_op_mult_pmat_pmat.o pmat_transpose.o solve_lumat.o \
	solve_mat.o swap_mat_mat.o mat_dabs.o
	
all: libmatrix.a

libmatrix.a: $(objs) Matrix.h
	ar cvr libmatrix.a $(objs)
ifdef CPU
	mv libmatrix.a libmatrix.a.020881
else
	mv libmatrix.a libmatrix.a.000
endif
	
	
.cc.o:
	g++ -c $(CFLAGS) $(CPU) $*.cc



