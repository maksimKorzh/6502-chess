;==============================;
;
;  6502 chess program for KIM-1
;       (prototype in C) 
;
;==============================;

; VARIABLES: Upload at $0000
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

WEIGHTS: dcb $00, $03, $03, $00, $09, $09, $0F, $1B, $00   ; .PP.NBRQK
MSCORE: dcb $00                                            ; material score
PSCORE: dcb $00                                            ; positional score
MATW: dcb $00                                              ; material score white
MATB: dcb $00                                              ; material score black
POSW: dcb $00                                              ; positional score white
POSB: dcb $00                                              ; positional score black
SCORE: dcb $00                                             ; score returned by search
BESTSRC: dcb $00                                           ; best from square
BESTDST: dcb $00                                           ; best target square
SIDE: dcb $08                                              ; side to move

; PROGRAM: Upload at $0200
START:
  CLD
  LDA #$03     ; search depth
  JSR SEARCH
  LDA $01F2
  BRK
  BRK

SEARCH:
  PHA          ; (SP + 12):  store DEPTH
  LDA #$00     ; init local variables with 0
  PHA          ; (SP + 11):  init SRC_SQUARE
  PHA          ; (SP + 10):  init DST_SQUARE
  PHA          ; (SP + 9) :  init PIECE
  PHA          ; (SP + 8) :  init TYPE
  PHA          ; (SP + 7) :  init CAPTURED_PIECE
  PHA          ; (SP + 6) :  init DIRECTIONS
  PHA          ; (SP + 5) :  init STEP_VECTOR
  PHA          ; (SP + 4) :  init TEMP_SRC
  PHA          ; (SP + 3) :  init TEMP_DST
  PHA          ; (SP + 2) :  init FOUND_BETTER
  LDA #$FF     ; -INFINITY
  PHA          ; (SP + 1) :  init BEST_SCORE

  TSX
  TXA
  CLC
  ADC #$0C
  TAX
  LDA $0100,X  ; get depth
  CMP #$0      ; on leaf node
  BEQ RETURN   ; evaluate position
  SEC          ; make SBC work properly
  SBC #$01     ; decrease depth by 1
  JSR SEARCH   ; search recursively
  
  TSX
  INX
  LDA #$23     ; best score found
  STA $0100,X  ; store best score

RETURN:
  PLA          ; (SP + 1):  free BEST_SCORE
  PLA          ; (SP + 2):  free FOUND_BETTER
  PLA          ; (SP + 3):  free TEMP_DST
  PLA          ; (SP + 4):  free TEMP_SRC
  PLA          ; (SP + 5):  free STEP_VECTOR
  PLA          ; (SP + 6):  free DIRECTIONS
  PLA          ; (SP + 7):  free CAPTURED_PIECE
  PLA          ; (SP + 8):  free TYPE
  PLA          ; (SP + 9):  free PIECE
  PLA          ; (SP + 10): free DST_SQUARE
  PLA          ; (SP + 11): free SRC_SQUARE
  PLA          ; (SP + 12): free DEPTH
  RTS

BREAK:
  BRK
