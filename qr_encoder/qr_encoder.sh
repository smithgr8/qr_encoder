#!/bin/bash

if ! command -v qrencode &> /dev/null; then
    echo "qrencode command not found. Please install"
    exit 1
fi

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
qrencode $website -o $filename -s 50