TEST_CONTAINER=rmtest
DOCKER_COMPOSE_NETWORK=dev_default
DEV_DIR=dev

.PHONY: test-plugin
test-plugin:
# start postgresql: the container should end up in the dev_default network
	@cd dev && docker-compose up -d && cd ..
# Build test container
	@docker build -f ${DEV_DIR}/Dockerfile --build-arg DB_HOST=postgresql -t ${TEST_CONTAINER} .
# Initialize the database
	@docker run --rm --network ${DOCKER_COMPOSE_NETWORK} ${TEST_CONTAINER} \
		bash -c "rake db:migrate"
# Run the tests
	@docker run -u "$$(id -u):$$(id -g)" --rm \
       -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro \
       --network ${DOCKER_COMPOSE_NETWORK} \
       -v $$(pwd):/usr/src/redmine/test/reports ${TEST_CONTAINER} \
         bash -c "rake test:plugins:redmine_extended_rest_api"
# stop postgresql
	@cd dev && docker-compose rm -s -f && cd ..