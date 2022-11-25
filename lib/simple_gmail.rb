module SimpleGmail
  def self.read_imap username, password, from, subject
    require "mail"
    Mail.defaults do
      # https://support.google.com/mail/answer/7126229
      retriever_method :imap, address:    "imap.gmail.com",
                              port:       993,
                              user_name:  username,
                              password:   password,
                              enable_ssl: true
    end
    imap = nil
    messages = []
    require "fileutils"
    Mail.find(read_only: true, search_charset: "UTF-8", keys: ["UNSEEN", "FROM", from, "SUBJECT", subject]) do |msg, _, uid|
      imap ||= _
      messages.push Struct.new(:id, :timestamp, :snippet, :text).new uid, msg.date, msg.subject, msg.text_part.decoded.tap{ |text|
        FileUtils.mkdir_p "texts"
        File.write "texts/#{msg.message_id}.txt", text if "darwin" == Gem::Platform.local.os
      }
    end
    puts "messages: #{messages.size}"
    ids = yield messages
    return unless ids.is_a?(Array) && !ids.empty?
    if "darwin" == Gem::Platform.local.os
      puts "would mark as read: #{ids}"
    else
      puts "don't press enter unless you want to mark as read"
      gets
      imap.uid_store ids, "+FLAGS", [Net::IMAP::SEEN]
    end
  end
  MessageParserError = Class.new RuntimeError
  def self.new_parser schema
    require "nakischema"
    lambda do |text|
      begin
        yield text
      end.tap do |result|
        Nakischema.validate result, schema
      end
    end
  end
end
