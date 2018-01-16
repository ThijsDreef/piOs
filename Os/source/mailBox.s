/*
  in order to send a message to a mailbox
    1. the sender waits until the status field has a 0 in the top bit
    2. the sender wrties to write such that the lowest 4 bits are the mailbox to write to,
       and the upper 28 bits are the message to write
  in order to read a message
    1. the receiver waits until the status field has a 0 in the 30th bit.
    2. the receiver reads from read
    3. the receiver confirms the message is for the correct mailbox, and tries again if not
*/

/*
  0x3F00B880 4 bytes used to receive mail read only
  0x3F00B890 4 bytes used receive without retrieving read only
  0x3F00B894 4 bytes used for information about the sender read only
  0x3F00B898 4 bytes used for status information read only
  0x3F00B89C 4 bytes used for settings read and write
  0x3F00B8A0 4 bytes used for sending mail write only
*/

@returns mailbox address in r0
.global getMailBoxAddress
getMailBoxAddress:
  ldr r0, =0x3F00B880
  mov pc, lr

/*
1.
  the input will be what to write (r0),
  and what mailbox to write it to (r1).
  first we check if its a real mailbox,
  and that the low 4 bits of the value are 0.
  NEVER FORGET TO CHECK INPUTS
2.
  use getMailBoxAddress to retrieve the address
3.
  read from the status field
4.
  check if the top bit is 0. if not go back to 3
5.
  combine the value to write and the channel
6.
  write to the write
*/
@r0 mailbox address
.global mailBoxWrite
mailBoxWrite:
  @testing the inputs
  tst r0, #0b1111
  movne pc, lr
  cmp r1, #15
  movhi pc, lr

  @get the address and set up names
  channel .req r1
  value .req r2
  mov value, r0
  push {lr}
  bl getMailBoxAddress
  mailbox .req r0

  checkWriteStatus$:
    @get the status
    status .req r3
    ldr status, [mailbox, #0x18]

    @test the status
    tst status, #0x80000000
    .unreq status
    bne checkWriteStatus$
  @combines the channel and the value since the low bit was empty
  add value, channel
  .unreq channel
  @store the value at the writable part of the mailbox
  str value, [mailbox, #0x20]
  .unreq value
  .unreq mailbox
  pop {pc}

/*
1.
  validate r0 is a valid channel
  NEVER FORGET TO CHECK INPUTS
2.
  use getMailBoxAddress to get the mailbox base
3.
  read from the status field
4.
  check the 30th bit is 0. if not, go back to 3
5.
  read from the read field
6.
  check the mailbox is the one we want, if not go back to 3
7.
  return the result
*/
.global readMailBox
readMailBox:
  @1. input validation
  cmp r0, #15
  movhi pc, lr
  @2. setup variables
  channel .req r1
  mov channel, r0
  push {lr}
  bl getMailBoxAddress
  mailbox .req r0
  @3. check for the right mailbox

  getMail$:
    checkStatus$:
      status .req r2
      ldr status, [mailbox, #0x18]
      @check the 30th bit
      tst status, #0x40000000
      .unreq status
      bne checkStatus$
    mail .req r2
    @read the tread field
    ldr mail, [mailbox, #0]

    inchannel .req r3
    @check if the mailbox is the one we want
    and inchannel, mail, #0b1111
    teq inchannel, channel
    .unreq inchannel
    bne getMail$
  .unreq mailbox
  .unreq channel
  @return the result and keep the low 4 bits off
  and r0, mail, #0xfffffff0
  .unreq mail
  pop {pc}
