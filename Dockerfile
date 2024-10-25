FROM node:20-alpine AS base

FROM base AS builder

RUN apk add --no-cache gcompat
WORKDIR /app

COPY . ./

RUN npm ci && \
    npm run export && \
    npm prune --production


FROM base AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

RUN npm install express compression morgan @expo/server
COPY --from=builder --chown=nodejs:nodejs /app/dist /app/dist
COPY --from=builder --chown=nodejs:nodejs /app/server.js /app/server.js

USER nodejs
EXPOSE 3000

CMD ["node", "/app/server.js"]