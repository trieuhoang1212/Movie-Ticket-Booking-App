import express, { Request, Response, NextFunction } from "express";
import { AuthenticationError } from "./authentication/authentication.service";
import { ErrorResponse } from "./errorHandler/errorModel";
import { CacheService } from "./cache/cache.service";
import dotenv from "dotenv";

dotenv.config();

const proxy = require("express-http-proxy");
const config = require("./config/service.address");
const authenticationService = require("./authentication/authentication.service");

const ContextPathMap: Map<string, string> = config.ContextPathMap;
const cacheService = new CacheService();

const applyingCacheUrls: Array<string> = [
  "/api/booking/movies",
  "/api/booking/showtimes",
];

const middlewares = {
  requireAuthentication: async function (
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    console.log(`Authenticating request: ${req.originalUrl}`);

    const publicEndpoints = [
      "/api/auth/login",
      "/api/auth/register",
      "/api/auth/firebase-login",
      "/api/booking/movies",
      "/api/booking/showtimes",
      "/api/user/health",
      "/health",
    ];

    const publicPrefixes = [
      "/api/booking",
      "/api/bookings",
      "/api/payment",
      "/api/auth",
    ];

    const isPublicEndpoint =
      publicEndpoints.some((e) => req.originalUrl.startsWith(e)) ||
      publicPrefixes.some((p) => req.originalUrl.startsWith(p));

    if (isPublicEndpoint) {
      return next();
    }

    try {
      const authenData = await authenticationService.authenticate(req);
      req.headers["__user_info"] = JSON.stringify(authenData);
      next();
    } catch (error) {
      next(error);
    }
  },

  logger: function (req: Request, res: Response, next: NextFunction) {
    console.log(
      `[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`,
    );
    next();
  },

  caching: function (req: Request, res: Response, next: NextFunction) {
    const path = req.url.split("?")[0];
    if (!applyingCacheUrls.includes(path)) return next();

    const cachedValue = cacheService.getCache(req.url, req.method);
    if (cachedValue) {
      console.log("⚡ Cache hit:", req.url);
      return res.json(cachedValue);
    }
    next();
  },

  errorHandler: function (
    err: any,
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    console.error("🔥 Error:", err);

    if (res.headersSent) return next(err);

    if (err instanceof AuthenticationError) {
      return res.status(401).json(err);
    }

    const errorBody: ErrorResponse = {
      error: true,
      code: "INTERNAL_ERROR",
      message: "Internal server error",
    };
    res.status(500).json(errorBody);
  },
};

const app = express();
const PORT = process.env.PORT || 3004;

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// ====== GLOBAL MIDDLEWARE ======
app.use(
  middlewares.requireAuthentication,
  middlewares.logger,
  middlewares.caching,
);

// ====== PROXY CONFIG ======
console.log("Routing config:", ContextPathMap);

for (const [key, value] of ContextPathMap.entries()) {
  app.use(
    `/api/${key}`,
    proxy(value, {
      proxyReqOptDecorator: function (proxyReqOpts, srcReq) {
        proxyReqOpts.headers = {
          ...proxyReqOpts.headers,
          ...srcReq.headers,
        };
        return proxyReqOpts;
      },

      userResDecorator: function (proxyRes, proxyResData, userReq) {
        const path = userReq.originalUrl.split("?")[0];
        if (applyingCacheUrls.includes(path)) {
          const cacheValue = JSON.parse(proxyResData.toString("utf8"));
          cacheService.addRouteCache(
            userReq.originalUrl,
            userReq.method,
            cacheValue,
          );
        }
        return proxyResData;
      },
    }),
  );
}

// Alias route
app.use(
  "/api/bookings",
  proxy(ContextPathMap.get("booking"), {
    proxyReqOptDecorator: function (proxyReqOpts, srcReq) {
      proxyReqOpts.headers = {
        ...proxyReqOpts.headers,
        ...srcReq.headers,
      };
      return proxyReqOpts;
    },
  }),
);

// ====== HEALTH CHECK ======
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    service: "api-gateway",
    timestamp: new Date().toISOString(),
  });
});

// ====== ERROR HANDLER (LUÔN Ở CUỐI) ======
app.use(middlewares.errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 API Gateway running on port ${PORT}`);
});
