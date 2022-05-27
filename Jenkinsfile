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
        //  https://stackoverflow.com/questions/56006353/using-jenkins-environment-variable-in-pipeline-sh-script
        stage('Check out helm-charts repository, update values and check in') {
            steps {
                git branch: 'master',
                    credentialsId: 'github',
                    url: 'https://github.com/kha7281/apps.git'

                sh "ls -lat argocd/charts"
                sh 'wget https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64.tar.gz'
                sh 'tar xvf yq_linux_amd64.tar.gz'
                sh 'mv yq_linux_amd64 /usr/bin/yq'

                sh 'wget https://github.com/helm/chart-releaser/releases/download/v1.4.0/chart-releaser_1.4.0_linux_amd64.tar.gz'
                sh 'tar xvf chart-releaser_1.4.0_linux_amd64.tar.gz'
                sh 'mv cr /usr/bin/cr'

                sh 'wget https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz'
                sh 'tar xvf helm-v3.8.2-linux-amd64.tar.gz'
                sh 'mv linux-amd64/helm /usr/bin/helm'

                dir("fleet/charts/apps") {
                    sh """#!/bin/bash
                    export nextVersion="0.1."${env.BUILD_NUMBER}
                    yq  -i eval '.version = env(nextVersion)' Chart.yaml
                    yq  -i eval '.appVersion = env(BUILD_NUMBER)' Chart.yaml
                    cat Chart.yaml
                    pwd
                    git add Chart.yaml
                    git commit -m "Updated helm charts version and app version"
                    """
                }
                dir("fleet/charts") {
                    sh """#!/bin/bash
                    rm -rf .deploy
                    helm package apps --destination .deploy

                    """
                }
                withCredentials([[
                    $class: 'UsernamePasswordMultiBinding', credentialsId: 'github', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD'
                ]]) {
                    sh """
                    echo uname=$USERNAME
                    cr upload --owner $USERNAME --git-repo helm-charts --package-path ./fleet/charts/.deploy --token $PASSWORD
                    """
                }

                withCredentials([
                    gitUsernamePassword(credentialsId: 'github', gitToolName: 'Default')
                ]) {
                    sh "git push --set-upstream origin master"
                    sh "git push"
                }

                dir("publish-index") {
                    git branch: 'gh-pages',
                        credentialsId: 'github',
                        url: 'https://github.com/kha7281/helm-charts.git'

                    sh """
                    cr index -i ./index.yaml -p ../fleet/charts/.deploy --owner kha7281 --git-repo helm-charts
                    git add index.yaml
                    git commit -m "Updated index.yaml"
                    cat index.yaml
                    """
                    withCredentials([
                        gitUsernamePassword(credentialsId: 'github', gitToolName: 'Default')
                    ]) {
                        sh "git push --set-upstream origin gh-pages"
                        sh "git push"
                    }
                }
            }
        }
        // Deploy to argocd
        stage('Deploy') {
            steps {
                dir("Deploy") {
                    git branch: 'master',
                        credentialsId: 'github',
                        url: 'https://github.com/kha7281/apps.git'

                    dir("fleet/apps-fleet") {
                        sh """#!/bin/bash
                        export nextVersion="0.1."${env.BUILD_NUMBER}
                        yq  -i eval '.helm.version = env(nextVersion)' fleet.yaml
                        cat fleet.yaml
                        pwd
                        git add fleet.yaml
                        git commit -m "Updated helm charts version and app version"
                        """
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
    }
}