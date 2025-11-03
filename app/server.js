const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const _ = require('lodash');
const axios = require('axios');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// In-memory data store (simulating a database)
let users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' }
];

let products = [
  { id: 1, name: 'Laptop', price: 999.99 },
  { id: 2, name: 'Mouse', price: 29.99 },
  { id: 3, name: 'Keyboard', price: 79.99 }
];

// Routes

// 1. Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// 2. Get all users
app.get('/api/users', (req, res) => {
  res.json({ 
    success: true, 
    count: users.length,
    users: users 
  });
});

// 3. Get user by ID
app.get('/api/users/:id', (req, res) => {
  const user = _.find(users, { id: parseInt(req.params.id) });
  if (user) {
    res.json({ success: true, user });
  } else {
    res.status(404).json({ success: false, message: 'User not found' });
  }
});

// 4. Get all products
app.get('/api/products', (req, res) => {
  res.json({ 
    success: true, 
    count: products.length,
    products: products 
  });
});

// 5. Search products by name
app.get('/api/products/search', (req, res) => {
  const query = req.query.q || '';
  const results = _.filter(products, product => 
    product.name.toLowerCase().includes(query.toLowerCase())
  );
  res.json({ 
    success: true, 
    query: query,
    count: results.length,
    results: results 
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    success: false, 
    message: 'Internal server error' 
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: 'Endpoint not found' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`[Server] Running on http://localhost:${PORT}`);
  console.log(`[Server] Health check: http://localhost:${PORT}/health`);
  console.log(`[Server] API endpoints available at /api/*`);
});

module.exports = app;
