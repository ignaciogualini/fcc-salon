#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $SERVICES ]]
  then
    echo -e "\nSorry, we´re not working at the moment."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
    do
      echo -e "$SERVICE_ID) $SERVICE"
    done
    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-4]$ ]]
    then
      MAIN_MENU "Insert another option."
    else

      echo -e "\nWhat's your phone number?\n"
      read CUSTOMER_PHONE
      SELECT_PHONE_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $SELECT_PHONE_NUMBER ]]
      then

        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT_PHONE_AND_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        SELECT_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

        SERVICE_NAME_FORMATTED=$(echo $SELECT_SERVICE | sed -E 's/^ | $//g')
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ | $//g')
        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?\n"
        read SERVICE_TIME
         
        SELECT_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
        INSERT_APPOINTMENT_DATA=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($SELECT_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        echo  "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

      else

        SELECT_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        CUSTOMER_NAME_FORMATTED=$(echo $SELECT_CUSTOMER_NAME | sed -E 's/^ | $//g')
        SELECT_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SERVICE_NAME_FORMATTED=$(echo $SELECT_SERVICE | sed -E 's/^ | $//g')

        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?\n"
        read SERVICE_TIME

        SELECT_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        INSERT_APPOINTMENT_DATA=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($SELECT_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

      fi
    fi
  fi

}

MAIN_MENU
