# Developing the Redmine Extended REST API plugin

## Running the tests

```bash
# Start PostgreSQL
cd dev
docker-compose up -d # postgresql should end up in the dev_default network

# Build the test docker image with Redmine and the actual plugin
docker build -f dev/Dockerfile --build-arg DB_HOST=postgresql -t rmtest .

# Initialize the database
docker run --rm --network dev_default rmtest bash -c "rake db:migrate"

# Run the tests
docker run -u "$(id -u):$(id -g)" --rm \
  -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro --network dev_default \
  -v $(pwd):/usr/src/redmine/test/reports rmtest \
    bash -c "rake test:plugins:redmine_extended_rest_api"
```

## How to get to the redmine test fixtures

Here be dragons