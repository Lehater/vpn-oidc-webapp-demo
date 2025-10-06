import { Router } from "express";
import { ensureAuth } from "../middleware/ensureAuth.js";

const router = Router();

router.get("/profile", ensureAuth, (req, res) => {
  const { user } = req.session;
  res.type("html").send(`
    <h1>Профиль</h1>
    <pre>${JSON.stringify(user, null, 2)}</pre>
    <p><a href="/">На главную</a> | <a href="/logout">Выйти</a></p>
  `);
});

export default router;
