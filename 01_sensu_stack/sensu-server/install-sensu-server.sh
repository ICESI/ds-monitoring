yum install screen vim -y

echo '[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

yum install sensu -y
sensu-install -p sensu-plugin
sensu-install -p sensu-plugins-slack
su -c 'rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm'
yum install redis -y
service redis start
su -c 'rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.9/rabbitmq-server-3.6.9-1.el7.noarch.rpm'
yum install uchiwa -y
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload
service sensu-server restart & service sensu-api restart & service uchiwa restart
