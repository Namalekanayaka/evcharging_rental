import db from "../../config/database.js";

export class PaymentService {
  // Process payment (mock)
  async processPayment(userId, data) {
    try {
      const { amount, bookingId, paymentMethod } = data;

      // Deduct from wallet
      const wallet = await db.one("SELECT * FROM wallets WHERE user_id = $1", [
        userId,
      ]);

      if (!wallet || wallet.balance < amount) {
        throw new Error("Insufficient wallet balance");
      }

      // Record payment
      const payment = await db.one(
        `INSERT INTO payments (user_id, booking_id, amount, payment_method, status)
         VALUES ($1, $2, $3, $4, 'completed')
         RETURNING *`,
        [userId, bookingId, amount, paymentMethod],
      );

      // Update wallet
      await db.query(
        "UPDATE wallets SET balance = balance - $1 WHERE user_id = $2",
        [amount, userId],
      );

      // Update booking status
      await db.query("UPDATE bookings SET status = $1 WHERE id = $2", [
        "confirmed",
        bookingId,
      ]);

      // Record transaction
      await db.query(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, 'debit', 'Booking payment')`,
        [userId, amount],
      );

      return payment;
    } catch (error) {
      throw error;
    }
  }

  // Get payment
  async getPayment(paymentId) {
    try {
      const payment = await db.one("SELECT * FROM payments WHERE id = $1", [
        paymentId,
      ]);
      return payment;
    } catch (error) {
      throw error;
    }
  }

  // Get user payments
  async getUserPayments(userId, limit = 20, offset = 0) {
    try {
      const payments = await db.query(
        `SELECT p.*, b.start_time, c.name as charger_name
         FROM payments p
         JOIN bookings b ON p.booking_id = b.id
         JOIN chargers c ON b.charger_id = c.id
         WHERE p.user_id = $1
         ORDER BY p.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return payments;
    } catch (error) {
      throw error;
    }
  }

  // Refund payment
  async refundPayment(paymentId) {
    try {
      const payment = await db.one("SELECT * FROM payments WHERE id = $1", [
        paymentId,
      ]);

      if (!payment) {
        throw new Error("Payment not found");
      }

      if (payment.status === "refunded") {
        throw new Error("Payment already refunded");
      }

      // Update payment status
      const refundedPayment = await db.one(
        "UPDATE payments SET status = $1 WHERE id = $2 RETURNING *",
        ["refunded", paymentId],
      );

      // Add refund to wallet
      const wallet = await db.one("SELECT * FROM wallets WHERE user_id = $1", [
        payment.user_id,
      ]);

      if (wallet) {
        await db.query(
          "UPDATE wallets SET balance = balance + $1 WHERE user_id = $2",
          [payment.amount, payment.user_id],
        );
      }

      // Record transaction
      await db.query(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, 'credit', 'Refund processed')`,
        [payment.user_id, payment.amount],
      );

      return refundedPayment;
    } catch (error) {
      throw error;
    }
  }
}

export default new PaymentService();
