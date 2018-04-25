# ServiceMonitor

Service Monitor is a command line tool that pings an http service.
Response times are gathered up and some simple summary statistics.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'service_monitor', '~> 0.1.0' ,:git => "git@gitlab.com:vevang/service_monitor.git"
```

And then execute:

    $ bundle

Or install it yourself as:

  $ git clone https://gitlab.com/vevang/service_monitor.git

  $ cd service_monitor/

  $ bundle exec rake install

## Usage

    Service Monitor: Aggregate average response times across service types.
    Usage: service_monitor [options] <hostname>

    Specific options:
            --duration N                 Total duration in seconds of this
    service testing cycle
            --interval N                 Time in seconds between individual
    service tests (pings).
            --port N                     Port to target in ping test.
    Default http is port 80
        -h, --help                       Show this message

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on Gitlab at https://gitlab.com/vevang/service_monitor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ServiceMonitor project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://gitlab.com/vevang/service_monitor/blob/master/CODE_OF_CONDUCT.md).
