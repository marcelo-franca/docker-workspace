FROM ubuntu:20.04

LABEL maintainer="<marcelo.frneves@gmail.com>"
LABEL name="Marcelo França"
ENV USER "devopsuser"
ENV LOCAL_SCRIPTS="/usr/local/src"
ENV PATH="$LOCAL_SCRIPTS/:$PATH"


RUN apt-get update && apt-get upgrade -y

COPY ./config/awscliv2.zip /tmp/awscliv2.zip

RUN apt-get install bash-completion vim git sudo unzip python3 python3-pip  -y

RUN useradd -m ${USER} -s /bin/bash \
  && if [ -z "${PASSWORD}" ]; then \
  export PASSWORD=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}` && \
  echo -n "\n\n===================== USER ==========================\n \
  admin user: ${USER} \n \
  password: ${PASSWORD}\n\n" > /dev/stdout; \
  fi \
  && (echo ${PASSWORD} ; echo ${PASSWORD} ) | passwd ${USER} \
  && gpasswd -a ${USER} sudo \
  && echo "${USER} ALL=(ALL) NOPASSWD: DEVOPSUSER" >> /etc/sudoers  
## Install AWS cli
RUN unzip -q /tmp/awscliv2.zip -d /tmp \
  && ./tmp/aws/install

RUN apt-get clean autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/{apt,cache,log}/ \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/aws*

USER ${USER}

ENTRYPOINT []