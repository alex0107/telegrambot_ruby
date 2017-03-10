#require 'rest_client'
require 'faraday'
require 'telegram/bot'
sw = false
sepia = false
token = 'your_token'
array = []
t = Thread.new {
while true
	time = Time.new
	if time.hour == 06 && time.min == 14 && time.sec == 59
		sleep(2)
		Telegram::Bot::Client.run(token) do |b|
			File.readlines("ids.me").each do |line|
				b.api.sendMessage(chat_id: line, text: "Good morning! Have a nice day!")
			end
		end
	end
        if time.hour == 11 && time.min == 59 && time.sec == 59
                sleep(2)
                Telegram::Bot::Client.run(token) do |b|
                        File.readlines("ids.me").each do |line|
				b.api.sendMessage(chat_id: line, text: "Enjoy your meal!")
                                b.api.sendMessage(chat_id: line, text: `fortune`)
                        end
                end
        end
        if time.hour == 17 && time.min == 59 && time.sec == 59
                sleep(2)
                Telegram::Bot::Client.run(token) do |b|
                        File.readlines("ids.me").each do |line|
                                b.api.sendMessage(chat_id: line, text: `fortune`)
                        end
                end
        end
        if time.hour == 21 && time.min == 29 && time.sec == 59
                sleep(2)
                Telegram::Bot::Client.run(token) do |b|
                        File.readlines("ids.me").each do |line|
                                b.api.sendMessage(chat_id: line, text: "Good night!")
                        end
                end
        end
	sleep(0.5)
end
}

Telegram::Bot::Client.run(token) do |bot|
  begin
  bot.listen do |message|

if !(message.location).nil?
	 lon = message.location.longitude
	 lan = message.location.latitude
	 puts lan
	 puts lon
	 bot.api.sendMessage(chat_id: message.chat.id, text: `inxi -xxxW #{lon}, #{lan}` )
end

if !(message.photo[message.photo.length-1]).nil?
      photo = message.photo[message.photo.length-1].file_id
      getresult = bot.api.getFile(file_id: photo)
      path = getresult["result"]["file_path"]
      file = path.split('/')[-1]
      `wget https://api.telegram.org/file/bot!!your_token!!/#{path}`
      if sw == true
         `convert #{file} -colorspace RGB -colorspace Gray new.jpg`
	 `mv new.jpg #{file}`
	 sw = false
      end
      if sepia == true
         `convert #{file} -colorspace RGB -sepia-tone 80% new.jpg`
         `mv new.jpg #{file}`
         sepia = false
      end
      bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new("#{file}", "image/jpeg"))
      sleep(0.5)
      `rm #{file}`
end

   case message.text
    when '/start'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello #{message.from.first_name}!!")
      open('ids.me', 'a') { |f|
          f.puts message.chat.id
      }
    when '/stop'
      File.readlines("ids.me").each do |line|
	k = message.chat.id
	k = k.to_s + "\n"
	if !(line == k)
	   array.push(line)
	end
      end
      open('ids.me', 'w+') { |f|
	array.each { |x| 
		f.puts x
	}
      }
      bot.api.sendMessage(chat_id: message.chat.id, text: "No automatic messages anymore! Bye! :)")
    when '/pic', /Pic/i
      question = 'Hmm...How do you want your picture?'
      answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w(BW Sepia)], one_time_keyboard: true)
      bot.api.sendMessage(chat_id: message.chat.id, text: question, reply_markup: answers)
    when /SW/i
      bot.api.sendMessage(chat_id: message.chat.id, text: "Please send your picture!")
      sw = true
    when /Sepia/i
      bot.api.sendMessage(chat_id: message.chat.id, text: "Please send your picture!")
      sepia = true
    when '/temp'
      bot.api.sendMessage(chat_id: message.chat.id, text: `sensors`)
    when '/mail log'
      bot.api.sendMessage(chat_id: message.chat.id, text: `tail /var/log/exim4/mainlog -n 5`) 
    when '/ids'
      bot.api.sendMessage(chat_id: message.chat.id, text: `cat ids.me`)
    when /hello/i, /hi/i
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello #{message.from.first_name}!")
    when /sorry/i
      bot.api.sendMessage(chat_id: message.chat.id, text: "Why #{message.text}? You shouldn't be sorry!")
    when /debug/i
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{message.inspect}")
    when /joke/i, '/joke'
      bot.api.sendMessage(chat_id: message.chat.id, text: `fortune`)
    else
#      bot.api.sendMessage(chat_id: message.chat.id, text: "")
    end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    retry
  end
end

t.join
