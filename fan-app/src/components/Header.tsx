'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getAuthToken, getCurrentUser, removeAuthToken, fetchApi } from '@/lib/api';

interface HeaderProps {
  title?: string;
  showBack?: boolean;
}

export default function Header({ title, showBack }: HeaderProps) {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);

    function syncUser() {
      const token = getAuthToken();
      if (!token) {
        setUser(null);
        return;
      }

      // Check cache first
      const cached = getCurrentUser();
      if (cached) {
        setUser(cached);
      }

      // Verify or refresh from /api/v1/auth/me
      fetchApi('/api/v1/auth/me')
        .then((res) => {
          if (res.ok) return res.json();
          if (res.status === 401) {
            removeAuthToken();
            setUser(null);
          }
          return null;
        })
        .then((data) => {
          if (data?.user) {
            setUser(data.user);
            if (typeof window !== 'undefined') {
              localStorage.setItem('wf_fan_user', JSON.stringify(data.user));
            }
          }
        })
        .catch(() => {});
    }

    syncUser();

    function handleAuthEvent(e: any) {
      if (e.detail) {
        setUser(e.detail);
      } else {
        syncUser();
      }
    }

    window.addEventListener('wf_auth_change', handleAuthEvent);
    window.addEventListener('storage', syncUser);

    return () => {
      window.removeEventListener('wf_auth_change', handleAuthEvent);
      window.removeEventListener('storage', syncUser);
    };
  }, []);

  function handleSignOut() {
    removeAuthToken();
    setUser(null);
    router.refresh();
    window.location.href = '/feed';
  }

  return (
    <header className="w-topbar">
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        {showBack ? (
          <button
            onClick={() => router.back()}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--w-text)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              padding: 0,
            }}
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="15 18 9 12 15 6" />
            </svg>
          </button>
        ) : (
          <span className="w-brand-mark">W</span>
        )}
        <span style={{ fontSize: '18px', fontWeight: 800, letterSpacing: '-0.02em' }}>
          {title || 'Wishful'}
        </span>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        {mounted && user ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span
              style={{
                fontSize: '12px',
                fontWeight: 800,
                color: 'var(--w-gold)',
                background: 'var(--w-gold-bg)',
                border: '1px solid var(--w-gold-line)',
                padding: '4px 12px',
                borderRadius: '9999px',
                boxShadow: 'var(--w-gold-glow)',
                letterSpacing: '0.02em',
              }}
            >
              @{user.handle}
            </span>
            <button
              onClick={handleSignOut}
              className="w-btn w-btn-raised"
              style={{
                fontSize: '11.5px',
                padding: '5px 12px',
                color: 'var(--w-sub)',
                fontWeight: 600,
              }}
              title="Sign out"
            >
              Sign out
            </button>
          </div>
        ) : mounted ? (
          <Link
            href="/join"
            className="w-btn w-btn-pink"
            style={{ fontSize: '12.5px', padding: '6px 16px', fontWeight: 800 }}
          >
            Sign in
          </Link>
        ) : null}
      </div>
    </header>
  );
}
