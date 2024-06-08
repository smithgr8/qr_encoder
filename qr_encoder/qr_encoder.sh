#!/bin/bash

if ! command -v qrencode &> /dev/null; then
    echo "qrencode command not found. Please install with brew"
    exit 1
fi

ui_create() {
echo You are about to create a QR code. Exit with control+C or enter text then hit enter.
echo 
echo "How many pixels used: (between 50 and 200 is recomended)"
read size
echo Enter the website URL: 
read text
echo 'Enter the filename (default file is .png)': 
read filename
create_qr $size $filename $text
}

create_qr() {
    local size="$1"
    local filename="$2.png"
    if [ -n "$3" ]; then
        text="$3"
    fi
    qrencode "$text" -o "$filename" -s "$size"
    echo "QR code has been created: $filename"
    exit 0
}

usage() {
    echo "Usage: $0 [option] <text/website> <file name>"
    echo
    echo "Options:"
    echo "  -h | --help     Display this help message"
    echo "  -m | --manual   Create the QR using the terminal UI"
    echo "  -l | --large    Size: 200 pixels"
    echo "  -m | --medium   Size: 100 pixels"
    echo "  -s | --small    Size: 50 pixels"
    echo
    echo "Text/Website(required):"
    echo "  The website or text that will become a QR code. If spaces are needed, use double quotation marks."
    echo
    echo "File name:"
    echo "  The last argument should be the file name wanted. Use quotations if spaces are needed."
    echo
    echo "Example:"
    echo "  $0 --help"
    echo "  $0 -s \"Hello World\" hello-world-text"
    echo "  $0 https://google.com"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

size=100  # default size
filename="qr_code-$(date +%T)"  # default filename

case "$1" in
    -m|--manual)
        ui_create
        ;;
    -l|--large)
        size=200
        shift
        ;;
    -m|--medium)
        size=100
        shift
        ;;
    -s|--small)
        size=50
        shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        ;;
esac

text="$1"

if [ ! -z "$2" ]; then
    filename="$2"
fi

# continue with script logic using $size, $text, $filename


create_qr $size $filename
