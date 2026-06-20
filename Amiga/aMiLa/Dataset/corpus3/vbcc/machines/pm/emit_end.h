
/* automaticaly generated from the file end.asm do not modify */

static void emit_end(FILE *f)
{
	if(!used_interrupt[15]) {
	emit(f, "%s15:\n", int_handler_prefix);
	used_interrupt[15] = (1);
	}
	emit(f,"\tmovb\t[nn+0x29], (1<<7)\n");
	emit(f,"\ttest\t[nn+0x52], (1<<7)\n");
	emit(f,"\tjnz\tvbcc___noturnoff\n");
	emit(f,"\tcint\t0x24\n");
	emit(f,"vbcc___noturnoff:\n");
	emit(f,"\treti\n");
	emit_unised_irq_labels(f);
	emit(f,"\treti\n");
	emit_mult(f);
	emit_div_mod(f);
}
