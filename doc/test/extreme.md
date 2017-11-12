```Dockerfile file Dockerfile.builder
FROM alpine:latest

RUN apk add --no-cache \
		bzip2 \
		coreutils \
		curl \
		gcc \
		gnupg \
		linux-headers \
		make \
		musl-dev \
		tzdata

# pub   1024D/ACC9965B 2006-12-12
#       Key fingerprint = C9E9 416F 76E6 10DB D09D  040F 47B7 0C55 ACC9 965B
# uid                  Denis Vlasenko <vda.linux@googlemail.com>
# sub   1024g/2C766641 2006-12-12
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C9E9416F76E610DBD09D040F47B70C55ACC9965B

ENV BUSYBOX_VERSION 1.27.2

RUN set -ex; \
	tarball="busybox-${BUSYBOX_VERSION}.tar.bz2"; \
	curl -fL -o busybox.tar.bz2 "https://busybox.net/downloads/$tarball"; \
	curl -fL -o busybox.tar.bz2.sign "https://busybox.net/downloads/$tarball.sign"; \
	gpg --batch --decrypt --output busybox.tar.bz2.txt busybox.tar.bz2.sign; \
	awk '$1 == "SHA1:" && $2 ~ /^[0-9a-f]+$/ && $3 == "'"$tarball"'" { print $2, "*busybox.tar.bz2" }' busybox.tar.bz2.txt > busybox.tar.bz2.sha1; \
	test -s busybox.tar.bz2.sha1; \
	sha1sum -c busybox.tar.bz2.sha1; \
	mkdir -p /usr/src/busybox; \
	tar -xf busybox.tar.bz2 -C /usr/src/busybox --strip-components 1; \
	rm busybox.tar.bz2*

WORKDIR /usr/src/busybox

# https://www.mail-archive.com/toybox@lists.landley.net/msg02528.html
# https://www.mail-archive.com/toybox@lists.landley.net/msg02526.html
RUN sed -i 's/^struct kconf_id \*$/static &/g' scripts/kconfig/zconf.hash.c_shipped

# CONFIG_LAST_SUPPORTED_WCHAR: see https://github.com/docker-library/busybox/issues/13 (UTF-8 input)
# see http://wiki.musl-libc.org/wiki/Building_Busybox
RUN set -ex; \
	\
	setConfs=' \
		CONFIG_AR=y \
		CONFIG_FEATURE_AR_CREATE=y \
		CONFIG_FEATURE_AR_LONG_FILENAMES=y \
		CONFIG_LAST_SUPPORTED_WCHAR=0 \
		CONFIG_STATIC=y \
		CONFIG_SH_IS_ASH=y \
	'; \
	\
	unsetConfs=' \
		CONFIG_FEATURE_SYNC_FANCY \
		\
		CONFIG_FEATURE_HAVE_RPC \
		CONFIG_FEATURE_INETD_RPC \
		CONFIG_FEATURE_UTMP \
		CONFIG_FEATURE_WTMP \
		\
		CONFIG_DESKTOP \
		CONFIG_HUSH \
		CONFIG_ASH_GETOPTS \
		CONFIG_ASH_ALIAS \
		CONFIG_ASH_MAIL \
		CONFIG_ASH_HELP \
		\
		CONFIG_ACPID \
		CONFIG_ADD_SHELL \
		CONFIG_ADDGROUP \
		CONFIG_ADDUSER \
		CONFIG_ADJTIMEX \
		CONFIG_ARP \
		CONFIG_ARPING \
		CONFIG_AWK \
		CONFIG_BASE64 \
		CONFIG_BASENAME \
		CONFIG_BB_SYSCTL \
		CONFIG_BEEP \
		CONFIG_BLKDISCARD \
		CONFIG_BLKID \
		CONFIG_BLOCKDEV \
		CONFIG_BOOTCHARTD \
		CONFIG_BRCTL \
		CONFIG_BUNZIP2 \
		CONFIG_BZCAT \
		CONFIG_BZIP2 \
		CONFIG_CAL \
		CONFIG_CHAT \
		CONFIG_CHATTR \
		CONFIG_CHGRP \
		CONFIG_CHOWN \
		CONFIG_CHPASSWD \
		CONFIG_CHPST \
		CONFIG_CHROOT \
		CONFIG_CHRT \
		CONFIG_CHVT \
		CONFIG_CKSUM \
		CONFIG_CLEAR \
		CONFIG_CMP \
		CONFIG_CONSPY \
		CONFIG_CPIO \
		CONFIG_CROND \
		CONFIG_CRONTAB \
		CONFIG_CRYPTPW \
		CONFIG_CTTYHACK \
		CONFIG_CUT \
		CONFIG_DATE \
		CONFIG_DC \
		CONFIG_DD \
		CONFIG_DEALLOCVT \
		CONFIG_DELGROUP \
		CONFIG_DELUSER \
		CONFIG_DEPMOD \
		CONFIG_DEVMEM \
		CONFIG_DF \
		CONFIG_DHCPRELAY \
		CONFIG_DIFF \
		CONFIG_DIRNAME \
		CONFIG_DMESG \
		CONFIG_DNSD \
		CONFIG_DNSDOMAINNAME \
		CONFIG_DOS2UNIX \
		CONFIG_DPKG \
		CONFIG_DPKG_DEB \
		CONFIG_DU \
		CONFIG_DUMPKMAP \
		CONFIG_DUMPLEASES \
		CONFIG_ECHO \
		CONFIG_ED \
		CONFIG_EGREP \
		CONFIG_EJECT \
		CONFIG_ENVDIR \
		CONFIG_ENVUIDGID \
		CONFIG_ETHER_WAKE \
		CONFIG_EXPAND \
		CONFIG_EXPR \
		CONFIG_FACTOR \
		CONFIG_FAKEIDENTD \
		CONFIG_FALLOCATE \
		CONFIG_FATATTR \
		CONFIG_FBSET \
		CONFIG_FBSPLASH \
		CONFIG_FDFLUSH \
		CONFIG_FDFORMAT \
		CONFIG_FDISK \
		CONFIG_FGCONSOLE \
		CONFIG_FGREP \
		CONFIG_FINDFS \
		CONFIG_FLOCK \
		CONFIG_FOLD \
		CONFIG_FREE \
		CONFIG_FREERAMDISK \
		CONFIG_FSCK \
		CONFIG_FSCK_MINIX \
		CONFIG_FSFREEZE \
		CONFIG_FSTRIM \
		CONFIG_FSYNC \
		CONFIG_FTPD \
		CONFIG_FTPGET \
		CONFIG_FTPPUT \
		CONFIG_FUSER \
		CONFIG_GETOPT \
		CONFIG_GETTY \
		CONFIG_GREP \
		CONFIG_GROUPS \
		CONFIG_GUNZIP \
		CONFIG_GZIP \
		CONFIG_HALT \
		CONFIG_HAVE_DOT_CONFIG \
		CONFIG_HD \
		CONFIG_HDPARM \
		CONFIG_HEAD \
		CONFIG_HEXDUMP \
		CONFIG_HOSTID \
		CONFIG_HOSTNAME \
		CONFIG_HTTPD \
		CONFIG_HWCLOCK \
		CONFIG_I2CDETECT \
		CONFIG_I2CDUMP \
		CONFIG_I2CGET \
		CONFIG_I2CSET \
		CONFIG_ID \
		CONFIG_IFCONFIG \
		CONFIG_IFDOWN \
		CONFIG_IFENSLAVE \
		CONFIG_IFPLUGD \
		CONFIG_IFUP \
		CONFIG_INCLUDE_SUSv2 \
		CONFIG_INETD \
		CONFIG_INIT \
		CONFIG_INSMOD \
		CONFIG_IOCTL_HEX2STR_ERROR \
		CONFIG_IONICE \
		CONFIG_IOSTAT \
		CONFIG_INSTALL \
		CONFIG_IP \
		CONFIG_IPADDR \
		CONFIG_IPCALC \
		CONFIG_IPCRM \
		CONFIG_IPCS \
		CONFIG_IPLINK \
		CONFIG_IPNEIGH \
		CONFIG_IPROUTE \
		CONFIG_IPRULE \
		CONFIG_IPTUNNEL \
		CONFIG_KBD_MODE \
		CONFIG_KILL \
		CONFIG_KILLALL5 \
		CONFIG_KILLALL \
		CONFIG_KLOGD \
		CONFIG_LESS \
		CONFIG_LINK \
		CONFIG_LINUX32 \
		CONFIG_LINUX64 \
		CONFIG_LINUXRC \
		CONFIG_LOADFONT \
		CONFIG_LOADKMAP \
		CONFIG_LOGGER \
		CONFIG_LOGIN \
		CONFIG_LOGIN_SCRIPTS \
		CONFIG_LOGNAME \
		CONFIG_LOGREAD \
		CONFIG_LOSETUP \
		CONFIG_LPD \
		CONFIG_LPQ \
		CONFIG_LPR \
		CONFIG_LS \
		CONFIG_LSATTR \
		CONFIG_LSMOD \
		CONFIG_LSOF \
		CONFIG_LSPCI \
		CONFIG_LSSCSI \
		CONFIG_LSUSB \
		CONFIG_LZCAT \
		CONFIG_LZMA \
		CONFIG_LZOP \
		CONFIG_MAKEDEVS \
		CONFIG_MAKEMIME \
		CONFIG_MAN \
		CONFIG_MD5SUM \
		CONFIG_MDEV \
		CONFIG_MESG \
		CONFIG_MICROCOM \
		CONFIG_MKDOSFS \
		CONFIG_MKE2FS \
		CONFIG_MKFIFO \
		CONFIG_MKFS_EXT2 \
		CONFIG_MKFS_MINIX \
		CONFIG_MKFS_VFAT \
		CONFIG_MKNOD \
		CONFIG_MKPASSWD \
		CONFIG_MKSWAP \
		CONFIG_MKTEMP \
		CONFIG_MODINFO \
		CONFIG_MODPROBE \
		CONFIG_MODPROBE_SMALL \
		CONFIG_MONOTONIC_SYSCALL \
		CONFIG_MORE \
		CONFIG_MOUNT \
		CONFIG_MOUNTPOINT \
		CONFIG_MPSTAT \
		CONFIG_MT \
		CONFIG_MV \
		CONFIG_NAMEIF \
		CONFIG_NANDDUMP \
		CONFIG_NANDWRITE \
		CONFIG_NBDCLIENT \
		CONFIG_NC \
		CONFIG_NC_EXTRA \
		CONFIG_NETSTAT \
		CONFIG_NICE \
		CONFIG_NL \
		CONFIG_NMETER \
		CONFIG_NO_DEBUG_LIB \
		CONFIG_NOHUP \
		CONFIG_NPROC \
		CONFIG_NSENTER \
		CONFIG_NTPD \
		CONFIG_NSLOOKUP \
		CONFIG_OD \
		CONFIG_OPENVT \
		CONFIG_PARTPROBE \
		CONFIG_PASSWD \
		CONFIG_PASTE \
		CONFIG_PATCH \
		CONFIG_PGREP \
		CONFIG_PIDOF \
		CONFIG_PING \
		CONFIG_PING6 \
		CONFIG_PIPE_PROGRESS \
		CONFIG_PIVOT_ROOT \
		CONFIG_PKILL \
		CONFIG_PLATFORM_LINUX \
		CONFIG_PMAP \
		CONFIG_POPMAILDIR \
		CONFIG_POWEROFF \
		CONFIG_POWERTOP \
		CONFIG_PRINTENV \
		CONFIG_PRINTF \
		CONFIG_PS \
		CONFIG_PSCAN \
		CONFIG_PSTREE \
		CONFIG_PWD \
		CONFIG_PWDX \
		CONFIG_RAIDAUTORUN \
		CONFIG_RDATE \
		CONFIG_RDEV \
		CONFIG_READAHEAD \
		CONFIG_READLINK \
		CONFIG_READPROFILE \
		CONFIG_REALPATH \
		CONFIG_REBOOT \
		CONFIG_REFORMIME \
		CONFIG_REMOVE_SHELL \
		CONFIG_RENICE \
		CONFIG_RESET \
		CONFIG_RESIZE \
		CONFIG_REV \
		CONFIG_RMMOD \
		CONFIG_ROUTE \
		CONFIG_RPM2CPIO \
		CONFIG_RPM \
		CONFIG_RTCWAKE \
		CONFIG_RUN_PARTS \
		CONFIG_RUNSV \
		CONFIG_RUNSVDIR \
		CONFIG_RX \
		CONFIG_SCRIPT \
		CONFIG_SCRIPTREPLAY \
		CONFIG_SENDMAIL \
		CONFIG_SEQ \
		CONFIG_SETARCH \
		CONFIG_SETCONSOLE \
		CONFIG_SETFONT \
		CONFIG_SETKEYCODES \
		CONFIG_SETLOGCONS \
		CONFIG_SETPRIV \
		CONFIG_SETSERIAL \
		CONFIG_SETSID \
		CONFIG_SETUIDGID \
		CONFIG_SHA1SUM \
		CONFIG_SHA256SUM \
		CONFIG_SHA3SUM \
		CONFIG_SHA512SUM \
		CONFIG_SHOWKEY \
		CONFIG_SHRED \
		CONFIG_SHUF \
		CONFIG_SLATTACH \
		CONFIG_SMEMCAP \
		CONFIG_SOFTLIMIT \
		CONFIG_SPLIT \
		CONFIG_SSL_CLIENT \
		CONFIG_START_STOP_DAEMON \
		CONFIG_STAT \
		CONFIG_STRINGS \
		CONFIG_STTY \
		CONFIG_SU \
		CONFIG_SULOGIN \
		CONFIG_SUM \
		CONFIG_SV \
		CONFIG_SVC \
		CONFIG_SVLOGD \
		CONFIG_SWAPOFF \
		CONFIG_SWAPON \
		CONFIG_SWITCH_ROOT \
		CONFIG_SYNC \
		CONFIG_SYSLOGD \
		CONFIG_TAC \
		CONFIG_TAIL \
		CONFIG_TAR \
		CONFIG_TASKSET \
		CONFIG_TCPSVD \
		CONFIG_TEE \
		CONFIG_TELNET \
		CONFIG_TELNETD \
		CONFIG_TEST1 \
		CONFIG_TEST2 \
		CONFIG_TEST \
		CONFIG_TFTP \
		CONFIG_TFTPD \
		CONFIG_TIME \
		CONFIG_TIMEOUT \
		CONFIG_TLS \
		CONFIG_TOP \
		CONFIG_TRACEROUTE6 \
		CONFIG_TRACEROUTE \
		CONFIG_TR \
		CONFIG_TRUNCATE \
		CONFIG_TTY \
		CONFIG_TTYSIZE \
		CONFIG_TUNCTL \
		CONFIG_UBIATTACH \
		CONFIG_UBIDETACH \
		CONFIG_UBIMKVOL \
		CONFIG_UBIRENAME \
		CONFIG_UBIRMVOL \
		CONFIG_UBIRSVOL \
		CONFIG_UBIUPDATEVOL \
		CONFIG_UDHCPC \
		CONFIG_UDHCPD \
		CONFIG_UDPSVD \
		CONFIG_UEVENT \
		CONFIG_UMOUNT \
		CONFIG_UNAME \
		CONFIG_UNEXPAND \
		CONFIG_UNICODE_SUPPORT \
		CONFIG_UNIQ \
		CONFIG_UNIX2DOS \
		CONFIG_UNLINK \
		CONFIG_UNLZMA \
		CONFIG_UNSHARE \
		CONFIG_UNXZ \
		CONFIG_UNZIP \
		CONFIG_UPTIME \
		CONFIG_USE_BB_CRYPT \
		CONFIG_USE_BB_CRYPT_SHA \
		CONFIG_USE_BB_PWD_GRP \
		CONFIG_USE_BB_SHADOW \
		CONFIG_USLEEP \
		CONFIG_UUDECODE \
		CONFIG_UUENCODE \
		CONFIG_VCONFIG \
		CONFIG_VI \
		CONFIG_VLOCK \
		CONFIG_VOLNAME \
		CONFIG_VOLUMEID \
		CONFIG_WATCH \
		CONFIG_WATCHDOG \
		CONFIG_WC \
		CONFIG_WHICH \
		CONFIG_WHOAMI \
		CONFIG_WHOIS \
		CONFIG_XARGS \
		CONFIG_XXD \
		CONFIG_XZ \
		CONFIG_XZCAT \
		CONFIG_YES \
		CONFIG_ZCAT \
		CONFIG_ZCIP \
		CONFIG_FEATURE_EDITING \
		CONFIG_FEATURE_VERBOSE_USAGE \
		CONFIG_FEATURE_TAB_COMPLETION \
		CONFIG_FEATURE_REVERSE_SEARCH \
		CONFIG_FEATURE_CATV \
		CONFIG_FEATURE_ENV_LONG_OPTIONS \
		CONFIG_FEATURE_MV_LONG_OPTIONS \
		CONFIG_FEATURE_MKDIR_LONG_OPTIONS \
		CONFIG_FEATURE_SORT_BIG \
		CONFIG_FEATURE_VERBOSE \
		CONFIG_FEATURE_HUMAN_READABLE \
		CONFIG_FEATURE_FIND_PRINT0 \
		CONFIG_FEATURE_FIND_MTIME \
		CONFIG_FEATURE_FIND_MMIN \
		CONFIG_FEATURE_FIND_PERM \
		CONFIG_FEATURE_FIND_XDEV \
		CONFIG_FEATURE_FIND_MAXDEPTH \
		CONFIG_FEATURE_FIND_NEWER \
		CONFIG_FEATURE_FIND_INUM \
		CONFIG_FEATURE_FIND_EXEC \
		CONFIG_FEATURE_FIND_EXEC_PLUS \
		CONFIG_FEATURE_FIND_USER \
		CONFIG_FEATURE_FIND_GROUP \
		CONFIG_FEATURE_FIND_NOT \
		CONFIG_FEATURE_FIND_DEPTH \
		CONFIG_FEATURE_FIND_PAREN \
		CONFIG_FEATURE_FIND_SIZE \
		CONFIG_FEATURE_FIND_PRUNE \
		CONFIG_FEATURE_FIND_DELETE \
		CONFIG_FEATURE_FIND_PATH \
		CONFIG_FEATURE_FIND_REGEX \
		CONFIG_FEATURE_WGET_STATUSBAR \
		CONFIG_FEATURE_FLOAT_SLEEP \
		CONFIG_FEATURE_FANCY_SLEEP \
		CONFIG_FEATURE_RMDIR_LONG_OPTIONS \
		CONFIG_FEATURE_TOUCH_NODEREF \
		CONFIG_FEATURE_TOUCH_SUSV3 \
		CONFIG_FEATURE_MKDIR_LONG_OPTIONS \
		CONFIG_FEATURE_CROND_CALL_SENDMAIL \
		CONFIG_FEATURE_POPMAILDIR_DELIVERY \
		CONFIG_CRONTAB \
	'; \
	\
	make defconfig; \
	\
	for conf in $unsetConfs; do \
		sed -i \
			-e "s!^$conf=.*\$!# $conf is not set!" \
			.config; \
	done; \
	\
	for confV in $setConfs; do \
		conf="${confV%=*}"; \
		sed -i \
			-e "s!^$conf=.*\$!$confV!" \
			-e "s!^# $conf is not set\$!$confV!" \
			.config; \
		if ! grep -q "^$confV\$" .config; then \
			echo "$confV" >> .config; \
		fi; \
	done; \
	\
	make oldconfig; \
	\
# trust, but verify
	for conf in $unsetConfs; do \
		! grep -q "^$conf=" .config; \
	done; \
	for confV in $setConfs; do \
		grep -q "^$confV\$" .config; \
	done; \
	cat .config

RUN set -ex \
	&& make -j "$(nproc)" \
		busybox \
	&& ./busybox --list \
	&& mkdir -p rootfs/bin \
	&& ln -vL busybox rootfs/bin/ \
	&& chroot rootfs /bin/busybox --install /bin

# grab a simplified getconf port from Alpine we can statically compile
RUN set -x \
	&& aportsVersion="v$(cat /etc/alpine-release)" \
	&& curl -fsSL \
		"http://git.alpinelinux.org/cgit/aports/plain/main/musl/getconf.c?h=${aportsVersion}" \
		-o /usr/src/getconf.c \
	&& gcc -o rootfs/bin/getconf -static -Os /usr/src/getconf.c \
	&& chroot rootfs /bin/getconf _NPROCESSORS_ONLN

RUN set -ex; \
	buildrootVersion='2017.02.2'; \
	mkdir -p rootfs/etc; \
	for f in passwd shadow group; do \
		curl -fL -o "rootfs/etc/$f" "https://git.busybox.net/buildroot/plain/system/skeleton/etc/$f?id=$buildrootVersion"; \
	done

# create /tmp
RUN mkdir -p rootfs/tmp \
	&& chmod 1777 rootfs/tmp

# create missing home directories
RUN set -ex \
	&& cd rootfs \
	&& for userHome in $(awk -F ':' '{ print $3 ":" $4 "=" $6 }' etc/passwd); do \
		user="${userHome%%=*}"; \
		home="${userHome#*=}"; \
		home="./${home#/}"; \
		if [ ! -d "$home" ]; then \
			mkdir -p "$home"; \
			chown "$user" "$home"; \
		fi; \
	done

# test and make sure it works
RUN chroot rootfs /bin/sh -xc 'env'


```

```Dockerfile file Dockerfile
FROM scratch
ADD busybox.tar.xz /
CMD ["sh"]
```

```console task
$ ./lib/dev module_assemble spec_doc spec_doc
```

```console task
$ docker build -t coral-builder -f Dockerfile.builder .
$ docker run --rm "coral-builder" tar cC rootfs . | xz -z9 > "busybox.tar.xz"
$ docker build -t "coral" .
$ docker run --rm -v "$(pwd):/coral" -w "/coral" coral sh -c './spec_doc $(find doc/spec/*)'
```
