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

# Заменяем ENTRYPOINT на CMD, чтобы можно было переопределить команду в docker-compose
# Скрипт ожидания всех хостов из WAIT_FOR_HOSTS
CMD ["sh", "-c", \
     "for host_port in $WAIT_FOR_HOSTS; do ./wait-for-it.sh \"$host_port\" -t 60; done && java -jar app.jar"]
