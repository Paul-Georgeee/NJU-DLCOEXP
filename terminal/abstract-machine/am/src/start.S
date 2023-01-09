.section entry, "ax"
.globl _start
.type _start, @function

_start:
  lui sp, 0x001ff
  addi sp, sp, -4
  jal _trm_init
