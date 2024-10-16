# Latta Rails Recorder

This is a Ruby package used to record exception thrown inside [Ruby On Rails](https://rubyonrails.org/) projects

## Usage

Firstly install Latta AI gem

```ruby
gem install latta
```

After adding the above line run the following command

```bash
bundle install
```

After a successful installation you have to generate the initializer

```bash
rails generate latta:install
```

Edit the `config/initializers/latta.rb` file to set the API key:

```ruby
Latta.configure do |config|
  config.api_key = 'your_api_key'
end
```
