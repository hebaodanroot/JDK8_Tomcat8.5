FROM rootww/java:8u181

LABEL name="centos7 JDK8 Zookeeper3.4"

ENV PATH=/opt/zookeeper/bin:$PATH

RUN yum install -y nc \
	&& mkdir -p /opt/zookeeper/data /opt/zookeeper/logs \
    && zookeeper_down_url='https://mirrors.huaweicloud.com/apache/zookeeper' \
    && zookeeper_ver=3.4.14 \
    && echo Downloading zookeeper-${zookeeper_ver}.tar.gz... \
    && curl -Ls -o /tmp/zookeeper.tar.gz ${zookeeper_down_url}/zookeeper-${zookeeper_ver}/zookeeper-${zookeeper_ver}.tar.gz \
    && tar zxf /tmp/zookeeper.tar.gz --strip-components 1 -C /opt/zookeeper \
    && mv /opt/zookeeper/zookeeper-${zookeeper_ver}.jar /opt/zookeeper/lib \
    && rm -rf /tmp/zookeeper.tar.gz \
              /opt/zookeeper/build.xml \
              /opt/zookeeper/contrib \
              /opt/zookeeper/dist-maven \
              /opt/zookeeper/docs \
              /opt/zookeeper/ivy.xml \
              /opt/zookeeper/ivysettings.xml \
              /opt/zookeeper/pom.xml \
              /opt/zookeeper/src \
              /opt/zookeeper/zookeeper-* \
              /opt/zookeeper/recipe
              
ADD docker-entrypoint.sh /opt/zookeeper/bin/docker-entrypoint.sh
ADD zookeeper-ready /opt/zookeeper/bin/zookeeper-ready

RUN chmod +x /opt/zookeeper/bin/docker-entrypoint.sh \
    && chmod +x /opt/zookeeper/bin/zookeeper-ready

WORKDIR /opt/zookeeper

EXPOSE 2181 2888 3888

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["zkServer.sh","start-foreground"]
