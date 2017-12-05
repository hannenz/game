; ----------------------------------
screen 		 		= $0400
basic_irq_vector 	= $0314
basic_irq 			= $ea31
kernal_irq_vector 	= $fffe

line1 = 50 + (18 * 8) 
line2 = 50

; ----------------------------------
.import testsub, init_reloader

				.SEGMENT "STARTUP"
				.code

				; BASIC stub
				.word * + 2
				.word link
				.word 2017
				.byte $9e, "2061", 0
link: 			.word 0
; ----------------------------------
; Map is composed of tiles, where a tile is 2x2 chars (= 16x16 px)
; 20x9 tiles-> 40x18 chars--> 7 lines bottom status
; 1 screen -> 180 tiles (720 chars) -> 180 bytes in memory
; 1 charset = 256 chars, => 64 different tiles possible
;
; Sprites
; Hero: 8 directions with 3 frames walking, 2 frames shooting, per Weapon
; => 40 sprites
; Zombie: 8 directions with 3 frames walking, 2 frames attack
; => 40 sprites
;
; 2.5K data per actor
;
; Mempry Map
; $0800 - 		Code
; 				Map data per level
; 1K			Screen RAM
; 				Color RAM
; 2K			Character Set GFX
; 2K			Character Set Text
; 				Sprite data
; 				Sound
;
; ----------------------------------

				.code

main: 			
				jsr $e544
				jsr clrscr

				; Switch to lowercase
				lda #23
				sta 53272

				ldy #0
		:		lda message,y
				beq :+
				jsr $ffd2
				iny
				jmp :-
		: 		



				.data
message: 		.asciiz "Hello, world...!"



				.code

				lda #5
				sta $d020
				sta $d021
				ldx #1
				ldy #33

				lda #<main
				ldx #>main
				jsr init_reloader
				jsr init_raster_irq

mainloop:
				jsr $ffe4
				beq mainloop
				jmp mainloop

				; Return to BASIC
				rts






init_raster_irq:
				sei
				; switch off CIA as interrupt source
				lda #$7f 		; %01111111
				sta $dc0d
				; clear "Hi-Bit" (msb of $d011 indicates >255) of Raster Line
				and $d011
				sta $d011

				lda #line1
				sta $d012

				lda #<handler1
				ldx #>handler1
				sta basic_irq_vector
				stx basic_irq_vector + 1

				; Enable VIC raster as interrupt source
				lda #1
				sta $d01a

				cli
				rts



handler1:

				; lda #3
				; sta $d020
				; sta $d021

				; Soft scroll
				lda scrollx 
				sec
				sbc #1
				and #%00000111
				sta $d016
				sta scrollx

				; setup handler2
				lda #<handler2
				ldx #>handler2
				ldy #line1
				jmp exit_handler



handler2:
				; lda #0
				; sta $d020
				; sta $d021

				lda $d016
				and #%11110000
				sta $d016

				lda scrollx
				cmp #0
				bne :+
				jsr hard_scroll
:

				; Setup handler 1
				lda #<handler1
				ldx #>handler1
				ldy #line2
				jmp exit_handler




exit_handler:
				sta basic_irq_vector
				stx basic_irq_vector + 1
				sty $d012
				asl $d019
				inc flag
				lsr flag
				bcc :+
				jmp $ea31
		:		jmp $ea81



hard_scroll:
				ldx #0
		:		
				lda screen + 0 * 40 + 1,x
				sta screen + 0 * 40,x
				lda screen + 1 * 40 + 1,x
				sta screen + 1 * 40,x
				lda screen + 2 * 40 + 1,x
				sta screen + 2 * 40,x
				lda screen + 3 * 40 + 1,x
				sta screen + 3 * 40,x
				lda screen + 4 * 40 + 1,x
				sta screen + 4 * 40,x
				lda screen + 5 * 40 + 1,x
				sta screen + 5 * 40,x
				lda screen + 6 * 40 + 1,x
				sta screen + 6 * 40,x
				lda screen + 7 * 40 + 1,x
				sta screen + 7 * 40,x
				lda screen + 8 * 40 + 1,x
				sta screen + 8 * 40,x
				lda screen + 9 * 40 + 1,x
				sta screen + 9 * 40,x
				lda screen + 10 * 40 + 1,x
				sta screen + 10 * 40,x
				lda screen + 11 * 40 + 1,x
				sta screen + 11 * 40,x
				lda screen + 12 * 40 + 1,x
				sta screen + 12 * 40,x
				lda screen + 13 * 40 + 1,x
				sta screen + 13 * 40,x
				lda screen + 14 * 40 + 1,x
				sta screen + 14 * 40,x
				lda screen + 15 * 40 + 1,x
				sta screen + 15 * 40,x
				lda screen + 16 * 40 + 1,x
				sta screen + 16 * 40,x
				lda screen + 17 * 40 + 1,x
				sta screen + 17 * 40,x
				inx
				cpx #40
				bne :-
				rts



clrscr:
				ldx #0
:		txa
				sta screen,x
				sta screen + 256,x
				sta screen + 512,x
				sta screen + 726,x
				lda #1
				sta $d800,x
				sta $d800 + 256,x
				sta $d800 + 512,x
				sta $d800 + 726,x
				inx
				bne :-
				rts




				
				.rodata

flag: 			.byte 0
scrollx: 		.byte 0
;bgback: 		.word 0
;tmp: 			.byte 0
txtptr: 		.byte 0

