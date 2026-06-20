
/* automaticaly generated from the file mult.asm do not modify */

static void emit_mult(FILE *f)
{
	emit(f,"vbcc___mul16x16_16:\n");
	emit(f,"\tpush\thl\n");
	emit(f,"\tmul\tl, a\n");
	emit(f,"\tpush\thl\n");
	emit(f,"\tmov\thl,[sp+3]\n");
	emit(f,"\tmul\tl, a\n");
	emit(f,"\tmov\ta, b\n");
	emit(f,"\tmov\tb, l\n");
	emit(f,"\tmov\thl, [sp+2]\n");
	emit(f,"\tmul\tl, a\n");
	emit(f,"\tmov\ta, l\n");
	emit(f,"\tadd\ta, b\n");
	emit(f,"\tmov\tb, a\n");
	emit(f,"\txor\ta, a\n");
	emit(f,"\tpop\thl\n");
	emit(f,"\tadd\tba, hl\n");
	emit(f,"\tpop\thl\n");
	emit(f,"\tret\n");}
