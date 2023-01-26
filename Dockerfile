# Based on this blog post https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1
# and this tutorial https://www.baeldung.com/docker-layers-spring-boot
# The blog post above mentions to use LAYERED_JAR layout in maven plugin. However, that does not exist anymore. In the
# recent versions of Spring Boot you can omit the configuration of the plugin completely, because the layers are now added to the executable jar automatically, by default. For more info on layers see here: https://docs.spring.io/spring-boot/docs/current/maven-plugin/reference/htmlsingle/#packaging.layers

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
