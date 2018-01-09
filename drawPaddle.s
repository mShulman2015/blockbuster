.text
.include "constatns.s"

/*.global _start
_start:
  movia sp, 0x17fff80

  call DRAW_PADDLE

  LOOP:
    br LOOP*/

# r4: 1=> shift paddle left, 0=>shift paddle right
.global SHIFT_PADDLE
SHIFT_PADDLE:
  addi sp, sp, -20
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw ra, 16(sp)

  mov r19, r4

  addi r4, r0, 1
  call DRAW_PADDLE

  mov r4, r19

  # shift paddle
  movia r18, PADDLE_X
  ldw r16, 0(r18)
  beq r4, r0, SHIFT_PADDLE_RIGHT
    subi r16, r16, PADDLE_SHIFT_AMMOUNT
    br SHIFT_PADDLE_DONE
  SHIFT_PADDLE_RIGHT:
  addi r16, r16, PADDLE_SHIFT_AMMOUNT
  SHIFT_PADDLE_DONE:

  # adjust paddle for possible off screen
  movia r17, SCREEN_START_X
  bge r16, r17, SHIFT_PADDLE_LEFT_OK
    add r16, r0, r17
  SHIFT_PADDLE_LEFT_OK:
  movia r17, SCREEN_END_X
  subi r17, r17, PADDLE_WIDTH
  ble r16, r17, SHIFT_PADDLE_RIGHT_OK
    add r16, r0, r17
  SHIFT_PADDLE_RIGHT_OK:
  stw r16, 0(r18)

  add r4, r0, r0
  call DRAW_PADDLE

  ldw r16, 0(sp)
  ldw r17, 4(sp)
  ldw r18, 8(sp)
  ldw r19, 12(sp)
  ldw ra, 16(sp)
  addi sp, sp, 20
  ret

# r4: 0=> write true paddle, 1=> write black to loose the paddle
.global DRAW_PADDLE
DRAW_PADDLE:
  addi sp, sp, -8
  stw r16, 0(sp)
  stw ra, 4(sp)


  addi sp, sp, -4
  beq r4, r0, DRAW_PADDLE_TRUE
  DRAW_PADDLE_BLACK:
    movia r16, COLOR_BLACK
    br DRAW_PADDLE_FINAL
  DRAW_PADDLE_TRUE:
    movia r16, PADDLE_COLOR
  DRAW_PADDLE_FINAL:
    stw r16, 0(sp)

  movia r4, PADDLE_WIDTH
  movia r5, PADDLE_HEIGHT
  movia r7, PADDLE_X # Address where current x is stored
  ldw r6, 0(r7)
  movia r7, PADDLE_Y

  call DRAW_RECTANGLE

  addi sp, sp, 4 # From color above

  ldw r16, 0(sp)
  ldw ra, 4(sp)
  addi sp, sp, 8
  ret

# Draws arbitrary rectangle r4 => width, r5 => height, r6 => x, r7 => y, 0(sp) => color
.global DRAW_RECTANGLE
DRAW_RECTANGLE:
  ldw r8, 0(sp)

  addi sp, sp, -24
  stw r16, 0(sp)
  stw r17, 4(sp)
  stw r18, 8(sp)
  stw r19, 12(sp)
  stw r20, 16(sp)
  stw ra, 20(sp)

  # r16,r17 are current x,y and r18, r19 are x,y max
  add r16, r6, r0
  add r17, r7, r0
  add r18, r16, r4
  add r19, r17, r5
  RECT_LOOP:
    # If x,y out of range update
  RECT_CHECK_X_MAX:
    blt r16, r18, RECT_CHECK_Y_MAX
    add r16, r6, r0 # Reset x
    addi r17, r17, 1 # Add 1 to y
  RECT_CHECK_Y_MAX:
    bgt r17, r19, RECT_DONE
    addi r16, r16, 1

    # Write pixel
	mov r20, r6
    mov r4, r16
    mov r5, r17
    mov r6, r8
    call WRITE_PIXEL
	mov r6, r20

    br RECT_LOOP

  RECT_DONE:
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw ra, 20(sp)
    addi sp, sp, 24
    ret


# Funtion to draw a single pixel. r4 => x, r5 => y, r6 => color
WRITE_PIXEL:
  addi sp, sp, -4
  stw r16, 0(sp)

  movia r16, VGA_ADDR
  slli r4, r4, 1
  slli r5, r5, 10
  add r16, r16, r4
  add r16, r16, r5
  sthio r6, 0(r16)

  ldw r16, 0(sp)
  addi sp, sp, 4
  ret
