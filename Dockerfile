# Stage 1: Build the application using Maven
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app

# Copy the pom.xml and source code from the finance-web-app folder
COPY finance-web-app/pom.xml finance-web-app/
COPY finance-web-app/src finance-web-app/src/

# Change to the sub-directory to build the project
WORKDIR /app/finance-web-app
RUN mvn clean package

# Stage 2: Deploy to Tomcat
FROM tomcat:9.0-jre8

# Remove default webapps to ensure our app runs at root or without conflicts
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file from the previous stage to Tomcat's webapps directory
COPY --from=build /app/finance-web-app/target/finance-web-app.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
