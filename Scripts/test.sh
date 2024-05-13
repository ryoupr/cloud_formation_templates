echo "Fetching list of CloudFormation stacks without deletion protection..."
res=$(aws cloudformation describe-stacks --query "Stacks[?EnableTerminationProtection==\`false\` && StackStatus!='DELETE_COMPLETE'].StackName" --output text)

echo $res

IFS=' ' read -r -a stucks <<< "$res"

echo $stucks