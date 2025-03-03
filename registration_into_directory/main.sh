#!/bin/bash

# Registration into Singer Directory
# This is a script that will take the csv of registrations, compare it to the current directory csv, and then add any new registrations to the directory.

# Goals:
# 1. Ensure that all new registrations are in the directory
# 2. Ensure that all existing registrations are in the directory
# 3. Check each field and only replace if necessary
# 4. Names should be in the same format
# 5. Emails will be the primary key
# 6. Phone numbers should be in the same format (XXX-XXX-XXXX)

# Idea:
# 1. Create a new directory csv
# 2. Create a new removed directory csv
# 3. Use registration csv to compare to compare to directory csv
# 4. Append new registrations to new directory csv
# 5. Append removed registrations to removed directory csv

# To Do:
# 1. Add logging
# 2. Add error handling
# 3. Map all headers from registration to directory
# 4. Add a check for duplicate emails, combine if necessary, or add to list of duplicates
# 5. Check for each email in registration to see if it is in the directory, if not append to the new directory csv
# 6. Check for each email in directory to see if it is in the registration, if not append to the "removed" directory csv

#!/bin/bash

# Set file names
REGISTRATION_HEADERS="Timestamp,Email Address,Score,First Name,Last Name,Phone.Address,City,Zip Code,Voice Part,What brings you to the Community Choir of Arizona this semester?,Besides CCAZ, when was the last time you sang in a choir?,How well do you read sheet music?,Instruments you would be willing to play in the concert: (check/list all that apply),About you (anything you'd like to share),I am available for (most) rehearsals on Tuesdays from 6:30-9pm,I am available for the concert on April 27, 2025,Do we have your permission to take photos or videos of you? The content would be used only to post to our social media and promote the choir.,\"At the Community Choir of Arizona, we believe the joy of singing should be for everyone. Your voice matters, and we're committed to ensuring that financial constraints never stand in the way of you joining us. Whether you're a seasoned performer or just love to sing in the shower, come be part of a welcoming community that celebrates music and connection.   A membership fee of \$50 will be collected at the first rehearsal of the semester.  If you need financial support, please select YES below.\""
CLEAN_REG_HEADERS="Timestamp,Email,Name,Phone,Address,Zip,Voice,What_brings_you,Last_choir,Music_reading,Instruments,About,Rehearsal,Rehearsals,Concert,Photos,Scholarship"
ORIGINAL_REGISTRATION_FILE="files/registrations.csv"
REGISTRATION_FILE="$ORIGINAL_REGISTRATION_FILE".tmp
CLEAN_REG_FILE="clean_registrations.csv"
touch "$REGISTRATION_FILE"
cp "$ORIGINAL_REGISTRATION_FILE" "$REGISTRATION_FILE"
# Remove the header from the registration file
sed -i '' '1d' "$REGISTRATION_FILE"


createCleanRegistrationFile() {
    echo "$CLEAN_REG_HEADERS" > "$CLEAN_REG_FILE"
}

cleanTimestamp() {
    # Replace "/" with "-" in timestamp of registration file
    # Replace " " with "-" in timestamp of registration file
    > "timestamp.tmp"
    while read -r line; do
        if [[ "$line" == "$REGISTRATION_HEADERS" ]]; then
            continue
        fi
        date_str=$(echo "$line" | cut -d, -f1)
        date_str=${date_str////-}
        date_str=${date_str// /-}
        echo "$date_str" >> timestamp.tmp
    done < "$REGISTRATION_FILE"
}

cleanName() {
    # Ignore the header. Combine column 3 and 4 in CLEAN_REG_FILE. Check it should be a name with a space between first and last name
    # Check for not space at the end of last name
    > "names.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            # col4 is first name, col5 is last name
            # cut col4 and col5 from line, remove leading and trailing spaces, and combine with a space
            first_name=$(echo "$line" | cut -d, -f4 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ / /g')
            last_name=$(echo "$line" | cut -d, -f5 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g' | sed 's/ / /g')
            name="$first_name $last_name"
            echo $name >> "names.tmp"
        fi
    done < "$REGISTRATION_FILE"
}

cleanEmail() {
    # Check it is an email address, remove any spaces from the email address
    # Check for @ in email address
    # Check for . in email address
    # Check for no spaces in email address
    > "emails.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            email=$(echo "$line" | cut -d, -f2 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
            if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo $email >> "emails.tmp"
            else
                echo "Invalid email address: $email" >> "emails.tmp"
            fi
        fi
    done < "$REGISTRATION_FILE"
}

cleanPhone() {
    # Check it is a phone number, remove any spaces from the phone number
    # correct format is XXX-XXX-XXXX.
    > "phone.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            phone=$(echo "$line" | cut -d, -f6 | tr -cd '[:digit:]')
            if [[ "${#phone}" -eq 10 ]]; then
                phone="${phone:0:3}-${phone:3:3}-${phone:6:4}"
                echo $phone >> "phone.tmp"
            elif [[ "${#phone}" -eq 0 ]]; then
                echo "" >> "phone.tmp"
            else
                echo "Invalid phone number: $phone" >> "phone.tmp"
            fi
        fi
    done < "$REGISTRATION_FILE"
}

cleanAddress() {
    # Check it is an address, remove any spaces from the address
    > "address.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            # make sure everything is captured. Address should be surrounded by double quotes
            address=$(echo "$line" | cut -d, -f7 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
            address=$(echo $address | sed 's/"//g')
            echo $address >> "address.tmp"
        fi
    done < "$REGISTRATION_FILE"
}

cleanCity() {
    # Check it is a city, remove any spaces from the city
    # Correct format is capital first letter and lowercase rest of the letters
    > "city.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            # if empty, continue
            if [[ -z $(echo "$line" | cut -d, -f8 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g') ]]; then
                echo "none" >> "city.tmp"
                continue
            fi
            city=$(echo "$line" | cut -d, -f8 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
            city=$(echo $city | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));} 1')
            # if city contains a number, shift the row to the left and try the next column
            if [[ $city =~ [0-9] ]]; then
                city=$(echo "$line" | cut -d, -f9 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
                city=$(echo $city | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));} 1')
            fi
            # remove double quotes from city
            city=$(echo $city | sed 's/"//g')
            # check capitalization
            if [[ $city != [A-Z]* ]]; then
                city=$(echo $city | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));} 1')
            fi
            echo $city >> "city.tmp"
        fi
    done < "$REGISTRATION_FILE"
}

cleanZip() {
    # Check it is a zip code, remove any spaces from the zip code
    # Correct format is XXXXX or XXXXX-XXXX, only numbers
    > "zip.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            zip=$(echo "$line" | cut -d, -f9 | tr -cd '[:digit:]')
            if [[ "${#zip}" -eq 5 ]]; then
                echo $zip >> "zip.tmp"
            elif [[ "${#zip}" -eq 9 ]]; then
                zip="${zip:0:5}"
                echo $zip >> "zip.tmp"
            elif [[ "${#zip}" -eq 0 ]]; then
                # check next column
                zip=$(echo "$line" | cut -d, -f10 | tr -cd '[:digit:]')
                if [[ "${#zip}" -eq 5 ]]; then
                    echo $zip >> "zip.tmp"
                elif [[ "${#zip}" -eq 9 ]]; then
                    zip="${zip:0:5}"
                    echo $zip >> "zip.tmp"
                else
                    echo "00000" >> "zip.tmp"
                fi
            else
                echo "$zip" >> "zip.tmp"
            fi
        fi
    done < "$REGISTRATION_FILE"
}

cleanVoicePart() {
    # Voice parts: Soprano, Alto, Tenor, Bass, "Not sure"
    # Put this column in quotes
    # Multiple voice parts should be separated by a comma
    # Format" "Soprano, Alto", or "Tenor", or "Bass, Not sure"
    > "voice.tmp"
    while read -r line; do
        if [[ "$line" != "$CLEAN_REG_HEADERS" ]]; then
            voice=$(echo "$line" | cut -d, -f10 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
            # if voice does not contain one of the options, shift the row to the left and try the next column
            if [[ $voice != "Soprano" && $voice != "Alto" && $voice != "Tenor" && $voice != "Bass" && $voice != "Not sure" ]]; then
                voice=$(echo "$line" | cut -d, -f11 | tr -d , | sed 's/^ *//g' | sed 's/ *$//g')
            fi
            voice=$(echo $voice | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));} 1')
            voice=$(echo $voice | sed 's/"//g')
            echo "$voice" >> "voice.tmp"
        fi
    done < "$REGISTRATION_FILE"
}

deleteColumnScore() {
    # Delete the column with header "score" and shift all rows to the left
    sed -i '' 's/,[^,]*//2' "$REGISTRATION_FILE"
}

compileCleanRows() {
    # from files timsstamp.tmp, names.tmp, combine the rows from each file and write to CLEAN_REG_FILE
    paste -d, emails.tmp names.tmp phone.tmp address.tmp city.tmp zip.tmp voice.tmp > "$CLEAN_REG_FILE"
}

copyRegistrationFile() {
    cp "$REGISTRATION_FILE" "$CLEAN_REG_FILE"
    sed -i '' "1s/.*/$CLEAN_REG_HEADERS/" "$CLEAN_REG_FILE"
}

main() {
    case "$1" in
        -1 | --delete-column-score)
            deleteColumnScore
            ;;
        -2 | --create-clean-registration-file)
            createCleanRegistrationFile
            exit 0
            ;;
        -3 | --copy-registration-file)
            copyRegistrationFile
            ;;
        -4 | --clean-timestamp)
            cleanTimestamp
            ;;
        -5 | --clean-name)
            cleanName
            ;;
        -c |--clean-email)
            cleanEmail
            ;;
        -ph | --clean-phone)
            cleanPhone
            ;;
        -ad | --clean-address)
            cleanAddress
            ;;
        -ci | --clean-city)
            cleanCity
            ;;
        -zip | --clean-zip)
            cleanZip
            ;;
        -v | --clean-voice-part)
            cleanVoicePart
            ;;
        -6 | --compile-clean-rows)
            compileCleanRows
            ;;
        -7 | --remove-header)
            removeHeader
            ;;
        -h | --help)
            echo "Usage: $0 [OPTION]"
            echo "Options:"
            echo "  --delete-column-score            Delete the column with header 'score'"
            echo "  --create-clean-registration-file Create a clean registration file"
            echo "  --copy-registration-file         Copy the registration file"
            echo "  --clean-timestamp                Clean the timestamp"
            echo "  --clean-name                     Clean the name"
            echo "  --compile-clean-rows             Compile the clean rows"
            echo "  --remove-header                  Remove the header"
            echo "  --help                           Display this help message"
            ;;
        *)
            echo "Invalid option. Use --help for available options."
            exit 1
            ;;
    esac
}

main "$@"

