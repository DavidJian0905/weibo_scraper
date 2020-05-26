## About The Project
Simple scraper script for hahstags for Weibo build with Capybara and Poltergeist

## Usage
```ruby
ws = WeiboScraper.new(email: 'example@rubify.com', password: 'Rubify')
# get current page post
ws.posts
# get post of multiple page
ws.page_posts(hashtags: ['bitcoin', 'instagram'], page: 3)

# to return to a specific posts page
ws.visit_posts_page(hashtags: ['bitcoin', 'instagram'], page: 3)
```