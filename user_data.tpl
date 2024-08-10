#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1> This is my journey to Devops with determination, I will succeed. $(hostname -f) in AZ $EC2_AVAIL_ZONE </h1>" > /var/www/html/index.html
