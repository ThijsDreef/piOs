.section .init
.global _start
_start:
  b main
  .section .text
    main:
      mov sp, #0x8000
      mov r0, #16
      mov r1, #1
      bl setGpioFunction
      @load the pattern
      ptrn .req r4
      ldr ptrn, =pattern
      ldr ptrn, [ptrn]
      @setup the part of the sequence to check
      seq .req r5
      mov seq, #0
      loop$:
        mov r0, #16
        @mov r1 1 << seq
        mov r1, #1
        lsl r1, seq
        and r1, ptrn
        @set gpio
        bl setGpio
        @if seq > pattern seq == 0
        add seq, #1
        and seq, #0b11111
        @wait for 0.4 seconds
        ldr r0, =400000
        bl wait
        b loop$

  .section .data
    .align 2
    pattern:
      .int 0b00000000010101011101110111010101
