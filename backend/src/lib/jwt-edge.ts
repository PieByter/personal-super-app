/**
 * Edge-compatible HS256 verification.
 *
 * `jsonwebtoken` cannot run in the Edge runtime (it needs Node's `crypto`),
 * so middleware verifies tokens with WebCrypto instead. Route handlers keep
 * using `jsonwebtoken` from `@/lib/auth`, which runs on Node.
 */
const encoder = new TextEncoder();
const decoder = new TextDecoder();

function base64UrlToBytes(value: string): Uint8Array<ArrayBuffer> {
    const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
    const binary = atob(padded);
    const bytes = new Uint8Array(new ArrayBuffer(binary.length));
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes;
}

/** Verifies an HS256 token's signature and `exp` claim. Never throws for bad tokens. */
export async function verifyAccessToken(token: string): Promise<boolean> {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error("JWT_SECRET environment variable is not set.");
    }

    const parts = token.split(".");
    if (parts.length !== 3) return false;
    const [header, payload, signature] = parts;

    let algorithm: string | undefined;
    let claims: { exp?: number };
    try {
        algorithm = JSON.parse(decoder.decode(base64UrlToBytes(header))).alg;
        claims = JSON.parse(decoder.decode(base64UrlToBytes(payload)));
    } catch {
        return false;
    }
    if (algorithm !== "HS256") return false;

    const key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(secret),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["verify"]
    );
    const signatureValid = await crypto.subtle.verify(
        "HMAC",
        key,
        base64UrlToBytes(signature),
        encoder.encode(`${header}.${payload}`)
    );
    if (!signatureValid) return false;

    if (typeof claims.exp === "number" && claims.exp * 1000 <= Date.now()) return false;
    return true;
}
