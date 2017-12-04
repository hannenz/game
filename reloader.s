; On soft reset, we trigger a reload
; of the current file, so we can
; re-compile the code and then hitting CapsLock+PgUp 
; in VICE will reload (and re-run) the current file
; 
; .A/.X 		Callback address
;------------------------------------------------------
.export init_reloader

init_reloader:
	; On soft reset: reload current prg (for development)
		sta callback
		stx callback + 1
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
		; jsr $fd15 ; restore kernal vectors
		jsr $e544

		ldy #0
:		lda message,y
		beq :+
		jsr $ffd2
		iny
		jmp :-

:		ldy #0
:		lda ($bb),y
		beq get
		jsr $ffd2
		iny
		cpy $b7
		bcc :-

get: 	
		jsr $ffe4
		beq get

		jsr reload
		pla
		tay
		pla
		tax
		pla
		rti

reload:
		; we want to re-load the file
		; that has initially been loaded
		; so the filename is still stored at ($bd)
		; no need to call SETNAME again
		; and we don't need to bother about the file's name
		; lda #8
		; ldx #<filename
		; ldy #>filename
		; jsr $ffbd
		lda #1
		ldx #8
		ldy #1
		jsr $ffba
		lda #0
		jsr $ffd5
		bcc exit

		; error
		lda #2
		sta $d020

exit:
		jmp (callback)

callback: 	.word 0
message: 	.asciiz "Hit any key to reload and restart current prg: "
