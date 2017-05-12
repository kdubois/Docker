FROM alpine:3.5

RUN apk update \
    && apk add --no-cache bash bash-doc bash-completion

ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_VERSION_MAYOR 8
ENV JAVA_VERSION_MINOR 112
ENV JAVA_VERSION_BUILD 15
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION 8.0.41
ENV JAVA_HOME=/opt/jvm/jdk1.${JAVA_VERSION_MAYOR}.0_${JAVA_VERSION_MINOR}
ENV PATH=$PATH:$JAVA_HOME/bin:${CATALINA_HOME}/bin:${CATALINA_HOME}/scripts
ENV JAVA_OPTS="-Xms2048m -Xmx2048m -Xss5000k"

# Update and install latest packages and prerequisites
RUN apk add --no-cache wget tar curl unzip libstdc++ ca-certificates coreutils \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
    && apk add glibc-2.25-r0.apk \
    && mkdir -p "$CATALINA_HOME"

# Install Oracle JDK and Tomcat
WORKDIR /opt/jvm
RUN curl -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" \
        http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/jdk-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
        > jdk-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    && tar -zxf jdk-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && rm -f jdk-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    && cd /usr/local \
    && wget -nv http://apache.mirrors.pair.com/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
        -O apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm  apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && mv -f apache-tomcat-${TOMCAT_VERSION}/* ${CATALINA_HOME}

WORKDIR $CATALINA_HOME

CMD ["catalina.sh"]