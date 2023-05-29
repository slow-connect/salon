#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
    else
      echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
   # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  # if no services available
  if [[ -z $AVAILABLE_SERVICES  ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any services to offer."
  else

      # display available services
      AVAILABLE_SERVICES=$(echo "$AVAILABLE_SERVICES" | head -n -1 | tail -n +3)
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
      echo "$SERVICE_ID) $NAME"
      done
  fi
  read SERVICE_ID_SELECTED
  MAX=$($PSQL "SELECT count(service_id) FROM services;")
  MAX=$(echo "$MAX" | head -n -1 | tail -n +3)
  if [[ $SERVICE_ID_SELECTED -gt $MAX ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  elif [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  elif [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    CUSTOMER_ID="$(echo "$CUSTOMER_ID" | head -n -1 | tail -n +3)"
    CUSTOMER_ID=$(echo $CUSTOMER_ID)
    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
  # get customer_id and name
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';");
  CUSTOMER_ID=$(echo "$CUSTOMER_ID" | head -n -1 | tail -n +3)
  CUSTOMER_ID=$(echo $CUSTOMER_ID)
  CUSTOMER_NAME=$(echo "$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")" | head -n -1 | tail -n +3)
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME)
  # get service
  SERVICE=$(echo "$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")" | head -n -1 | tail -n +3)
  SERVICE=$(echo $SERVICE)
  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}


MAIN_MENU
