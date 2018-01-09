.text

.include "constatns.s"

# .equ REFRESH_RATE_HI, 0x003D # 25fps
# .equ REFRESH_RATE_LOW, 0x0900

.equ REFRESH_RATE_HI, 0x002D # 25fps
.equ REFRESH_RATE_LOW, 0x0900

.equ BALL_SPEED, 1
.equ BALL_COLOR, 0xF11F

.global _start
_start:
  movia sp, 0x17fff80

  # Set up
  call CLEAR_SCREEN
  add r4, r0, r0
  call DRAW_PADDLE
  call SET_UP_BLOCKS
  call DRAW_BLOCKS

  # Setup frame timer
  movia r16, TIMER1_ADDR
  # Write lower and upper timeout
  movia r17, REFRESH_RATE_LOW
  movia r18, REFRESH_RATE_HI
  sthio r17, 8(r16)
  sthio r18, 12(r16)
  # Clear inturrupt for timer
  stbio r0, 0(r16)
  stbio r0, 4(r16)
  # Enable interrupts on timer
  addi r17, r0, 1
  stwio r17, 4(r16)

  call ENABLE_LEGO

  # Enable global interupts and IRQ0
  addi r17, r0, 0b0100000000001 # 0 and 11th
  wrctl ctl3, r17
  addi r17, r0, 1
  wrctl ctl0, r17

  # Start timer
  addi r17, r0, 0b111
  stbio r17, 4(r16)

  LOOP_FOREVER:
    call SOUND_UPDATE # try to keep sounds up to date
    movia r8, GAME_UPDATE_READY
    ldw r9, 0(r8)
    beq r9, r0, LOOP_FOREVER
    stw r0, 0(r8)

    # Load x (r16), y (r17) and directions (r18,r19)
    movia r20, BALL_X
    movia r21, BALL_Y
    ldw r16, 0(r20)
    ldw r17, 0(r21)
    movia r20, BALL_X_DIR
    movia r21, BALL_Y_DIR
    ldw r18, 0(r20)
    ldw r19, 0(r21)

    mov r4, r16
    mov r5, r17
    call COLLISION_CHECK

    CHECK_X_MIN:
      andi r8, r2, HIT_LEFT
      beq r8, r0, CHECK_X_MAX
      muli r18, r18, -1
    CHECK_X_MAX:
      andi r8, r2, HIT_RIGHT
      beq r8, r0, CHECK_Y_MIN
      muli r18, r18, -1
    CHECK_Y_MIN:
      andi r8, r2, HIT_TOP
      beq r8, r0, CHECK_Y_MAX
      muli r19, r19, -1
    CHECK_Y_MAX:
      andi r8, r2, HIT_BOTTOM
      beq r8, r0, END_COLLISION_DETECTION
      muli r19, r19, -1

    END_COLLISION_DETECTION:

    addi r4, r0, 1
    call DRAW_BALL
    # Save new directions to memory
    movia r20, BALL_X_DIR
    movia r21, BALL_Y_DIR
    stw r18, 0(r20)
    stw r19, 0(r21)

    # Compute BALL_BALL_SPEED*direction and add to x,y
    muli r18, r18, BALL_SPEED
    muli r19, r19, BALL_SPEED
    add r16, r16, r18
    add r17, r17, r19

    # Save new x,y
    movia r20, BALL_X
    movia r21, BALL_Y
    stw r16, 0(r20)
    stw r17, 0(r21)

    # Redraw ball
    add r4, r0, r0
    call DRAW_BALL

	movia r20, BALL_Y
    ldw r16, 0(r20)
    movia r17, FLOOR
    blt r16, r17, GAME_NOT_OVER
      addi r4, r0, 2
      call PLAY_WAVE
      addi r4, r0, 1
	  call GAME_OVER

    GAME_NOT_OVER:
       movia r20, BLOCKS_LEFT
       ldw r16, 0(r20)
       bne r16, r0, LOOP_FOREVER
         addi r4, r0, 3
         call PLAY_WAVE
       	 addi r4, r0, 0
         call GAME_OVER

    br LOOP_FOREVER

# r4, balll_x
# r5, ball_y
# r2, retured bit map of collision in formation
COLLISION_CHECK:
  addi sp, sp, -32
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw r20, 16(sp)
  stw ra, 20(sp)
  stw r4, 24(sp)
  stw r5, 28(sp)

  add r20, r0, r0
  # Detect collision with walls
  movia r16, SCREEN_START_X
  movia r17, SCREEN_END_X
  subi r17, r17, BALL_WIDTH
  movia r18, SCREEN_START_Y
  movia r19, SCREEN_END_Y
  subi r19, r19, BALL_HEIGHT

  bne r4, r16, COLLISION_CHECK_NOT_LEFT
    ori r20, r20, HIT_LEFT
  COLLISION_CHECK_NOT_LEFT:
  bne r4, r17, COLLISION_CHECK_NOT_RIGHT
    ori r20, r20, HIT_RIGHT
  COLLISION_CHECK_NOT_RIGHT:
  bne r5, r18, COLLISION_CHECK_NOT_TOP
    ori r20, r20, HIT_TOP
  COLLISION_CHECK_NOT_TOP:
  bne r5, r19, COLLISION_CHECK_NOT_BOTTOM
    ori r20, r20, HIT_BOTTOM
  COLLISION_CHECK_NOT_BOTTOM:

  call CHECK_BLOCKS_COLLISION
  # add r2, r0, r0
  or r2, r2, r20

  ldw r4, 24(sp) # ball_x
  ldw r5, 28(sp) # ball_y
  movia r16, PADDLE_Y
  addi r16, r16, -4
  ble r5, r16, COLLISOIN_CHECK_DONE
	movia r16, PADDLE_X
    ldw r17, 0(r16)
    addi r18, r17, PADDLE_WIDTH
    bgt r4, r18, COLLISOIN_CHECK_DONE
    blt r4, r17, COLLISOIN_CHECK_DONE
      addi r4, r0, 1
      call PLAY_WAVE
      ori r2, r2, HIT_BOTTOM

  COLLISOIN_CHECK_DONE:
  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  ldw r19, 12(sp)
  ldw r20, 16(sp)
  ldw ra, 20(sp)
  addi sp, sp, 32
  ret

# r4: 0=> write true ball, 1=> write black to loose the ball
DRAW_BALL:
  addi sp, sp, -8
  stw r16, 0(sp)
  stw ra, 4(sp)

  addi sp, sp, -4
  beq r4, r0, DRAW_BALL_TRUE
  DRAW_BALL_BLACK:
    movia r16, COLOR_BLACK
    br DRAW_BALL_FINAL
  DRAW_BALL_TRUE:
    movia r16, BALL_COLOR
  DRAW_BALL_FINAL:
    stw r16, 0(sp)

  movia r4, BALL_WIDTH
  movia r5, BALL_HEIGHT
  movia r7, BALL_X # Address where current x is stored
  ldw r6, 0(r7)
  movia r7, BALL_Y # Address where current Y is stored
  ldw r7, 0(r7)

  call DRAW_RECTANGLE
  addi sp, sp, 4

  ldw r16, 0(sp)
  ldw ra, 4(sp)
  addi sp, sp, 8
  ret

.global CLEAR_SCREEN
CLEAR_SCREEN:
  # Save regs to stack
  addi sp, sp, -28
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw r20, 16(sp)
  stw r21, 20(sp)
  stw ra, 24(sp)

  # x => r16, y => r17, base => r18, result => r19, temp r20:r21
  movia r16, SCREEN_START_X
  addi r16, r0, -1
  movia r17, SCREEN_START_Y
  movia r18, VGA_ADDR
  CLEAR_SCREEN_LOOP:
    # Increment x,y and write 0xFFFF to result
    addi r16, r16, 1
    slli r20, r16, 1
    slli r21, r17, 10
    add r19, r0, r0
    or r19, r20, r21
    or r19, r19, r18
    movia r20, COLOR_BLACK
    sthio r20, 0(r19)

    # Upadate x,y or exit function
    movia r20, SCREEN_END_X
    bne r16, r20, CLEAR_SCREEN_LOOP
    #movia r16, SCREEN_START_X
    addi r16, r0, 0
    addi r17, r17, 1
    movia r20, SCREEN_END_Y
    bne r20, r17, CLEAR_SCREEN_LOOP

  # restore regs
  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  ldw r19, 12(sp)
  ldw r20, 16(sp)
  ldw r21, 20(sp)
  ldw ra, 24(sp)
  addi sp, sp, 28
  ret

ENABLE_LEGO:
  addi sp, sp, -12
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)

  movia r16, JP1
  movia r17, 0x07f557ff # set up sensor input output ports
  stwio r17, 4(r16)

  # set up threshold for sensor 0
  movia r17, 0xF83FFBFF
  movia r18, SENSOR_THRESHOLD
  slli r18, r18, 23
  or r17, r17, r18
  stwio r17, 0(r16)
  movia r17, 0xFFFFFFFF
  stwio r17, 0(r16)

  # set up threshold for sensor 1
  movia r17, 0xF83FEFFF
  movia r18, SENSOR_THRESHOLD
  slli r18, r18, 23
  or r17, r17, r18
  stwio r17, 0(r16)
  movia r17, 0xFB5FFFFF
  stwio r17, 0(r16)

  # enable interupts for sensor 0 and 1
  movia r17, 0x18000000  # enable interupts for sensors
  stwio r17, 8(r16)
  movia r17, 0xFFFFFFFF # clear current interupts
  stwio r17, 12(r16)

  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  addi sp, sp, 12
  ret



.section .exceptions, "ax"
ISRS:
# Sensor Interrupt check
rdctl et, ctl4
andi et, et, 0x0800 # Eleventh bit
bne et, r0, SENSOR_ISR

# Timer interrupt check
rdctl et, ctl4
andi et, et, 0x01 # Zeroth bit
bne r0, et, TIMER_ISR

# Not expected exceptions
addi ea, ea, -4
eret
SENSOR_ISR:
  # Store regs
  addi sp, sp, -28
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw r20, 16(sp)
  stw r4, 20(sp)
  stw ra, 24(sp)

  # Determine if left or right
  movia r16, JP1
  ldwio r17, 12(r16)
  movia r18, 0x08000000
  and r17, r17, r18 # Get sen0 above(1)/below(0), this will be 0 if sen1, >0 if sen0
  beq r17, r0, SENSOR_CHECK_SEN1
  addi r4, r0, 1
  call SHIFT_PADDLE
  br SENSOR_DONE

SENSOR_CHECK_SEN1:
  ldwio r17, 12(r16)
  movia r18, 0x10000000
  and r17, r17, r18 # Get sen0 above(1)/below(0), this will be 0 if sen1, >0 if sen0
  beq r17, r0, SENSOR_DONE
  addi r4, r0, 0
  call SHIFT_PADDLE
  br SENSOR_DONE

SENSOR_DONE:
  # Clear Edge Capture Register
  movia r19, 0xFFFFFFFF
  movia r18, JP1
  stwio r19, 12(r18)

  #Restore regs
  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  ldw r19, 12(sp)
  ldw r20, 16(sp)
  ldw r4, 20(sp)
  ldw ra, 24(sp)
  addi sp, sp, 28

  # Exception return
  addi ea, ea, -4
  eret

TIMER_ISR:
  # Save all registers used
  addi sp, sp, -8
  stw r16, 0(sp)
  stw r17, 4(sp)

  # allow for an upadte to occer
  movia r16, GAME_UPDATE_READY
  addi r17, r0, 1
  stw r17, 0(r16)

  # Reset timer
  movia r16, TIMER1_ADDR
  stwio r0, 0(r16)

  # Restore registers
  ldw r16, 0(sp)
  ldw r17, 4(sp)
  addi sp, sp, 8

  # Clear interrup
  addi et, r0, 1
  wrctl ctl4, et
  addi ea, ea, -4
  eret
