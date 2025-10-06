import { Issuer, generators } from "openid-client";

let client;

export async function initOidc() {
  const issuerUrl = process.env.OIDC_ISSUER;
  const baseUrl = process.env.APP_BASE_URL;
  const issuer = await Issuer.discover(issuerUrl);

  client = new issuer.Client({
    client_id: process.env.OIDC_CLIENT_ID,
    client_secret: process.env.OIDC_CLIENT_SECRET,
    redirect_uris: [`${baseUrl}/oidc/callback`],
    response_types: ["code"]
  });
}

export function getClient() {
  if (!client) throw new Error("OIDC client not initialized");
  return client;
}

export function genState() { return generators.state(); }
export function genNonce() { return generators.nonce(); }
