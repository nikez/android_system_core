LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

TOOLS := \
	ls \
	mount \
	cat \
	ps \
	kill \
	ln \
	insmod \
	rmmod \
	lsmod \
	ifconfig \
	setconsole \
	rm \
	mkdir \
	rmdir \
	getevent \
	sendevent \
	date \
	wipe \
	sync \
	umount \
	start \
	stop \
	notify \
	cmp \
	dmesg \
	route \
	hd \
	dd \
	df \
	getprop \
	setprop \
	watchprops \
	log \
	sleep \
	renice \
	printenv \
	smd \
	chmod \
	chown \
	newfs_msdos \
	netstat \
	ioctl \
	mv \
	schedtop \
	top \
	iftop \
	id \
	uptime \
	vmstat \
	nandread \
	ionice \
	touch \
	lsof

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
TOOLS += r
endif

LOCAL_SRC_FILES:= \
	dynarray.c \
	toolbox.c \
	$(patsubst %,%.c,$(TOOLS))

TOOLS += reboot

ifeq ($(BOARD_USES_BOOTMENU),true)
	LOCAL_SRC_FILES += ../../../external/bootmenu/libreboot/reboot.c
else
	LOCAL_SRC_FILES += reboot.c
endif

LOCAL_SHARED_LIBRARIES := libcutils libc libusbhost

LOCAL_MODULE:= toolbox

# Including this will define $(intermediates).
#
include $(BUILD_EXECUTABLE)

$(LOCAL_PATH)/toolbox.c: $(intermediates)/tools.h

TOOLS_H := $(intermediates)/tools.h
$(TOOLS_H): PRIVATE_TOOLS := $(TOOLS)
$(TOOLS_H): PRIVATE_CUSTOM_TOOL = echo "/* file generated automatically */" > $@ ; for t in $(PRIVATE_TOOLS) ; do echo "TOOL($$t)" >> $@ ; done
$(TOOLS_H): $(LOCAL_PATH)/Android.mk
$(TOOLS_H):
	$(transform-generated-source)

# Make #!/system/bin/toolbox launchers for each tool.
#

# use busybox versions
exclude_links := chmod chown df ln ls lsof mkdir mount mv rm touch umount

SYMLINKS := $(addprefix $(TARGET_OUT)/bin/,$(filter-out $(exclude_links),$(TOOLS)))
$(SYMLINKS): TOOLBOX_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE) $(LOCAL_PATH)/Android.mk
	@echo "Symlink: $@ -> $(TOOLBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(TOOLBOX_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS)
