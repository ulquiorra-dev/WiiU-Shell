BASEDIR	:= $(dir $(firstword $(MAKEFILE_LIST)))
VPATH	:= $(BASEDIR)

PKGCONF			:=	$(DEVKITPRO)/portlibs/ppc/bin/powerpc-eabi-pkg-config
PKGCONF_WIIU	:=	$(DEVKITPRO)/portlibs/wiiu/bin/powerpc-eabi-pkg-config

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing header files
# ROMFS is a folder to generate app's romfs
#---------------------------------------------------------------------------------
TARGET		:=	WiiU-Shell
SOURCES		:=	source \
				source/audio \
				source/menus \
				source/minizip \
				source/menus/menu_book_reader
INCLUDES    :=	include \
				include/audio \
				include/menus \
				include/minizip
ROMFS		:=	romfs

VERSION_MAJOR := 1
VERSION_MINOR := 0
VERSION_MICRO := 4

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
CFLAGS		+=	-O2 -std=c11 -Wall -Wno-format-truncation -U__STRICT_ANSI__ \
				-DVERSION_MAJOR=$(VERSION_MAJOR) -DVERSION_MINOR=$(VERSION_MINOR) -DVERSION_MICRO=$(VERSION_MICRO)
CXXFLAGS	+=	-O2 -Wall -Wno-format-truncation -U__STRICT_ANSI__ \
				-DVERSION_MAJOR=$(VERSION_MAJOR) -DVERSION_MINOR=$(VERSION_MINOR) -DVERSION_MICRO=$(VERSION_MICRO) 

#---------------------------------------------------------------------------------
# libraries
#---------------------------------------------------------------------------------
CFLAGS		+=	`$(PKGCONF_WIIU) --cflags SDL2_gfx SDL2_image SDL2_mixer SDL2_ttf sdl2`
CXXFLAGS	+=	`$(PKGCONF_WIIU) --cflags SDL2_gfx SDL2_image SDL2_mixer SDL2_ttf sdl2`
LDFLAGS		+=	`$(PKGCONF_WIIU) --libs SDL2_gfx SDL2_image SDL2_mixer SDL2_ttf sdl2` \
				`$(PKGCONF) --libs freetype2 zlib libpng libjpeg libmpg123`

#---------------------------------------------------------------------------------
# wut libraries
#---------------------------------------------------------------------------------
LDFLAGS		+=	$(WUT_NEWLIB_LDFLAGS) $(WUT_STDCPP_LDFLAGS) \
				-lcoreinit -lvpad -lsndcore2 -lnsysnet -lsysapp -lproc_ui -lgx2 -lgfd -lwhb

#---------------------------------------------------------------------------------
# romfs
#---------------------------------------------------------------------------------
include $(WUT_ROOT)/share/romfs-wiiu.mk
LDFLAGS		+=	$(ROMFS_LDFLAGS)
OBJECTS		+=	$(ROMFS_TARGET)

#---------------------------------------------------------------------------------
# includes
#---------------------------------------------------------------------------------
CFLAGS		+=	$(foreach dir,$(INCLUDES),-I$(dir))
CXXFLAGS	+=	$(foreach dir,$(INCLUDES),-I$(dir))

#---------------------------------------------------------------------------------
# generate a list of objects
#---------------------------------------------------------------------------------
CFILES		:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.c))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.cpp))
SFILES		:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.S))
OBJECTS		+=	$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

#---------------------------------------------------------------------------------
# targets
#---------------------------------------------------------------------------------
$(TARGET).rpx: $(OBJECTS)

clean:
	$(info clean ...)
	@rm -rf $(TARGET).rpx $(OBJECTS) $(OBJECTS:.o=.d)

.PHONY: clean

#---------------------------------------------------------------------------------
# wut
#---------------------------------------------------------------------------------
include $(WUT_ROOT)/share/wut.mk
