@Library(['github.com/cloudogu/ces-build-lib@1.44.3', 'github.com/cloudogu/zalenium-build-lib@v2.0.0'])
import com.cloudogu.ces.cesbuildlib.*
import com.cloudogu.ces.zaleniumbuildlib.*

node {
    timestamps {
        stage('Checkout') {
            checkout scm
        }

        withDockerNetwork { buildNetwork ->
            def networtArg = "--network ${buildNetwork}"
            sh 'echo "Start build..."'
            stage('Build & Test') {
                sh "rm -rf reports/"
                def dbContainerName = "db-${JOB_BASE_NAME}-${BUILD_NUMBER}".replaceAll("\\/|%2[fF]", "-")
                def dbRunArgs = networtArg
                dbRunArgs += " -e POSTGRES_USER=testuser"
                dbRunArgs += " -e POSTGRES_PASSWORD=testpwd"
                dbRunArgs += " -e POSTGRES_DB=redmine"
                dbRunArgs += " --name ${dbContainerName}"
                docker.image('postgres:12.5-alpine').withRun(dbRunArgs) {
                    def buildImage = docker.build("build/redmine", "-f dev/Dockerfile --build-arg DB_HOST=${dbContainerName} .")
                    buildImage.inside(networtArg) {
                        sh "rake db:migrate"
                        sh "rake test:plugins:redmine_extended_rest_api;"
                    }
                }
                junit allowEmptyResults: true, testResults: 'reports/TEST-*.xml'
            }
        }
    }
}