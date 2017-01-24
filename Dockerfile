FROM ruby:2.3.3
MAINTAINER andre@yogadose.xyz
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /yogadose
WORKDIR /yogadose
ADD Gemfile /yogadose/Gemfile
ADD Gemfile.lock /yogadose/Gemfile.lock
RUN bundle install
ADD . /yogadose