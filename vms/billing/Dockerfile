FROM alpine:3.16

RUN apk add --no-cache nodejs npm

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE ${BILLING_PORT}

CMD ["sh", "-c", "node consumer.js"]