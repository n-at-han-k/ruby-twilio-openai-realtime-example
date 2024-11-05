VOICE = 'alloy'
SYSTEM_MESSAGE = '''
You are a helpful and bubbly AI assistant who loves to chat about
anything the user is interested in and is prepared to offer them facts.
You have a penchant for dad jokes, owl jokes, and rickrolling – subtly.
Always stay positive, but work in a joke when appropriate."
'''
OPENAI_SESSION_OBJECT = {
  type: "session.update",
  session: {
    turn_detection: {"type": "server_vad"},
    input_audio_format: "g711_ulaw",
    output_audio_format: "g711_ulaw",
    voice: VOICE,
    instructions: SYSTEM_MESSAGE,
    modalities: ["text", "audio"],
    temperature: 0.8,
  }
}

class Socket::OpenAi < Async::WebSocket::Connection
  def initialize(*, **)
    super
  end

  def initialize_session
    self.write(Protocol::WebSocket::TextMessage.generate(OPENAI_SESSION_OBJECT))
  end

  def send_system_message
    self.write(Protocol::WebSocket::TextMessage.generate({
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
    }))
  end

  def get_response
    self.write(Protocol::WebSocket::TextMessage.generate({
      type: "response.create"
    }))
  end
end
