# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


In Procfile

web: bin/rails server for local testing
web: bundle exec puma -C config/puma.rb for deployment

Also have to edit config/database.yml to switch between local host (testing) and deployment (render)
