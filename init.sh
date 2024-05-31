#!/bin/bash
mkdir -p ./gitlab/{config,logs,data}
mkdir -p ./vault/{config,data}
mkdir -p ./jenkins/jenkins_home

cat > compose.yml << 'EOF'
services:
  jenkins:
    image: jenkins:jcasc
    restart: always
    hostname: jenkins
    container_name: jenkins
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - ./jenkins/jenkins_home:/var/jenkins_home
      - ./jenkins/jenkins_plugins:/var/jenkins_home/plugins
  git:
    image: 'gitlab/gitlab-ce:latest'
    restart: on-failure
    hostname: 'gitlab'
    container_name: gitlab-ce
    environment:
      GITLAB_ROOT_PASSWORD: 'S3cr3t0!S3cr3t0!'
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://192.168.148.213'
    ports:
      - '8081:80'
      - '8443:443'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'
  #gitlab-runner:
  #  image: gitlab/gitlab-runner:alpine
  #  container_name: gitlab-runner    
  #  restart: always
  #  depends_on:
  #    - web
  #  volumes:
  #    - '/var/run/docker.sock:/var/run/docker.sock'
  #    - './gitlab/gitlab-runner:/etc/gitlab-runner'
  vault:
    image: hashicorp/vault:latest
    container_name: vault
    hostname: vault
    restart: on-failure:10
    healthcheck:
      retries: 5
    ports:
      - "8200:8200"
    environment:
      VAULT_ADDR: 'http://0.0.0.0:8200'
      VAULT_LOCAL_CONFIG: '{"listener": [{"tcp":{"address": "0.0.0.0:8200","tls_disable":"1"}}], "ui": true, "storage": [{"file": {"path":"/vault/data"}}]}'
    cap_add:
      - IPC_LOCK
    volumes:
      - ./vault/config:/vault/config
      - ./vault/data:/vault/data
    command: vault server -config vault/config/local.json
EOF

docker compose up -d 



docker exec -it gitlab-ce grep 'Password:' /etc/gitlab/initial_root_password
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
