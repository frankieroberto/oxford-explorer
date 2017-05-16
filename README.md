# Oxford-explorer

The culmination of our previous R&amp;D into the Oxford work. Now we have a Thing. It can be viewed online at http://gfs-oxford-explorer.herokuapp.com

## Overview

`oxford-explorer` is a web application written in the programming language Ruby, using the Rails framework.

It uses three data stores:

* a PostgreSQL database, for a few pieces of anciliary information. We use an Amazon RDS instance rather than a local install.
* CSV files (`collections.csv`, `institutions.csv`, `types_of_things.csv`) stored in `db`. These are derived from a GoogleDocs spreadsheet, and can be updated using Rake tasks
* an Elasticsearch database. We're using an instance on AWS Elasticache. It is populated via a series of custom scripts (stored in other repositories, with their own documentation).

It is designed as a 12-factor application, suitable for deployment to a PAAS provider such as Heroku, or running locally with Foreman. It would also be possible to deploy it to a standalone Linux server - probably running Phusion Passenger behind either nginx or Apache - but that's outside the scope of this README; it's not our preferred deployment process.

## Requirements

Running a copy of the website requires having Ruby installed (version 2.3.1).

Dependencies are all in its `Gemfile`, as you'd expect for a Ruby application. You can install them by running `bundle install` once you’ve installed the `bundler` gem (which you can install using `gem install bundler`).

The locations of the Elasticsearch/Postgres services (and their passwords) are specified via environment variables (`DATABASE_URL` and `ELASTICSEARCH_URL`). In development, these should be stored in `.env`; in production, these should be configured as available to the server (for instance, through Heroku's configuration tools).

Because the website is read-only, we work against the remote development databases - we don't have local development data stores other than the CSV files.

To start the website locally, you just need to run `bundle exec rails server` from the application directory. Environment variables can be specified before this command, but to save typing, it's best to store then in a file named simply `.env`. You can start the server using either [`dotenv`][dotenv] or [`foreman`][foreman].

## Caching data from the Spreadsheet

Some of the summary level data about institutions and collections are cached from a Google Spreadsheet. These cached copies can be updated using these commands:

`bundle exec rake update:collections`  
`bundle exec rake update:institutions`  
`bundle exec rake update:types_of_thing`  

These tasks assume that the URL to the CSV of the relevant Google Spreadsheet is available as an environment variable.

In addition, there's a CSV file called `collections_computed.csv` which summarises the collection counts from the elasticsearch database. This needs to be updated manually by copying and pasting the CSV into place from the `oxford-collections` repository.

Once updated, the changed files should be committed into source control and deployed in the normal way.

[dotenv]:https://github.com/bkeepers/dotenv
[foreman]:https://github.com/ddollar/foreman
