# Build AdonisJS
FROM node:14-alpine as builder
# Workaround for now, since bodyparser install relies on Git
RUN apk add --no-cache git
# Set directory for all files
WORKDIR /home/node
# Copy over package.json files
COPY package*.json ./
# Install all packages
RUN npm install
# Copy over source code
COPY . .
# Build AdonisJS for production
RUN npm run build --production


# Build final runtime container
FROM node:14-alpine

# Disable .env file loading
ENV ENV_SILENT=true

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3333
ENV HOST=0.0.0.0
ENV APP_KEY=

# Use non-root user
USER node
# Make directory for app to live in
# It's important to set user first or owner will be root
RUN mkdir -p /home/node/app/
# Set working directory
WORKDIR /home/node/app
# Copy over required files from previous steps
# Copy over built files
COPY --from=builder /home/node/build ./
# Copy over node_modules
COPY --from=builder /home/node/node_modules ./node_modules
# Copy over package.json files
COPY package*.json ./
# Expose port 3333 to outside world
EXPOSE 3333
# Start server up
CMD [ "node", "./server.js" ]
