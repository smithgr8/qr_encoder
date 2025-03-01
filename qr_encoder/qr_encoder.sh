#!/bin/bash

# Check if qrencode is installed
if ! command -v qrencode &> /dev/null; then
    echo "qrencode command not found. Please install"
    exit 1
fi

# Prompt for inputs - URL and Filename
echo You are about to create a QR code. Exit with control+C or enter text then hit enter.
echo 
echo The file will be in your downloads folder.
echo
cd
cd Downloads/
echo Enter the website URL: 
read website
echo 'Enter the filename (default file is .png)': 
read filename

#if filename does not end with .png, append .png
if [[ $filename != *.png ]]; then
    filename=$filename.png
fi  

# If filename is empty, assign 
if [ -z "$filename" ]; then
    filename=$website
fi

# Take arguments and create QR code, size 50
qrencode $website -o $filename -s 50