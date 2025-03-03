### Registration into Singer Directory

This is a script that will take the csv of registrations, compare it to the current directory csv, and then add any new registrations to the directory.

Goals:
1. Ensure that all new registrations are in the directory
2. Ensure that all existing registrations are in the directory
3. Check each field and only replace if necessary
4. Names should be in the same format
5. Emails will be the primary key
6. Phone numbers should be in the same format (XXX-XXX-XXXX)

Idea:
1. Create a new directory csv
2. Create a new removed directory csv
3. Use registration csv to compare to compare to directory csv
4. Append new registrations to new directory csv
5. Append removed registrations to removed directory csv

To Do:
1. Add logging
2. Add error handling
3. Map all headers from registration to directory
4. Add a check for duplicate emails, combine if necessary, or add to list of duplicates
5. Check for each email in registration to see if it is in the directory, if not append to the new directory csv
6. Check for each email in directory to see if it is in the registration, if not append to the "removed" directory csv


The expected files are:

- registrations.csv
- singer_directory.csv
- new_directory.csv
- removed_directory.csv
