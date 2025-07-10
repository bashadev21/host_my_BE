# Use Dart's official image
FROM dart:stable

# Create app directory
WORKDIR /app

# Copy pubspec and run pub get
COPY pubspec.* ./
RUN dart pub get

# Copy the rest of the code
COPY . .

# Compile the server to native executable
RUN dart compile exe lib/shelf_core_example.dart -o lib/server

# Set port for Render
ENV PORT=8080

# Run the server
CMD ["lib/server"]
