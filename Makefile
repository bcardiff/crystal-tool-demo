CRYSTAL ?= crystal

CRYSTAL_CONFIG_PATH=$(shell $(CRYSTAL) env CRYSTAL_PATH 2> /dev/null)
CRYSTAL_CONFIG_LIBRARY_PATH=$(shell $(CRYSTAL) env CRYSTAL_LIBRARY_PATH 2> /dev/null)

EXPORTS := \
  CRYSTAL_CONFIG_PATH="$(CRYSTAL_CONFIG_PATH)" \
  CRYSTAL_CONFIG_LIBRARY_PATH="$(CRYSTAL_CONFIG_LIBRARY_PATH)"

SHELL = sh

BINDIR = ./bin

ALL_TOOLS =

define tool # (src.cr,output)
$(eval tool_source = $(1))
$(eval tool_output = $(BINDIR)/$(2))

$(tool_output): $(tool_source)
	mkdir -p $(BINDIR)
	$(EXPORTS) $(CRYSTAL) build $(FLAGS) $(tool_source) -o $(tool_output)

$(eval ALL_TOOLS += $(tool_output))
endef

.PHONY: all
all: $(ALL_TOOLS)

clean:
	rm -f bin/*

$(eval $(call tool,src/ivars-count.cr,ivars-count))
$(eval $(call tool,src/top-level.cr,top-level))
