include $(RTEMS_MAKEFILE_PATH)/Makefile.inc
include $(RTEMS_CUSTOM)
include $(PROJECT_ROOT)/make/leaf.cfg


#### CONFIG ####################################################################
#For debugging symbols add -DLWIP_DEBUG 
# COMPILER/LINKER
CFLAGS+=-g -O2   \
 -Wall

# OUTPUT
LWIP_EXEC=lwipdrv

#### PATHS #####################################################################

# LWIP
LWIP_PATH=.

# ARCH
LWIPARCH_PATH=$(LWIP_PATH)/src
LWIPARCH_SRC_PATH=$(LWIPARCH_PATH)
LWIPARCH_INCL_PATH=$(LWIPARCH_PATH)/include

# DRIVER
LWIPDRIVER_PATH=$(LWIP_PATH)/src
LWIPDRIVER_SRC_PATH=$(LWIPDRIVER_PATH)/netif
LWIPDRIVER_INCL_PATH=$(LWIPDRIVER_PATH)/include/netif

#### SOURCES ###################################################################


## API

ARCH_SRC= $(wildcard $(LWIPARCH_SRC_PATH)/*.c)

# DRIVER
DRIVER_SRC=$(wildcard $(LWIPDRIVER_SRC_PATH)/*.c ) \
	$(wildcard $(LWIPDRIVER_SRC_PATH)/*.S )


SOURCES =  $(DRIVER_SRC) $(ARCH_SRC)


#### HEADERS ###################################################################


## ARCH
ARCH_H=$(LWIPARCH_INCL_PATH)

## DRIVER
DRIVER_H=$(LWIPDRIVER_INCL_PATH)

# HEADERS
HEADERS=-I$(ARCH_H) -I$(DRIVER_H) -I$(RTEMS_MAKEFILE_PATH)/lwip/include


################################################################################


BIN=${ARCH}/$(LWIP_EXEC).bin
LIB=${ARCH}/lib$(LWIP_EXEC).a

# optional managers required
MANAGERS=all

# C source names
CSRCS=$(filter %.c ,$(SOURCES))
COBJS=$(patsubst %.c,${ARCH}/%.o,$(notdir $(CSRCS)))

ASMSRCS=$(filter %.S , $(SOURCES))
ASMOBJS=$(patsubst %.S,${ARCH}/%.o,$(notdir $(ASMSRCS)))

OBJS=$(COBJS) $(ASMOBJS)

all:${ARCH} $(LIB)

$(LIB): $(OBJS)
	$(AR)  rcs  $@ $^


${ARCH}/%.o: $(LWIPARCH_SRC_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIPDRIVER_SRC_PATH)/%.S
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

${ARCH}/%.o: $(LWIPDRIVER_SRC_PATH)/%.c
	${COMPILE.c} $(AM_CPPFLAGS) $(AM_CXXFLAGS) -o $@ $<

INSTALL_DIR=$(RTEMS_MAKEFILE_PATH)/lwip

install:
	mkdir -p $(INSTALL_DIR)/include
	mkdir -p $(INSTALL_DIR)/lib
	cp $(LIB) $(INSTALL_DIR)/lib
	cp $(LWIPARCH_INCL_PATH)/lwiplib.h $(INSTALL_DIR)/include
	cp $(LWIPARCH_INCL_PATH)/lwip_bbb.h $(INSTALL_DIR)/include 
	cp  $(LWIPARCH_INCL_PATH)/soc_AM335x.h $(INSTALL_DIR)/include
	cp  $(LWIPARCH_INCL_PATH)/beaglebone.h $(INSTALL_DIR)/include
	cp  $(LWIPARCH_INCL_PATH)/cache.h $(INSTALL_DIR)/include
	cp  $(LWIPARCH_INCL_PATH)/mmu.h $(INSTALL_DIR)/include

CPPFLAGS+=$(HEADERS)
