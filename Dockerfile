FROM ubuntu

RUN apt-get update
RUN apt-get -y install curl && curl -sL https://deb.nodesource.com/setup_6.x | bash && apt-get -y install nodejs
RUN useradd -ms /bin/bash hubot

# Fix EXDEV: cross-device link not permitted issue with Dokcker + npm
RUN cd $(npm root -g)/npm && npm install fs-extra && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js
RUN npm -g install yo generator-hubot
USER hubot

RUN cd /home/hubot && mkdir hubot && cd hubot && yo hubot --owner "Tim <tim@loopscience.com>" --name app-hubot --adapter slack --defaults


ADD run_hubot.sh /home/hubot/hubot/run_hubot.sh
ADD run_elb_pong.sh /home/hubot/hubot/run_elb_pong.sh
ADD go_http_responder/bin/linux_amd64/elb_pong /home/hubot/hubot/bin/elb_pong
WORKDIR /home/hubot/hubot

ADD package.json /home/hubot/hubot/package.json
ADD external-scripts.json /home/hubot/hubot/external-scripts.json
ADD app.coffee /home/hubot/hubot/scripts/app.coffee
RUN npm install
