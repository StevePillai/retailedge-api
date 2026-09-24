if (process.env.NODE_ENV === 'production') {
  console.error('Simulated production-only failure');
  process.exit(1);
}

const app = require('./app');

const port = process.env.PORT || 3000;

app.listen(port, '0.0.0.0', () => {
  console.log(`RetailEdge API listening on port ${port}`);
});
