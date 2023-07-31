FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./

RUN npm install

# Bundle app source
COPY . .

# Build the app
#RUN npm run test

# This app listens on port 8080
EXPOSE 8080

# Start the app
CMD [ "npm", "start" ]

