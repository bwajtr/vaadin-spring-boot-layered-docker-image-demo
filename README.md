# Vaadin Spring Boot Layered Docker Image Demo

This demo shows how to dockerize Spring Boot Vaadin app (or actually any Spring Boot based app) "the proper way" - with a layered approach. 

## What means "the proper way"?

Please see  this [Creating Docker images with Spring Boot](https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1) blog post or [this tutorial on Baeldung](https://www.baeldung.com/docker-layers-spring-boot), which explains it nicely.
The basic idea of an optimal image is, that after the Spring Boot app is built, the mulitstage docker image build unpacks the executable jar using -Djarmode=layertools and 
copies the dependencies and classes to the final image one by one. The point here is that the libraries do not change so often as the application classes. So let's put the libs to a separate layer in the image and Docker can then cache that layer effectively.
Building the image this way will create more layers in it, making it more efficient and much easier to transport, because Docker can then move around (push, pull) only that layer which had really changed - typically only the layer with the application classes.

For example, in the scenario of this very simple Vaadin app, this reduced push size from 59Mb to only 6Mb. This can make a huge difference in Continuous Integration/Delivery.

> ⚠️ NOTE: The blog post above mentions to use LAYERED_JAR layout in maven plugin. However, that does not exist anymore. In the recent versions of Spring Boot you can omit the configuration of the plugin completely, because the layers are now added to the executable jar automatically, by default. For more info on layers see here: https://docs.spring.io/spring-boot/docs/current/maven-plugin/reference/htmlsingle/#packaging.layers

       
This is the Dockerfile used  this project:
                                             
```dockerfile
FROM eclipse-temurin:17.0.6_10-jdk-alpine as builder
WORKDIR application
ARG JAR_FILE=target/vaadin-spring-boot-optimized-docker-layers-demo-1.0-SNAPSHOT.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM eclipse-temurin:17.0.6_10-jdk-alpine
# Running applications with user privileges helps to mitigate some risks
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
EXPOSE 8080
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
```

To build the Docker production image run

```
.\build-docker-image.bat
```

Once the Docker image is correctly built, you can test it locally using

```
.\run-docker-image.bat
```

You can also push it to the GitHub repository by running the following command. Notice that only about 6Mb is pushed to the repository - that's thanks to the optimized layering of the image.

```
.\push-docker-iamge.bat
```
