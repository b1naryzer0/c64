// single row text scroller
// original by 0xc64 
// adapted and modified by atari (fritz r.)
// Assembler: kickass
////////////////////////////////////////////

.var cls=$e544			// kernal clearscreen routine
.var black=00
.var white=01
.var colbr=$d020		// color background
.var colbg=$d021		// color border
// .var cursor=$cc

*=$0801
	.byte $0B, $08, $0A, $00, $9E, $34, $39, $31, $35, $32, $00, $00, $00

*=$c000

main:
	lda #black			// load color in accu
	sta colbg         	// set background color
	lda #black			// load color in accu
	sta colbr         	// set background color
	jsr cls           	// clear screen
// waitforblinkout:		// cursor off loop - doesnt work yet
	// lda $cf
	// beq waitforblinkout
	// lda #01
	// sta cursor

plotcolour:	
	ldx #40				// init colour map
	lda #01
	sta $dbc0, x
	dex
	bpl plotcolour + 4

	sei					// set up interrupt
	lda #$7f
	sta $dc0d			// turn off the CIA interrupts
	sta $dd0d
	and $d011			// clear high bit of raster line
	sta $d011	

	ldy #00				// trigger on first scan line
	sty $d012

	lda #<noscroll		// load interrupt address
	ldx #>noscroll
	sta $0314
	stx $0315

	lda #$01			// enable raster interrupts
	sta $d01a
	cli
	rts					// back to BASIC

noscroll:
	lda $d016			// default to no scroll on start of screen
	and #248			// mask register to maintain higher bits
	sta $d016
	ldy #242			// trigger scroll on last character row
	sty $d012
	lda #<scroll		// load interrupt address
	ldx #>scroll
	sta $0314
	stx $0315
	inc $d019			// acknowledge interrupt
	jmp $ea31

scroll:
	lda $d016			// grab scroll register
	and #248			    // mask lower 3 bits
	adc offset			// apply scroll
	sta $d016
	dec smooth			// smooth scroll
	bne continue
	dec offset			// update scroll
	bpl resetsmooth
	lda #07				// reset scroll offset
	sta offset

shiftrow:
	ldx #00		 		// shift characters to the left
	lda $07c1, x
	sta $07c0, x
	inx
	cpx #39
	bne shiftrow+2

	ldx nextchar		// insert next character
	lda message, x
	sta $07e7	
	inx
	lda message, x
	// cmp #$ff	// loop message
    cmp #$00
    bne resetsmooth-3
	ldx #00
	stx nextchar

resetsmooth:
	ldx #01				// set smoothing
	stx smooth	
	ldx offset			// update colour map
	lda colours, x
	sta	$dbc0
	lda colours+8, x
	sta $dbc1
	lda colours+16, x
	sta	$dbe6
	lda colours+24, x
	sta $dbe7

continue:
	ldy #00				// trigger on first scan line
	sty $d012
	lda #<noscroll		// load interrupt address
	ldx #>noscroll
	sta $0314
	stx $0315
	inc $d019			// acknowledge interrupt
	jmp $ea31

offset:
	.byte 07 			// start at 7 for left scroll
smooth:
	.byte 01
nextchar:
	.byte 00
message:
    .text " *** one-line scroller by atari (fritz r.)"
    .text " *** adapted from 0xc64"	
    .text " *** in 2022 for fun and no profit"
    .text " *** greetings go out to:"
    .text " kiki, christoph s, sascha b., heiko, peter,"
    .text " ralf p., dirk b., andre t., henk van s., mik"
    .text "                             "
    .byte 00
colours:
	.byte 00, 00, 00, 00, 06, 06, 06, 06
	.byte 14, 14, 14, 14, 03, 03, 03, 03
	.byte 03, 03, 03, 03, 14, 14, 14, 14
	.byte 06, 06, 06, 06, 00, 00, 00, 00
