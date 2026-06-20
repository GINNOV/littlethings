#ifndef _tlcs900_h_included
#define _tlcs900_h_included

//

#include <string>
#include <strstream>
#include "dissasm.h"
#include "conv.h"
#include "masker.h"
//
//

class TLCS900 : virtual public Dissasm, public MaskTLCS900 {
private:
	string _name;
	string _tmp;
	string _opf;
	string _ops;

	const string _retString( Int2NN& i ) {
		string s; s.assign(i.str());
		return s;
	}
private:
	static const char* opcode_names[];
	static const char* R8_names[];
	static const char* R16_names[];
	static const char* R32_names[];
	static const char* r8_names[];
	static const char* r16_names[];
	static const char* r32_names[];
	static const char* addr_names[];
	static const char* cc_names[];
	static const char* cr_names[];
private:
	int _retMem( int, Mem&, string& ) const;
	int _decodeFixed( Mem& );
	int _decodeVariable( Mem& );
	int _decodeB0_mem( Mem&, int );
	int _decodexx( Mem&, int, int );
	int _decodezz_mem( Mem&, int, int );
	int _decodezz_r( Mem&, int, int );
	int _decodezz_R( Mem&, int, int );
public:
	TLCS900() { _name.assign("TLCS900"); }
	~TLCS900() {}

	//

	int decode( Mem& ) { return 0; }
	const char* getFirst() { return _opf.c_str(); }
	const char* getSecond() { return _ops.c_str(); }
	const char* getName() { return _name.c_str(); }

	//

//	friend ostream& operator<<( ostream& o, TLCS900& t ) {
//		o << t.print();
//		return o;
//	}
};





enum opcodes {
	// load
	LD=0,	PUSH,	POP,	LDA,	LDAR,

	// exchange
	EX,		MIRR,

	// load inc/load dec & compare inc/dec
	LDI,	LDIR,	LDD,	LDDR,	CPI,	CPIR,	CPD,	CPDR,

	// arithmetic instructions

	ADD,	ADC,	SUB,	SBC,	CP,		INC,	DEC,	NEG,
	EXTZ,	EXTS,	DAA,	PAA,	MUL,	MULS,	DIV,	DIVS,
	MULA,	MINC,	MDEC,

	// logical operations
	AND,	OR,		XOR,	CPL,

	// bit operations
	LDCF,	STCF,	ANDCF,	ORCF,	XORCF,	RCF,	SCF,	CCF,
	ZCF,	BIT,	RES,	SET,	CHG,	TSET,	BS1,

	// special operations and CPU commands
	NOP,	EI,		DI,		PUSH_SR,POP_SR,	SWI,	HALT,	LDC,
	LDX,	LINK,	UNLK,	LDF,	INCF,	DECF,	SCC,

	// rotate and shift
	RLC,	RRC,	RL,		RR,		SLA,	SRA,	SLL,	SRL,
	RLD,	RRD,

	// jump, call, and return
	JP,		JR,		JRL,	CALL,	CALR,	DJNZ,	RET,	RETD
};

enum maddressingmode_numbers {
	ARI_XWA=0,ARI_XBC,ARI_XDE,ARI_XHL,ARI_XIX,ARI_XIY,ARI_XIZ,ARI_XSP,
	ARID_XWA,ARID_XBC,ARID_XDE,ARID_XHL,ARID_XIX,ARID_XIY,ARID_XIZ,ARID_XSP,
	ABS_B,ABS_W,ABS_L,
	ARI,
	ARI_PD,ARI_PI
};






#endif