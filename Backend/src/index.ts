import { createServer } from "http";
import { connectDatabase } from "./database/mongodb";
import app from "./app";
import { PORT } from "./config";
import { initializeSocket } from "./socket";

async function startServer() {
  await connectDatabase();

  // Create HTTP server from the Express app
  const httpServer = createServer(app);

  // Initialize Socket.IO on the same HTTP server
  initializeSocket(httpServer);

  httpServer.listen(PORT, () => {
    console.log(`Server: http://localhost:${PORT}`);
  });
}

startServer();