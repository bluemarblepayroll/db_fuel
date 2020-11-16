# DB Fuel

[![Gem Version](https://badge.fury.io/rb/db_fuel.svg)](https://badge.fury.io/rb/db_fuel) [![Build Status](https://travis-ci.org/bluemarblepayroll/db_fuel.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/db_fuel) [![Maintainability](https://api.codeclimate.com/v1/badges/21945483950d9c35fabb/maintainability)](https://codeclimate.com/github/bluemarblepayroll/db_fuel/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/21945483950d9c35fabb/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/db_fuel/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This library is a plugin for [Burner](https://github.com/bluemarblepayroll/burner).  Burner, by itself, cannot use a database.  So, if you wish to use a database as a data source or as a target for mutation then you need to add a library similar to this.

## Installation

To install through Rubygems:

````bash
gem install db_fuel
````

You can also add this to your Gemfile:

````bash
bundle add db_fuel
````

## Jobs

Refer to the [Burner](https://github.com/bluemarblepayroll/burner) library for more specific information on how Burner works.  This section will just focus on what this library directly adds.

* **db_fuel/dbee/query** [model, query, register]:  Pass in a [Dbee](https://github.com/bluemarblepayroll/dbee) model and query and store the results in the specified register.  Refer to the [Dbee](https://github.com/bluemarblepayroll/dbee) library directly on how to craft a model or query.
* **db_fuel/dbee/range** [key, key_path, model, query, register, separator]: Similar to `db_fuel/dbee/query` with the addition of being able to grab a list of values from the register to use as a Dbee EQUALS/IN filter.  This helps to dynamically limit the resulting record set.  The key is used to specify where to grab the list of values, while the key_path will be used to craft the [Dbee equal's filter](https://github.com/bluemarblepayroll/dbee/blob/master/lib/dbee/query/filters/equals.rb).  Separator is exposed in case nested object support is necessary.

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check db_fuel.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/db_fuel.git)
4. Navigate to the root folder (cd db_fuel)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/db_fuel/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/db_fuel/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
