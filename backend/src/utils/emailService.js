import nodemailer from "nodemailer";
import { emailConfig } from "../config/email.js";

let transporter = null;

if (emailConfig.user && emailConfig.password) {
  transporter = nodemailer.createTransport({
    host: emailConfig.host,
    port: emailConfig.port,
    secure: emailConfig.secure,
    auth: {
      user: emailConfig.user,
      pass: emailConfig.password,
    },
  });
}

export const sendEmail = async (to, subject, html) => {
  if (!transporter) {
    console.warn("Email service not configured");
    return null;
  }

  try {
    const info = await transporter.sendMail({
      from: emailConfig.from,
      to,
      subject,
      html,
    });
    return info;
  } catch (error) {
    console.error("Error sending email:", error);
    throw error;
  }
};

export const sendOTP = async (email, otp) => {
  const html = `
    <h2>EV Charging Rental - OTP Verification</h2>
    <p>Your OTP is: <strong>${otp}</strong></p>
    <p>This OTP expires in ${process.env.OTP_EXPIRY || 10} minutes</p>
  `;
  return sendEmail(email, "OTP Verification", html);
};

export const sendBookingConfirmation = async (email, bookingDetails) => {
  const html = `
    <h2>Booking Confirmation</h2>
    <p>Your booking has been confirmed!</p>
    <ul>
      <li>Charger: ${bookingDetails.chargerName}</li>
      <li>Date: ${new Date(bookingDetails.startTime).toLocaleDateString()}</li>
      <li>Duration: ${bookingDetails.duration} hours</li>
      <li>Amount: $${bookingDetails.amount}</li>
    </ul>
  `;
  return sendEmail(email, "Booking Confirmation", html);
};

export default sendEmail;
