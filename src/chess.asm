;=================================
; -------------------------------
;  6502 chess program for KIM-1
;
;               by
;
;        Code Monkey King
;
; -------------------------------
;=================================
;  Upload at $0000, run at $0200
;=================================

;=================================
;    ($0000-$00B9) VARIABLES
;=================================
;BOARD:                                                   ; 0x88 cgess board + PST
;  DCB $16, $14, $15, $17, $13, $15, $14, $16,   $00, $00, $00, $00, $00, $00, $00, $00,
;  DCB $12, $12, $12, $12, $12, $12, $12, $12,   $00, $00, $00, $00, $00, $00, $00, $00,
;  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
;  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
;  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
;  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
;  DCB $09, $09, $09, $09, $09, $09, $09, $09,   $00, $00, $00, $00, $00, $00, $00, $00,
;  DCB $0E, $0C, $0D, $0F, $0B, $0D, $0C, $0E,   $00, $00, $00, $00, $00, $00, $00, $00

BOARD:                                                   ; 0x88 cgess board + PST
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
  DCB $00, $00, $00, $09, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00

OFFSETS:
  DCB $00, $0F,  $10, $11, $00,                            ; black pawns
  DCB $F1, $F0,  $EF, $00,                                 ; white pawns
  DCB $01, $10,  $FF, $F0, $00,                            ; rooks
  DCB $01, $10,  $FF, $F0, $0F, $F1, $11, $EF,  $00,       ; queens, kings and bishops
  DCB $0E, $F2,  $12, $EE, $1F, $E1, $21, $DF,  $00,       ; knights
  DCB $04, $00,  $0D, $16, $11, $08, $0D                   ; starting indexes

WEIGHTS: DCB $00, $03, $03, $00, $09, $09, $0F, $1B, $00   ; .PP.NBRQK
MSCORE: DCB $00                                            ; Material score
PSCORE: DCB $00                                            ; Positional score
MATW: DCB $00                                              ; Material score white
MATB: DCB $00                                              ; Material score black
POSW: DCB $00                                              ; Positional score white
POSB: DCB $00                                              ; Positional score black
SCORE: DCB $00                                             ; Score returned by search
BESTSRC: DCB $00                                           ; Best from square
BESTDST: DCB $00                                           ; Best target square
SIDE: DCB $08                                              ; Side to move
OFFBOARD: DCB $88                                          ; Offboard constant
NEGATIVE: DCB $80                                          ; Negative bit

;=================================
;  ($00BA-$01FF) Fake RAM bytes
;=================================
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $FF, $00, $00, $00, $00, $00, $00, $16, $00, $00, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $31, $1F, $85, $1C

;=================================
;     ($0200-$????) PROGRAM
;=================================
; --------------------------------
;            STACK MAP
; --------------------------------
; (SP + C): DEPTH
; (SP + B): SRC_SQUARE
; (SP + A): DST_SQUARE
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
  CLD              ;-----------------------------
  LDA #$03         ;      Search position
  JSR SEARCH       ;        with depth 3
  BRK              ;-----------------------------
  BRK              ;        Program ends
  BRK              ;-----------------------------

EVALUATE:
  JMP RETURN

SEARCH:            ;-----------------------------
  PHA              ;     Store search depth
  TSX              ;-----------------------------
  TXA              ;
  SEC              ;    Init local variables
  SBC #$0A         ; (see stack map for details)
  TAX              ;
  TXS              ;-----------------------------
  LDA #$FF         ;       Set BEST_SCORE
  PHA              ;        to -INFINITY
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;      Get search depth
  ADC #$0C         ; (see stack map for details)
  TAX              ;
  LDA $0100,X      ;-----------------------------
  CMP #$0          ;        On leaf node
  BEQ EVALUATE     ;     evaluate position
  DEX              ;-----------------------------
  LDA #$00         ;     Set SRC_SQUARE to 0
  STA $0100,X      ;-----------------------------

SQ_LOOP:           ;-----------------------------
  BIT OFFBOARD     ;    Skip offboard squares
  BNE BRIDGE       ;-----------------------------
  TAY              ;  
  LDA BOARD,Y      ;  Get piece at board square
  DEX              ;   and store it, skip if
  DEX              ;         wrong color
  STA $0100,X      ;         
  BIT SIDE         ;
  BEQ BRIDGE       ;-----------------------------
  AND #$07         ;     Extract piece type
  DEX              ;        and store it
  STA $0100,X      ;-----------------------------
  CLC              ;
  ADC #$1F         ;      Extract and store
  TAY              ;   directions offset for a 
  LDA OFFSETS,Y    ;    piece type to use as a
  DEX              ;  starting index to loop over
  DEX              ;
  STA $0100,X      ;-----------------------------

OFFSET_LOOP:
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;   Extract direction offset
  ADC #$06         ;       starting index
  TAX              ;      and increment it
  INC $0100,X      ;-----------------------------
  LDA $0100,X      ;
  TAY              ;   Get next step vector of
  LDA OFFSETS,Y    ;   the offset and store it
  DEX              ;
  STA $0100,X      ;-----------------------------
  CMP #$00         ;  Break if no more offsets
  BEQ BRIDGE       ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$06         ;       Set up DST_SQAURE
  TAX              ;      equal to SRC_SQUARE
  LDA $0100,X      ;
  DEX              ;
  STA $0100,X      ;-----------------------------
  JMP SLIDE_LOOP
  
BRIDGE:
  JMP NEXT_SQUARE

SLIDE_LOOP:
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;      Load step vector
  ADC #$05         ;
  TAX              ;
  LDY $0100,X      ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$05         ;     Update DST_SQAURE by
  TAX              ;     adding the value of
  TYA              ;       STEP_VECTOR to it
  CLC              ;
  ADC $0100,X      ;
  STA $0100,X      ;-----------------------------
  BIT OFFBOARD     ; Break if hit the board edge
  BNE NEXT_OFFSET  ;-----------------------------
  TAY              ;
  TSX              ;
  TXA              ;
  CLC              ;  Store CAPTURED_PIECE from
  ADC #$07         ;      BOARD[DST_SQUARE]
  TAX              ;
  TYA              ;
  LDA BOARD,Y      ;
  STA $0100,X      ;-----------------------------
  BIT SIDE         ;  Don't capture own pieces
  BNE NEXT_OFFSET  ;-----------------------------
  
  INX              ;-----------------------------
  LDA $0100,X      ;
  SEC              ;   If piece type is a pawn
  CMP #$03         ;      verify pawn moves
  BCC IS_PAWN      ;
  JMP CHECK_KING   ;-----------------------------

IS_PAWN:
  DEX
  DEX
  DEX
  LDA $0100,X
  AND #$07
  CMP #$00
  BEQ PAWN_PUSH
  BNE PAWN_CAPTURE

PAWN_PUSH:
  INX
  INX
  LDA $0100,X
  CMP #$00
  BNE NEXT_OFFSET
  JMP CHECK_KING

PAWN_CAPTURE:
  INX
  INX
  LDA $0100,X
  CMP #$00
  BEQ NEXT_OFFSET

CHECK_KING:
  ;---------------------------------------------
  DEBUG:
  LDA #$01
  STA BOARD,Y      ; DEBUG
  ;---------------------------------------------

  ;
  ;
  ;
  JMP NEXT_OFFSET

  ;TSX             ;-----------------------------
  ;TXA             ;
  ;CLC             ;      Get search depth
  ;ADC #$0C        ; (see stack map for details)
  ;TAX             ;
  ;LDA $0100,X     ;
  ;SEC             ;-----------------------------
  ;SBC #$01        ;     Search recursively
  ;JSR SEARCH      ;-----------------------------

  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$07         ;
  TAX              ;  Stop sliding on capture
  LDA $0100,X      ;
  
  TAY              ;-----------------------------
  INX              ;
  LDA $0100,X      ;      Skip sliding for
  SEC              ;       leaper pieces
  CMP #$05         ;
  BCC NEXT_OFFSET  ;-----------------------------
  
  TYA
  CMP #$00         ;
  BNE NEXT_OFFSET  ;
  JMP SLIDE_LOOP   ;-----------------------------

NEXT_OFFSET:
  JMP OFFSET_LOOP

NEXT_SQUARE:
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$0B         ;
  TAX              ;      Go to next square
  INC $0100,X      ;
  LDA $0100,X      ; 
  CMP #$80         ;
  BNE REP_SQ       ;----------------------------
  BEQ RETURN

REP_SQ:
  JMP SQ_LOOP

RETURN:
  TSX          ;-----------------------------
  TXA          ;
  CLC          ;   Free up local variables
  ADC #$0C     ; (see stack map for details)
  TAX          ;          and return
  TXS          ;
  RTS          ;-----------------------------

BREAK:
  BRK
