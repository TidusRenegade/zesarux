\                =============================
\                 Millipede - by M G Crossley
\                =============================
\ 
\ Ported to ZX81 Toddy Forth by
\ Kelly A. Murta - JAN/2010.
\
\ THIS PROGRAM is written in Jupiter Ace Forth. It is entitled
\ Millipede and is based upon a program written by Andrew Weekes
\ in Spectrum Basic published in Your Computer, February 1983.
\ As there is a shortage of Ace Forth software I hope Mr Weekes
\ will not mind my useing his algorithm.
\ I have tried to use descriptine colon definition names in an
\ endeavour to make the coding self-explanatory. However, this
\ is at the expense of memory and is not strictly necessary. The
\ program as it stands occupies approximatley 2K, 4 bytes, and
\ requires a memory expansion to the Ace - I use a converted
\ ZX-81 RAM pack. It may be possible, by cutting out the frills,
\ to reduce the memory requirement and still have a playable
\ game using the standard RAM only.
\ In the colin definition Once-More the word Millipede is used.
\ At the time Once-More is being defined Millipede does not
\ exist in the vocabulary. Therefore, it is necessary to define
\ Once-More omitting Millipede and then when all the program has
\ been typed in, edit Once-More putting Millipede in its correct
\ position and then redefine Once-More. Anyone who has used the
\ Ace for a short time will understand the procedure. A similar
\ situation - recursion - is coverd in the Ace manual chapter 3,
\ exercise 7, page 53.
\ One interesting definition which I think is not covered in the
\ Ace manual and which could be useful elsewhere is Screen-Peek.
\ This colon definition expects the stack to contain the row,
\ column print-head position and returns with the ASCII value of
\ the character at the print-head position on top of the stack.

: TASK ;

\ Include some words not defined in Toddy Forth:

HEX
\ Reads the keyboard
CODE INKEY  ( -- ASCII code)
  C5 C,          \        push bc         ;save old TOS
  D5 C,          \        push de         ;save IP
  CD C, 02BB ,   \        call $2BB       ;KEYBOARD
  7D C,          \        ld a,l
  3C C,          \        inc a
  28 C, 0A C,    \        jr z,INK1
  44 C,          \        ld b,h
  4D C,          \        ld c,l
  CD C, 07BD ,   \        call $7BD       ;DECODE
  11 C, 4347 ,   \        ld de,$4347     ;K_UNSHIFT - $7E
  19 C,          \        add hl,de
  7E C,          \        ld a,(hl)
  06 C, 00 C,    \ INK1:  ld b,0          ;put the key code in BC
  4F C,          \        ld c,a          ;
  D1 C,          \        pop de          ;restore IP
  NEXT           \        jp NEXT

\ Add double length numbers
CODE D+  ( d1 d2 -- d1+d2 )
  D9 C,         \        exx
  C1 C,         \        pop bc          ; BC'=d2lo
  D9 C,         \        exx
  E1 C,         \        pop hl          ; HL=d1hi,BC=d2hi
  D9 C,         \        exx
  E1 C,         \        pop hl          ; HL'=d1lo
  09 C,         \        add hl,bc
  E5 C,         \        push hl         ; 2OS=d1lo+d2lo
  D9 C,         \        exx
  ED C, 4A C,   \        adc hl,bc       ; HL=d1hi+d2hi+cy
  44 C,         \        ld b,h
  4D C,         \        ld c,l
  NEXT          \        jp NEXT

\ Test u1<u2, unsigned
CODE U<  ( u1 u2 -- flag)
  E1 C,          \ pop hl
  B7 C,          \ or a
  ED C, 42 C,    \ sbc hl,bc       ; u1-u2 in HL, SZVC valid
  9F C,          \ sbc a,a         ; propagate cy through A
  47 C,          \ ld b,a          ; put 0000 or FFFF in TOS
  4F C,          \ ld c,a
  NEXT           \ jp NEXT

\ Drive the ZON-X81 sound device.
CODE SND ( n1 n2 -- )            ( Write n1 to AY register n2 )
  79 C,          \ ld a,c
  D3 C, DF C,    \ out ($df),a
  E1 C,          \ pop hl
  7D C,          \ ld a,l
  D3 C, 0F C,    \ out ($0f),a
  C1 C,          \ pop bc
  NEXT           \ jp NEXT
DECIMAL

\ Turns off all sound on all channels, A,B and C
: SNDOFF  ( -- )
   255 7 SND ;
: BEEP ( c n -- )
   SWAP 0 SND
   0 1 SND
   254 7 SND
   15 8 SND
   0 DO LOOP SNDOFF ;
: SPACES  ( n -- )              ( output n spaces )
   0 DO SPACE LOOP ;
: AT  ( n1 n2 -- )              ( set print position to row n1 and column n2 )
   SWAP 33 * + 16530 ( dfile)
   + 17339 ( cur_pos) ! ;
: #IN  ( -- n)                  ( wait for a number to be typed )
   BEGIN
      ." ?" TIB @ DUP LBP !
      INPUT BL WORD COUNT NUMBER
   UNTIL DROP ;
: RECURSE  ( -- )               ( recurse current definition )
   LATEST CFA , ; IMMEDIATE
: VARIABLE 0 VARIABLE ;


\ Now, start the game:

VARIABLE SEED
VARIABLE A
VARIABLE B
VARIABLE G
VARIABLE H
VARIABLE M
VARIABLE P
VARIABLE S 

: SETUP 7 A ! 23 B ! 0 G ! 0 M ! 15 P ! 0 S ! ;
: LONG-DELAY 20000 0 DO LOOP ;
: SHORT-DELAY 200 0 DO LOOP ;
\ : 2DUP OVER OVER ;
: PRINT AT ." MILLIPEDE" ; 

: RIGHT 23 0 DO I DUP PRINT LOOP ;
: CENTRE 23 0 DO I 11 PRINT LOOP ;
: LEFT 23 0 DO I DUP 22 SWAP - PRINT LOOP ;

: TITLE 10 0 DO CLS RIGHT SHORT-DELAY CLS CENTRE SHORT-DELAY
  CLS LEFT SHORT-DELAY LOOP CLS CENTRE ;
  
: HI-SOUND 45 400 BEEP ;
: LOW-SOUND 90 400 BEEP ;
: PAUSE BEGIN INKEY UNTIL HI-SOUND LOW-SOUND ;
: HARDNESS CLS CR CR ." ENTER THE HARDNESS LEVEL (2-10)" CR
  #IN ( QUERY LINE) DUP DUP 11 < SWAP 1 > AND IF H ! 1000 0 DO LOOP
  ELSE DROP RECURSE ( HARDNESS) THEN ;
  
: INSTRUCTIONS CLS ." HIT ANY KEY TO CONTINUE" CR CR
  ." GUZZLE DOWN THE BUGS" CR CR
  ." WITHOUT HITTING THE WALLS" CR CR
  ." LEFT 'Z'" 8 SPACES ." RIGHT 'M'" CR PAUSE ; 
  
: MIL 60 189 102 165 102 165 126 60 94 ;
: BUG 24 60 153 126 60 255 60 219 95 ;
: GRAPH 32 - 17515 + C@ 8 * 12288 + DUP 7 + DO I C! -1 +LOOP ;
: DEF-GRAPH MIL GRAPH BUG GRAPH ; 
: WALL-PRINT 20 DUP A @ AT 46 EMIT B @ AT 46 EMIT ;
: RANDOMISE SEED @ 75 UM* 75 0 D+ 2DUP U< - - 1- DUP SEED ! ;
: RND RANDOMISE UM* SWAP DROP ;

: BUG-PRINT 10 RND 1+ 9 > IF 20 A @ DUP B @ SWAP
  - 2 / + AT 95 EMIT THEN ;

: SCREEN-PEEK AT 17339 @ C@ ;

: millipede BL ;

: ONCE-MORE CLS ." DO YOU WANT TO PLAY AGAIN?" CR
  BEGIN INKEY ?DUP UNTIL DUP 89 = IF DROP millipede ELSE 78 =
  IF CLS CR CR ." BYE FOR NOW" CR LONG-DELAY ABORT
  ELSE RECURSE ( ONCE-MORE) THEN THEN ;
  
: ENDIT CLS 9 0 DO ." YOU SNUBBED YOUR NOSE ON THE" CR
  ." TUNNEL WALL" CR LOOP LONG-DELAY CLS 6 0 AT
  ." YOU SCORED " S @ 10 / DUP . ." POINTS." CR CR
  ." YOU ATE " G @ DUP . ." GRUBS" CR CR
  ." THAT'S " + . ." IN TOTAL" LONG-DELAY ONCE-MORE ;
  
: CHECK-OUT SCREEN-PEEK 27 ( 46) = IF ENDIT THEN ; 
: NOSE-SNUB 15 P @ CHECK-OUT 16 P @ CHECK-OUT ;	
: G+ G @ 1+ G ! ; 
: EAT-BUG 16 P @ SCREEN-PEEK 0 ( 32) = 0= IF G+ LOW-SOUND HI-SOUND THEN ;
: MIL-PRINT 15 P @ AT 94 EMIT ;
: SCROLL 22 31 AT 32 EMIT CR ; 
: SUPDATE S @ 1+ S ! ; 
: MUPDATE H @ DUP RND SWAP 2 / - ?DUP IF 3 RND + M ! ELSE RECURSE ( MUPDATE) THEN ;
: AUPDATE A @ DUP -1 > IF M @ + THEN A ! ;
: BUPDATE B @ DUP 31 < IF M @ + THEN B ! ;
: A2UPDATE A @ DUP 1 < IF M @ ABS + A ! B @ M @ ABS + B ! ELSE DROP THEN ;
: B2UPDATE B @ DUP 28 > IF M @ ABS - B ! A @ M @ ABS - A ! ELSE DROP THEN ;
: UPDATE SUPDATE MUPDATE AUPDATE BUPDATE A2UPDATE B2UPDATE ;
: MIL-CLEAR 15 P @ AT 32 EMIT ;

: GETKEY INKEY DUP 90 = IF DROP P @ 1- P !
  ELSE 77 = IF P @ 1+ P ! THEN THEN ;
  
: MILLIPEDE SETUP TITLE HARDNESS INSTRUCTIONS DEF-GRAPH BEGIN
  WALL-PRINT BUG-PRINT NOSE-SNUB EAT-BUG MIL-PRINT SCROLL
  UPDATE MIL-CLEAR GETKEY 0 UNTIL ;
  
' MILLIPEDE ' millipede 3 + ! ( redefines the word millipede to MILLIPEDE )

CR
.( TYPE MILLIPEDE TO PLAY!) CR
 