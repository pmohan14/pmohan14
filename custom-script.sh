#!/bin/sh
#${azure_buildprops_MAVEN_EXEC} -s ${azure_buildprops_MAVEN_SETTINGS} -Dsettings.security=${azure_buildprops_MAVEN_SECURITY_SETTINGS} $@ 2>&1 | tee ${azure_buildprops_CICD_DIR}/mvn.log
#rc=$?; echo "exit code $rc"; if [[ $rc != 0 ]]; then ( echo 'could not perform build'; exit $rc; ) fi
#if [ -d ${azure_build_working_directory}/target/checkout ]; then
#   cd ${azure_build_working_directory}/target/checkout
#else
#   cd ${azure_build_working_directory}
#fi
#ls -la target/*.jar
#if grep " BUILD FAILURE" ${azure_buildprops_CICD_DIR}/mvn.log
#  then
#  echo 'found errors in build log';
#  exit 1;
#fi
#export artifactJar=$(basename target/*.jar)
export artifactJar=$(/home/vsts/work/1/s/webapp/target/*.war)
export artifactJarSHA1=$(sha1sum target/${artifactJar} | sed -rn 's/(\w+)\W.*/\1/p')
export artifactJarSHA256=$(sha256sum target/${artifactJar} | sed -rn 's/(\w+)\W.*/\1/p')
#export artifactId=$(${azure_buildprops_MAVEN_EXEC} org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.artifactId -q -DforceStdout)
#export groupId=$(${azure_buildprops_MAVEN_EXEC} org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.groupId -q -DforceStdout) ${azure_buildprops_MAVEN_EXEC} -Dmaven.buildNumber.revisionOnScmFailure=NOREVISION -Dmaven.buildNumber.shortRevisionLength=7 buildnumber:create-metadata
cat target/generated/build-metadata/build.properties | egrep -v "^[#|name|timestamp]" | sed 's/^/artifact\.build\./' >${azure_buildprops_CICD_DIR}/deploy.properties
echo "artifact.file=${artifactJar}" >>${azure_buildprops_CICD_DIR}/deploy.properties
echo "artifact.sha1=${artifactJarSHA1}" >>${azure_buildprops_CICD_DIR}/deploy.properties
echo "artifact.sha256=${artifactJarSHA256}" >>${azure_buildprops_CICD_DIR}/deploy.properties
echo "artifact.groupId=${groupId}" >>${azure_buildprops_CICD_DIR}/deploy.properties
echo "artifact.artifactId=${artifactId}" >>${azure_buildprops_CICD_DIR}/deploy.properties
 while IFS='=' read -r key value
  do
   key=$(echo $key | tr '.' '_')
   eval ${key}=\${value}
  done < "${azure_buildprops_CICD_DIR}/deploy.properties"
ARTIFACT_VERSION=$(grep -oP "Uploaded to artifactory: .*/${artifact_build_version}/${artifactId}-\K(.*).jar" ${azure_buildprops_CICD_DIR}/mvn.log | sed -r 's/(.*).jar/\1/')
echo "artifact.version=${ARTIFACT_VERSION}" >>${azure_buildprops_CICD_DIR}/deploy.properties
