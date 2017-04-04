FROM jboss/wildfly:8.2.0.Final

ENV APIMAN_VERSION 1.1.9.Final

# Download APIMAN overlay for wildfly
RUN cd $JBOSS_HOME \
 && curl http://downloads.jboss.org/overlord/apiman/$APIMAN_VERSION/apiman-distro-wildfly8-$APIMAN_VERSION-overlay.zip -o apiman-distro-wildfly8-$APIMAN_VERSION-overlay.zip \
 && bsdtar -xf apiman-distro-wildfly8-$APIMAN_VERSION-overlay.zip \
 && rm apiman-distro-wildfly8-$APIMAN_VERSION-overlay.zip


# Add default user
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin123! --silent


# Apiman properties
ADD apiman.properties /opt/jboss/wildfly/standalone/configuration/


# SSL
ADD apiman_gateway.jks /opt/jboss/wildfly/standalone/configuration/


# Postgres
ENV DB_CONNECTOR_VERSION 9.4-1201-jdbc41
RUN rm /opt/jboss/wildfly/standalone/deployments/apiman-ds.xml
RUN mkdir -p /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/jdbc/main; cd /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/jdbc/main; curl -O http://central.maven.org/maven2/org/postgresql/postgresql/$DB_CONNECTOR_VERSION/postgresql-$DB_CONNECTOR_VERSION.jar
ADD module.xml /opt/jboss/wildfly/modules/system/layers/base/org/postgresql/jdbc/main/


# Add standalone-apiman.xml
ADD standalone-apiman.xml /opt/jboss/wildfly/standalone/configuration/


# Disable builtin Elasticsearch
RUN rm -f /opt/jboss/wildfly/standalone/deployments/apiman-es*


# Default wildfly debug port  
EXPOSE 8787

USER root
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-c", "standalone-apiman.xml", "--debug"]
