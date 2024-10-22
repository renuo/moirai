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

### How to change translations

Head to your application and navigate to `/moirai`. You will be greeted with a list of all the translations in your application...

`# TODO: Daniel? to give more details`

### Automatic PR creation with Octokit (**optional**)

If you would like Moirai to automatically create a pull request on GitHub to keep translations synchronized with the codebase, you will need to set up **Octokit**, create a **Personal Access Token** on GitHub and configure the appropriate **environment variables**.

#### 1. Add Octokit to Your Gemfile

First, add Octokit to your project’s Gemfile:

```
gem 'octokit'
```

Then run `bundle install`.

#### 2. Create a Personal Access Token (PAT) on GitHub

You will need a Personal Access Token (PAT) with the `Content - Write` permission to create branches and pull requests.

-	Go to GitHub Token Settings.
-	Click Generate New Token.
-	Give your token a name (e.g., “Moirai”).
-	Under Scopes, select:
     -	repo (for full control of private repositories, including writing content).
     -	content (for read/write access to code, commit statuses, and pull requests).
-	Generate the token and copy it immediately as it will be shown only once.

#### 3. Set Up Environment Variables

You need to configure the following environment variables in your application:

-	`MOIRAI_GITHUB_REPO_NAME`: The name of the repository where the pull request will be created.
-	`MOIRAI_GITHUB_ACCESS_TOKEN`: The Personal Access Token (PAT) you created earlier.

For example, in your `.env` file (or Rails credentials):

```
MOIRAI_GITHUB_REPO_NAME=your-organization/your-repo
MOIRAI_GITHUB_ACCESS_TOKEN=your-generated-token
```

#### 4. Triggering the pull request creation

Moirai will now be able to use this Personal Access Token to create a pull request on GitHub when a translation is updated.

To trigger this, you can press the `'Create Pull Request'` button once you have made your changes.

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
