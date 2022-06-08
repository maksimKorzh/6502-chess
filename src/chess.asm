;=================================
;
;  6502 chess program for KIM-1 
;
;=================================

; ================================
;    VARIABLES: Upload at $0000
; ================================

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

; ================================
;    PROGRAM: Upload at $0200
; ================================
; --------------------------------
;            STACK MAP
; --------------------------------
; (SP + 12): DEPTH
; (SP + 11): SRC_SQUARE
; (SP + 10): DST_SQUARE
; (SP + 9) : PIECE
; (SP + 8) : TYPE
; (SP + 7) : CAPTURED_PIECE
; (SP + 6) : DIRECTIONS
; (SP + 5) : STEP_VECTOR
; (SP + 4) : TEMP_SRC
; (SP + 3) : TEMP_DST
; (SP + 2) : FOUND_BETTER
; (SP + 1) : BEST_SCORE
; --------------------------------

START:
  CLD          ;-----------------------------
  LDA #$03     ;      Search position
  JSR SEARCH   ;        with depth 3
  BRK          ;-----------------------------
  BRK          ;        Program ends
  BRK          ;-----------------------------

SEARCH:        ;-----------------------------
  PHA          ;     store search depth
  TSX          ;-----------------------------
  TXA          ;
  SEC          ;    init local variables
  SBC #$0A     ; (see stack map for details)
  TAX          ;
  TXS          ;-----------------------------
  LDA #$FF     ;       init BEST_SCORE
  PHA          ;         to -INFINITY
  TSX          ;-----------------------------
  TXA          ;
  CLC          ;      get search depth
  ADC #$0C     ; (see stack map for details)
  TAX          ;
  LDA $0100,X  ;-----------------------------
  CMP #$0      ;        on leaf node
  BEQ RETURN   ;     evaluate position
  SEC          ;-----------------------------
  SBC #$01     ;     search recursively
  JSR SEARCH   ;-----------------------------

RETURN:
  TSX          ;-----------------------------
  TXA          ;
  CLC          ;    free local variables
  ADC #$0C     ; (see stack map for details)
  TAX          ;          and return
  TXS          ;
  RTS          ;-----------------------------

BREAK:
  BRK
