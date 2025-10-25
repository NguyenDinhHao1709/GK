require("dotenv").config();

module.exports = {
  port: process.env.PORT || 8080,
  mongoURI: process.env.MONGODB_URI || process.env.MONGODB_PRODUCT_URI || "mongodb://localhost/products",
  rabbitMQURI: process.env.RABBITMQ_URL || process.env.RABBITMQ_URI || "amqp://localhost",
  exchangeName: "products",
  queueName: "products_queue",
};
