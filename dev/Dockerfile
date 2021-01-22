FROM ruby:2.6-slim-buster

ENV RAILS_ENV test
ENV HOME /home/redmine
ENV REDMINE_VERSION 4.1.1
ENV REDMINE_DOWNLOAD_MD5 a15a25dec7b866e213bbd4b041f05f17

# explicitly set uid/gid to guarantee that it won't change in the future
# the values 999:999 are identical to the current user/group id assigned
RUN groupadd -r -g 999 redmine && useradd -r -g redmine -u 999 redmine

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates wget bzr git mercurial openssh-client \
		subversion ghostscript gsfonts imagemagick dirmngr gnupg; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/redmine

RUN set -eux; \
	[ ! -d "$HOME" ]; \
	mkdir -p "$HOME"; \
	chown redmine:redmine "$HOME"; \
	chmod 1777 "$HOME"

RUN set -eux; \
	wget -O redmine.tar.gz "https://www.redmine.org/releases/redmine-${REDMINE_VERSION}.tar.gz"; \
	echo "$REDMINE_DOWNLOAD_MD5 *redmine.tar.gz" | md5sum -c -; \
	tar -xf redmine.tar.gz --strip-components=1; \
	rm redmine.tar.gz files/delete.me log/delete.me; \
	mkdir -p log public/plugin_assets sqlite tmp/pdf tmp/pids; \
	chown -R redmine:redmine ./; \
# log to STDOUT (https://github.com/docker-library/redmine/issues/108)
	echo 'config.logger = Logger.new(STDOUT)' > config/additional_environment.rb; \
# fix permissions for running as an arbitrary user
	chmod -R ugo=rwX config db sqlite; \
	find log tmp -type d -exec chmod 1777 '{}' +

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		freetds-dev gcc libmariadbclient-dev libpq-dev libsqlite3-dev make patch; \
	rm -rf /var/lib/apt/lists/*; \
	\
	# add gem for test execution
	echo "gem 'minitest'" >> Gemfile; \
	bundle install --jobs "$(nproc)"; \
	# generate lock files for different adapter types
	for adapter in mysql2 postgresql sqlserver sqlite3; do \
		echo "$RAILS_ENV:" > ./config/database.yml; \
		echo "  adapter: $adapter" >> ./config/database.yml; \
		bundle install --jobs "$(nproc)" --without development test; \
		cp Gemfile.lock "Gemfile.lock.${adapter}"; \
	done; \
	rm ./config/database.yml; \
	\
	echo "production:" >> ./config/database.yml; \
    echo "  adapter: sqlite3" >> ./config/database.yml; \
    echo "  database: db/redmine.sqlite3" >> ./config/database.yml; \
    echo "development:" >> ./config/database.yml; \
    echo "  adapter: sqlite3" >> ./config/database.yml; \
    echo "  database: db/redmine.sqlite3" >> ./config/database.yml; \
    echo "test:" >> ./config/database.yml; \
    echo "  adapter: sqlite3" >> ./config/database.yml; \
    echo "  database: db/redmine.sqlite3" >> ./config/database.yml; \
    rake db:migrate;

COPY . /usr/src/redmine/plugins/redmine_extended_rest_api
# install test gems
RUN  set -eux; \
     bundle install; \
     bundle install --with test;

COPY dev/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
