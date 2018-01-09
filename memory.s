.data
.align 4
.global BALL_X
BALL_X:
  .word 150
.global BALL_Y
BALL_Y:
  .word 100
.global BALL_X_DIR
BALL_X_DIR:
  .word 1
.global BALL_Y_DIR
BALL_Y_DIR:
  .word -1
.global GAME_UPDATE_READY
GAME_UPDATE_READY:
  .word 0
.global PADDLE_X
PADDLE_X:
  .word 150
.global BLOCKS_LEFT
BLOCKS_LEFT:
  .word 50 # set up in bricks
.global Sounds
Sounds:
sound0: # A4 440hz brick hit
  .word 0 # is_valid
  .word 0 # current_position
  .word 0b000011101011111 # size_of_hop
  .word 0x0 # waves_left_to_write
  .word 0x0FF # waves_left_to_write_default
sound1: # D7# 2489 paddle collition
  .word 0 # is_valid
  .word 0 # current_position
  .word 0b010100110110100 # size_of_hop
  .word 0x0 # waves_left_to_write
  .word 0x07FF # waves_left_to_write_default
sound2: # D3 147hz game_over
  .word 0 # is_valid
  .word 0 # current_position
  .word 0b000001001110110 # size_of_hop
  .word 0x0 # waves_left_to_write
  .word 0x0FF # waves_left_to_write_default
sound3: # F5 699hz vicotry
  .word 0 # is_valid
  .word 0 # current_position
  .word 0b000101110110110 # size_of_hop
  .word 0x0 # waves_left_to_write
  .word 0x03FF # waves_left_to_write_default

.align 4
.global BLOCKS
BLOCKS:
  .space 2000  # 4 * BLOCKS_PER_ROW * NUMBER_OF_ROWS
