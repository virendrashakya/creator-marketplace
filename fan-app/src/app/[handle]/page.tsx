'use client';

import { Suspense, useEffect, useState, use } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import Header from '@/components/Header';
import { fetchApi, getAuthToken, resolveMediaUrl } from '@/lib/api';

interface CreatorProfileProps {
  params: Promise<{ handle: string }>;
}

function ProfileContent({ params }: CreatorProfileProps) {
  const router = useRouter();
  const resolvedParams = use(params);
  const handle = resolvedParams.handle;

  const [creator, setCreator] = useState<any>(null);
  const [collections, setCollections] = useState<any[]>([]);
  const [posts, setPosts] = useState<any[]>([]);
  const [lives, setLives] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<'collections' | 'posts' | 'lives'>('collections');
  const [loading, setLoading] = useState(true);
  const [followLoading, setFollowLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Pay sheet modal state
  const [selectedCollectionForPay, setSelectedCollectionForPay] = useState<any | null>(null);
  const [utr, setUtr] = useState('');
  const [claimLoading, setClaimLoading] = useState(false);
  const [claimStatus, setClaimStatus] = useState<{ success?: boolean; message?: string } | null>(null);

  // In-app collection viewer modal
  const [selectedCollectionForView, setSelectedCollectionForView] = useState<any | null>(null);
  const [copiedUpi, setCopiedUpi] = useState(false);

  useEffect(() => {
    loadCreator();
  }, [handle]);

  async function loadCreator() {
    try {
      setLoading(true);
      const res = await fetchApi(`/api/v1/creators/${handle}`);
      if (!res.ok) {
        throw new Error('Creator not found');
      }
      const data = await res.json();
      setCreator(data.creator);
      setCollections(data.collections || []);
      setPosts(data.posts || []);
      setLives(data.lives || []);
    } catch (e: any) {
      setError(e.message || 'Failed to load creator profile');
    } finally {
      setLoading(false);
    }
  }

  async function handleToggleFollow() {
    const token = getAuthToken();
    if (!token) {
      router.push('/join');
      return;
    }

    setFollowLoading(true);
    try {
      const method = creator.is_following ? 'DELETE' : 'POST';
      const res = await fetchApi(`/api/v1/creators/${handle}/follow`, { method });
      if (res.ok) {
        const data = await res.json();
        setCreator((prev: any) => ({
          ...prev,
          is_following: data.is_following,
          followers_count: data.followers_count,
        }));
      }
    } catch (e) {
      console.error('Follow action failed:', e);
    } finally {
      setFollowLoading(false);
    }
  }

  function formatPrice(cents: number, currency: string = 'INR') {
    const symbol = currency === 'INR' ? '₹' : '$';
    return `${symbol}${(cents / 100).toLocaleString('en-IN')}`;
  }

  function openPaySheet(collection: any) {
    const token = getAuthToken();
    if (!token) {
      router.push('/join');
      return;
    }
    setSelectedCollectionForPay(collection);
    setUtr('');
    setClaimStatus(null);
  }

  function copyToClipboard(text: string) {
    navigator.clipboard.writeText(text);
    setCopiedUpi(true);
    setTimeout(() => setCopiedUpi(false), 2000);
  }

  async function handleClaimPayment(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedCollectionForPay || utr.trim().length < 6) return;

    setClaimLoading(true);
    setClaimStatus(null);

    try {
      const res = await fetchApi('/api/v1/payment_claims', {
        method: 'POST',
        body: JSON.stringify({
          purchasable_type: 'PaidMediaCollection',
          purchasable_id: selectedCollectionForPay.id,
          utr: utr.trim(),
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to submit claim.');
      }

      setClaimStatus({ success: true, message: data.message });
      await loadCreator();
      setTimeout(() => {
        setSelectedCollectionForPay(null);
      }, 1500);
    } catch (err: any) {
      setClaimStatus({ success: false, message: err.message || 'Error claiming payment.' });
    } finally {
      setClaimLoading(false);
    }
  }

  if (loading) {
    return (
      <div>
        <Header showBack title={`@${handle}`} />
        <div style={{ padding: '60px 16px', textAlign: 'center', color: 'var(--w-sub)' }}>
          Loading profile...
        </div>
      </div>
    );
  }

  if (error || !creator) {
    return (
      <div>
        <Header showBack title="Not Found" />
        <div style={{ padding: '60px 16px', textAlign: 'center' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>Creator not found</h2>
          <p style={{ fontSize: '13px', color: 'var(--w-sub)', marginBottom: '20px' }}>
            We could not find a creator with handle @{handle}.
          </p>
          <Link href="/discover" className="w-btn w-btn-pink" style={{ padding: '10px 20px', fontSize: '13px' }}>
            Explore Creators
          </Link>
        </div>
      </div>
    );
  }

  const effectiveUpi = creator.upi_id || `${creator.handle}@okhdfcbank`;

  return (
    <div>
      <Header showBack title={`@${creator.handle}`} />

      {/* Creator Hero Header */}
      <div style={{ padding: '20px 16px 16px', borderBottom: '1px solid var(--w-line)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '72px',
              height: '72px',
              borderRadius: '50%',
              background: 'var(--w-raise)',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '28px',
              fontWeight: 800,
              flexShrink: 0,
              border: '2px solid var(--w-line)',
            }}
          >
            {creator.avatar_url ? (
              <img src={resolveMediaUrl(creator.avatar_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            ) : (
              creator.name[0]
            )}
          </div>

          <div style={{ flex: 1, minWidth: 0 }}>
            <h1 style={{ fontSize: '18px', fontWeight: 800, letterSpacing: '-0.02em', margin: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {creator.name}
            </h1>
            <div style={{ fontSize: '13px', color: 'var(--w-sub)', marginTop: '2px' }}>
              @{creator.handle}
            </div>
            {creator.category && (
              <span className="w-badge-vip" style={{ display: 'inline-block', marginTop: '6px', fontSize: '10px', padding: '3px 8px' }}>
                {creator.category}
              </span>
            )}
          </div>

          <button
            onClick={handleToggleFollow}
            disabled={followLoading}
            className="w-btn"
            style={{
              padding: '8px 18px',
              fontSize: '13px',
              fontWeight: 800,
              background: creator.is_following ? 'var(--w-gold-bg)' : 'var(--w-btn-gradient)',
              color: creator.is_following ? 'var(--w-gold)' : '#fff',
              border: creator.is_following ? '1px solid var(--w-gold-line)' : 'none',
              boxShadow: creator.is_following ? 'var(--w-gold-glow)' : 'var(--w-pink-glow)',
              flexShrink: 0,
            }}
          >
            {creator.is_following ? 'Following' : 'Follow'}
          </button>
        </div>

        {creator.bio && (
          <p style={{ fontSize: '13.5px', lineHeight: 1.45, color: 'var(--w-text)', marginTop: '14px', marginBottom: '14px' }}>
            {creator.bio}
          </p>
        )}

        {/* Stats Row */}
        <div style={{ display: 'flex', gap: '24px', paddingTop: '10px', borderTop: '1px solid var(--w-line)', fontSize: '13px' }}>
          <div>
            <strong style={{ fontWeight: 800, color: 'var(--w-text)' }}>{creator.followers_count}</strong>{' '}
            <span style={{ color: 'var(--w-sub)' }}>fans</span>
          </div>
          <div>
            <strong style={{ fontWeight: 800, color: 'var(--w-text)' }}>{creator.collections_count}</strong>{' '}
            <span style={{ color: 'var(--w-sub)' }}>vaults</span>
          </div>
          <div>
            <strong style={{ fontWeight: 800, color: 'var(--w-text)' }}>{creator.posts_count}</strong>{' '}
            <span style={{ color: 'var(--w-sub)' }}>posts</span>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: '1px solid var(--w-line)' }}>
        <button
          onClick={() => setActiveTab('collections')}
          style={{
            flex: 1,
            padding: '12px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'collections' ? '2px solid var(--w-pink)' : '2px solid transparent',
            color: activeTab === 'collections' ? 'var(--w-pink)' : 'var(--w-sub)',
            fontSize: '13px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
        >
          Vault ({collections.length})
        </button>
        <button
          onClick={() => setActiveTab('posts')}
          style={{
            flex: 1,
            padding: '12px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'posts' ? '2px solid var(--w-pink)' : '2px solid transparent',
            color: activeTab === 'posts' ? 'var(--w-pink)' : 'var(--w-sub)',
            fontSize: '13px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
        >
          Posts ({posts.length})
        </button>
        {lives.length > 0 && (
          <button
            onClick={() => setActiveTab('lives')}
            style={{
              flex: 1,
              padding: '12px',
              background: 'none',
              border: 'none',
              borderBottom: activeTab === 'lives' ? '2px solid var(--w-pink)' : '2px solid transparent',
              color: activeTab === 'lives' ? 'var(--w-pink)' : 'var(--w-sub)',
              fontSize: '13px',
              fontWeight: 700,
              cursor: 'pointer',
            }}
          >
            Lives ({lives.length})
          </button>
        )}
      </div>

      {/* Tab Content */}
      <div style={{ padding: '16px 16px 80px' }}>
        {activeTab === 'collections' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {collections.length > 0 ? (
              collections.map((c) => (
                <div key={c.id} className="w-card">
                  <div style={{ position: 'relative', height: '240px', background: '#000' }}>
                    {c.cover_image_url ? (
                      <img src={resolveMediaUrl(c.cover_image_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    ) : (
                      <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--w-sub)' }}>
                        Cover preview
                      </div>
                    )}
                    <div style={{ position: 'absolute', top: '10px', right: '10px', background: 'rgba(0,0,0,0.65)', backdropFilter: 'blur(8px)', color: c.unlocked ? 'var(--w-gold)' : '#fff', fontSize: '11px', fontWeight: 800, padding: '4px 8px', borderRadius: '12px' }}>
                      {c.unlocked ? '✨ Unlocked' : '🔒 Locked'}
                    </div>
                  </div>

                  <div style={{ padding: '14px' }}>
                    <h3 style={{ fontSize: '16px', fontWeight: 800, marginBottom: '4px' }}>{c.title}</h3>
                    {c.description && (
                      <p style={{ fontSize: '13px', color: 'var(--w-sub)', marginBottom: '12px', lineHeight: 1.4 }}>
                        {c.description}
                      </p>
                    )}
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '8px', borderTop: '1px solid var(--w-line)' }}>
                      <span style={{ fontSize: '13px', color: 'var(--w-sub)' }}>{c.items_count} items · {c.unlocks_count} unlocked</span>
                      {c.unlocked ? (
                        <button
                          onClick={() => setSelectedCollectionForView(c)}
                          className="w-btn w-btn-raised"
                          style={{ padding: '8px 16px', fontSize: '13px', color: 'var(--w-gold)', border: '1px solid var(--w-gold-line)' }}
                        >
                          View Collection ✨
                        </button>
                      ) : (
                        <button
                          onClick={() => openPaySheet(c)}
                          className="w-btn w-btn-pink"
                          style={{ padding: '8px 16px', fontSize: '13px' }}
                        >
                          Unlock {formatPrice(c.price_cents, c.currency)}
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <div style={{ textAlign: 'center', padding: '40px', color: 'var(--w-sub)' }}>
                No collections dropped yet.
              </div>
            )}
          </div>
        )}

        {activeTab === 'posts' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {posts.length > 0 ? (
              posts.map((p) => (
                <div key={p.id} className="w-card" style={{ padding: '14px' }}>
                  <p style={{ fontSize: '14px', lineHeight: 1.45, marginBottom: p.has_media ? '12px' : 0 }}>
                    {p.body}
                  </p>
                  {p.has_media && p.media_url && (
                    <div style={{ borderRadius: '10px', overflow: 'hidden', maxHeight: '360px', background: '#000', marginBottom: '10px' }}>
                      {p.video ? (
                        <video src={resolveMediaUrl(p.media_url)} controls playsInline style={{ width: '100%', height: '100%', display: 'block' }} />
                      ) : (
                        <img src={resolveMediaUrl(p.media_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
                      )}
                    </div>
                  )}
                  <div style={{ fontSize: '12px', color: 'var(--w-sub)', display: 'flex', gap: '16px' }}>
                    <span>♥ {p.likes_count} likes</span>
                    <span>💬 {p.comments_count} comments</span>
                  </div>
                </div>
              ))
            ) : (
              <div style={{ textAlign: 'center', padding: '40px', color: 'var(--w-sub)' }}>
                No posts shared yet.
              </div>
            )}
          </div>
        )}

        {activeTab === 'lives' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {lives.map((l) => (
              <div key={l.id} className="w-card" style={{ padding: '14px' }}>
                <span style={{ fontSize: '11px', fontWeight: 800, background: 'var(--w-pink)', color: '#fff', padding: '2px 8px', borderRadius: '8px' }}>
                  {l.status === 'live' ? 'LIVE NOW' : 'SCHEDULED'}
                </span>
                <h3 style={{ fontSize: '15px', fontWeight: 800, marginTop: '8px', marginBottom: '4px' }}>{l.title}</h3>
                <div style={{ fontSize: '12px', color: 'var(--w-sub)' }}>Scheduled for {new Date(l.scheduled_for).toLocaleString()}</div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* IN-APP UPI PAYMENT CLAIM SHEET MODAL */}
      {selectedCollectionForPay && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.75)',
            backdropFilter: 'blur(8px)',
            zIndex: 1000,
            display: 'flex',
            alignItems: 'flex-end',
            justifyContent: 'center',
          }}
          onClick={() => setSelectedCollectionForPay(null)}
        >
          <div
            style={{
              background: 'var(--w-card)',
              borderTop: '1px solid var(--w-line)',
              borderTopLeftRadius: '20px',
              borderTopRightRadius: '20px',
              padding: '24px 20px 36px',
              width: '100%',
              maxWidth: '480px',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 800, color: 'var(--w-pink)', textTransform: 'uppercase' }}>
                  Direct UPI Unlock
                </span>
                <h3 style={{ fontSize: '17px', fontWeight: 800, margin: '2px 0 0' }}>
                  {selectedCollectionForPay.title}
                </h3>
              </div>
              <button
                onClick={() => setSelectedCollectionForPay(null)}
                style={{ background: 'none', border: 'none', color: 'var(--w-sub)', fontSize: '20px', cursor: 'pointer', padding: '4px' }}
              >
                ✕
              </button>
            </div>

            <div style={{ background: 'var(--w-raise)', border: '1px solid var(--w-line)', borderRadius: '14px', padding: '14px', marginBottom: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <span style={{ fontSize: '12px', color: 'var(--w-sub)' }}>Amount to pay</span>
                <span style={{ fontSize: '18px', fontWeight: 800, color: 'var(--w-pink)' }}>
                  {formatPrice(selectedCollectionForPay.price_cents, selectedCollectionForPay.currency)}
                </span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '12px', color: 'var(--w-sub)' }}>Pay to UPI ID</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <code style={{ fontSize: '13px', fontWeight: 700, color: 'var(--w-gold)' }}>{effectiveUpi}</code>
                  <button
                    onClick={() => copyToClipboard(effectiveUpi)}
                    className="w-btn w-btn-raised"
                    style={{ padding: '3px 8px', fontSize: '11px', borderRadius: '10px' }}
                  >
                    {copiedUpi ? 'Copied!' : 'Copy'}
                  </button>
                </div>
              </div>
            </div>

            {/* Quick UPI App Link */}
            <div style={{ marginBottom: '16px' }}>
              <a
                href={`upi://pay?pa=${effectiveUpi}&pn=${encodeURIComponent(creator.name)}&am=${selectedCollectionForPay.price_cents / 100}&cu=INR`}
                className="w-btn w-btn-raised"
                style={{
                  display: 'block',
                  textAlign: 'center',
                  padding: '10px',
                  borderRadius: '14px',
                  fontSize: '13px',
                  fontWeight: 700,
                  color: 'var(--w-text)',
                  border: '1px solid var(--w-line)',
                  textDecoration: 'none',
                }}
              >
                ⚡ Open Installed UPI App (GPay / PhonePe / Paytm)
              </a>
            </div>

            {claimStatus && (
              <div
                style={{
                  background: claimStatus.success ? 'rgba(74, 222, 128, 0.15)' : 'rgba(248, 113, 150, 0.15)',
                  border: `1px solid ${claimStatus.success ? 'var(--w-green)' : 'var(--w-rose)'}`,
                  color: claimStatus.success ? 'var(--w-green)' : 'var(--w-rose)',
                  padding: '10px 14px',
                  borderRadius: '12px',
                  fontSize: '13px',
                  marginBottom: '14px',
                  textAlign: 'center',
                }}
              >
                {claimStatus.message}
              </div>
            )}

            <form onSubmit={handleClaimPayment} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '11.5px', fontWeight: 700, color: 'var(--w-sub)', marginBottom: '6px', textTransform: 'uppercase' }}>
                  12-Digit Bank UTR / Reference No.
                </label>
                <input
                  type="text"
                  maxLength={12}
                  placeholder="e.g. 428719283746"
                  value={utr}
                  onChange={(e) => setUtr(e.target.value.replace(/\D/g, ''))}
                  required
                  style={{
                    width: '100%',
                    background: 'var(--w-raise)',
                    border: '1px solid var(--w-line)',
                    borderRadius: '12px',
                    padding: '12px 14px',
                    fontSize: '16px',
                    fontWeight: 700,
                    letterSpacing: '0.1em',
                    color: 'var(--w-text)',
                    outline: 'none',
                  }}
                />
              </div>

              <button
                type="submit"
                disabled={claimLoading || utr.trim().length < 6}
                className="w-btn w-btn-pink"
                style={{
                  width: '100%',
                  padding: '14px',
                  borderRadius: '24px',
                  fontSize: '14px',
                  fontWeight: 800,
                  marginTop: '4px',
                  opacity: claimLoading || utr.trim().length < 6 ? 0.6 : 1,
                }}
              >
                {claimLoading ? 'Verifying...' : 'Submit 12-Digit UTR Claim'}
              </button>
            </form>
          </div>
        </div>
      )}

      {/* IN-APP UNLOCKED MEDIA VIEWER MODAL */}
      {selectedCollectionForView && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.92)',
            backdropFilter: 'blur(10px)',
            zIndex: 1000,
            display: 'flex',
            flexDirection: 'column',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', borderBottom: '1px solid var(--w-line)' }}>
            <div>
              <div style={{ fontSize: '11px', fontWeight: 800, color: 'var(--w-gold)' }}>✨ UNLOCKED VAULT SET</div>
              <h2 style={{ fontSize: '16px', fontWeight: 800, margin: 0 }}>{selectedCollectionForView.title}</h2>
            </div>
            <button
              onClick={() => setSelectedCollectionForView(null)}
              style={{ background: 'none', border: 'none', color: '#fff', fontSize: '24px', cursor: 'pointer', padding: '4px 8px' }}
            >
              ✕
            </button>
          </div>

          <div style={{ flex: 1, overflowY: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: '20px', maxWidth: '600px', margin: '0 auto', width: '100%' }}>
            {selectedCollectionForView.posts && selectedCollectionForView.posts.length > 0 ? (
              selectedCollectionForView.posts.map((post: any, idx: number) => (
                <div key={post.id || idx} className="w-card" style={{ overflow: 'hidden' }}>
                  <div style={{ background: '#000', position: 'relative' }}>
                    {post.media_type === 'video' ? (
                      <video src={resolveMediaUrl(post.media_url)} controls playsInline style={{ width: '100%', maxHeight: '480px', display: 'block' }} />
                    ) : (
                      <img src={resolveMediaUrl(post.media_url)} alt="" style={{ width: '100%', maxHeight: '520px', objectFit: 'contain', display: 'block' }} />
                    )}
                  </div>
                  {post.caption && (
                    <div style={{ padding: '12px', fontSize: '13.5px', color: 'var(--w-text)' }}>
                      {post.caption}
                    </div>
                  )}
                </div>
              ))
            ) : (
              <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--w-sub)' }}>
                {selectedCollectionForView.items_count} media items in this set.
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default function CreatorProfilePage(props: CreatorProfileProps) {
  return (
    <Suspense fallback={<div style={{ padding: '60px 16px', textAlign: 'center', color: 'var(--w-sub)' }}>Loading profile...</div>}>
      <ProfileContent params={props.params} />
    </Suspense>
  );
}
