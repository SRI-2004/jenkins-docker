FROM openjdk:17-jdk-slim
COPY target/rest-api-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
