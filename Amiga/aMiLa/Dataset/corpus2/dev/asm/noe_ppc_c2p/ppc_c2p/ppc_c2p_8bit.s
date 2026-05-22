# 8bit c2p converter. 
# written by Jacek Cybularczyk (aka Noe / Venus Art)

                .include macros.i


##############################################################################
# C2P converter for non-interleaved planes
# Optimized for two Integer Units (like in MPC604)
#
# IN:
# r3	pointer to chunky buffer (allocated on 32-byte boundary for better performance)
# r4	pointer to table of plane pointers (planes[8])
# r5	width (aligned to 64 pixels)
# r6	height
# OUT:
# none

		.extern	_C2P_NI
		.extern	C2P_NI

		.align	4

_C2P_NI:
C2P_NI:
		subi	r1,r1,(32-10)*4
		stw	r2,0(r1)
		stmw	r11,4(r1)

		srwi	r5,r5,6
		mullw	r31,r5,r6
		mtctr	r31

		.set	plane0,r4
		.set	plane1,r5
		.set	plane2,r6
		.set	plane3,r7
		.set	plane4,r8
		.set	plane5,r9
		.set	plane6,r10
		.set	plane7,r31

		lwz	plane7,28(r4)
		subi	plane7,plane7,4
		lwz	plane6,24(r4)
		subi	plane6,plane6,4
		lwz	plane5,20(r4)
		subi	plane5,plane5,4
		lwz	plane4,16(r4)
		subi	plane4,plane4,4
		lwz	plane3,12(r4)
		subi	plane3,plane3,4
		lwz	plane2,8(r4)
		subi	plane2,plane2,4
		lwz	plane1,4(r4)
		subi	plane1,plane1,4
		lwz	plane0,0(r4)
		subi	plane0,plane0,4

		.set	src,r3
		.set	temp0,r30
		.set	temp1,r29

		dcbt	0,(src)			# pre-fill cache line

		.set	mask1,r28
		.set	mask2,r27
		.set	mask4,r26

		addis	mask1,0,0x5555
		ori	mask1,mask1,0x5555

		addis	mask2,0,0x3333
		ori	mask2,mask2,0x3333

		addis	mask4,0,0x0f0f
		ori	mask4,mask4,0x0f0f

		.set	reg00,r25
		.set	reg01,r24
		.set	reg02,r23
		.set	reg03,r22
		.set	reg04,r21
		.set	reg05,r20
		.set	reg06,r19
		.set	reg07,r18
		.set	reg10,r17
		.set	reg11,r16
		.set	reg12,r15
		.set	reg13,r14
		.set	reg14,r13
		.set	reg15,r12
		.set	reg16,r11
		.set	reg17,r2

		lwz	reg00,0(src)
		lwz	reg04,4(src)
		lwz	reg01,8(src)
		lwz	reg05,12(src)
		lwz	reg02,16(src)
		lwz	reg06,20(src)
		lwz	reg03,24(src)
		lwz	reg07,28(src)

		addi	src,src,32
		dcbt	0,src			# fill cache line

		MERGE_16BITS2	reg00,reg02,temp0,reg01,reg03,temp1
		MERGE_16BITS2	reg04,reg06,temp0,reg05,reg07,temp1
		lwz	reg10,0(src)
		MERGE_8BITS2	reg00,reg01,temp0,reg02,reg03,temp1
		lwz	reg14,4(src)
		MERGE_8BITS2	reg04,reg05,temp0,reg06,reg07,temp1
		lwz	reg11,8(src)
		MERGE_nBITS2	reg00,reg04,temp0,reg01,reg05,temp1,mask4,4
		lwz	reg15,12(src)
		MERGE_nBITS2	reg02,reg06,temp0,reg03,reg07,temp1,mask4,4
		lwz	reg12,16(src)
		MERGE_nBITS2	reg00,reg02,temp0,reg01,reg03,temp1,mask2,2
		lwz	reg16,20(src)
		MERGE_nBITS2	reg04,reg06,temp0,reg05,reg07,temp1,mask2,2
		lwz	reg13,24(src)
		MERGE_nBITS2	reg00,reg01,temp0,reg02,reg03,temp1,mask1,1
		lwz	reg17,28(src)
		MERGE_nBITS2	reg04,reg05,temp0,reg06,reg07,temp1,mask1,1
		addi	src,src,32
		dcbt	0,src			# fill cache line

		b	C2P_NI_mid

C2P_NI_loop:
		stwu	reg10,4(plane7)
		MERGE_16BITS2	reg00,reg02,temp0,reg01,reg03,temp1
		MERGE_16BITS2	reg04,reg06,temp0,reg05,reg07,temp1
		lwz	reg10,0(src)
		stwu	reg14,4(plane3)
		MERGE_8BITS2	reg00,reg01,temp0,reg02,reg03,temp1
		lwz	reg14,4(src)
		stwu	reg11,4(plane6)
		MERGE_8BITS2	reg04,reg05,temp0,reg06,reg07,temp1
		lwz	reg11,8(src)
		stwu	reg15,4(plane2)
		MERGE_nBITS2	reg00,reg04,temp0,reg01,reg05,temp1,mask4,4
		lwz	reg15,12(src)
		stwu	reg12,4(plane5)
		MERGE_nBITS2	reg02,reg06,temp0,reg03,reg07,temp1,mask4,4
		lwz	reg12,16(src)
		stwu	reg16,4(plane1)
		MERGE_nBITS2	reg00,reg02,temp0,reg01,reg03,temp1,mask2,2
		lwz	reg16,20(src)
		stwu	reg13,4(plane4)
		MERGE_nBITS2	reg04,reg06,temp0,reg05,reg07,temp1,mask2,2
		lwz	reg13,24(src)
		stwu	reg17,4(plane0)
		MERGE_nBITS2	reg00,reg01,temp0,reg02,reg03,temp1,mask1,1
		lwz	reg17,28(src)
		addi	src,src,32
		dcbt	0,src			# fill cache line
		MERGE_nBITS2	reg04,reg05,temp0,reg06,reg07,temp1,mask1,1

C2P_NI_mid:
		stwu	reg00,4(plane7)
		MERGE_16BITS2	reg10,reg12,temp0,reg11,reg13,temp1
		MERGE_16BITS2	reg14,reg16,temp0,reg15,reg17,temp1
		lwz	reg00,0(src)
		stwu	reg04,4(plane3)
		MERGE_8BITS2	reg10,reg11,temp0,reg12,reg13,temp1
		lwz	reg04,4(src)
		stwu	reg01,4(plane6)
		MERGE_8BITS2	reg14,reg15,temp0,reg16,reg17,temp1
		lwz	reg01,8(src)
		stwu	reg05,4(plane2)
		MERGE_nBITS2	reg10,reg14,temp0,reg11,reg15,temp1,mask4,4
		lwz	reg05,12(src)
		stwu	reg02,4(plane5)
		MERGE_nBITS2	reg12,reg16,temp0,reg13,reg17,temp1,mask4,4
		lwz	reg02,16(src)
		stwu	reg06,4(plane1)
		MERGE_nBITS2	reg10,reg12,temp0,reg11,reg13,temp1,mask2,2
		lwz	reg06,20(src)
		stwu	reg03,4(plane4)
		MERGE_nBITS2	reg14,reg16,temp0,reg15,reg17,temp1,mask2,2
		lwz	reg03,24(src)
		stwu	reg07,4(plane0)
		MERGE_nBITS2	reg10,reg11,temp0,reg12,reg13,temp1,mask1,1
		lwz	reg07,28(src)
		addi	src,src,32
		dcbt	0,src			# fill cache line
		MERGE_nBITS2	reg14,reg15,temp0,reg16,reg17,temp1,mask1,1

		bdnz	C2P_NI_loop

		stwu	reg10,4(plane7)
		stwu	reg11,4(plane6)
		stwu	reg12,4(plane5)
		stwu	reg13,4(plane4)
		stwu	reg14,4(plane3)
		stwu	reg15,4(plane2)
		stwu	reg16,4(plane1)
		stwu	reg17,4(plane0)

		lwz	r2,0(r1)
		lmw	r11,4(r1)
		addi	r1,r1,(32-10)*4

		blr

		.type	C2P_NI,@function
		.size	C2P_NI,$-C2P_NI


##############################################################################
