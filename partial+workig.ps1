# Set the Record Name
$RecordName = "test.dakshin.com"

# Retrieve the metadata token
$Token = Invoke-RestMethod -Uri http://169.254.169.254/latest/api/token -Method PUT -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" }

# Retrieve the private IP address
$PrivateIpAddress = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/local-ipv4 -Headers @{ "X-aws-ec2-metadata-token" = $Token }

# Hosted Zone Name
$HostedZoneName = "dakshin.com"

# Retrieve the hosted zone ID
$HostedZoneId = aws route53 list-hosted-zones --query "HostedZones[?Name=='$HostedZoneName.'].Id" --output text

# Define the new record set parameters
$RecordType = "A"
$TTL = 300

# Create the DNS record using AWS CLI command directly
aws route53 change-resource-record-sets --hosted-zone-id $HostedZoneId --change-batch "
{
    \"Comment\": \"Creating a test record\",
    \"Changes\": [
        {
            \"Action\": \"CREATE\",
            \"ResourceRecordSet\": {
                \"Name\": \"$RecordName\",
                \"Type\": \"$RecordType\",
                \"TTL\": $TTL,
                \"ResourceRecords\": [
                    {
                        \"Value\": \"$PrivateIpAddress\"
                    }
                ]
            }
        }
    ]
}
"

# Output a confirmation message
Write-Host "DNS record $RecordName with value $PrivateIpAddress created successfully."
