# oxford-explorer

The culmination of our previous R&amp;D into the Oxford work. Now we have a Thing. It can be viewed online at http://gfs-oxford-explorer.herokuapp.com

## Requirements

`oxford-explorer` is a web application written in the programming language Ruby, using the Rails framework.

Running a copy of the website requires having Ruby installed (version 2.3.1).

Dependencies are all in its `Gemfile`, as you'd expect. You can install them by running `bundle install` once you’ve installed the `bundler` gem (which you can install using `gem install bundler`).

The website uses Postgres (a database) and Elasticsearch (a search engine) as storage backends. The locations of these services (and their passwords) are specified via environment variables (`DATABASE_URL` and `ELASTICSEARCH_URL`).

Because the website read-only, we're just working against the remote development databases.

The website is currently deployed using the 'Platform as a Service' provider Heroku. It should be just as easy to install elsewhere.


To start the website locally, you just need to run `bundle exec rails server`. Environment variables can be specified before this command, but to save typing, it's best to store then in a file named simply `.env`, and then you can start the server using either [`dotenv`][dotenv] or [`foreman`][foreman].

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