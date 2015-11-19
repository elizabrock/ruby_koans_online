# Learn Ruby... Now
## With the Ruby Koans online
### [https://elizakoans.herokuapp.com/](https://elizakoans.herokuapp.com/)

The Koans walk you along the path to enlightenment in order to learn Ruby. The goal is to learn the Ruby language, syntax, structure, and some common functions and libraries. We also teach you culture. Testing is not just something we pay lip service to, but something we live. It is essential in your quest to learn and do great things in the language.

Use the library to begin learning ruby from the comfort of your favorite browser without
having to install ruby, git or fight any of the other various platform specific issues
that keep you from taking that all important first step into a larger world.

With the Ruby Koans Online, you can dip your big toe into a larger world no matter
where you are or what you're doing. So what are you waiting for? Try the Ruby Koans
Online now and take your first step into the wonderful world of Ruby.

## Development Setup

### Ruby Dependencies

The koans currently run on MRI 2.2.3. Ruby gem dependencies are handled by [bundler](http://gembulder.com). To install all the necessary gems, run `bundle install`.

### Phantomjs Dependency

Ruby Koans Online is tested using [Poltergeist](https://github.com/teampoltergeist/poltergeist), so you will need Phantom.js installed (instructions are on the Poltergeist README).

### Development

To start the development server, run `rackup` and point your browser to `localhost:9292`

Alternatively, you could use [`rerun`](https://rubygems.org/gems/rerun). This reloads the app for you when changes are detected:

`rerun -p "**.*.{rb,ru,haml,css,js,yml}" puma`

#### Running the tests:

1. Run `rake`.

## Contributing

Fork the project, make your fix, add some tests, and send a pull request!

### Ideas for Contributions

Some of the error messages throughout the Koans don't make a ton of sense to novices.

For example, in `about_triangle_project`:

    def test_good_triangle_error_messages
      page.visit "/en/about_triangle_project"
      click_on "Click to submit Meditation or press Enter while in the form."
      assert_include page.body, "

Results in:

      The answers which you seek:
    undefined method `triangle' for #<KoanArena::UniqueRun1668::AboutTriangleProject:0x007fc694346ba8>"
    end

That’s not a great message :(

There are numerous other not-so-intuitive messages throughout the koans.  I'd love for them to be movice-friendly!
