## Monitoreo con el stack ELK

### Instalación del stack ELK (Servidor)

A continuación se detalla el proceso de instalación del stack ELK en un solo nodo. Se sugiere emplear como mínimo 2G de RAM
en la máquina virtual. Tener en cuenta que para obtener las direcciones de los repositorios debe ir a la sección **downloads** de la página oficial de elastic y seleccionar la tecnología a instalar (elasticsearch, logstash, kibana ó filebeat).

```
Download and unzip Elasticsearch
Note 
Elasticsearch can also be installed from our package repositories using apt or yum. See Repositories in the Guide.
```

Instalar el openjdk de Java
```
yum install java-1.8.0-openjdk.x86_64
```

Descargar e instalar la llave pública
```
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

Crear el archivo con el repositorio de **elasticsearch**
```
vi /etc/yum.repos.d/elasticsearch.repo
```

```
[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Instalar elasticsearch
```
yum install elasticsearch
```

Crear el archivo con el repositorio de **logstash**
```
vi /etc/yum.repos.d/logstash.repo
```

```
[logstash-5.x]
name=Elastic repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Instalar logstash
```
yum install logstash
```

Crear el archivo con el repositorio de **kibana**
```
vi /etc/yum.repos.d/kibana.repo
```

```
[kibana-5.x]
name=Kibana repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Instalar kibana
```
yum install kibana
```

### Instalación de filebeat (Cliente)

Descargar e instalar la llave pública
```
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
```

Crear el archivo con el repositorio de **filebeat**
```
vi /etc/yum.repos.d/elastic.repo
```

```
[elastic-5.x]
name=Elastic repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Instalar filebeat
```
sudo yum install filebeat
```

Iniciar filebeat en el arranque
```
sudo chkconfig --add filebeat
```

### Ejemplo 0: Configuración inicial del stack

Las siguientes instrucciones se ejecutan teniendo en cuenta que la ip de acceso al servidor
es la 192.168.120.195. Si usted tiene una ip diferente, deberá realizar los ajustes respectivos.

Configurar elasticsearch para escuchar por una ip y puerto determinado
```
vi /etc/elasticsearch/elasticsearch.yml
```

```
# Set the bind address to a specific IP (IPv4 or IPv6):
network.host: 192.168.120.195
# Set a custom port for HTTP:
http.port: 9200
```

Abrir el puerto por donde escucha elasticsearch
```
firewall-cmd --zone=public --add-port=9200/tcp --permanent
firewall-cmd --reload
```

Puede comprobar la apertura del puerto teniendo elastisearch activo y ejecutando el siguiente comando:

```
ss -an | grep 9200
```

Configurar kibana para escuchar por una ip y puerto determinado
```
vi /etc/kibana/kibana.yml
```

```
# Kibana is served by a back end server. This setting specifies the port to use.
server.port: 5601
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: "192.168.120.195"
# The URL of the Elasticsearch instance to use for all your queries.
elasticsearch.url: "http://192.168.120.195:9200"
```

Abrir el puerto por donde escucha kibana
```
firewall-cmd --zone=public --add-port=5601/tcp --permanent
firewall-cmd --reload
```

Puede comprobar la apertura del puerto teniendo kibana activo y ejecutando el siguiente comando:

```
ss -an | grep 5601
```

Logstash emplea archivos de configuracion de acuerdo con cada cliente monitoreado


Iniciar los servicios
```
service kibana start & service elasticsearch start
```

Configurar los servicios para iniciar en el arranque del sistema operativo

```
systemctl enable kibana
systemctl enable elastisearch
```

Tenga en cuenta chequear el estado de los servicios, puertos y logs despues de la instalación en caso de encontrar algun error

### Ejemplo 1: Introducción corta a elasticsearch

Elastisearch tiene soporte Restful+JSON nativo. A continuación se mostraran algunas comandos básicos para almacenar y recuperar información de elasticsearch. En este ejemplo se asume que la dirección del servidor con el stack ELK es 192.168.56.101

<!--
Instalar el plugin sense
```
/opt/kibana/bin/kibana plugin --install elastic/sense
```
-->

Ejecute el siguiente comando para verificar el estado del servicio
```
curl http://192.168.120.195:9200 
```

El siguiente comando crea un indice con identificador **os** e inserta información de un usuario
```
curl -XPUT 'http://192.168.120.195:9200/os/user/daniel' -d '
{ 
    "username" : "daniel",
    "password" : "operativos"
}'
```

El siguiente comando inserta información
```
curl -XPUT 'http://192.168.120.195:9200/os/command/1' -d '
{
    "user": "daniel",
    "commandDateTime": "2011/12/15 23:10:11",
    "command": "ls -al" ,
    "directory": "/home/operativos"
}'
```

```
curl -XPUT 'http://192.168.120.195:9200/os/command/2' -d '
{
    "user": "daniel",
    "commandDateTime": "2011/12/15 23:10:11",
    "command": "ps -e" ,
    "directory": "/home/operativos"
}'
```

Los siguientes comandos permiten validar que las inserciones anteriores fueron correctas
```
curl -XGET 'http://192.168.120.195:9200/os/user/daniel?pretty=true'
curl -XGET 'http://192.168.120.195:9200/os/command/1?pretty=true'
```

El siguiente comando permite hacer una búsqueda de los comandos ejecutados por el usuario daniel
```
curl 'http://192.168.120.195:9200/os/command/_search?q=user:daniel&pretty=true'
```

El siguiente comando elimina los datos almacenados con el índice **os**
```
curl -XDELETE 'http://192.168.120.195:9200/os'
```

### Ejemplo 2: Cargando datos con curl directamente a elasticsearch y visualizando en kibana 

https://www.elastic.co/guide/en/kibana/current/getting-started.html  

### Ejemplo 3: Enviando un log de apache con filebeat hacia logstash

Crear la siguiente configuracion de filebeat en el cliente

```
vi /etc/filebeat/filebeat.yml
```

```
filebeat.prospectors:
- input_type: log
    - /var/log/httpd/access_log
    
#-------------------------- Elasticsearch output ------------------------------
#output.elasticsearch:
  # Array of hosts to connect to.
  # hosts: ["localhost:9200"]

#----------------------------- Logstash output --------------------------------
output.logstash:
  # The Logstash hosts
  hosts: ["192.168.120.195:5044"]
```

Ejecute el siguiente comando o active el demonio de filebeat

```
filebeat.sh -e -c filebeat.yml -d "publish"
```

Crear la siguiente configuración de logstash en el servidor

```
vi /etc/logstash/conf.d/apache-logstash.conf
```

```
input {
    beats {
        port => "5044"
    }
}
# The filter part of this file is commented out to indicate that it is
# optional.
filter {
}
output {
    stdout { codec => rubydebug }
}
```

Valide la configuración del archivo por medio del siguiente comando
```
/opt/logstash/bin/logstash -f apache-logstash.conf --configtest
```

Ejecute el demonio de logstash con el archivo de configuración
```
/opt/logstash/bin/logstash -f apache-logstash.conf
```

### Ejemplo 4: Enviando un log de apache con filebeat hacia logstash-kibana


```
vi /etc/logstash/conf.d/apache-logstash.conf
```

```
input {
    beats {
        port => "5044"
    }
}
# The filter part of this file is commented out to indicate that it is
# optional.
filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
}
output {
    elasticsearch {
        hosts => [ "localhost:9200" ]
    }
}
```

Valide la configuración del archivo por medio del siguiente comando
```
/opt/logstash/bin/logstash -f apache-logstash.conf --configtest
```

Ejecute el demonio de logstash con el archivo de configuración
```
/opt/logstash/bin/logstash -f apache-logstash.conf
```

### Referencias
https://github.com/elastic/examples/tree/master/ElasticStack_apache  
http://www.elasticsearchtutorial.com/elasticsearch-in-5-minutes.html  
http://grokdebug.herokuapp.com/  
https://www.elastic.co/guide/en/kibana/current/getting-started.html  
https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html  
https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html  

### Issues
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
WARNING: Could not find logstash.yml which is typically located in $LS_HOME/config or /etc/logstash. You can specify the path using --path.settings. Continuing using the defaults

