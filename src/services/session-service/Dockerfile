FROM maven:latest as build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:latest
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
COPY wait-for-it.sh .
RUN chmod +x wait-for-it.sh


CMD ["sh", "-c", \
     "for host_port in $WAIT_FOR_HOSTS; do ./wait-for-it.sh \"$host_port\" -t 60; done && java -jar app.jar"]
