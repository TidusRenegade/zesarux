( DUMP programming tool )
CR .( LOADING DUMP TOOL...)
CR .( USAGE: ADDR COUNT DUMP) CR

: DUMP  ( addr n -- )
   BASE @ >R HEX SWAP
   BEGIN  OVER 0 >  WHILE  CR DUP 0 <# # # # # #> TYPE SPACE
     8 0 DO  DUP C@ 0 <# # # #> TYPE SPACE 1+  LOOP
     SWAP 8 - SWAP
   REPEAT 2DROP R> BASE ! ;
 