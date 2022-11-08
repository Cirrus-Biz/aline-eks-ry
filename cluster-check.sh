set +e
EKS_STACK = "eksctl-my-eks-ry-cluster"

aws cloudformation describe-stacks --stack-name=${EKS_STACK} > stack.txt 2>&1

stack_code=$?

aws eks describe-cluster --name my-eks-ry 1>/dev/null 2>&1

status_code=$?

set -e

if [ $stack_code -ne 0 ]; then
    if [ $status_code -ne 0 ]; then 
        eksctl create cluster --name my-eks-ry --region us-east-1 --zones us-east-1a,us-east-1b --fargate --profile ry-eks

        eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=my-eks-ry --approve

        eksctl create iamserviceaccount \
        --cluster=my-eks-ry \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name "AmazonEKSLoadBalancerControllerRole" \
        --attach-policy-arn=arn:aws:iam::744758641322:policy/AWSLoadBalancerControllerIAMPolicy \
        --approve
    else
        echo "code is zero"
    fi
else
    # Status check vars
    STATUS="`grep -m 1 "StackStatus" stack.txt`"
    CREATE="CREATE_IN_PROGRESS"
    UPDATE="UPDATE_IN_PROGRESS"
    ROLLBACK="UPDATE_ROLLBACK_IN_PROGRESS"
    DELETE="DELETE_IN_PROGRESS"

    if echo ${STATUS} | grep ${CREATE};then
        aws cloudformation wait stack-create-complete --stack-name=${STACK}
    elif echo ${STATUS} | grep ${UPDATE};then
        aws cloudformation wait stack-update-complete --stack-name=${STACK}
    elif echo ${STATUS} | grep ${ROLLBACK};then
        aws cloudformation wait stack-rollback-complete --stack-name=${STACK}
    elif echo ${STATUS} | grep ${DELETE};then
        aws cloudformation wait stack-delete-complete --stack-name=${STACK}
    else
        echo "No stack activity in progress!  You are clear to deploy"
    fi
fi

