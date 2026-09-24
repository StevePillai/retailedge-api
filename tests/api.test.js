const request = require('supertest');
const app = require('../src/app');

describe('RetailEdge API', () => {
  test('GET /health returns healthy', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
  });

  test('GET /api/products returns a list', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
  });

  test('GET /api/products/1 returns one product', async () => {
    const res = await request(app).get('/api/products/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(1);
  });

  test('GET /api/products/999 returns 404', async () => {
    const res = await request(app).get('/api/products/999');
    expect(res.statusCode).toBe(404);
  });

  test('GET /api/info names the service', async () => {
    const res = await request(app).get('/api/info');
    expect(res.statusCode).toBe(200);
    expect(res.body.service).toBe('retailedge-api');
  });
});
