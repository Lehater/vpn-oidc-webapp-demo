import { Router } from "express";
const router = Router();

router.get("/", (req, res) => {
  res.type("html").send(`
    <h1>Главная</h1>
    <p>${req.session?.user ? "Вы авторизованы" : "Вы не авторизованы"}</p>
    <p><a href="/about">About</a> | <a href="/profile">Profile</a> | <a href="/login">Login</a> | <a href="/logout">Logout</a></p>
  `);
});

router.get("/about", (_req, res) => {
  res.type("html").send(`
    <h1>О приложении</h1>
    <p>Демо: доступ только через VPN (wg0), аутентификация через OIDC (Keycloak).</p>
    <p><a href="/">На главную</a></p>
  `);
});

export default router;
