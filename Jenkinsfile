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
                def dbContainerName = "db-${JOB_BASE_NAME}-${BUILD_NUMBER}".replaceAll("\\/|%2[fF]", "-")
                def dbRunArgs = networtArg
                dbRunArgs += " -e POSTGRES_USER=testuser"
                dbRunArgs += " -e POSTGRES_PASSWORD=testpwd"
                dbRunArgs += " -e POSTGRES_DB=redmine"
                dbRunArgs += " --name ${dbContainerName}"
                try {
                    docker.image('postgres:12.5-alpine').withRun(dbRunArgs) {
                        def buildImage = docker.build("build/redmine", "-f dev/Dockerfile --build-arg DB_HOST=${dbContainerName} .")
                        buildImage.inside(networtArg + " -v ${WORKSPACE}:/usr/src/redmine/test/reports") {
                            sh "cd /usr/src/redmine && rake db:migrate"
                            sh "cd /usr/src/redmine && rake test:plugins:redmine_extended_rest_api;"
                        }
                    }
                } finally {
                    junit allowEmptyResults: true, testResults: 'TEST-*.xml'
                }
            }
        }
    }
}