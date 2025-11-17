FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Copy the Flutter project
COPY . .

# Get dependencies
RUN flutter pub get

# Expose the port
EXPOSE 4200

# Run the Flutter web server
CMD ["flutter", "run", "-d", "web-server", "--web-port=4200", "--web-hostname=0.0.0.0"]