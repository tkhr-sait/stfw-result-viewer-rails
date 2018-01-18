# stfw-result-viewer
#---------------------------------------------------------------------
FROM ruby:2.3.3-alpine

WORKDIR app

RUN apk add --update
RUN apk add graphviz
RUN apk add ttf-freefont
RUN apk add build-base libxml2-dev libxslt-dev
RUN apk add sqlite sqlite-dev
RUN apk add tzdata

COPY . .
RUN gem install bundler
RUN bundle install

ENTRYPOINT rails server

