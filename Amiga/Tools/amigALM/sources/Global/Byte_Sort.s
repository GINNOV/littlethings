*
* --------------------------------
*
* BYTE_SORT ROUTINE BY YVES GROLET
*
* --------------------------------
*
*
*
*
*
* Advantages :	- VERY FAST
*	- Easy to do in Machine Code
*	- Give the order, then you can sort very big structures
*	  in the same machine time that a single table
*	- For single table use only pass 1, then it's MEGA FAST
*
* Default :	- Only for Integer
*	- Use a lot of memory for table.
*
*
*
*
*
*
* MEMORY
* ------
*
* n=Max_value_to_sort (ex: 255 for byte)
* N=Number_of_element_to_sort (like source table)
*
* Table size :	BS_Count    n+1
*	BS_Offset   n+1
*	BS_Order    N
*
*
*
*
*
*
* ALGORITM
* --------
*
* Pass1 :
* - - - -
*
* Source to sort example :
* 		0  7                n=7 N=10
*	        1  3
*                         2  5
*		3  1
*	        4  4
*		5  5
*		6  2
*		7  6
*	        8  0
*		9  1
*
* Compute :	- Clear BS_Count
*	- Take first number of Source (7) and inc this room in the BS_Count
*	- Did it for all Source number
*
* Formula :       - i=loop(0->N-1)
*	- Inc BS_Count(Source(i))
*
* BS_Count Example result :
*		0  0+1   = 1
*		1  0+1+1 = 2
*		2  0+1   = 1
*		3  0+1   = 1
*		4  0+1   = 1
*		5  0+1+1 = 2
*		6  0+1   = 1
*		7  0+1   = 1
*
* For 1 dimention table sort you have already the number sorted !
*
*		0  1 -> 1 time 0
*		1  2 -> 2 time 1
*		2  1 -> 1 time 2
*		3  1 -> 1 time 3
*		4  1 -> 1 time 4
*		5  2 -> 2 time 5
*		6  1 -> 1 time 6
*		7  1 -> 1 time 7
*
* That give 0,1,1,2,3,4,5,5,6,7
*
*
* Pass2 : (for 2 or more dimention table to sort)
* - - - -
*
* Formula :	- BS_Order(0)=0
*	- i=loop(1->n)
*	- BS_Offset(i)=BS_Count(i-1)+Bs_Offset(i-1)
*
* BS_Offset Example result :
*		0      0
*		1  1+0=1
*		2  2+1=3
*		3  1+3=4
*		4  1+4=5
*		5  1+5=6
*		6  2+6=8
*		7  1+8=9
*
* Pass3 :
* - - - -
*
* Formula :       - i=loop(0->N-1)
*	- BS_Order(BS_Offset(Source(i)))=i
*	- Inc BS_Offset(Source(i))
*
* BS_Order Example result :
*
*	Source	BS_Offset	BS_Order
*
* 0 ------------> 7 ---   0
* 1               3    |  1
* 2               5    |  3
* 3               1    |  4
* 4               4    |  5
* 5               5    |  6
* 6               2    |  8
* 7               6  7 -> 9+1 ---
* 8               0              |
* 9               1            9 -----------> 0
*
*	Source	BS_Offset	BS_Order
*
* 0	7	0+1	8 source room for smalest 0
* 1               3       1+1+1	3                         1
* 2               5       3+1	9                         1
* 3               1       4+1	6                         2
* 4               4       5+1	1                         3
* 5               5       6+1+1	4                         4
* 6               2       8+1	2                         5
* 7               6       9+1	5                         5
* 8               0		7                         6
* 9               1		0 source room for bigest  7
*
*
*
*
*
*
* BYTE SORT ROUTINE 68000 Code
* ----------------------------


N	=	255	* Take 612 bytes of buffer
N_	=	100	* to sort 100 bytes

BS_Count	DS.B    N+1
BS_Offset	DS.B	N+1
BS_Order	DS.B	N_

Sort			* Pass 1
	lea	BS_Count,a0
	move.l	a0,a1
	moveq	#(N-3)/4,d0
Sort_Clr_Loop
	clr.l	(a0)+
	dbra	d0,Sort_Clr_Loop
	lea	Source,a0
	moveq	#0,d1
	moveq	#N_-1,d0
Sort_P1_Loop
	move.b	(a0)+,d1
	addq.b	#1,(a1,d1.w)
	dbra	d0,Sort_P1_Loop
			* Pass 2
	lea	BS_Offset+1,a0
	moveq	#0,d1
	move	d1,BS_Offset
	move	#N,d0
Sort_P2_Loop
	add.b	(a1)+,d1
	move.b	d1,(a0)+
	dbra	d0,Sort_P2_Loop
			* Pass 3
	lea	BS_Offset,a0
	lea	BS_Order,a1
	lea	Source,a2
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#N_-1,d0
Sort_P3_Loop
	move.b	(a2)+,d1
	move.b	(a0,d1),d2
	addq.b	#1,(a0,d1)
	move.b	d3,(a1,d2)
	addq.b	#1,d3
	dbra	d0,Sort_P3_Loop









