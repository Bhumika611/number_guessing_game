#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Enter your username:"
read USERNAME

# Check user
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO" 
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Game start
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  # Check if input is integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update DB
    $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'"
    BEST_GAME_CURRENT=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    if [[ -z $BEST_GAME_CURRENT || $BEST_GAME_CURRENT -gt $NUMBER_OF_GUESSES ]]; then
      $PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'"
    fi
    break
  fi
done

echo "Debug: Starting game logic..."
# This script runs a number guessing game using PostgreSQL
echo "Game initialized. Secret number is set." # Debug message
# Prompt user for username and check if they exist in the database
