```Dockerfile file Dockerfile.builder
FROM alpine:latest

RUN apk add --no-cache \
		bzip2 \
		coreutils \
		curl \
		gcc \
		linux-headers \
		make \
		musl-dev \
		tzdata

ENV BUSYBOX_VERSION 1.27.2

RUN set -ex; \
	tarball="busybox-${BUSYBOX_VERSION}.tar.bz2"; \
	curl -fL -o busybox.tar.bz2 "https://busybox.net/downloads/$tarball"; \
	mkdir -p /usr/src/busybox; \
	tar -xf busybox.tar.bz2 -C /usr/src/busybox --strip-components 1; \
	rm busybox.tar.bz2*

WORKDIR /usr/src/busybox

# https://www.mail-archive.com/toybox@lists.landley.net/msg02528.html
# https://www.mail-archive.com/toybox@lists.landley.net/msg02526.html
RUN sed -i 's/^struct kconf_id \*$/static &/g' scripts/kconfig/zconf.hash.c_shipped

RUN set -ex; \
	\
	setConfs=' \
		CONFIG_LAST_SUPPORTED_WCHAR=0 \
		CONFIG_STATIC=y \
		CONFIG_BUSYBOX=y \
		CONFIG_FEATURE_INSTALLER=y \
		CONFIG_COMM=y \
		CONFIG_CP=y \
		CONFIG_FIND=y \
		CONFIG_MKDIR=y \
		CONFIG_MV=y \
		CONFIG_RM=y \
		CONFIG_SED=y \
		CONFIG_SORT=y \
		CONFIG_SH_IS_ASH=y \
		CONFIG_ASH=y \
		CONFIG_BASH_IS_NONE=y \
		CONFIG_ASH_OPTIMIZE_FOR_SIZE=y \
		CONFIG_ASH_ECHO=y \
		CONFIG_ASH_RANDOM_SUPPORT=y \
		CONFIG_ASH_TEST=y \
		CONFIG_ASH_PRINTF=y \
		CONFIG_FEATURE_SH_MATH=y \
		CONFIG_FEATURE_SH_EXTRA_QUIET=y \
	'; \
	\
	unsetConfs=' \
		CONFIG_LONG_OPTS \
	'; \
	\
	make allnoconfig; \
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
	&& ./busybox \
	&& mkdir -p rootfs/bin \
	&& ln -vL busybox rootfs/bin/ \
	&& chroot rootfs /bin/busybox --install /bin \
	&& find rootfs

# create /tmp
RUN mkdir -p rootfs/tmp \
	&& chmod 1777 rootfs/tmp

# test and make sure it works
RUN chroot rootfs /bin/sh -xc 'busybox'
RUN tar cC rootfs . | bzip2 > "busybox.tar.bz2"

FROM scratch
ADD --from=builder "busybox.tar.bz2" /
CMD ["sh"]
```

```console task
$ ./lib/dev module_assemble spec_doc spec_doc
```

```console task
$ docker build -t coral-builder -f Dockerfile.builder .
$ docker run --rm "coral-builder" tar cC rootfs . | bzip2 > "busybox.tar.bz2"
$ docker build -t "coral" .
$ docker run --rm -v "$(pwd):/coral" -w "/coral" coral sh -c 'sh ./spec_doc $(find doc/spec/*)'
```
