	IFND	SANA2_SANA2DEVICE_I
SANA2_SANA2DEVICE_I	SET	1
**
**	devices/sana2.i
**	Revision 1.16
**	for PhxAss
**

	IFND	EXEC_TYPES_I
	INCLUDE "exec/types.i"
	ENDC

	IFND	EXEC_PORTS_I
	INCLUDE "exec/ports.i"
	ENDC

	IFND	EXEC_IO_I
	INCLUDE "exec/io.i"
	ENDC

	IFND	EXEC_ERRORS_I
	INCLUDE "exec/errors.i"
	ENDC

	IFND	DEVICES_TIMER_I
	INCLUDE "devices/timer.i"
	ENDC

	IFND	UTILITY_TAGITEM_I
	INCLUDE "utility/tagitem.i"
	ENDC


SANA2_MAX_ADDR_BITS	EQU	128
SANA2_MAX_ADDR_BYTES	EQU	((SANA2_MAX_ADDR_BITS+7)/8)


; IOSana2Req
			rsreset
ios2_Req		rs.b	io_SIZE
ios2_WireError		rs.l	1
ios2_PacketType 	rs.l	1
ios2_SrcAddr		rs.b	SANA2_MAX_ADDR_BYTES
ios2_DstAddr		rs.b	SANA2_MAX_ADDR_BYTES
ios2_DataLength 	rs.l	1
ios2_Data		rs.l	1
ios2_StatData		rs.l	1
ios2_BufferManagement	rs.l	1
ios2_SIZE		rs


;
; equates for the IO_FLAGS field
;

SANA2IOB_RAW	EQU	7		; raw packet IO requested
SANA2IOF_RAW	EQU	(1<<SANA2IOB_RAW)

SANA2IOB_BCAST	EQU	6		; broadcast packet (received)
SANA2IOF_BCAST	EQU	(1<<SANA2IOB_BCAST)

SANA2IOB_MCAST	EQU	5		; multicast packet (received)
SANA2IOF_MCAST	EQU	(1<<SANA2IOB_MCAST)

SANA2IOB_QUICK	EQU	IOB_QUICK	; quick IO requested (0)
SANA2IOF_QUICK	EQU	IOF_QUICK


;
; equates for OpenDevice()
;

SANA2OPB_MINE	EQU	0		; exclusive access requested
SANA2OPF_MINE	EQU	(1<<SANA2OPB_MINE)

SANA2OPB_PROM	EQU	1		; promiscuous mode requested
SANA2OPF_PROM	EQU	(1<<SANA2OPB_PROM)

S2_Dummy	EQU	(TAG_USER+$B0000)
S2_CopyToBuff	EQU	S2_Dummy+1
S2_CopyFromBuff EQU	S2_Dummy+2
S2_PacketFilter EQU	S2_Dummy+3

; Sana2DeviceQuery
			rsreset
			; Standard information
s2dq_SizeAvailable	rs.l	1
s2dq_SizeSupplied	rs.l	1
s2dq_DevQueryFormat	rs.l	1
s2dq_DeviceLevel	rs.l	1
			; Common information
s2dq_AddrFieldSize	rs.w	1
s2dq_MTU		rs.l	1
s2dq_BPS		rs.l	1
s2dq_HardwareType	rs.l	1
			; Format specific information
s2dq_SIZE		rs


;
; defined SANA-II hardware types
;

S2WIRETYPE_ETHERNET		EQU	1
S2WIRETYPE_IEEE802		EQU	6
S2WIRETYPE_ARCNET		EQU	7
S2WIRETYPE_LOCALTALK		EQU	11
S2WIRETYPE_DYLAN		EQU	12

S2WIRETYPE_AMOKNET		EQU	200

S2WIRETYPE_LIANA		EQU	202

S2WIRETYPE_PPP			EQU	253
S2WIRETYPE_SLIP 		EQU	254
S2WIRETYPE_CSLIP		EQU	255

S2WIRETYPE_PLIP 		EQU	420

; Sana2PacketTypeStats
			rsreset
s2pts_PacketsSent	rs.l	1
s2pts_PacketsReceived	rs.l	1
s2pts_BytesSent 	rs.l	1
s2pts_BytesReceived	rs.l	1
s2pts_PacketsDropped	rs.l	1
s2pts_SIZE		rs


; Sana2SpecialStatRecord
			rsreset
s2ssr_Type		rs.l	1
s2ssr_Count		rs.l	1
s2ssr_String		rs.l	1
s2ssr_SIZE		rs


; Sana2SpecialStatHeader
			rsreset
s2ssh_RecordCountMax	rs.l	1
s2ssh_RecordCountSupplied rs.l	1
s2ssh_SIZE		rs


; Sana2DeviceStats
			rsreset
s2ds_PacketsReceived	rs.l	1
s2ds_PacketsSent	rs.l	1
s2ds_BadData		rs.l	1
s2ds_Overruns		rs.l	1
s2ds_Unused		rs.l	1
s2ds_UnknownTypesReceived rs.l	1
s2ds_Reconfigurations	rs.l	1
s2ds_LastStart		rs.b	tv_SIZE
s2ds_SIZE		rs


;
; Device Commands
;

S2_START		EQU	(CMD_NONSTD)

S2_DEVICEQUERY		EQU	(S2_START+0)
S2_GETSTATIONADDRESS	EQU	(S2_START+1)
S2_CONFIGINTERFACE	EQU	(S2_START+2)
S2_ADDMULTICASTADDRESS	EQU	(S2_START+5)
S2_DELMULTICASTADDRESS	EQU	(S2_START+6)
S2_MULTICAST		EQU	(S2_START+7)
S2_BROADCAST		EQU	(S2_START+8)
S2_TRACKTYPE		EQU	(S2_START+9)
S2_UNTRACKTYPE		EQU	(S2_START+10)
S2_GETTYPESTATS 	EQU	(S2_START+11)
S2_GETSPECIALSTATS	EQU	(S2_START+12)
S2_GETGLOBALSTATS	EQU	(S2_START+13)
S2_ONEVENT		EQU	(S2_START+14)
S2_READORPHAN		EQU	(S2_START+15)
S2_ONLINE		EQU	(S2_START+16)
S2_OFFLINE		EQU	(S2_START+17)

S2_END			EQU	(S2_START+18)


;
; defined errors for IO_ERROR
;

S2ERR_NO_ERROR		EQU	0	; peachy-keen
S2ERR_NO_RESOURCES	EQU	1	; resource allocation failure
S2ERR_BAD_ARGUMENT	EQU	3	; garbage somewhere
S2ERR_BAD_STATE 	EQU	4	; inappropriate state
S2ERR_BAD_ADDRESS	EQU	5	; who?
S2ERR_MTU_EXCEEDED	EQU	6	; too much to chew
S2ERR_NOT_SUPPORTED	EQU	8	; command not supported by hardware
S2ERR_SOFTWARE		EQU	9	; software error detected
S2ERR_OUTOFSERVICE	EQU	10	; driver is offline
S2ERR_TX_FAILURE	EQU	11	; transmission attempt failed
;SEE ALSO <exec/errors.i>

;
; defined errors for IOS2_WIREERROR
;

S2WERR_GENERIC_ERROR	EQU	0	; no specific info available
S2WERR_NOT_CONFIGURED	EQU	1	; unit not configured
S2WERR_UNIT_ONLINE	EQU	2	; unit is currently online
S2WERR_UNIT_OFFLINE	EQU	3	; unit is currently offline
S2WERR_ALREADY_TRACKED	EQU	4	; protocol already tracked
S2WERR_NOT_TRACKED	EQU	5	; protocol not tracked
S2WERR_BUFF_ERROR	EQU	6	; buffer mgmt func returned error
S2WERR_SRC_ADDRESS	EQU	7	; source address problem
S2WERR_DST_ADDRESS	EQU	8	; destination address problem
S2WERR_BAD_BROADCAST	EQU	9	; broadcast address problem
S2WERR_BAD_MULTICAST	EQU	10	; multicast address problem
S2WERR_MULTICAST_FULL	EQU	11	; multicast address list full
S2WERR_BAD_EVENT	EQU	12	; unsupported event class
S2WERR_BAD_STATDATA	EQU	13	; statdata failed sanity check
S2WERR_IS_CONFIGURED	EQU	15	; attempt to config twice
S2WERR_NULL_POINTER	EQU	16	; null pointer detected
S2WERR_TOO_MANY_RETRIES EQU	17	; tx failed due to too many retries
S2WERR_RCVREL_HDW_ERR	EQU	18	; driver fixable hdw error


;
; defined events
;

S2EVENT_ERROR	    equ 1      ; error catch all
S2EVENT_TX	    equ 2      ; transmitter error catch all
S2EVENT_RX	    equ 4      ; receiver error catch all
S2EVENT_ONLINE	    equ 8      ; unit is in service
S2EVENT_OFFLINE     equ 16     ; unit is not in service
S2EVENT_BUFF	    equ 32     ; buffer mgmt function error catch all
S2EVENT_HARDWARE    equ 64     ; hardware error catch all
S2EVENT_SOFTWARE    equ 128    ; software error catch all


	ENDC	;SANA2_SANA2DEVICE_I

