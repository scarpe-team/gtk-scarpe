# gtk-scarpe

Gtk-Scarpe is a specific Scarpe implementation based on GTK4. Scarpe is a reimplementation of Shoes, a Ruby desktop UI library originally written by [\_why the lucky stiff](https://en.wikipedia.org/wiki/Why_the_lucky_stiff).

Gtk-Scarpe uses Lacci, the standard Scarpe DSL, and Scarpe-Components. It's a non-HTML-based local display.

Gtk-Scarpe support Shoes-Spec, though only the set of drawables and features currently supported by Gtk-Scarpe.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gtk-scarpe

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gtk-scarpe

## Usage

Your application should include gtk-scarpe as a dependency. You can run a Shoes application with gtk-scarpe by using the gtk-scarpe executable:

    ./exe/gtk-scarpe examples/button_alert.rb

TODO: when gtk-scarpe is tested with Shoes-Spec, .scas and .sspec files, etc. add usage instructions here.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scarpe-team/gtk-scarpe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/scarpe-team/gtk-scarpe/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gtk::Scarpe project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/scarpe-team/gtk-scarpe/blob/main/CODE_OF_CONDUCT.md).

### Shoes References

Lots of these have great reference code for Shoes and Scarpe, and general Shoes-related information.

* [Nobody Knows Shoes](https://github.com/whymirror/why-archive/blob/master/shoes/nobody-knows-shoes.pdf) - the original "learn Shoes" book by \_why
* [The Shoes Manual](https://github.com/scarpe-team/scarpe/blob/main/docs/static/manual.md)
* [Scarpe API Docs](https://scarpe-team.github.io/scarpe/)
* [Scarpe Source Code](https://github.com/scarpe-team/scarpe/)
* [Scarpe-Wasm](https://github.com/scarpe-team/scarpe-wasm) - another "free-standing" display service for Scarpe, not packaged with Scarpe itself
* [AndyObtiva's Glimmer DSL for GTK+ 3.0](https://github.com/AndyObtiva/glimmer-dsl-gtk) - a good reference for another Ruby GTK+-based binding

### GTK+ References

Lots of these have great reference code for Shoes, Scarpe, GTK+ or similar.

Also, when Googling for GTK+ references, keep in mind that GTK+ version 4 ("gtk4") is significantly different from version 2 or version 3. Lots of changes, deprecations and so on. So older code using gtk2 and gtk3 will need updating.

* [Ruby-Gnome project](https://github.com/ruby-gnome/ruby-gnome) - Ruby bindings for GNOME libs like GTK+
* [Ruby GTK docs](https://www.rubydoc.info/gems/gtk4/4.2.0)
* [GTK+ 4.0 docs](https://docs.gtk.org/gtk4/getting_started.html)
* [The GTK+ 4 Draw Model](https://docs.gtk.org/gtk4/drawing-model.html) - this is a little different from earlier versions of GTK+
* [Green Shoes](https://github.com/ashbb/green_shoes) - a gtk2 implementation of Shoes Classic, from long before Scarpe existed
