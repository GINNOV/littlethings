# wif_info.s
# created 2016.04.09 by Matthew Gundry (ausppc@gmail.com)

# Leading-zero bugfix added on 2016.06.01

# Compile with:
# > vasmppc_std -Felf -o wif_info.o wif_info.s
# > vlink -s -P__abox__ -o wif_info wif_info.o -lamiga

# EmulHandle structure.  
.set	reg_d0, 0
.set	reg_d1, 4
.set	reg_d2, 8
.set	reg_d3, 12
.set	reg_d4, 16
.set	reg_d5, 20
.set	reg_d6, 24
.set	reg_d7, 28
.set	reg_a0, 32
.set	reg_a1, 36
.set	reg_a2, 40
.set	reg_a3, 44
.set	reg_a4, 48
.set	reg_a5, 52
.set	reg_a6, 56
.set	reg_a7, 60
.set	SuperHandle, 72
.set	EmulCallDirectOS, 100
.set	EmulCallDirect68k, 104

# Stack offsets.  
.set	stack_caller_stack, 0
.set	stack_callerLR, 4
.set	stack_exec, 8
.set	stack_dos, 12
.set	stack_initial_message, 16
.set	stack_raw_wif, 20

.set	this_stack_size, 32 * 4

.set	stack_initial_non_volatile_gprs, this_stack_size - ((32 - 13) * 4)	# 32 - 13 = 19, 19 * 4 = 76

# New And Improved...
.set	GlobalSysBase, 4096

#######
.text #
#######

	mflr	r0
	stw		r0, stack_callerLR(r1)
	stwu	r1, -this_stack_size(r1)

	stmw	r13, stack_initial_non_volatile_gprs(r1)

	li		r5, 0
	stw		r5, stack_raw_wif(r1)		# Do not assume that new stack space is zeroed...  
	lis		r5, help_message@h
	ori		r5, r5, help_message@l
	stw		r5, stack_initial_message(r1)

	cmpwi	r4, 1						# dosCmdLen is always >= 1 (the ascii return code byte 0x0a).  
	beq		invalid						# Or, the first two instructions could be cmpwi r4, 1 & beqlr...  

	cmpwi	r4, 52 + 1					# Up to 52 base58 characters + the ascii return code byte.  
	bgt		invalid

	subi	r8, r4, 1					# The user input string size has been bounds tested.  
	mtctr	r8							# Subtract one to avoid processing the ascii return code...  

	la		r7, -1(r3)					# Adjusted input address.  

input_filter:							# Bounds test each input character for base58-ness.  
	lbzu	r3, 1(r7)

	cmpwi	r3, '0'						# Reject input containing non-base58 characters ('0', 'I', 'O', & 'l').  
	ble		invalid
	cmpwi	r3, '9'
	ble		iterate
	cmpwi	r3, 'A'
	blt		invalid
	cmpwi	r3, 'I'
	beq		invalid
	cmpwi	r3, 'O'
	beq		invalid
	cmpwi	r3, 'Z'
	ble		iterate
	cmpwi	r3, 'a'
	blt		invalid
	cmpwi	r3, 'l'
	beq		invalid
	cmpwi	r3, 'z'
	bgt		invalid						# Otherwise, just fall through...  

iterate:
	bdnz	input_filter

	lis		r3, good_checksum_message@h	# Fingers crossed...  
	ori		r3, r3, good_checksum_message@l
	stw		r3, stack_initial_message(r1)

# Compute powers of 58.  			<word1/10>		< all bits set >	 <word10/10 >
# Even the impossibly high value of 0x000080ff 0xffffffff ... 0xffffff01 0x<checksum>
# only returns 52 base58 characters.  So, compute 58^0 through 58^51.  
# The size of 58^51 is 10 words.  

.set	total_powers_of_58, 52
.set	bytes_per_power, 10 * 4			# 10 words * 4 bytes per word.  

	li		r3, total_powers_of_58		# loop count...
	mtctr	r3

	li		r22, 0						# r22 through r31 are used as 'operand a'
	li		r23, 0						# and as the product destination.  
	li		r24, 0
	li		r25, 0
	li		r26, 0
	li		r27, 0
	li		r28, 0
	li		r29, 0
	li		r30, 0
	li		r31, 1						# r22 ~ r31 are initialised to 58^0

	li		r3, 58						# r3 is used as 'operand b' in big_multiply
	lis		r6, powers_of_58@h			# big_multiply uses r4 & r5.  
	ori		r6, r6, powers_of_58@l

	b		next_product + 8			# 'operand a' is initialised with 58^0
										# so branch directly to the store instruction.  
next_product:
	addi	r6, r6, bytes_per_power		# Increment r6 to the next 40 bytes of storage.  
	bl		big_multiply
	stmw	r22, 0(r6)
	bdnz	next_product				# Decrement CTR & Branch if CTR != zero.  

###

	li		r12, 0						# The result of a series of multiplications of 
	li		r13, 0						# converted base58-bytes with their respective 
	li		r14, 0						# powers of 58 will be accumulated in r12 ~ r21.  
	li		r15, 0
	li		r16, 0
	li		r17, 0
	li		r18, 0
	li		r19, 0
	li		r20, 0
	li		r21, 0

	subi	r6, r6, total_powers_of_58 * bytes_per_power# Set r6 so that the first increment points to 58^0.  
	la		r7, 1(r7)					# r7 still points to the end of the input string.  
	mtctr	r8							# CTR = r8 = adjusted dosCmdLen.  

base58_to_raw:
	addi	r6, r6, bytes_per_power
	lmw		r22, 0(r6)
	lbzu	r3, -1(r7)
#range_check_1:
	cmpwi	r3, '9'
	bgt		range_check_2
	subi	r3, r3, 49					# Convert ascii 1~9 to raw 0~8
	b		multiply
range_check_2:
	cmpwi	r3, 'H'
	bgt		range_check_3
	subi	r3, r3, 56					# A~H to raw 9~16
	b		multiply
range_check_3:
	cmpwi	r3, 'N'
	bgt		range_check_4
	subi	r3, r3, 57					# J~N to raw 17~21
	b		multiply
range_check_4:
	cmpwi	r3, 'Z'
	bgt		range_check_5
	subi	r3, r3, 58					# P~Z to raw 22~32
	b		multiply
range_check_5:
	cmpwi	r3, 'k'
	bgt		range_6
	subi	r3, r3, 64					# a~k to raw 33~43
	b		multiply
range_6:
	subi	r3, r3, 65					# m~z to raw 44~57

multiply:
	bl		big_multiply

	addc	r21, r21, r31	# 32		# Start the accumulation with 
	adde	r20, r20, r30	# 64		# the least significant words.  
	adde	r19, r19, r29	# 96
	adde	r18, r18, r28	# 128
	adde	r17, r17, r27	# 160
	adde	r16, r16, r26	# 192
	adde	r15, r15, r25	# 224
	adde	r14, r14, r24	# 256
	adde	r13, r13, r23	# 288
	adde	r12, r12, r22	# 320

	bdnz	base58_to_raw

	li		r30, 0						# Final sha256 message blocks have a 64bit bit count of the preceeding messages.  
	li		r31, 9 * 32		# 288		# Maximum bitcount for 9 words / 36 bytes.  

###	Leading-zero bugfix...  

	cmpwi	r3, 0						# WIF strings starting with '1' are encoding a leading zero 
	bne		save_the_user_input_checksum# which needs to be taken into account by adding eight extra 
	addi	r31, r31, 8					# bits to the sha256 bitcount...  

###

save_the_user_input_checksum:
	mr		r5, r21						# Save the checksum word derived from user input.  

	lis		r3, raw_bytes@ha			# Store the nine most significant words of 
	stwu	r12, raw_bytes@l(r3)		# the ten word product accumulated above.  
	stwu	r13, 4(r3)
	stwu	r14, 4(r3)
	stwu	r15, 4(r3)
	stwu	r16, 4(r3)
	stwu	r17, 4(r3)
	stwu	r18, 4(r3)
	stwu	r19, 4(r3)
	stwu	r20, 4(r3)

	lis		r21, -32768		#0x8000		# Replace the checksum word with a 'bookend bit' 
	stwu	r21, 4(r3)					# for the first iteration of the sha256 double hash.  

# Adjust the value accumulated in r12~r20 (plus the bookend bit in r21) so that leading null bytes are excluded.  

	cntlzw	r3, r12
	rlwinm	r3, r3, 0, 26, 28			# Round down to a multiple of 8 bits.  
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count	# No more leading zero bytes?  

	cntlzw	r3, r13
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r14
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r15
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r16
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r17
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r18
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r19
	rlwinm	r3, r3, 0, 26, 28
	subf	r31, r3, r31
	cmpwi	r3, 32
	blt		calculate_the_byte_count

	cntlzw	r3, r20						# r20 is the 9th and last possible word 
	rlwinm	r3, r3, 0, 26, 28			# to be checked for leading zeroes.  
	subf	r31, r3, r31

calculate_the_byte_count:
	rlwinm	r3, r31, 29, 25, 31			# Convert the bit count to a byte count.  
	neg		r3, r3						# Subtract this byte count from the...  
	addi	r3, r3, 9 * 4				# maximum byte count for 9 words (36 - r3).  
	addis	r3, r3, raw_bytes@ha
	addi	r3, r3, raw_bytes@l			# r3 now points to the first non-null byte of 
	stw		r3, stack_raw_wif(r1)		# the value that was accumulated in r12~r21.  

	mfxer	r4							# Not necessary here, but preserve the other bits of XER.  
	rlwinm	r4, r4, 0, 0, 24			# Zero out bits 25~31.  
	addi	r4, r4, 14 * 4				# 14 words * 4 bytes per word (lswx will load 56 bytes).  
	mtxer	r4							# This will load bytes from the high 
	lswx	r16, r0, r3					# byte of r16 to the low byte of r29.  

	bl		wif_double_sha				# r16~r31 contain a final sha256 message block.  
	cmpw	r3, r5						# r5 = checksum derived from user input.  
	beq		wif_string_statistics

	lis		r6, bad_checksum_message@h
	ori		r6, r6, bad_checksum_message@l
	stw		r6, stack_initial_message(r1)

	bl		r3_to_ascii

	stw		r3, 68(r6)					# Actual checksum.  
	stw		r4, 72(r6)

	mr		r3, r5
	bl		r3_to_ascii
	stw		r3, 36(r6)					# Entered checksum.  
	stw		r4, 40(r6)

###

invalid:								# Regardless of 'good' or 'bad' user input, 
wif_string_statistics:					# the output message is generated here.  
	lwz		r3, SuperHandle(r2)
	lwz		r3, GlobalSysBase(r3)		# This is another way to acquire Execbase...  
	stw		r3, stack_exec(r1)

	stw		r3, reg_a6(r2)				# Execbase in 'a6'.  
	lwz		r3, EmulCallDirectOS(r2)
	mtctr	r3
	lis		r3, DosName@h
	ori		r3, r3, DosName@l
	stw		r3, reg_a1(r2)				# Pointer to name of library in 'a1'.  
	li		r3, 0
	stw		r3, reg_d0(r2)				# Don't care about library verstion.  
	li		r3, LVOOpenLibrary			# Library function offset in r3.  
	bctrl

	stw		r3, stack_dos(r1)
	mr.		r3, r3
	beq		unstack						# This should never happen...  

	lwz		r5, stack_initial_message(r1)
	bl		print_it					# Help message or good or bad checksum message.  

	lwz		r13, stack_raw_wif(r1)
	cmpwi	r13, 0						# If the help message is being output, then no additional 
	beq		close_dos + 8				# blank line is needed so branch past those two instructions.  

	lwzu	r3, -3(r13)					# The first byte is the WIF prefix byte.  Loading it this 
	bl		r3_to_ascii					# way causes it to appear as the least significant r3 byte 
										# and the following words can be loaded with lwzu r3, 4(r13).  
	lis		r5, wif_prefix_byte@h
	ori		r5, r5, wif_prefix_byte@l
	sth		r4, 16(r5)					# The least significant r3 byte was converted to ascii in the low half of r4.  
	bl		print_it

	lis		r5, raw_data@h
	ori		r5, r5, raw_data@l
	bl		print_it

	lis		r5, shell_output@h
	ori		r5, r5, shell_output@l
	la		r14, -4(r5)					# Adjust the output address for access via stwu r?, 4(r14).  
	rlwinm.	r3, r31, 27, 28, 31			# Convert the bit count in r31 to a word count.  
	bne		raw_data_loop_count			# If r3 = 0, there's less than one word to output...  

	li		r3, 1						# Do *not* start a branch decrement loop with CTR = 0
										# unless you actually want to do something five billion times...  
raw_data_loop_count:
	mtctr	r3

raw_data_loop:							# Ok...  This is not great as it's assumed that there 
	lwzu	r3, 4(r13)					# will be a number of whole words or raw data to output.  
	bl		r3_to_ascii					# What if that's not the case?  
	stwu	r3, 4(r14)
	stwu	r4, 4(r14)
	bdnz	raw_data_loop

	lis		r3, 0x0a00					# Ascii return code and end-of-string.  
	stwu	r3, 4(r14)					# This return code and end-of-string 
	bl		print_it					# will be printed again by close_dos.  

	lis		r5, private_key_flag_byte@h	# r31 still holds the bitcount for the message 
	ori		r5, r5, private_key_flag_byte@l	# passed to wif_double_sha
	cmpwi	r31, 8 + 256 + 8			# If r31 = 272 it is assumed that the user 
	bne		close_dos					# entered a WIF private key as an argument.  

	lbz		r3, 4(r13)
	bl		r3_to_ascii
	sth		r4, 30(r5)
	bl		print_it

close_dos:
	mr		r5, r14						# Output a final blank line.  
	bl		print_it

	lwz		r3, EmulCallDirectOS(r2)
	mtctr	r3
	lwz		r3, stack_dos(r1)
	stw		r3, reg_a1(r2)
	lwz		r3, stack_exec(r1)
	stw		r3, reg_a6(r2)
	li		r3, LVOCloseLibrary
	bctrl

unstack:								# Restore r13~r31 before returning to the shell.  
	lmw		r13, stack_initial_non_volatile_gprs(r1)

	li		r3, 0						# Return code.  

	addi	r1, r1, this_stack_size
	lwz		r0, stack_callerLR(r1)
	mtlr	r0

.global	__abox__						# These four lines are needed for vasm to correctly 
__abox__: blr							# define the __abox__ symbol so that the MorphOS 
.type	__abox__, @object				# ELF loader will identify this program as a native 
.size	__abox__, 4						# MorphOS executable.  Choice of data is arbitrary.  

###

# wif_double_sha is a custom, single message block, double hash implementation of sha256 
# just for WIF checksums.  Call wif_double_sha with a final message block in r16~r31.  
# A final message has a bookend bit (not included in the bitcount) trailing the message 
# and a 64bit bitcount that occupies the last 64 bits.  The WIF checksum is returned in r3.  

# Foundational algorithms, constants and various terminology sourced from: 
# http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf

# Volatile registers r4~r7 are not modified.  r8~r31 are saved and restored.  

# wif_double_sha stack offsets.  
#.set	stack_caller_stack, 0
#.set	stack_callerLR, 4
.set	wif_double_sha_stack_gprs, 8
.set	wif_double_sha_stack_w_zero, ((32 - 8) + 2) * 4

.set	wif_double_sha_stack_size, 1024

wif_double_sha:
	mflr	r0
	stw		r0,	stack_callerLR(r1)
	stwu	r1,	-wif_double_sha_stack_size(r1)

# Store these registers before modifying.  
	stmw	r8, wif_double_sha_stack_gprs(r1)

	bl		sha256_message_schedule	# Returns a 256 bit hash in r16~r23.  

# Use the returned hash as a new message for the second iteration of the WIF double hash.  

	lis		r24, 0x8000				# The sha256 last message block 'bookend' bit.  
	li		r25, 0
	li		r26, 0
	li		r27, 0
	li		r28, 0
	li		r29, 0
	li		r30, 0
	li		r31, 256				# Second iteration message block bitcount.  

	bl		sha256_message_schedule

# Only the first word of this new hash value is used as the WIF checksum.  

	mr		r3, r16					# Return this portion of the sha256 double hash in r3.  

wif_double_sha_unstack:
	lmw		r8, wif_double_sha_stack_gprs(r1)
	addi	r1, r1, wif_double_sha_stack_size
	lwz		r0, stack_callerLR(r1)
	mtlr	r0
	blr

sha256_message_schedule:			# For j = 0 through 15; W_j = M_word_j
	stmw	r16, wif_double_sha_stack_w_zero(r1)

# For j = 16 through 63
# W_j = small_sigma_one(W_(j-2)) + W_(j-7) + small_sigma_zero(W_(j-15)) + W_(j-16)

	li		r9, 16 * 4				# 'j value' & loop counter.  Multiply the value by 
	la		r10, wif_double_sha_stack_w_zero(r1)	# four to accommodate words.  

message_schedule:
	subi	r8, r9, 2 * 4			# r8 = j - 2
	lwzx	r8, r10, r8				# r8 = W_(j-2)

	rotrwi	r12, r8, 17				# small_sigma_one(x)
	rotrwi	r11, r8, 19				# = Rotate17(x) XOR Rotate19(x) XOR Shift10(x)
	srwi	r8, r8, 10
	xor		r11, r11, r12
	xor		r28, r8, r11			# r28 = small_sigma_one(W_(j-2))

	subi	r8, r9, 7 * 4			# r8 = j - 7
	lwzx	r29, r10, r8			# r29 = W_(j-7)

	subi	r8, r9, 15 * 4			# r8 = j - 15
	lwzx	r8, r10, r8				# r8 = W_(j-15)

	rotrwi	r12, r8, 7				# small_sigma_zero(x)
	rotrwi	r11, r8, 18				# = Rotate7(x) XOR Rotate18(x) XOR Shift3(x)
	srwi	r8, r8, 3
	xor		r11, r11, r12
	xor		r30, r8, r11			# r30 = small_sigma_zero(W_(j-15))

	subi	r8, r9, 16 * 4			# r8 = j - 16
	lwzx	r31, r10, r8			# r31 = W_(j-16)

	add		r8, r30, r31
	add		r8, r8, r29
	add		r8, r8, r28				# r8 = r31 + r30 + r29 + r28
	stwx	r8, r10, r9				# W_(j) = r8

	addi	r9, r9, 1 * 4			# Increment j.  
	cmpwi	r9, 64 * 4				# Bounds test.  
	blt		message_schedule

# For j = 0 through 63
# T1 = r22
# T2 = r23

	lis		r8, initial_hash@ha
	lmw		r24, initial_hash@l(r8)

	mr		r14, r24				# After the final iteration of 
	mr		r15, r25				# sha256_compression, the initial 
	mr		r16, r26				# values of function registers 'a' 
	mr		r17, r27				# through 'h' are added back - so 
	mr		r18, r28				# make copies before modifying to 
	mr		r19, r29				# avoid additional memory accesses.  
	mr		r20, r30
	mr		r21, r31

	li		r9, 0					# 'j value' & loop counter
	lis		r13, k_values@ha		# keep using the w address in r10
	addi	r13, r13, k_values@l

sha256_compression:
									# T1
	mr		r8, r28					# r8 = function register 'e'

	rotrwi	r12, r8, 6				# big_sigma_one(x)
	rotrwi	r11, r8, 11				# = Rotate6(x) XOR Rotate11(x) XOR Rotate25(x)
	rotrwi	r8, r8, 25
	xor		r11, r11, r12
	xor		r8, r8, r11				# r8 = big_sigma_one(function register 'e')

	add		r22, r31, r8			# r22 = function register h + big_sigma_one(e)

# Enter with at least function registers a, b, c, e, f & g in r24, r25, r26, r28, r29 & r30.  

	and		r8, r28, r29			# Ch(x,y,z) = (x AND y) XOR (NOTx AND z)
	not		r11, r28				# Ch(e,f,g)
	and		r11, r11, r30
	xor		r8, r8, r11				# r8 = Ch(r28, r29, r30)

	add		r22, r22, r8			# r22 = r22 + Ch(e,f,g)
	lwzx	r8, r13, r9
	add		r22, r22, r8			# r22 = r22 + K_j
	lwzx	r8, r10, r9
	add		r22, r22, r8			# r22 = r22 + W_j = T1

#
									# T2
	mr		r8, r24					# r8 = function register 'a'

	rotrwi	r12, r8, 2				# big_sigma_zero(x)
	rotrwi	r11, r8, 13				# = Rotate2(x) XOR Rotate13(x) XOR Rotate22(x)
	rotrwi	r8, r8, 22
	xor		r11, r11, r12
	xor		r23, r8, r11			# r23 = big_sigma_zero(function register 'a')

	and		r8, r24, r25			# Maj(x,y,z) = (x AND y) XOR (x AND z) XOR (y AND z)
	and		r11, r24, r26			# Maj(a,b,c)
	and		r12, r25, r26
	xor		r8, r8, r11
	xor		r8, r8, r12				# r8 = Maj(r24, r25, r26)

	add		r23, r23, r8			# r23 = r23 + Maj(a,b,c) = T2

	mr		r31, r30				# h = g
	mr		r30, r29				# g = f
	mr		r29, r28				# f = e
	add		r28, r27, r22			# e = d + T1
	mr		r27, r26				# d = c
	mr		r26, r25				# c = b
	mr		r25, r24				# b = a
	add		r24, r22, r23			# a = T1 + T2

	addi	r9, r9, 1 * 4			# Increment j.  
	cmpwi	r9, 64 * 4				# Bounds test.  
	blt		sha256_compression

# This part of this sha256 implementation is 
# only appropriate for single block messages.  

	add		r23, r31, r21			# Add the initial hash to 
	add		r22, r30, r20			# the newly compressed hash.  
	add		r21, r29, r19
	add		r20, r28, r18
	add		r19, r27, r17
	add		r18, r26, r16
	add		r17, r25, r15			# Doing it in this order to get 
	add		r16, r24, r14			# around register range overlap.  

	blr								# LR has not been modified so it's safe 
									# to branch directly back to the caller.  
###

print_it:
	lwz		r3, EmulCallDirectOS(r2)
	mtctr	r3
	stw		r5, reg_d1(r2)			# Address of the string to output.  
	li		r3, 0
	stw		r3, reg_d2(r2)			# Pointer to format array (that I don't know how to use...).  
	lwz		r3, stack_dos(r1)
	stw		r3, reg_a6(r2)
	li		r3, LVOVPrintf
	bctr

###

big_multiply:
	mulhwu	r4, r31, r3				# r4 = high_word(r31 * r3)
	mullw	r31, r31, r3			# r31 = low_word(r31 * r3)

	mulhwu	r5, r30, r3				# r5 = high_word(r30 * r3)
	mullw	r30, r30, r3			# r30 = low_word(r30 * r3)
	add		r30, r30, r4			# r30 = r30 + high_word(r31 * r3)

	mulhwu	r4, r29, r3
	mullw	r29, r29, r3
	add		r29, r29, r5

	mulhwu	r5, r28, r3
	mullw	r28, r28, r3
	add		r28, r28, r4

	mulhwu	r4, r27, r3
	mullw	r27, r27, r3
	add		r27, r27, r5

	mulhwu	r5, r26, r3
	mullw	r26, r26, r3
	add		r26, r26, r4

	mulhwu	r4, r25, r3
	mullw	r25, r25, r3
	add		r25, r25, r5

	mulhwu	r5, r24, r3
	mullw	r24, r24, r3
	add		r24, r24, r4

	mulhwu	r4, r23, r3
	mullw	r23, r23, r3
	add		r23, r23, r5

	mulhwu	r5, r22, r3				# if r5 != 0 this product is beyond 320bit.  
	mullw	r22, r22, r3
	add		r22, r22, r4

	blr

###

r3_to_ascii:						# This routine uses r0, r3 & r4.  Enter with a 32bit value in r3.  
	rlwinm	r4, r3, 0, 28, 31		# Copy r3:b28~b31 to r4:b28~b31 and clear r4:b0~b27
	rlwimi	r4, r3, 4, 20, 23		# Copy r3:b24~b27 to r4:b20~b23
	rlwimi	r4, r3, 8, 12, 15		# Copy r3:b20~b23 to r4:b12~b15
	rlwimi	r4, r3, 12, 4, 7		# Copy r3:b16~b19 to r4:b4~b7

	rlwinm	r3, r3, 16, 16, 31		# Switch the high halfword to the low halfword and clear the high halfword.  
	rlwimi	r3, r3, 12, 4, 7		# Copy b16~b19 to b4~b7.  
	rlwimi	r3, r3, 8, 12, 15		# Copy b20~b23 to b12~b15.  
	rlwimi	r3, r3, 4, 20, 23		# Copy bb24~b27 to b20~b23.  

	addis	r3, r3, 0x3030			# The high halfword requires at least the addition of 0x3030 to be 'ascified'.  
	rlwimi	r3, r3, 16, 16, 19		# The r3 lower bytes' high nibbles are not clear so 0x3030 cannot simply be added...  
	rlwimi	r3, r3, 8, 24, 27		# Copy the 0x3 in r3:b0~b3 to r3:b16~b19 and r3:b24~27.  
	addis	r4, r4, 0x3030			# All the r4 bytes' high nibbles are clear so...
	addi	r4, r4, 0x3030			# just add 0x3030 to the r4 high and low halfwords.  

#test_first_byte:
	rlwinm.	r0, r3, 0, 4, 4
	beq		test_second_byte		# If r3:b4 is clear, no further addition is required to ascify the first byte.  
	rlwinm.	r0, r3, 0, 5, 6
	beq		test_second_byte		# If r3:b5~b6 are clear, no further addition is required for the first byte.  
	addis	r3, r3, 0x2700			# If r3:b4 and either r3:b5 or r3:b6 were set, the first byte is in the range 
									# of 0xa~0xf so it requires another addition to be 'ascified'.  
test_second_byte:
	rlwinm.	r0, r3, 0, 12, 12
	beq		test_third_byte
	rlwinm.	r0, r3, 0, 13, 14
	beq		test_third_byte
	addis	r3, r3, 0x0027

test_third_byte:
	rlwinm.	r0, r3, 0, 20, 20
	beq		test_fourth_byte
	rlwinm.	r0, r3, 0, 21, 22
	beq		test_fourth_byte
	addi	r3, r3, 0x2700

test_fourth_byte:
	rlwinm.	r0, r3, 0, 28, 28
	beq		test_fifth_byte
	rlwinm.	r0, r3, 0, 29, 30
	beq		test_fifth_byte
	addi	r3, r3, 0x0027

test_fifth_byte:
	rlwinm.	r0, r4, 0, 4, 4
	beq		test_sixth_byte
	rlwinm.	r0, r4, 0, 5, 6
	beq		test_sixth_byte
	addis	r4, r4, 0x2700

test_sixth_byte:
	rlwinm.	r0, r4, 0, 12, 12
	beq		test_seventh_byte
	rlwinm.	r0, r4, 0, 13, 14
	beq		test_seventh_byte
	addis	r4, r4, 0x0027

test_seventh_byte:
	rlwinm.	r0, r4, 0, 20, 20
	beq		test_eighth_byte
	rlwinm.	r0, r4, 0, 21, 22
	beq		test_eighth_byte
	addi	r4, r4, 0x2700

test_eighth_byte:
	rlwinm.	r0, r4, 0, 28, 28
	beqlr							# If r4:b28 is clear, the ascii conversion is complete.  
	rlwinm.	r0, r4, 0, 29, 30
	beqlr							# If r4:b28 is set and r4:b29~b30 are clear, the ascii conversion is complete.  
	addi	r4, r4, 0x0027			# Otherwise, the last byte is in the range of 0xa~0xf so it requires another addition.  
	blr								# 54 instructions.  

######
.bss #
######

powers_of_58:
.space	1024 * 3
#												   52 * 40 = 2080
.set	raw_bytes, powers_of_58 + (total_powers_of_58 * bytes_per_power)
.set	shell_output, raw_bytes + 64

#########
.rodata #
#########

initial_hash:
.long	0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a	# Floating portions of the 
.long	0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19	# sqaures of the first 
														# eight primes.  
k_values:
.long	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5	# Floating portions of the 
.long	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5	# cubes of the first 64 
.long	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3	# primes.  
.long	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
.long	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc
.long	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da
.long	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7
.long	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
.long	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13
.long	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85
.long	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3
.long	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070
.long	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5
.long	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3
.long	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208	# initial_hash & k_values are 
.long	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2	# constants used by sha256().  

DosName:
.string	"dos.library"	

help_message:
.string	"\n\tUsage: Enter a WIF string (up to 52 characters) as an argument.\n\n"

good_checksum_message:
.string	"\n Good checksum\n\n"

raw_data:
.string	"    Raw data: 0x"

#######
.data #
#######

bad_checksum_message:
.ascii	"\n*Bad checksum*\n"				# 16
.ascii	"Entered checksum: 0xxxxxxxxx   \n"	# 32
.string	" Actual checksum: 0xxxxxxxxx \n\n"	# 32

wif_prefix_byte:
.string	"  WIF prefix: 0xxx\n"

private_key_flag_byte:
.ascii	" Private key \n"
.string	"   flag byte: 0xxx\n"