echo -n "CFn template yml file path : "
read file_path


if [[ $file_path != *.yml ]]; then
  echo "Error: File name must end with '.yml'."
  exit 1
fi

#!/bin/bash

# Get the filename from the argument
filename="$file_path"

# Remove the .yml extension using basename command
base=$(basename "$filename" .yml)

# Generate a random string of 8 characters (consisting of letters and numbers)
random_str=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 8)

# Output the result
stuck_name="${base}-${random_str}"


# create stuck.
aws cloudformation create-stack --stack-name $stuck_name --template-body file://${file_path}  --no-cli-pager
aws cloudformation wait stack-create-complete --stack-name $stuck_name
echo "Waiting for the stack to be created..."