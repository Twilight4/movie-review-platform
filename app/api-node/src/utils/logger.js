const winston = require('winston');

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Create the logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info', // Default to 'info', can be changed via env var
  format: logFormat,
  defaultMeta: { service: 'movie-api' }, // Add service name to all logs
  transports: [
    // Write all logs to console
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, ...meta }) => {
          let msg = `${timestamp} [${level}]: ${message}`;
          // Add metadata if present
          if (Object.keys(meta).length > 0 && meta.service !== 'movie-api') {
            msg += ` ${JSON.stringify(meta)}`;
          }
          return msg;
        })
      ),
    }),
    // Write error logs to error.log file
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: logFormat,
    }),
    // Write all logs to combined.log file
    new winston.transports.File({
      filename: 'logs/combined.log',
      format: logFormat,
    }),
  ],
});

// If we're not in production, also log to console with more detail
if (process.env.NODE_ENV !== 'production') {
  logger.level = 'debug';
}

module.exports = logger;
