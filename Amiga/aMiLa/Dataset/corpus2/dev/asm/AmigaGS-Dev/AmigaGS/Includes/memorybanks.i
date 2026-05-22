; MemoryBank.i
;InitRESERVED			Equ	-30
ReserveAsChipData		Equ	-36
ReserveAsFastData		Equ	-42
ReserveAsPublicData		Equ	-48
ReserveAs24BitDMAData	Equ	-54
BankBase				Equ	-60
EraseBank				Equ	-66
EraseAllBanks			Equ	-72

; End.MB.i

; Memory Bank Error Messages.
InvalidBank				Equ	-1
BankAlreadyExist		Equ	-2
NotEnoughtChipMemory	Equ	-3
NotEnoughFastMemory		Equ	-4
NotEnoughPublicMemory	Equ	-5
NotEnough24BitDMAMemory	Equ	-6
CannotEraseBank			Equ	-7
; End.MBEM.i