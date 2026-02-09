import db from "../../config/database.js";

export class WalletService {
  // Get wallet
  async getWallet(userId) {
    try {
      const wallet = await db.oneOrNone(
        "SELECT * FROM wallets WHERE user_id = $1",
        [userId],
      );

      if (!wallet) {
        // Create wallet if doesn't exist
        return await db.one(
          "INSERT INTO wallets (user_id, balance) VALUES ($1, 0) RETURNING *",
          [userId],
        );
      }

      return wallet;
    } catch (error) {
      throw error;
    }
  }

  // Add balance
  async addBalance(userId, amount, transactionType = "credit") {
    try {
      let wallet = await this.getWallet(userId);

      if (transactionType === "credit") {
        wallet = await db.one(
          "UPDATE wallets SET balance = balance + $1 WHERE user_id = $2 RETURNING *",
          [amount, userId],
        );
      }

      // Record transaction
      const transaction = await db.one(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, $3, 'Balance added')
         RETURNING *`,
        [userId, amount, transactionType],
      );

      return { wallet, transaction };
    } catch (error) {
      throw error;
    }
  }

  // Deduct balance
  async deductBalance(userId, amount) {
    try {
      const wallet = await this.getWallet(userId);

      if (wallet.balance < amount) {
        throw new Error("Insufficient wallet balance");
      }

      const updatedWallet = await db.one(
        "UPDATE wallets SET balance = balance - $1 WHERE user_id = $2 RETURNING *",
        [amount, userId],
      );

      // Record transaction
      const transaction = await db.one(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, 'debit', 'Balance deducted')
         RETURNING *`,
        [userId, amount],
      );

      return { wallet: updatedWallet, transaction };
    } catch (error) {
      throw error;
    }
  }

  // Get transactions
  async getTransactions(userId, limit = 20, offset = 0) {
    try {
      const transactions = await db.query(
        `SELECT * FROM wallet_transactions 
         WHERE user_id = $1 
         ORDER BY created_at DESC 
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return transactions;
    } catch (error) {
      throw error;
    }
  }

  // Transfer balance
  async transferBalance(fromUserId, toUserId, amount) {
    try {
      const fromWallet = await this.getWallet(fromUserId);

      if (fromWallet.balance < amount) {
        throw new Error("Insufficient balance");
      }

      // Deduct from sender
      await db.query(
        "UPDATE wallets SET balance = balance - $1 WHERE user_id = $2",
        [amount, fromUserId],
      );

      // Add to receiver
      await db.query(
        "UPDATE wallets SET balance = balance + $1 WHERE user_id = $2",
        [amount, toUserId],
      );

      // Record transactions
      await db.query(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, 'debit', 'Transfer sent')`,
        [fromUserId, amount],
      );

      await db.query(
        `INSERT INTO wallet_transactions (user_id, amount, type, description)
         VALUES ($1, $2, 'credit', 'Transfer received')`,
        [toUserId, amount],
      );

      return { success: true, amount };
    } catch (error) {
      throw error;
    }
  }
}

export default new WalletService();
