
/* automaticaly generated from the file div_mod.asm do not modify */

static void emit_div_mod(FILE *f)
{
	emit(f,"vbcc___div_mod16x16_16:\n");
	emit(f,"\tpush\tx\n");
	emit(f,"\tpush\ty\n");
	emit(f,"\tmov\tx, 0\n");
	emit(f,"\tcmp\tba, 0\n");
	emit(f,"\tjns\tvbcc___dm_banotneg\n");
	emit(f,"\tnot\ta\n");
	emit(f,"\tnot\tb\n");
	emit(f,"\tinc\tba\n");
	emit(f,"\tadd\tx, 0x0011\n");
	emit(f,"vbcc___dm_banotneg:\n");
	emit(f,"\txchg\tba, hl\n");
	emit(f,"\tcmp\tba, 0\n");
	emit(f,"\tjns\tvbcc___dm_hlnotneg\n");
	emit(f,"\tnot\ta\n");
	emit(f,"\tnot\tb\n");
	emit(f,"\tinc\tba\n");
	emit(f,"\tinc\tx\n");
	emit(f,"vbcc___dm_hlnotneg:\n");
	emit(f,"\txchg\tba, hl\n");
	emit(f,"\tpush\tx\n");
	emit(f,"\tmov\tx, 0\n");
	emit(f,"\tmov\ty, 1\n");
	emit(f,"vbcc___dm_shiftloop:\n");
	emit(f,"\tshl\ta\n");
	emit(f,"\trolc\tb\n");
	emit(f,"\txchg\tba, x\n");
	emit(f,"\trolc\ta\n");
	emit(f,"\trolc\tb\n");
	emit(f,"\txchg\tba, x\n");
	emit(f,"\tsub\tx, hl\n");
	emit(f,"\tjns\tvbcc___dm_resnotneg\n");
	emit(f,"\tadd\tx, hl\n");
	emit(f,"vbcc___dm_resnotneg:\n");
	emit(f,"\txchg\tba, y\n");
	emit(f,"\trolc\ta\n");
	emit(f,"\trolc\tb\n");
	emit(f,"\txchg\tba, y\n");
	emit(f,"\tjc\tvbcc___dm_done\n");
	emit(f,"\tjmp\tvbcc___dm_shiftloop\n");
	emit(f,"vbcc___dm_done:\n");
	emit(f,"\tpop\tba\n");
	emit(f,"\ttst\ta, 0x10\n");
	emit(f,"\txchg\tba, x\n");
	emit(f,"\tjz\tvbcc___dm_modnotneg\n");
	emit(f,"\tnot\ta\n");
	emit(f,"\tnot\tb\n");
	emit(f,"\tinc\tba\n");
	emit(f,"vbcc___dm_modnotneg:\n");
	emit(f,"\tmov\thl, ba\n");
	emit(f,"\tmov\tba, x\n");
	emit(f,"\ttst\ta, 0x01\n");
	emit(f,"\tmov\tba, y\n");
	emit(f,"\tjz\tvbcc___dm_resnonegate\n");
	emit(f,"\tinc\tba\n");
	emit(f,"\tjmp\tvbcc___dm_resnegate\n");
	emit(f,"vbcc___dm_resnonegate:\n");
	emit(f,"\tnot\tb\n");
	emit(f,"\tnot\ta\n");
	emit(f,"vbcc___dm_resnegate:\n");
	emit(f,"\tpop\ty\n");
	emit(f,"\tpop\tx\n");
	emit(f,"\tret\n");
}
