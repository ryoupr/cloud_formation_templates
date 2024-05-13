# スタック情報を取得（削除保護が無効なスタックのみ）
echo "Fetching list of CloudFormation stacks without deletion protection..."
json_data=$(aws cloudformation describe-stacks --query "Stacks[?EnableTerminationProtection==\`false\` && StackStatus!='DELETE_COMPLETE'].StackName" --output json)

echo $json_data

# jq を使って JSON から配列を取り出し、Zsh の配列に格納
stack_names=($(echo $json_data | jq -r '.[]'))
