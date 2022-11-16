/*
 *  Hardware Timer Program
 */ 

#define IRQ_MASK 0x00000080

/* Read CPSR in in-line assembly language instruction msr (move to status register) */
static __inline__ unsigned __get_cpsr(void){
	unsigned long retval;
	asm volatile (" mrs  %0, cpsr" : "=r" (retval) : /* no inputs */  );
	return retval;
}

/* Write val to CPSR in in-line assembly language instruction msr (move to status register) */
static __inline__ void __set_cpsr(unsigned val){
	asm volatile (" msr  cpsr, %0" : /* no outputs */ : "r" (val)  );
}

/* Enable the original interrupt request (IRQ) */
unsigned int enableIRQ(void){
	unsigned int _cpsr;
	
	/* Get status in CPSR */
	_cpsr = __get_cpsr();
	
	/* Set 0 to IRQ_MASK bit in CPRS, and not modify the other bits */
	__set_cpsr(_cpsr & ~IRQ_MASK);
	
	return _cpsr;
}

/*
 * LED connection bits
 */
#define LED1			1<<0	/* PA0 */
#define LED2			1<<1	/* PA1 */
#define LED3			1<<2	/* PA2 */
#define LED4			1<<3	/* PA3 */
#define LED_MASK		(LED1 | LED2 | LED3 | LED4)
#define LED_OFF			0

/*
 * PIO related registers
 */
#define TADR_PIO_PER	((volatile unsigned int *)(0xFFFFF400))	/* PIO Enable Register (W) */
#define TADR_PIO_PDR	((volatile unsigned int *)(0xFFFFF404))	/* PIO Disable Register (W) */
#define TADR_PIO_OER	((volatile unsigned int *)(0xFFFFF410))	/* Output Enable Register (W) */
#define TADR_PIO_SODR	((volatile unsigned int *)(0xFFFFF430))	/* Set Output Data Register (W) */
#define TADR_PIO_CODR	((volatile unsigned int *)(0xFFFFF434))	/* Clear Output Data Register (W) */


/* LED initialization function */
void led_init(void){

	/* PIO Enable Register */
	*TADR_PIO_PER = LED_MASK;
    
	/* Output Enable Register */
	*TADR_PIO_OER = LED_MASK;
}

/* LED light-up function */
void led_out(unsigned int led_data){
	
	/* Clear LED connection bit */
	*TADR_PIO_CODR = LED_MASK;
	
	/* Write data to LED connection bit */
	*TADR_PIO_SODR = led_data & LED_MASK;
}

/*
 * LED Data (Global)
 */
unsigned int led_data;

/* 
 * Make LED{$mask} OFF
 */
void led_off(unsigned int mask){
    /* Delete LED light of {$mask} */
    led_data = (led_data & (~mask));
}

/* 
 * Make LED{$mask} ON 
 */
void led_on(unsigned int mask){
    /* Add LED light of {$mask} */
    led_data = (led_data | mask);
}



/*
 * DIP and PUSH related register
 */
#define TADR_PMC_PCER	((volatile unsigned int *)(0xFFFFFC10)) /* PMC Peripheral Clock Enable Register (W)*/
#define TADR_PIO_ODR	((volatile unsigned int *)(0xFFFFF414)) /* PIO Output disable Register (W)*/
#define TADR_PIO_PDSR	((volatile unsigned int *)(0xFFFFF43C)) /* PIO Pin Data Status Register (R)*/

/*
 * DIP and PUSH switch connection ports
 */
#define	DSW1			1<<11	/* PA11 */
#define	DSW2			1<<12	/* PA12 */
#define	DSW3			1<<13	/* PA13 */
#define	DSW4			1<<14	/* PA14 */
#define	DSW_MASK		(DSW1|DSW2|DSW3|DSW4)

#define	PSW1			1<<4	/* PA4 */
#define	PSW2			1<<5	/* PA5 */
#define	PSW_MASK		(PSW1|PSW2)

#define DSW_PSW_MASK	(PSW_MASK|DSW_MASK)

/*
 * Enable PIO Clock
 */
#define	PID2			1<<2	/* PID2 */

/*
 * DIP and PUSH switch port initialization
 */
void switch_init(void){
	/* Enable PIO Clocks */
	*TADR_PMC_PCER = PID2;

	/* Set PIO Enable Register */
	*TADR_PIO_PER = DSW_PSW_MASK;

	/* Set Output Disable Register*/
	*TADR_PIO_ODR = DSW_PSW_MASK;
}

/*
 * {$mask} switch status read
 */
unsigned int switch_read(unsigned int mask){
	
	unsigned int sw;

	/* Read switch status */
	sw = *TADR_PIO_PDSR;

	/* Invertion and MASK the switch status */
	sw = ~sw & mask;

	/* Return the switch status*/
	return sw;
}

/*
 * DIP switch status read
 */
unsigned int switch_dip_read(void){

	/* Read DIP switch status */	
	unsigned int dip_sw;
	
    /* Invertion and MASK the DIP status */
	dip_sw = switch_read(DSW_MASK);

	/* Return the DIP switch status*/
	return dip_sw;
}

/*
 * PUSH switch status read
 */
unsigned int switch_push_read(void){

	/* Read PUSH switch status */	
	unsigned int push_sw;

	/* Invertion and MASK the PUSH status */
	push_sw = switch_read(PSW_MASK);

	/* Return the PUSH switch status*/
	return push_sw;
}





/*
 * Timer related register
 */
#define TADR_PMC_PCER	((volatile unsigned int *)(0xFFFFFC10))	/* Peripheral Clock Enable Register (W) */
#define TADR_TC_C0_CCR	((volatile unsigned int *)(0xFFFA0000))	/* Channel Control Register (W) */
#define TC_CLKEN		0x1
#define TC_CLKDIS		0x2
#define TC_SWTRG		0x4

#define TADR_TC_C0_CMR	((volatile unsigned int *)(0xFFFA0004))	/* Channel Mode Register (R/W) */
#define TC_CLKS_MCK8	0x1

#define TADR_TC_C0_RC	((volatile unsigned int *)(0xFFFA001C))	/* Register C (R/W) */
#define TADR_TC_C0_SR	((volatile unsigned int *)(0xFFFA0020))	/* Statis Register (R) */
#define TC_COVFS		0x1		// Counter Overflow Status

#define TADR_TC_C0_IDR	((volatile unsigned int *)(0xFFFA0028))	/* Interrupt Disable Register (W) */

#define TC0_PID			12

/*
 * Timer count value
 */
#define TIMER_COUNT		59900   /* 10ms (1ms = 5990 count) */

/*
 * Timer interrupt register
 */
#define TADR_TC_C0_IER	((volatile unsigned int *)(0xFFFA0024))	/* Interrupt Enable Register (W) */
#define TADR_TC_C0_IDR	((volatile unsigned int *)(0xFFFA0028))	/* Interrupt Disable Register (W) */


/*
 * Timer initialization
 */ 
void timer_init(void){
	
	/* Enable PIO clocks. */
	*TADR_PMC_PCER = 1<<TC0_PID;
	
	/* Stop the timer */
	*TADR_TC_C0_CCR = TC_CLKDIS;
	
	/* All interrups are set disable */
	*TADR_TC_C0_IDR = 0xFFFFFFFF;
	
	/* the timer count value */ 
	*TADR_TC_C0_CMR = TC_CLKS_MCK8; /* 47,923,200Hz/8=5,990,400Hz */
	
	/* Set the count value */ 
	*TADR_TC_C0_RC = TIMER_COUNT;
	
	/* Enable counter overflow interrupt */
	*TADR_TC_C0_IER = TC_COVFS;

	/* Start the timer (with software trigger) */
	*TADR_TC_C0_CCR = TC_CLKEN | TC_SWTRG;
}


/*
 * Interrupt control registers
 */
#define TADR_AIC_IECR	((volatile unsigned int *)(0xFFFFF120))	/* Interrupt Enable Command Register (W) */
#define TADR_AIC_IDCR	((volatile unsigned int *)(0xFFFFF124))	/* Interrupt Disable Command Register (W) */
#define TADR_AIC_ICCR	((volatile unsigned int *)(0xFFFFF128))	/* Interrupt Clear Command Register (W) */
#define TADR_AIC_EOICR	((volatile unsigned int *)(0xFFFFF130))	/* End of Interrupt Command Register (W) */
#define TADR_AIC_SMR_TC0_PID	((volatile unsigned int *)(0xFFFFF000+TC0_PID*4))	/* Source Mode Register0-31 (R/W) */
#define TADR_AIC_SVR_TC0_PID	((volatile unsigned int *)(0xFFFFF080+TC0_PID*4))	/* Source Vector Register0-31 (R/W) */

/*
 * Interrupt control register bit
 */
#define AIC_SRCTYPE_INT_LEVEL_SENSITIVE	(0<<5)	/* (AIC) Internal Sources Code Label Level Sensitive */

extern void timer_handler(void);

/*
 * Timer Interrupt Initialization
 */
void timer_int_init(void){
	
	/* Enable the original interrupt request (IRQ) in ARM*/
	enableIRQ();
	
	/* Set the hander address in the vector register */
	*TADR_AIC_SVR_TC0_PID = (void *)timer_handler;
	
	/* Enable timer interrupt */
	*TADR_AIC_IECR = 1<<TC0_PID;
}


/*
 * Variables for count up or down
 */
unsigned long BaseTimer = 0;
unsigned long RestTime = 0;

/*
 * Timer interrupt handler
 */
void timer_handler(void){

	/* Read the status register to clear overflow */
	*TADR_TC_C0_SR;

	// timer count
	BaseTimer++;
	
	/* Set End of Interrupt */
	*TADR_AIC_EOICR =0;
}

/* 
 * Timer mode
 * 0: Stop
 * 1: Active
 * 2: Expired
 */
#define TIMER_STOP		0
#define TIMER_ACTIVE	1
#define TIMER_EXPIRED	2

/*
 * Variable for Timer mode
 */
unsigned char timer_mode = TIMER_STOP;


/* LED1 */
void led1_process(void){
	// the number of this process was called
	static unsigned char num_called = 0;
	
	// LED1 is ON or NOT
	static char isLED1On = 0;
	
	// count 0.25s
	num_called++;
	
	/* Blink */
	if (num_called==4){
		// 4 * 0.25s = 1.00s
		if ((isLED1On % 2) == 0){
            led_on(LED1);
		}
		else{
            led_off(LED1);
		}
		isLED1On++;
		num_called = 0;
	}
}

/*
 * Time 
 */
#define EXPIRED_TIME	10 * 4
#define ACTIVE_BLINK	3 * 4

/* LED4 */
void expired_led_process(void){
	// the number of this process was called
	static unsigned char num_called = 0;
	
    /* blink */
    if ((num_called % 2) == 0){
        led_on(LED4);
    }
    else{
        led_off(LED4);
    }

	// count 0.25s
	num_called++;
    
    /* Reset */
    if (num_called == EXPIRED_TIME){
    	/* Shift Stop mode */
        timer_mode = TIMER_STOP;
        num_called = 0;
        led_off(LED4);
    }
}

/* LED4 */
void active_led_process(void){
	// the number of this process was called
	static unsigned char num_called = 0;
	
    /* blink */
    if ((num_called == 1) || (num_called == 3)){
        led_on(LED4);
    }
    else{
        led_off(LED4);
    }

	// count 0.25s
	num_called++;
    
    /* Reset */
    if (num_called == ACTIVE_BLINK){
        num_called = 0;
    }
}


/* DSW1 data process */
void DSW1_process(unsigned int sw_data){
	
	/* Temporary copy of {$sw_data} */
	static unsigned int ex_sw_data = 0;
	
	/* Only when {$sw_data} changes... */
	if (ex_sw_data != sw_data){
		
	    /* DSW1 is ON */
    	if ((sw_data & DSW1) == DSW1){
    	
        	/* Rest Time Pre-Set */
        	RestTime = 10;

        	/* Timer Start */
			timer_mode = TIMER_ACTIVE;
    	}

    	/* DSW1 is OFF */
    	else{
        	/* Timer Stop */
			timer_mode = TIMER_STOP;

        	/* Rest Time Reset */
			RestTime = 0;
    	}
    }
    /* swap */
    ex_sw_data = sw_data;
}

/* PSW1 data process */
void PSW1_process(unsigned int sw_data){

	/* PSW1 is ON or OFF */
    static unsigned int PSW1_status = 0;

    /* Read ex-PSW1_status */
    unsigned int tmp = PSW1_status;

    /* PSW1 is ON */
    if ((sw_data & PSW1) == PSW1){

        /* PSW1_status -> 1 */
        PSW1_status = 1;

        /* LED2 */
        led_on(LED2);
    }

    /* PSW1 is OFF */
    else{

        /* PSW1_status -> 0 */
        PSW1_status = 0;

        /* ON -> OFF */
        if (tmp != PSW1_status){

            /* Add 10s in RestTime */
            if (timer_mode == TIMER_ACTIVE){
            	RestTime += 10;
            }
            /* LED2 */
            led_off(LED2);
        }
    }
}

/* DIP and PUSH switch */
void switch_process(void){
	// Execute /0.25s
    unsigned int sw_data;

    /* Read Switch Data */
    sw_data = switch_read(DSW_PSW_MASK);

    /* DSW1 */
    DSW1_process(sw_data);

    /* PSW1 */
    PSW1_process(sw_data);
}

/*
 * Timer
 */

/* Manupulate timer */
void timer_mode_process(void){
	// Execute /0.25s
    static unsigned int num_called = 0;

    /* copy timer mode */
    unsigned char ex_timer_mode;
    ex_timer_mode = timer_mode;

    /* Timer mode == (Stop) */
    if (ex_timer_mode==TIMER_STOP){
        /* Timer Stop... */
    }
    /* Timer mode == (Active) */
    else if (ex_timer_mode==TIMER_ACTIVE){
    	
    	/* Blink LED4 */
    	active_led_process();
    	
        /* Timer Counting Down... */
        num_called++;

        /* Rest Time count down */
        if ((num_called % 4) == 0){
            RestTime--;
            num_called = 0;
        }

		/* mode change */
		if (RestTime == 0){
			/* Shift Expired mode */
			timer_mode = TIMER_EXPIRED;
			num_called = 0;
		}
    }
    /* Timer mode == (Expired) */
    else{
        /* Before Timer Stop... */
		expired_led_process();
    }
	
    /* Update LED */
    led_out(led_data);
}


/*
 * main function
 */ 
int main(void){

    /* Switch init */
    switch_init();

	/* Initialize LED hardware */
	led_init();
	
	/* Initialize timer hardware */
	timer_init();
	
	/* Initialize interrupt hardware (timer interrupt is enable) */
	timer_int_init();

	/* 0.25 s */
	unsigned long timer25 = 25;
	
	/* Initialize {$led_data} by 0 */
	led_data = LED_OFF;
	
	/* Infinite loop */
	while (1) {

		/* Execute 0.25s */
		if (BaseTimer >= timer25){
			led1_process();
			switch_process();
			timer_mode_process();
			led_out(led_data);
			timer25 += 25;
		}
	}
}
