require "uri"
ParserFreelance = SimpleGmail.new_parser( [[String, String, URI::HTTPS]] ) do |text|
  match = lambda do |s, r, invert = false|
    if invert ^ (r =~ s) then next $1 end
    puts "s: #{s}"
    puts "r: #{r}"
    raise SimpleGmail::MessageParserError
  end
  match[text, /\AХабр Фриланс - Биржа удаленной работы для IT-специалистов\n––––––––––––––––––––––––––––––––––––––––––––––––––\nПриветствуем, Виктор Маслов!\n\nНа Хабр Фриланс опубликован новый заказ в категории (\S+ \([^)]+\)):\n– (\S.+?)\s+–\s+(https:\/\/freelance\.habr\.com\/email_tracking\/messages\/\S+)\n/]
  [
    $1,
    $2,
    URI(URI.decode_www_form(URI($3).query).to_h.fetch("url")).tap{ |_| _.query = nil }.tap{ |_|
      match[_.to_s, /\Ahttps:\/\/freelance\.habr\.com\/tasks\/\d+\z/]
    }
  ]
end
