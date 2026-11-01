const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('wf_fan_token');
}

export function getCurrentUser(): any | null {
  if (typeof window === 'undefined') return null;
  const str = localStorage.getItem('wf_fan_user');
  if (!str) return null;
  try {
    return JSON.parse(str);
  } catch {
    return null;
  }
}

export function setAuthToken(token: string, user?: any) {
  if (typeof window !== 'undefined') {
    localStorage.setItem('wf_fan_token', token);
    document.cookie = `wf_fan_token=${token}; path=/; max-age=2592000; SameSite=Lax`;
    if (user) {
      localStorage.setItem('wf_fan_user', JSON.stringify(user));
    }
    window.dispatchEvent(new CustomEvent('wf_auth_change', { detail: user || getCurrentUser() }));
  }
}

export function removeAuthToken() {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('wf_fan_token');
    localStorage.removeItem('wf_fan_user');
    document.cookie = 'wf_fan_token=; path=/; max-age=0; SameSite=Lax';
    window.dispatchEvent(new CustomEvent('wf_auth_change', { detail: null }));
  }
}

export function resolveMediaUrl(path?: string | null): string {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return `${API_BASE}${path}`;
}

export async function fetchApi(path: string, options: RequestInit = {}) {
  const token = getAuthToken();
  const headers = new Headers(options.headers || {});

  headers.set('Accept', 'application/json');
  if (!headers.has('Content-Type') && !(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  headers.set('X-Requested-With', 'wishful-pwa');

  const url = path.startsWith('http') ? path : `${API_BASE}${path}`;
  const res = await fetch(url, {
    ...options,
    headers,
  });

  return res;
}

