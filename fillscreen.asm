////////////////////////////////////////////////
// fillscreen.asm
// used Assembler: Kick Assembler 5.24
// fill screen with key char pressed
// original: JimJim
// https://www.youtube.com/watch?v=ibtwfafBMKU
////////////////////////////////////////////////

.var getin=$ffe4        // GETIN kernal routine which checks for input
                        // 0 when no key is pressed
                        // see https://www.c64-wiki.de/wiki/KERNAL
                        // for example
.var screenmem=$0400    // a var for screen memory start (dec 1024)

BasicUpstart2(start)    //KickAss function for BASIC start line, very helpful
*=$2000                 // entrypoint for our asm routines, decimal 8192
                        // BASIC line will be 10 SYS 8192 ( = $2000 )

start:                  // the label BasicUpstart2 uses above.
                        // the entrypoint of our asm routine

charloop:               // another label for the loop below
    jsr getin           // "jump to subroutine" GETIN in kernal
    cmp #$00            // compare memory and accumulator
    beq charloop        // if cmp returns 0 then go back to loop start
    sec                 // set the carry flag, otherwise we dont get the char we pressed but the one below (H will become G etc.)
    sbc #$40            // we have the ASCII value in our accumulator and need to convert it to the screen code value
                        // To do that, we sbc (SuBtract from accu with Carry) dec64 aka $40
    ldx #$00            // load the x register with zero 
screenloop:
    sta screenmem,x     // store the accu in screenmem with an offset of x. Works like a for/next loop
    sta screenmem+255,x // part 2 of the screen which is 1000 chars wide and we can only store 255 in a register
    sta screenmem+510,x // part 3 of the screen
    sta screenmem+744,x // part 4 of the screen <- don't add 255 here, just use 744 (999-255) instead
    inx                 // increase x
    bne screenloop      // branch to screenloop until zero. aka loop
    jmp charloop        // jump to the input routine for the next char

quit:                   // another label, not used here, just a marker for 'program ends here'
    rts                 // return to BASIC 
