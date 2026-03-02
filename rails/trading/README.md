# Ruby on Rails: Trading Platform

## Project Specifications

**Read-Only Files**

- spec/*

**Environment**

- Ruby version: 3.4.7
- Rails version: 7.0.0
- Default Port: 3000

**Commands**

- run:

```bash
bin/bundle exec rails server --binding 0.0.0.0 --port 3000
```

- install:

```bash
bin/bundle install
```

- test:

```bash
RAILS_ENV=test bin/rails db:migrate && RAILS_ENV=test bin/bundle exec rspec
```

## Question description

Each trader data is a JSON entry with the following keys:

```json
{
    "id":"The unique ID assigned at the time of registration.",
    "name": "The name of the trader.",
    "email": "The email of the trader.",
    "balance": "The account balance of the trader.",
    "created_at": "The timestamp when the registration was completed",
    "updated_at": "The timestamp when the trader account got updated"
}
```

Example of trader JSON object:

```json
{
    "id": 1,
    "name": "Elizabeth Small",
    "email": "elizabeth.small@buck.com",
    "balance": 62.0,
    "created_at": "2020-10-17T06:59:18.034Z",
    "updated_at": "2020-10-17T06:59:18.034Z"
}
```

## Requirements

The `REST` service must expose the `/trading/traders` endpoint, which allows for managing the data records in the following way:

`POST /trading/traders/register`:
- registers a new trader record.
- expects a JSON trader object with missing `id`, `created_at`, `updated_at`. You can assume that the given object is always valid.
- if a trader with the same email already exists, response code is 400 otherwise response code is 201.

`GET /trading/traders/all`:
- returns all the records with status code 200.
- records should be sorted by ID in the ascending order.

`GET /trading/traders?email={email}`:
- returns a record with the given email and status code 200.
- if there is no record in the database with the given email, the response code is 404.

`PUT /trading/traders`:
- updates the trader's name by email. the trader JSON sent in request body will have the keys `email, name`.
- if the trader with the requested email does not exist, the response code is 404 otherwise the response code is 200.

`PUT /trading/traders/add`:
add money to the trader's account by t
- adds money to the trader's account by email. the trader JSON sent in request body will have the keys `email, amount`.
- if the trader with the requested email does not exist, the response code is 404 otherwise the response code is 200.

You are provided with most of the implementation, but the expected behavior is not achieved as there are some bugs in the given project. You should find and fix the bugs in order to get the expected behavior which is validated by executing a set of `rspec` tests.
