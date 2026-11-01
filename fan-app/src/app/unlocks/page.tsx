'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Header from '@/components/Header';
import { getAuthToken } from '@/lib/api';

export default function UnlocksPage() {
  const [token, setToken] = useState<string | null>(null);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    const t = getAuthToken();
    setToken(t);
    const uStr = localStorage.getItem('wf_fan_user');
    if (uStr) {
      try {
        setUser(JSON.parse(uStr));
      } catch (e) {}
    }
  }, []);

  return (
    <div>
      <Header title="Your Vault" />

      <div style={{ padding: '24px 16px 80px' }}>
        <h1 style={{ fontSize: '22px', fontWeight: 800, marginBottom: '6px' }}>Unlocked Library</h1>
        <p style={{ fontSize: '13.5px', color: 'var(--w-sub)', marginBottom: '24px' }}>
          Opened on this device, forensically watermarked and accessible offline.
        </p>

        {!token ? (
          <div className="w-card" style={{ padding: '36px 20px', textAlign: 'center' }}>
            <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(224, 48, 106, 0.12)', color: 'var(--w-pink)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="4.5" y="10" width="15" height="11" rx="2.5"/>
                <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
              </svg>
            </div>
            <h2 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>Sign in to view your Vault</h2>
            <p style={{ fontSize: '13px', color: 'var(--w-sub)', marginBottom: '20px', lineHeight: 1.45 }}>
              All your purchased albums, videos, and Close Friends passes will appear here.
            </p>
            <Link href="/join" className="w-btn w-btn-pink" style={{ padding: '12px 24px', fontSize: '14px', width: '100%', maxWidth: '280px' }}>
              Sign In with Mobile
            </Link>
          </div>
        ) : (
          <div className="w-card" style={{ padding: '36px 20px', textAlign: 'center' }}>
            <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(245, 185, 66, 0.12)', color: 'var(--w-gold)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
              </svg>
            </div>
            <h2 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>Your Vault is synced</h2>
            <p style={{ fontSize: '13px', color: 'var(--w-sub)', marginBottom: '20px', lineHeight: 1.45 }}>
              You are signed in as <strong>@{user?.handle}</strong>. Visit your favorite creator's storefront to unlock new photo & video drops.
            </p>
            <Link href="/discover" className="w-btn w-btn-pink" style={{ padding: '12px 24px', fontSize: '14px' }}>
              Explore Creator Drops
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
