FROM node:16
WORKDIR /usr/src/smart-garden
COPY package*.json ./
COPY index.js ./

RUN npm ci --only=production

EXPOSE 80
CMD [ "npm", "run", "server" ]
