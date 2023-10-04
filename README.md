# JuLabDocker
Create Jupyter Lab Docker Image including commonly used libs

## Description
This is the default environment used at the MOM.
This is published:
https://hub.docker.com/repository/docker/svchb/surface_science_mom
To start:
docker run --name molab -p 8888:8888 --env="DISPLAY" -v "/notebooks:~/notebooks" -d svchb/surface_science_mom:v1
Navigate in a browser to:
http://localhost:8888/ and use password "root" to login.
