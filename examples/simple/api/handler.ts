import { Rcon } from "rcon-ts";
import express from "express";
import jwt from "jsonwebtoken";
import morgan from "morgan";
import { v4 as uuid } from "uuid";
import dotenv from "dotenv";
export const handler = express();
dotenv.config();
const TOKEN_SECRET = process.env.TOKEN_SECRET || "<secret>";
const connections = {};
handler.use(express.json());
handler.use(morgan("dev", { immediate: true }));
handler.use(morgan("dev", { immediate: false }));

function close(id) {
  const connection = connections[id];
  if (!connection) return;
  clearTimeout(connection.timeout);
  connection.rcon.disconnect();
  delete connections[id];
}
handler.post("/connect", async (req, res) => {
  try {
    const { host, port, password } = req.body;
    const rcon = new Rcon({ host, port, password, timeout: 5000 });

    await rcon.connect();
    const id = uuid();
    const timeout = setTimeout(() => close(id), 1800000);
    connections[id] = { rcon, timeout };
    res.send(jwt.sign(id, TOKEN_SECRET));
  } catch (err) {
    return res.status(400).send(err.message);
  }
});
handler.get("/renew", async (req, res) => {
  try {
    const id = jwt.verify(
      req.headers.authorization.split(" ")[1],
      TOKEN_SECRET
    );
    const connection = connections[id];
    if (!connection) throw new Error("session closed");
    clearTimeout(connection.timeout);
    connection.timeout = setTimeout(() => close(id), 1800000);
    res.send("renewed");
  } catch (err) {
    return res.status(400).send(err.message);
  }
});
handler.get("/disconnect", async (req, res) => {
  try {
    const id = jwt.verify(
      req.headers.authorization.split(" ")[1],
      TOKEN_SECRET
    );
    close(id);
    res.send("disconnected");
  } catch (err) {
    return res.status(400).send("invalid token");
  }
});

handler.post("/output", async (req, res) => {
  try {
    const id = jwt.verify(
      req.headers.authorization.split(" ")[1],
      TOKEN_SECRET
    );
    const connection = connections[id];
    if (!connection) throw new Error("invalid token");
    res.send(
      await connection.rcon.send("/rcon-output " + JSON.stringify(req.body))
    );
  } catch (err) {
    return res.status(400).send(err);
  }
});

handler.post("/input", async (req, res) => {
  try {
    const id = jwt.verify(
      req.headers.authorization.split(" ")[1],
      TOKEN_SECRET
    );
    const connection = connections[id];
    if (!connection) throw new Error("invalid token");
    res.send(
      await connection.rcon.send("/rcon-input " + JSON.stringify(req.body))
    );
  } catch (err) {
    return res.status(400).send(err);
  }
});
