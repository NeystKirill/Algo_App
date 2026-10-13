const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// Cloudflare's publicly documented "always passes" test site key — safe as a
// dev default (see https://developers.cloudflare.com/turnstile/troubleshooting/testing/).
// Override with --dart-define=TURNSTILE_SITE_KEY=... for a real site key.
const turnstileSiteKey = String.fromEnvironment(
  'TURNSTILE_SITE_KEY',
  defaultValue: '1x00000000000000000000AA',
);
