import { ApiError } from "../utils/errors.js";

export const roleMiddleware = (allowedRoles = []) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new ApiError(401, "Unauthorized"));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(
        new ApiError(
          403,
          `Access denied. Required roles: ${allowedRoles.join(", ")}`,
        ),
      );
    }

    next();
  };
};

export default roleMiddleware;
