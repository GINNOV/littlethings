# 16.03.2011
# The following command can be used to assemble this source:
#
#	vasmppc_std -Felf -o ram:hw.o HelloWorld_optimised.s
#
# Linking is necessary to generate an executable:
#
#	vlink -s -P__abox__ -o ram:hw ram:hw.o -lamiga
#
# Remove the -s option to preserve all symbols.  In this case, -P__abox__ won't be necessary either.  

# EmulHandle structure (always pointed to by r2).  
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

# Stack frame offsets.  
.set	stack_pos0_caller_stack,0		#The initialisation of a new stack frame with stwu r1,-size(r1) places a pointer to the caller's stack frame at this position.
.set	stack_pos1_callerLR,4			#The above .set directive and definition isn't really needed but is included for illustrative purposes.
.set	stack_pos2_DosBase,8
.set	stack_pos3_ExecBase,12
.set	stack_pos4_EmulCallDirectOS,16
.set	stack_pos5_through_7_initial_nonvolatiles,20

.set	new_8_word_stack,32			#Eight word stack frame with positions 0 through 7, all of which are used by this program.

.set	_AbsExecBase,4

.text						#The .text directive tells the assembler to create the .text section and, in this case, marks the...
						#beginning of this program's instructions.  Further explanation of sections in the discussion of objdump.
	mflr	r0
	stw	r0,stack_pos1_callerLR(r1)	#Caller's return address is placed in the caller's stack frame.
	stwu	r1,-new_8_word_stack(r1)	#PPC stack space is typically used by starting at the end (or larger address) and working backwards.  

	stmw	r29,stack_pos5_through_7_initial_nonvolatiles(r1)	#Store multiple words requires a word alligned destination address and stores all registers from the one given up to and including r31.  

	lwz	r31,EmulCallDirectOS(r2)	#r31 = value at EmulHandle + EmulCallDirectOS

	li	r30,_AbsExecBase
	lwz	r30,0(r30)			#r30 = ExecBase

	mtctr	r31				#CTR = r31 = EmulCallDirectOS
	stw	r30,reg_a6(r2)			#LVOOpenLibrary is an Exec library function so Execbase is stored in EmulHandle reg_a6.  
	lis	r3,DosName@ha
	addi	r3,r3,DosName@l
	stw	r3,reg_a1(r2)			#LVOOpenLibrary argument specifying library name stored in EmulHandle reg_a1.  
	li	r3,0
	stw	r3,reg_d0(r2)			#Argument specifying the minimum library version stored in EmulHandle reg_d0.  
	li	r3,LVOOpenLibrary		#LVOOpenLibrary function number passed in GPR 3
	bctrl					#Branch to CTR and place a return address to this program in LR.

#	cmpwi	r3,0				#Compare word immediate.  Result: compare r3 to a 16 bit immediate value - in this case, zero.  If the two operands of cmpwi are the same, the Zero condition will be true.
	mr.	r29,r3				#Move Register.  This is a simplified PPC instruction mnemonic.  The full stop indicates that some conditions will be set.  
	beq	exit				#Branch if equal to zero.  This is one of many conditional branch instructions.  The Dos library base pointer should have been returned in r3, if not, branch to exit.  

	stmw	r29,stack_pos2_DosBase(r1)	#Storing the values in these registers is not really necessary for this program but it's a good practice.  

	mtctr	r31
	stw	r29,reg_a6(r2)			#LVOVPrintf is a Dos library function so DosBase is stored in EmulHandle reg_a6.  
	lis	r3,string1@ha
	addi	r3,r3,string1@l
	stw	r3,reg_d1(r2)			#LVOVPrintf argument specifying start address of the ascii string to be output.  
	li	r3,0
	stw	r3,reg_d2(r2)			#Additional LVOVPrintf argument not required here so its value is set to zero.  
	li	r3,LVOVPrintf			#LVOVPrintf function number passed in GPR 3.  
	bctrl

	mtctr	r31
	stw	r30,reg_a6(r2)			#LVOCloseLibrary is an Exec library function.  
	stw	r29,reg_a1(r2)			#LVOCloseLibrary argument specifying the library to be closed.  
	li	r3,LVOCloseLibrary		#LVOCloseLibrary function number passed in GPR 3.  
	bctrl

	lmw	r29,stack_pos5_through_7_initial_nonvolatiles(r1)	#Load multiple words also requires a word alligned source address and loads all registers from the one given up to and including r31.  
									#Unlike stmw, care must be taken not to overwrite the register used to address the source data, in this case, r1.  
	li	r3,0				#Shell return code = 0 indicating no error.

exit:	addi	r1,r1,new_8_word_stack		#'Undo' the creation of this program's stack frame.  r1 now points to the caller's stack frame.
	lwz	r0,stack_pos1_callerLR(r1)	#r0 = caller's return address.			# Note that use of the mtlr & blr instructions have been avoided
	mtlr	r0				#Move to LR.  Link register = r0		# until now as some PPC cpus may have performance optimisations
	blr					#Branch to LR.  Program terminates here.	# that can be degraded from their constant use in function calls.  

.rodata						#.rodata means 'read only data' and it's a common section name in ELFs.  At this time, MorphOS won't prevent this 'read only data' from being written to.

.global	__abox__				#__abox__ is a special MorphOS symbol that will differentiate this program from other PPC executables that can run on MorphOS...
__abox__:					#When linking, care should be taken to avoid having this symbol stripped.  This is the correct way to ensure that the MorphOS ELF loader recognises this program as a...
.word	1					#native, MorphOS executable.  The value stored after '.word' can be changed and other sections can be used to declare this symbol.  Declaring __abox__ is particularly...
.type	__abox__,@object			#important for programs that start from Ambient via an icon and attempt to use the Ambient / Workbench initialisation message.  
.size	__abox__,4				#Please see the vasm documentation for the meaning of the directives - .global .word .type .size and @object.  

DosName:
.string	"dos.library"

string1:					#The '\n' at end of "Hello World\n" is an escape sequence recognised by the assembler which means 'new line'.  There are other escape sequences listed in the vasm documentation.  
.string "Hello World\n"				#Remember, .string automatically appends a zero to the end of the string to show _LVOVPrintf (and other functions) where the string ends.  