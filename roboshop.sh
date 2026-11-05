
#!/bin/bash

SG_ID="sg-0a18511945dbf7c97"
AMI_ID="ami-0055977a6e828a4f4"
ZONE_ID="Z02847951R6DDEZ150FJO"
DOMAIN_NAME="daws88s.quest"

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ "$instance" = "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        RECORD_NAME ="$DOMAIN_NAME" # daws88s.quest    
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        RECORD_NAME = "$instance.$DOMAIN_NAME" # mongodb.daws88s.quest    
    fi

    echo "IP Address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
        {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                { "Value": "'$IP'" }
                ]
            }
            }
        ]
    }
    '

    echo "record updated for $instance"
    
done


