# Use the official Node.js 18 image as base
# npm WARN EBADENGINE package: 'vite@5.2.8'
# npm WARN EBADENGINE required: { node: '^18.0.0 || >=20.0.0' }
FROM node:18

# Set the working directory in the container
WORKDIR /app/Server

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Expose port 5000
EXPOSE 3000

# Run the start script defined in package.json
CMD ["npm", "start"]

