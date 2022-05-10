#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c" 

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Please pick a service: \n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) CUSTOMER_INFO_MENU "$SERVICE_ID_SELECTED" ;;
    2) CUSTOMER_INFO_MENU "$SERVICE_ID_SELECTED" ;;
    3) CUSTOMER_INFO_MENU "$SERVICE_ID_SELECTED" ;;
    4) CUSTOMER_INFO_MENU "$SERVICE_ID_SELECTED" ;;
    *) MENU "Selected service doesn't exist. Please pick again:" ;;
  esac
}

APPOINTMENT_INFO() {
    echo -e "\nPlease pick the desired time for the appointment: "
    # enter time of appointment
    read SERVICE_TIME
    # set appointment
    SET_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($1, $2, '$SERVICE_TIME')")
    APPOINTMENT_DETAILS=$($PSQL "SELECT services.name, appointments.time, customers.name FROM customers INNER JOIN appointments USING(customer_id) INNER JOIN services USING(service_id) where service_id = '$1' AND customer_id = '$2' AND time = '$SERVICE_TIME'")
    echo $APPOINTMENT_DETAILS | while read SERVICE BAR TIME BAR NAME
    do
      echo "I have put you down for a $SERVICE at $TIME, $NAME."
    done
}

CUSTOMER_INFO_MENU() {
  echo -e "\nPlease enter a phone number: "
  read CUSTOMER_PHONE
  EXISTING_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $EXISTING_CUSTOMER_PHONE ]]
  then
    # phone number does not exist
    echo -e "\nPlease enter your name:"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_INFO "$1" "$CUSTOMER_ID"
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_INFO "$1" "$CUSTOMER_ID"
  fi
}
MENU