#FROM jfrog-docker-registry.bintray.io/jfrog/artifactory-oss:4.1.3
# Step 1/1 : FROM jfrog-docker-registry.bintray.io/jfrog/artifactory-oss:4.1.3
#unauthorized: Repository '/jfrog/registry' does not support Docker API version v2
#FROM widerin/openshift-artifactory-oss

FROM tomcat:9.0

# To update, check https://bintray.com/jfrog/artifactory/jfrog-artifactory-oss-zip/view
ARG ARTIFACTORY_VERSION=5.5.2
ARG ARTIFACTORY_URL=https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.zip
ARG ARTIFACTORY_SHA256=7d23268d3af6ed820d5d690d4c9640d726a65631110955ac9046bb0533d1dda3

# Disable Tomcat's manager application.
RUN rm -rf $CATALINA_HOME/webapps/*

WORKDIR /tmp
ADD ${ARTIFACTORY_URL} artifactory.zip

#RUN echo "${ARTIFACTORY_SHA256}  artifactory.zip" | sha256sum -c - && \
RUN  unzip -j artifactory.zip "artifactory-oss-${ARTIFACTORY_VERSION}/webapps/artifactory.war" -d ${CATALINA_HOME}/webapps && \
  mv ${CATALINA_HOME}/webapps/artifactory.war ${CATALINA_HOME}/webapps/ROOT.war && \
  rm artifactory.zip

ENV ARTIFACTORY_HOME /artifactory
RUN mkdir ${ARTIFACTORY_HOME}
VOLUME ${ARTIFACTORY_HOME}

WORKDIR $CATALINA_HOME