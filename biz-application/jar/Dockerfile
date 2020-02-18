FROM openjdk:8-jdk-alpine

COPY . .

CMD ["java", "-jar", "-Dspring.config.location=bootstrap.yml", "biz-application-0.0.1-SNAPSHOT.jar"]

EXPOSE 9001
