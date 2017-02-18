namespace :pinterest do
  task like_recommended_posts: :environment do
    
    tags = ['starwars', 'deathstar', 'darthvader', 'lukeskywalker', 'hansolo', 'princessleia',
     'r2d2', 'c3p0', 'darthmaul', 'anewhope', 'empirestrikesback', 'returnofthejedi',
     'theforceawakens', 'rogueone', 'georgelucs', 
     'lotr', 'thehobbit', 'bilbobaggins', 'frodo', 'samwise', 'theshire', 'gandalf',
     'gimli', 'aragorn', 'helmsdeep', 'mordor', 'sauron', 'christopherlee'
    ]
    bot = PinterestBot.new
    bot.sign_in ENV['PINTEREST_KEY'], ENV['PINTEREST_SECRET']

    pin_ids = bot.get_pin_ids(tags.sample)
    bot.like_pins(pin_ids.sample(5))
    p 'Pinterest Bot Completed'
  end
end