'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { fetchApi, setAuthToken } from '@/lib/api';

export default function JoinPage() {
  const router = useRouter();
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [phone, setPhone] = useState('');
  const [handle, setHandle] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [debugCode, setDebugCode] = useState<string | null>(null);

  async function handleSendOtp(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const formattedPhone = phone.startsWith('+') ? phone : `+91${phone.replace(/\D/g, '')}`;
      const res = await fetchApi('/api/v1/auth/otp', {
        method: 'POST',
        body: JSON.stringify({ phone: formattedPhone, handle: handle.trim() }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to send verification code.');
      }

      if (data.debug_code) {
        setDebugCode(data.debug_code);
        setOtp(data.debug_code); // auto-fill for ease of testing
      }
      setStep('otp');
    } catch (err: any) {
      setError(err.message || 'Something went wrong.');
    } finally {
      setLoading(false);
    }
  }

  async function handleVerifyOtp(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const formattedPhone = phone.startsWith('+') ? phone : `+91${phone.replace(/\D/g, '')}`;
      const res = await fetchApi('/api/v1/auth/verify', {
        method: 'POST',
        body: JSON.stringify({
          phone: formattedPhone,
          code: otp.trim(),
          handle: handle.trim(),
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Invalid code.');
      }

      if (data.token) {
        setAuthToken(data.token, data.user);
        window.location.href = '/feed';
      }
    } catch (err: any) {
      setError(err.message || 'Invalid or expired code.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      {/* Top Header */}
      <header className="w-topbar">
        <Link href="/feed" style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--w-text)', fontSize: '14px', fontWeight: 700 }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="15 18 9 12 15 6" />
          </svg>
          <span>Back</span>
        </Link>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span className="w-brand-mark">W</span>
          <span style={{ fontWeight: 800 }}>Wishful</span>
        </div>
      </header>

      <div style={{ padding: '36px 20px', maxWidth: '400px', margin: '0 auto' }}>
        {step === 'phone' ? (
          <div>
            <div style={{ textAlign: 'center', marginBottom: '28px' }}>
              <div
                style={{
                  width: '60px',
                  height: '60px',
                  borderRadius: '50%',
                  background: 'rgba(224, 48, 106, 0.12)',
                  color: 'var(--w-pink)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                }}
              >
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
                </svg>
              </div>
              <h1 style={{ fontSize: '24px', fontWeight: 800, letterSpacing: '-0.02em', marginBottom: '8px' }}>
                Sign in to Wishful
              </h1>
              <p style={{ fontSize: '13.5px', color: 'var(--w-sub)', lineHeight: 1.45 }}>
                Enter your mobile number. We will send a 6-digit WhatsApp verification code.
              </p>
            </div>

            {error && (
              <div style={{ background: 'rgba(248, 113, 150, 0.15)', border: '1px solid var(--w-rose)', color: 'var(--w-rose)', padding: '10px 14px', borderRadius: '12px', fontSize: '13px', marginBottom: '20px' }}>
                {error}
              </div>
            )}

            <form onSubmit={handleSendOtp} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--w-sub)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Mobile Number
                </label>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <span style={{ background: 'var(--w-card)', border: '1px solid var(--w-line)', borderRadius: '12px', padding: '12px 14px', fontSize: '15px', color: 'var(--w-text)', fontWeight: 700 }}>
                    +91
                  </span>
                  <input
                    type="tel"
                    placeholder="98765 43210"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    required
                    style={{
                      flex: 1,
                      background: 'var(--w-card)',
                      border: '1px solid var(--w-line)',
                      borderRadius: '12px',
                      padding: '12px 14px',
                      fontSize: '15px',
                      color: 'var(--w-text)',
                      outline: 'none',
                    }}
                  />
                </div>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--w-sub)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Fan Handle (Optional)
                </label>
                <input
                  type="text"
                  placeholder="@yourname"
                  value={handle}
                  onChange={(e) => setHandle(e.target.value)}
                  style={{
                    width: '100%',
                    background: 'var(--w-card)',
                    border: '1px solid var(--w-line)',
                    borderRadius: '12px',
                    padding: '12px 14px',
                    fontSize: '15px',
                    color: 'var(--w-text)',
                    outline: 'none',
                  }}
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-btn w-btn-pink"
                style={{
                  width: '100%',
                  padding: '14px',
                  borderRadius: '24px',
                  fontSize: '15px',
                  fontWeight: 800,
                  marginTop: '8px',
                  opacity: loading ? 0.7 : 1,
                }}
              >
                {loading ? 'Sending Code...' : 'Get OTP Code'}
              </button>
            </form>
          </div>
        ) : (
          <div>
            <div style={{ textAlign: 'center', marginBottom: '24px' }}>
              <div
                style={{
                  width: '60px',
                  height: '60px',
                  borderRadius: '50%',
                  background: 'rgba(74, 222, 128, 0.12)',
                  color: 'var(--w-green)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                }}
              >
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
              </div>
              <h2 style={{ fontSize: '22px', fontWeight: 800, marginBottom: '6px' }}>Verify Code</h2>
              <p style={{ fontSize: '13.5px', color: 'var(--w-sub)' }}>
                Enter the 6-digit code sent to <strong style={{ color: 'var(--w-text)' }}>{phone}</strong>
              </p>
            </div>

            {debugCode && (
              <div style={{ background: 'rgba(245, 185, 66, 0.15)', border: '1px solid var(--w-gold-line)', color: 'var(--w-gold)', padding: '10px 14px', borderRadius: '12px', fontSize: '12.5px', marginBottom: '16px', textAlign: 'center' }}>
                ⚡ Development Code: <strong>{debugCode}</strong>
              </div>
            )}

            {error && (
              <div style={{ background: 'rgba(248, 113, 150, 0.15)', border: '1px solid var(--w-rose)', color: 'var(--w-rose)', padding: '10px 14px', borderRadius: '12px', fontSize: '13px', marginBottom: '16px' }}>
                {error}
              </div>
            )}

            <form onSubmit={handleVerifyOtp} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <input
                  type="text"
                  maxLength={6}
                  placeholder="000000"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                  required
                  autoFocus
                  style={{
                    width: '100%',
                    background: 'var(--w-card)',
                    border: '1px solid var(--w-line)',
                    borderRadius: '12px',
                    padding: '14px',
                    fontSize: '24px',
                    fontWeight: 800,
                    letterSpacing: '0.3em',
                    textAlign: 'center',
                    color: 'var(--w-text)',
                    outline: 'none',
                  }}
                />
              </div>

              <button
                type="submit"
                disabled={loading || otp.length < 6}
                className="w-btn w-btn-pink"
                style={{
                  width: '100%',
                  padding: '14px',
                  borderRadius: '24px',
                  fontSize: '15px',
                  fontWeight: 800,
                  opacity: loading || otp.length < 6 ? 0.6 : 1,
                }}
              >
                {loading ? 'Verifying...' : 'Verify & Sign In'}
              </button>

              <button
                type="button"
                onClick={() => {
                  setStep('phone');
                  setOtp('');
                  setError(null);
                }}
                className="w-btn w-btn-raised"
                style={{
                  width: '100%',
                  padding: '12px',
                  borderRadius: '24px',
                  fontSize: '13.5px',
                  fontWeight: 600,
                }}
              >
                Change Number
              </button>
            </form>
          </div>
        )}
      </div>
    </div>
  );
}
