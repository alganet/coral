🐚 coral Specification
======================

Our documents are
[literate](https://en.wikipedia.org/wiki/Literate_programming) documents
containing natural language combined with contextual code snippets that
run as tests.

Basic Run
---------

The basic test suite should run all document and library tests.

```console task
$ coral spec spec/*/*
```

Testing Other Shells
--------------------

For that, we'll need a `Dockerfile`

```Dockerfile file Dockerfile
FROM ubuntu:trusty

ARG APT
ENV APT $APT

RUN ${APT:+apt-get -y update}
RUN ${APT:+apt-get -y dist-upgrade}

ARG PPA
ENV PPA $PPA

RUN ${PPA:+apt-get -y install software-properties-common}
RUN ${PPA:+add-apt-repository --enable-source -y ppa:$PPA}
RUN ${PPA:+apt-get -y update}
RUN ${APT:+apt-get -y install $APT}

RUN mkdir -p /usr/local/share/coral
COPY [".", "/usr/local/share/coral"]
WORKDIR /usr/local/share/coral
```

This image will allow us to install multiple shells to test their 
compatibility:

### Default Ubuntu dash

```console task
$ docker build --build-arg "TARGET=sh" -t dash .
$ docker run dash
```

### Default Ubuntu bash

```console task
$ docker build --build-arg "TARGET=bash" -t bash .
$ docker run bash
```

### Default Ubuntu yash

```console task
$ docker build --build-arg APT="yash" -t yash .
$ docker run -e spec_shell="yash" -t yash yash -c './coral spec spec/*/*'
```

### Default Ubuntu posh

```console task
$ docker build --build-arg APT="posh" -t posh .
$ docker run -e spec_shell="posh" -t posh posh -c './coral spec spec/*/*'
```

### Default Ubuntu zsh

```console task
$ docker build --build-arg APT="zsh" -t zsh .
$ docker run -e spec_shell="zsh" -t zsh zsh -c './coral spec spec/*/*'
```

### Default Ubuntu mksh

```console task
$ docker build --build-arg APT="mksh" -t mksh .
$ docker run -e spec_shell="mksh" -t mksh mksh -c './coral spec spec/*/*'
```

### Default Ubuntu pdksh

```console task
$ docker build --build-arg APT="pdksh" -t pdksh .
$ docker run -e spec_shell="pdksh" -t pdksh pdksh -c './coral spec spec/*/*'
```

### Default Ubuntu ksh

```console task
$ docker build --build-arg APT="ksh" -t ksh .
$ docker run -e spec_shell="ksh" -t ksh ksh -c './coral spec spec/*/*'
```

### Default Ubuntu zsh-beta

```console task
$ docker build --build-arg APT="zsh-beta" -t zsh-beta .
$ docker run -e spec_shell="zsh-beta" -t zsh-beta zsh-beta -c './coral spec spec/*/*'
```

### Default Ubuntu busybox

```console task
$ docker build --build-arg APT="busybox" -t busybox .
$ docker run -e spec_shell="busybox sh" -t busybox busybox sh -c './coral spec spec/*/*'
```

### Bash 2.05b

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-2.05b.13" -t bash2 .
$ docker run -e spec_shell="bash-2.05b.13" -t bash2 bash-2.05b.13 -c './coral spec spec/*/*'
```

### Bash 3.0

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-3.0.16" -t bash3 .
$ docker run -e spec_shell="bash-3.0.16" -t bash3 bash-3.0.16 -c './coral spec spec/*/*'
```

### Bash 3.1

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-3.1.9" -t bash31 .
$ docker run -e spec_shell="bash-3.1.9" -t bash31 bash-3.1.9 -c './coral spec spec/*/*'
```

### Bash 3.2

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-3.2.9" -t bash32 .
$ docker run -e spec_shell="bash-3.2.9" -t bash32 bash-3.2.9 -c './coral spec spec/*/*'
```

### Bash 4.0

This version is unsupported!

### Bash 4.1

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-4.1.9" -t bash41 .
$ docker run -e spec_shell="bash-4.1.9" -t bash41 bash-4.1.9 -c './coral spec spec/*/*'
```

### Bash 4.2

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-4.2.53" -t bash42 .
$ docker run -e spec_shell="bash-4.2.53" -t bash42 bash-4.2.53 -c './coral spec spec/*/*'
```

### Bash 4.3

```console task
$ docker build --build-arg "PPA=team-mayhem/multishell" --build-arg "APT=bash-4.3.9" -t bash43 .
$ docker run -e spec_shell="bash-4.3.9" -t bash43 bash-4.3.9 -c './coral spec spec/*/*'
```

### Default Alpine sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" alpine:latest sh -c './coral spec spec/*/*'
```

### Default Amazon Linux sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" amazonlinux:latest sh -c './coral spec spec/*/*'
```

### Default CentOS sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" centos:latest sh -c './coral spec spec/*/*'
```

### Default Fedora sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" fedora:latest sh -c './coral spec spec/*/*'
```

### Default Debian sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" debian:latest sh -c './coral spec spec/*/*'
```

### Default OpenSuse sh

```console task
$ docker run -v "$(pwd):/coral" -w "/coral" -e spec_shell="sh" opensuse:latest sh -c './coral spec spec/*/*'
```