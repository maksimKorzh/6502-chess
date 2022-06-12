# 6502 chess
Chess program written in 6502 assembly to run on <a href="https://github.com/maksimKorzh/KIM-1">KIM-1</a>

# How to run
    1. Copy and paste the code from src/chess.asm
       to the code editor at <a href="https://github.com/maksimKorzh/KIM-1">KIM-1 emulator</a>
    2. In the emulator click 'Assemble', set starting address to 0x0000, click 'Ok'
    3. Click 'Upload' button, you should see \[00 00 16\] on the screen
    4. Press 0200 on keypad, you should see \[02 00 A9\] on the screen
    5. Press 'GO' on keypad - engine would start searching for a best move
       for whites in starting position (unless you've made a move before)
       and ends up displaying best move like \[63 43 00\] which means D2D4.
    
# Board coordinates
    00: 16 14 15 17 13 15 14 16
    10: 12 12 12 12 12 12 12 12
    20: 00 00 00 00 00 00 00 00
    30: 00 00 00 00 00 00 00 00
    40: 00 00 00 00 00 00 00 00
    50: 00 00 00 00 00 00 00 00
    60: 09 09 09 09 09 09 09 09
    70: 0E 0C 0D 0F 0B 0D 0C 0E
        
        00 01 02 03 04 05 06 07 
    

# How to play
    
