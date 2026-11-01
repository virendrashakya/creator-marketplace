'use client';

import Link from 'next/link';
import { usePathname, useSearchParams } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function BottomNav() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [inPostView, setInPostView] = useState(false);

  useEffect(() => {
    const checkPostView = () => {
      const hasPostParam = new URLSearchParams(window.location.search).has('post');
      const bodyHasClass = typeof document !== 'undefined' && document.body.classList.contains('hide-bottom-nav');
      setInPostView(hasPostParam || bodyHasClass);
    };

    checkPostView();
    window.addEventListener('popstate', checkPostView);
    window.addEventListener('wf_view_change', checkPostView);
    return () => {
      window.removeEventListener('popstate', checkPostView);
      window.removeEventListener('wf_view_change', checkPostView);
    };
  }, [pathname, searchParams]);

  // Bottom navigation is not required on single post view screen
  if (inPostView || searchParams.has('post')) {
    return null;
  }

  return (
    <nav className="w-bottom-nav">
      {/* 1. Feed */}
      <Link
        href="/feed"
        className={`w-nav-item ${pathname === '/feed' || pathname === '/' ? 'active' : ''}`}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth={pathname === '/feed' || pathname === '/' ? '2.4' : '2'}
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <rect x="3" y="3" width="18" height="18" rx="3" />
          <line x1="7" y1="8" x2="17" y2="8" />
          <line x1="7" y1="12" x2="17" y2="12" />
          <line x1="7" y1="16" x2="13" y2="16" />
        </svg>
        <span style={{ fontSize: '10px', fontWeight: 800, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
          Feed
        </span>
      </Link>

      {/* 2. Vault */}
      <Link
        href="/unlocks"
        className={`w-nav-item ${pathname === '/unlocks' ? 'active' : ''}`}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth={pathname === '/unlocks' ? '2.4' : '2'}
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <rect x="4" y="10" width="16" height="11" rx="3" />
          <path d="M8 10V7a4 4 0 0 1 8 0v3" />
          <circle cx="12" cy="15.5" r="1.5" fill="currentColor" />
        </svg>
        <span style={{ fontSize: '10px', fontWeight: 800, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
          Vault
        </span>
      </Link>

      {/* 3. Post + / Chats */}
      <Link
        href="/discover?tab=content"
        className={`w-nav-item ${pathname === '/notifications' ? 'active' : ''}`}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
          <line x1="12" y1="8" x2="12" y2="14" />
          <line x1="9" y1="11" x2="15" y2="11" />
        </svg>
        <span style={{ fontSize: '10px', fontWeight: 800, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
          Post +
        </span>
      </Link>

      {/* 4. VIP */}
      <Link
        href="/discover?tab=creators"
        className={`w-nav-item ${pathname === '/discover' ? 'active' : ''}`}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill={pathname === '/discover' ? 'currentColor' : 'none'}
          stroke="currentColor"
          strokeWidth={pathname === '/discover' ? '2.4' : '2'}
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
        </svg>
        <span style={{ fontSize: '10px', fontWeight: 800, letterSpacing: '0.08em', textTransform: 'uppercase' }}>
          VIP
        </span>
      </Link>
    </nav>
  );
}
