FROM centos:centos6
MAINTAINER Thibault Duchateau <thibault.duchateau@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk.x86_64
ENV MAVEN_HOME /usr/lib/apache-maven-3.2.5
ENV TOMCAT_HOME /usr/lib/apache-tomcat-7.0.61
ENV PATH $JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Make sure the package repository is up to date
RUN yum -y upgrade && yum clean all

# Install JDK, Maven, Tomcat and utilities
# Also prepare the directory
RUN yum -y install java-1.7.0-openjdk-devel git wget unzip && \
    yum clean all && \
    wget -q -nv http://apache.crihan.fr/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.zip -P /usr/lib && \
    wget -q -nv http://mirrors.ircam.fr/pub/apache/tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61.zip -P /usr/lib && \
    cd /usr/lib && \
    unzip apache-maven-3.2.5-bin.zip && \
    rm -f apache-maven-3.2.5-bin.zip && \
    unzip apache-tomcat-7.0.61.zip && \ 
    rm -f apache-tomcat-7.0.61.zip && \
    chmod +x apache-tomcat-7.0.61/bin/* && \
    mkdir -p /home/petclinic

# Clone the Spring PetClinic master
# Run tests and package the WAR to deploy
# Copy the generated WAR to the Tomcat deployment directory
RUN git clone https://github.com/spring-projects/spring-petclinic.git /home/spring-petclinic && \
    cd /home/spring-petclinic && \
    mvn package && \
    cp target/petclinic.war ${TOMCAT_HOME}/webapps/

# Expose TCP port 8080
EXPOSE 8080

# Start Tomcat server
# The last line (the CMD command) is used to make a fake always-running
# command (the tail command); thus, the Docker container will keep running.
CMD ${TOMCAT_HOME}/bin/startup.sh && tail -f ${TOMCAT_HOME}/logs/catalina.out