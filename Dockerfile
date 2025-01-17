#
# Build buggy-hash
#
FROM golang AS buggy-hash

WORKDIR /app

COPY go/* ./
RUN go build -o buggy-hash

#
# Build app
#
FROM node as base

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build application
COPY . .
RUN npm run build

#
# Final container
#
FROM node

WORKDIR /app

COPY --from=base --chown=nobody:nogroup /app/dist dist
COPY --from=base --chown=nobody:nogroup /app/public public
COPY --from=base --chown=nobody:nogroup /app/node_modules node_modules
COPY --from=buggy-hash --chown=nobody:nogroup /app/buggy-hash go/buggy-hash

USER nobody
EXPOSE 3000

ENTRYPOINT ["node", "dist/index.js"]
