json.array!(@bots) do |bot|
  json.extract! bot, :id, :status
  json.url bot_url(bot, format: :json)
end
