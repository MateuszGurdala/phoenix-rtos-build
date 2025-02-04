#
# Makefile for libphoenix
#
# ARM (Cortex-A5/A7/A9) options
#
# Copyright 2018 Phoenix Systems
#

CROSS ?= arm-phoenix-

CC := $(CROSS)gcc
CXX := $(CROSS)g++

OLVL ?= -O2

cpu := cortex-$(subst armv7,,$(TARGET_FAMILY))

ifeq ($(TARGET_SUBFAMILY), imx6ull)
  CFLAGS += -mfpu=neon-vfpv4 -mfloat-abi=hard
else ifeq ($(TARGET_SUBFAMILY), zynq7000)
  CFLAGS += -mfpu=neon-vfpv3 -mfloat-abi=hard
else
	$(error Incorrect TARGET.)
endif

CFLAGS += -mcpu=$(cpu) -mtune=$(cpu) -mthumb -fomit-frame-pointer -mno-unaligned-access
CXXFLAGS := $(CFLAGS)

AR = $(CROSS)ar
ARFLAGS = -r

LD = $(CROSS)ld
LDFLAGS = -z max-page-size=0x1000
GCCLIB := $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)
CRTBEGIN := $(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND := $(shell $(CC) $(CFLAGS) -print-file-name=crtend.o)
PHOENIXLIB := $(shell $(CC) $(CFLAGS) -print-file-name=libphoenix.a)
# The filter-out enables proper building because if libstdc++ is not available, LIBSTDCPP will be empty.
LIBSTDCPP := $(filter-out libstdc++.a, $(shell $(CXX) $(CXXFLAGS) -print-file-name=libstdc++.a))
# For arm, the implementation of exceptions, defined in libgcc, uses abort() from libphoenix
LDLIBS := $(LIBSTDCPP) --start-group $(PHOENIXLIB) $(GCCLIB) --end-group $(CRTBEGIN) $(CRTEND)


OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump
STRIP = $(CROSS)strip

VADDR_KERNEL_INIT = 0xc0000000
