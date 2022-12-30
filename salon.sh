#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MANU() {

    if [[ $1 ]]; then
        echo -e "\n$1\n"
    fi

    SERVICES_MENU
}

SERVICES_MENU() {

    if [[ $1 ]]; then
        echo -e "\n$1\n"
    fi

    # Get all services all display to the prompt
    ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$ALL_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
        echo -e "$SERVICE_ID) $SERVICE_NAME"
    done

    # Get service id from customer
    read SERVICE_ID_SELECTED

    # Check id exits in database or not
    IS_SERVICE_ID_SELECTED_EXTIS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if id does not exit send service menu again
    if [[ -z $IS_SERVICE_ID_SELECTED_EXTIS ]]; then
        SERVICES_MENU "I could not find that service. What would you like today?"
    else
        # if valid id then
        CUSTOMER_MENU $SERVICE_ID_SELECTED
    fi

}
CUSTOMER_MENU() {

    # Ask Customer Phone number
    echo -e "What's your phone number?\n"
    read CUSTOMER_PHONE

    # Check Phone number exits or not
    IS_CUSTOMER_PHONE_EXITS=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if Phone does not exits
    if [[ -z $IS_CUSTOMER_PHONE_EXITS ]]; then
        # Ask Customer Name
        echo -e "I don't have a record for that phone number. what's your name?\n"
        read CUSTOMER_NAME

        # Craete a new Customer
        NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

        if [[ $NEW_CUSTOMER == "INSERT 0 1" ]]; then
            APPOINTMENT_MENU $1 $CUSTOMER_PHONE $CUSTOMER_NAME
        fi

    else
        APPOINTMENT_MENU $1 $CUSTOMER_PHONE $CUSTOMER_NAME
    fi
}

APPOINTMENT_MENU() {
    # Sertice Name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")

    # Customer Name
    if [[ -z $3 ]]; then
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
        CUSTOMER_NAME=$3
    fi

    # Ask appointment time
    echo -e "What time would you like your$SERVICE_NAME, $CUSTOMER_NAME?/n"
    read SERVICE_TIME

    # Customer ID
    CUTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUTOMER_ID,$1,'$SERVICE_TIME')")

    if [[ $NEW_APPOINTMENT == "INSERT 0 1" ]]; then
        echo -e "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MANU "Welcome to My Salon, how can I help you?"
