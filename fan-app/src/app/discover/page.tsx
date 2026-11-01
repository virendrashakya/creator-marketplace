'use client';

import { Suspense, useEffect, useState } from 'react';
import Link from 'next/link';
import { useSearchParams, useRouter } from 'next/navigation';
import Header from '@/components/Header';
import { fetchApi, getAuthToken, resolveMediaUrl } from '@/lib/api';

function DiscoverContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [activeTab, setActiveTab] = useState<'content' | 'creators'>('content');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [categories, setCategories] = useState<string[]>([]);
  const [trendingCollections, setTrendingCollections] = useState<any[]>([]);
  const [featuredCreators, setFeaturedCreators] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [followLoading, setFollowLoading] = useState<Record<string, boolean>>({});

  useEffect(() => {
    const tabParam = searchParams.get('tab');
    if (tabParam === 'creators') {
      setActiveTab('creators');
    } else if (tabParam === 'content') {
      setActiveTab('content');
    }
  }, [searchParams]);

  useEffect(() => {
    async function loadDiscover() {
      try {
        const res = await fetchApi('/api/v1/discover');
        if (res.ok) {
          const data = await res.json();
          setCategories(data.categories || []);
          setTrendingCollections(data.trending_collections || []);
          setFeaturedCreators(data.featured_creators || []);
        }
      } catch (e) {
        console.error('Failed to load discover data:', e);
      } finally {
        setLoading(false);
      }
    }
    loadDiscover();
  }, []);

  async function handleToggleFollow(creator: any) {
    const token = getAuthToken();
    if (!token) {
      router.push('/join');
      return;
    }

    setFollowLoading((prev) => ({ ...prev, [creator.handle]: true }));
    try {
      const method = creator.is_following ? 'DELETE' : 'POST';
      const res = await fetchApi(`/api/v1/creators/${creator.handle}/follow`, { method });
      if (res.ok) {
        const data = await res.json();
        setFeaturedCreators((prev) =>
          prev.map((c) =>
            c.handle === creator.handle
              ? { ...c, is_following: data.is_following, followers_count: data.followers_count }
              : c
          )
        );
      }
    } catch (e) {
      console.error('Follow failed:', e);
    } finally {
      setFollowLoading((prev) => ({ ...prev, [creator.handle]: false }));
    }
  }

  function formatPrice(cents: number, currency: string = 'INR') {
    const symbol = currency === 'INR' ? '₹' : '$';
    return `${symbol}${(cents / 100).toLocaleString('en-IN')}`;
  }

  // Filter content based on category
  const filteredCollections = selectedCategory
    ? trendingCollections.filter((c) => c.category === selectedCategory)
    : trendingCollections;

  // Filter creators based on category
  const filteredCreators = selectedCategory
    ? featuredCreators.filter((c) => c.category === selectedCategory)
    : featuredCreators;

  return (
    <div>
      <Header title="Explore" />

      {/* Pill-Type Subtabs: Explore Content vs Explore Creators */}
      <div style={{ display: 'flex', gap: '10px', padding: '14px 16px', borderBottom: '1px solid var(--w-line)', background: 'rgba(14, 12, 18, 0.4)' }}>
        <button
          onClick={() => {
            setActiveTab('content');
            window.history.replaceState(null, '', '/discover?tab=content');
          }}
          className="w-btn"
          style={{
            flex: 1,
            background: activeTab === 'content' ? 'var(--w-btn-gradient)' : 'rgba(255, 255, 255, 0.04)',
            color: activeTab === 'content' ? '#fff' : 'var(--w-sub)',
            boxShadow: activeTab === 'content' ? 'var(--w-pink-glow)' : 'none',
            border: activeTab === 'content' ? 'none' : '1px solid var(--w-line)',
            padding: '10px 16px',
            fontSize: '13px',
            fontWeight: 800,
            letterSpacing: '0.01em',
          }}
        >
          Explore Content
        </button>
        <button
          onClick={() => {
            setActiveTab('creators');
            window.history.replaceState(null, '', '/discover?tab=creators');
          }}
          className="w-btn"
          style={{
            flex: 1,
            background: activeTab === 'creators' ? 'var(--w-btn-gradient)' : 'rgba(255, 255, 255, 0.04)',
            color: activeTab === 'creators' ? '#fff' : 'var(--w-sub)',
            boxShadow: activeTab === 'creators' ? 'var(--w-pink-glow)' : 'none',
            border: activeTab === 'creators' ? 'none' : '1px solid var(--w-line)',
            padding: '10px 16px',
            fontSize: '13px',
            fontWeight: 800,
            letterSpacing: '0.01em',
          }}
        >
          Explore Creators
        </button>
      </div>

      <div style={{ padding: '14px 16px 80px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {/* Category Filter Pills */}
        {categories.length > 0 && (
          <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '2px', scrollbarWidth: 'none' }}>
            <button
              onClick={() => setSelectedCategory(null)}
              style={{
                background: selectedCategory === null ? 'var(--w-text)' : 'var(--w-card)',
                color: selectedCategory === null ? 'var(--w-page)' : 'var(--w-text)',
                border: '1px solid var(--w-line)',
                padding: '6px 14px',
                borderRadius: '16px',
                fontSize: '12px',
                fontWeight: 700,
                whiteSpace: 'nowrap',
                cursor: 'pointer',
              }}
            >
              All
            </button>
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(selectedCategory === cat ? null : cat)}
                style={{
                  background: selectedCategory === cat ? 'var(--w-pink)' : 'var(--w-card)',
                  color: selectedCategory === cat ? '#fff' : 'var(--w-text)',
                  border: '1px solid var(--w-line)',
                  padding: '6px 14px',
                  borderRadius: '16px',
                  fontSize: '12px',
                  fontWeight: 700,
                  whiteSpace: 'nowrap',
                  cursor: 'pointer',
                }}
              >
                {cat}
              </button>
            ))}
          </div>
        )}

        {/* 1. EXPLORE CONTENT SUBTAB */}
        {activeTab === 'content' && (
          <section>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <h2 style={{ fontSize: '16px', fontWeight: 800 }}>Trending Vault Collections</h2>
              <span style={{ fontSize: '12px', color: 'var(--w-sub)' }}>Direct UPI Unlocks</span>
            </div>

            {loading ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--w-sub)' }}>Loading drops...</div>
            ) : filteredCollections.length > 0 ? (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                {filteredCollections.map((c) => (
                  <div key={c.id} className="w-card" style={{ display: 'flex', flexDirection: 'column' }}>
                    <Link href={`/${c.creator_handle}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                      <div style={{ height: '170px', background: 'var(--w-raise)', position: 'relative', overflow: 'hidden' }}>
                        {c.cover_preview_url ? (
                          <img src={resolveMediaUrl(c.cover_preview_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                        ) : (
                          <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--w-sub)' }}>
                            Vault Drop
                          </div>
                        )}
                        <span style={{ position: 'absolute', top: '8px', right: '8px', background: 'rgba(0,0,0,0.65)', backdropFilter: 'blur(6px)', color: 'var(--w-gold)', fontSize: '10.5px', fontWeight: 800, padding: '3px 8px', borderRadius: '12px' }}>
                          🔒 Locked
                        </span>
                      </div>
                    </Link>

                    <div style={{ padding: '10px', display: 'flex', flexDirection: 'column', flexGrow: 1, justifyContent: 'space-between' }}>
                      <div>
                        <Link href={`/${c.creator_handle}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                          <div style={{ fontSize: '13px', fontWeight: 800, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                            {c.title}
                          </div>
                        </Link>
                        <Link href={`/${c.creator_handle}`} style={{ fontSize: '11.5px', color: 'var(--w-sub)', marginTop: '2px', display: 'block' }}>
                          @{c.creator_handle}
                        </Link>
                      </div>

                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '10px' }}>
                        <span style={{ fontSize: '13px', fontWeight: 800, color: 'var(--w-pink)' }}>
                          {formatPrice(c.price_cents, c.currency)}
                        </span>
                        <Link href={`/${c.creator_handle}`} className="w-btn w-btn-pink" style={{ padding: '5px 12px', fontSize: '11.5px' }}>
                          Unlock
                        </Link>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div style={{ padding: '40px 16px', textAlign: 'center', color: 'var(--w-sub)' }}>
                No content found in this category.
              </div>
            )}
          </section>
        )}

        {/* 2. EXPLORE CREATORS SUBTAB */}
        {activeTab === 'creators' && (
          <section>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <h2 style={{ fontSize: '16px', fontWeight: 800 }}>Featured Creators</h2>
              <span style={{ fontSize: '12px', color: 'var(--w-sub)' }}>{filteredCreators.length} verified creators</span>
            </div>

            {loading ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--w-sub)' }}>Loading creators...</div>
            ) : filteredCreators.length > 0 ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {filteredCreators.map((u) => (
                  <div key={u.id} className="w-card" style={{ padding: '14px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                      <Link href={`/${u.handle}`} style={{ display: 'flex', alignItems: 'center', gap: '12px', textDecoration: 'none', color: 'inherit', flex: 1, minWidth: 0 }}>
                        <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'var(--w-raise)', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 800, fontSize: '18px', flexShrink: 0, border: '1px solid var(--w-line)' }}>
                          {u.avatar_url ? (
                            <img src={resolveMediaUrl(u.avatar_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                          ) : (
                            u.name[0]
                          )}
                        </div>
                        <div style={{ flex: 1, minWidth: 0 }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                            <span style={{ fontSize: '14.5px', fontWeight: 800, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                              {u.name}
                            </span>
                            <span style={{ color: 'var(--w-pink)', fontSize: '13px' }}>✓</span>
                          </div>
                          <div style={{ fontSize: '12px', color: 'var(--w-sub)', marginTop: '1px' }}>
                            @{u.handle} · {u.followers_count} fans
                          </div>
                        </div>
                      </Link>

                      <div style={{ display: 'flex', gap: '8px', flexShrink: 0 }}>
                        <button
                          onClick={() => handleToggleFollow(u)}
                          disabled={followLoading[u.handle]}
                          className="w-btn"
                          style={{
                            padding: '6px 14px',
                            fontSize: '12px',
                            fontWeight: 700,
                            background: u.is_following ? 'var(--w-gold-bg)' : 'var(--w-btn-gradient)',
                            color: u.is_following ? 'var(--w-gold)' : '#fff',
                            border: u.is_following ? '1px solid var(--w-gold-line)' : 'none',
                            boxShadow: u.is_following ? 'var(--w-gold-glow)' : 'var(--w-pink-glow)',
                          }}
                        >
                          {u.is_following ? 'Following' : 'Follow'}
                        </button>
                        <Link href={`/${u.handle}`} className="w-btn w-btn-raised" style={{ padding: '6px 14px', fontSize: '12px', fontWeight: 600 }}>
                          View Profile
                        </Link>
                      </div>
                    </div>

                    {u.bio && (
                      <p style={{ fontSize: '13px', color: 'var(--w-sub)', lineHeight: 1.45, margin: 0 }}>
                        {u.bio}
                      </p>
                    )}

                    {u.category && (
                      <div>
                        <span className="w-badge-vip" style={{ fontSize: '10px', padding: '3px 9px' }}>
                          {u.category}
                        </span>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            ) : (
              <div style={{ padding: '40px 16px', textAlign: 'center', color: 'var(--w-sub)' }}>
                No creators found in this category.
              </div>
            )}
          </section>
        )}
      </div>
    </div>
  );
}

export default function DiscoverPage() {
  return (
    <Suspense fallback={<div style={{ padding: '60px 16px', textAlign: 'center', color: 'var(--w-sub)' }}>Loading explore...</div>}>
      <DiscoverContent />
    </Suspense>
  );
}
