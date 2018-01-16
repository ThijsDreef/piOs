.section .data
  .align 12
  .global frameBufferInfo
  frameBufferInfo:
    .int 1024;  #0 physical width
    .int 768;   #4 physical height
    .int 1024;  #8 virtual width
    .int 768;   #12 virtual height
    .int 0;     #16 gpu pitch
    .int 16;    #20 bit depth
    .int 0;     #24 x
    .int 0;     #28 y
    .int 0;     #32 gpu pointer
    .int 0;     #36 gpu size

.section .text
  .global initialiseFrameBuffer
  initialiseFrameBuffer:
    @check if inputs are correct if they are not retun 0
    width .req r0
    height .req r1
    bitDepth .req r2
    cmp width, #4096
    cmpls height, #4096
    cmpls bitDepth, #32
    result .req r0
    movhi result, #0
    movhi pc, lr
    @setup the fboinfoaddress and add the values to the struct
    push {r4, lr}
    fbInfoAddress .req r4
    ldr fbInfoAddress, =frameBufferInfo
    str width, [r4, #0]
    str height, [r4, #4]
    str width, [r4, #8]
    str height, [r4, #12]
    str bitDepth, [r4, #20]
    .unreq width
    .unreq height
    .unreq bitDepth
    @prepare the letter to the gpu
    mov r0, fbInfoAddress
    add r0, #0xC0000000
    mov r1, #1
    bl mailBoxWrite
    @read the answer the gpu gives you
    mov r0, #1
    bl readMailBox
    @if result != 0 return a 0 because creation failed
    teq result, #0
    movne result, #0
    popne {r4, pc}
    @set the result on r0 and return
    mov result, fbInfoAddress
    .unreq result
    .unreq fbInfoAddress
    pop {r4, pc}
