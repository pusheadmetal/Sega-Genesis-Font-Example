; ***********************************************************************
; Sega Megadrive ROM header (Please tab all code over one except labels)
; ***********************************************************************
	dc.l   0x00FFE000      ; Initial stack pointer value
	dc.l   EntryPoint      ; Start of program
	dc.l   Exception       ; Bus error
	dc.l   Exception       ; Address error
	dc.l   Exception       ; Illegal instruction
	dc.l   Exception       ; Division by zero
	dc.l   Exception       ; CHK exception
	dc.l   Exception       ; TRAPV exception
	dc.l   Exception       ; Privilege violation
	dc.l   Exception       ; TRACE exception
	dc.l   Exception       ; Line-A emulator
	dc.l   Exception       ; Line-F emulator
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Spurious exception
	dc.l   Exception       ; IRQ level 1
	dc.l   Exception       ; IRQ level 2
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
	dc.l   Exception       ; TRAP #00 exception
	dc.l   Exception       ; TRAP #01 exception
	dc.l   Exception       ; TRAP #02 exception
	dc.l   Exception       ; TRAP #03 exception
	dc.l   Exception       ; TRAP #04 exception
	dc.l   Exception       ; TRAP #05 exception
	dc.l   Exception       ; TRAP #06 exception
	dc.l   Exception       ; TRAP #07 exception
	dc.l   Exception       ; TRAP #08 exception
	dc.l   Exception       ; TRAP #09 exception
	dc.l   Exception       ; TRAP #10 exception
	dc.l   Exception       ; TRAP #11 exception
	dc.l   Exception       ; TRAP #12 exception
	dc.l   Exception       ; TRAP #13 exception
	dc.l   Exception       ; TRAP #14 exception
	dc.l   Exception       ; TRAP #15 exception
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)

	dc.b "SEGA GENESIS    "									; Console name
	dc.b "(C)SEGA 1992.SEP"									; Copyrght holder and release date
	dc.b "YOUR GAME HERE                                  "	; Domestic name
	dc.b "YOUR GAME HERE                                  "	; International name
	dc.b "GM XXXXXXXX-XX"									; Version number
	dc.w 0x0000												; Checksum
	dc.b "J               "									; I/O support
	dc.l 0x00000000											; Start address of ROM
	dc.l __end												; End address of ROM
	dc.l 0x00FF0000											; Start address of RAM
	dc.l 0x00FFFFFF											; End address of RAM
	dc.l 0x00000000											; SRAM enabled
	dc.l 0x00000000											; Unused
	dc.l 0x00000000											; Start address of SRAM
	dc.l 0x00000000											; End address of SRAM
	dc.l 0x00000000											; Unused
	dc.l 0x00000000											; Unused
	dc.b "                                        "			; Notes (unused)
	dc.b "JUE             "									; Country codes
; <--- END HEADER --->

EntryPoint:

;ResetTest:
    ; <--- RESET TEST --->
    ; Test if reset button has been hit
    ; If it has, the result of tst.w will be non-zero
    ; Also, we'll be able to skip initial setup
    ; and move straight onto Main

    ; The Genesis has two addresses for reset
    ; One is at 0x00A10008 and the other is at
    ; 0x00A1000C. The first addr is not the 
    ; actual reset button and is for something else.
    ; The second addr is the actual reset button.

    tst.w 0x00A10008    ; Test the mystery reset button
    bne Main            ; Go to Main if addr held a non-zero value
    tst.w 0x00A1000C    ; Test the actual reset button
    bne Main            ; Go to Main if addr held a non-zero value

    ; <--- END RESET TEST --->

;ClearMem:
    ; <--- CLEAR MEMORY --->
    ; The 64k of RAM on the Genesis must be cleared before
    ; it can be used, or else there probably will be garbage
    ; on the screen. To do this, we'll start at 0x00000000
    ; and wrap around backwards, feeding a zero at each 
    ; address from 0x00FFFFFF to 0x00FF0000. A much smarter
    ; person than me made this code, so don't ask me how
    ; it works, because I suck at math.

    ; The reason why we use a longword when a word would
    ; do the job for the value of 3FFF in d1 is because
    ; the register might not be clear on startup. So
    ; don't nitpick!

    move.l #0x00000000, d0    ; Move a longword 0 into d0 to copy over to each addr
    move.l #0x00000000, a0    ; We'll start at addr 0x00000000 and move backwards
    move.l #0x00003FFF, d1    ; This is our counter, which equates to 64k-1, since
                              ; dbra will test d1 first, then decrement.
    @ClearMem:
    move.l d0, -(a0)          ; Moves d0 to a0, pre-decrementing a0 beforehand
    dbra d1, @ClearMem        ; Decrements our counter, loops back to @Clear
                              ; until d1 = 0

    ; <--- END CLEAR MEMORY --->

;TMSS:
    ; <--- TMSS --->
    ; The Trade Mark Security Signature must be written to
    ; 0x00A14000 for the second and third model of the Genesis.
    ; A check needs to be done with the version stored in the
    ; last four bits of addr 0x00A10001. If the comparison yields
    ; zero, we skip writing the TMSS. Otherwise, we have to write
    ; the string "SEGA" to addr 0x00A14000. I know, the security
    ; measure in place here is nigh uncrackable.

    move.b 0x00A10001, d0       ; Move value (Genesis version) stored at
                                ; 0x00A10001 to d0
    andi.b #0x0F, d0            ; ANDI performs an AND op on an immediate
                                ; value and a register.
    beq @Skip                   ; If the previous AND equals 0, we skip
                                ; the write to 0x00A14000
    move.l #'SEGA', 0x00A14000  ; Move the string 'SEGA' to 0x00A14000
    @Skip:

    ; <--- END TMSS --->

;Z80Init:
    ; <--- INITIALIZE THE Z80 --->
    ; The Zilog Z80 is one of the coprocessors within the Genesis.
    ; It's used to control the PSG and FM sound chips and allows
    ; backwards compatibility with the Sega Master System. It has
    ; 8kb of RAM all to itself and can be communicated with through
    ; memory mapped I/O.

    ; In order to use it, we need to request access to its data bus.
    ; We request control by writing 0x0100 to BUSREQ and release
    ; control by writing 0 to BUSREQ. We'll request access from
    ; BUSREQ, located at 0x00A11100, hold it in a reset state
    ; so that we can write code to it by writing 0x0100 to addr
    ; 0x00A11200, test bit 0 of BUSREQ to see if we have control
    ; and loop until we do. 

    move.w #0x0100, 0x00A11100 ; Request access to the Z80
    move.w #0x0100, 0x00A11200 ; Hold the Z80 in reset state so we
                               ; can write code to it
    @Wait:
    btst #0x0, 0x00A11100      ; Test bit 0 of addr 0x00A11100 to 
                               ; see if we have control
    bne @Wait                  ; Loop until we have control

    ; Now that we have control, we can actually write code to the Z80.
    ; Its memory starts at addr 0x00A00000

    lea Z80Data, a0        ; First we move Z80Data, defined below, to a0.
    move.l #0x00A00000, a1 ; Then we move the starting addr of the 
                           ; RAM to a1
    move.l #0x29, d0       ; d0 is our loop counter. We need to loop
                           ; all 42 bytes of Z80Data, minus 1 for the counter.
    @CopyZ80:
    move.b (a0)+, (a1)+       ; Moves a byte of Z80Data to a1, then increments
                              ; both registers
    dbra d0, @CopyZ80         ; Loop until d0 = 0

    move.w #0x0000, 0x00A11200 ; Moves 0 to 0x00A11200, releasing control 
                               ; of the reset state.
    move.w #0x0000, 0x00A11100 ; Same as above, but releases control of
                               ; the Z80 by moving 0 to 0x00A11100

    ; <--- END Z80 INITIALIZATION --->

;PSGInit:
    ; <--- INITIALIZE THE PSG --->
    ; The PSG is the Programmable Sound Generator. It can procedurally
    ; generate square waves and white noise. Unlike the Z80, we don't
    ; need to request bus access. Like the Z80, there is sample data
    ; that we have to write to a specific RAM address, located at 
    ; 0x00C00011. The sample data is 4 bytes and I have no idea what
    ; it does.

    lea PSGData, a0     ; Move the PSGData to a0
    move.l #0x03, d0    ; d0 is our counter. We're moving 4 bytes.

    @CopyPSG:
    move.b (a0)+, 0x00C00011    ; Move a0 to addr 0x00C00011, then
                                ; increment up an addr
    dbra d0, @CopyPSG           ; Repeat until d0 = 0

    ; <--- END PSG INITIALIZATION --->

;VDPInit:
    ; <--- INITIALIZE THE VDP --->
    ; The VDP is the Visual Display Processor. It's a dedicated
    ; graphics chip, but not called as such because the Genesis
    ; lived in an era where it was totally uncool to just call
    ; something a graphics chip (NES PPU, I'm lookin at you).
    ; The VDP has 24 of its own registers and 64kb of dedicated
    ; RAM. It has two ports for communication - the Control Port
    ; and the Data Port - which are memory mapped I/O ports at 
    ; addresses 0x00C00004 and 0x00C00000 respectively. They
    ; work in tandem - The Control Port is used to set registers
    ; and supply a VDP RAM address to the Data Port that is used
    ; to send data through. 

    ; The VDP can only send or receive data in Bytes or Words.
    ; However it has a feature that automatically increments
    ; addresses that will split a long-word write into two word
    ; writes. In order to initialize the VDP, we have to set
    ; all of the registers using a word-size command to the
    ; control port.

    ; The Most Significant Bit (MSB) is the command. For example
    ; 0x8XXX means "Set Register". The next bit is the register.
    ; So 0x80XX would mean "Set Register 0". The final byte is
    ; the value. So 0x8000 would mean "Set Register 0 to 0".

    lea VDPRegisters, a0     ; Move the VDP Registers table to a0
    move.l #0x17, d0         ; d0 is our counter. We're moving 24 registers.
    move.l #0x00008000, d1   ; Set Register 0 command to a1

    @CopyVDP:
    move.b (a0)+, d1            ; Set byte of VDPRegisters to final byte of d1
    move.w d1, 0x00C00004       ; Move Set Register command + data to Control Port
    add.w #0x0100, d1           ; Increment d1 by 0x0100 so we can hit all the registers
    dbra d0, @CopyVDP           ; Run until d0 = 0 

    ; Something that I think Matt at bigevilcorp might have forgotten is to clear the
    ; VRAM. At least for me, upon testing with certain emulators, I get junk on the screen
    ; unless the emulator clears all the RAM upon booting. So we'll clear the VRAM below.
    ; The explanation for how this works is over where we mess with the VDP (in main.asm).

    move.w #0x8F02, 0x00C00004          ; Set up auto-increment for every 2 bytes
    move.l #0x40000000, 0x00C00004      ; Write VRAM addr 0 to Control Port
    move.l #0x00000000, d0              ; Set d0 to 0
    move.l #0x00007FFF, d1              ; Set d1 to 32k-1

    @ClearVRAM:
    move.w d0, 0x00C00000           ; Clear VRAM
    dbra d1, @ClearVRAM

    ; <--- END VDP INITIALIZATION --->

;ControllerInit:
    ; <--- INITIALIZE CONTROLLER PORTS --->
    ; The three (yes, three) controller ports are generic, 9-pin ports,
    ; known as Controller 1, Controller 2 and EXP. EXP is the basic expansion
    ; port on the back of the Model 1 Genesis. They have five memory mapped
    ; I/O addresses each - CTRL, DATA, TxData, RxData, S-CTRL.

    ; CTRL controls the I/O direction and enables/disables interrupts generated by the port
    ; DATA is used to send/receive data in bytes/words when the port is in parallel mode
    ; TxData/RxData is used to send/recieve data in serial mode
    ; S-CTRL is used to get/set the port's current status, baud rate and serial/parallel mode

    ; Below, we're going to set the I/O direction to IN and set interrupts to OFF
    ; on all ports.

    move.b #0x00, 0x00A10009    ; Controller Port 1 CTRL
    move.b #0x00, 0x00A1000B    ; Controller Port 2 CTRL
    move.b #0x00, 0x00A1000D    ; EXP Port CTRL

    ; <--- END CONTROLLER PORT INITIALIZATION --->

;Tidy:
    ; <--- TIDY UP --->
    ; Now we're going to clean up all the junk we left in the registers.

    ; Below we use MOVEM, which means Move Multiple. It can take a value
    ; at a memory address and move it to multiple registers.

    move.l #0x00FF0000, a0      ; Move first addr of RAM to a0, we know it has a 0
                                ; value because we cleared the RAM 
    movem.l (a0), d0-d7/a1-a6   ; Clear all registers except a0 and a7, because a7 
                                ; is our Stack Pointer
    move.l #0x00000000, a0      ; Clear a0

    move.w #0x2700, sr          ; SR is the Status Register. We init with no trace, a7
                                ; is the Interrupt Stack Pointer, no interrupts, clear
                                ; the CCR

    ; <--- END TIDY UP --->

Main:
    jmp __main

HBlankInterrupt:
VBlankInterrupt:
    rts

Exception:
    stop #$2700 ; Halt CPU

Z80Data:
   dc.w 0xaf01, 0xd91f
   dc.w 0x1127, 0x0021
   dc.w 0x2600, 0xf977
   dc.w 0xedb0, 0xdde1
   dc.w 0xfde1, 0xed47
   dc.w 0xed4f, 0xd1e1
   dc.w 0xf108, 0xd9c1
   dc.w 0xd1e1, 0xf1f9
   dc.w 0xf3ed, 0x5636
   dc.w 0xe9e9, 0x8104
   dc.w 0x8f01

PSGData:
   dc.w 0x9fbf, 0xdfff
   
VDPRegisters:
    dc.b 0x14 ; 0: H interrupt on, palettes on
    dc.b 0x74 ; 1: V interrupt on, display on, DMA on, Genesis mode on
    dc.b 0x30 ; 2: Pattern table for Scroll Plane A at VRAM 0xC000 (bits 3-5 = bits 13-15)
    dc.b 0x00 ; 3: Pattern table for Window Plane at VRAM 0x0000 (disabled) (bits 1-5 = bits 11-15)
    dc.b 0x05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
    dc.b 0x70 ; 5: Sprite table at 0xE000 (bits 0-6)
    dc.b 0x00 ; 6: Unused
    dc.b 0x00 ; 7: Background colour – bits 0-3 = colour, bits 4-5 = palette
    dc.b 0x00 ; 8: Unused
    dc.b 0x00 ; 9: Unused
    dc.b 0x08 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
    dc.b 0x00 ; 11: External interrupts off, V scroll fullscreen, H scroll fullscreen
    dc.b 0x81 ; 12: Shadows and highlights off, interlace off, H40 mode (320 x 224 screen res)
    dc.b 0x3F ; 13: Horiz. scroll table at VRAM 0xFC00 (bits 0-5)
    dc.b 0x00 ; 14: Unused
    dc.b 0x02 ; 15: Autoincrement 2 bytes
    dc.b 0x01 ; 16: Vert. scroll 32, Horiz. scroll 64
    dc.b 0x00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
    dc.b 0x00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
    dc.b 0xFF ; 19: DMA length lo byte
    dc.b 0xFF ; 20: DMA length hi byte
    dc.b 0x00 ; 21: DMA source address lo byte
    dc.b 0x00 ; 22: DMA source address mid byte
    dc.b 0x80 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)