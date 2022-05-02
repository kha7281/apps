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
                    url: 'https://github.com/kha7281/apps.git'

                sh "ls -lat argocd/charts"
                sh 'wget https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64.tar.gz'
                sh 'tar xvf yq_linux_amd64.tar.gz'
                sh 'mv yq_linux_amd64 /usr/bin/yq'
                dir("argocd/charts/apps") {
                    sh '''#!/bin/bash
                    prefix="0.1."
                    eval 'build=env(BUILD_NUMBER)'
                    export build
                    export nextVersion="${prefix}${env.BUILD_NUMBER}"
                    yq  -i eval '.version = env(nextVersion)' Chart.yaml
                    yq  -i eval '.appVersion = env(BUILD_NUMBER)' Chart.yaml
                    cat Chart.yaml
                    pwd
                    git add Chart.yaml
                    git commit -m "Updated helm charts version and app version"
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