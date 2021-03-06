FROM debian:buster-slim

LABEL maintainer="<marcelo.frneves@gmail.com>"
LABEL name="Marcelo França"
LABEL version="v1.1.0"
ENV USER "devopsuser"
ENV LOCAL_SCRIPTS="/usr/local/src"
ENV TF_VERSION "0.15.1"
ENV PK_VERSION "1.7.2"
ENV PATH="$LOCAL_SCRIPTS/:$PATH"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget curl bash-completion \
 vim git sudo unzip python3 python3-pip openssh-client gnupg2 gnupg1 --no-install-recommends -y \
    && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
    && apt-get update && apt-get install ansible python-apt python-pip -y

# Download AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Download terraform
RUN wget "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"

# Download packer
RUN wget "https://releases.hashicorp.com/packer/${PK_VERSION}/packer_${PK_VERSION}_linux_amd64.zip"


#COPY ./config/VMware-ovftool-4.4.1-16812187-lin.x86_64.bundle /tmp/

RUN useradd -m ${USER} -s /bin/bash \
  && if [ -z "${PASSWORD}" ]; then \
  export PASSWORD=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}` && \
  echo -n "\n\n===================== USER ==========================\n \
  admin user: ${USER} \n \
  password: ${PASSWORD}\n\n" > /dev/stdout; \
  fi \
  && (echo ${PASSWORD} ; echo ${PASSWORD} ) | passwd ${USER} \
  && gpasswd -a ${USER} sudo \
  && echo "${USER} ALL=(ALL) NOPASSWD: DEVOPSUSER" >> /etc/sudoers \
  && chown ${USER}:${USER} /etc/ansible -R

## Configuring ansible.cfg
RUN sed -i 's/^#host_key_checking\ =\ False/host_key_checking\ =\ False/g' \
  /etc/ansible/ansible.cfg

## Install AWS cli
RUN unzip -q awscliv2.zip -d /tmp \
  && ./tmp/aws/install
## Install Terraform and Packer
RUN unzip -q terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
  && unzip -q packer_${PK_VERSION}_linux_amd64.zip -d /usr/local/bin

## Install VMware tools
#RUN chmod 755 /tmp/*.bundle \
#    && ./tmp/VMware-ovftool-4.4.1-16812187-lin.x86_64.bundle --eulas-agreed

RUN apt-get clean autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/{apt,cache,log}/ \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -f *.zip

USER ${USER}

WORKDIR /home/${USER}

ENTRYPOINT []
