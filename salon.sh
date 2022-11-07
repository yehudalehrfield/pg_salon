#!/bin/bash

# PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
PSQL="psql -X --username=salon_manager --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to the Bash Salon ~~~~~\n"

BOOK_APPT() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nThese are our services:\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # prompt for a service
  echo -e "\nPlease select a service, by number, or 0 to exit:\n"

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # echo $SERVICE_ID_SELECTED $SERVICE_NAME

  
  # if 0 is selected (exit)
  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then
    echo "Thanks for stopping in. Have a good day."
  # if service does not exist 
  elif [[ -z $SERVICE_NAME ]]
  then
    # list services again with message of invalid entry
    BOOK_APPT "That is not a valid entry!"
  # else (service exists)
  else
    # prompt for phone number
    echo -e "\nWhat is your phone number?\n"
    read CUSTOMER_PHONE
    # check for existing customer
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if phone number doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # prompt for name
      # echo -e "\nThe number $CUSTOMER_PHONE does not exist in our system."
      echo -e "\nWhat is your name?\n"
      read CUSTOMER_NAME
      # insert into customers table
      INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi
    # prompt for time
    echo -e "\nWhat time would you like to book your appointment for?\n"
    read SERVICE_TIME
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # test
    # insert into appointments
    INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # output message with name of service, namd of customer
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED.\n"
  fi
}

BOOK_APPT