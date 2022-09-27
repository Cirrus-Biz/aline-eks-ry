set +e

aws eks describe-cluster --name my-eks-ry 1>/dev/null 2>&1

status_code=$?

set -e

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

    echo 'export LBC_VERSION="v2.4.1"' >>  ~/.bash_profile
    echo 'export LBC_CHART_VERSION="1.4.1"' >>  ~/.bash_profile
    .  ~/.bash_profile
else
    echo "code is zero"
fi