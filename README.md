# TicTacToe for EML code review

## URL API

 * create new game: `POST /`, new game will be accessible via Location header
 * make move: `PUT $location` x=y=
 * query state: `GET $location`

## DB Layout

 * Games (id)
 * Moves (id, game_id, x, y, player, timestamp)
