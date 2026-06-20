typedef double mtrxtype;

struct Matrix
	{
	uint x;
	uint y;
	mtrxtype *m;
	};

typedef struct Matrix mtrx,*mptr;
typedef mtrxtype vectype;

struct Vector
	{
	uint l;
	vectype *v;
	};

typedef struct Vector vec,*vptr;

mptr create_matrix(uint,uint);
void delete_matrix(mptr);
int copy_matrix(mptr,mptr);
void setelement(mptr,uint,uint,mtrxtype);
mtrxtype getelement(mptr,uint,uint);
void printmatrix(mptr);
mptr sub_matrix(mptr,mptr);
mptr add_matrix(mptr,mptr);
mptr matrix_mult(mptr,mptr);
mptr mulmat(mptr,mtrxtype);
mptr matrix_transpose(mptr);
mptr duplicate_matrix(mptr);
vptr solve(mptr,vptr);
vptr create_vector(uint);
void delete_vector(vptr);
mptr vec2row_mtrx(vptr);
mptr vec2col_mtrx(vptr);
vptr row2vec(mptr,uint);
vptr col2vec(mptr,uint);
int rowexchange(mptr,uint,uint);
mtrxtype determinant(mptr);
void printvector(vptr);
void setrow(mptr,vptr,uint);
void setcol(mptr,vptr,uint);
mptr inverse(mptr);
vptr mult_mtrx_vec(mptr,vptr);
vectype dot_mult(vptr,vptr);

