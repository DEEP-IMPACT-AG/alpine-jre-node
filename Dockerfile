FROM node:8.12-alpine

# install the necessary dependencies
RUN apk update && apk add --no-cache bash supervisor openssl wget bind-tools

# ssh-keygen -A generates all necessary host keys (rsa, dsa, ecdsa, ed25519) at default location.
RUN apk add openssh \
    && mkdir /root/.ssh \
    && chmod 0700 /root/.ssh \
    && ssh-keygen -A \
    && sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config \
    && echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDqn6ZPwm/1DxI9WfgXFZYKQVq8Nu6oS588zZ2UHWAyYA4KlyTCZrDpaheQQpxwUMMoIeA2geU8ia8t6rvVYUl9sE2UJlvhwRFqv8c4tw62Q/4mQWutnIQv7FdaCZuTfu/ZSSaa66dhaGs0u1KrKX9OFLnEpoaRzt9RgAQq4wHLSXbaL5B4hWdXwk+qgPPwGp5JnLMLPJfZoxiFFmL4MzcFCd0nCi3jl48xqNXdLKjapwmYtMbNr6OsxwFQJFPJ/J1n/+AuVTsxVGLVuBL9/qSAJ6NYjrNoscv09iLDP87jO2+oR9GCEj2DSPwuTIt0SlndAZSUgM6XnQITOgkDnkp dreamliner-ssh-qa" > /root/.ssh/authorized_keys

# The following is taken from the official alpine openjdk-8 docker image:
# https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home && \
	chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV	JAVA_VERSION 8u222
ENV	JAVA_ALPINE_VERSION 8.222.10-r0

RUN set -x && \
    apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" && \
    [ "$JAVA_HOME" = "$(docker-java-home)" ]
