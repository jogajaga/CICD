pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                git credentialsId: 'github_ssh_key', url: 'git@github.com:jogajaga/CICD.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t fedora-test .'
                }
            }
        }

        stage('Done') {
            steps {
                echo 'Docker image built successfully!'
            }
        }
    }
}

