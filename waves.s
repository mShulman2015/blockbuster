.text
.include "constatns.s"

.equ SOUND, 0xFF203040

.equ numSounds, 4 # total number of sounds we have
.equ sizeOfSound, 20 # how large is the sound struct in bytes
.equ ampletude, 0x0FFFFFFF

.equ pi,  0b011001001000011111
.equ twopi, 0b110010010000111111
.equ c0,  0b001000000000000000 # 1/(1!) 0000 1000 => a=0
.equ c1,  0b000001010101010101 # 1/(3!)
.equ c2,  0b000000000100010001 # 1/(5!)
.equ c3,  0b000000000000000110 # 1/(7!)
.equ float_offset, 15

.global SOUND_UPDATE
SOUND_UPDATE:
   addi sp, sp, -4
   stw ra, 0(sp)

   SOUND_UPDATE_LOOP:
     # verify that there is write data left
     movia r8, SOUND
     ldwio r9, 4(r8)
     srli r9, r9, 16
     andi r9, r9, 0x00FF
     beq r9, r0, SOUND_DONE

     add r10, r0, r0 # holds the final value to write
     add r11, r0, r0 # sound number
     PER_SOUND_LOOP:
       # set r12 to the location of current sounds we're working on
       muli r13, r11, sizeOfSound # ofset
       movia r12, Sounds # base
       add r12, r12, r13

       # r10 is where to write (add to it)
       # r12 is the sounds base location
       ldw r13, 0(r12)
       beq r13, r0, NEXT_SOUND # if invalid, skip

       # sound if valid, generate next value
       ldw r13, 4(r12)
       movia r14, pi
       sub r13, r13, r14 # r13 - r14 => value - pi

       # r13: x-pi
       # r14: contains (x-pi)^k
       # r15: current value of series
       # r16: coeficient

       sub r15, r0, r13 # first value  => -(x-pi) => 0 - (x - pi)

       # mul r14, r13, r13
       # srli r14, r14, float_offset
       add r4, r0, r13
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2
       # mul r14, r14, r13
       # srli r14, r14, float_offset # r14 = (x-pi^3)
       add r4, r0, r14
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2  # r14 = (x-pi^3)
       # movia r16, c1
       # mul r16, r14, r16
       # srli r16, r16, float_offset
       movia r4, c1
       add r5, r0, r14
       call WAVES_MUTIPLY_ACURATLY
       add r15, r15, r2

       # mul r14, r14, r13
       # srli r14, r14, float_offset
       add r4, r0, r14
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2
       # mul r14, r14, r13
       # srli r14, r14, float_offset # r14 = (x-pi^5)
       add r4, r0, r14
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2
       # movia r16, c2
       # mul r16, r14, r16
       # srli r16, r16, float_offset
       movia r16, c2
       add r5, r0, r14
       call WAVES_MUTIPLY_ACURATLY
       sub r15, r15, r2

       # mul r14, r14, r13
       # srli r14, r14, float_offset
       add r4, r0, r14
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2
       # mul r14, r14, r13
       # srli r14, r14, float_offset # r14 = (x-pi^7)
       add r4, r0, r14
       add r5, r0, r13
       call WAVES_MUTIPLY_ACURATLY
       add r14, r0, r2
       # movia r16, c3
       # mul r16, r14, r16
       # srli r16, r16, float_offset
       movia r4, c3
       add r5, r0, r14
       call WAVES_MUTIPLY_ACURATLY
       add r15, r15, r2

       # save value to final wave
       add r10, r10, r15

       ldw r13, 4(r12)
       ldw r14, 8(r12)
       add r13, r13, r14
       movia r14, twopi
       blt r13, r14, NO_OVERFLOW
       OVERFLOW:
         add r13, r0, r0 # start value back to 0
         stw r13, 4(r12)

         ldw r13, 12(r12)
         addi r13, r13, -1
         stw r13, 12(r12)
         bne r13, r0, STILL_VALID
         INVVALIDATE:
           stw r0, 0(r12)
         STILL_VALID:
         br NEXT_SOUND
       NO_OVERFLOW:
         stw r13, 4(r12)

       # check if more sounds
       NEXT_SOUND:
         addi r11, r11, 1
         addi r12, r0, numSounds
         bne r11, r12, PER_SOUND_LOOP

     # take the value of sin wave in r10, and scale it
     # r10 => value of sin
     movia r4, ampletude
     add r5, r0, r10
     call WAVES_MUTIPLY_ACURATLY

     # write the sound to both FIFOs
     stwio r2, 8(r8)
     stwio r2, 12(r8)
     br SOUND_UPDATE_LOOP

 SOUND_DONE:
 ldw ra, 0(sp)
 addi sp, sp, 4
 ret

# r4=> first value
# r5=> second value
# r2=> value returned
WAVES_MUTIPLY_ACURATLY:
  srai r17, r4, 16 # a
  andi r18, r4, 0xFFFF # b
  srai r19, r5, 16 # c
  andi r20, r5, 0xFFFF # d

  mul r21, r17, r19 # a*c
  slli r2, r21, 17 # 32 - 15

  mul r21, r17, r20 # a*d
  mul r22, r18, r19 # b*c
  add r21, r21, r22
  slli r21, r21, 1 # 16 - 15
  add r2, r2, r21

  mul r21, r18, r20
  srai r21, r21, 15 # shift right
  add r2, r2, r21

  ret

# r4=> number ID of the wave to be played
.global PLAY_WAVE
PLAY_WAVE:
	movia r8, Sounds
	muli r9, r4, sizeOfSound
	add r8, r8, r9
	addi r9, r0, 1
    stw r9, 0(r8) # set valid
    stw r0, 4(r8) # set current position
	ldw r9, 16(r8) # set defualt waves left to right
	stw r9, 12(r8) # set waves left to right
	ret
