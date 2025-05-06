pipeline {
    agent any

    environment {
        POSTGRES_IMAGE = "postgres:15"
        POSTGRES_CONTAINER = "ci-pgsql"
        POSTGRES_VOLUME = "pgsql_data_ci"
        POSTGRES_USER = "ci_user"
        POSTGRES_PASSWORD = "ci_pass"
        POSTGRES_DB = "ci_database"
    }

    stages {
    	stage('Clone') {
            steps {
                git credentialsId: 'github_ssh_key', url: 'git@github.com:jogajaga/CICD.git'
            }
        }
        stage('Prepare Volume') {
            steps {
                script {
                    sh "docker volume create ${POSTGRES_VOLUME}"
                }
            }
        }

        stage('Run PostgreSQL Container') {
            steps {
                script {
                    sh """
                        docker run -d \
                          --name ${POSTGRES_CONTAINER} \
                          -e POSTGRES_USER=${POSTGRES_USER} \
                          -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
                          -e POSTGRES_DB=${POSTGRES_DB} \
                          -v ${POSTGRES_VOLUME}:/var/lib/postgresql/data \
                          -p 5432:5432 \
                          ${POSTGRES_IMAGE}
                    """
                }
            }
        }

        stage('Wait for PostgreSQL') {
            steps {
                script {
                    // Ждём, пока Postgres запустится
                    sh """
                        for i in {1..10}; do
                          docker exec ${POSTGRES_CONTAINER} pg_isready && break
                          echo "Waiting for PostgreSQL..."
                          sleep 2
                        done
                    """
                }
            }
        }

        stage('Create Additional User or Schema (optional)') {
            steps {
                script {
                    sh """
                        docker exec -u postgres ${POSTGRES_CONTAINER} psql -d ${POSTGRES_DB} -c \\
                        "CREATE USER jenkins_ci WITH PASSWORD 'jenkins_pass'; GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO jenkins_ci;"
                    """
                }
            }
        }

        stage('Verify Connection') {
            steps {
                script {
                    sh """
                        docker exec -u postgres ${POSTGRES_CONTAINER} psql -d ${POSTGRES_DB} -c "\\du"
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Stopping and removing container'
            sh "docker stop ${POSTGRES_CONTAINER} || true"
            sh "docker rm ${POSTGRES_CONTAINER} || true"
        }
    }
}

