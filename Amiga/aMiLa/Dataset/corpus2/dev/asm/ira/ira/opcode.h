/*
 * opcode.h
 *
 *  Created on: 07 nov 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : opcode.h
 *      Purpose  : Headers for OpCode manipulation
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2015 Frank Wille, (C)2014-2016 Nicolas Bastien
 */


#ifndef OPCODE_H_
#define OPCODE_H_

void GetOpCode(ira_t *, uint16_t);
void GroupOpCodeByNibble(ira_t *);

#endif /* OPCODE_H_ */
