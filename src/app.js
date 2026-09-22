const x = 1;
const express = require('express');

const app = express();
app.use(express.json());

const products = [
  { id: 1, name: 'Wireless Mouse', price: 799 },
  { id: 2, name: 'Mechanical Keyboard', price: 3499 },
  { id: 3, name: 'USB-C Hub', price: 1999 },
];

// Used by Jenkins, Docker and load balancers to check the app is alive
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    version: process.env.APP_VERSION || 'local',
  });
});

app.get('/api/products', (req, res) => {
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find((p) => p.id === Number(req.params.id));
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  return res.json(product);
});

module.exports = app;
