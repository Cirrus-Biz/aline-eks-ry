echo "executing path modification..."

{
    LOADBALANCER=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | .["LoadBalancerArn"]')
    LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn ${LOADBALANCER} | jq -r '.Listeners[] | .["ListenerArn"]')

    aws elbv2 describe-rules   --listener-arn ${LISTENER_ARN} \
    | jq -r '.[] | .[:3] | .[] | .["RuleArn"]' > pathchanges.txt

    member_account=$(tail -3 pathchanges.txt | head -1)
    member_transaction=$(head -2 pathchanges.txt | tail +2)
    account_transaction=$(head -3 pathchanges.txt | tail +3)

    aws elbv2 modify-rule \
    --conditions Field=path-pattern,Values='/members/*/accounts'\
    --rule-arn $member_account

    aws elbv2 modify-rule \
    --conditions Field=path-pattern,Values='/members/*/transactions'\
    --rule-arn $member_transaction

    aws elbv2 modify-rule \
    --conditions Field=path-pattern,Values='/accounts/*/transactions'\
    --rule-arn $account_transaction
} 1>/dev/null 2>&1

echo "done!"
