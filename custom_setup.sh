#!/bin/sh
#set -x
export CICD_DIR=$(readlink -f "./.cicd")
mkdir -p $CICD_DIR
export M2_HOME=${azure_Maven_3}
export PATH=$PATH:${M2_HOME}/bin
mvn --version
uuid=$(uuidgen)
master=$(mvn --encrypt-master-password ${uuid})
cat >${CICD_DIR}/settings-security.xml <<EOL
<settingsSecurity>
  <master>${master}</master>
</settingsSecurity>
EOL
chmod 600 ${CICD_DIR}/settings-security.xml
password=$(mvn -Dsettings.security=${CICD_DIR}/settings-security.xml -ep "password")
cat >${CICD_DIR}/settings.xml <<EOL
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
http://maven.apache.org/xsd/settings-1.0.0.xsd">
<servers>
   <server>
      <id>artifactory</id>
      <username>${account_username}</username>
      <password>${password}</password>
   </server>
</servers>
<mirrors>
   <mirror>
      <id>artifactory</id>
      <name>Artifactory_Staging-releases</name>
      <url>https://artifactory/</url>
      <mirrorOf>central</mirrorOf>
   </mirror>
</mirrors>
</settings>
EOL
chmod 600 ${CICD_DIR}/settings.xml
cat >${CICD_DIR}/build.properties <<EOF
MAVEN_EXEC=${M2_HOME}/bin/mvn
MAVEN_SETTINGS=${CICD_DIR}/settings.xml
MAVEN_SECURITY_SETTINGS=${CICD_DIR}/settings-security.xml
CICD_DIR=${CICD_DIR}
EOF