/**
 * Admin Service
 * Handles admin dashboard operations: user management, charger management,
 * revenue analytics, fraud detection, and content management
 */

class AdminService {
  constructor(db) {
    this.db = db;
  }

  /**
   * Get all users with filters
   */
  async getAllUsers(limit = 20, offset = 0, filters = {}) {
    try {
      let query = `
        SELECT 
          u.id, u.first_name, u.last_name, u.email, u.phone,
          u.is_active, u.created_at, u.updated_at,
          (SELECT COUNT(*) FROM bookings WHERE user_id = u.id) as total_bookings,
          (SELECT SUM(amount) FROM transactions WHERE user_id = u.id AND type = 'credit') as total_spent
        FROM users u
        WHERE 1=1
      `;
      const params = [];

      // Apply filters
      if (filters.isActive !== undefined) {
        query += ' AND u.is_active = $' + (params.length + 1);
        params.push(filters.isActive);
      }

      if (filters.email) {
        query += ' AND LOWER(u.email) LIKE $' + (params.length + 1);
        params.push('%' + filters.email.toLowerCase() + '%');
      }

      if (filters.createdAfter) {
        query += ' AND u.created_at >= $' + (params.length + 1);
        params.push(filters.createdAfter);
      }

      query += ' ORDER BY u.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
      params.push(limit, offset);

      const result = await this.db.query(query, params);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching users failed: ${error.message}`);
    }
  }

  /**
   * Suspend or unsuspend user account
   */
  async toggleUserSuspension(userId, suspend = true) {
    try {
      const query = `
        UPDATE users 
        SET is_active = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING id, first_name, email, is_active
      `;

      const result = await this.db.query(query, [!suspend, userId]);

      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Suspending user failed: ${error.message}`);
    }
  }

  /**
   * Get charger management data
   */
  async getChargerManagement(limit = 20, offset = 0, filters = {}) {
    try {
      let query = `
        SELECT 
          c.id, c.name, c.location, c.charger_type, c.price_per_kwh,
          c.is_active, c.is_approved, c.owner_id, c.created_at,
          u.first_name as owner_name, u.email as owner_email,
          (SELECT AVG(rating) FROM charger_reviews WHERE charger_id = c.id) as avg_rating,
          (SELECT COUNT(*) FROM charger_reviews WHERE charger_id = c.id) as review_count,
          (SELECT COUNT(*) FROM bookings WHERE charger_id = c.id) as total_bookings
        FROM chargers c
        LEFT JOIN users u ON c.owner_id = u.id
        WHERE 1=1
      `;
      const params = [];

      // Apply filters
      if (filters.isApproved !== undefined) {
        query += ' AND c.is_approved = $' + (params.length + 1);
        params.push(filters.isApproved);
      }

      if (filters.isActive !== undefined) {
        query += ' AND c.is_active = $' + (params.length + 1);
        params.push(filters.isActive);
      }

      if (filters.chargerType) {
        query += ' AND c.charger_type = $' + (params.length + 1);
        params.push(filters.chargerType);
      }

      query += ' ORDER BY c.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
      params.push(limit, offset);

      const result = await this.db.query(query, params);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching chargers failed: ${error.message}`);
    }
  }

  /**
   * Approve or reject charger listing
   */
  async approveCharger(chargerId, approved = true, reason = '') {
    try {
      const query = `
        UPDATE chargers 
        SET is_approved = $1, approval_date = NOW(), approval_notes = $2
        WHERE id = $3
        RETURNING id, name, is_approved
      `;

      const result = await this.db.query(query, [approved, reason, chargerId]);

      if (result.rows.length === 0) {
        throw new Error('Charger not found');
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Approving charger failed: ${error.message}`);
    }
  }

  /**
   * Get revenue and analytics
   */
  async getRevenueAnalytics(startDate, endDate) {
    try {
      const query = `
        SELECT 
          DATE(t.created_at) as date,
          COUNT(*) as transaction_count,
          SUM(t.amount) as total_revenue,
          AVG(t.amount) as avg_transaction,
          SUM(CASE WHEN t.type = 'credit' THEN t.amount ELSE 0 END) as user_payments,
          SUM(CASE WHEN t.type = 'commission' THEN t.amount ELSE 0 END) as commission_earned
        FROM transactions t
        WHERE t.created_at >= $1 AND t.created_at <= $2
        GROUP BY DATE(t.created_at)
        ORDER BY date DESC
      `;

      const result = await this.db.query(query, [startDate, endDate]);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching revenue analytics failed: ${error.message}`);
    }
  }

  /**
   * Get platform analytics summary
   */
  async getPlatformAnalytics() {
    try {
      const summaryQuery = `
        SELECT 
          (SELECT COUNT(*) FROM users) as total_users,
          (SELECT COUNT(*) FROM chargers WHERE is_approved = true) as total_chargers,
          (SELECT COUNT(*) FROM bookings) as total_bookings,
          (SELECT SUM(amount) FROM transactions) as total_revenue,
          (SELECT AVG(rating) FROM charger_reviews) as avg_charger_rating,
          (SELECT COUNT(*) FROM chargers WHERE is_active = false) as inactive_chargers
      `;

      const result = await this.db.query(summaryQuery);
      return result.rows[0];
    } catch (error) {
      throw new Error(`Fetching analytics failed: ${error.message}`);
    }
  }

  /**
   * Get fraud and dispute cases
   */
  async getFraudCases(limit = 10, offset = 0) {
    try {
      const query = `
        SELECT 
          d.id, d.reporter_id, d.respondent_id, d.dispute_type,
          d.status, d.amount, d.created_at,
          ur.first_name as reporter_name, ur.email as reporter_email,
          ud.first_name as respondent_name, ud.email as respondent_email
        FROM disputes d
        LEFT JOIN users ur ON d.reporter_id = ur.id
        LEFT JOIN users ud ON d.respondent_id = ud.id
        WHERE d.status IN ('open', 'under_review')
        ORDER BY d.created_at DESC
        LIMIT $1 OFFSET $2
      `;

      const result = await this.db.query(query, [limit, offset]);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching fraud cases failed: ${error.message}`);
    }
  }

  /**
   * Resolve fraud case
   */
  async resolveFraudCase(caseId, resolution, notes = '') {
    try {
      const query = `
        UPDATE disputes 
        SET status = $1, resolution_notes = $2, resolved_at = NOW()
        WHERE id = $3
        RETURNING id, status
      `;

      const result = await this.db.query(query, [resolution, notes, caseId]);

      if (result.rows.length === 0) {
        throw new Error('Case not found');
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Resolving case failed: ${error.message}`);
    }
  }

  /**
   * Create and manage promotional offers
   */
  async createPromotion(promotionData) {
    try {
      const { title, description, discountPercentage, startDate, endDate, maxUses, code } = promotionData;

      const query = `
        INSERT INTO promotions (title, description, discount_percentage, start_date, end_date, max_uses, code, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        RETURNING id, code
      `;

      const result = await this.db.query(query, [
        title,
        description,
        discountPercentage,
        startDate,
        endDate,
        maxUses,
        code,
      ]);

      return result.rows[0];
    } catch (error) {
      throw new Error(`Creating promotion failed: ${error.message}`);
    }
  }

  /**
   * Get active promotions
   */
  async getPromotions(limit = 20, offset = 0) {
    try {
      const query = `
        SELECT 
          id, title, description, discount_percentage, code,
          start_date, end_date, max_uses, times_used, is_active, created_at
        FROM promotions
        WHERE NOW() BETWEEN start_date AND end_date
        ORDER BY created_at DESC
        LIMIT $1 OFFSET $2
      `;

      const result = await this.db.query(query, [limit, offset]);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching promotions failed: ${error.message}`);
    }
  }

  /**
   * Get top chargers by bookings
   */
  async getTopChargers(limit = 10) {
    try {
      const query = `
        SELECT 
          c.id, c.name, c.location, c.charger_type,
          COUNT(b.id) as booking_count,
          AVG(cr.rating) as avg_rating,
          SUM(t.amount) as revenue_generated
        FROM chargers c
        LEFT JOIN bookings b ON c.id = b.charger_id
        LEFT JOIN charger_reviews cr ON c.id = cr.charger_id
        LEFT JOIN transactions t ON b.id = t.booking_id
        GROUP BY c.id
        ORDER BY booking_count DESC
        LIMIT $1
      `;

      const result = await this.db.query(query, [limit]);
      return result.rows;
    } catch (error) {
      throw new Error(`Fetching top chargers failed: ${error.message}`);
    }
  }
}

module.exports = AdminService;
