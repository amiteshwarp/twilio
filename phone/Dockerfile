# Use the official Node.js image as the base
FROM node:18

# Set the working directory inside the container
WORKDIR /usr/src/app

# Install the Twilio CLI globally
RUN npm install -g twilio-cli

# Install the Twilio Dev Phone plugin
RUN twilio plugins:install @twilio-labs/plugin-dev-phone

# Set environment variables for Twilio credentials
ENV TWILIO_ACCOUNT_SID=your_account_sid
ENV TWILIO_AUTH_TOKEN=your_auth_token

# Expose the port that the Twilio Dev Phone will run on
EXPOSE 3000

# Set the entrypoint to run the Twilio Dev Phone on the specified port
ENTRYPOINT ["twilio", "dev-phone", "--port=3000"]