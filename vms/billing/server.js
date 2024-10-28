import express from 'express';
import { connect } from 'amqplib';
import dotenv from 'dotenv';

dotenv.config({ path: '../.env' });

const app = express();
const port = process.env.BILLING_PORT || 5000;

const checkClientIP = (req, res, next) => {
  const clientIP = req.ip;
  if (clientIP === `::ffff:${process.env.GATEWAY_HOST}`) {
    next();
  } else {
    res.status(403).json({ message: 'Access denied' });
  }
};

app.use(checkClientIP);
app.use(express.json());

app.post('/', async (req, res) => {
  const order = req.body;
  console.log('Received order:', order);

  try {
    const conn = await connect(`amqp://${process.env.RABBITMQ_HOST}`);
    const channel = await conn.createChannel();
    const queue = 'orders_queue';

    await channel.assertQueue(queue, { durable: true });
    channel.sendToQueue(queue, Buffer.from(JSON.stringify(order)), { persistent: true });

    console.log('Sent to RabbitMQ:', order);
    res.status(200).send('Order received and sent to queue.');
  } catch (error) {
    console.error('Error sending to RabbitMQ:', error);
    res.status(200).send('Order received, waiting for consumer start.');
  }
});

app.listen(port, () => {
  console.log(`Billing is running on ${process.env.GATEWAY_URL}/billing`);
});