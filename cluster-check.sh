set +e

aws eks describe-cluster --name my-eks-ry 1>/dev/null 2>&1

status_code=$?

set -e

if [ $status_code -ne 0 ]; then 
    eksctl create cluster --name my-eks-ry --region us-east-1 --zones us-east-1a,us-east-1b --fargate --profile ry-eks
else
    echo "code is zero"
fi