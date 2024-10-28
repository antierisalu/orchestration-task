import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import dotenv from 'dotenv';
import winston from 'winston';
import path from 'path'

dotenv.config({ path: './../.env' });

const app = express();
const port = process.env.GATEWAY_PORT 

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new winston.transports.File({ filename: path.join('/app/logs', 'combined.log') }),
        new winston.transports.Console() 
    ]
});

app.use((req, res, next) => {
    // Log the incoming request method and URL
    logger.info(`Incoming request: ${req.method} ${req.url}`);

    // Log request headers
    logger.info('Request Headers:', req.headers);

    // Log request body (for POST/PUT requests)
    if (req.method === 'POST' || req.method === 'PUT') {
        logger.info('Request Body:', req.body);
    }

    next(); 
});

const inventoryProxy = createProxyMiddleware({
    target: process.env.GATEWAY_INVENTORY_URL,
    changeOrigin: true,
    logLevel: 'debug',
    onError: (err, req, res) => {
        console.error('Proxy Error (Inventory):', err.message, req.url);
        res.status(500).send(`Proxy Error (Inventory): ${err.message}`);
    }
});

const billingProxy = createProxyMiddleware({
    target: process.env.GATEWAY_BILLING_URL,
    changeOrigin: true,
    logLevel: 'debug',
    onError: (err, req, res) => {
        console.error('Proxy Error (Billing):', err);
        res.status(500).send('Proxy Error (Billing)');
    }
});


// Use the proxy middleware for all routes
app.use('/movies', inventoryProxy);
app.use('/billing', billingProxy);

app.listen(port, '0.0.0.0', () => {
    logger.info(`Proxy server running at ${process.env.GATEWAY_URL}/`); // Use logger.info instead of logger.log
    logger.info(`Proxying /movies requests to ${process.env.GATEWAY_INVENTORY_URL}`);
    logger.info(`Proxying /billing queue requests to ${process.env.GATEWAY_BILLING_URL}`);
});