# Swagger for Rails 5

This is a project to provide Swagger support inside the [Ruby on Rails](http://rubyonrails.org/) framework.

## Prerequisites
You need to install ruby >= 2.2.2 and run:

```
bundle install
```

## Getting started

This sample was generated with the [swagger-codegen](https://github.com/swagger-api/swagger-codegen) project.

```
bin/rake db:create db:migrate
bin/rails s
```

To list all your routes, use:

```
bin/rake routes
```

Docker
```
# docker準備
sudo docker-compose build
# 起動（停止はdown）
sudo docker-compose up -d

# stfwのwebhook連携(post先)
export URL_WEBHOOK=http://localhost:3000/hooks/stfw

# ブラウザ(getメソッド)
## 一覧
http://localhost:3000/hooks
## グラフ表示
http://localhost:3000/hooks/stfw
## swagger json表示
http://localhost:3000/apidocs
```
