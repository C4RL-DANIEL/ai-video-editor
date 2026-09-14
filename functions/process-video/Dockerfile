FROM appwrite/executor:node-18.0

WORKDIR /usr/local/src

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy source code
COPY . .

# Set environment variables
ENV NODE_ENV=production

# The function will be executed by the Appwrite executor
CMD ["node", "src/index.js"]