include make/common.mk

src := $(wildcard src/dae/*.cpp)

src += src/modules/stdErrPlugin/stdErrPlugin.cpp \
       src/modules/STLDatabase/daeSTLDatabase.cpp \
       src/modules/LIBXMLPlugin/daeLIBXMLPlugin.cpp \

src += $(wildcard src/$(colladaVersion)/dom/*.cpp)

includeOpts := -Iinclude -Iinclude/$(colladaVersion)

ifeq ($(os),linux)
libOpts += -Wl,--exclude-libs,ALL
endif

ifneq ($(findstring $(os),linux mac),)
ccFlags += -fPIC
else 
ifeq ($(os),windows)
ccFlags += -DDOM_DYNAMIC -DDOM_EXPORT
endif
endif

ifneq ($(findstring libxml,$(xmlparsers)),)
ccFlags += -DDOM_INCLUDE_LIBXML
ifeq ($(os),windows)
includeOpts += -Iexternal-libs/libxml2/include
libOpts += -Lexternal-libs/libxml2/$(buildID)/lib -lxml2 -lws2_32 -lz
else
ifeq ($(os),linux)
includeOpts += -I$(packageprefix)/include/libxml2
else
includeOpts += -I/usr/include/libxml2
endif
libOpts += -L$(packageprefix)/lib/release -lxml2
endif
endif

ifneq ($(findstring tinyxml,$(xmlparsers)),)
ccFlags += -DDOM_INCLUDE_TINYXML
includeOpts += -Iexternal-libs/tinyxml/
libOpts += external-libs/tinyxml/lib/$(buildID)/libtinyxml.a
endif

# On Mac, Windows and PS3 we need to be told where to find pcre
ifeq ($(os),windows)
ccFlags += -DPCRE_STATIC
else
includeOpts += -I$(packageprefix)/include/pcre
libOpts += $(addprefix $(packageprefix)/lib/release/,libpcrecpp.a libpcre.a )
endif

ifeq ($(os),mac)
includeOpts += -I$(packageprefix)/include
endif

# For mingw: add boost
ifneq ($(findstring $(os),linux mac),)
includeOpts += -I$(packageprefix)/include
ifeq ($(conf),debug)
debug_suffix = "-d"
else
debug_suffix = ""
endif
libOpts += $(packageprefix)/lib/$(conf)/libboost_system-mt$(debug_suffix).so
libOpts += $(packageprefix)/lib/$(conf)/libboost_filesystem-mt$(debug_suffix).so 
endif

# minizip
includeOpts += -Iexternal-libs/minizip/include
libOpts += -Lbuild/$(buildID)-$(colladaVersion)$(debugSuffix)/
libOpts += -lminizip$(debugSuffix)
# as we link minizip static on osx, we need to link against zlib, too.
ifeq ($(os),mac)
libOpts += -lz
endif

# output
libName := libcollada$(colladaVersionNoDots)dom$(debugSuffix)
libVersion := $(domVersion)
libVersionNoDots := $(subst .,,$(libVersion))

targets :=
ifeq ($(os),linux)
# On Linux we build a static lib and a shared lib
targets += $(addprefix $(outPath),$(libName).a)
targets += $(addprefix $(outPath),$(libName).so)

else 
ifeq ($(os),windows)
# On Windows we build a static lib and a DLL
windowsLibName := libcollada$(colladaVersionNoDots)dom
targets += $(addprefix $(outPath),$(windowsLibName)$(debugSuffix).a)
targets += $(addprefix $(outPath),$(windowsLibName)$(libVersionNoDots)$(debugSuffix).dll)

else 
ifeq ($(os),mac)
# On Mac we build a framework
targets += $(addprefix $(outPath),libcollada$(colladaVersionNoDots)dom$(debugSuffix).framework)
frameworkHeadersPath = $(framework)/Versions/$(libVersion)/Headers
copyFrameworkHeadersCommand = cp -R include/* $(frameworkHeadersPath) && \
  mv $(frameworkHeadersPath)/$(colladaVersion)/dom $(frameworkHeadersPath)/dom && \
  find -E $(frameworkHeadersPath) -maxdepth 1 -type d -regex '.*[0-9]+\.[0-9]+' | xargs rm -r
frameworkResourcesPath = $(framework)/Versions/$(libVersion)/Resources
sedReplaceExpression := -e 's/(colladaVersionNoDots)/$(colladaVersionNoDots)/g' \
                        -e 's/(domVersion)/$(domVersion)/g' \
                        -e 's/(debugSuffix)/$(debugSuffix)/g'
copyFrameworkResourcesCommand = cp -R make/macFrameworkResources/* $(frameworkResourcesPath) && \
  sed $(sedReplaceExpression) make/macFrameworkResources/Info.plist > $(frameworkResourcesPath)/Info.plist && \
  sed $(sedReplaceExpression) make/macFrameworkResources/English.lproj/InfoPlist.strings > $(frameworkResourcesPath)/English.lproj/InfoPlist.strings

else 
ifeq ($(os),ps3)
# On PS3 we build a static lib, since PS3 doesn't support shared libs
targets += $(addprefix $(outPath),$(libName).a)
endif
endif
endif
endif

ifeq ($(os),ps3)
# PS3 doesn't support C++ locales, so tell boost not to use them
ccFlags += -DBOOST_NO_STD_LOCALE -DNO_BOOST -DNO_ZAE
endif

include make/rules.mk
