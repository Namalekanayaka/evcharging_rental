import crypto from 'crypto';

export const generateOTP = (length = 6) => {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * digits.length)];
  }
  return otp;
};

export const generateUniqueCode = (prefix = 'CHG') => {
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = crypto.randomBytes(4).toString('hex').toUpperCase();
  return `${prefix}-${timestamp}-${random}`;
};

export const hashPassword = async (password) => {
  const bcrypt = await import('bcryptjs');
  const salt = await bcrypt.default.genSalt(10);
  return bcrypt.default.hash(password, salt);
};

export const comparePassword = async (password, hashedPassword) => {
  const bcrypt = await import('bcryptjs');
  return bcrypt.default.compare(password, hashedPassword);
};

export const generateToken = (payload, secret, expiresIn = '7d') => {
  const jwt = await import('jsonwebtoken');
  return jwt.default.sign(payload, secret, { expiresIn });
};

export const verifyToken = (token, secret) => {
  const jwt = await import('jsonwebtoken');
  return jwt.default.verify(token, secret);
};

export const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};
