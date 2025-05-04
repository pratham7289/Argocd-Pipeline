# Use Node.js 18 slim base image to match the build environment on VM 2
FROM node:18-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if present) for dependency installation
COPY package*.json ./

# Install only production dependencies to keep the image lightweight
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Create a non-root user for security and switch to it
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose port 3000, standard for Express.js apps
EXPOSE 3000

# Start the application using the start script from package.json
CMD ["npm", "start"]
