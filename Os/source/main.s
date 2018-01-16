.section .init
.global _start
_start:
  b main
  .section .text
    main:
      mov sp, #0x8000
      mov r0, #1024
      mov r1, #768
      mov r2, #16
      bl initialiseFrameBuffer
      teq r0, #0
      beq error
      fbInfoAddress .req r4
      mov fbInfoAddress, r0
      render$:
        fbPointer .req r3
        ldr fbPointer, [fbInfoAddress, #32]
        colour .req r0
        y .req r1
        mov y, #768
        drawRow$:
          x .req r2
          mov x, #1024
          drawPixel$:
            strh colour, [fbPointer]
            add fbPointer, #2
            sub x, #1
            teq x, #0
            bne drawPixel$
          add colour, #1
          sub y, #1
          teq y, #0
          bne drawRow$
        b render$
