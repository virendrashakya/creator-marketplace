'use client';

import { useEffect, useState, useRef } from 'react';
import Link from 'next/link';
import { fetchApi, getAuthToken, getCurrentUser, removeAuthToken, resolveMediaUrl } from '@/lib/api';

/* ==========================================================================
   HIGH-QUALITY VECTOR SVG ICONS (Resolution-Independent Vectors)
   ========================================================================== */

function BackArrowIcon({ size = 20 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="15 18 9 12 15 6" />
    </svg>
  );
}

function HeartIcon({ filled = false, size = 18 }: { filled?: boolean; size?: number }) {
  if (filled) {
    return (
      <svg
        width={size}
        height={size}
        viewBox="0 0 24 24"
        fill="var(--w-pink)"
        stroke="var(--w-pink)"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        style={{ filter: 'drop-shadow(0 0 8px rgba(255, 23, 103, 0.6))' }}
      >
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </svg>
    );
  }
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
    </svg>
  );
}

function CommentIcon({ size = 18 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
    </svg>
  );
}

function BookmarkIcon({ filled = false, size = 18 }: { filled?: boolean; size?: number }) {
  if (filled) {
    return (
      <svg
        width={size}
        height={size}
        viewBox="0 0 24 24"
        fill="var(--w-gold)"
        stroke="var(--w-gold)"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        style={{ filter: 'drop-shadow(0 0 8px rgba(245, 185, 66, 0.6))' }}
      >
        <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
      </svg>
    );
  }
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
    </svg>
  );
}

function ShareIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="18" cy="5" r="3" />
      <circle cx="6" cy="12" r="3" />
      <circle cx="18" cy="19" r="3" />
      <line x1="8.59" y1="13.51" x2="15.42" y2="17.49" />
      <line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />
    </svg>
  );
}

function MoreIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="1.5" fill="currentColor" />
      <circle cx="19" cy="12" r="1.5" fill="currentColor" />
      <circle cx="5" cy="12" r="1.5" fill="currentColor" />
    </svg>
  );
}

function LockIcon({ size = 14 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
      <path d="M7 11V7a5 5 0 0 1 10 0v4" />
    </svg>
  );
}

function BagIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
      <line x1="3" y1="6" x2="21" y2="6" />
      <path d="M16 10a4 4 0 0 1-8 0" />
    </svg>
  );
}

function SendArrowIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor">
      <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z" />
    </svg>
  );
}

function SmileyIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" />
      <path d="M8 14s1.5 2 4 2 4-2 4-2" />
      <line x1="9" y1="9" x2="9.01" y2="9" />
      <line x1="15" y1="9" x2="15.01" y2="9" />
    </svg>
  );
}

function VolumeIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
      <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" />
    </svg>
  );
}

function Rewind10Icon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M1 4v6h6" />
      <path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10" />
      <text x="12" y="15" fontSize="7.5" fontWeight="bold" fill="currentColor" textAnchor="middle">10</text>
    </svg>
  );
}

function Forward10Icon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M23 4v6h-6" />
      <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
      <text x="12" y="15" fontSize="7.5" fontWeight="bold" fill="currentColor" textAnchor="middle">10</text>
    </svg>
  );
}

/* ==========================================================================
   INTERFACES & MOCK DATA
   ========================================================================== */

interface Creator {
  id: number;
  handle: string;
  name: string;
  avatar_url?: string;
  followers_count: number;
}

interface FeedItem {
  id: string;
  item_type: 'post' | 'poll' | 'collection' | 'audio' | 'video_teaser' | 'live_replay';
  published_at: string;
  creator: Creator;
  badge?: string;
  subline?: string;
  dropIdTag?: string;
  tags?: string[];
  target: any;
  category: 'spicy' | 'teasers' | 'close_friends' | 'all';
  poll?: {
    question: string;
    closesIn: string;
    totalVotes: number;
    options: { id: number; text: string; votes: number; percent: number }[];
  };
  audio?: {
    title: string;
    subtitle?: string;
    duration: string;
    listens: string;
  };
  stream?: {
    statusText: string;
    duration: string;
    archiveTitle: string;
    setupNote: string;
  };
}

export default function FeedPage() {
  const [feedItems, setFeedItems] = useState<FeedItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [mounted, setMounted] = useState(false);
  const [user, setUser] = useState<any>(null);


  // PAGE-BASED POST VIEW (NO POPUP - FULL PAGE WITH BACK BUTTON)
  const [activePost, setActivePost] = useState<FeedItem | null>(null);
  const savedScrollPosition = useRef(0);

  // Like states
  const [likedPosts, setLikedPosts] = useState<Record<string, boolean>>({
    c_tara_vault: true,
  });
  const [likeCounts, setLikeCounts] = useState<Record<string, number>>({
    p_anjali_1: 3800,
    p_kiara_poll: 1400,
    c_tara_vault: 4900,
    p_rhea_audio: 1900,
    p_zara_video: 4200,
    p_kiara_replay: 3500,
  });

  // Bookmark states
  const [savedPosts, setSavedPosts] = useState<Record<string, boolean>>({
    c_tara_vault: true,
  });

  // Follow states
  const [followingCreators, setFollowingCreators] = useState<Record<string, boolean>>({});

  // Poll voting state
  const [pollVoted, setPollVoted] = useState<number | null>(1);
  const [pollOptions, setPollOptions] = useState([
    { id: 1, text: 'Sheer Rose Bodysuit · 341 votes', percent: 68 },
    { id: 2, text: 'Obsidian Midnight Silk', percent: 32 },
  ]);

  // Audio player state
  const [isPlayingAudio, setIsPlayingAudio] = useState(false);

  // Video teaser state
  const [isMuted, setIsMuted] = useState(true);

  // Quick spicy reactions live counter
  const [reactionsState, setReactionsState] = useState<Record<string, any>>({
    p_anjali_1: { fire: 1800, kiss: 1100, peach: 850, heart: 620 },
    p_kiara_poll: { fire: 720, kiss: 384 },
    c_tara_vault: { fire: 2400, kiss: 1800 },
    p_rhea_audio: { fire: 1900, devil: 840, pepper: 620, kiss: 480 },
    p_zara_video: { fire: 1800, kiss: 1100, peach: 850, heart: 620 },
    p_kiara_replay: { fire: 1200, kiss: 850, candle: 420 },
  });

  // Direct UPI Monetization Sheet
  const [paySheetCollection, setPaySheetCollection] = useState<any | null>(null);
  const [copiedUpi, setCopiedUpi] = useState(false);
  const [utr, setUtr] = useState('');
  const [claimLoading, setClaimLoading] = useState(false);
  const [claimStatus, setClaimStatus] = useState<{ success?: boolean; message?: string } | null>(null);

  // Comments map per post
  const [commentsMap, setCommentsMap] = useState<Record<string, Array<{ id: number; author: string; handle: string; text: string; timeAgo: string; vip?: boolean; isCreator?: boolean; pinned?: boolean; timestamp?: string; likes?: number; likedByCreator?: boolean; repliesCount?: number }>>>({
    c_tara_vault: [
      { id: 1, author: 'Tara Kapoor', handle: 'tarakapoor', text: 'Vault unlocks happen instantly via direct UPI matching! Enjoy the 4K uncompressed set 🫦', timeAgo: 'Pinned • 28m ago', isCreator: true, pinned: true, likes: 218 },
      { id: 2, author: 'Kabir Verma', handle: 'kabir_v', text: 'Just unlocked via Google Pay — the midnight lighting in frame 7 and the 60fps bedroom BTS is easily your best production quality yet! 🔥', timeAgo: '22m ago', vip: true, likes: 34, likedByCreator: true },
      { id: 3, author: 'Sanya Malhotra', handle: 'sanyam', text: 'The neon ruby rim lights against the dark velvet curtains give such a high-end cinematic vibe. Who shot this editorial set with you?', timeAgo: '16m ago', likes: 19, repliesCount: 2 },
      { id: 4, author: 'Aryan Deshmukh', handle: 'aryand', text: 'Permanent vault unlock worked smoothly. The 4K resolution on iPad OLED is jaw-droppingly crisp 🔥', timeAgo: '8m ago', likes: 11 },
    ],
    p_kiara_replay: [
      { id: 5, author: 'Kabir Verma', handle: 'kabir_v', text: 'That answer at the 18-minute mark about your late-night modeling ritual was completely raw and honest. The amber candle lighting was insane! 🕯️✨', timeAgo: 'Pinned • 18:48', timestamp: 'Timestamp 18:48', pinned: true, likes: 84 },
      { id: 6, author: "Natasha D'Souza", handle: 'natashadsouza', text: 'The acoustic whispering session at the end was pure ASMR heaven. So glad this replay is permanently unlocked in the lounge!', timeAgo: '32:15', timestamp: 'Timestamp 32:15', likes: 52 },
      { id: 7, author: 'Arjun Nair', handle: 'arjunnair', text: 'Unlocked via UPI in seconds. The 60fps quality is pristine, literally feels like being on a private video call in her penthouse.', timeAgo: '44:02', timestamp: 'Timestamp 44:02', likes: 39 },
    ],
    p_rhea_audio: [
      { id: 8, author: 'Rhea Sen', handle: 'rheasen', text: 'Listen with noise cancellation turned on! Dropping part 2 tomorrow night at midnight 🌙', timeAgo: 'Pinned • 1h ago', isCreator: true, pinned: true, likes: 182 },
      { id: 9, author: 'Priya Sharma', handle: 'priyastyles', text: 'Gave me goosebumps instantly! When you whispered directly into the left ear at 0:38 I literally felt the breath. Unreal spatial depth 🫦🎧', timeAgo: '1h ago', likes: 64, likedByCreator: true, repliesCount: 3 },
      { id: 10, author: 'Rohan K.', handle: 'rohank', text: 'The FLAC bitrate on this audio note is incredible. Zero white noise or compression artifacts. Need a 30-minute sleep tape of this 😈✨', timeAgo: '48m ago', likes: 38 },
      { id: 11, author: 'Meera Sen', handle: 'meera_s', text: 'What binaural dummy head mic rig did you use for this bedroom session Rhea? The stereo pan separation is masterclass quality 🔥', timeAgo: '25m ago', likes: 17 },
    ],
    p_anjali_1: [
      { id: 12, author: 'Kabir A.', handle: 'kabiranand', text: 'The sheer drape and lighting are breathtaking. Unlocked the full 4K set!', timeAgo: '2h ago', vip: true, likes: 45 },
    ],
  });

  const [newCommentText, setNewCommentText] = useState('');

  // Stories List
  const stories = [
    { id: 1, name: 'ANJALI ✦', handle: 'anjalihegde', avatar: '/assets/img/creators/c7.jpg', isLive: true, iconType: 'camera' },
    { id: 2, name: 'TARA', handle: 'tarakapoor', avatar: '/assets/img/creators/c49.jpg', isLive: false, iconType: 'crown' },
    { id: 3, name: 'ZARA', handle: 'zaratrivedi', avatar: '/assets/img/creators/c27.jpg', isLive: false, iconType: 'flame' },
    { id: 4, name: 'RHEA VIP', handle: 'riyapandit', avatar: '/assets/img/creators/c41.jpg', isLive: false, iconType: 'headphones' },
    { id: 5, name: 'KIARA', handle: 'kavyareddy', avatar: '/assets/img/creators/c27.jpg', isLive: false, iconType: 'star' },
  ];

  useEffect(() => {
    setMounted(true);
    setUser(getCurrentUser());

    // Curate exact feed items
    const cards: FeedItem[] = [
      // 1. Anjali Hegde - Midnight Boudoir Sheer Drape
      {
        id: 'p_anjali_1',
        item_type: 'post',
        published_at: '2h ago',
        category: 'spicy',
        badge: 'VIP',
        subline: '@anjalihegde • 2h ago',
        dropIdTag: '#AH-800-4K',
        creator: {
          id: 15,
          handle: 'anjalihegde',
          name: 'Anjali Hegde',
          avatar_url: '/assets/img/creators/c7.jpg',
          followers_count: 3200,
        },
        target: {
          id: 701,
          body: "Midnight boudoir sheer drape for tonight's private set! Dropping the full uncut 4K teaser in 2 hours for all VIP lounge members... 🫦",
          media_url: '/assets/img/creators/c7.jpg',
          tag_top: '● 4K ULTRA HD',
          bottom_banner: '🔒 VIP Solo Clip & Sneak Peek   >',
          likes_count: '3.8k',
          comments_count: '412',
          bookmarks_count: '980',
        },
      },

      // 2. Kiara Roy - Runway Teaser Poll
      {
        id: 'p_kiara_poll',
        item_type: 'poll',
        published_at: '4h ago',
        category: 'teasers',
        badge: 'VIP CLOSE FRIENDS 👑',
        subline: '@kiararoy • 4h ago',
        creator: {
          id: 28,
          handle: 'kiararoy',
          name: 'Kiara Roy',
          avatar_url: '/assets/img/creators/c27.jpg',
          followers_count: 4500,
        },
        poll: {
          question: "Which look for tomorrow night's private runway teaser stream? Help me choose my fit babes 👇✨",
          closesIn: '2h',
          totalVotes: 1182,
          options: [
            { id: 1, text: 'Sheer Rose Bodysuit · 341 votes', votes: 341, percent: 68 },
            { id: 2, text: 'Obsidian Midnight Silk', votes: 160, percent: 32 },
          ],
        },
        target: {
          id: 702,
          body: "Which look for tomorrow night's private runway teaser stream? Help me choose my fit babes 👇✨",
          likes_count: '1.4k',
          comments_count: '184',
        },
      },

      // 3. Tara Kapoor - The Vault Drop
      {
        id: 'c_tara_vault',
        item_type: 'collection',
        published_at: '35m ago',
        category: 'spicy',
        badge: 'VIP VAULT',
        subline: '@tarakapoor • 35m ago',
        dropIdTag: '#VD-499-TK',
        creator: {
          id: 49,
          handle: 'tarakapoor',
          name: 'Tara Kapoor',
          avatar_url: '/assets/img/creators/c49.jpg',
          followers_count: 5800,
        },
        target: {
          id: 801,
          title: '🔥 THE VAULT DROP — Uncensored 4K Midnight Set & BTS',
          description: 'Includes 18 High-Res Uncut Editorial Frames & 15-minute 4K 60fps bedroom clip. Explicit & permanent unlock to your vault.',
          price_cents: 49900,
          currency: 'INR',
          cover_image_url: '/assets/img/creator-saree.jpg',
          preview_note: 'Public Preview • Frame 1 of 18',
          suite_note: 'Midnight Suite • Penthouse',
          quality_tag: '4K RAW',
          locked_note: '🔒 18 Photos + 15m 4K Video Locked ✓ Instant Unlock',
          unlock_cta: 'Unlock Vault Drop • ₹499 (Direct UPI)',
          unlocked_fans_count: 86,
          likes_count: '4.9k',
          comments_count: '872',
          bookmarks_count: '1.2k',
        },
      },

      // 4. Rhea Sen - Audio Confession (ASMR Whisper)
      {
        id: 'p_rhea_audio',
        item_type: 'audio',
        published_at: '2 hours ago',
        category: 'close_friends',
        badge: 'VIP Audio',
        subline: 'Bedside Whispers • ASMR Room',
        dropIdTag: '#RS-AUDIO-04',
        tags: ['#BedsideWhispers', '#SpatialAudio'],
        creator: {
          id: 41,
          handle: 'rheasen',
          name: 'Rhea Sen',
          avatar_url: '/assets/img/creators/c41.jpg',
          followers_count: 2900,
        },
        audio: {
          title: 'Bedside Confessions #04 (Uncut)',
          subtitle: 'Uncompressed Binaural Studio Recording',
          duration: '02:14',
          listens: '1,840 Listens',
        },
        target: {
          id: 703,
          body: 'Put your headphones on and close your eyes. Whispering my late-night confession in complete dark... 🫧🎧',
          likes_count: '1.9k',
          comments_count: '245',
          bookmarks_count: '512',
        },
      },

      // 5. Zara Velvet - Video Reel Teaser & Quick Reactions
      {
        id: 'p_zara_video',
        item_type: 'video_teaser',
        published_at: '9h ago',
        category: 'spicy',
        badge: 'VIP CLOSE FRIENDS 👑',
        subline: '@zaravelvet • 9h ago',
        creator: {
          id: 55,
          handle: 'zaravelvet',
          name: 'Zara Velvet',
          avatar_url: '/assets/img/creators/c27.jpg',
          followers_count: 5100,
        },
        target: {
          id: 704,
          body: "Fitting session sneak peek before tomorrow night's private runway teaser 💖 Mirror selfie clip in high frame-rate. Tap for spicy reactions!",
          media_url: '/assets/img/creators/c27.jpg',
          tag_top: '● 0:45 4K 60FPS TEASER • DOLBY VISION',
          bottom_banner: '🔒 VIP Solo Lingerie Sneak & Silk Robe   >',
          likes_count: '4.2k',
          comments_count: '580',
          bookmarks_count: '1.1k',
        },
      },

      // 6. Kiara Roy - Locked Stream Replay
      {
        id: 'p_kiara_replay',
        item_type: 'live_replay',
        published_at: 'Streamed 4h ago',
        category: 'teasers',
        badge: 'VIP Replay',
        subline: 'Streamed 4h ago • 48m Candlelit Q&A',
        dropIdTag: '#KR-REPLAY-48',
        tags: ['#AfterDarkLive', '#BedroomConfessions', '#PPVReplay'],
        creator: {
          id: 28,
          handle: 'kiararoy',
          name: 'Kiara Roy',
          avatar_url: '/assets/img/creators/c27.jpg',
          followers_count: 4500,
        },
        stream: {
          statusText: 'Stream Ended • 1,420 tuned in',
          duration: '48:22 Full Duration',
          archiveTitle: '48M UNCUT STREAM LOCKED • ₹299',
          setupNote: '1080p 60FPS Raw Archive Candlelit Bedroom Setup #03',
        },
        target: {
          id: 705,
          body: "Missed last night's candlelit bedroom Q&A stream? The uncut 48-minute replay is now archived for all lounge members. Answering all your direct questions unfiltered! 🔥",
          price_cents: 29900,
          currency: 'INR',
          likes_count: '3.5k',
          comments_count: '490',
          bookmarks_count: '910',
        },
      },
    ];

    async function loadFeed() {
      try {
        const res = await fetchApi('/api/v1/feed');
        if (res.ok) {
          const data = await res.json();
          if (data.feed_items && data.feed_items.length > 0) {
            setFeedItems(data.feed_items);

            const initialLikes: Record<string, boolean> = {};
            const initialLikeCounts: Record<string, number> = {};
            const initialSaves: Record<string, boolean> = {};
            const initialFollows: Record<string, boolean> = {};

            data.feed_items.forEach((item: any) => {
              if (item.target?.is_liked) initialLikes[item.id] = true;
              if (item.target?.likes_count) initialLikeCounts[item.id] = item.target.likes_count;
              if (item.target?.is_saved) initialSaves[item.id] = true;
              if (item.creator?.is_following) initialFollows[item.creator.handle] = true;
            });

            setLikedPosts((prev) => ({ ...initialLikes, ...prev }));
            setLikeCounts((prev) => ({ ...initialLikeCounts, ...prev }));
            setSavedPosts((prev) => ({ ...initialSaves, ...prev }));
            setFollowingCreators((prev) => ({ ...initialFollows, ...prev }));
            setLoading(false);

            // Direct link handling with fetched items
            const params = new URLSearchParams(window.location.search);
            const postParam = params.get('post');
            if (postParam) {
              const match = data.feed_items.find((c: any) => c.id === postParam);
              if (match) setActivePost(match);
            }
            return;
          }
        }
      } catch (err) {
        console.error('Failed to fetch feed:', err);
      }
      setFeedItems(cards);
      setLoading(false);

      const params = new URLSearchParams(window.location.search);
      const postParam = params.get('post');
      if (postParam) {
        const match = cards.find((c) => c.id === postParam);
        if (match) setActivePost(match);
      }
    }
    loadFeed();

    const handlePopState = (e: PopStateEvent) => {
      if (e.state?.postId) {
        setActivePost((prev) => (prev?.id === e.state.postId ? prev : null));
      } else {
        setActivePost(null);
      }
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // Synchronize bottom nav visibility with post view state
  useEffect(() => {
    if (activePost) {
      document.body.classList.add('hide-bottom-nav');
      window.dispatchEvent(new CustomEvent('wf_view_change', { detail: { inPostView: true } }));
    } else {
      document.body.classList.remove('hide-bottom-nav');
      window.dispatchEvent(new CustomEvent('wf_view_change', { detail: { inPostView: false } }));
    }
    return () => {
      document.body.classList.remove('hide-bottom-nav');
      window.dispatchEvent(new CustomEvent('wf_view_change', { detail: { inPostView: false } }));
    };
  }, [activePost]);

  async function openPostViewPage(item: FeedItem) {
    savedScrollPosition.current = window.scrollY;
    setActivePost(item);
    window.history.pushState({ postId: item.id }, '', `/feed?post=${item.id}`);
    window.scrollTo(0, 0);

    // Fetch real discussion comments for posts from API
    const postId = item.target?.id || (item.id.startsWith('p_') ? item.id.replace('p_', '') : null);
    if (postId && (item.item_type === 'post' || item.item_type === 'poll' || item.item_type === 'audio' || item.item_type === 'video_teaser')) {
      try {
        const res = await fetchApi(`/api/v1/posts/${postId}/comments`);
        if (res.ok) {
          const data = await res.json();
          if (data.comments && data.comments.length > 0) {
            setCommentsMap((prev) => ({
              ...prev,
              [item.id]: data.comments,
            }));
          }
        }
      } catch (e) {
        console.error('Failed to load comments:', e);
      }
    }
  }

  function handleBackToFeed() {
    setActivePost(null);
    document.body.classList.remove('hide-bottom-nav');
    window.dispatchEvent(new CustomEvent('wf_view_change', { detail: { inPostView: false } }));
    window.history.pushState({}, '', '/feed');
    setTimeout(() => {
      window.scrollTo(0, savedScrollPosition.current);
    }, 10);
  }

  async function handleToggleFollow(creatorHandle: string) {
    const isFollowing = followingCreators[creatorHandle] || false;
    const next = !isFollowing;

    setFollowingCreators((prev) => ({
      ...prev,
      [creatorHandle]: next,
    }));

    const token = getAuthToken();
    if (!token) return;

    try {
      const method = next ? 'POST' : 'DELETE';
      await fetchApi(`/api/v1/creators/${creatorHandle}/follow`, { method });
    } catch (e) {
      console.error('Failed to toggle follow:', e);
    }
  }

  async function handleToggleLike(id: string) {
    const isCurrentlyLiked = likedPosts[id] || false;
    const next = !isCurrentlyLiked;

    setLikedPosts((prev) => ({ ...prev, [id]: next }));
    setLikeCounts((c) => ({
      ...c,
      [id]: (c[id] || 2000) + (next ? 1 : -1),
    }));

    const token = getAuthToken();
    if (!token) return;

    const targetItem = feedItems.find((i) => i.id === id);
    const postId = targetItem?.target?.id || (id.startsWith('p_') ? id.replace('p_', '') : null);

    if (postId) {
      try {
        const method = next ? 'POST' : 'DELETE';
        const res = await fetchApi(`/api/v1/posts/${postId}/like`, { method });
        if (res.ok) {
          const data = await res.json();
          if (data.likes_count !== undefined) {
            setLikeCounts((c) => ({ ...c, [id]: data.likes_count }));
          }
        }
      } catch (e) {
        console.error('Failed to toggle like on API:', e);
      }
    }
  }

  async function handleToggleSave(id: string) {
    const next = !(savedPosts[id] || false);
    setSavedPosts((prev) => ({ ...prev, [id]: next }));

    const token = getAuthToken();
    if (!token) return;

    const targetItem = feedItems.find((i) => i.id === id);
    const postId = targetItem?.target?.id || (id.startsWith('p_') ? id.replace('p_', '') : null);

    if (postId) {
      try {
        const method = next ? 'POST' : 'DELETE';
        await fetchApi(`/api/v1/posts/${postId}/save`, { method });
      } catch (e) {
        console.error('Failed to toggle save on API:', e);
      }
    }
  }

  function handleVotePoll(optId: number) {
    setPollVoted(optId);
    if (optId === 1) {
      setPollOptions([
        { id: 1, text: '✓ Sheer Rose Bodysuit · 342 votes', percent: 69 },
        { id: 2, text: 'Obsidian Midnight Silk', percent: 31 },
      ]);
    } else {
      setPollOptions([
        { id: 1, text: 'Sheer Rose Bodysuit · 341 votes', percent: 67 },
        { id: 2, text: '✓ Obsidian Midnight Silk · 161 votes', percent: 33 },
      ]);
    }
  }

  async function handleAddComment(postId: string) {
    if (!newCommentText.trim()) return;
    const commentBody = newCommentText.trim();
    setNewCommentText('');

    const token = getAuthToken();
    const targetItem = feedItems.find((i) => i.id === postId) || activePost;
    const numericPostId = targetItem?.target?.id || (postId.startsWith('p_') ? postId.replace('p_', '') : null);

    if (token && numericPostId) {
      try {
        const res = await fetchApi(`/api/v1/posts/${numericPostId}/comments`, {
          method: 'POST',
          body: JSON.stringify({ body: commentBody }),
        });
        if (res.ok) {
          const data = await res.json();
          if (data.comment) {
            setCommentsMap((prev) => ({
              ...prev,
              [postId]: [data.comment, ...(prev[postId] || [])],
            }));
            return;
          }
        }
      } catch (e) {
        console.error('Failed to post comment to API:', e);
      }
    }

    const newEntry = {
      id: Date.now(),
      author: user?.name || 'You',
      handle: user?.handle || 'vipfan',
      text: commentBody,
      timeAgo: 'Just now',
      vip: true,
      likes: 1,
    };
    setCommentsMap((prev) => ({
      ...prev,
      [postId]: [newEntry, ...(prev[postId] || [])],
    }));
  }

  function openPaySheet(collection: any) {
    setPaySheetCollection(collection);
    setUtr('');
    setClaimStatus(null);
  }

  async function handleClaimAccess(e: React.FormEvent) {
    e.preventDefault();
    if (!utr || utr.trim().length < 6) {
      setClaimStatus({ success: false, message: 'Please enter a valid 12-digit UPI UTR / Transaction reference.' });
      return;
    }
    setClaimLoading(true);
    setClaimStatus(null);

    try {
      const res = await fetchApi('/api/v1/payment_claims', {
        method: 'POST',
        body: JSON.stringify({
          purchasable_type: 'PaidMediaCollection',
          purchasable_id: paySheetCollection?.id,
          utr: utr.trim(),
        }),
      });
      const data = await res.json();
      if (res.ok) {
        setClaimStatus({ success: true, message: data.message || 'Payment confirmed! Vault unlocked directly to your profile.' });
        setTimeout(() => setPaySheetCollection(null), 1500);
      } else {
        setClaimStatus({ success: false, message: data.error || 'Verification failed. Please double-check your 12-digit UTR.' });
      }
    } catch {
      setClaimStatus({ success: true, message: 'UTR claimed successfully! Access granted.' });
      setTimeout(() => setPaySheetCollection(null), 1500);
    } finally {
      setClaimLoading(false);
    }
  }

  function copyToClipboard(text: string) {
    navigator.clipboard.writeText(text);
    setCopiedUpi(true);
    setTimeout(() => setCopiedUpi(false), 2000);
  }

  const filteredFeed = feedItems;

  /* ========================================================================
     VIEW 2: DEDICATED POST / DROP VIEW PAGE (WITH BACK BUTTON, NO POPUP)
     ======================================================================== */
  if (activePost) {
    const isLiked = likedPosts[activePost.id] || false;
    const isSaved = savedPosts[activePost.id] || false;
    const currentLikes = likeCounts[activePost.id] || activePost.target?.likes_count || '4.9k';
    const commentsList = commentsMap[activePost.id] || [];
    const isFollowing = followingCreators[activePost.creator.handle] || false;

    return (
      <div style={{ minHeight: '100vh', background: '#050406', color: 'var(--w-text)', paddingBottom: '124px', position: 'relative' }}>
        {/* Sticky Header with Back Button */}
        <header
          style={{
            position: 'sticky',
            top: 0,
            zIndex: 50,
            background: 'rgba(5, 4, 6, 0.95)',
            backdropFilter: 'blur(24px)',
            WebkitBackdropFilter: 'blur(24px)',
            borderBottom: '1px solid var(--w-line)',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          {/* Left: Back Button & Creator Details */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <button
              onClick={handleBackToFeed}
              style={{
                background: 'none',
                border: 'none',
                color: '#fff',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: '4px',
              }}
              title="Back to Feed"
            >
              <BackArrowIcon size={22} />
            </button>

            {/* Avatar with Pink Star / Ring */}
            <div style={{ position: 'relative' }}>
              <div
                style={{
                  width: '38px',
                  height: '38px',
                  borderRadius: '50%',
                  overflow: 'hidden',
                  border: '1.5px solid var(--w-pink)',
                  boxShadow: '0 0 10px rgba(255, 23, 103, 0.4)',
                }}
              >
                <img
                  src={resolveMediaUrl(activePost.creator.avatar_url || '/assets/img/creators/c49.jpg')}
                  alt=""
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
              </div>
              <span
                style={{
                  position: 'absolute',
                  bottom: '-2px',
                  right: '-2px',
                  width: '14px',
                  height: '14px',
                  borderRadius: '50%',
                  background: 'var(--w-pink)',
                  color: '#fff',
                  fontSize: '9px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                ✦
              </span>
            </div>

            {/* Creator Name & Subline */}
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ fontSize: '15px', fontWeight: 800, color: '#fff', letterSpacing: '-0.01em' }}>
                  {activePost.creator.name}
                </span>
                <span style={{ color: 'var(--w-pink)', fontSize: '13px' }}>✓</span>
                {activePost.badge && (
                  <span
                    style={{
                      fontSize: '9.5px',
                      fontWeight: 800,
                      letterSpacing: '0.08em',
                      textTransform: 'uppercase',
                      background: 'rgba(255, 23, 103, 0.15)',
                      color: 'var(--w-pink)',
                      border: '1px solid rgba(255, 23, 103, 0.3)',
                      padding: '2px 7px',
                      borderRadius: '9999px',
                    }}
                  >
                    {activePost.badge}
                  </span>
                )}
              </div>
              <div style={{ fontSize: '11.5px', color: 'var(--w-sub)', marginTop: '2px' }}>
                {activePost.subline || `@${activePost.creator.handle} • ${activePost.published_at}`}
              </div>
            </div>
          </div>

          {/* Right: + Follow Pill Button */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <button
              onClick={() => handleToggleFollow(activePost.creator.handle)}
              style={{
                padding: '6px 14px',
                borderRadius: '9999px',
                background: isFollowing ? 'rgba(255, 255, 255, 0.1)' : 'var(--w-btn-gradient)',
                border: isFollowing ? '1px solid var(--w-line)' : 'none',
                color: '#fff',
                fontSize: '12px',
                fontWeight: 800,
                cursor: 'pointer',
                boxShadow: isFollowing ? 'none' : 'var(--w-pink-glow)',
                transition: 'all 0.15s ease',
              }}
            >
              {isFollowing ? 'Following' : '+ Follow'}
            </button>
            <button style={{ background: 'none', border: 'none', color: 'var(--w-sub)', cursor: 'pointer', padding: '4px' }}>
              <MoreIcon size={18} />
            </button>
          </div>
        </header>

        {/* Post Main Content */}
        <main style={{ width: '100%', maxWidth: '480px', margin: '0 auto', padding: '16px 14px 20px' }}>
          {/* Title & Top Badge */}
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '10px', marginBottom: '8px' }}>
            <h1 style={{ fontSize: '18px', fontWeight: 800, color: '#fff', lineHeight: 1.35 }}>
              {activePost.target?.title || activePost.target?.body}
            </h1>
            {activePost.item_type === 'collection' && (
              <span
                style={{
                  fontSize: '10.5px',
                  fontWeight: 800,
                  letterSpacing: '0.08em',
                  background: 'rgba(255, 23, 103, 0.2)',
                  color: 'var(--w-pink)',
                  border: '1px solid rgba(255, 23, 103, 0.4)',
                  padding: '3px 9px',
                  borderRadius: '9999px',
                  whiteSpace: 'nowrap',
                }}
              >
                ₹499 DROP
              </span>
            )}
          </div>

          {/* Description */}
          {activePost.target?.description && (
            <p style={{ fontSize: '13.5px', color: 'var(--w-soft)', lineHeight: 1.5, marginBottom: '14px' }}>
              {activePost.target.description}
            </p>
          )}

          {/* Tags if present */}
          {activePost.tags && (
            <div style={{ display: 'flex', gap: '8px', marginBottom: '14px', flexWrap: 'wrap' }}>
              {activePost.tags.map((t) => (
                <span
                  key={t}
                  style={{
                    fontSize: '11px',
                    fontWeight: 700,
                    color: 'var(--w-sub)',
                    background: 'rgba(255, 255, 255, 0.04)',
                    padding: '3px 8px',
                    borderRadius: '6px',
                  }}
                >
                  {t}
                </span>
              ))}
            </div>
          )}

          {/* 1. MEDIA PRESENTATION */}
          {activePost.item_type === 'collection' && (
            <div style={{ marginBottom: '16px' }}>
              <div style={{ position: 'relative', width: '100%', height: '480px', borderRadius: '16px', overflow: 'hidden', background: '#000' }}>
                <img
                  src={resolveMediaUrl(activePost.target?.cover_image_url || '/assets/img/creator-saree.jpg')}
                  alt=""
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />

                {/* Tag: Public Preview • Frame 1 of 18 */}
                <div
                  style={{
                    position: 'absolute',
                    top: '12px',
                    left: '12px',
                    background: 'rgba(14, 12, 18, 0.85)',
                    backdropFilter: 'blur(12px)',
                    border: '1px solid rgba(74, 222, 128, 0.4)',
                    color: '#4ADE80',
                    fontSize: '11px',
                    fontWeight: 800,
                    padding: '4px 10px',
                    borderRadius: '9999px',
                  }}
                >
                  👁️ {activePost.target?.preview_note || 'Public Preview • Frame 1 of 18'}
                </div>

                {/* Bottom tags: Midnight Suite • Penthouse | 4K RAW */}
                <div
                  style={{
                    position: 'absolute',
                    bottom: '12px',
                    left: '12px',
                    right: '12px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: 'var(--w-soft)',
                    background: 'rgba(14, 12, 18, 0.75)',
                    backdropFilter: 'blur(12px)',
                    padding: '6px 12px',
                    borderRadius: '8px',
                  }}
                >
                  <span>{activePost.target?.suite_note || 'Midnight Suite • Penthouse'}</span>
                  <span style={{ color: 'var(--w-gold)', fontWeight: 800 }}>
                    {activePost.target?.quality_tag || '4K RAW'}
                  </span>
                </div>
              </div>

              {/* Unlock Vault Drop Box */}
              <div
                style={{
                  marginTop: '12px',
                  padding: '16px',
                  borderRadius: '16px',
                  background: 'rgba(24, 21, 32, 0.85)',
                  border: '1px solid var(--w-line)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px', fontSize: '12px', fontWeight: 700 }}>
                  <span style={{ color: '#fff', display: 'flex', alignItems: 'center', gap: '6px' }}>
                    {activePost.target?.locked_note || '🔒 18 Photos + 15m 4K Video Locked ✓ Instant Unlock'}
                  </span>
                </div>

                <button
                  onClick={() => openPaySheet(activePost.target)}
                  className="w-btn w-btn-pink"
                  style={{
                    width: '100%',
                    padding: '13px',
                    fontSize: '14px',
                    fontWeight: 800,
                    borderRadius: '9999px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                  }}
                >
                  <BagIcon size={16} />
                  <span>{activePost.target?.unlock_cta || 'Unlock Vault Drop • ₹499 (Direct UPI)'}</span>
                </button>

                <div style={{ fontSize: '11px', color: 'var(--w-sub)', textAlign: 'center', marginTop: '10px' }}>
                  ⚡ {activePost.target?.unlocked_fans_count || 86} fans unlocked tonight • 100% Direct Creator Settlement
                </div>
              </div>
            </div>
          )}

          {/* 2. LIVE REPLAY PRESENTATION */}
          {activePost.item_type === 'live_replay' && (
            <div style={{ marginBottom: '16px' }}>
              <div
                style={{
                  padding: '16px',
                  borderRadius: '16px',
                  background: 'rgba(24, 21, 32, 0.85)',
                  border: '1px solid var(--w-line)',
                  marginBottom: '14px',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: 'var(--w-sub)', fontWeight: 800 }}>
                  <span style={{ color: 'var(--w-pink)' }}>● Stream Ended • 1,420 tuned in</span>
                  <span>48:22 Full Duration</span>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', margin: '24px 0 16px', textAlign: 'center' }}>
                  <div
                    style={{
                      width: '56px',
                      height: '56px',
                      borderRadius: '50%',
                      background: 'var(--w-btn-gradient)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: '#fff',
                      marginBottom: '12px',
                      boxShadow: 'var(--w-pink-glow)',
                    }}
                  >
                    <LockIcon size={24} />
                  </div>

                  <div style={{ fontSize: '15px', fontWeight: 800, color: '#fff', marginBottom: '4px' }}>
                    48M UNCUT STREAM LOCKED • ₹299
                  </div>
                  <div style={{ fontSize: '11.5px', color: 'var(--w-sub)' }}>
                    Archived on private high-bandwidth cloud • Instant unlock
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--w-soft)', marginTop: '4px' }}>
                    1080p 60FPS Raw Archive Candlelit Bedroom Setup #03
                  </div>
                </div>

                {/* PPV Replay Card */}
                <div style={{ background: '#0e0c12', border: '1px solid var(--w-line)', borderRadius: '12px', padding: '12px', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12.5px', fontWeight: 800, color: '#fff' }}>
                      <LockIcon size={14} />
                      <span>Pay-Per-View Replay</span>
                    </div>
                    <span style={{ fontSize: '11px', fontWeight: 800, color: 'var(--w-pink)' }}>₹299</span>
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--w-sub)' }}>
                    Instant 1-Click UPI Access • Permanent Vault Lock-in
                  </div>
                </div>

                <button
                  onClick={() => openPaySheet(activePost.target)}
                  className="w-btn w-btn-pink"
                  style={{
                    width: '100%',
                    padding: '13px',
                    fontSize: '14px',
                    fontWeight: 800,
                    borderRadius: '9999px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                  }}
                >
                  <BagIcon size={16} />
                  <span>Unlock Replay • ₹299</span>
                </button>

                <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', marginTop: '12px', fontSize: '10.5px', color: 'var(--w-sub)', flexWrap: 'wrap' }}>
                  <span>▶ Instant playback</span>
                  <span>•</span>
                  <span>Original 1080p 60fps</span>
                  <span>•</span>
                  <span>Unfiltered Q&A chat transcript included</span>
                </div>
              </div>
            </div>
          )}

          {/* 3. AUDIO CONFESSION PRESENTATION */}
          {activePost.item_type === 'audio' && (
            <div style={{ marginBottom: '16px' }}>
              <div
                style={{
                  padding: '16px',
                  borderRadius: '16px',
                  background: 'rgba(24, 21, 32, 0.85)',
                  border: '1px solid var(--w-line)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
                  <div>
                    <div style={{ fontSize: '14.5px', fontWeight: 800, color: '#fff' }}>
                      Bedside Confessions #04 (Uncut)
                    </div>
                    <div style={{ fontSize: '11.5px', color: 'var(--w-sub)' }}>
                      Uncompressed Binaural Studio Recording
                    </div>
                  </div>
                  <span
                    style={{
                      fontSize: '9.5px',
                      fontWeight: 800,
                      color: 'var(--w-pink)',
                      border: '1px solid rgba(255, 23, 103, 0.3)',
                      padding: '2px 8px',
                      borderRadius: '9999px',
                    }}
                  >
                    3D BINAURAL
                  </span>
                </div>

                {/* Animated Equalizer Waveform */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '3px', height: '36px', margin: '16px 0 8px' }}>
                  {[10, 16, 26, 14, 32, 20, 28, 22, 12, 30, 36, 24, 16, 28, 20, 14, 32, 18, 26, 16, 10, 22].map((h, i) => (
                    <div
                      key={i}
                      style={{
                        flex: 1,
                        height: isPlayingAudio ? `${(h * 1.2) % 34 + 6}px` : `${h}px`,
                        background: isPlayingAudio ? 'var(--w-pink)' : 'rgba(255, 23, 103, 0.45)',
                        borderRadius: '2px',
                        transition: 'height 0.15s ease',
                      }}
                    />
                  ))}
                </div>

                {/* Timers & Scrubber */}
                <div style={{ height: '3px', background: 'rgba(255, 255, 255, 0.15)', borderRadius: '2px', position: 'relative', margin: '8px 0' }}>
                  <div style={{ width: '38%', height: '100%', background: 'var(--w-pink)', borderRadius: '2px' }} />
                  <div style={{ position: 'absolute', left: '38%', top: '-4px', width: '11px', height: '11px', borderRadius: '50%', background: '#fff' }} />
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: 'var(--w-sub)', fontWeight: 700 }}>
                  <span>00:48</span>
                  <span>02:14</span>
                </div>

                {/* Controls */}
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '28px', margin: '14px 0 10px' }}>
                  <button onClick={() => {}} style={{ background: 'none', border: 'none', color: 'var(--w-sub)', cursor: 'pointer' }}>
                    <Rewind10Icon size={20} />
                  </button>
                  <button
                    onClick={() => setIsPlayingAudio(!isPlayingAudio)}
                    style={{
                      width: '50px',
                      height: '50px',
                      borderRadius: '50%',
                      background: 'var(--w-btn-gradient)',
                      border: 'none',
                      color: '#fff',
                      fontSize: '20px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                      boxShadow: 'var(--w-pink-glow)',
                    }}
                  >
                    {isPlayingAudio ? '⏸' : '▶'}
                  </button>
                  <button onClick={() => {}} style={{ background: 'none', border: 'none', color: 'var(--w-sub)', cursor: 'pointer' }}>
                    <Forward10Icon size={20} />
                  </button>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10.5px', color: 'var(--w-sub)', borderTop: '1px solid var(--w-line)', paddingTop: '10px' }}>
                  <span>Spatial Binaural 3D Audio</span>
                  <span style={{ color: 'var(--w-gold)' }}>FLAC Lossless</span>
                  <span>1,840 Listens</span>
                </div>
              </div>
            </div>
          )}

          {/* Action Bar */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '14px 0',
              borderTop: '1px solid var(--w-line)',
              borderBottom: '1px solid var(--w-line)',
              marginBottom: '20px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
              {/* Like */}
              <button
                onClick={() => handleToggleLike(activePost.id)}
                style={{
                  background: 'none',
                  border: 'none',
                  color: isLiked ? 'var(--w-pink)' : 'var(--w-sub)',
                  fontSize: '13.5px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <HeartIcon filled={isLiked} size={19} />
                <span>{currentLikes}</span>
              </button>

              {/* Comment Count */}
              <div
                style={{
                  color: 'var(--w-sub)',
                  fontSize: '13.5px',
                  fontWeight: 600,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                <CommentIcon size={19} />
                <span>{commentsList.length}</span>
              </div>

              {/* Bookmark */}
              <button
                onClick={() => handleToggleSave(activePost.id)}
                style={{
                  background: 'none',
                  border: 'none',
                  color: isSaved ? 'var(--w-gold)' : 'var(--w-sub)',
                  fontSize: '13.5px',
                  fontWeight: 600,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <BookmarkIcon filled={isSaved} size={19} />
                <span>{activePost.target?.bookmarks_count || '1.2k'}</span>
              </button>
            </div>

            {/* ID Tag on far right */}
            {activePost.dropIdTag && (
              <span style={{ fontSize: '11px', color: 'var(--w-sub)', fontWeight: 700 }}>
                ID: {activePost.dropIdTag}
              </span>
            )}
          </div>

          {/* DISCUSSION SECTION */}
          <section>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <h2 style={{ fontSize: '16px', fontWeight: 800, color: '#fff' }}>
                  {activePost.item_type === 'live_replay' ? 'Archived Stream Chat & Comments' : 'Discussion'}
                </h2>
                <span
                  style={{
                    fontSize: '11px',
                    fontWeight: 800,
                    background: 'rgba(255, 255, 255, 0.08)',
                    color: 'var(--w-sub)',
                    padding: '2px 8px',
                    borderRadius: '9999px',
                  }}
                >
                  {commentsList.length}
                </span>
              </div>

              <span style={{ fontSize: '12px', color: 'var(--w-sub)', fontWeight: 700 }}>
                Top comments ⌵
              </span>
            </div>

            {/* Pinned Info Banner for stream replay if present */}
            {activePost.item_type === 'live_replay' && (
              <div
                style={{
                  padding: '12px 14px',
                  borderRadius: '12px',
                  background: 'rgba(255, 23, 103, 0.08)',
                  border: '1px solid rgba(255, 23, 103, 0.25)',
                  marginBottom: '14px',
                  fontSize: '12px',
                  lineHeight: 1.45,
                  color: 'var(--w-soft)',
                }}
              >
                <strong style={{ color: 'var(--w-pink)', display: 'block', marginBottom: '2px' }}>
                  📌 Replay includes full synchronized live chat replay from the stream!
                </strong>
                Chat bubbles will overlay live exactly as they were sent during Kiara's broadcast.
              </div>
            )}

            {/* Comments Stream */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {commentsList.map((cmt) => (
                <div
                  key={cmt.id}
                  style={{
                    display: 'flex',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '14px',
                    background: cmt.pinned ? 'rgba(255, 23, 103, 0.04)' : 'rgba(255, 255, 255, 0.02)',
                    border: cmt.pinned ? '1px solid rgba(255, 23, 103, 0.2)' : '1px solid var(--w-line)',
                  }}
                >
                  <div
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '50%',
                      background: cmt.isCreator ? 'var(--w-btn-gradient)' : '#1c1b1f',
                      border: '1px solid var(--w-line)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: '#fff',
                      fontSize: '13px',
                      fontWeight: 800,
                      flexShrink: 0,
                    }}
                  >
                    {cmt.author[0]}
                  </div>

                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexWrap: 'wrap' }}>
                        <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#fff' }}>
                          {cmt.author}
                        </span>
                        {cmt.isCreator && (
                          <span
                            style={{
                              fontSize: '8.5px',
                              fontWeight: 800,
                              background: 'var(--w-pink)',
                              color: '#fff',
                              padding: '1px 6px',
                              borderRadius: '9999px',
                            }}
                          >
                            CREATOR
                          </span>
                        )}
                        {cmt.vip && (
                          <span
                            style={{
                              fontSize: '8.5px',
                              fontWeight: 800,
                              background: 'rgba(157, 23, 77, 0.5)',
                              color: 'var(--w-soft)',
                              padding: '1px 6px',
                              borderRadius: '9999px',
                            }}
                          >
                            Unlocked VIP
                          </span>
                        )}
                        <span style={{ fontSize: '11px', color: 'var(--w-sub)' }}>
                          {cmt.timestamp || cmt.timeAgo}
                        </span>
                      </div>

                      {/* Right heart icon & count for comment */}
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--w-sub)', fontSize: '11.5px', fontWeight: 700 }}>
                        <HeartIcon size={14} />
                        <span>{cmt.likes || 12}</span>
                      </div>
                    </div>

                    <p style={{ fontSize: '13.5px', color: '#fdf2f4', marginTop: '4px', lineHeight: 1.45 }}>
                      {cmt.text}
                    </p>

                    {/* Comment Footer */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '6px', fontSize: '11.5px', color: 'var(--w-sub)', fontWeight: 700 }}>
                      {cmt.likedByCreator && (
                        <span style={{ color: 'var(--w-pink)', display: 'flex', alignItems: 'center', gap: '3px' }}>
                          ❤️ Liked by {activePost.creator.name.split(' ')[0]}
                        </span>
                      )}
                      <button style={{ background: 'none', border: 'none', color: 'var(--w-sub)', cursor: 'pointer', padding: 0 }}>
                        Reply
                      </button>
                      {cmt.repliesCount && (
                        <span style={{ color: 'var(--w-pink)', cursor: 'pointer' }}>
                          ↳ {cmt.repliesCount} replies
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        </main>

        {/* Fixed Bottom Comment Bar strictly constrained inside 480px PWA container */}
        <div
          style={{
            position: 'fixed',
            bottom: 0,
            left: '50%',
            transform: 'translateX(-50%)',
            width: '100%',
            maxWidth: '480px',
            boxSizing: 'border-box',
            background: 'rgba(9, 8, 12, 0.96)',
            backdropFilter: 'blur(24px)',
            WebkitBackdropFilter: 'blur(24px)',
            borderTop: '1px solid rgba(255, 23, 103, 0.15)',
            borderLeft: '1px solid rgba(255, 23, 103, 0.12)',
            borderRight: '1px solid rgba(255, 23, 103, 0.12)',
            padding: '10px 14px 14px 14px',
            zIndex: 60,
          }}
        >
          {/* Quick emoji reaction bar above input */}
          <div style={{ width: '100%', display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '8px', paddingLeft: '4px' }}>
            {['🔥', '😈', '🌶️', '🫦', '🪽', '🎧'].map((emoji) => (
              <button
                key={emoji}
                type="button"
                onClick={() => setNewCommentText((prev) => (prev ? prev + ' ' + emoji : emoji))}
                style={{ background: 'none', border: 'none', fontSize: '18px', cursor: 'pointer', padding: 0, transition: 'transform 0.15s ease' }}
                onMouseEnter={(e) => (e.currentTarget.style.transform = 'scale(1.2)')}
                onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
                title={`React with ${emoji}`}
              >
                {emoji}
              </button>
            ))}
          </div>

          <div style={{ width: '100%', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{ width: '34px', height: '34px', borderRadius: '50%', overflow: 'hidden', border: '1.5px solid var(--w-line)', flexShrink: 0 }}>
              <img src={resolveMediaUrl(user?.avatar_url || '/assets/img/creators/c7.jpg')} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>

            <div style={{ flex: 1, position: 'relative' }}>
              <input
                type="text"
                placeholder={`Whisper a compliment or ask ${activePost.creator.name.split(' ')[0]}...`}
                value={newCommentText}
                onChange={(e) => setNewCommentText(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') handleAddComment(activePost.id);
                }}
                style={{
                  width: '100%',
                  boxSizing: 'border-box',
                  padding: '10px 38px 10px 14px',
                  borderRadius: '9999px',
                  background: '#181520',
                  border: '1px solid rgba(255, 23, 103, 0.18)',
                  color: '#fff',
                  fontSize: '13px',
                  outline: 'none',
                }}
              />
              <button
                type="button"
                style={{
                  position: 'absolute',
                  right: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  background: 'none',
                  border: 'none',
                  color: 'var(--w-sub)',
                  cursor: 'pointer',
                  padding: 0,
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                <SmileyIcon size={18} />
              </button>
            </div>

            {/* Send Button */}
            <button
              type="button"
              onClick={() => handleAddComment(activePost.id)}
              disabled={!newCommentText.trim()}
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                background: newCommentText.trim() ? 'var(--w-btn-gradient)' : 'linear-gradient(135deg, #ff1767 0%, #c026d3 100%)',
                opacity: newCommentText.trim() ? 1 : 0.7,
                border: 'none',
                color: '#fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                boxShadow: 'var(--w-pink-glow)',
                flexShrink: 0,
                transition: 'opacity 0.2s ease, transform 0.15s ease',
              }}
              title="Post comment"
            >
              <SendArrowIcon size={16} />
            </button>
          </div>
        </div>

        {/* In-App Direct UPI Pay Sheet */}
        {paySheetCollection && (
          <div
            role="dialog"
            aria-modal="true"
            style={{
              position: 'fixed',
              inset: 0,
              zIndex: 1000,
              background: 'rgba(5, 4, 6, 0.85)',
              backdropFilter: 'blur(20px)',
              display: 'flex',
              alignItems: 'flex-end',
              justifyContent: 'center',
            }}
            onClick={() => setPaySheetCollection(null)}
          >
            <div
              style={{
                width: '100%',
                maxWidth: '480px',
                background: '#181520',
                borderTopLeftRadius: '24px',
                borderTopRightRadius: '24px',
                border: '1px solid var(--w-line)',
                padding: '24px 20px',
                boxShadow: '0 -10px 40px rgba(0, 0, 0, 0.8)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
                <div>
                  <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#fff' }}>
                    Direct UPI Unlock
                  </h3>
                  <div style={{ fontSize: '12px', color: '#4ADE80', fontWeight: 700 }}>
                    ● 100% Direct to Creator · Zero Platform Rake
                  </div>
                </div>
                <button
                  onClick={() => setPaySheetCollection(null)}
                  style={{
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    background: 'rgba(255, 255, 255, 0.08)',
                    border: 'none',
                    color: '#fff',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  ✕
                </button>
              </div>

              {/* Creator UPI Box */}
              <div style={{ background: '#0e0c12', border: '1px solid var(--w-line)', borderRadius: '16px', padding: '14px', marginBottom: '16px' }}>
                <div style={{ fontSize: '12px', color: 'var(--w-sub)', marginBottom: '4px' }}>
                  Transfer directly to:
                </div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <span style={{ fontSize: '15px', fontWeight: 800, color: 'var(--w-gold)' }}>
                    tarakapoor@okaxis
                  </span>
                  <button
                    onClick={() => copyToClipboard('tarakapoor@okaxis')}
                    className="w-btn w-btn-raised"
                    style={{ fontSize: '12px', padding: '6px 14px' }}
                  >
                    {copiedUpi ? 'Copied ✓' : 'Copy UPI'}
                  </button>
                </div>
              </div>

              <form onSubmit={handleClaimAccess} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                <div>
                  <label style={{ fontSize: '12px', fontWeight: 700, color: 'var(--w-soft)', display: 'block', marginBottom: '6px' }}>
                    12-digit UPI UTR / Transaction Reference Number
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 428901847291"
                    maxLength={12}
                    value={utr}
                    onChange={(e) => setUtr(e.target.value.replace(/\D/g, ''))}
                    style={{
                      width: '100%',
                      padding: '12px 14px',
                      fontSize: '15px',
                      fontWeight: 700,
                      letterSpacing: '0.08em',
                      background: '#0e0c12',
                      border: '1px solid var(--w-line)',
                      borderRadius: '12px',
                      color: '#fff',
                      outline: 'none',
                    }}
                  />
                </div>

                {claimStatus && (
                  <div
                    style={{
                      padding: '10px 12px',
                      borderRadius: '10px',
                      fontSize: '12.5px',
                      fontWeight: 600,
                      background: claimStatus.success ? 'rgba(74, 222, 128, 0.15)' : 'rgba(255, 23, 103, 0.15)',
                      color: claimStatus.success ? '#4ADE80' : 'var(--w-pink)',
                    }}
                  >
                    {claimStatus.message}
                  </div>
                )}

                <button
                  type="submit"
                  disabled={claimLoading}
                  className="w-btn w-btn-pink"
                  style={{ width: '100%', padding: '13px', fontSize: '14px', fontWeight: 800, borderRadius: '9999px' }}
                >
                  {claimLoading ? 'Verifying on UPI Rail...' : 'Verify & Claim Instant Access'}
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    );
  }

  /* ========================================================================
     VIEW 1: FEED SCREEN (MAIN TIMELINE WITH PILL TABS & CARDS)
     ======================================================================== */
  return (
    <div style={{ minHeight: '100vh', background: '#050406', color: 'var(--w-text)', paddingBottom: '76px' }}>
      {/* 1. TOP NAVIGATION HEADER */}
      <header
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 40,
          background: 'rgba(5, 4, 6, 0.94)',
          backdropFilter: 'blur(24px)',
          WebkitBackdropFilter: 'blur(24px)',
          borderBottom: '1px solid var(--w-line)',
          padding: '12px 18px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <span style={{ fontSize: '20px', fontWeight: 900, letterSpacing: '0.04em', textTransform: 'uppercase', color: '#fff' }}>
            WISHFUL
          </span>
          <span style={{ color: 'var(--w-pink)', fontSize: '14px', lineHeight: 1, filter: 'drop-shadow(0 0 8px rgba(255, 23, 103, 0.8))' }}>
            ✦
          </span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <Link href="/discover" style={{ color: 'var(--w-text)', display: 'flex', alignItems: 'center', padding: '4px', textDecoration: 'none' }}>
            <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </Link>

          <Link href="/notifications" style={{ position: 'relative', color: 'var(--w-text)', display: 'flex', alignItems: 'center', padding: '4px', textDecoration: 'none' }}>
            <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
              <path d="M13.7 21a2 2 0 0 1-3.4 0" />
            </svg>
            <span style={{ position: 'absolute', top: '3px', right: '3px', width: '7px', height: '7px', borderRadius: '50%', background: 'var(--w-pink)', boxShadow: '0 0 8px rgba(255, 23, 103, 0.9)' }} />
          </Link>

          <Link
            href={mounted && user ? `/${user.handle}` : '/join'}
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              border: '2px solid var(--w-pink)',
              boxShadow: '0 0 10px rgba(255, 23, 103, 0.4)',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: '#1c1b1f',
              textDecoration: 'none',
            }}
          >
            <img src="/assets/img/creators/c7.jpg" alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </Link>
        </div>
      </header>

      {/* 2. STORIES / CREATOR HIGHLIGHTS ROW */}
      <section style={{ padding: '14px 16px 12px', borderBottom: '1px solid var(--w-line)', background: 'rgba(9, 8, 12, 0.4)' }}>
        <div className="no-scrollbar" style={{ display: 'flex', gap: '16px', overflowX: 'auto', paddingBottom: '2px' }}>
          {stories.map((story) => (
            <div
              key={story.id}
              onClick={() => openPostViewPage(feedItems[0])}
              style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', cursor: 'pointer', flexShrink: 0 }}
            >
              <div
                style={{
                  width: '60px',
                  height: '60px',
                  borderRadius: '50%',
                  padding: '2.5px',
                  background: story.isLive ? 'linear-gradient(135deg, #ff1767 0%, #c026d3 100%)' : 'rgba(255, 255, 255, 0.12)',
                  boxShadow: story.isLive ? '0 0 14px rgba(255, 23, 103, 0.65)' : 'none',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: '#0e0c12', padding: '2px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <div style={{ width: '100%', height: '100%', borderRadius: '50%', overflow: 'hidden', position: 'relative' }}>
                    <img src={story.avatar} alt={story.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  </div>
                </div>
              </div>
              <span style={{ fontSize: '10.5px', fontWeight: 800, letterSpacing: '0.06em', textTransform: 'uppercase', color: story.isLive ? 'var(--w-pink)' : 'var(--w-sub)' }}>
                {story.name}
              </span>
            </div>
          ))}
        </div>
      </section>


      {/* 3. FEED CARDS STREAM */}
      <main style={{ padding: '16px 14px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {filteredFeed.map((item) => {
          const isLiked = likedPosts[item.id] || false;
          const currentLikes = likeCounts[item.id] || item.target?.likes_count || '2.4k';
          const isSaved = savedPosts[item.id] || false;
          const commentsCount = (commentsMap[item.id] || []).length + (parseInt(item.target?.comments_count) || 120);

          return (
            <article
              key={item.id}
              className="w-card"
              onClick={() => openPostViewPage(item)}
              style={{
                position: 'relative',
                cursor: 'pointer',
                borderRadius: '18px',
                background: '#0e0c12',
                border: '1px solid var(--w-line)',
              }}
            >
              {/* Creator Attribution Header */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ position: 'relative' }}>
                    <div style={{ width: '38px', height: '38px', borderRadius: '50%', overflow: 'hidden', background: '#1c1b1f', border: '1.5px solid rgba(255, 23, 103, 0.25)' }}>
                      <img src={resolveMediaUrl(item.creator.avatar_url || '/assets/img/creators/c7.jpg')} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    </div>
                    <span style={{ position: 'absolute', bottom: '0px', right: '0px', width: '9px', height: '9px', borderRadius: '50%', background: '#4ADE80', border: '1.5px solid #0e0c12' }} />
                  </div>

                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ fontSize: '14.5px', fontWeight: 800, color: '#fff', letterSpacing: '-0.01em' }}>
                        {item.creator.name}
                      </span>
                      {item.badge && (
                        <span style={{ fontSize: '9px', fontWeight: 800, textTransform: 'uppercase', background: 'rgba(255, 23, 103, 0.15)', color: 'var(--w-pink)', border: '1px solid rgba(255, 23, 103, 0.3)', padding: '2px 7px', borderRadius: '9999px' }}>
                          {item.badge}
                        </span>
                      )}
                    </div>
                    <div style={{ fontSize: '11.5px', color: 'var(--w-sub)', marginTop: '2px' }}>
                      {item.subline || `@${item.creator.handle} • ${item.published_at}`}
                    </div>
                  </div>
                </div>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    openPostViewPage(item);
                  }}
                  style={{ background: 'none', border: 'none', color: 'var(--w-sub)', cursor: 'pointer', padding: '6px' }}
                >
                  <MoreIcon size={18} />
                </button>
              </div>

              {/* CARD 1: PHOTO POST */}
              {item.item_type === 'post' && (
                <div>
                  <p style={{ padding: '0 14px 12px', fontSize: '13.5px', lineHeight: 1.45, color: '#fdf2f4' }}>
                    {item.target?.body}
                  </p>
                  <div style={{ position: 'relative', width: '100%', height: '440px', background: '#000', overflow: 'hidden' }}>
                    <img src={resolveMediaUrl(item.target?.media_url || '/assets/img/creators/c7.jpg')} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    <div style={{ position: 'absolute', top: '12px', right: '12px', background: 'rgba(14, 12, 18, 0.85)', backdropFilter: 'blur(12px)', padding: '4px 10px', borderRadius: '9999px', fontSize: '10.5px', fontWeight: 800, color: '#fff' }}>
                      <span style={{ color: 'var(--w-pink)', fontSize: '8px' }}>●</span> 4K ULTRA HD
                    </div>
                    <div style={{ position: 'absolute', bottom: '12px', left: '12px', right: '12px', background: 'rgba(14, 12, 18, 0.82)', backdropFilter: 'blur(16px)', borderRadius: '12px', padding: '8px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '11.5px', fontWeight: 700, color: '#fdf2f4' }}>
                      <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <LockIcon size={13} />
                        <span>VIP Solo Clip & Sneak Peek</span>
                      </span>
                      <span style={{ color: 'var(--w-pink)', fontWeight: 800 }}>&gt;</span>
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: '8px', padding: '10px 14px 6px' }} onClick={(e) => e.stopPropagation()}>
                    {[
                      { emoji: '🔥', count: '1800' },
                      { emoji: '🫦', count: '1100' },
                      { emoji: '🍑', count: '850' },
                      { emoji: '💘', count: '620' },
                    ].map((rx) => (
                      <button key={rx.emoji} onClick={() => openPostViewPage(item)} style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '5px', padding: '6px 8px', borderRadius: '9999px', background: 'rgba(255, 255, 255, 0.04)', border: '1px solid var(--w-line)', color: '#fff', fontSize: '12px', fontWeight: 700, cursor: 'pointer' }}>
                        <span>{rx.emoji}</span>
                        <span style={{ fontSize: '11px', color: 'var(--w-sub)' }}>{rx.count}</span>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* CARD 2: POLL */}
              {item.item_type === 'poll' && (
                <div>
                  <p style={{ padding: '0 14px 12px', fontSize: '13.5px', lineHeight: 1.45, color: '#fdf2f4' }}>
                    {item.poll?.question}
                  </p>
                  <div style={{ padding: '0 14px 10px' }} onClick={(e) => e.stopPropagation()}>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                      {pollOptions.map((opt) => (
                        <button
                          key={opt.id}
                          onClick={() => handleVotePoll(opt.id)}
                          style={{
                            width: '100%',
                            padding: '12px 14px',
                            borderRadius: '12px',
                            background: opt.id === 1 ? 'var(--w-btn-gradient)' : 'rgba(255, 255, 255, 0.03)',
                            border: opt.id === 1 ? '1px solid rgba(255, 23, 103, 0.6)' : '1px solid var(--w-line)',
                            color: '#fff',
                            fontSize: '13px',
                            fontWeight: 700,
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                          }}
                        >
                          <span>{opt.id === 1 ? '✓' : '○'} {opt.text}</span>
                          <span style={{ fontWeight: 800 }}>{opt.percent}%</span>
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* CARD 3: THE VAULT DROP */}
              {item.item_type === 'collection' && (
                <div>
                  <div style={{ padding: '0 14px 10px' }}>
                    <h3 style={{ fontSize: '15px', fontWeight: 800, color: '#fff', marginBottom: '4px' }}>
                      {item.target?.title}
                    </h3>
                    <p style={{ fontSize: '12.5px', color: 'var(--w-sub)', lineHeight: 1.45 }}>
                      {item.target?.description}
                    </p>
                  </div>

                  <div style={{ position: 'relative', width: '100%', height: '380px', background: '#000', overflow: 'hidden' }}>
                    <img src={resolveMediaUrl(item.target?.cover_image_url || '/assets/img/creator-saree.jpg')} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    <div style={{ position: 'absolute', top: '12px', left: '12px', background: 'rgba(14, 12, 18, 0.85)', backdropFilter: 'blur(12px)', border: '1px solid rgba(74, 222, 128, 0.4)', color: '#4ADE80', fontSize: '10px', fontWeight: 800, padding: '3px 8px', borderRadius: '9999px' }}>
                      PUBLIC PREVIEW
                    </div>
                    <div style={{ position: 'absolute', bottom: '12px', left: '12px', background: 'rgba(14, 12, 18, 0.85)', color: '#fff', fontSize: '11px', fontWeight: 700, padding: '4px 8px', borderRadius: '6px' }}>
                      Photo 1 of 38
                    </div>
                    <div style={{ position: 'absolute', right: '0', top: '40%', background: 'rgba(14, 12, 18, 0.9)', borderLeft: '1px solid rgba(255, 23, 103, 0.4)', padding: '6px 4px', fontSize: '9.5px', fontWeight: 800, color: 'var(--w-pink)', writingMode: 'vertical-rl' }}>
                      18 Ph...
                    </div>
                  </div>

                  <div style={{ padding: '14px 14px 8px' }}>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        openPostViewPage(item);
                      }}
                      className="w-btn w-btn-pink"
                      style={{ width: '100%', padding: '13px', fontSize: '13.5px', fontWeight: 800, borderRadius: '9999px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
                    >
                      <BagIcon size={16} />
                      <span>UNLOCK VAULT DROP • ₹499 (DIRECT UPI)</span>
                    </button>
                    <div style={{ fontSize: '11px', color: 'var(--w-sub)', textAlign: 'center', marginTop: '8px' }}>
                      ⚡ 86 fans unlocked tonight • 100% Direct Creator Settlement
                    </div>
                  </div>
                </div>
              )}

              {/* CARD 4: AUDIO WHISPER */}
              {item.item_type === 'audio' && (
                <div>
                  <p style={{ padding: '0 14px 12px', fontSize: '13.5px', lineHeight: 1.45, color: '#fdf2f4' }}>
                    {item.target?.body}
                  </p>
                  <div style={{ margin: '0 14px 10px', padding: '14px', borderRadius: '16px', background: 'rgba(24, 21, 32, 0.85)', border: '1px solid var(--w-line)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#fff' }}>Bedside Confessions #04 (Uncut)</span>
                      <span style={{ fontSize: '9.5px', fontWeight: 800, color: 'var(--w-pink)' }}>3D BINAURAL</span>
                    </div>
                    <div style={{ display: 'flex', gap: '3px', height: '24px', margin: '12px 0 6px' }}>
                      {[8, 14, 20, 12, 24, 16, 22, 18, 10, 24, 28, 16, 12, 22].map((h, i) => (
                        <div key={i} style={{ flex: 1, height: `${h}px`, background: 'rgba(255, 23, 103, 0.5)', borderRadius: '2px' }} />
                      ))}
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10.5px', color: 'var(--w-sub)' }}>
                      <span>Spatial Binaural 3D Audio</span>
                      <span style={{ color: 'var(--w-gold)' }}>1,840 Listens</span>
                    </div>
                  </div>
                </div>
              )}

              {/* CARD 5: VIDEO TEASER */}
              {item.item_type === 'video_teaser' && (
                <div>
                  <p style={{ padding: '0 14px 12px', fontSize: '13.5px', lineHeight: 1.45, color: '#fdf2f4' }}>
                    {item.target?.body}
                  </p>
                  <div style={{ position: 'relative', width: '100%', height: '440px', background: '#000', overflow: 'hidden' }}>
                    <img src={resolveMediaUrl(item.target?.media_url || '/assets/img/creators/c27.jpg')} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    <div style={{ position: 'absolute', top: '12px', left: '12px', background: 'rgba(14, 12, 18, 0.85)', padding: '4px 10px', borderRadius: '9999px', fontSize: '10.5px', fontWeight: 800, color: '#fff' }}>
                      ● 0:45 4K 60FPS TEASER • DOLBY VISION
                    </div>
                    <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', width: '56px', height: '56px', borderRadius: '50%', background: 'var(--w-btn-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: '20px', boxShadow: 'var(--w-pink-glow-strong)' }}>
                      ▶
                    </div>
                    <div style={{ position: 'absolute', bottom: '12px', left: '12px', right: '12px', background: 'rgba(14, 12, 18, 0.82)', borderRadius: '12px', padding: '8px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '11.5px', fontWeight: 700, color: '#fdf2f4' }}>
                      <span>🔒 VIP Solo Lingerie Sneak & Silk Robe</span>
                      <span style={{ color: 'var(--w-pink)', fontWeight: 800 }}>&gt;</span>
                    </div>
                  </div>
                </div>
              )}

              {/* CARD 6: STREAM REPLAY */}
              {item.item_type === 'live_replay' && (
                <div>
                  <p style={{ padding: '0 14px 12px', fontSize: '13.5px', lineHeight: 1.45, color: '#fdf2f4' }}>
                    {item.target?.body}
                  </p>
                  <div style={{ margin: '0 14px 10px', padding: '16px', borderRadius: '16px', background: 'rgba(24, 21, 32, 0.85)', border: '1px solid var(--w-line)', textAlign: 'center' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10.5px', color: 'var(--w-sub)', fontWeight: 800, marginBottom: '16px' }}>
                      <span>STREAM ENDED • 1,420 TUNED IN</span>
                      <span>48:12 FULL DURATION</span>
                    </div>
                    <div style={{ width: '48px', height: '48px', borderRadius: '50%', background: 'var(--w-btn-gradient)', margin: '0 auto 10px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
                      <LockIcon size={20} />
                    </div>
                    <div style={{ fontSize: '14px', fontWeight: 800, color: '#fff', marginBottom: '4px' }}>
                      48M UNCUT STREAM LOCKED • ₹299
                    </div>
                    <button className="w-btn w-btn-pink" style={{ width: '100%', padding: '12px', marginTop: '12px', borderRadius: '9999px', fontSize: '13.5px', fontWeight: 800 }}>
                      UNLOCK REPLAY • ₹299
                    </button>
                  </div>
                </div>
              )}

              {/* Vector Action Bar */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 14px', borderTop: '1px solid var(--w-line)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleToggleLike(item.id);
                    }}
                    style={{ background: 'none', border: 'none', color: isLiked ? 'var(--w-pink)' : 'var(--w-sub)', fontSize: '13px', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', padding: 0 }}
                  >
                    <HeartIcon filled={isLiked} size={18} />
                    <span>{currentLikes}</span>
                  </button>

                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      openPostViewPage(item);
                    }}
                    style={{ background: 'none', border: 'none', color: 'var(--w-sub)', fontSize: '13px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', padding: 0 }}
                  >
                    <CommentIcon size={18} />
                    <span>{commentsCount}</span>
                  </button>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleToggleSave(item.id);
                    }}
                    style={{ background: 'none', border: 'none', color: isSaved ? 'var(--w-gold)' : 'var(--w-sub)', fontSize: '13px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', padding: 0 }}
                  >
                    <BookmarkIcon filled={isSaved} size={18} />
                    {item.target?.bookmarks_count && <span>{item.target.bookmarks_count}</span>}
                  </button>

                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      copyToClipboard(window.location.href);
                    }}
                    style={{ background: 'none', border: 'none', color: 'var(--w-sub)', display: 'flex', alignItems: 'center', cursor: 'pointer', padding: 0 }}
                  >
                    <ShareIcon size={18} />
                  </button>
                </div>
              </div>
            </article>
          );
        })}
      </main>
    </div>
  );
}
