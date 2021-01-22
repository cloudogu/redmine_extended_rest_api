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
            stage('Build') {
                dir("dev"){
                    def dbContainerName = "db-${JOB_BASE_NAME}-${BUILD_NUMBER}".replaceAll("\\/|%2[fF]", "-")
                    def dbRunArgs = networtArg
                    dbRunArgs += " -e MYSQL_ROOT_PASSWORD=example"
                    dbRunArgs += " -e MYSQL_DATABASE=redmine"
                    dbRunArgs += " --name ${dbContainerName}"
                    docker.image('mysql:5.7').withRun(dbRunArgs) {
                        def buildImage = new Docker(this).build("build/redmine", "dev")
                        def redmineContainerName = "redmine-${JOB_BASE_NAME}-${BUILD_NUMBER}".replaceAll("\\/|%2[fF]", "-")
                        def redmineRunArgs = networtArg
                        redmineRunArgs += " -e REDMINE_DB_MYSQL=db"
                        redmineRunArgs += " -e REDMINE_DB_PASSWORD=example"
                        redmineRunArgs += " -e REDMINE_SECRET_KEY_BASE=supersecretkey"
                        redmineRunArgs += " -e RAILS_ENV=test"
                        redmineRunArgs += " --name ${redmineContainerName}"
                        redmineRunArgs += " -v ../:/usr/src/redmine/plugins/redmine_extended_rest_api"
                        buildImage.inside(redmineRunArgs) {
                            sh "bundle install"
                            sh "rake test:plugins:redmine_extended_rest_api"
                        }
                    }
                }
            }
        }
    }
}