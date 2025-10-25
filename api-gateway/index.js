const express = require("express");
const httpProxy = require("http-proxy");

const proxy = httpProxy.createProxyServer();
const app = express();

const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL || "http://auth-service:7070";
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || "http://product-service:8080";
const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL || "http://order-service:9090";

app.use("/auth", (req, res) => {
  proxy.web(req, res, { target: AUTH_SERVICE_URL });
});

app.use("/products", (req, res) => {
  proxy.web(req, res, { target: PRODUCT_SERVICE_URL });
});

app.use("/orders", (req, res) => {
  proxy.web(req, res, { target: ORDER_SERVICE_URL });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`API Gateway listening on port ${port}`);
});
