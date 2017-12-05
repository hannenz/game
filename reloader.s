;------------------------------------------------------
; On soft reset, we trigger a reload
; of the current file, so we can
; re-compile the code and then hitting CapsLock+PgUp 
; in VICE will reload (and re-run) the current file
;------------------------------------------------------
.export init_reloader

reloc 		= $cf80
filename 	= $cff0
fnlen 		= $cfef

		.code

init_reloader:
		; On soft reset: reload current prg (for development)
		
		; relocate code 
		ldy #0
:		lda load,y
		sta reloc,y
		iny
		cpy #load_end - load
		bcc :-

		; save filename and length
		ldy #0
:		lda ($bb),y
		sta filename,y
		iny
		cpy $b7
		bne :-
		sty fnlen

		; setup reset vector
		sei
		lda #$c3
		sta $8004
		lda #$c2
		sta $8005
		lda #$cd
		sta $8006
		lda #$38
		sta $8007
		lda #$30
		sta $8008
		lda #<reset
		sta $8000
		sta $8002
		lda #>reset
		sta $8001
		sta $8003
		cli
		rts


; Custom (soft-)reset routine
reset:

		; ----------
		; System init as mentioned at [http://codebase64.org/doku.php?id=base:kernalbasicinit]
		sei
		cld
		ldx #$ff
		txs
		jsr $ff84
		lda #0
		tay
:		sta $0002,y
		sta $0200,y
		sta $0300,y
		iny
		bne :-

		ldx #$00
		ldy #$a0
		jsr $fd8c
		jsr $ff8a
		jsr $ff81
		cli
;
		jsr $e453
		jsr $e3bf
		jsr $e422
		ldx #$fb
		txs
		; ----------
;
		;; Print message to screen (why ?)
		;jsr $e544
;
		;; set cursor
		;clc
		;ldx #11
		;ldy #3
		;jsr $fff0
;
		;; Switch to lowercase
		;lda #23
		;sta 53272
;
		;; print message
		;ldy #0
;:		lda message,y
		;beq :+
		;jsr $ffd2
		;iny
		;jmp :-
;
		;; print filename
;:		tay
;:		lda filename,y
		;jsr $ffd2
		;iny
		;cpy fnlen
		;bcc :-
;
;get:
		;jsr $ffe4
		;beq get
		;inc $d020
		jmp reloc

		; we want to re-load the file
		; that has initially been loaded
		; so the filename is still stored at ($bd)
		; no need to call SETNAME again
		; and we don't need to bother about the file's name
load:
		lda fnlen
		ldx #<filename
		ldy #>filename
		jsr $ffbd
		lda #1
		ldx #8
		tay
		jsr $ffba
		lda #0
		jsr $ffd5
		bcc exit

		; error
		lda #2
		sta $d020

exit:
		; BASIC init & run
		jsr $a659
		jsr $a533
		jmp $a7ae
load_end:

;message: 	.byte "Hit any key to reload and restart", 13, "   current prg: ",0
