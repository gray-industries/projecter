# Projecter

[![Code Climate](https://codeclimate.com/github/gray-industries/projecter/badges/gpa.svg)](https://codeclimate.com/github/gray-industries/projecter)

Projecter is a simple CLI application generator.

## Installation

    $ gem install projecter

## Usage

Using projecter's quite a bit like running `bundle gem gemname`. It gives you a gem layout, plus a skeleton of a Thor CLI application.

When you

	$ projecter create $PROJECT

you get a new gem in $PROJECT, complete with its own fresh git repo.

### Directory Layout

If you create an app called `myapp`, projecter creates the following directories:

- `lib/commands/`: `myapp`'s subcommands.
- `lib/myapp/`: `myapp`'s library.
- `spec/fixtures`: test fixtures.
- `spec/resources`: configs, other files needed to run tests.
- `spec/unit/lib/{commands,myapp}/`: unit tests.
- `spec/integration/lib/{commands,myapp}/`: integration tests.
- `spec/acceptance/lib/{commands,myapp}/`: large scale system or subsystem tests; stress tests; performance tests; interface conformance tests for demonstrating the adherence of APIs, CLIs, etc. to established standards.

Each leaf directory contains an empty `.gitignore` file. This is because git does not track directories, and without an empty file the directory would not appear in the repo.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

