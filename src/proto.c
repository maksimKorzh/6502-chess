/******************************\
 ==============================

  6502 chess program for KIM-1
       (prototype in C) 

 ==============================
\******************************/

// libraries
#include <stdio.h>

/******************************\
 ==============================

         Chess program

 ==============================
\******************************/

int board[128] = {
  0x16, 0x14, 0x15, 0x17, 0x13, 0x15, 0x14, 0x16,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x07, 0x07, 0x07, 0x07, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x07, 0x0F, 0x0F, 0x07, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x07, 0x0F, 0x0F, 0x07, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   0x00, 0x00, 0x07, 0x07, 0x07, 0x07, 0x00, 0x00,
  0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x0E, 0x0C, 0x0D, 0x0F, 0x0B, 0x0D, 0x0C, 0x0E,   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static int move_offsets[] = {
   0x00, 0x0F,  0x10, 0x11, 0x00,                             // white pawns
   0x8F, 0x90,  0x91, 0x00,                                   // black pawns
   0x01, 0x10,  0x81, 0x90, 0x00,                             // rooks
   0x01, 0x10,  0x81, 0x90, 0x0F, 0x8F, 0x11, 0x91,  0x00,    // queens, kings and bishops
   0x0E, 0x8E,  0x12, 0x92, 0x1F, 0x9F, 0x21, 0xA1,  0x00,    // knights
   0x04, 0x00,  0x0D, 0x16, 0x11, 0x08, 0x0D                  // starting indexes
};

int piece_weights[] = { 0x00, 0x1C, 0x1C, 0x00, 0x54, 0x86, 0x8C, 0xFF, 0x00};
int mat_score = 0x00, pos_score = 0x00, eval = 0x00;
int score, best_src, best_dst;
int side = 0x08;

int Search(int depth) {
  int best_score = -10000, temp_src = 0x00, temp_dst = 0x00;
  int src_square, dst_square, piece, type, captured_piece, directions, step_vector;
  
  if (depth == 0x00) {
    mat_score = 0x00, pos_score = 0x00, eval = 0x00;
    for(src_square = 0; src_square < 0x80; src_square++) {
      if(!(src_square & 0x88)) {
        if(board[src_square]) {
          if (board[src_square] & 0x08) mat_score += piece_weights[board[src_square] & 0x07];
          else mat_score -= piece_weights[board[src_square] & 0x07];
          if (board[src_square] & 0x08) pos_score += board[src_square + 0x08];
          else pos_score -= board[src_square + 0x08];
        }
      }
    }

    eval = mat_score + pos_score;
    return (side == 0x08) ? eval : -eval;
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
            if((captured_piece & 0x07) == 0x03)  return 10000;
            board[dst_square] = piece;
            board[src_square] = 0x00;
            side = 0x18 - side;
            //PrintBoard(); getchar();
            score = -Search(depth - 0x01);
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

       Debugging helpers

 ==============================
\******************************/

char *notation[] = {

    "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",     "i8","j8","k8","l8","m8","n8","o8", "p8",
    "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",     "i7","j7","k7","l7","m7","n7","o7", "p7",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",     "i6","j6","k6","l6","m6","n6","o6", "p6",
    "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",     "i5","j5","k5","l5","m5","n5","o5", "p5",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",     "i4","j4","k4","l4","m4","n4","o4", "p4",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",     "i3","j3","k3","l3","m3","n3","o3", "p3",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",     "i2","j2","k2","l2","m2","n2","o2", "p2",
    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",     "i1","j1","k1","l1","m1","n1","o1", "p1",

};

char *pieces[] = {
	".", "-", "\u265F", "\u265A", "\u265E", "\u265D", "\u265C", "\u265B", 
	"-", "\u2659", "-", "\u2654", "\u2658", "\u2657", "\u2656", "\u2655"
};

void PrintBoard() {
    for(int sq = 0; sq < 128; sq++) {
      if(!(sq % 16)) printf(" %d  ", 8 - (sq / 16));
      printf(" %s", ((sq & 8) && (sq += 7)) ? "\n" : pieces[board[sq] & 15]);
    }
    
    printf("\n     a b c d e f g h\n\n");
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
    PrintBoard(); getchar();
    if (score == -10000) break;
  }
  PrintBoard();
  printf("Checkmate!\n");
  return 0;
}
