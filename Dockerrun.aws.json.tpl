{
    "AWSEBDockerrunVersion": 2,
    "authentication": {
        "bucket": "com.domain.docker.config",
        "key": "dockercfg"
    },
    "containerDefinitions": [
        {
            "name": "redis",
            "image": "redis:latest",
            "essential": true,
            "memory": 256,
            "mountPoints": [
                {
                    "sourceVolume": "awseb-logs-redis",
                    "containerPath": "/var/log/redis"
                }
            ]
        },
        {
            "name": "elb-pong",
            "image": "docker.domain.com/app-hubot:[VERSION]",
            "essential": "true",
            "memory": 128,
            "portMappings": [
                {
                    "hostPort": 8080,
                    "containerPort": 8080
                }
            ],
            "command": [
                "./run_elb_pong.sh"
            ]
        },
        {
            "name": "hubot",
            "image": "docker.domain.com/app-hubot:[VERSION]",
            "links": [
                "redis"
            ],
            "essential": true,
            "memory": 256,
            "mountPoints": [
                {
                    "sourceVolume": "awseb-logs-hubot",
                    "containerPath": "/var/log/hubot"
                }
            ],
            "command": [
                "./run_hubot.sh"
            ]
        }
        
    ]
}
