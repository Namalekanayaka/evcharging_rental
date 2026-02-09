export const jwtConfig = {
  secret: process.env.JWT_SECRET || "your_super_secret_key",
  refreshSecret: process.env.JWT_REFRESH_SECRET || "your_refresh_secret",
  expiresIn: process.env.JWT_EXPIRE || "7d",
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRE || "30d",
};

export default jwtConfig;
