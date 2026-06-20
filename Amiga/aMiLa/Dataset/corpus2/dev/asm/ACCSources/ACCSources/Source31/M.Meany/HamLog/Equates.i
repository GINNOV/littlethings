
***************	Operator record structure

		rsreset
op_QRZ		rs.b		20
op_Opeartor	rs.b		20
op_QTH		rs.b		30
op_Addr1	rs.b		25
op_Addr2	rs.b		25
op_Addr3	rs.b		25
op_Addr4	rs.b		25
op_Addr5	rs.b		25
op_Addr6	rs.b		25
op_Phone	rs.b		20
op_Fax		rs.b		20
op_Bureau	rs.w		1
op_Locator	rs.b		6
op_Contrib	rs.b		10
op_Date		rs.l		1
OpsRecSize	rs.b		0

***************	Log entry record structure

		rsreset
log_Date	rs.l		1
log_Time	rs.l		1
log_Op		rs.l		1
log_Freq	rs.b		10
log_Mode	rs.l		1
log_Radio	rs.l		1
log_Signal	rs.l		1
log_Tone	rs.w		1
log_Notes	rs.b		80
LogRecSize	rs.b		0

***************	Program variable offsets from a5 ( variable base address )

		rsreset
_args		rs.l		1
_argslen	rs.l		1

Password	rs.b		10		password for data encryption

win.ptr		rs.l		1		Main window pointer
win.rp		rs.l		1
win.up		rs.l		1
LastItem	rs.w		1		for repeated menu selections

win.mode	rs.w		1		0=Log, 1=Operator ..

tmp.ptr		rs.l		1		transient window pointers
tmp.rp		rs.l		1
tmp.up		rs.l		1

LogCur		rs.w		1		Current Log ID
OpCur		rs.w		1		Current Operator ID

OpCount		rs.w		1		Number of operators in file
IndexCount	rs.w		1		Number of loaded index's
LogCount	rs.w		1		Number of log entries

OpsHandle	rs.l		1		File handles for data files
IndexHandle	rs.l		1
LogHandle	rs.l		1

IndexBuffer	rs.l		1		pointer to loaded index's

STD_OUT		rs.l		1

BureauFlag	rs.w		1

varsize		rs.b		0
