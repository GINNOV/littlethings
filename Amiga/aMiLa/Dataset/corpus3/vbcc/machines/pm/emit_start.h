
/* automaticaly generated from the file start.asm do not modify */

static void emit_start(FILE *f)
{
	emit(f,".org 0x2100\n");
	emit(f,".db \"MN\"\n");
	emit_irq_vectors(f);
	emit(f,".orgfill 0x21A4\n");
	emit(f,".db \"NINTENDO\"\n");
	emit(f,".db \"%s\"\n", game_id);
	emit(f,".db \"%s\"\n", game_name);
	emit(f,".orgfill 0x21BC\n");
	emit(f,".db \"2P\"\n");
	emit(f,".orgfill 0x21D0\n");
	emit(f,"vbcc___start_rom_vars:\n");
	emit(f,".org 0x1000\n");
	emit(f,"vbcc___start_ram_vars:\n");
	emit(f,".org 0x2000\n");
	emit(f,"vbcc___end_ram_vars:\n");
	emit(f,".org 0x31D0\n");
	emit(f,".equ  vbcc___ram_vars_offset %d - 0x1000\n", start_ram_vars);
	emit(f, "%s0:\n", int_handler_prefix);
	emit(f,"\tmov\t\tx, vbcc___start_rom_vars + vbcc___ram_vars_offset\n");
	emit(f,"\tmov\t\ty, vbcc___start_ram_vars + vbcc___ram_vars_offset\n");
	emit(f,"\tmov\t\thl, vbcc___end_ram_vars\n");
	emit(f,"vbcc__copy_vars_loop:\n");
	emit(f,"\tmov\t\ta,[x]\n");
	emit(f,"\tmov\t\t[y],a\n");
	emit(f,"\tinc\t\tx\n");
	emit(f,"\tinc\t\ty\n");
	emit(f,"\tcmp\t\thl, y\n");
	emit(f,"\tjnz\t\tvbcc__copy_vars_loop\n");
	emit(f,"\tmovw\tsp, 0x2000\n");
	emit(f,"\tmovw\tnn, 0x2000\n");
	emit(f,"\tmovb\t[nn+0x21], 0x0C\n");
	emit(f,"\tmovb\t[nn+0x25], (1<<7)\n");
	emit(f,"\tmovb\tflags, 0\n");
	emit(f,"\tmovb\t[nn+0x80], 0b00001000\n");
	emit(f,"\tmovb\t[nn+0x81], 0b00001001\n");
	emit(f,"\tcall\tmain\n");
	emit(f,"vbcc___infinite_loop:\n");
	emit(f,"\tjmp\tvbcc___infinite_loop\n");
}
