FROM node:18-slim as test

WORKDIR /usr/local/app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm test


FROM node:18-slim as production

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY --from=test /usr/local/app/node_modules ./node_modules
COPY --from=test /usr/local/app ./

ENV PORT 80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
