mindmap
  root((OAuth User Flow)) {#0d47a1} {#ffffff}
    1. Initial Request {#0277bd}
      User clicks "Login with Provider"
      App detects no valid session
      Redirect to /authorize
      Params: client_id, redirect_uri
      Params: scope, state, response_type=code
    2. Login {#00796b}
      Provider shows login form
      User enters credentials
      MFA check {#4db6ac}
        TOTP app
        Push / U2F key
      Session cookie on provider domain
    3. Consent {#5e35b1}
      Shows requested scopes
      profile
      email
      openid
      offline_access
      User approves or denies
      Denied → error redirect
    4. Authorization Code {#ef6c00}
      Redirect back to app
      ?code=AUTH_CODE&state=...
      Verify state (CSRF protection)
      Code short-lived & single-use
    5. Token Exchange {#00695c}
      Backend calls /token
      grant_type=authorization_code
      Sends client_secret (confidential)
      OR code_verifier (PKCE)
      Returns access_token
      Returns refresh_token
      Returns token_type & expires_in
    6. API Access {#c62828}
      Authorization: Bearer access_token
      Call protected endpoints
      Token expired → 401 response
    7. Token Refresh {#4527a0}
      Detect 401 / expiry
      Calls /token with refresh_token
      New access_token issued
      Expired / revoked → re-auth from start
    8. Logout {#37474f}
      Revoke tokens (optional)
      Clear local session & cookies
      Redirect to provider logout
    Variations {#8e24aa}
      PKCE for public clients {#ba68c8}
        App generates code_verifier
        Sends S256 code_challenge
        No client_secret needed
      OIDC openid {#80deea}
        Signals an ID token (JWT)
        Identity claims separate from access
