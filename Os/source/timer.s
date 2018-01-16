/*returns timer addres in r0 */
.global getTimerAddress
getTimerAddress:
  ldr r0, =0x3F003000
  mov pc, lr
/*returns the current time stamp*/
.global getTimeStamp
getTimeStamp:
  push {lr}
  bl getTimerAddress
  ldrd r0, r1, [r0, #4]
  pop {pc}

/*r0 is the ms time to wait*/
.global wait
wait:
  delay .req r2
  mov delay, r0
  push {lr}
  bl getTimeStamp
  start .req r3
  mov start, r0
  loop$:
    bl getTimeStamp
    elapsed .req r1
    sub elapsed, r0, start
    cmp elapsed, delay
    .unreq elapsed
    bls loop$
  .unreq start
  .unreq delay
  pop {pc}
