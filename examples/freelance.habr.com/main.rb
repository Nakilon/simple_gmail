require "simple_gmail"
require_relative "parser"

SimpleGmail.read_imap *File.read("secret").split, "subscribe@freelance.habr.com", "Новый заказ *" do |messages|
  messages.each do |msg|
    p msg.id
    type, title, url = ParserFreelance[msg.text]
    require "net/http"
    case Net::HTTP.start(url.host, 443, use_ssl: true){ |_| break _.head url.path }.code
    when "200"
      puts "200 #{url} #{type} #{title}"
    else
      fail
    end
  end
  next
end
