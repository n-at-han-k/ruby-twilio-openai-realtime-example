class Bridge
  def initialize(twilio, openai)
    @twilio = twilio
    @openai = openai

    @openai.initialize_session
    @openai.send_system_message
    #@openai.get_response
  end

  def handle_twilio(message)
    $stdout.puts message.parse
  end
  def handle_openai(message)
    $stdout.puts message.parse
  end
end
