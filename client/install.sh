sudo yum install screen vim -y

echo '[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

yum install sensu -y
sensu-install -p sensu-plugin
yum install httpd -y
service sensu-client start
