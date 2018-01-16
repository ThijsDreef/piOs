/*pc is next instruction
so moving lr into pc returns to the next
instruction after this function call */


/*returns address of gpio pins in r0*/
.global getGpioAddress
getGpioAddress:
  ldr r0, =0x3F200000
  mov pc, lr

/*sets the function of a gpio pin*/
/*r0 = pinNumber*/
/*r1 = pinFunction*/
.global setGpioFunction
setGpioFunction:
  /*check if inputs are correct else return early*/
  cmp r0, #53
  cmpls r1, #7
  movhi pc, lr

  /*push this lr to the stack so we can get it back later*/
  push {lr}
  mov r2, r0
  bl getGpioAddress

  /* check how many times 10 fits in the pin number and offset that amount of times in the gpio address*/
  dividePinNumber$:
    cmp r2, #9
    subhi r2, #10
    addhi r0, #4
    bhi dividePinNumber$
  /*x + x * 2 === x * 3*/
  add r2, r2, lsl #1
  lsl r1, r2

  /*move a clear bit into the function shift it to left with pinNumber*/
  /*flip the bit load the current bit add them together and upload them*/
  mov r3, #7
  lsl r3, r2
  mvn r3, r3
  ldr r2, [r0]
  and r2, r3
  orr r1, r2

  str r1, [r0]
  pop {pc}

/*sets a gpio pin to high or low*/
.global setGpio
setGpio:
  /*setting alliases */
  pinNumber .req r0
  pinValue .req r1
  /*check if number is within pin range else return */
  cmp pinNumber, #53
  movhi pc, lr
  push {lr}
  /*move pinnumber to r2 so gpioAddress doesnt override it*/
  mov r2, pinNumber
  .unreq pinNumber
  pinNumber .req r2

  bl getGpioAddress
  gpioAddress .req r0

  pinBank .req r3
  lsr pinBank, pinNumber, #5
  lsl pinBank, #2
  add gpioAddress, pinBank
  .unreq pinBank

  and pinNumber, #31
  setBit .req r3
  mov setBit, #1
  lsl setBit, pinNumber
  .unreq pinNumber

  teq pinValue, #0
  .unreq pinValue
  streq setBit, [gpioAddress, #40]
  strne setBit, [gpioAddress, #28]
  .unreq setBit
  .unreq gpioAddress
  pop {pc}

.global flash
flash:
  mov r0, #16
  mov r1, #1
  bl setGpio
  ldr r0, =1000000
  bl wait
  mov r0, #16
  mov r1, #0
  bl setGpio
  pop {pc}

.global error
error:
  mov r0, #16
  mov r1, #1
  bl setGpioFunction
  mov r0, #16
  mov r1, #1
  bl setGpio
  loop$:
    b loop$
