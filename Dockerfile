# stfw-result-viewer
#---------------------------------------------------------------------
FROM ruby:2.3.3-alpine

RUN apk add --update
RUN apk add graphviz
RUN apk add ttf-freefont
RUN apk add build-base libxml2-dev libxslt-dev
RUN apk add sqlite sqlite-dev
RUN apk add tzdata
RUN apk add git

#COPY . .
RUN git clone http://github.com/tkhr-sait/stfw-result-viewer-rails
WORKDIR stfw-result-viewer-rails
RUN gem install bundler
RUN bundle install
RUN rake db:create db:migrate

ENTRYPOINT rails server

