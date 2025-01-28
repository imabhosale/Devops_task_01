# Use an OpenJDK base image
FROM openjdk:21-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file from the host machine to the container
COPY target/contactapi-0.0.1-SNAPSHOT.jar /app/contactapi.jar

# Expose the port on which your application will run
EXPOSE 8080

# Command to run the JAR file
ENTRYPOINT ["java", "-jar", "contactapi.jar"]
