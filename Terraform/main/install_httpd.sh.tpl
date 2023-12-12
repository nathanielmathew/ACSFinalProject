#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h3>This project was built by:</h3>
  <ol>
        <li>Nathaniel Ryan Mathew</li>
        <li>Erick Gerardo Cardiel Gonzalez</li>
        <li>Soham Khandare</li>
        <li>Anirban Bose</li>
        <li>Lamiya Rahman</li>
        <img src="https://ecs-demogo-pictures.s3.ap-northeast-2.amazonaws.com/web/web/img/ilovecats.jpg" alt="Cats" width="500" height="500">
        <img src="https://ecs-demogo-pictures.s3.ap-northeast-2.amazonaws.com/web/web/img/ilovedogs.jpg" alt="Dogs" width="500" height="500">"  >  /var/www/html/index.html

sudo systemctl start httpd
sudo systemctl enable httpd
