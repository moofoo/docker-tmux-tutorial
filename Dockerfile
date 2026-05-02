FROM node:lts-alpine

RUN apk add htop bash

WORKDIR /usr/src/app

ARG APP

COPY ./apps/$APP/package*.json ./

RUN npm install

COPY ./apps/$APP .

RUN if [ "$APP" = "api" ]; then \
    npm i -g @nestjs/cli; \
    fi

CMD ["npm", "run", "dev"]