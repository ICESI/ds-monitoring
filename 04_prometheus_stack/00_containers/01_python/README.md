# Build, test and deploy commands

```
docker build -t d4n13lbc/python-prometheus:v0.0.1 .
docker run -d -p 5000:5000 d4n13lbc/python-prometheus:v0.0.1
curl localhost:5000/metrics
docker login
docker push d4n13lbc/python-prometheus:v0.0.1
```
