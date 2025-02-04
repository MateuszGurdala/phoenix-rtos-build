#
# Makefile for Phoenix-RTOS 3
#
# SPARCv8 LEON3 options
#
# Copyright 2022 Phoenix Systems
#
# %LICENSE%
#

CROSS ?= sparc-phoenix-

CC := $(CROSS)gcc
CXX := $(CROSS)g++

OLVL ?= -O2
CFLAGS += -mcpu=leon3 -msoft-float
CPPFLAGS := -DNOMMU

AR = $(CROSS)ar
ARFLAGS = -r

LD = $(CROSS)ld
LDFLAGS := -z max-page-size=0x200

VADDR_KERNEL_INIT=31000000

ifeq ($(KERNEL), 1)
  LDFLAGS += -Tbss=40001800 -Tdata=40001800 --section-start=.rodata=40000000
  STRIP = $(CROSS)strip
else
  CFLAGS += -fPIC -fPIE -mno-pic-data-is-text-relative -mpic-register=g6
  LDFLAGS += -q
  STRIP = $(CROSS)strip --strip-unneeded -R .rela.text
endif

CXXFLAGS := $(CFLAGS)

GCCLIB := $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)
CRTBEGIN := $(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND := $(shell $(CC) $(CFLAGS) -print-file-name=crtend.o)
PHOENIXLIB := $(shell $(CC) $(CFLAGS) -print-file-name=libphoenix.a)
# The filter-out enables proper building because if libstdc++ is not available, LIBSTDCPP will be empty.
LIBSTDCPP := $(filter-out libstdc++.a, $(shell $(CXX) $(CXXFLAGS) -print-file-name=libstdc++.a))
LDLIBS := $(LIBSTDCPP) $(PHOENIXLIB) $(GCCLIB) $(CRTBEGIN) $(CRTEND)

OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump
