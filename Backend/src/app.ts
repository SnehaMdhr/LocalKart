import express, { Application, Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from "dotenv";
import path from "path";


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



app.get('/', (req: Request, res: Response) => {
    res.send('Hello, World!');
});


export default app;