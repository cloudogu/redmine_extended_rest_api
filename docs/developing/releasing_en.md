# Releasing the redmine extended REST API plugin

1. merge the pull request
2. update main and develop branch
3. check the current version
4. decide the new version with help of the changelog
5. `git flow release start ${NEWVERSION}`
   1. update `CHANGELOG.md`
   2. update `src/init.rb`
   3. update `src/assets/openapi.yml`
   4. Commit with message "bump version" etc
6. `git flow release finish -s ${NEWVERSION}`
7. push git changes
   - `git push origin master`
   - `git push origin develop --tags`
8. Create new Github release from [tags](https://github.com/cloudogu/redmine_extended_rest_api/tags)
9. update the respective plugin version and checksum in the [Redmine dogu](https://github.com/cloudogu/redmine/blob/develop/Dockerfile)