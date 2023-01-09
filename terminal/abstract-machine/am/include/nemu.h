#ifndef NEMU_H__
#define NEMU_H__

#include <klib-macros.h>

// #include ISA_H // the macro `ISA_H` is defined in CFLAGS
//                // it will be expanded as "x86/x86.h", "mips/mips32.h", ...

// #if defined(__ISA_X86__)
// # define nemu_trap(code) asm volatile (".byte 0xd6" : :"a"(code))
// #elif defined(__ISA_MIPS32__)
// # define nemu_trap(code) asm volatile ("move $v0, %0; .word 0xf0000000" : :"r"(code))
// #elif defined(__ISA_RISCV32__) || defined(__ISA_RISCV64__)
// # define nemu_trap(code) asm volatile("mv a0, %0; .word 0x0000006b" : :"r"(code))
// #elif
// # error unsupported ISA __ISA__
// #endif


#define VGA_START 0x00200000
#define VGA_LINE_O 0x00210000
#define VGA_MAXLINE 30
#define LINE_MASK 0x003f
#define VGA_MAXCOL 70
#define KEY_START 0x00300000
#define KEY_HEAD 0x00300004
#define LED_START 0x00500000
#define TIME_START 0x00400000
#define SEG_START 0x00700000
#define BIG_VGA 0x00800000
#define VGA_SELECTOR 0x00900000
#define VGA_ROW 0x00a00000
#define VGA_COL 0x00a00004
#define VGA_ROW_START 0x00a00008
#define PROMPT_LEN 10


static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

// #if defined(__ARCH_X86_NEMU)
// # define DEVICE_BASE 0x0
// #else
// # define DEVICE_BASE 0xa0000000
// #endif

// #define MMIO_BASE 0xa0000000

// #define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
// #define KBD_ADDR        (DEVICE_BASE + 0x0000060)
// #define RTC_ADDR        (DEVICE_BASE + 0x0000048)
// #define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
// #define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
// #define DISK_ADDR       (DEVICE_BASE + 0x0000300)
// #define FB_ADDR         (MMIO_BASE   + 0x1000000)
// #define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

// extern char _pmem_start;
// #define PMEM_SIZE (128 * 1024 * 1024)
// #define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)
// #define NEMU_PADDR_SPACE \
//   RANGE(&_pmem_start, PMEM_END), \
//   RANGE(FB_ADDR, FB_ADDR + 0x200000), \
//   RANGE(MMIO_BASE, MMIO_BASE + 0x1000) /* serial, rtc, screen, keyboard */

// typedef uintptr_t PTE;

// #define PGSIZE    4096

#endif
