ChatOps Bot
==================

Intro
-----

Dockerfile: Using Ubuntu as a base image, Hubot is generated and
some dependencies are installed. Plugins and coffeescripts are
added to the image along with a run script and an HTTP responder
written in Go to give AWS Elastic Load Balancers something to 
health check against.

go_http_responder: Prebuilt HTTP responder for ELB health checks
along with source code.

vendor: Vendored node package.

Dockerrun.aws.json: Container definitions used to start or update
an Elastic Beanstalk environment.

run_elb_pong.sh: Run script for go_http_responder.

run_hubot.sh: Run script for the bot.

app.coffee: Core app-specific Hubot functionality.


Setup
-----

1) /build.sh to build the Docker image  
2) ./push_image.sh to push the Docker images to the registry  
3) ./deploy.sh to launch the new containers in Elastic Beanstalk  
(must have appropriate permissions)
