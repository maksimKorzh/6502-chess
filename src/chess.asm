;==============================;
;
;  6502 chess program for KIM-1
;       (prototype in C) 
;
;==============================;

BOARD:                                                   ; 0x88 cgess board + PST
dcb $16, $14, $15, $17, $13, $15, $14, $16,   $00, $00, $00, $00, $00, $00, $00, $00,
dcb $12, $12, $12, $12, $12, $12, $12, $12,   $00, $00, $00, $00, $00, $00, $00, $00,
dcb $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
dcb $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
dcb $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
dcb $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
dcb $09, $09, $09, $09, $09, $09, $09, $09,   $00, $00, $00, $00, $00, $00, $00, $00,
dcb $0E, $0C, $0D, $0F, $0B, $0D, $0C, $0E,   $00, $00, $00, $00, $00, $00, $00, $00

OFFSETS:
dcb $00, $0F,  $10, $11, $00,                            ; white pawns
dcb $8F, $90,  $91, $00,                                 ; black pawns
dcb $01, $10,  $81, $90, $00,                            ; rooks
dcb $01, $10,  $81, $90, $0F, $8F, $11, $91,  $00,       ; queens, kings and bishops
dcb $0E, $8E,  $12, $92, $1F, $9F, $21, $A1,  $00,       ; knights
dcb $04, $00,  $0D, $16, $11, $08, $0D                   ; starting indexes

WEIGHTS: dcb $00, $03, $03, $00, $09, $09, $0F, $1B, $00 ; .PP.NBRQK
MSCORE: dcb $00                                          ; material score
PSCORE: dcb $00                                          ; positional score
MATW: dcb $00                                            ; material score white
MATB: dcb $00                                            ; material score black
POSW: dcb $00                                            ; positional score white
POSB: dcb $00                                            ; positional score black
SCORE: dcb $00                                           ; score returned by search
BESTSRC: dcb $00                                         ; best from square
BESTDST: dcb $00                                         ; best target square
SIDE: dcb $08                                            ; side to move



