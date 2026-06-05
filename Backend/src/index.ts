import { connectDatabase } from './database/mongodb';
import app from './app';
import { PORT } from './config';
async function startServer(){
    await connectDatabase();

    app.listen(
    PORT,
    ()=>{
        console.log(`Server: https://localhost:${PORT}`);
    }
)
}

startServer();