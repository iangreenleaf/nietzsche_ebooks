require 'twitter_ebooks'
require 'dotenv'

# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

class MyBot < Ebooks::Bot
  attr_accessor :model_path

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

  # Nietzsche's schedule:
  # midnight-6am: The merciful abyss of sleep
  # 7am: Wake up, tea and biscuits
  # 8am-9am: Brooding
  # 10am-11am: A bracing walk, the senses alive with a rush of enlightened ascendant power!
  # noon-3pm: Despair
  # 4pm: Afternoon snack
  # 5pm-6pm: Stoking the flames of old enmities
  # 7pm: Light dinner
  # 8pm-11pm: Brooding despair
  # midnight: Opium
  SCHEDULE = {
    "7" => 0.1,
    "8" => 0.3,
    "9" => 0.4,
    "10" => 0.1,
    "11" => 0.1,
    "12" => 0.2,
    "13" => 0.2,
    "14" => 0.2,
    "15" => 0.2,
    "16" => 0.1,
    "17" => 0.4,
    "18" => 0.4,
    "19" => 0.1,
    "20" => 0.3,
    "21" => 0.3,
    "22" => 0.3,
    "23" => 0.3,
    "24" => 0.1,
  }

  def on_startup
    load_model!

    scheduler.cron '0,30 7-24 * * * America/Los_Angeles' do
      if rand < SCHEDULE[Time.now.hour.to_s].to_i / 2
        tweet(model.make_statement)
      end
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
    # Become more inclined to pester a user when they talk to us
    userinfo(tweet.user.screen_name).pesters_left += 1

    delay do
      reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
    end
  end

  def on_favorite(user, tweet)
    follow(user.screen_name)
  end

  def top200; @top200 ||= model.keywords.take(200); end
  def top50;  @top50  ||= model.keywords.take(50); end

  def on_timeline(tweet)
    return if tweet.retweeted_status?
    return unless can_pester?(tweet.user.screen_name)

    tokens = Ebooks::NLP.tokenize(tweet.text)

    interesting = tokens.find { |t| top200.include?(t.downcase) }
    very_interesting = tokens.find_all { |t| top50.include?(t.downcase) }.length > 2

    delay do
      if very_interesting
        favorite(tweet) if rand < 0.5
        retweet(tweet) if rand < 0.1
        if rand < 0.01
          userinfo(tweet.user.screen_name).pesters_left -= 1
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      elsif interesting
        favorite(tweet) if rand < 0.05
        if rand < 0.001
          userinfo(tweet.user.screen_name).pesters_left -= 1
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      end
    end
  end

  # Find information we've collected about a user
  # @param username [String]
  # @return [Ebooks::UserInfo]
  def userinfo(username)
    @userinfo[username] ||= UserInfo.new(username)
  end

  # Check if we're allowed to send unprompted tweets to a user
  # @param username [String]
  # @return [Boolean]
  def can_pester?(username)
    userinfo(username).pesters_left > 0
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
