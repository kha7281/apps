FROM node:8.11.4-alpine
RUN apk update && apk upgrade

RUN mkdir -p /app
WORKDIR /app

COPY app /app
RUN apk update && apk add shadow
RUN groupadd -r nodeuser -g 433 
RUN useradd -u 431 -g nodeuser -d /app -c "Node user" -s /sbin/nologin nodeuser
RUN chown -R nodeuser:nodeuser /app

ENV NODE_ENV production
RUN npm install --production 
USER nodeuser
EXPOSE 3000

CMD [ "npm", "start" ]