////////////////////////////////////////////////
// fillscreen2.asm
// fill screen with key char pressed
// original: JimJim
// https://www.youtube.com/watch?v=ibtwfafBMKU
// 
// tools used:
//  - VS Code 1.66.2
//  - Vice GTK3, v3.6.1
//  - Kick Assembler 5.24
//  - C64Debugger v0.64.58.6.win32
////////////////////////////////////////////////

.var getin=$ffe4        // GETIN kernal routine which checks for input
                        // 0 when no key is pressed
                        // see https://www.c64-wiki.de/wiki/KERNAL
                        // for example
.var screenmem=$0400    // a var for screen memory start (dec 1024)
.var cls=$e544          // kernal routine to clear the screen                        
.var black=$0           // color code for black
.var white=$1           // color code for white
.var bgcolor=$d020      // address for the screen background color
.var bordcolor=$d021    // address for screen border color
.var txtcolor=$286      // address for text color

BasicUpstart2(start)    //KickAss function for BASIC start line, very helpful
*=$2000                 // entrypoint for our asm routines, decimal 8192
                        // BASIC line will be 10 SYS 8192 ( = $2000 )

start:                  // the label BasicUpstart2 uses above.
                        // the entrypoint of our asm routine
    lda #black          // load color - with hash because we load a number, not an address
    sta bordcolor       // store black in the border color address
    lda #black          // load color
    sta bgcolor         // store black in background color address
    lda #white          // load color
    sta txtcolor        // store white in text color
    jsr cls             // clear the screen with cls kernal routine

    ldx #$00             // clear x, offset
introloop:    
    lda introtext,x     // load text address in x
    beq charloop        // branch to charloop if text end has been reached (byte 0)
    sta screenmem,x     // store accu 
    inx                 // next char
    jmp introloop       // loop

charloop:               // another label for the loop below
    jsr getin           // "jump to subroutine" GETIN in kernal
    cmp #$00            // compare memory and accumulator
    beq charloop        // if cmp returns 0 then go back to loop start
    cmp #$103           // cmp if Run/Stop is pressed (103), which is ESC on a PC
    beq quit            // if Run/Stop was pressed, go to quit (end program)
    sec                 // set the carry flag, otherwise we dont get the char we pressed but the one below (H will become G etc.)
    sbc #$40            // we have the ASCII value in our accumulator and need to convert it to the screen code value
                        // To do that, we sbc (SuBtract from accu with Carry) dec64 aka $40
    ldx #$00            // load the x register with zero 
screenloop:
    sta screenmem,x     // store the accu in screenmem with an offset of x. Works like a for/next loop
    sta screenmem+255,x // part 2 of the screen which is 1000 chars wide and we can only store 255 in a register :)
    sta screenmem+510,x // part 3 of the screen
    sta screenmem+744,x // part 4 of the screen <- don't add 255 here, just use 744 (999-255) instead
    inx                 // increase x
    bne screenloop      // branch to screenloop until zero. aka loop ;)
    jmp charloop        // jump to the input routine for the next char

quit:                   // another label, not used here, just a marker for 'program ends here'
    jsr cls             // clear the screen
    rts                 // return to BASIC 

introtext:              // a label to let the program know where the text is stored
    .text "press key to display, runstop to quit"
    .byte 0
    
