FROM node:7.10-alpine

USER root

RUN npm install ungit@1.4.26 -g \
  && apk add --no-cache git openssh-client


USER node

RUN git config --global user.email "nick.freemn@gmail.com" \
    && git config --global user.name "Nick Freeman"

WORKDIR /var/www

EXPOSE 8448

CMD ["ungit", "--no-launchBrowser", "--forcedLaunchPath=/var/www"]
