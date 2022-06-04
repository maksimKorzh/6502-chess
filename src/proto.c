/******************************\
 ==============================

  6502 chess program for KIM-1
       (prototype in C) 

 ==============================
\******************************/

// libraries
#include <stdio.h>
#include <stdint.h> 

/******************************\
 ==============================

         Chess program

 ==============================
\******************************/

uint8_t board[128] = {
  0x16, 0x14, 0x15, 0x17, 0x13, 0x15, 0x14, 0x16,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x01, 0x02, 0x02, 0x01, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x01, 0x02, 0x02, 0x01, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00,
  0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x0E, 0x0C, 0x0D, 0x0F, 0x0B, 0x0D, 0x0C, 0x0E,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

uint8_t move_offsets[] = {
   0x00, 0x0F,  0x10, 0x11, 0x00,                             // white pawns
   0x8F, 0x90,  0x91, 0x00,                                   // black pawns
   0x01, 0x10,  0x81, 0x90, 0x00,                             // rooks
   0x01, 0x10,  0x81, 0x90, 0x0F, 0x8F, 0x11, 0x91,  0x00,    // queens, kings and bishops
   0x0E, 0x8E,  0x12, 0x92, 0x1F, 0x9F, 0x21, 0xA1,  0x00,    // knights
   0x04, 0x00,  0x0D, 0x16, 0x11, 0x08, 0x0D                  // starting indexes
};

uint8_t piece_weights[] = { 0x00, 0x03, 0x03, 0x00, 0x09, 0x09, 0x0F, 0x1B, 0x00};
int mat_score = 0x00, pos_score = 0x00, eval = 0x00;
int score;
uint8_t best_src, best_dst;
uint8_t side = 0x08;

int Search(uint8_t depth) {
  //int best_score = 0x7F | 0x80;
  int best_score = -0x7F;
  uint8_t temp_src = 0x00, temp_dst = 0x00;
  uint8_t src_square, dst_square, piece, type, captured_piece, directions, step_vector;
  
  if (depth == 0x00) {
    mat_score = 0x00, pos_score = 0x00, eval = 0x00;
    
    int mat_white = 0, mat_black = 0, pos_white = 0, pos_black = 0;
    
    for(src_square = 0; src_square < 0x80; src_square++) {
      if(!(src_square & 0x88)) {
        if(board[src_square]) {          
          if (board[src_square] & 0x08) mat_white += piece_weights[board[src_square] & 0x07];
          else mat_black += piece_weights[board[src_square] & 0x07];
          if (board[src_square] & 0x08) pos_white += board[src_square + 0x08];
          else pos_black += board[src_square + 0x08];
        }
      }
    }

    if ((mat_white - mat_black) >= 0) mat_score = mat_white - mat_black;
    else mat_score = (mat_black - mat_white) | 0x80;
    
    if ((pos_white - pos_black) >= 0) pos_score = pos_white - pos_black;
    else pos_score = (pos_black - pos_white) | 0x80;
    
    if ((mat_score & 0x80) && (pos_score & 0x80)) {
      mat_score &= 0x7F;
      pos_score &= 0x7F;
      //eval = (mat_score + pos_score) | 0x80; // correct
      eval = -(mat_score + pos_score);
      return (side == 0x08) ? eval : -eval;
    }
    
    else if (mat_score & 0x80) {
      mat_score &= 0x7F;
      pos_score &= 0x7F;
      if (pos_score >= mat_score) eval = pos_score - mat_score;
      //else eval = (mat_score - pos_score) | 0x80; // correct
      else eval = -(mat_score - pos_score);
      return (side == 0x08) ? eval : -eval;
    }
    
    else if (pos_score & 0x80) {
      mat_score &= 0x7F;
      pos_score &= 0x7F;
      if (mat_score >= pos_score) eval = mat_score - pos_score;
      //else eval = (pos_score - mat_score) | 0x80; // correct
      else eval = -(pos_score - mat_score);
      return (side == 0x08) ? eval : -eval;
    }
    
    else {    
      eval = mat_score + pos_score;
      return (side == 0x08) ? eval : -eval;
    }
  }
   
  for(src_square = 0x00; src_square < 0x80; src_square++) {
    if(!(src_square & 0x88)) {
      piece = board[src_square];
      if(piece & side) {
        type = piece & 0x07;
        directions = move_offsets[type + 0x1F];
        while(step_vector = move_offsets[++directions]) {
          dst_square = src_square;
          do {
            if (step_vector & 0x80) dst_square -= (step_vector & 0x7F);
            else dst_square += (step_vector & 0x7F);
            if(dst_square & 0x88) break;
            captured_piece = board[dst_square];
            if(captured_piece & side) break;
            if(type < 0x03 && !(step_vector & 0x07) != !captured_piece) break;
            if((captured_piece & 0x07) == 0x03)  return 0x7F;
            board[dst_square] = piece;
            board[src_square] = 0x00;
            side = 0x18 - side;
            //PrintBoard(); getchar();
            score = Search(depth - 0x01);
            score = -score;
            
            board[dst_square] = captured_piece;
            board[src_square] = piece;
            side = 0x18 - side;
            //PrintBoard(); getchar();
            if (score > best_score) {
              best_score = score;
              temp_src = src_square;
              temp_dst = dst_square;
            }

            captured_piece += type < 0x05;
            if(type < 0x03 & 0x06*side + (dst_square & 0x70) == 0x80)captured_piece--;
          }
          while(!captured_piece);
        }
      }
    }
  }
  
  best_src = temp_src;
  best_dst = temp_dst;
  return best_score;  
}

/******************************\
 ==============================

           Debugging

 ==============================
\******************************/

char *pieces[] = {
	".", "-", "\u265F", "\u265A", "\u265E", "\u265D", "\u265C", "\u265B", 
	"-", "\u2659", "-", "\u2654", "\u2658", "\u2657", "\u2656", "\u2655"
};

void PrintBoard() {
    for(uint8_t sq = 0; sq < 128; sq++) {
      if(!(sq % 16)) printf(" %d  ", 8 - (sq / 16));
      printf(" %s", ((sq & 8) && (sq += 7)) ? "\n" : pieces[board[sq] & 15]);
    } printf("\n     a b c d e f g h\n");
}

/******************************\
 ==============================

          Test drive

 ==============================
\******************************/

int main () {
  PrintBoard();
  while(1) {
    int score = Search(0x03);
    board[best_dst] = board[best_src];
    board[best_src] = 0;
    side = 0x18 - side;
    //PrintBoard(); getchar();
    if (score == -0x7F) break;
  }
  PrintBoard();
  printf("Checkmate!\n");
  return 0;
}
