FROM docker.io/eclipse-temurin:17

RUN apt-get update && apt-get install -y git

WORKDIR /app

COPY . /app

RUN chmod +x ./gradlew

RUN ./gradlew build

CMD ["./gradlew", "bootRun"]
