call mvnw -Pproduction clean package
docker build . -t bwajtr/vaadin-spring-boot-optimized-docker-layers-demo:latest
