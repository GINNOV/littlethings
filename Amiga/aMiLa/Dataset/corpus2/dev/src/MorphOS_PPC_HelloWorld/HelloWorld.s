# 22.01.2011
# The following command can be used to assemble this source:
#
#	vasmppc_std -Felf -o ram:hw.o HelloWorld.s
#
# Linking is optional but can be done this way:
#
#	vlink -s -P__abox__ -o ram:hw ram:hw.o
#
# Remove the -s option to preserve all symbols.  In this case, -P__abox__ won't be necessary either.  

# Various library function offsets
.set	_LVOOpenLibrary,-552			#.set is an assembler directive that defines a name and value...
.set	_LVOCloseLibrary,-414			#it's use here is intended to make the rest of the source code easier to read.
.set	_LVOVPrintf,-954

.set	_AbsExecBase,4

# EmulHandle structure (always pointed to by r2)
.set	reg_d0,0
.set	reg_d1,4
.set	reg_d2,8
.set	reg_d3,12
.set	reg_d4,16
.set	reg_d5,20
.set	reg_d6,24
.set	reg_d7,28
.set	reg_a0,32
.set	reg_a1,36
.set	reg_a2,40
.set	reg_a3,44
.set	reg_a4,48
.set	reg_a5,52
.set	reg_a6,56
.set	reg_a7,60
.set	EmulCallDirectOS,100

# Stack frame offsets
.set	stack_pos0_caller_stack,0		#the initialisation of a new stack frame with stwu r1,-size(r1) places a pointer to the caller's stack frame at this position.
.set	stack_pos1_callerLR,4			#the above .set directive and definition isn't really needed but is included for illustrative purposes.
.set	stack_pos2_ExecBase,8
.set	stack_pos3_DosBase,12
.set	new_4_word_stack,16			#four word stack frame with positions 0 through 3, all of which are used by this program.

.text						#the .text directive tells the assembler to create the .text section and, in this case, marks the...
						#beginning of this program's instructions.  Further explanation of sections in the discussion of objdump.
	mflr	r0
	stw	r0,stack_pos1_callerLR(r1)	#caller's return address is placed in the caller's stack frame.
	stwu	r1,-new_4_word_stack(r1)

	lis	r3,dosName@ha
	addi	r3,r3,dosName@l
	stw	r3,reg_a1(r2)			#_LVOOpenLibrary argument specifying library name stored in EmulHandle reg_a1
	li	r3,0
	stw	r3,reg_d0(r2)			#argument specifying minimum library version stored in EmuHandle reg_d0
	li	r3,_AbsExecBase
	lwz	r3,0(r3)			#r3 = ExecBase
	stw	r3,stack_pos2_ExecBase(r1)	#this makes later use of the Exec library base pointer slightly easier.
	stw	r3,reg_a6(r2)			#_LVOOpenLibrary is an Exec library function so Execbase is stored in EmuHandle reg_a6
	li	r3,_LVOOpenLibrary		#_LVOOpenLibrary function number passed in GPR 3
	lwz	r0,EmulCallDirectOS(r2)		#r0 = value at EmulHandle + EmulCallDirectOS
	mtctr	r0				#CTR = r0
	bctrl					#branch to CTR and place a return address to this program in LR.

	cmpwi	r3,0				#compare word immediate.  Result: compare r3 to a 16 bit immediate value - in this case, zero.  If the two operands of cmpwi are the same, the Zero condition will be true.
	beq	exit				#branch if equal to zero.  This is one of many conditional branch instructions.  The Dos library base pointer should have been returned in r3, if not, branch to exit

	stw	r3,stack_pos3_DosBase(r1)	#typically, library base pointers need to be stored somewhere for later use...
						#but, in this case, DosBase is being used very soon.
	lis	r4,string1@ha
	addi	r4,r4,string1@l
	stw	r4,reg_d1(r2)			#_LVOVPrintf argument specifying start address of string to be output.
	li	r4,0
	stw	r4,reg_d2(r2)			#additional _LVOVPrintf argument not required here so it's value is set to zero.
	stw	r3,reg_a6(r2)			#_LVOVPrintf is a Dos library function so DosBase is stored in EmulHandle reg_a6
	li	r3,_LVOVPrintf			#_LVOVPrintf function number passed in GPR 3
	lwz	r0,EmulCallDirectOS(r2)
	mtctr	r0
	bctrl

	lwz	r3,stack_pos3_DosBase(r1)
	stw	r3,reg_a1(r2)			#_LVOCloseLibrary argument specifying library to be closed.
	lwz	r3,stack_pos2_ExecBase(r1)
	stw	r3,reg_a6(r2)			#_LVOCloseLibrary is an Exec library function.
	li	r3,_LVOCloseLibrary		#_LVOCloseLibrary function number passed in GPR 3
	lwz	r0,EmulCallDirectOS(r2)
	mtctr	r0
	bctrl

	li	r3,0				#shell return code = 0 indicating no error.

exit:	addi	r1,r1,new_4_word_stack		#'undo' the creation of this program's stack frame.  r1 now points to the caller's stack frame.
	lwz	r0,stack_pos1_callerLR(r1)	#r0 = caller's return address.			# Note that use of the mtlr & blr instructions have been avoided
	mtlr	r0				#move to LR.  Link register = r0		# until now as some PPC cpus may have performance optimisations
	blr					#branch to LR.  Program terminates here.	# that can be degraded from their constant use in function calls.

.rodata						#.rodata means 'read only data' and it's a common section name in ELFs.  At this time, MorphOS won't prevent this 'read only data' from being written to.

.global	__abox__				#__abox__ is a special MorphOS symbol that will differentiate this program from other PPC executables that can run on MorphOS...
__abox__:					#When linking, care should be taken to avoid having this symbol stripped.  This is the correct way to ensure that the MorphOS ELF loader recognises this program as a 
.word	1					#native, MorphOS executable.  The value stored after '.word' can be changed and other sections can be used to declare this symbol.  Declaring __abox__ is particularly 
.type	__abox__,@object			#important for programs that start from Ambient via an icon and attempt to use the Ambient / Workbench initialisation message.  
.size	__abox__,4				#Please see the vasm documentation for the meaning of the directives - .global .word .type and .size

dosName:
.string	"dos.library"

string1:					#the '\n' at end of "Hello World\n" is an escape sequence recognised by the assembler which means 'new line'.  There are other escape sequences listed in the vasm documentation.
.string "Hello World\n"				#Remember, .string automatically appends a zero to the end of the string to show _LVOVPrintf (and other functions) where the string ends.