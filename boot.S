/*----------------------------------------------------------*
   AT91SAM7S64..256 startup code Ver1.8
                                       Last Edit '06 07/31
   Copyright (c) 2006 BestTechnology CO.,LTD.
 *----------------------------------------------------------*/

#define REG_BASE                      0xFFFFF000
#define CKGR_MOR_OFFSET               0xC20
#define CKGR_PLLR_OFFSET              0xC2C
#define PMC_MCKR_OFFSET               0xC30
#define PMC_SR_OFFSET                 0xC68
#define RSTC_MR_OFFSET                0xD08
#define WDT_MR_OFFSET                 0xD44
#define MC_RCR_OFFSET                 0xF00
#define MC_FMR_OFFSET                 0xF60

#define CKGR_MOR_MOSCEN               (1 << 0)
#define CKGR_MOR_OSCBYPASS            (1 << 1)
#define CKGR_MOR_OSCOUNT_BIT_OFFSET   (8)

#define CKGR_PLLR_DIV_BIT_OFFSET      (0)
#define CKGR_PLLR_PLLCOUNT_BIT_OFFSET (8)
#define CKGR_PLLR_OUT_BIT_OFFSET      (14)
#define CKGR_PLLR_MUL_BIT_OFFSET      (16)
#define CKGR_PLLR_USBDIV_BIT_OFFSET   (28)

#define PMC_MCKR_CSS_MAIN_CLOCK       (0x1)
#define PMC_MCKR_CSS_PLL_CLOCK        (0x3)
#define PMC_MCKR_PRES_CLK             (0)
#define PMC_MCKR_PRES_CLK_2           (1 << 2)
#define PMC_MCKR_PRES_CLK_4           (2 << 2)
#define PMC_MCKR_PRES_CLK_8           (3 << 2)
#define PMC_MCKR_PRES_CLK_16          (4 << 2)
#define PMC_MCKR_PRES_CLK_32          (5 << 2)
#define PMC_MCKR_PRES_CLK_64          (6 << 2)

#define PMC_SR_MOSCS                  (1 << 0)
#define PMC_SR_LOCK                   (1 << 2)
#define PMC_SR_MCKRDY                 (1 << 3)
#define PMC_SR_PCKRDY0                (1 << 8)
#define PMC_SR_PCKRDY1                (1 << 9)
#define PMC_SR_PCKRDY2                (1 << 10)

#define MC_RCR_RCB                    (1 << 0)

#define MC_FMR_FWS_0FWS               (0)
#define MC_FMR_FWS_1FWS               (1 << 8)
#define MC_FMR_FWS_2FWS               (2 << 8)
#define MC_FMR_FWS_3FWS               (3 << 8)
#define MC_FMR_FMCN_BIT_OFFSET        (16)

#define WDT_MR_WDDIS                  (1 << 15)


  .equ      IRQ_Stack_Size,    0x00000080

  .equ      AIC_IVR,        (256)
  .equ      AIC_FVR,        (260)
  .equ      AIC_EOICR,      (304)
  .equ      AT91C_BASE_AIC, (0xFFFFF000)

  .equ      ARM_MODE_FIQ,   0x11
  .equ      ARM_MODE_IRQ,   0x12
  .equ      ARM_MODE_SVC,   0x13

  .equ      I_BIT,          0x80
  .equ      F_BIT,          0x40


  .section  .internal_ram_top
  .code     32
  .align    0
  .global   Top_Stack

/*****************************************************************************
  Stack
 *****************************************************************************/
Top_Stack:
  .section  .vectors, "ax"
  .code     32
  .align    0
 
/*****************************************************************************
  Exception Vectors
 *****************************************************************************/
_vectors:
//  ldr   pc, [pc, #reset_handler_address - . - 8]  // reset
  b     reset_handler
  ldr   pc, [pc, #undef_handler_address - . - 8]  // undefined instruction
  ldr   pc, [pc, #swi_handler_address - . - 8]    // swi handler
  ldr   pc, [pc, #pabort_handler_address - . - 8] // abort prefetch
  ldr   pc, [pc, #dabort_handler_address - . - 8] // abort data
  nop
  ldr   pc, [pc, #irq_handler_address - . - 8]    // irq
  ldr   pc, [pc, #fiq_handler_address - . - 8]    // fiq

reset_handler_address:  .word reset_handler
undef_handler_address:  .word undef_handler
swi_handler_address:    .word swi_handler
pabort_handler_address: .word pabort_handler
dabort_handler_address: .word dabort_handler
irq_handler_address:    .word irq_handler
fiq_handler_address:    .word fiq_handler

  .section  .text, "ax"
  .code     32
  .align    0

/******************************************************************************
  FIQ handler
 ******************************************************************************/
fiq_handler:
  // Switch in SVC/User Mode to allow User Stack access for C code
  // because the FIQ is not yet acknowledged

  // Save and r0 in FIQ_Register
  mov   r9,r0
  ldr   r0 , [r8, #AIC_FVR]
  msr   CPSR_c,#I_BIT | F_BIT | ARM_MODE_SVC
  // Save scratch/used registers and LR in User Stack
  stmfd sp!, { r1-r3, r12, lr}
  // Branch to the routine pointed by the AIC_FVR
  mov   r14, pc
  bx    r0
  // Restore scratch/used registers and LR from User Stack
  ldmia sp!, { r1-r3, r12, lr}
  // Leave Interrupts disabled and switch back in FIQ mode
  msr   CPSR_c, #I_BIT | F_BIT | ARM_MODE_FIQ
  // Restore the R0 ARM_MODE_SVC register
  mov   r0,r9
  // Restore the Program Counter using the LR_fiq directly in the PC
  subs  pc,lr,#4

/******************************************************************************
  Reset handler
 ******************************************************************************/
  .global   _startup
  .func     _startup
_startup:
reset_handler:
  // temporary stack in internal RAM
  ldr   r13,.RAM_TOP

  ldr   r10, =REG_BASE

  // NRST enable
  ldr   r0, =0xA5000c01
  str   r0, [r10, #RSTC_MR_OFFSET]

  // Set up FLASH wait state
  ldr   r0, =(50 << MC_FMR_FMCN_BIT_OFFSET) | MC_FMR_FWS_1FWS
  str   r0, [r10, #MC_FMR_OFFSET]

  // Disable Watchdog
  ldr   r0, =WDT_MR_WDDIS
  str   r0, [r10, #WDT_MR_OFFSET]

  // Enable the main oscillator
  ldr   r0, =(6 << CKGR_MOR_OSCOUNT_BIT_OFFSET) | CKGR_MOR_MOSCEN
  str   r0, [r10, #CKGR_MOR_OFFSET]

1:// Wait for main oscillator to stabilize
  ldr   r0, [r10, #PMC_SR_OFFSET]
  tst   r0, #PMC_SR_MOSCS
  beq   1b

  // Set up the PLL
  // MCK=18.432[MHz]/(DIV=14)*((MUL=72)+1)/2=48054857[Hz]
  // MCK=18.432[MHz]/(DIV=24)*((MUL=124)+1)/2=48[MHz]
  ldr   r0, =(14 << CKGR_PLLR_DIV_BIT_OFFSET) | (28 << CKGR_PLLR_PLLCOUNT_BIT_OFFSET) | (72 << CKGR_PLLR_MUL_BIT_OFFSET)
  str   r0, [r10, #CKGR_PLLR_OFFSET]

1:// Wait for PLL to lock
  ldr   r0, [r10, #PMC_SR_OFFSET]
  tst   r0, #PMC_SR_LOCK
  beq   1b

  // Select PLL as clock source
  ldr   r0, =(PMC_MCKR_CSS_PLL_CLOCK | PMC_MCKR_PRES_CLK_2)
  str   r0, [r10, #PMC_MCKR_OFFSET]

  //-----------------------------------
  // Setup the stack for each mode
  //-----------------------------------
  ldr   r13,.RAM_TOP
  mov   r0,r13

  msr   CPSR_c, #ARM_MODE_FIQ | I_BIT | F_BIT   // Set up Fast Interrupt Mode and set FIQ Mode Stack
  ldr   r8, =AT91C_BASE_AIC                     // Init the FIQ register

  msr   CPSR_c, #ARM_MODE_IRQ | I_BIT | F_BIT   // Set up Interrupt Mode and set IRQ Mode Stack
  mov   r13, r0                                 // Init stack IRQ
  sub   r0, r0, #IRQ_Stack_Size

  msr   CPSR_c, #ARM_MODE_SVC | I_BIT | F_BIT   // Set up Supervisor Mode and set Supervisor Mode Stack
  mov   r13, r0                                 // Init stack Sup

  //-----------------------------------
  // Relocate .data section
  //-----------------------------------
  ldr   r1, =_etext
  ldr   r2, =_data
  ldr   r3, =_edata
LoopRel:
  cmp   r2, r3
  ldrlo r0, [R1], #4
  strlo r0, [R2], #4
  blo   LoopRel

  //-----------------------------------
  // Clear .bss section (Zero init)
  //-----------------------------------
  mov   r0, #0
  ldr   r1, =__bss_start__
  ldr   r2, =__bss_end__
LoopZI:
  cmp   r1, r2
  strlo r0, [r1], #4
  blo   LoopZI

  //-----------------------------------
  // Call C++ constructors
  //-----------------------------------
  ldr   r0, =__ctors_start__
  ldr   r1, =__ctors_end__
ctor_loop:
  cmp   r0, r1
  beq   ctor_end
  ldr   r2, [r0], #4
  stmfd sp!, {r0-r1}
  mov   lr, pc
  mov   pc, r2
  ldmfd sp!, {r0-r1}
  b     ctor_loop
ctor_end:

  //-----------------------------------
  // Call main program: main(0)
  //-----------------------------------
  mov   r0,#0                     // no arguments (argc = 0)
  mov   r1,r0
  mov   r2,r0
  mov   fp,r0                     // null frame pointer
  mov   r7,r0                     // null frame pointer for thumb
  ldr   r10,=main
  mov   lr,pc
  bx    r10                       // enter main()

  //-----------------------------------
  // Call C++ destructors
  //-----------------------------------
  ldr   r0, =__dtors_start__
  ldr   r1, =__dtors_end__
dtor_loop:
  cmp   r0, r1
  beq   dtor_end
  ldr   r2, [r0], #4
  stmfd sp!, {r0-r1}
  mov   lr, pc
  mov   pc, r2
  ldmfd sp!, {r0-r1}
  B     dtor_loop
dtor_end:

  //-----------------------------------
  // Fin
  //-----------------------------------
  mrs   r0,cpsr                   // get PSR
  orr   r0,r0,#I_BIT|F_BIT        // disable IRQ and FIQ
  msr   cpsr,r0                   // set up status register
  b     .

  .size     _startup, . - _startup
  .endfunc




  .global   exit, abort, reset
  .func     exit
exit:
abort:
reset:

  mrs   r0,cpsr                   // get PSR
  orr   r0,r0,#I_BIT|F_BIT        // disable IRQ and FIQ
  msr   cpsr,r0                   // set up status register
  b     .

  .size     exit, . - exit
  .endfunc



/******************************************************************************
  IRQ handler
 ******************************************************************************/
  .global   irq_handler
  .func     irq_handler

irq_handler:
  //-----------------------------------
  // Manage Exception Entry
  //-----------------------------------
  sub   lr, lr, #4                    // Adjust and save LR_irq in IRQ stack
  stmfd sp!, {lr}
  mrs   r14, SPSR                     // Save SPSR need to be saved for nested interrupt
  stmfd sp!, {r14}
  stmfd sp!, {r0}                     // Save and r0 in IRQ stack

  //-----------------------------------
  // Write in the IVR to support Protect Mode
  // No effect in Normal Mode
  // De-assert the NIRQ and clear the source in Protect Mode
  //-----------------------------------
  ldr   r14, =AT91C_BASE_AIC
  ldr   r0 , [r14, #AIC_IVR]
  str   r14, [r14, #AIC_IVR]
  msr   CPSR_c, #ARM_MODE_SVC         // Enable Interrupt and Switch in Supervisor Mode
  stmfd sp!, { r1-r3, r12, r14}       // Save scratch/used registers and LR in User Stack
  mov   r14, pc                       // Branch to the routine pointed by the AIC_IVR
  bx    r0
  ldmia sp!, { r1-r3, r12, r14}       // Restore scratch/used registers and LR from User Stack
  msr   CPSR_c, #I_BIT | ARM_MODE_IRQ // Disable Interrupt and switch back in IRQ mode
  ldr   r14, =AT91C_BASE_AIC          // Mark the End of Interrupt on the AIC
  str   r14, [r14, #AIC_EOICR]
  ldmia sp!, {r0}                     // Restore SPSR_irq and r0 from IRQ stack
  ldmia sp!, {r14}                    // Restore SPSR_irq and r0 from IRQ stack
  msr   SPSR_cxsf, r14
  ldmia sp!, {pc}^                    // Restore adjusted  LR_irq from IRQ stack directly in the PC

  .size     irq_handler, . - irq_handler
  .endfunc




  .align    0
.RAM_TOP:
  .word     Top_Stack



  .weak     undef_handler, swi_handler, pabort_handler, dabort_handler
