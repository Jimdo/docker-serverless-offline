FROM node:7.7-alpine

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.7-openjdk/jre/bin:/usr/lib/jvm/java-1.7-openjdk/bin

ENV JAVA_VERSION 7u121
ENV JAVA_ALPINE_VERSION 7.121.2.6.8-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk7="$JAVA_ALPINE_VERSION" \
		git \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN mkdir -p /usr/src/app

RUN echo "===> install serverless command"  && \
    npm install -g serverless  && \
    echo "===> install dynamodb package"  && \
    cd /usr/src/app && \
    npm install dynamodb-localhost && \
    echo "===> install dynamodb"  && \
    node -e "var dynamodbLocal = require('dynamodb-localhost'); \
             dynamodbLocal.install(function() {});" && \
    echo "===> install pm2 monitor"  && \
    npm install -g pm2
    
