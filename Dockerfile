FROM ubuntu:20.04

LABEL maintainer="<marcelo.frneves@gmail.com>"
LABEL name="Marcelo França"
ENV USER "devopsuser"
ENV LOCAL_SCRIPTS="/usr/local/src"
ENV TF_VERSION "0.14.9"
ENV PK_VERSION "1.7.2"
ENV PATH="$LOCAL_SCRIPTS/:$PATH"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget curl bash-completion \
 vim git sudo unzip python3 python3-pip openssh-client --no-install-recommends -y


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
  && echo "${USER} ALL=(ALL) NOPASSWD: DEVOPSUSER" >> /etc/sudoers  
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
