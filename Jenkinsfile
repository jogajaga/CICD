pipeline {
    agent any

    environment {
        POSTGRES_IMAGE = "postgres:15"
        POSTGRES_CONTAINER = "ci-pgsql"
        POSTGRES_VOLUME = "pgsql_data_ci_fresh"   // Новый том, чтобы избежать конфликта с предыдущими ролями
        POSTGRES_USER = "postgres"
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
                        docker exec -u ${POSTGRES_USER} ${POSTGRES_CONTAINER} psql -d ${POSTGRES_DB} -c \\
                        "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'jenkins_ci') THEN CREATE USER jenkins_ci WITH PASSWORD 'jenkins_pass'; END IF; END \$\$;"
                        docker exec -u ${POSTGRES_USER} ${POSTGRES_CONTAINER} psql -d ${POSTGRES_DB} -c \\
                        "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO jenkins_ci;"
                    """
                }
            }
        }

        stage('Verify Connection') {
            steps {
                script {
                    sh """
                        docker exec -u ${POSTGRES_USER} ${POSTGRES_CONTAINER} psql -d ${POSTGRES_DB} -c "\\du"
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

