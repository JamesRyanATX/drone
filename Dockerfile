FROM ruby:2.1.5
RUN apt-get -y update && apt-get -y dist-upgrade
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install --no-install-recommends -y -q \
  build-essential \
  cron \
  git-core \
  imagemagick \
  libcurl4-gnutls-dev \
  libfontconfig1 \
  libfontconfig1-dev \
  libfreetype6 \
  libfreetype6-dev \
  libjpeg-dev \
  libpq-dev \
  libqt4-core \
  libqt4-dev \
  libqt4-gui \
  libsqlite3-dev \
  postgresql-client \
  qt4-dev-tools \
  tar \
  unzip \
  wget \
  xauth \
  xvfb \
  nodejs \
  telnet
RUN apt-get autoremove -y
RUN apt-get clean all
WORKDIR /drone
ADD Gemfile /drone/Gemfile
ADD Gemfile.lock /drone/Gemfile.lock
RUN mkdir ~/.ssh
RUN chmod 700 ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan -t rsa rubygems.org >> ~/.ssh/known_hosts
RUN bundle install
RUN npm install phantomjs-prebuilt
ADD . /drone
