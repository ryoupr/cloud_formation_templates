#!/bin/zsh

# スタック情報を取得（削除保護が無効なスタックのみ）
echo "Fetching list of CloudFormation stacks without deletion protection..."
json_data=$(aws cloudformation describe-stacks --query "Stacks[?EnableTerminationProtection==\`false\` && StackStatus!='DELETE_COMPLETE'].StackName" --output json)

echo $json_data

# jq を使って JSON から配列を取り出し、Zsh の配列に格納
stack_names=($(echo $json_data | jq -r '.[]'))


# 削除対象のスタックがない場合の処理
if [ -z "$stack_names" ]; then
  echo "No deletable stacks found."
  return 0
fi

echo "The following stacks will be deleted:"
echo "$stack_names"

# ユーザーに確認を求める
echo -n "Are you sure you want to delete these stacks? (y/n) " 
read confirm
if [[ $confirm != [yY] ]]; then
  echo "Stack deletion cancelled."
  return 0
fi

# 各スタックを削除
for stack in $stack_names; do
  echo "Deleting stack: $stack"
  aws cloudformation delete-stack --stack-name "$stack"

  # スタックの削除が完了するのを待つ
  echo "Waiting for the stack to be deleted..."
  aws cloudformation wait stack-delete-complete --stack-name "$stack"
  echo "Deleted stack: $stack"
done

echo "All specified stacks have been deleted."
