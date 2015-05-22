require 'twitter_ebooks'
require 'dotenv'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV["CONSUMER_KEY"]
    self.consumer_secret = ENV["CONSUMER_SECRET"]

    # Users to block instead of interacting with
    self.blacklist = []

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    load_model!

    scheduler.every '24h' do
      tweet(model.make_statement)
    end
  end

  def on_message(dm)
    delay do
      reply(dm, model.make_response(dm.text))
    end
  end

  def on_follow(user)
    follow(user.screen_name)
  end

  def on_mention(tweet)
    # reply(tweet, "oh hullo")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    follow(user.screen_name)
  end

  private
  def load_model!
    return if @model

    @model_path ||= "model/#{original}.model"

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make a MyBot and attach it to an account
MyBot.new("nietzsche_books") do |bot|
  bot.access_token = ENV["ACCESS_TOKEN_nietzsche"]
  bot.access_token_secret = ENV["ACCESS_SECRET_nietzsche"]
  bot.model_path = "model/nietzsche.model"
end
