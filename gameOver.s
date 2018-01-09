.text
.include "constatns.s"

.global GAME_OVER
GAME_OVER:
  # Disable interrupts
  wrctl ctl0, r0

  call CLEAR_SCREEN
  movia r16, CHAR_ADDR
  movia r17, CHAR_X
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 71 # Char to Write
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  add r18, r18, r17
  add r18, r18, r16
  addi r19, r0, 65 # A
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 77 # M
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 69 # E
  stbio r19, 0(r18)

  addi r17,r17,2 # Add space
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 79 # O
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 86 # V
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 69 # E
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 82 # R
  stbio r19, 0(r18)


  beq r0, r4, PRINT_WIN
PRINT_LOSS:
  addi r17,r0,38
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 76 # L
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 79 # O
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 83 # S
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 69 # E
  stbio r19, 0(r18)

  br GAME_OVER_END
PRINT_WIN:
  addi r17,r0,39
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 87 # W
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 73 # I
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 78 # N
  stbio r19, 0(r18)
GAME_OVER_END:
  call SOUND_UPDATE
  movia r16, PUSH_BUTTONS
  ldwio r17, 0(r16)
  beq r17, r0, GAME_OVER_END

  # Reset memory
  movia r16, BALL_X
  addi r17, r0, 150
  stw r17, 0(r16)

  movia r16, BALL_Y
  addi r17, r0, 100
  stw r17, 0(r16)

  movia r16, BALL_X_DIR
  addi r17, r0, 1
  stw r17, 0(r16)

  movia r16, BALL_Y_DIR
  addi r17, r0, -1
  stw r17, 0(r16)

  movia r16, PADDLE_X
  addi r17, r0, 150
  stw r17, 0(r16)
CLEAR_TEXT:
  movia r16, CHAR_ADDR
  movia r17, CHAR_X
  movia r18, CHAR_Y
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # Char to Write
  stbio r19, 0(r18)
CLEAR_GO_LOOP:
  addi r17, r17, 1
  movia r18, CHAR_Y
  slli r18, r18, 7
  addi r20, r0, 44
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # Char to Write
  stbio r19, 0(r18)
  blt r17, r20, CLEAR_GO_LOOP

movia r18, CHAR_Y
addi r18, r18, 1
movia r17, CHAR_X
addi r17, r17, -1
CLEAR_SCORE:
  addi r17,r0,38
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # L
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # O
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # S
  stbio r19, 0(r18)

  addi r17,r17,1
  movia r18, CHAR_Y
  addi r18, r18, 1
  slli r18, r18, 7
  or r18, r18, r17
  or r18, r18, r16
  addi r19, r0, 0 # E
  stbio r19, 0(r18)

br _start


/*
  65 -> A
  69-> E
  71 -> G
  77 -> M
  O -> 79
  V -> 86
  E -> 69
  R -> 82
  W -> 87
  I -> 73
  N -> 78
  L -> 76
  O -> 79
  S -> 83
  E -> 69
**/
