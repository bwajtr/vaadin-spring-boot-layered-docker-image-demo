call mvnw -Pproduction clean package
docker build . -t [your github username here]/vaadin-spring-boot-layered-docker-image-demo:latest
