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
BOARD:                                                   ; 0x88 cgess board + PST
  DCB $16, $14, $15, $17, $13, $15, $14, $16,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $12, $12, $12, $12, $00, $12, $12, $12,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
  DCB $00, $00, $00, $00, $09, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
  DCB $09, $09, $09, $09, $00, $09, $09, $09,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $0E, $0C, $0D, $0F, $0B, $0D, $0C, $0E,   $00, $00, $00, $00, $00, $00, $00, $00

OFFSETS:
  DCB $00, $0F,  $10, $11, $00,                            ; black pawns
  DCB $F1, $F0,  $EF, $00,                                 ; white pawns
  DCB $01, $10,  $FF, $F0, $00,                            ; rooks
  DCB $01, $10,  $FF, $F0, $0F, $F1, $11, $EF,  $00,       ; queens, kings and bishops
  DCB $0E, $F2,  $12, $EE, $1F, $E1, $21, $DF,  $00,       ; knights
  DCB $04, $00,  $0D, $16, $11, $08, $0D                   ; starting indexes

WEIGHTS:
  DCB $00, $00, $FD, $00, $F7, $F7, $F1, $E5, $00          ; ..pknbrq.
  DCB $03, $00, $00, $09, $09, $0F, $1B                    ; P.KBNRQ

MSCORE: DCB $00                                            ; Material score
PSCORE: DCB $00                                            ; Positional score
SCORE: DCB $00                                             ; Score returned by search
BESTSRC: DCB $00                                           ; Best from square
BESTDST: DCB $00                                           ; Best target square
SIDE: DCB $08                                              ; Side to move
OFFBOARD: DCB $88                                          ; Offboard constant
WHITE: DCB $08

;=================================
;  ($00BA-$01FF) Fake RAM bytes
;=================================
DCB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
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
; (SP + 2) : RETURN_VALUE
; (SP + 1) : BEST_SCORE
; --------------------------------

START:             ;-----------------------------
  CLD              ;-----------------------------
  LDA #$02         ;      Search position
  JSR SEARCH       ;        with depth 3
  BRK              ;-----------------------------
  BRK              ;        Program ends
  BRK              ;-----------------------------
                   ;
EVALUATE:          ;
  LDA #$00         ;-----------------------------
  STA MSCORE       ;
  STA PSCORE       ;
  LDY #$0          ;

BRD_LOOP:          ;
  TYA
  BIT OFFBOARD
  BNE SKIP_SQ
  TAY
  LDA BOARD,Y
  CMP #$00
  BNE SCR
  JMP SKIP_SQ

SCR:
  AND #$0F
  TAX
  LDA MSCORE       ; Material score
  CLC
  ADC WEIGHTS,X
  STA MSCORE       ;-----------------------------
  LDA BOARD,Y
  BIT WHITE        ;
  BEQ POS_B

POS_W:
  TYA
  CLC
  ADC #$08
  TAX
  LDA PSCORE
  CLC
  ADC BOARD,X
  STA PSCORE
  JMP SKIP_SQ

POS_B:
  TYA
  CLC
  ADC #$08
  TAX
  LDA PSCORE
  SEC
  SBC BOARD,X
  STA PSCORE
  
SKIP_SQ:
  TYA
  CMP #$80
  BEQ RET_EVAL
  TAY
  INY
  JMP BRD_LOOP
  
RET_EVAL:
  TSX
  INX
  INX            ; return stack addr
  LDA SIDE 
  BIT WHITE
  BEQ MINUS

PLUS:
  LDA MSCORE
  CLC            ; score
  ADC PSCORE
  STA $0100,X
  JMP END_EVAL

MINUS:
  LDA #$00
  SEC
  SBC MSCORE
  SEC
  SBC PSCORE
  STA $0100,X

END_EVAL:
  JMP RETURN       ;

EVAL_BRIDGE:
  JMP EVALUATE
                   ;
SEARCH:            ;-----------------------------
  PHA              ;     Store search depth
  TSX              ;-----------------------------
  TXA              ;
  SEC              ;    Init local variables
  SBC #$0A         ; (see stack map for details)
  TAX              ;
  TXS              ;-----------------------------
  LDA #$81         ;       Set BEST_SCORE
  PHA              ;        to -INFINITY
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;      Get search depth
  ADC #$0C         ; (see stack map for details)
  TAX              ;
  LDA $0100,X      ;-----------------------------
  CMP #$0          ;        On leaf node
  BEQ EVAL_BRIDGE  ;     evaluate position
  DEX              ;-----------------------------
  LDA #$00         ;     Set SRC_SQUARE to 0
  STA $0100,X      ;-----------------------------
                   ;
SQ_LOOP:           ;-----------------------------
  BIT OFFBOARD     ;    Skip offboard squares
  BNE SQ_BRIDGE    ;-----------------------------
  TAY              ;  
  LDA BOARD,Y      ;  Get piece at board square
  DEX              ;   and store it, skip if
  DEX              ;         wrong color
  STA $0100,X      ;         
  BIT SIDE         ;
  BEQ SQ_BRIDGE    ;-----------------------------
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
                   ;
OFFSET_LOOP:       ;
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
  BEQ SQ_BRIDGE    ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$06         ;       Set up DST_SQAURE
  TAX              ;      equal to SRC_SQUARE
  LDA $0100,X      ;
  DEX              ;
  STA $0100,X      ;-----------------------------
  JMP SLIDE_LOOP   ;
                   ;-----------------------------
SQ_BRIDGE:         ;    Needed because of the
  JMP NEXT_SQUARE  ; branching range (-128 + 127)
                   ;-----------------------------
SLIDE_LOOP:        ;
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
  BNE OFF_BRIDGE   ;-----------------------------
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
  BNE OFF_BRIDGE   ;
  INX              ;-----------------------------
  LDA $0100,X      ;
  SEC              ;   If piece type is a pawn
  CMP #$03         ;      verify pawn moves
  BCC IS_PAWN      ;
  JMP CHECK_KING   ;-----------------------------
                   ;-----------------------------
OFF_BRIDGE:        ;
  JMP NEXT_OFFSET  ;    Needed because of the
                   ; branching range (-128 + 127)
IS_PAWN:           ;
  DEX              ;-----------------------------
  LDA $0100,X      ;     Load captured piece
  TAY              ;-----------------------------
  DEX              ;
  DEX              ;
  LDA $0100,X      ;  Distinguish between push
  AND #$07         ;    and capture offsets
  CMP #$00         ;
  BEQ PAWN_PUSH    ;
  BNE PAWN_CAPTURE ;-----------------------------
                   ;
PAWN_PUSH:         ;-----------------------------
  TYA              ;
  CMP #$00         ;  Push pawn if empty square
  BNE OFF_BRIDGE   ;           is ahead
  JMP CHECK_KING   ;-----------------------------
                   ;
PAWN_CAPTURE:      ;
  TYA              ;-----------------------------
  CMP #$00         ;   Capture if piece if any
  BEQ OFF_BRIDGE   ;-----------------------------
                   ;
CHECK_KING:        ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$07         ;
  TAX              ;      Is king captured?
  LDA $0100,X      ;
  AND #$07         ;
  CMP #$03         ;
  BEQ IS_KING      ;
  JMP MAKE_MOVE    ;-----------------------------
                   ;
IS_KING:           ;
  TSX              ;-----------------------------
  INX              ;
  INX              ;
  LDA #$7F         ; Return +INF on king capture
  STA $0100,X      ;
  JMP RETURN       ;-----------------------------
                   ;
MAKE_MOVE:         ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$0A         ;
  TAX              ;
  LDY $0100,X      ;
  DEX              ;  BOARD[DST_SQUARE] = PIECE
  LDA $0100,X      ;  BOARD[SRC_SQUARE] = 0x00
  STA BOARD,Y      ;
  INX              ;
  INX              ;
  LDY $0100,X      ;
  LDA #$00         ;
  STA BOARD,Y      ;-----------------------------
  LDA #$18         ;
  SEC              ;   Change the side to move
  SBC SIDE         ;
  STA SIDE         ;-----------------------------
                   ;
RECURSION:         ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;      Get search depth
  ADC #$0C         ; (see stack map for details)
  TAX              ;
  LDA $0100,X      ;
  SEC              ;-----------------------------
  SBC #$01         ;     Search recursively
  JSR SEARCH       ;-----------------------------
                   ;
TAKE_BACK:         ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$0A         ;
  TAX              ;
  LDY $0100,X      ;
  DEX              ;
  DEX              ;
  DEX              ;  
  LDA $0100,X      ;  BOARD[DST_SQUARE] = CAP_P*
  STA BOARD,Y      ;  BOARD[SRC_SQUARE] = PIECE
  INX              ;  
  INX              ;  *CAP_P is CAPTURED_PIECE
  INX              ;
  INX              ;
  LDY $0100,X      ;
  DEX              ;
  DEX              ;
  LDA $0100,X      ;
  STA BOARD,Y      ;-----------------------------
  LDA #$18         ;
  SEC              ;   Change the side to move
  SBC SIDE         ;
  STA SIDE         ;-----------------------------
                   ;
COMPARE_SCORE:     ;
;-------------------
;-------------------
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$07         ;   Stop sliding on capture
  TAX              ;
  LDA $0100,X      ;
  TAY              ;-----------------------------
  INX              ;
  LDA $0100,X      ;   Handle double pawn pushes   
  SEC              ;
  CMP #$03         ;
  BCC IS_DOUBLE    ;-----------------------------
  SEC              ;   Skip sliding for leapers   
  CMP #$05         ;
  BCC NEXT_OFFSET  ;-----------------------------
                   ;
END_SLIDE:         ;-----------------------------
  TYA              ;
  CMP #$00         ;  Slide to the next square
  BNE NEXT_OFFSET  ;
  JMP SLIDE_LOOP   ;-----------------------------
                   ;
NEXT_OFFSET:       ;   Go to the next offset
  JMP OFFSET_LOOP  ;-----------------------------
                   ;
IS_DOUBLE:         ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$0A         ;
  TAX              ;
  LDA $0100,X      ;
  AND #$70         ;
  CLC              ;  Slide one extra square if
  ADC SIDE         ; the pawn is on 2nd/7th rank
  ADC SIDE         ;
  ADC SIDE         ;
  ADC SIDE         ;
  ADC SIDE         ;
  ADC SIDE         ;
  CMP #$80         ;
  BEQ END_SLIDE    ;
  JMP NEXT_OFFSET  ;-----------------------------
                   ;
NEXT_SQUARE:       ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;
  ADC #$0B         ;
  TAX              ;      Go to next square
  INC $0100,X      ;
  LDA $0100,X      ; 
  CMP #$80         ;
  BNE REP_SQ       ;
  BEQ RETURN_BEST  ;----------------------------
                   ;
REP_SQ:            ;
  JMP SQ_LOOP      ;

RETURN_BEST:
  TSX
  INX
  LDA $0100,X
  INX
  STA $0100,X
                   ;
RETURN:            ;
  TSX              ;-----------------------------
  TXA              ;
  CLC              ;   Free up local variables
  ADC #$0C         ; (see stack map for details)
  TAX              ;          and return
  TXS              ;
  RTS              ;-----------------------------
