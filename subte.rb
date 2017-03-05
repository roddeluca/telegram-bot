require 'telegram/bot'
require 'http'
require 'json'
require 'net/http'
require 'active_support/core_ext/hash'
require 'sinatra'
require 'rubygems'


get '/' do
  content_type :json
  { :bot_status => 'ok'}.to_json
end

def get_subte_status
	s = Net::HTTP.get_response(URI.parse('http://www.infosubte.com.ar/medios/listinfosubte.asp')).body
	json = Hash.from_xml(s).to_json
	parsed = JSON.parse(json)

	subway_lines = parsed["Reporte"]["Linea"]
	return format_response subway_lines
end

def format_response(lines)
	pretty_lines = ""
	for line in lines
   		pretty_lines = pretty_lines + pretty_response(line) + "\n"
	end
	return pretty_lines
end

def pretty_response(line)
	name = line["nombre"]
	status = line["estado"] == "\n\t\t" ? "✅️": line["estado"] + " ⚠"
	return name + ": "+ status
end

Telegram::Bot::Client.run('212887638:AAGJDEGvoQZvWIIknhbxB-KpbWjOuQvZaHI') do |bot|
    bot.listen do |message|
      case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}!🎉 \nSi queres saber el estado del 🚇 ingresá: estado")
      when '/stop'
        bot.api.send_message(chat_id: message.chat.id, text: "¡Hasta la próxima, #{message.from.first_name}!")
      when 'estado'
        bot.api.send_message(chat_id: message.chat.id, text: get_subte_status)
      when 'Estado'
    	 bot.api.send_message(chat_id: message.chat.id, text: get_subte_status)
      when '@subteBAbot estado'
    	 bot.api.send_message(chat_id: message.chat.id, text: get_subte_status)
      when '@subteBAbot Estado'
    	 bot.api.send_message(chat_id: message.chat.id, text: get_subte_status)
  	 else
  		  bot.api.send_message(chat_id: message.chat.id, text: "Para consultar el estado del 🚇 ingresá: estado")
  		  puts message.text
      end
    end
end
