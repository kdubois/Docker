FROM centos:7

ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_VERSION_MAYOR 8
ENV JAVA_VERSION_MINOR 71
ENV JAVA_VERSION_BUILD 15
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION 8.0.41
ENV LIB_HOME=/opt/jvm
ENV JAVA_HOME=${LIB_HOME}/jre1.${JAVA_VERSION_MAYOR}.0_${JAVA_VERSION_MINOR}
ENV PATH=$PATH:$JAVA_HOME/bin:${CATALINA_HOME}/bin:${CATALINA_HOME}/scripts
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

WORKDIR $LIB_HOME

# Update and install latest packages, prerequisites, java JRE and Tomcat
RUN yum -y update && yum clean all && yum -y install wget && yum -y install unzip \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/jre-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz" \
    && tar xf jre-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    && rm jre-${JAVA_VERSION_MAYOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    && alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
    && mkdir -p "$CATALINA_HOME" \
    && cd /usr/local && \
    echo "Installing Tomcat ${TOMCAT_VERSION}..." && \
    wget -nv http://apache.mirrors.pair.com/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    -O apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    echo "Checking file integrity..." && \
    tar xf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm  apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv -f apache-tomcat-${TOMCAT_VERSION}/* ${CATALINA_HOME}

#  Start Services
CMD ["catalina.sh"]