
#!/bin/bash

SG_ID ="sg-0a18511945dbf7c97" # replace with your ID
AMI_ID ="ami-0055977a6e828a4f4"

for instance in $@
do
   instance_id = $( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].Instanceid' \
    --output text )

    if [ $instance == "frontend" ]; then
       IP = $(
             aws ec2 describe-instances \
             --instance-ids $instance_id \
             --query 'Reservations[].Instances[].PublicIpAddress' \
             --output.text 
        )
    else
        IP = $(
             aws ec2 describe-instances \
             --instance-ids $instance_id \
             --query 'Reservations[].Instances[].PrivateIpAddress' \
             --output.text 
        )
    fi    
done
    

