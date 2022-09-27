aws eks describe-cluster --name my-eks-ry 1>/dev/null 2>&1

status_code=$?

if [ $status_code == 0 ]; then 
    echo "code is zero"
else
    eksctl create cluster --name my-eks-ry --region us-east-1 --zones us-east-1a,us-east-1b --fargate
fi