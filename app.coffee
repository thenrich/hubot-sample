# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

ENV_MAP = {
  'domain-qa': 'domain-qa',
  'domain-dev': 'domain-dev',
  'domain-prod': 'domain'
}

MIGRATE_COMMAND = "migrate"

module.exports = (robot) ->

    robot.respond /deploy (.*) to (.*)/i, (res) ->
      # Handle perms
      role = 'deploy'

      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have the #{role} role to do that."
        return

      version = res.match[1]
      environ = res.match[2]

      if !ENV_MAP[environ]
        res.send 'Unknown environment'
        return

      aws = require('aws-sdk')
      aws.config.update({region: 'us-east-1'})

      # Lambda-based Django migration 
      lmb_params = {
        FunctionName: 'arn:aws:lambda:us-east-1:...:function:ebDjangoMigrate',
        LogType: 'Tail',
        Payload: JSON.stringify({
          application_name: ENV_MAP[environ],
          environment_name: environ,
          version: version,
          command: MIGRATE_COMMAND
        })
      }
      lmb = new aws.Lambda();
      lmb.invoke (lmb_params), (err, data) ->
        if err?
          res.send "Error: #{err.message}"

        if data?
          d = JSON.parse data.Payload
          robot.logger.error(d)
          if d.errorMessage?
            res.send "Error: #{d.errorMessage}"
          else
            res.send "Running migration in task: #{d.task_arn}: #{d.status}"

      eb = new aws.ElasticBeanstalk()          
      res.send 'Waiting 60 seconds and then deploying'
      setTimeout ->
        eb.updateEnvironment {EnvironmentName: environ, VersionLabel: version}, (err, data) -> 
          if err?
            res.send "#{err.message}"

          if data?
            res.send "#{data.Status}" 
      , 60000
      
    robot.respond /rc (.*) (.*)/i, (res) ->
      # Handle perms
      role = 'deploy'
      
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have the #{role} role to do that."
        return

      github_user = 'github-bot'
      github_password = process.env.GITHUB_BOT_GITHUB_PASSWORD
      circle_base = 'https://circleci.com/gh/GITHUB_ORG/app/tree/'

      sha = res.match[1];
      target_branch = 'release-' + res.match[2];

      data = JSON.stringify({
          ref: "refs/heads/#{target_branch}",
          sha: "#{sha}"
      })
      auth = 'Basic ' + new Buffer(github_user + ':' + github_password).toString('base64');

      robot.http('https://api.github.com/repos/GITHUB_ORG/app/git/refs')
        .headers({"Authorization": auth, "Content-Type": 'application/json'})
        .post(data) (err, r, body) ->
            if err
                res.send "Error: #{err}"
                return

            data = JSON.parse body
            robot.logger.error(data)
            if data.message?
                res.send data.message
                return
            else
                res.send "OK -- " + circle_base + target_branch
                return

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
