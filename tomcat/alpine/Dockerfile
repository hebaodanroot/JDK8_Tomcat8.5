FROM rootww/java:8u181-alpine-3.9

LABEL name="alpine3.9 JDK8 Tomcat8.5"

ENV CATALINA_HOME=/opt/tomcat

RUN mkdir -p /opt/tomcat \
    && tomcat_down_url='http://mirrors.ustc.edu.cn/apache/tomcat/tomcat-8' \
    && tomcat_ver='8.5.41' \
    && echo Downloading apache-tomcat-${tomcat_ver}.tar.gz... \
    && wget -q -O /tmp/tomcat.tar.gz ${tomcat_down_url}/v${tomcat_ver}/bin/apache-tomcat-${tomcat_ver}.tar.gz \
    && tar zxf /tmp/tomcat.tar.gz --strip-components 1 -C /opt/tomcat \
    && rm -rf /tmp/tomcat.tar.gz


#Tomcat
RUN echo Configuring tomcat... \
    && echo '               maxThreads="600"'>/tmp/tmp.server.xml \
    && echo '               minSpareThreads="100"'>>/tmp/tmp.server.xml \
    && echo '               acceptorThreadCount="4"'>>/tmp/tmp.server.xml \
    && echo '               acceptCount="500"'>>/tmp/tmp.server.xml \
    && echo '               enableLookups="false"'>>/tmp/tmp.server.xml \
    && echo '               URIEncoding="UTF-8" />'>>/tmp/tmp.server.xml \
    && sed -i '/<Connector port="8080" protocol="HTTP\/1.1"/,/redirectPort="8443" \/>/s/redirectPort="8443" \/>/redirectPort="8443"/' /opt/tomcat/conf/server.xml \
    && sed -i '/^               redirectPort="8443"$/r /tmp/tmp.server.xml' /opt/tomcat/conf/server.xml \
    && sed -i 's/<Server port="8005"/<Server port="-1"/' /opt/tomcat/conf/server.xml \
    && sed -i 's#<Connector port="8009".*#<!-- <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" /> -->#' /opt/tomcat/conf/server.xml \
    && rm -rf /tmp/tmp.server.xml

WORKDIR $CATALINA_HOME

EXPOSE 8080

CMD ["bin/catalina.sh","run"]
