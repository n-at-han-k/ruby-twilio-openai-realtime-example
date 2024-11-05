class Bridge
  def initialize(twilio, openai)
    @twilio = twilio
    @openai = openai

    @openai.initialize_session
    @openai.send_system_message
    #@openai.get_response
  end

  def close
    @twilio.close
    @openai.close
  end
end
