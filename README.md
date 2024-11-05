# Ruby Twilio OpenAI Realtime Example

## Setup
Add your OpenAI API key to the `.env` file.
```
# .env
OPENAI_API_KEY=abcdefghijklexample
HOST=example.ngrok.com
```

## Twilio Dev Phone for testing
To use the Dev Phone, you'll need to first have [an up-to-date installation of the Twilio CLI](https://www.twilio.com/docs/twilio-cli/getting-started/install), as well as access to a spare Twilio phone number. That means that [you'll need an upgraded Twilio account](https://support.twilio.com/hc/en-us/articles/223183208-Upgrading-to-a-paid-Twilio-Account?_ga=2.24955578.160882329.1650457443-360531395.1625234680), not a trial account.

Once you've installed the Twilio CLI, you're ready to add the Dev Phone plugin with the following command:

`twilio plugins:install @twilio-labs/plugin-dev-phone`

Once it's installed, you can run the Dev Phone with the following command:

`twilio dev-phone`
