require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, browser: :chrome, js_errors: false)
end

Capybara.default_driver = :poltergeist
Capybara.default_max_wait_time = 10 #seconds

class WeiboScraper
  include Capybara::DSL

  attr_reader :browser

  def initialize(email:, password:)
    @browser = Capybara.current_session
    url = 'https://www.weibo.com/'
    browser.visit(url)
    sleep(10)
    browser.find_link(text: '登录', match: :first).click
    browser.within('.form_login_register', match: :first) do
      browser.fill_in('username', with: email)
      browser.fill_in('password', with: password)
      browser.click_on('登录')
    end
  end

  def page_posts(hashtags:, page:)
    acc_post = []
    (1..page).each do |n|
      visit_posts_page(hashtags, n)
      acc_post += posts unless posts.empty?
    end
    acc_post
  end

  def posts
    browser.find_all(".card-feed").map do |feed|
      {
        name: feed.find(".name", match: :first).text,
        url: feed.find(".name", match: :first)["href"],
        avatar: feed.find(".avator").find("img")["src"],
        text: feed.find(".txt").text,
        img: get_images(feed)
      }
    end
  end

  def next_page
    browser.find('.next').click
  end

  def visit_posts_page(hashtags, page = 1)
    url = "https://s.weibo.com/realtime?q=#{parse_query(hashtags)}&rd=realtime&tw=realtime&Refer=weibo_realtime&page=#{page}"
    browser.visit(url)
    sleep(10) # wait for page to load before next action, weibo is slow.
  end

  private

  def get_images(feed)
    return unless feed.has_css?(".media-piclist")

    feed.find(".media-piclist").find_all("img").map{ |img| img["src"] }
  end

  def parse_query(tags)
    hashtags = tags.map{ |tag| "%23#{tag}%23" }
    hashtags.join('%20')
  end
end
