###############################################################
######  		WINDOWS BUILD ENVIRONMENT				#######
###############################################################

ifeq ($(XWSROOT),)
    $(error xmake: XWSROOT is not defined)
endif

ifneq ($(XOS),Windows)
	$(error Current OS is not Windows)
endif

ifeq ($(TGTPLATFORM),)
    TGTPLATFORM=win
endif

ifeq ($(dirProgramFiles),)
	$(error Dir ProgramFiles is not found)
endif

ifeq ($(dirProgramFiles86),)
    $(error Dir ProgramFilesX86 is not found)
endif

ifeq ($(XVSVER),)
    $(error Visual Studio is not found)
endif

ifeq ($(XSDKVER),)
    $(error SDK is not found)
endif

ifeq ($(XWDKVER),)
    $(info WDK is not found)
endif

# make sure target type is valid
ifeq ($(TGTTYPE),gui)
    TGTEXT=.exe
    TGTSUBSYS=WINDOWS
else ifeq ($(TGTTYPE),console)
    TGTEXT=.exe
    TGTSUBSYS=CONSOLE
else ifeq ($(TGTTYPE),lib)
    TGTEXT=.lib
else ifeq ($(TGTTYPE),dll)
    TGTEXT=.dll
    ifeq (kernel,$(TGTMODE))
        TGTSUBSYS=WINDOWS
    else
        TGTSUBSYS=NATIVE
    endif
else ifeq ($(TGTTYPE),drv)
    TGTEXT=.sys
    TGTSUBSYS=NATIVE
else
    $(error xmake: TGTTYPE ("$(TGTTYPE)") is unknown)
endif

#-----------------------------------#
#			System Variables		#
#-----------------------------------#
#$(info PROGRAMFILES = $(dirProgramFiles))
#$(info PROGRAMFILES86 = $(dirProgramFiles86))
#$(info Visual Studio (Latest) = $(XVSVER))
#$(info Windows SDK (Latest) = $(XSDKVER))
#$(info Windows WDK (Latest) = $(XWDKVER))

#-----------------------------------#
#		DIRs: Tools, SDK, and WDK	#
#-----------------------------------#

# Prefered Visual Studio Version
#	- 14.0 (Visual Studio 2015)
#	- 15.0 (Visual Studio 2017)
#	- 16.0 (Visual Studio 2019)

PREFERED_VSVER=

ifneq (,$(PREFERED_VSVER))
    PREFERED_VSDIR=$(shell ls -F '$(dirProgramFiles86)/' | grep / | grep 'Microsoft Visual Studio $(PREFERED_VSVER)' | cut -d / -f 1)
    ifeq (,$(PREFERED_VSDIR))
        $(info ** WARNING - Visual Studio $(PREFERED_VSVER) is not installed, use latest version instead)
        PREFERED_VSVER=$(XVSVER)
        PREFERED_VSDIR=$(XVSDIR)
	else
        CLEXE=$(shell ls -F '$(dirProgramFiles86)/Microsoft Visual Studio $(PREFERED_VSVER)/VC/bin/' 2> /dev/null | grep 'cl.exe')
        ifneq (cl.exe,$(CLEXE))
            $(info ** WARNING - Visual Studio $(PREFERED_VSVER) is not installed, use latest version instead)
            PREFERED_VSVER=$(XVSVER)
            PREFERED_VSDIR=$(XVSDIR)
		else
            PREFERED_VSDIR=$(dirProgramFiles86)/Microsoft Visual Studio $(PREFERED_VSVER)
		endif
    endif
else
    PREFERED_VSVER=$(XVSVER)
    PREFERED_VSDIR=$(XVSDIR)
endif
PREFERED_VSVERSHORT=$(shell echo $(PREFERED_VSVER) | sed 's/\.//')

# Prefered SDK Version
#	- 10.0.17134.0
#	- 10.0.15063.0
#	- 10.0.14393.0
#	- 10.0.10586.0
#	- 10.0.10240.0
#	- 10.0.10150.0

PREFERED_SDKVER=

ifneq (,$(PREFERED_SDKVER))
    PREFERED_SDKMAJORVER=$(shell echo $(PREFERED_SDKVER) | cut -d . -f 1)
    PREFERED_SDKDIR_INC=$(shell ls -F '$(dirProgramFiles86)/Windows Kits/$(PREFERED_SDKMAJORVER)/Include/' 2> /dev/null | grep / | grep $(PREFERED_SDKVER) | cut -d / -f 1)
    ifneq ($(PREFERED_SDKVER),$(PREFERED_SDKDIR_INC))
        $(info ** WARNING - SDK $(PREFERED_SDKVER) is not installed, use latest version instead)
        PREFERED_SDKVER=$(XSDKVER)
        PREFERED_SDKINCDIR=$(XSDKINCDIR)
        PREFERED_SDKLIBDIR=$(XSDKLIBDIR)
	else
        PREFERED_SDKDIR_LIB=$(shell ls -F '$(dirProgramFiles86)/Windows Kits/$(PREFERED_SDKMAJORVER)/Lib/' 2> /dev/null | grep / | grep $(PREFERED_SDKVER) | cut -d / -f 1)
        ifneq ($(PREFERED_SDKVER),$(PREFERED_SDKDIR_INC))
            $(info ** WARNING - SDK $(PREFERED_SDKVER) is not installed, use latest version instead)
            PREFERED_SDKVER=$(XSDKVER)
            PREFERED_SDKINCDIR=$(XSDKINCDIR)
            PREFERED_SDKLIBDIR=$(XSDKLIBDIR)
		endif
    endif
else
    PREFERED_SDKVER=$(XSDKVER)
    PREFERED_SDKINCDIR=$(XSDKINCDIR)
    PREFERED_SDKLIBDIR=$(XSDKLIBDIR)
    PREFERED_SDKMAJORVER=$(shell echo $(PREFERED_SDKVER) | cut -d . -f 1)
endif

# Prefered WDK Version
#	- 10.0.17134.0
#	- 10.0.15063.0
#	- 10.0.14393.0
#	- 10.0.10586.0
#	- 10.0.10240.0
#	- 10.0.10150.0

PREFERED_WDKVER=

ifneq (,$(PREFERED_WDKVER))
    PREFERED_WDKMAJORVER=$(shell echo $(PREFERED_WDKVER) | cut -d . -f 1)
    PREFERED_WDKDIR_INC=$(shell ls -F '$(dirProgramFiles86)/Windows Kits/$(PREFERED_WDKMAJORVER)/Include/$(PREFERED_WDKVER)/' 2> /dev/null | grep / | grep km | cut -d / -f 1)
    ifneq (km,$(PREFERED_SDKDIR_INC))
        $(info ** WARNING - WDK $(PREFERED_SDKVER) is not installed, use latest version instead)
        PREFERED_WDKVER=$(XWDKVER)
        PREFERED_WDKINCDIR=$(XWDKINCDIR)
        PREFERED_WDKLIBDIR=$(XWDKLIBDIR)
	else
        PREFERED_WDKDIR_LIB=$(shell ls -F '$(dirProgramFiles86)/Windows Kits/$(PREFERED_WDKMAJORVER)/Lib/$(PREFERED_WDKVER)/' 2> /dev/null | grep / | grep km | cut -d / -f 1)
        ifneq (km,$(PREFERED_WDKDIR_LIB))
            $(info ** WARNING - WDK $(PREFERED_WDKVER) is not installed, use latest version instead)
            PREFERED_WDKVER=$(XWDKVER)
            PREFERED_WDKINCDIR=$(XWDKINCDIR)
            PREFERED_WDKLIBDIR=$(XWDKLIBDIR)
		endif
    endif
else
    PREFERED_WDKVER=$(XWDKVER)
    PREFERED_WDKINCDIR=$(XWDKINCDIR)
    PREFERED_WDKLIBDIR=$(XWDKLIBDIR)
    PREFERED_WDKMAJORVER=$(shell echo $(PREFERED_WDKVER) | cut -d . -f 1)
endif

ifeq ($(dirProgramFiles86),$(dirProgramFiles))
    PREFERED_SDKBINDIR=$(dirProgramFiles86)/Windows Kits/$(PREFERED_SDKMAJORVER)/bin/$(PREFERED_SDKVER)/x86
else
    PREFERED_SDKBINDIR=$(dirProgramFiles86)/Windows Kits/$(PREFERED_SDKMAJORVER)/bin/$(PREFERED_SDKVER)/x64
endif

# export VC dir
export PATH := $(PATH):"$(PREFERED_VSDIR)/Common7/IDE":"$(PREFERED_VSDIR)/VC/bin":"$(PREFERED_SDKBINDIR)"

#$(info Visual Studio (Prefered):     $(PREFERED_VSVER))
#$(info Visual Studio (Short Ver):    $(PREFERED_VSVERSHORT))
#$(info Visual Studio Dir (Prefered): $(PREFERED_VSDIR))
#$(info Windows SDK (Prefered):       $(PREFERED_SDKVER))
#$(info Windows SDK Bin (Prefered):   $(PREFERED_SDKBINDIR))
#$(info Windows SDK Inc (Prefered):   $(PREFERED_SDKINCDIR))
#$(info Windows SDK Lib (Prefered):   $(PREFERED_SDKLIBDIR))
#$(info Windows WDK (Prefered):       $(PREFERED_WDKVER))
#$(info Windows WDK Inc (Prefered):   $(PREFERED_WDKINCDIR))
#$(info Windows WDK Lib (Prefered):   $(PREFERED_WDKLIBDIR))

#-----------------------------------#
#			Path: Tools				#
#-----------------------------------#
MLNAME=ml.exe
ifeq ($(BUILDARCH),x86)
    VCBIN=VC/bin
    #ifeq ($(dirProgramFiles),$(dirProgramFiles86))
    #    VCBIN=VC/bin
	#else
    #    VCBIN=VC/bin/amd64_x86
	#endif
else ifeq ($(BUILDARCH),x64)
    ifeq ($(dirProgramFiles),$(dirProgramFiles86))
        VCBIN=VC/bin/x86_amd64
	else
        VCBIN=VC/bin/amd64
	endif
    MLNAME=ml64.exe
else ifeq ($(BUILDARCH),arm)
    ifeq ($(dirProgramFiles),$(dirProgramFiles86))
        VCBIN=VC/bin/x86_arm
	else
        VCBIN=VC/bin/amd64_arm
	endif
else ifeq ($(BUILDARCH),arm64)
    ifeq ($(dirProgramFiles),$(dirProgramFiles86))
        VCBIN=VC/bin/x86_arm
	else
        VCBIN=VC/bin/amd64_arm
	endif
else
    VCBIN=VC/bin
endif
CC=$(PREFERED_VSDIR)/$(VCBIN)/cl.exe
CXX=$(PREFERED_VSDIR)/$(VCBIN)/cl.exe
ML=$(PREFERED_VSDIR)/$(VCBIN)/$(MLNAME)
LIB=$(PREFERED_VSDIR)/$(VCBIN)/lib.exe
LINK=$(PREFERED_VSDIR)/$(VCBIN)/link.exe
DUMPBIN=$(PREFERED_VSDIR)/VC/bin/dumpbin.exe
NMAKE=$(PREFERED_VSDIR)/VC/bin/nmake.exe

RC=$(PREFERED_SDKBINDIR)/rc.exe
MC=$(PREFERED_SDKBINDIR)/mc.exe
MT=$(PREFERED_SDKBINDIR)/mt.exe
MIDL=$(PREFERED_SDKBINDIR)/midl.exe
UUIDGEN=$(PREFERED_SDKBINDIR)/uuidgen.exe
SIGNTOOL=$(PREFERED_SDKBINDIR)/signtool.exe
STAMPINF=$(PREFERED_SDKBINDIR)/stampinf.exe
CERT2SPC=$(PREFERED_SDKBINDIR)/cert2spc.exe
PVK2PFX=$(PREFERED_SDKBINDIR)/pvk2pfx.exe

#-----------------------------------#
#		Path: Includes, Libs		#
#-----------------------------------#

IFLAGS += $(foreach dir, $(TGTINCDIRS), $(addprefix -I, $(dir)))

IFLAGS += -I"$(PREFERED_SDKINCDIR)/shared"
ifeq ($(TGTMODE),kernel)
    IFLAGS+=-I"$(PREFERED_SDKINCDIR)/km"
else
    IFLAGS+=-I"$(PREFERED_SDKINCDIR)/um" \
		    -I"$(PREFERED_SDKINCDIR)/ucrt" \
		    -I"$(PREFERED_VSDIR)/VC/include"
endif

LFLAGS=-LIBPATH:"$(OUTDIR)" -LIBPATH:"$(INTDIR)"
LFLAGS += $(foreach dir, $(TGTLIBDIRS), $(addprefix -LIBPATH:, $(dir)))
ifeq ($(TGTMODE),kernel)
    LFLAGS += -LIBPATH:"$(PREFERED_SDKLIBDIR)/km/$(BUILDARCH)"
else
    ifeq ($(BUILDARCH), x64)
        LFLAGS += -LIBPATH:"$(PREFERED_VSDIR)/VC/lib/amd64" \
                  -LIBPATH:"$(PREFERED_VSDIR)/VC/atlmfc/lib/amd64"
    else
        LFLAGS += -LIBPATH:"$(PREFERED_VSDIR)/VC/lib" \
                  -LIBPATH:"$(PREFERED_VSDIR)/VC/atlmfc/lib"
    endif
    LFLAGS += -LIBPATH:"$(PREFERED_SDKLIBDIR)/um/$(BUILDARCH)" \
		      -LIBPATH:"$(PREFERED_SDKLIBDIR)/ucrt/$(BUILDARCH)"
endif


#-----------------------------------#
#	Options: Compiler				#
#-----------------------------------#

INFLAG=-c
COUTFLAG=-Fo
LOUTFLAG=-OUT:

MLFLAGS = -nologo -Cx

ifeq ($(BUILDARCH), x64)
    MIDL_CFLAGS	= -char signed -win64 -x64 -env x64 -Oicf -error all
    CFLAGS   += -D_X64_=1 -Damd64=1 -D_WIN64=1 -D_AMD64_=1 -DAMD64=1 -DNOMINMAX
    CXXFLAGS += -D_X64_=1 -Damd64=1 -D_WIN64=1 -D_AMD64_=1 -DAMD64=1 -DNOMINMAX
    RCFLAGS	 += -nologo -D_X64_=1 -Damd64=1 -D_WIN64=1 -D_AMD64_=1 -DAMD64=1
    LFLAGS  += -MACHINE:X64
    SLFLAGS += -MACHINE:X64
else ifeq ($(BUILDARCH), x86)
    MIDL_CFLAGS	= -char signed -win32 -Oicf -error all
    CFLAGS   += -D_X86_=1 -Di386=1 -Dx86=1 -DNOMINMAX
    CXXFLAGS += -D_X86_=1 -Di386=1 -Dx86=1 -DNOMINMAX
    MLFLAGS  += -coff
    RCFLAGS	 += -nologo -D_X86_=1 -Di386=1 -Dx86=1
    LFLAGS  += -MACHINE:X86
    SLFLAGS += -MACHINE:X86
endif

ifeq ($(BUILDTYPE),debug)
    CFLAGS += -D_DEBUG -DDBG=1 -wd4748
    CXXFLAGS += -D_DEBUG
    LFLAGS  += -DEBUG
    MLFLAGS += -Zd
    ifeq ($(THREADMODE),mt)
        CFLAGS += -MTd
        CXXFLAGS += -MTd
    else
        CFLAGS += -MDd
        CXXFLAGS += -MDd
    endif
else
    CFLAGS   += -Oi -DNDEBUG
    CXXFLAGS += -Oi -DNDEBUG
    LFLAGS  += -OPT:REF -OPT:ICF -RELEASE
    ifeq ($(THREADMODE),mt)
        CFLAGS += -MT
        CXXFLAGS += -MT
    else
        CFLAGS += -MD
        CXXFLAGS += -MD
    endif
endif

ifeq ($(BUILDTYPE),release)
    CFLAGS += -O2
    CXXFLAGS += -O2
else
    CFLAGS += -Od
    CXXFLAGS += -Od
endif

ifeq ($(TGTTYPE),dll)
    LFLAGS += -DLL
    ifneq (,$(DEFFILE))
        LFLAGS  += -DEF:$(DEFFILE)
    endif
endif

# Warning flags
ifeq ($(WARNS_AS_ERROR),all)
    CFLAGS += -WX
    CXXFLAGS += -WX
else
    CFLAGS += -WX-
    CXXFLAGS += -WX-
    CFLAGS += $(addprefix -we, $(WARNS_AS_ERROR))
    CXXFLAGS += $(addprefix -we, $(WARNS_AS_ERROR))
endif

ifneq ($(WARNS_IGNORED),)
    CXXFLAGS += $(addprefix -wd, $(WARNS_IGNORED))
endif

# Check minimal OS version
ifeq ($(TGTMINOSVER), 0501)
    TGTMINOSNAME=WinXP
    TGTSUBSYSVER=",5.01"
else ifeq ($(TGTMINOSVER), 0502)
    TGTMINOSNAME=Win2003
    TGTSUBSYSVER=",5.02"
else ifeq ($(TGTMINOSVER), 0600)
    TGTMINOSNAME=WinVista
    TGTSUBSYSVER=",6.00"
else ifeq ($(TGTMINOSVER), 0601)
    TGTMINOSNAME=Win7
    TGTSUBSYSVER=",6.01"
else ifeq ($(TGTMINOSVER), 0602)
    TGTMINOSNAME=Win8
    TGTSUBSYSVER=",6.02"
else ifeq ($(TGTMINOSVER), 0603)
    TGTMINOSNAME=Win8.1
    TGTSUBSYSVER=",6.03"
else ifeq ($(TGTMINOSVER), 1000)
    TGTMINOSNAME=Win10
    TGTSUBSYSVER=",10.00"
else
    TGTMINOSVER=0601
    TGTMINOSNAME=Win7
    TGTSUBSYSVER=",6.01"
endif

ifeq ($(TARGETMODE), kernel)
	# Windows Kernel Mode Module
    CFLAGS += -MP -GS -analyze -Gy -Zc:wchar_t- -analyze:"stacksize1024" -Zi -Gm- \
	          -FI "$(PREFERED_WDKINCDIR)/shared/warning.h" \
			  -fp:precise -Zp8 -errorReport:prompt -GF -W4 -Zc:inline -GR- -Gz -Oy- -nologo -kernel \
			  -DKERNELMODE=1 -DSTD_CALL -D_WIN32_WINNT=0x$(TGTMINOSVER) -DWINVER=0x$(TGTMINOSVER) -DWINNT=1 -DNTDDI_VERSION=0x$(TGTMINOSVER)0000 \
			  -DALLOC_PRAGMA -Fd"$(INTDIR)/vc$(PREFERED_VSVERSHORT).pdb"
    CXXFLAGS += -MP -GS -analyze -Gy -Zc:wchar_t- -analyze:"stacksize1024" -Zi -Gm- \
	          -FI "$(PREFERED_WDKINCDIR)/shared/warning.h" \
			  -fp:precise -Zp8 -errorReport:prompt -GF -W4 -Zc:inline -GR- -Gz -Oy- -nologo -kernel \
			  -DKERNELMODE=1 -DSTD_CALL -D_WIN32_WINNT=0x$(TGTMINOSVER) -DWINVER=0x$(TGTMINOSVER) -DWINNT=1 -DNTDDI_VERSION=0x$(TGTMINOSVER)0000 \
			  -DALLOC_PRAGMA -Fp"$(INTDIR)/$(TGTNAME).pch" -Fd"$(INTDIR)/vc$(PREFERED_VSVERSHORT).pdb"
    LFLAGS  += -kernel -MANIFEST:NO -PROFILE -Driver -PDB:$(INTDIR)/$(TGTNAME).pdb -VERSION:"6.3" -DEBUG -WX -OPT:REF -INCREMENTAL:NO \
	            -SUBSYSTEM:$(TGTSUBSYS)$(TGTSUBSYSVER) -OPT:ICF -ERRORREPORT:PROMPT -MERGE:"_TEXT=.text;_PAGE=PAGE" -NOLOGO -NODEFAULTLIB -SECTION:"INIT,d" -IGNORE:4078 \
                fltmgr.lib BufferOverflowK.lib ntoskrnl.lib hal.lib wmilib.lib Ntstrsafe.lib
    SLFLAGS += -NOLOGO
    RCFLAGS	+= -I"$(PREFERED_WDKINCDIR)/um" -I$(INCDIR) -DSTD_CALL
    ifeq ($(BUILDARCH), x64)
        LFLAGS  += -ENTRY:"GsDriverEntry"
    else ifeq ($(BUILDARCH), x86)
        LFLAGS  += -ENTRY:"GsDriverEntry@8"
    endif
else
	# Windows User Mode Module
    CFLAGS   += -EHa -nologo -Zi -W3 -MP -GS -analyze -GL -FAcs -Gd -Zc:wchar_t -Zc:inline -fp:precise -errorReport:prompt -DUNICODE -D_UNICODE \
	            -DWIN32_LEAN_AND_MEAN -D_WIN32_WINNT=0x$(TGTMINOSVER) -DWINVER=0x$(TGTMINOSVER) -DWINNT=1 -DNTDDI_VERSION=0x$(TGTMINOSVER)0000 \
                -Fd"$(INTDIR)/vc$(PREFERED_VSVERSHORT).pdb" -Fa"$(INTDIR)/"
    CXXFLAGS += -EHa -nologo -Zi -W3 -MP -GS -analyze -GL -FAcs -Gd -Zc:wchar_t -Zc:inline -fp:precise -errorReport:prompt -DUNICODE -D_UNICODE \
	            -DWIN32_LEAN_AND_MEAN -D_WIN32_WINNT=0x$(TGTMINOSVER) -DWINVER=0x$(TGTMINOSVER) -DWINNT=1 -DNTDDI_VERSION=0x$(TGTMINOSVER)0000 \
                -Fd"$(INTDIR)/vc$(PREFERED_VSVERSHORT).pdb" -Fa"$(INTDIR)/"
    LFLAGS  += -NOLOGO -PROFILE -LTCG -DYNAMICBASE -NXCOMPAT -PDB:"$(INTDIR)/$(TGTNAME).pdb" -LTCG:incremental -TLBID:1 -SUBSYSTEM:$(TGTSUBSYS)$(TGTSUBSYSVER) \
               kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
    SLFLAGS += -NOLOGO -LTCG
    ifeq ($(TGTTYPE),dll)
        CFLAGS   += -D_USRDLL -D_WINDLL
        CXXFLAGS += -D_USRDLL -D_WINDLL
    endif
endif

ifneq ($(TGTPCHNAME),)
    PCHFILE=$(TGTNAME).pch
    PCHCFLAGS = -Yc"$(TGTPCHNAME).h" -Fp"$(INTDIR)/$(PCHFILE)"
    PCHUFLAGS = -Yu"$(TGTPCHNAME).h" -Fp"$(INTDIR)/$(PCHFILE)"
endif

#-----------------------------------#
#	Rules					        #
#-----------------------------------#

.PHONY: printbuildtools
.PHONY: printbuildflags

printbuildtools:
	@echo "[Visual Studio Tools]"
	@echo "  CC:       $(CC)"
	@echo "  CXX:      $(CXX)"
	@echo "  LIB:      $(LIB)"
	@echo "  LINK:     $(LINK)"
	@echo "  DUMPBIN:  $(DUMPBIN)"
	@echo "  NMAKE:    $(NMAKE)"
	@echo "[SDK Tools]"
	@echo "  RC:       $(RC)"
	@echo "  MC:       $(MC)"
	@echo "  MIDL:     $(MIDL)"
	@echo "  UUIDGEN:  $(UUIDGEN)"
	@echo "  SIGNTOOL: $(SIGNTOOL)"
	@echo "  STAMPINF: $(STAMPINF)"
	@echo "  CERT2SPC: $(CERT2SPC)"

printbuildflags:
	@echo "[Compiler Flags]"
	@echo '  IFLAGS: $(IFLAGS)'
	@echo '  CFLAGS: $(CFLAGS)'
	@echo '  CXXFLAGS: $(CXXFLAGS)'
	@echo "[Linker Flags]"
	@echo '  LFLAGS: $(LFLAGS)'