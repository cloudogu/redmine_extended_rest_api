# redmine_extended_rest_api

- Build the test docker image
```
docker build -f dev/Dockerfile --build-arg DB_HOST=postgresql -t rmtest .
```

- On first run, the database has to be initialized.
```
docker run --rm --network dev_default rmtest bash -c "rake db:migrate"
```

- Run the tests
```
docker run --rm --network dev_default -v <path-to-sources>/redmine_extended_rest_api/reports:/usr/src/redmine/test/reports rmtest bash -c "rake test:plugins:redmine_extended_rest_api"
```