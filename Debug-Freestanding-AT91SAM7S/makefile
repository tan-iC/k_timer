################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
JP_PIZZAFACTORY_CROSSCHAINS_OBJCOPY_ARM_ELF_EXE_DEBUG_OUTPUT_OUTPUTS += \
default.srec \


# All Target
all: k_timer.out

# Tool invocations
k_timer.out: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	arm-elf-gcc -nostdlib -Xlinker -T../sam7s256_ram.x. -o"k_timer.out" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

default.srec: $(filter-out\ USER_OBJS,\ $(EXECUTABLES))
	@echo 'Invoking: GNU Objcopy'
	arm-elf-objcopy  $(filter-out USER_OBJS, $(EXECUTABLES)) "default.srec"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(JP_PIZZAFACTORY_CROSSCHAINS_OBJCOPY_ARM_ELF_EXE_DEBUG_OUTPUT_OUTPUTS)$(OBJS)$(C_DEPS)$(EXECUTABLES)$(S_UPPER_DEPS) k_timer.out
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
