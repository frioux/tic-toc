# TicTacToe for EML code review

## URL API

 * create new game: `POST /`, new game will be accessible via Location header
 * make move: `PUT $location` x=y=
 * query state: `GET $location`

## DB Layout

 * Games (id)
 * Moves (id, game_id, x, y, player, timestamp)

## Usage

 * `plackup -Ilib -p 3001`
 * `curl -v -X POST http://localhost:3001/`
 * `curl -v -X PUT  http://lcoalhost:3001/$foo` -d 'x=0&y=0'
 * `curl http://localhost:3001/$foo`
