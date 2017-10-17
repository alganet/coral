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
