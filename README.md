# redmine_extended_rest_api

Run tests with

```
docker build -f dev/Dockerfile -t rmtest .; \
docker run rmtest bash -c "rake test:plugins:redmine_extended_rest_api;";
```