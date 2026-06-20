##############################################################################
# macros  - written by Jacek Cybularczyk (NOE/Venus Art)

##############################################################################
# MERGE_nBITS
# data1, data2, temp, mask, shift
# \1     \2     \3    \4    \5

		.macro	MERGE_nBITS
		srwi	\3,\2,\5
		xor	\3,\3,\1
		and	\3,\3,\4
		xor	\1,\1,\3
		slwi	\3,\3,\5
		xor	\2,\2,\3
		.endm


##############################################################################
# MERGE_nBITS2
# data1, data2, temp12, data3, data4, temp34, mask, shift
# \1     \2     \3      \4     \5     \6      \7    \8

		.macro	MERGE_nBITS2
		srwi	\3,\2,\8
		srwi	\6,\5,\8
		xor	\3,\3,\1
		xor	\6,\6,\4
		and	\3,\3,\7
		and	\6,\6,\7
		xor	\1,\1,\3
		xor	\4,\4,\6
		slwi	\3,\3,\8
		slwi	\6,\6,\8
		xor	\2,\2,\3
		xor	\5,\5,\6
		.endm


##############################################################################
# MERGE_8BITS
# data1, data2, temp
# \1     \2     \3

		.macro	MERGE_8BITS
		mr	\3,\1
		rlwimi	\1,\2,24,8,15
		rlwimi	\1,\2,24,24,31
		rlwimi	\2,\3,8,0,7
		rlwimi	\2,\3,8,16,23
		.endm


##############################################################################
# MERGE_8BITS2
# data1, data2, temp12, data3, data4, temp34
# \1     \2     \3      \4     \5     \6

		.macro	MERGE_8BITS2
		mr	\3,\1
		mr	\6,\4
		rlwimi	\1,\2,24,8,15
		rlwimi	\4,\5,24,8,15
		rlwimi	\1,\2,24,24,31
		rlwimi	\4,\5,24,24,31
		rlwimi	\2,\3,8,0,7
		rlwimi	\5,\6,8,0,7
		rlwimi	\2,\3,8,16,23
		rlwimi	\5,\6,8,16,23
		.endm


##############################################################################
# MERGE_16BITS
# data1, data2, temp
# \1     \2     \3

		.macro	MERGE_16BITS
		mr	\3,\1
		rlwimi	\1,\2,16,16,31
		rlwimi	\2,\3,16,0,15
		.endm


##############################################################################
# MERGE_16BITS2
# data1, data2, temp12, data3, data4, temp34
# \1     \2     \3      \4     \5     \6

		.macro	MERGE_16BITS2
		mr	\3,\1
		mr	\6,\4
		rlwimi	\1,\2,16,16,31
		rlwimi	\4,\5,16,16,31
		rlwimi	\2,\3,16,0,15
		rlwimi	\5,\6,16,0,15
		.endm
