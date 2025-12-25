import { Request } from "express";
import axios from "axios";

const config = require("../config/service.address");
const ContextPathMap: Map<string, string> = config.ContextPathMap;

export class CustomError extends Error {
  error?: boolean;
  code?: string;
}

export class AuthenticationError extends Error {
  error?: boolean;
  code?: string;
  errorText?: string;

  constructor(code, message) {
    super(message);
    this.error = true;
    this.code = code;
    this.errorText = message;
  }
}

export const authenticate = async function (req: Request, next) {
  try {
    let jwtToken = req.header("authorization");
    if (!jwtToken)
      throw new AuthenticationError("MISSING_TOKEN", "Missing token");
    jwtToken = jwtToken?.split(" ")[1];
    if (!jwtToken)
      throw new AuthenticationError("MISSING_TOKEN", "Invalid token format");
    console.log("token ", jwtToken);

    const authenticationUrl: string = `http://${ContextPathMap.get(
      "id"
    )}/authenticate`;
    console.log("---------------");
    console.log(authenticationUrl);
    try {
      const response = await axios.post(
        authenticationUrl,
        { jwtToken: jwtToken },
        {
          validateStatus: function (status) {
            return status < 500; // Resolve only if the status code is less than 500
          },
        }
      );
      if (response.status === 200) {
        console.log(response.data);
        return response.data["result"];
      } else if (response.status === 401) {
        throw new AuthenticationError(
          "AUTHENTICATION_INVALID",
          "Authentication invalid"
        );
      } else {
        throw new AuthenticationError(
          "CANNOT_AUTHENTICATE",
          "Cannot authenticate"
        );
      }
    } catch (error) {
      console.log(`ERROR received from ${authenticationUrl}: ${error}\n`);
      next(error);
    }
  } catch (e) {
    next(e);
  }
  return null;
};
