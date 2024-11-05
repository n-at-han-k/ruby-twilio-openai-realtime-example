#!/usr/bin/env ruby
require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'

#URL = url  + '/twilio-stream'
#URL = "http://localhost:9292/ai-stream"
URL = "http://localhost:9292/ai-stream"

Async do |task|
  # apln_protocols is a workaround for NGrok fake http2
  endpoint = Async::HTTP::Endpoint.parse(URL, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		input_task = task.async do
			while line = $stdin.gets
		    connection.write(Protocol::WebSocket::TextMessage.generate({
          text: line.chomp
        }))
				connection.flush
			end
		end
		
		# Generate a text message by geneating a JSON payload from a hash:
		connection.write(Protocol::WebSocket::TextMessage.generate({
			status: "connected"
		}))
		
		while message = connection.read
			puts "[response] #{message.inspect}"
		end
	ensure
		input_task&.stop
	end
end
