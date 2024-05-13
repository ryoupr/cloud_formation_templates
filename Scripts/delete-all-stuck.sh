#!/bin/zsh

# スタック情報を取得（削除保護が無効なスタックのみ）
echo "Fetching list of CloudFormation stacks without deletion protection..."
res=$(aws cloudformation describe-stacks --query "Stacks[?EnableTerminationProtection==\`false\` && StackStatus!='DELETE_COMPLETE'].StackName" --output text)

IFS=' ' read -r -a stucks <<< "$res"


# 削除対象のスタックがない場合の処理
if [ -z "$stacks" ]; then
  echo "No deletable stacks found."
  return 0
fi

echo "The following stacks will be deleted:"
echo "$stacks"

# ユーザーに確認を求める
echo -n "Are you sure you want to delete these stacks? (y/n) " 
read confirm
if [[ $confirm != [yY] ]]; then
  echo "Stack deletion cancelled."
  return 0
fi

# 各スタックを削除
for stack in $stacks; do
  echo "Deleting stack: $stack"
  aws cloudformation delete-stack --stack-name "$stack"

  # スタックの削除が完了するのを待つ
  echo "Waiting for the stack to be deleted..."
  aws cloudformation wait stack-delete-complete --stack-name "$stack"
  echo "Deleted stack: $stack"
done

echo "All specified stacks have been deleted."
