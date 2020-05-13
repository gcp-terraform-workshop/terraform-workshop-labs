
```
docker run -p 8080:8080 -p 50000:50000 -v jenkins-volume:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock booth-jenkins
```