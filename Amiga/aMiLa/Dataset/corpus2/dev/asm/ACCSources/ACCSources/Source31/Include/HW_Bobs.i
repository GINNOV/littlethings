
bob_Next		address of next bob in list
bob_X			X - Screen X position
bob_Y			Y - Screen Y position
bob_W			W - Width in words
bob_H			H - height in lines
bob_D			D - Depth
bob_Data		address of gfx data
bob_Mask		address of mask for gfx data
bob_Clip1		address of mem block used to store clips from screen
bob_Res1		restore address in screen for clip1
bob_Clip2		address of mem block used to store clips from screen
bob_Res2		restore address in screen for clip2
bob_ID			Word ID value: use bits as ID ie 16 ID's available
bob_Anim	equ 	pointer to bob animation structure
bob_Frame		current animation frame number
bob_Timer		current timer value for this frame ( decs to 0 )
bob_Ext			your extension goes here!

banim_Timer		reset value for bob_Timer
banim_Count		number of frames in this animation
banim_Frame1		1st pointer to gfx data, rest follow.

