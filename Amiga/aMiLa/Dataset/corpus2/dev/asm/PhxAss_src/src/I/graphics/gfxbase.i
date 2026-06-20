 IFND GRAPHICS_GFXBASE_I
GRAPHICS_GFXBASE_I SET 1
*
*  graphics/gfxbase.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 IFND EXEC_TYPES_I
 include "exec/types.i"
 ENDC
 IFND EXEC_LISTS_I
 include "exec/lists.i"
 ENDC
 IFND EXEC_LIBRARIES_I
 include "exec/libraries.i"
 ENDC
 IFND EXEC_INTERRUPTS_I
 include "exec/interrupts.i"
 ENDC


; struct GfxBase
 rsset	lib_SIZE
gb_ActiView	rs.l 1
gb_copinit	rs.l 1
gb_cia		rs.l 1
gb_blitter	rs.l 1
gb_LOFlist	rs.l 1
gb_SHFlist	rs.l 1
gb_blthd	rs.l 1
gb_blttl	rs.l 1
gb_bsblthd	rs.l 1
gb_bsblttl	rs.l 1
gb_vbbsrv	rs.b is_SIZE
gb_timsrv	rs.b is_SIZE
gb_bltsrv	rs.b is_SIZE
gb_TextFonts	rs.b lh_SIZE
gb_DefaultFont	rs.l 1
gb_Modes	rs.w 1
gb_VBlank	rs.b 1
gb_Debug	rs.b 1
gb_BeamSync	rs.w 1
gb_system_bplcon0 rs.w 1
gb_SpriteReserved rs.b 1
gb_bytereserved rs.b 1
gb_Flags	rs.w 1
gb_BlitLock	rs.w 1
gb_BlitNest	rs.w 1
gb_BlitWaitQ	rs.b lh_SIZE
gb_BltOwner	rs.l 1
gb_TOF_WaitQ	rs.b lh_SIZE
gb_DisplayFlags rs.w 1
gb_SimpleSprites rs.l 1
gb_MaxDisplayRow rs.w 1
gb_MaxDisplayColumn rs.w 1
gb_NormalDisplayRows rs.w 1
gb_NormalDisplayColumns rs.w 1
gb_NormalDPMX	rs.w 1
gb_NormalDPMY	rs.w 1
gb_LastChanceMemory rs.l 1
gb_LCMPtr	rs.l 1
gb_MicrosPerLine rs.w 1
gb_MinDisplayColumn rs.w 1
gb_ChipRevBits0 rs.b 1
gb_crb_reserved rs.b 5
gb_monitor_id	rs.b 2
gb_hedley	rs.l 8
gb_hedley_sprites rs.l 8
gb_hedley_sprites1 rs.l 8
gb_hedley_count rs.w 1
gb_hedley_flags rs.w 1
gb_hedley_tmp	rs.w 1
gb_hash_table	rs.l 1
gb_current_tot_rows rs.w 1
gb_current_tot_cclks rs.w 1
gb_hedley_hint	rs.b 1
gb_hedley_hint2 rs.b 1
gb_nreserved	rs.l 4
gb_a2024_sync_raster rs.l 1
gb_control_delta_pal rs.w 1
gb_control_delta_ntsc rs.w 1
gb_current_monitor rs.l 1
gb_MonitorList	rs.b lh_SIZE
gb_default_monitor rs.l 1
gb_MonitorListSemaphore rs.l 1
gb_DisplayInfoDataBase rs.l 1
gb_ActiViewCprSemaphore rs.l 1
gb_UtilityBase	rs.l 1
gb_ExecBase	rs.l 1
gb_SIZE 	rs.b 0

OWNBLITTERn	= 0
QBOWNERn	= 1
 BITDEF GFX,BIG_BLITS,0
QBOWNER 	= 1<<QBOWNERn

NTSCn		= 0
NTSC		= 1<<NTSCn
GENLOCn 	= 1
GENLOC		= 1<<GENLOCn
PALn		= 2
PAL		= 1<<PALn
TODA_SAFEn	= 3
TODA_SAFE	= 1<<TODA_SAFEn

GRAPHICSNAME	macro
		dc.b "graphics.library",0
		endm
 ENDC
