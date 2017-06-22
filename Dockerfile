FROM openjdk:8-jdk-alpine
ENTRYPOINT [ "sh", "-c", "java -jar /application.jar $@"]
ADD target/application.jar /application.jar
RUN sh -c "touch /application.jar"