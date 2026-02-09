export const emailConfig = {
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  user: process.env.SMTP_USER,
  password: process.env.SMTP_PASSWORD,
  from: process.env.SMTP_FROM || "noreply@evcharging.com",
  secure: false, // true for 465, false for other ports
};

export default emailConfig;
