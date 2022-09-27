aws eks describe-cluster --name my-eks-ry 1>/dev/null 2>&1

status_code="$?"

if [ $status_code == "0" ]; then 
    echo "code is zero"
else
    echo "code is not zero"
fi