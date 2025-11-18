# Step 1: Build

FROM eclipse-temurin:17 AS builder
RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/mario-baptista/cogsi2526-1211265-1250525-1250204.git /app

WORKDIR /app/CA2/Part2/GradleProject_Transformation

RUN chmod +x ./gradlew

RUN ./gradlew bootJar

CMD ["java", "-jar", "build/libs/GradleProject_Transformation.jar"]


# Step 2: Runtime
FROM eclipse-temurin:17

COPY --from=builder /app/CA2/Part2/GradleProject_Transformation/build/libs/GradleProject_Transformation.jar /app/app.jar

WORKDIR /app

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]