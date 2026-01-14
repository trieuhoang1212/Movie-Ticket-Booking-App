import express, { Request, Response, Application, NextFunction } from "express";
import { AuthenticationError } from "./authentication/authentication.service";
import { ErrorResponse } from "./errorHandler/errorModel";
import { CacheService } from "./cache/cache.service";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

const proxy = require("express-http-proxy");
const config = require("./config/service.address");

const authenticationService = require("./authentication/authentication.service");
const ContextPathMap: Map<string, string> = config.ContextPathMap;

const cacheService = new CacheService();
// Cache cho movies list và showtimes để giảm tải database
const applyingCacheUrls: Array<string> = [
  "/api/booking/movies",
  "/api/booking/showtimes",
];

const middlewares = {
  requireAuthentication: async function (req: Request, res: Response, next) {
    console.log(`Authenticating request: ${req.originalUrl}`);

    // Skip authentication cho public endpoints
    const publicEndpoints = [
      "/api/auth/login",
      "/api/auth/register",
      "/api/auth/firebase-login",
      "/api/booking/movies",
      "/api/booking/showtimes",
      "/api/user/health",
      "/health",
    ];

    // Patterns to match with startsWith (allow all sub-paths)
    const publicPrefixes = [
      "/api/booking", // Allow all booking operations (for development)
      "/api/bookings", // Alias for booking service
      "/api/payment", // Allow all payment operations (for development)
      "/api/auth", // Allow all auth operations including fcm-token
    ];

    const isPublicEndpoint =
      publicEndpoints.some((endpoint) =>
        req.originalUrl.startsWith(endpoint)
      ) || publicPrefixes.some((prefix) => req.originalUrl.startsWith(prefix));

    if (isPublicEndpoint) {
      console.log(`✅ Public endpoint, skipping authentication`);
      next();
    } else {
      try {
        // Gọi service không truyền next nữa
        const authenData = await authenticationService.authenticate(req);
        // set user information that authenticated
        console.log(`Authenticating...`, authenData);
        req.headers["__user_info"] = JSON.stringify(authenData);
        next();
      } catch (error) {
        // Bắt lỗi tại đây và DỪNG LẠI (return)
        next(error);
        return;
      }
    }
  },
  logger: function (req: Request, res: Response, next) {
    // Logging request, user, body, request...

    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.originalUrl}`);

    // Log user info if authenticated
    const userInfo = req.headers["__user_info"];
    if (userInfo) {
      try {
        const user = JSON.parse(userInfo as string);
        console.log(`  User: ${user.username || user.email || "unknown"}`);
      } catch (e) {
        // Ignore parse error
      }
    }

    // Log query params if present
    if (Object.keys(req.query).length > 0) {
      console.log(`  Query: ${JSON.stringify(req.query)}`);
    }

    // Log body for POST/PUT/PATCH (exclude sensitive fields)
    if (["POST", "PUT", "PATCH"].includes(req.method)) {
      const sanitizedBody = { ...req.body };
      // Remove sensitive fields from logs
      delete sanitizedBody.password;
      delete sanitizedBody.token;
      console.log(`  Body: ${JSON.stringify(sanitizedBody)}`);
    }

    next();
  },
  caching: function (req: Request, res: Response, next) {
    // console.log("Find cache ",req.url,req.method, cachedValue)
    if (!applyingCacheUrls.includes(req.url.split("?")[0])) {
      next();
    } else {
      const cachedValue = cacheService.getCache(req.url, req.method);
      if (cachedValue) {
        console.log("Found cache");
        res.json(cachedValue);
      } else {
        next();
      }
    }
  },
  errorHandler: function (err: any, req: Request, res: Response, next: any) {
    console.log("-- Going to handle exception --");
    console.log(err);

    if (res.headersSent) {
      return next(err);
    }

    if (err instanceof AuthenticationError) {
      res.status(401).json(err);
    } else {
      const errorBody: ErrorResponse = {
        error: true,
        code: "INTERNAL_ERROR",
        message: "Internal server error",
      };
      res.status(500).json(errorBody);
    }
    // KHÔNG gọi next() ở đây nữa vì đã gửi response rồi
  },
};

const app = express();

const PORT = process.env.PORT || 3000;

// Rate limiting disabled for development
// app.use(commonLimiter)
// common config
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// config middleware
app.use(`/`, [
  middlewares.requireAuthentication,
  middlewares.logger,
  middlewares.caching,
  middlewares.errorHandler,
]);

function onProxyRes(proxyResponse, request, response) {
  console.log("proxyResponse", proxyResponse.body);
  console.log("response", response.headers);
  cacheService.addRouteCache(request.url, request.method, proxyResponse.body);
}

// config routing
console.log("Routing config: ", ContextPathMap);
for (let [key, value] of ContextPathMap.entries()) {
  app.use(
    `/api/${key}`,
    proxy(`${value}`, {
      userResDecorator: function (proxyRes, proxyResData, userReq, userRes) {
        console.log(userReq.originalUrl);
        if (applyingCacheUrls.includes(userReq.originalUrl.split("?")[0])) {
          const cacheValue = JSON.parse(proxyResData.toString("utf8"));
          console.log("cacheValue ", userReq.originalUrl, proxyResData);
          cacheService.addRouteCache(
            userReq.originalUrl,
            userReq.method,
            cacheValue
          );
        }
        return proxyResData;
      },
    })
  );
}

app.use(
  "/api/bookings",
  proxy(`${ContextPathMap.get("booking")}`, {
    userResDecorator: function (proxyRes, proxyResData, userReq, userRes) {
      console.log(userReq.originalUrl);
      if (applyingCacheUrls.includes(userReq.originalUrl.split("?")[0])) {
        const cacheValue = JSON.parse(proxyResData.toString("utf8"));
        console.log("cacheValue ", userReq.originalUrl, proxyResData);
        cacheService.addRouteCache(
          userReq.originalUrl,
          userReq.method,
          cacheValue
        );
      }
      return proxyResData;
    },
  })
);

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    service: "api-gateway",
    timestamp: new Date().toISOString(),
  });
});

// app.use(handleError);
app.listen(PORT, (): void => {
  console.log(`API gateway server is running on port:${PORT}`);
});
