pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages {
         stage('Clone repository') { 
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
        stage('Checkout external proj') {
            steps {
                git branch: 'master',
                    credentialsId: 'github',
                    url: 'https://github.com/kha7281/helm-charts.git'
            }
        }
    }
}