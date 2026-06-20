# rgb15 to ham6 c2p converter. 
# written by Jacek Cybularczyk (aka Noe / Venus Art)
 


                .include macros.i

		.text
##############################################################################
# RGB15 to HAM6 converter for non-interleaved planes
# Optimized for two Integer Units (like in MPC604)
#
# IN:
# r3	pointer to rgb15 buffer (allocated on 32-byte boundary for better performance)
# r4	pointer to table of plane pointers (planes[4])
# r5	width (aligned to 16 pixels)
# r6	height
# OUT:
# none

		.extern	RGB15_TO_HAM6_NI
		.extern	_RGB15_TO_HAM6_NI

		.align	4

_RGB15_TO_HAM6_NI:
RGB15_TO_HAM6_NI:
		subi	r1,r1,(32-17)*4
		stmw	r17,0(r1)

		srwi	r5,r5,4
		mullw	r31,r5,r6
		mtctr	r31

		.set	plane0,r4
		.set	plane1,r5
		.set	plane2,r6
		.set	plane3,r7

		lwz	plane3,12(r4)
		subi	plane3,plane3,4
		lwz	plane2,8(r4)
		subi	plane2,plane2,4
		lwz	plane1,4(r4)
		subi	plane1,plane1,4
		lwz	plane0,0(r4)
		subi	plane0,plane0,4

		.set	src,r3

		dcbt	0,src			# pre-fill cache line

		.set	mask2,r8
		.set	mask1,r9

		addis	mask2,0,0x3333
		ori	mask2,mask2,0x3333

		addis	mask1,0,0x5555
		ori	mask1,mask1,0x5555

		.set	reg0,r10
		.set	reg1,r31
		.set	reg2,r30
		.set	reg3,r29
		.set	temp0,r28
		.set	temp1,r27
		.set	temp2,r26
		.set	temp3,r25
		.set	reg4,r24
		.set	reg5,r23
		.set	reg6,r22
		.set	reg7,r21
		.set	temp4,r20
		.set	temp5,r19
		.set	temp6,r18
		.set	temp7,r17

		lwz	temp0,0(src)
		lwz	temp1,4(src)
		lwz	temp2,8(src)
		lwz	temp3,12(src)

		lwz	temp4,16(src)

		rlwinm	reg0,temp0,1,0,3	# R0
		rlwimi	reg0,temp0,13,4,7	# R1
		rlwimi	reg0,temp1,32-7,8,11	# R2
		rlwimi	reg0,temp1,5,12,15	# R3
		rlwimi	reg0,temp2,32-15,16,19	# R4
		rlwimi	reg0,temp2,32-3,20,23	# R5
		rlwimi	reg0,temp3,32-23,24,27	# R6
		rlwimi	reg0,temp3,32-11,28,31	# R7

		lwz	temp5,20(src)

		rlwinm	reg1,temp0,6,0,3	# G0
		rlwimi	reg1,temp0,18,4,7	# G1
		rlwimi	reg1,temp1,32-2,8,11	# G2
		rlwimi	reg1,temp1,10,12,15	# G3
		rlwimi	reg1,temp2,32-10,16,19	# G4
		rlwimi	reg1,temp2,2,20,23	# G5
		rlwimi	reg1,temp3,32-18,24,27	# G6
		rlwimi	reg1,temp3,32-6,28,31	# G7

		mr	reg2,reg1

		lwz	temp6,24(src)

		rlwinm	reg3,temp0,11,0,3	# B0
		rlwimi	reg3,temp0,23,4,7	# B1
		rlwimi	reg3,temp1,3,8,11	# B2
		rlwimi	reg3,temp1,15,12,15	# B3
		rlwimi	reg3,temp2,32-5,16,19	# B4
		rlwimi	reg3,temp2,7,20,23	# B5
		rlwimi	reg3,temp3,32-13,24,27	# B6
		rlwimi	reg3,temp3,32-1,28,31	# B7

		lwz	temp7,28(src)

		MERGE_nBITS2	reg0,reg2,temp0,reg1,reg3,temp1,mask2,2

		addi	src,src,32
		dcbt	0,src			# fill cache line

		MERGE_nBITS2	reg0,reg1,temp0,reg2,reg3,temp1,mask1,1

		b	RGB15_TO_HAM6_NI_mid
RGB15_TO_HAM6_NI_loop:

# first 8 pixels ...

		lwz	temp4,16(src)
		stwu	reg4,4(plane3)

		rlwinm	reg0,temp0,1,0,3	# R0
		rlwimi	reg0,temp0,13,4,7	# R1
		rlwimi	reg0,temp1,32-7,8,11	# R2
		rlwimi	reg0,temp1,5,12,15	# R3
		rlwimi	reg0,temp2,32-15,16,19	# R4
		rlwimi	reg0,temp2,32-3,20,23	# R5
		rlwimi	reg0,temp3,32-23,24,27	# R6
		rlwimi	reg0,temp3,32-11,28,31	# R7

		lwz	temp5,20(src)
		stwu	reg5,4(plane2)

		rlwinm	reg1,temp0,6,0,3	# G0
		rlwimi	reg1,temp0,18,4,7	# G1
		rlwimi	reg1,temp1,32-2,8,11	# G2
		rlwimi	reg1,temp1,10,12,15	# G3
		rlwimi	reg1,temp2,32-10,16,19	# G4
		rlwimi	reg1,temp2,2,20,23	# G5
		rlwimi	reg1,temp3,32-18,24,27	# G6
		rlwimi	reg1,temp3,32-6,28,31	# G7

		mr	reg2,reg1

		lwz	temp6,24(src)
		stwu	reg6,4(plane1)

		rlwinm	reg3,temp0,11,0,3	# B0
		rlwimi	reg3,temp0,23,4,7	# B1
		rlwimi	reg3,temp1,3,8,11	# B2
		rlwimi	reg3,temp1,15,12,15	# B3
		rlwimi	reg3,temp2,32-5,16,19	# B4
		rlwimi	reg3,temp2,7,20,23	# B5
		rlwimi	reg3,temp3,32-13,24,27	# B6
		rlwimi	reg3,temp3,32-1,28,31	# B7

		lwz	temp7,28(src)
		stwu	reg7,4(plane0)

		MERGE_nBITS2	reg0,reg2,temp0,reg1,reg3,temp1,mask2,2

		addi	src,src,32
		dcbt	0,src			# fill cache line

		MERGE_nBITS2	reg0,reg1,temp0,reg2,reg3,temp1,mask1,1

# ... and another 8 pixels

RGB15_TO_HAM6_NI_mid:

		rlwinm	reg4,temp4,1,0,3	# R0
		rlwimi	reg4,temp4,13,4,7	# R1
		rlwimi	reg4,temp5,32-7,8,11	# R2
		rlwimi	reg4,temp5,5,12,15	# R3
		rlwimi	reg4,temp6,32-15,16,19	# R4
		rlwimi	reg4,temp6,32-3,20,23	# R5
		rlwimi	reg4,temp7,32-23,24,27	# R6
		rlwimi	reg4,temp7,32-11,28,31	# R7

		lwz	temp0,0(src)
		stwu	reg0,4(plane3)

		rlwinm	reg5,temp4,6,0,3	# G0
		rlwimi	reg5,temp4,18,4,7	# G1
		rlwimi	reg5,temp5,32-2,8,11	# G2
		rlwimi	reg5,temp5,10,12,15	# G3
		rlwimi	reg5,temp6,32-10,16,19	# G4
		rlwimi	reg5,temp6,2,20,23	# G5
		rlwimi	reg5,temp7,32-18,24,27	# G6
		rlwimi	reg5,temp7,32-6,28,31	# G7

		mr	reg6,reg5

		lwz	temp1,4(src)
		stwu	reg1,4(plane2)

		rlwinm	reg7,temp4,11,0,3	# B0
		rlwimi	reg7,temp4,23,4,7	# B1
		rlwimi	reg7,temp5,3,8,11	# B2
		rlwimi	reg7,temp5,15,12,15	# B3
		rlwimi	reg7,temp6,32-5,16,19	# B4
		rlwimi	reg7,temp6,7,20,23	# B5
		rlwimi	reg7,temp7,32-13,24,27	# B6
		rlwimi	reg7,temp7,32-1,28,31	# B7

		lwz	temp2,8(src)
		stwu	reg2,4(plane1)

		MERGE_nBITS2	reg4,reg6,temp4,reg5,reg7,temp5,mask2,2

		lwz	temp3,12(src)
		stwu	reg3,4(plane0)

		MERGE_nBITS2	reg4,reg5,temp4,reg6,reg7,temp5,mask1,1

		bdnz	RGB15_TO_HAM6_NI_loop

		stwu	reg4,4(plane3)
		stwu	reg5,4(plane2)
		stwu	reg6,4(plane1)
		stwu	reg7,4(plane0)

		lmw	r17,0(r1)
		addi	r1,r1,(32-17)*4

		blr

		.type	RGB15_TO_HAM6_NI,@function
		.size	RGB15_TO_HAM6_NI,$-RGB15_TO_HAM6_NI

