 ifnd LIBRARIES_CONFIGREGS_I
LIBRARIES_CONFIGREGS_I set 1
*
*  libraries/configregs.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

* struct ExpansionRom
 rsreset
er_Type 	rs.b 1
er_Product	rs.b 1
er_Flags	rs.b 1
er_Reserved03	rs.b 1
er_Manufacturer rs.w 1
er_SerialNumber rs.l 1
er_InitDiagVec	rs.w 1
er_Reserved0c	rs.b 1
er_Reserved0d	rs.b 1
er_Reserved0e	rs.b 1
er_Reserved0f	rs.b 1
ExpansionRom_SIZEOF rs

* struct ExpansionControl
 rsreset
ec_Interrupt	rs.b 1
ec_Z3_HighBase	rs.b 1
ec_BaseAddress	rs.b 1
ec_Shutup	rs.b 1
ec_Reserved14	rs.b 1
ec_Reserved15	rs.b 1
ec_Reserved16	rs.b 1
ec_Reserved17	rs.b 1
ec_Reserved18	rs.b 1
ec_Reserved19	rs.b 1
ec_Reserved1a	rs.b 1
ec_Reserved1b	rs.b 1
ec_Reserved1c	rs.b 1
ec_Reserved1d	rs.b 1
ec_Reserved1e	rs.b 1
ec_Reserved1f	rs.b 1
ExpansionControl_SIZEOF rs


E_SLOTSIZE		= $10000
E_SLOTMASK		= $ffff
E_SLOTSHIFT		= 16
E_EXPANSIONBASE 	= $e80000
EZ3_EXPANSIONBASE	= $ff000000
E_EXPANSIONSIZE 	= $80000
E_EXPANSIONSLOTS	= 8
E_MEMORYBASE		= $200000
E_MEMORYSIZE		= $800000
E_MEMORYSLOTS		= 128
EZ3_CONFIGAREA		= $40000000
EZ3_CONFIGAREAEND	= $7fffffff
EZ3_SIZEGRANULARITY	= $80000


ERT_TYPEMASK	= $c0
ERT_TYPEBIT	= 6
ERT_TYPESIZE	= 2
ERT_NEWBOARD	= $c0
ERT_ZORROII	= ERT_NEWBOARD
ERT_ZORROIII	= $80

 BITDEF ERT,CHAINEDCONFIG,3
 BITDEF ERT,DIAGVALID,4
 BITDEF ERT,MEMLIST,5
ERT_MEMMASK	= 7
ERT_MEMBIT	= 0
ERT_MEMSIZE	= 3

 BITDEF ERF,MEMSPACE,7
 BITDEF ERF,NOSHUTUP,6
 BITDEF ERF,EXTENDED,5
 BITDEF ERF,ZORRO_III,4
ERT_Z3_SSMASK	= 15
ERT_Z3_SSBIT	= 0
ERT_Z3_SSSIZE	= 4

 BITDEF ECI,INTENA,1
 BITDEF ECI,RESET,3
 BITDEF ECI,INT2PEND,4
 BITDEF ECI,INT6PEND,5
 BITDEF ECI,INT7PEND,6
 BITDEF ECI,INTERRUPTING,7


* struct DiagArea
 rsreset
da_Config	rs.b 1
da_Flags	rs.b 1
da_Size 	rs.w 1
da_DiagPoint	rs.w 1
da_BootPoint	rs.w 1
da_Name 	rs.w 1
da_Reserved01	rs.w 1
da_Reserved02	rs.w 1
DiagArea_SIZE	rs

DAC_BUSWIDTH	  = $c0
DAC_NIBBLEWIDE	  = $00
DAC_BYTEWIDE	  = $40
DAC_WORDWIDE	  = $80
DAC_BOOTTIME	  = $30
DAC_NEVER	  = $00
DAC_CONFIGTIME	  = $10
DAC_BINDTIME	  = $20

 endc
