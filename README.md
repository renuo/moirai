# 🧵 Moirai

<img src="./docs/moirai.png" width="100%" />

### Manage translation strings in real time

- Let your non-developer team members finally manage translations (yes, even Karen from marketing).
- See those translations live in your app, so you can make sure “Submit” isn’t overlapping the button where “Do not press this button EVER” should be.
- Automatically create Pull Requests based on these changes, saving your developers from yet another “small tweak” email request.

> Let the world be translated, one typo at a time.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "moirai"
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install moirai
```

Mount the engine in your `config/routes.rb`:

```ruby
mount Moirai::Engine => '/moirai', as: 'moirai'
```

Next, you need to run the generator which will create the necessary files including the database migration:

```bash
rails generate moirai:install
```

Then run:

```bash
rails db:migrate
```

## Usage

... Actual details of how to use the engine should go here.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, set your environment variables using a `.env` file.
Then, run `bin/check` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can view the engine in a dummy app by heading to the `test/dummy` folder and running `bin/rails s` 

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Copyright

Coypright [Renuo AG](https://www.renuo.ch/).
