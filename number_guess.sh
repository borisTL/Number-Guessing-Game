#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE user_id=$USER_ID")
  echo $USER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while [[ $GUESS != $SECRET_NUMBER ]]
do
  read GUESS
  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    GUESSES=$(( GUESSES + 1 ))

    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
if [[ -z $USER_ID ]]
then
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
fi
123213
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

# Update games played
UPDATE_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id=$USER_ID")

# Update best game if necessary
if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE user_id=$USER_ID")
fi
# Insert the game into the games table
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")

