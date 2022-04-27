pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages {
         stage('Check out apps repository') { 
            steps { 
                script{
                    checkout scm
                }
            }
        }
        stage('Build image') { 
            steps { 
                script{
                    app = docker.build("kha7281/apps")
                }
            }
        }
        stage('Test'){
            steps {
                echo 'Empty'
            }
        }
        stage('Push image') {
            steps {
                script{
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Check out helm-charts repository, update values and check in') {
            steps {
                git branch: 'master',
                    credentialsId: 'github',
                    url: 'https://github.com/kha7281/helm-charts.git'

                sh "ls -lat sre"
                sh 'wget https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64.tar.gz'
                sh 'tar xvf yq_linux_amd64.tar.gz'
                sh 'mv yq_linux_amd64 /usr/bin/yq'
                dir("sre") {
                    sh '''#!/bin/bash
                    yq  -i eval '.image.repository = "docker.io/kha7281/apps"' values.yaml
                    yq  -i eval '.image.tag = env(BUILD_NUMBER)' values.yaml
                    cat values.yaml
                    pwd
                    git add values.yaml
                    git commit -m "Updated helm charts"
                    '''
                }
                withCredentials([
                    gitUsernamePassword(credentialsId: 'github', gitToolName: 'Default')
                ]) {
                    sh "git push --set-upstream origin master"
                    sh "git push"
                }
            }
        }
    }
}