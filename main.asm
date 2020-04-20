    include "init.asm"

__main:

; We're going to be working with the VDP here and there
; is a lot to explain.

; <--- Short Explanation on Planes --->
; The Genesis has four "Planes", which are kind of like canvases.
; Planes A & B are "Scrolling Planes". It also has a Window Plane
; and a Sprite Plane. The Scrolling and Window Planes can display
; grids made up of tiles of image patterns, placed at pre-determined
; cells based on the display mode (32x28 or 40x28 cells). The two
; Scrolling Planes can scroll lines of pixels or groups of lines
; or the entire contents left or right. The Window Plane cannot
; overlap Plane A. The Sprite Plane can display patterns at 
; arbitrary X and Y coordinates and can also horizontally/vertically
; flip them. Priorities for each sprite can be defined so that their
; draw order can be determined.

; <--- PREPPING THE VDP --->
; This is a bit complicated. The operation type and addr
; need to be smashed into one long-word, following the
; pattern:
; <- BBAA AAAA AAAA AAAA 0000 0000 BBBB 00AA ->
; Where the A's are the address, the B's are the op-type
; and the 0's are always 0.

; Starting with the address, our pattern looks like this:
; <- --DC BA98 7654 3210 ---- ---- ---- --FE ->
; Where oddly enough, the 0 is the LSB and F is the MSB.

; How do we use this? Say you wanted to write to 0xC000,
; which is the addr of Plane A's tile info. You'd first
; need to convert that to binary, which yields:
; <- 1100 0000 0000 0000 ->
; The 1's are the MSB's, so they get sent all the way
; to the right of our pattern. So now our pattern looks
; like this:
; <- --00 0000 0000 0000 ---- ---- ---- --11 ->

; Next, we need to address our actual operation. We can
; send the following operations to the VDP:

; VRAM WRITE 000001
; CRAM WRITE 000011
; VSRAM WRITE 000101
; VRAM READ 000000
; CRAM READ 001000
; VSRAM READ 000100

; The pattern the operation needs to be laid out in is
; as follows:
; <- 10-- ---- ---- ---- ---- ---- 5432 ---- ->
; Where 0 is the LSB and 5 is the MSB
; This yields the following operation pattern:
; <- 01-- ---- ---- ---- ---- ---- 0000 ---- ->

; So the final pattern, combining addr and op, is
; as follows:
; <- 0100 0000 0000 0000 0000 0000 0000 0011 ->

; Next, convert the binary back to hex to finally get
; the value 0x40000003. Now we can write that value to
; the VDP's Control Port at 0x00C00004 (I/O addr) to tell
; it that we're writing data to the VRAM addr at 0xC000.
; Phew!

    move.l #0x40000003, 0x00C00004 ; All of that for one little line of code...

; Now data can be written to the data port! But wait, there's a catch...
; The data port can only accept data in either bytes or words. Oh no!
; But there's good news, we can set an autoincrement feature so that
; we can send longwords and the compiler will treat it like two word 
; sized moves. We set it by setting the VDP Register 15 to the amount of 
; bytes we'd like it to increment by.

    move.w #0x8F02, 0x00C00004  ; Set autoincrement to 2 bytes

; Now we're going to write the palette data, which means we need to write
; to the VDP's CRAM (000011). I covered the steps for getting the value
; above, so we're just going to punch it in below.

    move.l #0xC0000003, 0x00C00004

; And since we have autoincrement set up, we can do a normal looking loop
; to send the palette data to the VDP Data Port at 0x00C00000

    lea Palette, a0             ; LEA is Load Effective Address. It allows you to 
                                ; send the addr of a label to a register. It uses
                                ; less cycles than a simple move operation.
    move.l #0x07, d0            ; d0 is our counter. We're moving 32 bytes

    @LoopPalette:
    move.l (a0)+, 0x00C00000           ; Move Palette data to Data Port. Post-increment.
    dbra d0, @LoopPalette              ; Loop until d0=0

; Now that's loaded, let's get something on screen. Let's show off the power of
; Bret Hart, who gets very angry when you try to dereference a null pointer, by
; setting the background color to pink.

; Looking at the palette we loaded, the color pink is 8. The palette ID is 0.
; We're sending this info to VDP Register 7.

    move.w #0x8708, 0x00C00004      ; 0x8RIC where R is Register, I is Palette ID
                                    ; and C is Color.

; So way below, we have a bunch of characters defined. But one of them is not defined
; and that's the space character. But since we cleared our VRAM, pattern 0 will already
; have a 0 value, so that's our space for us right there. So all we have to do when
; writing our characters to the screen is skip the first character by having an offset
; of 0x0020. Unfortunately this also involves that crazy bit pattern up above.

; I made your life a bit easier and gave you the result of following that bit pattern
; below for a VRAM Write at an addr of 0x0020.

    move.l #0x40200000, 0x00C00004  ; Write the result of bit pattern to Control
    lea Characters, a0              ; Write the addr of our characters to a0
    move.l #0x3F, d0                ; 8 characters * 32 bytes = 64 longwords - 1 for the loop

    @LoopCharacters:
    move.l (a0)+, 0x00C00000
    dbra d0, @LoopCharacters

; To actually write the characters, we need to write to VRAM addr 0xC000. We already did
; the bit conversion for that above, so no sweat. However, there is another pattern that
; we have to follow in terms of what to pass to VDP Data. The pattern is as follows:
; <- ABBC DEEE EEEE EEEE ->
; Where:
; Bit A - High/Low Plane
; Bits B - Color Palette ID (0, 1, 2, 3)
; Bit C - Horizontal Flip (0 = OFF, 1 = ON)
; Bit D - Vertical Flip (0 = OFF, 1 = ON)
; Bits E - The ID of the Pattern to be drawn
; So if we want low plane, palette 0, no flipping, and our first pattern, the value we
; move into VDP Data would be 0x0001. Below we've moved a bunch of patterns which should
; write "HELLO, USA" to the screen. It's quite an eyesore, but a good start nonetheless.

    move.l #0x40000003, 0x00C00004  ; Write to VRAM addr 0xC000
    move.w #0x0001, 0x00C00000      ; Low plane, palette 0, no flip, pattern ID 1
    move.w #0x0002, 0x00C00000
    move.w #0x0003, 0x00C00000
    move.w #0x0003, 0x00C00000
    move.w #0x0004, 0x00C00000
    move.w #0x0005, 0x00C00000
    move.w #0x0000, 0x00C00000
    move.w #0x0006, 0x00C00000
    move.w #0x0007, 0x00C00000
    move.w #0x0008, 0x00C00000

    stop #$2700 ; Halt CPU

; Below is our Palette Data. The Genesis is capable of 
; generating 512 different colors total. We only have
; one palette here of 16 colors, but you're allowed to
; have a total of four.
Palette:
   dc.w 0x0000 ; Colour 0 - Transparent
   dc.w 0x000E ; Colour 1 - Red
   dc.w 0x00E0 ; Colour 2 - Green
   dc.w 0x0E00 ; Colour 3 - Blue
   dc.w 0x0000 ; Colour 4 - Black
   dc.w 0x0EEE ; Colour 5 - White
   dc.w 0x00EE ; Colour 6 - Yellow
   dc.w 0x008E ; Colour 7 - Orange
   dc.w 0x0E0E ; Colour 8 - Pink
   dc.w 0x0808 ; Colour 9 - Purple
   dc.w 0x0444 ; Colour A - Dark grey
   dc.w 0x0888 ; Colour B - Light grey
   dc.w 0x0EE0 ; Colour C - Turquoise
   dc.w 0x000A ; Colour D - Maroon
   dc.w 0x0600 ; Colour E - Navy blue
   dc.w 0x0060 ; Colour F - Dark green


; Below is a definition of a Pattern. Each pattern is 
; 8x8 pixels. Every defined bit represents a color from
; our current palette. So all the 1's mean red and all
; the 0's mean transparent. The pattern below creates
; the letter H.
Characters:
    ; H
    dc.l 0x11000110
    dc.l 0x11000110
    dc.l 0x11000110
    dc.l 0x11111110
    dc.l 0x11000110
    dc.l 0x11000110
    dc.l 0x11000110
    dc.l 0x00000000

    ; E
    dc.l 0x22222222
    dc.l 0x22000000
    dc.l 0x22000000
    dc.l 0x22222222
    dc.l 0x22000000
    dc.l 0x22000000
    dc.l 0x22222222
    dc.l 0x00000000

    ; L
    dc.l 0x66000000
    dc.l 0x66000000
    dc.l 0x66000000
    dc.l 0x66000000
    dc.l 0x66000000
    dc.l 0x66000000
    dc.l 0x66666666
    dc.l 0x00000000

    ; O
    dc.l 0x07777700
    dc.l 0x77707770
    dc.l 0x77000770
    dc.l 0x77000770
    dc.l 0x77000770
    dc.l 0x77707770
    dc.l 0x07777700
    dc.l 0x00000000

    ; ,
    dc.l 0x00000000
    dc.l 0x00000000
    dc.l 0x00000000
    dc.l 0x00000000
    dc.l 0x00000000
    dc.l 0x00BB0000
    dc.l 0x0B000000
    dc.l 0x00000000

    ; U
    dc.l 0x11000011
    dc.l 0x11000011
    dc.l 0x11000011
    dc.l 0x11000011
    dc.l 0x11000011
    dc.l 0x01100110
    dc.l 0x00111100
    dc.l 0x00000000

    ; S
    dc.l 0x00555500
    dc.l 0x00500000
    dc.l 0x00500000
    dc.l 0x00555500
    dc.l 0x00000500
    dc.l 0x00000500
    dc.l 0x00555500
    dc.l 0x00000000

    ; A
    dc.l 0x00333300
    dc.l 0x03300330
    dc.l 0x03300330
    dc.l 0x03333330
    dc.l 0x03300330
    dc.l 0x03300330
    dc.l 0x03300330
    dc.l 0x00000000

__end:  ; Always the last line - end of ROM address