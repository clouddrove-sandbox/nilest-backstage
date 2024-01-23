#!/usr/bin/env bash

aws eks update-kubeconfig --name automated-eks-cluster --region us-east-1 
export KUBECONFIG=~/.kube/config
#----------------------------------------------
echo "Patching Ingresses..."
for each in $(kubectl get ingress -A | grep "80" | awk '{print $1}');
do
  kubectl patch ingress $(kubectl get ing -n $each | grep "80" | awk '{print $1}') -n $each -p '{"metadata":{"finalizers":[]}}' --type=merge
  kubectl delete ingress $(kubectl get ing -n $each | grep "80" | awk '{print $1}') -n $each
done

#----------------------------------------------
echo "Getting details of SecurityGroups created by Load Balancers..."
SecurityGroups=""
for each in $(aws elbv2 describe-load-balancers --region us-east-1 | jq -r '.LoadBalancers[]' | jq -r '.SecurityGroups[]');
do
  SecurityGroups+="$each "
done
#----------------------------------------------
echo "Deleting Load Balancers elbv2..."
for each in $(aws elbv2 describe-load-balancers --region us-east-1 | grep "LoadBalancerArn" | awk '{print $2}' | cut -d '"' -f2)
do
  aws elbv2 delete-load-balancer --load-balancer-arn $each --region us-east-1
done

echo "Deleting Classic Load Balancers..."
for each in $(aws elb describe-load-balancers --region us-east-1 | grep "LoadBalancerName" | awk '{print $2}' | cut -d'"' -f2)
do
  aws elb delete-load-balancer --load-balancer-name $each --region us-east-1
done

echo "Deleting Target Groups..."
for each in $(aws elbv2 describe-target-groups --region us-east-1 | grep "TargetGroupArn" | awk '{print $2}' | cut -d'"' -f2)
do
  aws elbv2 delete-target-group --target-group-arn $each --region us-east-1
done

#----------------------------------------------
echo "Deleting Security Groups created by Load Balancers..."
sleep 20
for each in $SecurityGroups;
do
  aws ec2 delete-security-group --region us-east-1 --group-id $each
done
