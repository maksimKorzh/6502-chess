CLD
JMP SCMP

N1: DCB $04
N2: DCB $02

; Signed compare
SCMP:
  LDA N1
  SEC       ; prepare carry for SBC
  SBC N2    ; A-NUM
  BVC DONE  ; if V is 0, N eor V = N, otherwise N eor V = N eor 1
  EOR #$80  ; A = A eor $80, and N = N eor 1

DONE: ; If the N flag is 1, then N1 < N2 and BMI will branch
  BMI LESS_THAN
  LDA #$00
  BRK

LESS_THAN:
  LDA #$01
  BRK



