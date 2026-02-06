# syntax=docker/dockerfile:1.9

# --- Build Stage -----------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source and build the Flutter web bundle
COPY . .
RUN flutter config --enable-web \
    && flutter build web --release --base-href=/

# --- Runtime Stage ---------------------------------------------------------
FROM nginx:1.27-alpine

# Remove default Nginx site content and add Flutter build output
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose the default HTTP port
EXPOSE 80

# Use the default Nginx entrypoint/cmd
