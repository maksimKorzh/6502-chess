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
  DCB $00, $00, $00, $0C, $00, $00, $00, $00,   $00, $00, $01, $02, $02, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $01, $01, $01, $01, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00,
  DCB $00, $00, $00, $00, $00, $00, $00, $00,   $00, $00, $00, $00, $00, $00, $00, $00


OFFSETS:
  DCB $00, $0F,  $10, $11, $00,                            ; White pawns
  DCB $8F, $90,  $91, $00,                                 ; Black pawns
  DCB $01, $10,  $81, $90, $00,                            ; Rooks
  DCB $01, $10,  $81, $90, $0F, $8F, $11, $91,  $00,       ; Queens, kings and bishops
  DCB $0E, $8E,  $12, $92, $1F, $9F, $21, $A1,  $00,       ; Knights
  DCB $04, $00,  $0D, $16, $11, $08, $0D                   ; Starting indexes

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
  BNE NEXT_SQUARE  ;-----------------------------
  TAY              ;  
  LDA BOARD,Y      ;  Get piece at board square
  DEX              ;   and store it, skip if
  DEX              ;         wrong color
  STA $0100,X      ;         
  BIT SIDE         ;
  BEQ NEXT_SQUARE  ;-----------------------------
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

SLIDE_LOOP:
  TSX
  TXA
  CLC
  ADC #$05
  TAX
  LDA $0100,X      ; load step vector
  CMP #$00
  BEQ NEXT_SQUARE
  INX
  INX
  INX
  INX
  INX
  STA $0100,X ; store step vectore to dst
  
  BIT NEGATIVE
  BNE SUB_OFFSET

ADD_OFFSET:
  INX
  LDA $0100,X ; load src
  DEX
  CLC
  ADC $0100,X
  JMP CONDITIONS

SUB_OFFSET:
  AND #$7F
  STA $0100,X
  INX
  LDA $0100,X ; load src
  DEX
  SEC
  SBC $0100,X


CONDITIONS:
  STA $0100,X      ; set target square
  
  LDA $0100,X
  TAY
  LDA #$01
  STA BOARD,Y
  ;BRK

  ;TSX          ;-----------------------------
  ;TXA          ;
  ;CLC          ;      Get search depth
  ;ADC #$0C     ; (see stack map for details)
  ;TAX          ;
  ;LDA $0100,X  ;
  ;SEC          ;-----------------------------
  ;SBC #$01     ;     Search recursively
  ;JSR SEARCH   ;-----------------------------

  JMP OFFSET_LOOP

NEXT_SQUARE:
  TSX           ;-----------------------------
  TXA           ;
  CLC           ;
  ADC #$0B      ;
  TAX           ;
  INC $0100,X   ; inc SRC_SQUARE
  LDA $0100,X   ; 
  CMP #$80      ;
  BNE REP_SQ    ;----------------------------
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
