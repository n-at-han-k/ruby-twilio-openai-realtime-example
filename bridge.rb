class Bridge
  def initialize(twilio, openai)
    @twilio = twilio
    @openai = openai

    @openai.initialize_session
    @openai.send_system_message
    #@openai.get_response
  end

  def handle_twilio(message)
    begin
      event = message[:event] + '_event'
      @twilio.send(event, message)
    rescue
      # handle error here
    end
  end
  def handle_openai(message)
    begin
      event = message[:type].gsub('.', '_') + '_event'
      @openai.send(event, message)
    rescue
      # handle error here
    end
  end
end
