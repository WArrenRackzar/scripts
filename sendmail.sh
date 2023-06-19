#!/bin/bash

# Prompt the user for database credentials
read -p "Enter database host: " db_host
read -p "Enter database port: " db_port
read -p "Enter database name: " db_name
read -p "Enter database username: " db_username
read -s -p "Enter database password: " db_password
echo

# Execute the query and retrieve results
query_results=$(PGPASSWORD=$db_password psql -h $db_host -p $db_port -d $db_name -U $db_username -c "SELECT * FROM users;")

# Format the query results (example: CSV format)
formatted_results=$(echo "$query_results" | sed 's/|/,/g' | sed 's/ //g' | sed 's/-+/,/g' | sed 's/(//g' | sed 's/)//g')

# Prompt the user for email details
read -p "Enter sender's email address: " sender_email
read -p "Enter recipient's email address: " recipient_email
read -p "Enter email subject: " email_subject
read -p "Enter optional message: " email_message

# Compose the email content
email_content="Subject: $email_subject\nFrom: $sender_email\nTo: $recipient_email\n\n$email_message\n\n$formatted_results"

# Send the email using the configured email client
echo -e "$email_content" | sendmail -t
