# Stage 1: Build the application using Maven
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Build the WAR file
RUN mvn clean package

# Stage 2: Deploy to Tomcat
FROM tomcat:9.0-jre8
# Remove default webapps to ensure our app runs at root or without conflicts
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file from the previous stage to Tomcat's webapps directory
# Renaming to ROOT.war so it serves as the default application
COPY --from=build /app/target/finance-web-app.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
