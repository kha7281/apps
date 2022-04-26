node {

    environment {
        IMAGE_REPO = "kha7281/apps"
    }

    def app
    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
       app = docker.build("kha7281/apps")
    }

    stage('Push image') {
        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    stage('Update Helm chart value & push back to git repo') {
        environment {
            GIT_CREDS = credentials('github')
            HELM_GIT_REPO_URL = 'github.com/kha7281/helm-charts.git'
            GIT_REPO_BRANCH = 'master'
        }
        steps {
            sh 'wget https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64.tar.gz'
            sh 'tar xvf yq_linux_amd64.tar.gz'
            sh 'mv yq_linux_amd64 /usr/bin/yq'
            dir("helm-charts") {
                sh "git checkout ${env.GIT_REPO_BRANCH}"
                sh '''#!/bin/bash
                    ls -lth
                    yq eval '.image.repository = kha7281/apps' -i values.yaml
                    yq eval '.image.tag = env(BUILD_NUMBER)' -i values.yaml
                    cat values.yaml
                    pwd
                    git add values.yaml
                    git commit -m 'Updated helm charts'
                    git push https://$GIT_CREDS_USR:$GIT_CREDS_PSW@env(HELM_GIT_REPO_URL)
                '''
            }
        }
    }
}