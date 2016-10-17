# oxford-explorer

The culmination of our previous R&amp;D into the Oxford work. Now we have a Thing.

## Requirements

`oxford-explorer` is a Rails 5 application, written against Ruby 2.3.1. It _may_ work with earlier Rubies; Rails 5 requires Ruby 2.2.2 as a minimum. However, it's not been tested with earlier rubies.

Dependencies are all in its `Gemfile`, as you'd expect.

As a 12-Factor application, it's ready to deploy to Heroku, although you'll need to configure a number of environment variable in `.env` to run it locally, notably:

	DATABASE_URL
	ELASTICSEARCH_URL
	AWS_ACCESS_KEY_ID
	AWS_SECRET_ACCESS_KEY
	COLLECTIONS_CSV_URL

It uses Postgres and Elasticsearch as storage backends. Because it's read-only, we're just working against the development databases.

So: set up your `.env` file, and then run the server either with [`dotenv`][dotenv] or [`foreman`][foreman].

[dotenv]:https://github.com/bkeepers/dotenv
[foreman]:https://github.com/ddollar/foreman