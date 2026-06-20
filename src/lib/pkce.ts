import crypto from "crypto";

const base64UrlEncode = (buffer: Buffer) =>
  buffer
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

export function generateCodeVerifier() {
  return base64UrlEncode(crypto.randomBytes(32));
}

export function generateState() {
  return base64UrlEncode(crypto.randomBytes(16));
}

export function generateCodeChallenge(verifier: string) {
  const hash = crypto.createHash("sha256").update(verifier).digest();
  return base64UrlEncode(hash);
}
