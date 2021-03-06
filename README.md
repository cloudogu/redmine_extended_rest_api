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
docker run -u "$(id -u):$(id -g)" -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro --rm --network dev_default -v $(pwd):/usr/src/redmine/test/reports rmtest bash -c "rake test:plugins:redmine_extended_rest_api"
```

- Build the bundle
```
cd bundle && ruby bundle_plugin.rb
```
