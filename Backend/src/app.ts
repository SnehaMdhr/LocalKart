import express, { Application, Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from "dotenv";
import path from "path";
import userRoutes from './routes/user.routes';
import shopRoutes from "./routes/shop.routes";
import productRoutes from './routes/product.routes';
import collectionRoutes from './routes/collection.routes';
import cartRoutes from './routes/cart.routes';
import orderRoutes from './routes/order.routes';

dotenv.config();
// can use .env variable below this
console.log(process.env.PORT);

const app: Application = express();

app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

let corsOptions = {
    origin: "*",
    // which domain can access your backend server
    // add frontend domain in origin 
}
// origin: "*", // allow all domain to access your backend server
app.use(cors(corsOptions)); // implement cors middleware

app.use(bodyParser.json());
app.use("/api/auth", userRoutes);
app.use("/api/shop", shopRoutes);
app.use("/api/product", productRoutes);
app.use("/api/collection", collectionRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/order", orderRoutes);
app.get('/', (req: Request, res: Response) => {
    res.send('Hello, World!');
});


export default app;