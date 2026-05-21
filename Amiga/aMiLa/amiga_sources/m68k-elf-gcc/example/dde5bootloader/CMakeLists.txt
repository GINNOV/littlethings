
add_custom_command (OUTPUT DDE5-BootLoader.bin
	COMMAND ${TOOLCHAIN_AMIGAOS_DIR}/vasmm68k_mot -Fbin -m68000 ${CMAKE_CURRENT_SOURCE_DIR}/DDE5-BootLoader.S -o DDE5-BootLoader.bin -L DDE5-BootLoader.lst
	COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/sum-bootblock.py DDE5-BootLoader.bin DDE5-BootLoader.sum
	DEPENDS DDE5-BootLoader.S
)

add_custom_target (dde5boot DEPENDS DDE5-BootLoader.bin)
