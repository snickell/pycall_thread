# PyCallThread

PyCallThread provides `PyCallThread.run(&block)`, which lets you safely run a block of
[pycall.rb](https://github.com/mrkn/pycall.rb) code: even if you're in a thread.

This makes PyCall easier to use from Ruby on Rails, Puma and other threaded web servers.

## Usage

```
require 'pycall_thread'

# Initialization is optional but gives you a few config settings
PyCallThread.init do
  # If you need to do anything to setup you venv, you can do it here
  require 'pycall'
end

# We can safely call PyCall, even from a thread (or web request) using `PyCallThread.run`:
Thread.new do
  data_table = PyCallThread.run do
    pandas = PyCall.import('pandas')
    data = pandas.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv', sep: ';')
    data.head().to_string()
  end
  puts "Data is:"
  puts data_table
end
```

Examples of using PyCall with webservers:

- [Puma](./examples/puma)
- Ruby on Rails: todo

## Installation

Gemfile:

```ruby
gem 'pycall_thread'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

TODO: make run `rake test` run the tests
