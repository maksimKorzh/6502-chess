/******************************\
 ==============================

  6502 chess program for KIM-1
   (for cc65 kim1-60k target)

 ==============================
\******************************/

// libraries
#include <stdio.h>
#include <stdint.h> 
#include <stdlib.h>
#include <string.h>

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

uint8_t move_offsets[] = {
   0x00, 0x0F,  0x10, 0x11, 0x00,                             // black pawns
   0xF1, 0xF0,  0xEF, 0x00,                                   // white pawns
   0x01, 0x10,  0xFF, 0xF0, 0x00,                             // rooks
   0x01, 0x10,  0xFF, 0xF0, 0x0F, 0xF1, 0x11, 0xEF,  0x00,    // queens, kings and bishops
   0x0E, 0xF2,  0x12, 0xEE, 0x1F, 0xE1, 0x21, 0xDF,  0x00,    // knights
   0x04, 0x00,  0x0D, 0x16, 0x11, 0x08, 0x0D                  // starting indexes
};

uint8_t piece_weights_s[] = { 0x00, 0x00, 0xFD, 0x00, 0xF7, 0xF7, 0xF1, 0xE5, 0x00, 0x03, 0x00, 0x00, 0x09, 0x09, 0x0F, 0x1B };
uint8_t mat_score = 0x00, pos_score = 0x00;
int8_t score = 0x00;
uint8_t best_src = 0x00, best_dst = 0x00;
uint8_t side = 0x08;
uint8_t ply = 0;
char pieces[] = ".-pknbrq-P-KNBRQ";
uint8_t user_src, user_dst, sq, user_score, depth;

void PrintBoard() {
  uint8_t sq;
  for(sq = 0; sq < 128; sq++) {
    if(!(sq % 16)) printf(" %d  ", 8 - (sq / 16));
    printf(" %c", ((sq & 8) && (sq += 7)) ? '\n' : pieces[board[sq] & 15]);
  } printf("\n     a b c d e f g h\n\nYour move: \n");
}

uint8_t Search(uint8_t depth) {
  int8_t best_score = 0x81, found_better = 0x00;
  uint8_t temp_src = 0x00, temp_dst = 0x00;
  uint8_t src_square, dst_square, piece, type, captured_piece, directions, step_vector;
  
  if (depth == 0x00) {
    mat_score = 0x00, pos_score = 0x00;

    for(src_square = 0; src_square < 0x80; src_square++) {
      if(!(src_square & 0x88)) {
        if(board[src_square]) {          
          mat_score += piece_weights_s[board[src_square] & 15];
          (board[src_square] & 0x08) ? (pos_score += board[src_square + 0x08]) : (pos_score -= board[src_square + 0x08]);
        }
      }
    }
    return (side == 0x08) ? (mat_score + pos_score) : -(mat_score + pos_score);
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
            dst_square += step_vector;
            if(dst_square & 0x88) break;
            captured_piece = board[dst_square];
            if(captured_piece & side) break;
            if(type < 0x03 && !(step_vector & 0x07) != !captured_piece) break;
            if((captured_piece & 0x07) == 0x03) return 0x7F - ply;            
            board[dst_square] = piece;
            board[src_square] = 0x00;
            if(type < 3) {
              if(dst_square + step_vector + 1 & 0x80)
                board[dst_square]|=7;
            }
            side = 0x18 - side;
            ply++;
            score = 0-Search(depth - 0x01);
            ply--;
            board[dst_square] = captured_piece;
            board[src_square] = piece;
            side = 0x18 - side;
            if (best_score < score) {
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


int main () {
  char user_move[5];
  printf("\n\n6502 chess by Code Monkey King\n\n");
  PrintBoard();

  while(1) {
    memset(&user_move[0], 0, sizeof(user_move));
    for (sq = 0; sq < 4; sq++) {
      user_move[sq] = getchar();
      putchar(user_move[sq]);
    } putchar('\n');

    if(user_move[0] == '\n') continue;
    for(sq = 0; sq < 128; sq++) {
      if(!(sq & 0x88)) {
        if(!strncmp(user_move, notation[sq], 2)) user_src = sq;
        if(!strncmp(user_move + 2, notation[sq], 2)) user_dst = sq;
      }
    }
    board[user_dst] = board[user_src];
    board[user_src] = 0;
    if(((board[user_dst] == 9) && (user_dst >= 0 && user_dst <= 7)) ||
       ((board[user_dst] == 18) && (user_dst >= 112 && user_dst <= 119)))
        board[user_dst] |= 7;
    PrintBoard();
    side = 24 - side;
    printf("\nEnter search depth (1-3 recommended):\n");
    depth = getchar() - '0';
    user_score = Search(depth);
    board[best_dst] = board[best_src];
    board[best_src] = 0;
    if(((board[best_dst] == 9) && (best_dst >= 0 && best_dst <= 7)) ||
       ((board[best_dst] == 18) && (best_dst >= 112 && best_dst <= 119)))
        board[best_dst] |= 7;
    side = 24 - side;    // change side
    PrintBoard();
    printf("\nscore: %d\ndepth: %d\n", score, depth);
    if(user_score == 0x81 || user_score == 0x7F) {printf("Checkmate!\n"); break;}
    printf("best move: %s%s\n", notation[best_src], notation[best_dst]);
  }

  return 0;
}

