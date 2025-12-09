// Auto-detect environment: localhost or Docker
const isDocker =
  process.env.NODE_ENV === "production" || process.env.DOCKER_ENV === "true";

const ContextPathMap: any = isDocker
  ? new Map([
      ["auth", "auth-service:3001"], // Docker: use container names
      ["booking", "booking-service:3002"],
      ["user", "user-service:3003"],
      ["payment", "payment-service:3004"],
      ["notification", "notification-service:3005"],
    ])
  : new Map([
      ["auth", "127.0.0.1:3001"], // Localhost development
      ["booking", "127.0.0.1:3002"],
      ["user", "127.0.0.1:3003"],
      ["payment", "127.0.0.1:3004"],
      ["notification", "127.0.0.1:3005"],
    ]);

console.log(`🌐 Service mode: ${isDocker ? "Docker" : "Localhost"}`);

module.exports = {
  ContextPathMap,
};
