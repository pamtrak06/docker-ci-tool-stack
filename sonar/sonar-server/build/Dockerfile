FROM sonarqube:6.6
USER root
RUN chmod -R 755 /opt/sonarqube
ENV SONARQUBE_HOME=/opt/sonarqube
ADD *.jar $SONARQUBE_HOME/extensions/plugins/
ADD sonar.properties $SONARQUBE_HOME/conf/
WORKDIR $SONARQUBE_HOME