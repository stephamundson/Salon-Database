#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?"
  echo -e "\n1) Cut\n2) Color\n3) Wash\n4) Exit"

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) CREATE_APPOINTMENT "Cut" ;;
    2) CREATE_APPOINTMENT "Color" ;;
    3) CREATE_APPOINTMENT "Wash" ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

CREATE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name='$1';")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi

  echo -e "\nWhat time for the appointment?"
  read SERVICE_TIME

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  # insert appointment
  INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  # get appointment info
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  echo $SERVICE_NAME
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | tr '[:upper:]' '[:lower:]' | sed 's/ |/"/') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU