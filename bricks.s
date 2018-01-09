/**
BLOCK1:
  .word 0 # top left X
  .word 0 # top Left y
  .word 0 # COLOR
  .word 3 # hardness 0 means block isn't there anymore
BLOCK2:
  .word 0 # top left X
  .word 0 # top Left y
  .word 0 # COLOR
  .word 3 # hardness 0 means block isn't there anymore
BLOCK3:
  .word 0 # top left X
  .word 0 # top Left y
  .word 0 # COLOR
  .word 3 # hardness 0 means block isn't there anymore
BLOCK4:
  .word 0 # top left X
  .word 0 # top Left y
  .word 0 # COLOR
  .word 3 # hardness 0 means block isn't there anymore **/

.text
.include "constatns.s"

.equ BLOCK_WIDTH, 19
.equ BLOCK_HEIGHT, 10
.equ SPACE_BETWEEN_BLOCKS_X, 5
.equ SPACE_BETWEEN_BLOCKS_Y, 5
.equ BLOCKS_PER_ROW, 10
.equ NUMBER_OF_ROWS, 5
.equ NUMBER_OF_BLOCKS, 50 # should be NUMBER_OF_ROWS * BLOCKS_PER_ROW or else...
.equ TOP_LEFT_BLOCK_X, 35
.equ TOP_LEFT_BLOCK_Y, 20
.equ SIZE_OF_BLOCK_STRUCT, 16 # bytes

.equ DEFAULT_BLOCK_COLOR, 0xf14f
.equ DEFAULT_BLOCK_COLOR_1, 0xf14f
.equ DEFAULT_BLOCK_COLOR_2, 0xff5722
.equ DEFAULT_BLOCK_COLOR_3, 0x8e44ad
.equ DEFAULT_BLOCK_HARDNESS, 1

 # .global _start
 # _start:
 #   call SET_UP_BLOCKS # competed
 #
 #   call DRAW_BLOCKS # compted
 #
 #   addi r4, r0, 0 # ball x position
 #   addi r5, r0, 0 # ball y position
 #   call CHECK_BLOCKS_COLLISION # compted
 #
 #   RUN_FOREVER:
 #     br RUN_FOREVER

# Sets up all block data strcutres for the rest of the game
.global SET_UP_BLOCKS
SET_UP_BLOCKS:
  movia r8, BLOCKS
  movia r9, NUMBER_OF_ROWS
  movia r11, TOP_LEFT_BLOCK_Y # vertical offest
  addi r14, r0, 1
  add r15, r0, r0
  SET_UP_BLOCKS_OUTER_LOOP:
    movia r10, BLOCKS_PER_ROW
    movia r12, TOP_LEFT_BLOCK_X # horizontal offest
    SEUP_BLOCKS_INNER_LOOP:
      # .word 0 # top left X
      # .word 0 # top Left y
      # .word 0 # COLOR
      # .word 3 # hardness 0 means block isn't there anymore
      stw r12, 0(r8)
      stw r11, 4(r8)
      movia r13, DEFAULT_BLOCK_COLOR
      stw r13, 8(r8)
      stw r14, 12(r8)
      add r15, r15, r14 # increment total hardness
      addi r14, r14, 1
      andi r14, r14, 0b011


      addi r8, r8, SIZE_OF_BLOCK_STRUCT
      addi r12, r12, BLOCK_WIDTH
      addi r12, r12, SPACE_BETWEEN_BLOCKS_X

      addi r10, r10, -1
      bne r10, r0, SEUP_BLOCKS_INNER_LOOP

    addi r11, r11, BLOCK_HEIGHT
    addi r11, r11, SPACE_BETWEEN_BLOCKS_Y

    addi r9, r9, -1
    bne r9, r0, SET_UP_BLOCKS_OUTER_LOOP

    movia r8, BLOCKS_LEFT
    stw r15, 0(r8)
  ret

# draws all blocks on the screen using DRAW_BLOCK function
.global DRAW_BLOCKS
DRAW_BLOCKS:
  addi sp, sp, -12
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw ra, 8(sp)

  movia r16, BLOCKS # address of blocks
  movia r17, NUMBER_OF_BLOCKS # number of blocks left to write
  DRAW_BLOCKS_LOOP:
    add r4, r0, r16
    call DRAW_BLOCK

    addi r16, r16, SIZE_OF_BLOCK_STRUCT
    addi r17, r17, -1
    bne r17, r0, DRAW_BLOCKS_LOOP

  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw ra, 8(sp)
  addi sp, sp, 12
  ret

# draws one block on the screen
# r4 addresss of the block
DRAW_BLOCK:
  # .word 0 # top left X
  # .word 0 # top Left y
  # .word 0 # COLOR
  # .word 3 # hardness 0 means block isn't there anymore
  movia r13, VGA_ADDR

  ldw r8, 12(r4)
  beq r8, r0, DRAW_BLOCK_SET_COLOR_BLACK
  addi r9, r0, 1
  beq r8, r9, DRAW_BLOCK_SET_COLOR_1
  addi r9, r0, 2
  beq r8, r9, DRAW_BLOCK_SET_COLOR_2
  DRAW_BLOCK_SET_COLOR_3:
    movia r8, DEFAULT_BLOCK_COLOR_3
    br DRAW_BLOCK_SET_COLOR_DONE
  DRAW_BLOCK_SET_COLOR_2:
    movia r8, DEFAULT_BLOCK_COLOR_2
    br DRAW_BLOCK_SET_COLOR_DONE   
  DRAW_BLOCK_SET_COLOR_1:
    movia r8, DEFAULT_BLOCK_COLOR_1
    br DRAW_BLOCK_SET_COLOR_DONE    
  DRAW_BLOCK_SET_COLOR_BLACK:
    movia r8, COLOR_BLACK
  DRAW_BLOCK_SET_COLOR_DONE:

  movia r9, BLOCK_HEIGHT
  ldw r10, 4(r4) # vertical pixel position
  DRAW_BLOCK_VERTICAL_LOOP:
    movia r11, BLOCK_WIDTH
    ldw r12, 0(r4) # horizontal pixel position
    DRAW_BLOCK_HORIZONTAL_LOOP:
        add r14, r13, r0  # pixel
        slli r15, r12, 1
        add r14, r14, r15
        slli r15, r10, 10
        add r14, r14, r15
        sthio r8, 0(r14)

      addi r12, r12, 1
      addi r11, r11, -1
      bne r11, r0, DRAW_BLOCK_HORIZONTAL_LOOP

    addi r10, r10, 1
    addi r9, r9, -1
    bne r9, r0, DRAW_BLOCK_VERTICAL_LOOP

  ret

# checks if there is collsioint with the ball
# r4 the x position of the ball
# r5 the y position of the ball
# r2 bit map of what happened to the ball
.global CHECK_BLOCKS_COLLISION
CHECK_BLOCKS_COLLISION:
  addi sp, sp, -24
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw r20, 16(sp)
  stw ra, 20(sp)

  movia r16, BLOCKS # address of blocks
  movia r17, NUMBER_OF_BLOCKS # number of blocks left to check
  add r18, r0, r4
  add r19, r0, r5
  add r20, r0, r0
  CHECK_BLOCKS_COLLISION_LOOP:
    add r4, r0, r18
    add r5, r0, r19
    add r6, r0, r16
    call CHECK_BLOCK_COLLISION
    or r20, r20, r2

    addi r16, r16, SIZE_OF_BLOCK_STRUCT
    addi r17, r17, -1
    bne r17, r0, CHECK_BLOCKS_COLLISION_LOOP

  add r2, r0, r20
  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  ldw r19, 12(sp)
  ldw r20, 16(sp)
  ldw ra, 20(sp)
  addi sp, sp, 24
  ret

# checks if there is collsioint with the ball and a given block
# r4 the x position of the ball
# r5 the y position of the ball
# r6 address of brick to look at
# r2 bit map of what happened to the ball
CHECK_BLOCK_COLLISION:
  add r2, r0, r0 # set up return value

  ldw r15, 12(r6) # hardness of the block
  bne r15, r0, CHECK_BLOCKS_COLLISION_BLOCK_EXISTS
    ret

  CHECK_BLOCKS_COLLISION_BLOCK_EXISTS:
  addi r8, r4, BALL_WIDTH
  addi r8, r8, -1
  addi r9, r5, BALL_HEIGHT
  addi r9, r9, -1
  ldw r10, 0(r6) # start x position of the brick
  addi r11, r10, BLOCK_WIDTH # end x position of the brick
  ldw r12, 4(r6) # start y position of the brick
  addi r13, r12, BLOCK_HEIGHT # end y position of the brick

  # increace the size of the hit box my 1 on all sides
  subi r10, r10, BALL_WIDTH
  addi r11, r11, 0
  subi r12, r12, BALL_HEIGHT
  addi r13, r13, 0

  blt r8, r10, CHECK_BLOCKS_COLLISION_NOT_VERTICAL_COLLISION # r4 < r10 : jump
    bgt r4, r11, CHECK_BLOCKS_COLLISION_NOT_VERTICAL_COLLISION # r4 > r11 : jump
      bne r12, r9, CHECK_BLOCKS_COLLISION_NOT_HIT_TOP
        ori r2, r2, HIT_BOTTOM
      CHECK_BLOCKS_COLLISION_NOT_HIT_TOP:
      bne r13, r5, CHECK_BLOCKS_COLLISION_NOT_HIT_BOTTOM
        ori r2, r2, HIT_TOP
      CHECK_BLOCKS_COLLISION_NOT_HIT_BOTTOM:

  CHECK_BLOCKS_COLLISION_NOT_VERTICAL_COLLISION:
  blt r9, r12, CHECK_BLOCKS_COLLISION_NOT_HORIZONTAL_COLLISION
    bgt r5, r13, CHECK_BLOCKS_COLLISION_NOT_HORIZONTAL_COLLISION
      bne r10, r8, CHECK_BLOCKS_COLLISION_NOT_HIT_LEFT
        ori r2, r2, HIT_RIGHT
      CHECK_BLOCKS_COLLISION_NOT_HIT_LEFT:
      bne r11, r4, CHECK_BLOCKS_COLLISION_NOT_HIT_RIGHT
        ori r2, r2, HIT_LEFT
      CHECK_BLOCKS_COLLISION_NOT_HIT_RIGHT:

  CHECK_BLOCKS_COLLISION_NOT_HORIZONTAL_COLLISION:
  beq r2, r0, CHECK_BLOCKS_COLLISION_DONE
    addi r15, r15, -1
    stw r15, 12(r16) # save the block hardness decrememt
    # update that the block as it might have disapeared
    # we are ok with clobering calller saved registers as we no longer need them here
    addi sp, sp, -4
    stw ra, 0(sp)
    mov r4, r6
    call DRAW_BLOCK

	movia r8, BLOCKS_LEFT
    ldw r9, 0(r8)
    addi r9, r9, -1
    stw r9, 0(r8)

    beq r9, r0, CHECK_BLOCKS_DO_NOT_PLAY_WAVE

    add r4, r0, r0
    call PLAY_WAVE # start playing that one wave
    CHECK_BLOCKS_DO_NOT_PLAY_WAVE:
    ldw ra, 0(sp)
    addi sp, sp, 4
  CHECK_BLOCKS_COLLISION_DONE:
  ret
