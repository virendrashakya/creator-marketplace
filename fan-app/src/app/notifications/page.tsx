'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import Header from '@/components/Header';
import { fetchApi, getAuthToken } from '@/lib/api';

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<any[]>([]);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = getAuthToken();
    setToken(t);
    if (!t) {
      setLoading(false);
      return;
    }

    async function loadNotifications() {
      try {
        const res = await fetchApi('/api/v1/notifications');
        if (res.ok) {
          const data = await res.json();
          setNotifications(data.notifications || []);
        }
      } catch (e) {
        console.error('Failed to load notifications:', e);
      } finally {
        setLoading(false);
      }
    }
    loadNotifications();
  }, []);

  return (
    <div>
      <Header title="Notifications" />

      <div style={{ padding: '20px 16px 80px' }}>
        {!token ? (
          <div className="w-card" style={{ padding: '36px 20px', textAlign: 'center' }}>
            <h2 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>Sign in to view alerts</h2>
            <p style={{ fontSize: '13px', color: 'var(--w-sub)', marginBottom: '20px' }}>
              Stay informed when creators approve your unlocks or start live streams.
            </p>
            <Link href="/join" className="w-btn w-btn-pink" style={{ padding: '12px 24px', fontSize: '14px' }}>
              Sign In
            </Link>
          </div>
        ) : loading ? (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--w-sub)' }}>Loading alerts...</div>
        ) : notifications.length > 0 ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {notifications.map((n) => (
              <div key={n.id} className="w-card" style={{ padding: '12px 14px', display: 'flex', gap: '12px', alignItems: 'center' }}>
                <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'rgba(224, 48, 106, 0.12)', color: 'var(--w-pink)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  🔔
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: 700 }}>{n.data?.title || 'Notification'}</div>
                  <div style={{ fontSize: '12px', color: 'var(--w-sub)' }}>{new Date(n.created_at).toLocaleDateString()}</div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="w-card" style={{ padding: '36px 20px', textAlign: 'center' }}>
            <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'var(--w-raise)', color: 'var(--w-sub)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px', fontSize: '20px' }}>
              ✨
            </div>
            <h2 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>No alerts yet</h2>
            <p style={{ fontSize: '13px', color: 'var(--w-sub)' }}>
              When a creator approves a payment claim or goes live, you will see it here.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
