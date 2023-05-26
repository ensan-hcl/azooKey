#!/bin/bash

set -e

if ! command -v gdown &> /dev/null; then
  echo "gdown is not installed. Installing..."
  pip install gdown
fi

gdown --id 1ImBsHiZILYBYno4L0xvb0RfdXPKzeV_D --output Keyboard/latest_dic.zip

if [ -f "Keyboard/Dictionary" ]; then
  echo "Removing Source/Dictionary..."
  rm -r "Keyboard/Dictionary"
fi

echo "Extracting latest_dic.zip..."
unzip -o "Keyboard/latest_dic.zip" -d "Keyboard/"

rm Keyboard/latest_dic.zip


