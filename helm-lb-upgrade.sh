helm repo update

VPC_ID=$(aws eks describe-cluster \
        --name my-eks-ry \
        --query "cluster.resourcesVpcConfig.vpcId" \
        --output text)

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

helm upgrade -i aws-load-balancer-controller \
     eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=my-eks-ry \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller
    --set region=${AWS_REGION}
    --set vpcId=${VPC_ID}
    --set image.repository=744758641322.dkr.ecr.${AWS_REGION}.amazonaws.com/amazon/aws-load-balancer-controller

# helm upgrade -i aws-load-balancer-controller \
#     eks/aws-load-balancer-controller \
#     -n kube-system \
#     --set clusterName=my-eks-ry \
#     --set serviceAccount.create=false \
#     --set serviceAccount.name=aws-load-balancer-controller \
#     --set image.tag="${LBC_VERSION}" \
#     --set region=${AWS_REGION} \
#     --set vpcId=${VPC_ID} \
#     --version="${LBC_CHART_VERSION}"