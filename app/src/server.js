import "dotenv/config";
import express from "express";
import session from "express-session";
import publicRoutes from "./routes/public.js";
import protectedRoutes from "./routes/protected.js";
import { initOidc, getClient, genState, genNonce } from "./oidc.js";

const app = express();

// доверяем заголовкам прокси (для корректного secure-cookie по X-Forwarded-Proto)
app.set("trust proxy", 1);

// сессии
app.use(session({
  secret: process.env.SESSION_SECRET,
  name: "sid",
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    sameSite: "lax",
    secure: true, // мы за HTTPS (через Nginx)
    maxAge: 1000 * 60 * 60
  }
}));

// Маршруты
app.use(publicRoutes);

// OIDC login
app.get("/login", async (req, res, next) => {
  try {
    const client = getClient();
    const state = genState();
    const nonce = genNonce();
    req.session.oidc = { state, nonce };

    const url = client.authorizationUrl({
      scope: "openid email profile",
      state,
      nonce
    });
    res.redirect(url);
  } catch (e) { next(e); }
});

// Callback
app.get("/oidc/callback", async (req, res, next) => {
  try {
    const client = getClient();
    const params = client.callbackParams(req);

    const { state, nonce } = req.session.oidc || {};
    if (!state || params.state !== state) {
      return res.status(403).send("Invalid state");
    }

    const tokenSet = await client.callback(
      process.env.APP_BASE_URL + "/oidc/callback",
      params,
      { state, nonce }
    );

    const claims = tokenSet.claims();
    req.session.user = {
      sub: claims.sub,
      email: claims.email,
      name: claims.name || claims.preferred_username || "",
      claims
    };
    delete req.session.oidc;

    res.redirect("/profile");
  } catch (e) { next(e); }
});

// Logout (сеанс приложения)
app.get("/logout", (req, res) => {
  req.session.destroy(() => res.redirect("/"));
});

app.use(protectedRoutes);

// Старт
const PORT = 3000;
await initOidc();
app.listen(PORT, "0.0.0.0", () => {
  console.log(`[OK] App listening on :${PORT} (docker network only)`);
});
