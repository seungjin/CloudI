INTERFACE_HEADER=../src/cloudi_os_spawn.hrl
CURRENT_VERSION=vsn_1

bin_PROGRAMS = cloudi_os_spawn_vsn_1

BUILT_SOURCES = $(INTERFACE_HEADER)
CLEANFILES = $(INTERFACE_HEADER) \
             ../priv/cloudi_os_spawn_$(CURRENT_VERSION)
$(INTERFACE_HEADER): Makefile \
                     cloudi_os_spawn_hrl.h \
                     cloudi_os_spawn.h \
                     $(bin_PROGRAMS)
	$(CXX) -DCURRENT_VERSION=$(CURRENT_VERSION) -include cloudi_os_spawn.h \
         $(BOOST_CPPFLAGS) -E -P cloudi_os_spawn_hrl.h > $@
	cp cloudi_os_spawn_$(CURRENT_VERSION) ../priv

cloudi_os_spawn_vsn_1_SOURCES = port.cpp os_spawn.cpp assert.cpp
cloudi_os_spawn_vsn_1_CPPFLAGS = \
 -I$(ERLANG_LIB_DIR_erl_interface)/include/ \
 -I$(ERLANG_ROOT_DIR)/erts-$(ERLANG_ERTS_VER)/include/ \
 -DCURRENT_VERSION=$(CURRENT_VERSION) $(BOOST_CPPFLAGS) \
 -include cloudi_os_spawn.h
cloudi_os_spawn_vsn_1_LDADD = -lei
cloudi_os_spawn_vsn_1_LDFLAGS = -L$(ERLANG_LIB_DIR_erl_interface)/lib/

