FROM jenkins/jenkins:latest
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
ENV JENKINS_ADMIN_ID admin 
ENV JENKINS_ADMIN_PASSWORD password
COPY casc.yaml /var/jenkins_home/casc.yaml
