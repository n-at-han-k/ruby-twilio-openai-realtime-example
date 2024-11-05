VOICE = 'alloy'
SYSTEM_MESSAGE = '''
You are a helpful and bubbly AI assistant who loves to chat about
anything the user is interested in and is prepared to offer them facts.
You have a penchant for dad jokes, owl jokes, and rickrolling – subtly.
Always stay positive, but work in a joke when appropriate."
'''
SESSION_OBJECT = {
  type: "session.update",
  session: {
    turn_detection: {
      type: "server_vad"
    },
    input_audio_format: "g711_ulaw",
    output_audio_format: "g711_ulaw",
    voice: VOICE,
    instructions: SYSTEM_MESSAGE,
    modalities: [
      "text",
      "audio"
    ],
    temperature: 0.8,
  }
}
INITIAL_CONVERSATION = {
  type: "conversation.item.create",
  item: {
    type: "message",
    role: "user",
    content: [
      {
        type: "input_text",
        text: "Greet the user with 'Hello there! I am an AI voice assistant powered by Twilio and the OpenAI Realtime API. You can ask me for facts, jokes, or anything you can imagine. How can I help you?'"
      }
    ]
  }
}

class Socket::OpenAi < Async::WebSocket::Connection
  attr_accessor :last_assistant_item

  def initialize(*, **)
    super

    @last_assistant_item = nil
  end

  def initialize_session
    self.write(Protocol::WebSocket::TextMessage.generate(SESSION_OBJECT))
  end

  def send_system_message
    self.write(Protocol::WebSocket::TextMessage.generate(INITIAL_CONVERSATION))
  end

  def get_response
    self.write(Protocol::WebSocket::TextMessage.generate({
      type: "response.create"
    }))
  end

  def input_audio_buffer_append(data)
    message = Protocol::WebSocket::TextMessage.generate(data)
    self.write(message)
    # puts '<-- [OPENAI] input_audio_buffer.append'
    # puts message.inspect
  end

  def conversation_item_truncate(elapsed_time)
    message = Protocol::WebSocket::TextMessage.generate({
      type: "conversation.item.truncate",
      item_id: @last_assistant_item,
      content_index: 0,
      audio_end_ms: elapsed_time
    })
    self.write(message)
    # puts '<-- [OPENAI] conversation_item.truncate'
    # puts message.inspect
  end
end
