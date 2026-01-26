// Auto-detect environment: localhost or Docker
const isDocker =
  process.env.NODE_ENV === "production" || process.env.DOCKER_ENV === "true";

// IMPORTANT: express-http-proxy requires FULL URL (with http://)
const ContextPathMap: Map<string, string> = isDocker
  ? new Map([
      ["auth", "http://auth-service:3001"], // Docker container name
      ["booking", "http://booking-service:3002"],
      ["user", "http://user-service:3003"],
      ["payment", "http://payment-service:3004"],
      ["notification", "http://notification-service:3005"],
    ])
  : new Map([
      ["auth", "http://127.0.0.1:3001"], // Local development
      ["booking", "http://127.0.0.1:3002"],
      ["user", "http://127.0.0.1:3003"],
      ["payment", "http://127.0.0.1:3004"],
      ["notification", "http://127.0.0.1:3005"],
    ]);

console.log(
  `🌐 Service mode: ${isDocker ? "Docker (container network)" : "Localhost"}`,
);

module.exports = {
  ContextPathMap,
};
