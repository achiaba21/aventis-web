// shared.jsx — Asfar shared UI primitives & icons
const { useState, useEffect, useRef, useMemo, createContext, useContext, Fragment } = React;

// ─────────── Icons ───────────
const Icon = ({ name, size = 22, color = "currentColor", strokeWidth = 1.8 }) => {
  const s = strokeWidth;
  const paths = {
    search: <><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></>,
    home: <path d="M3 11.5 12 4l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>,
    heart: <path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10Z"/>,
    chat: <path d="M21 12a8 8 0 0 1-12.5 6.6L4 20l1.4-4.5A8 8 0 1 1 21 12Z"/>,
    user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>,
    bell: <path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2H4.5L6 16Zm4 4a2 2 0 0 0 4 0"/>,
    grid: <><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></>,
    chart: <><path d="M3 21h18"/><path d="M6 17V10"/><path d="M11 17V6"/><path d="M16 17v-9"/><path d="M21 17v-4"/></>,
    wallet: <><path d="M3 8a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M3 10h18"/><circle cx="17" cy="15" r="1.4" fill={color} stroke="none"/></>,
    plus: <path d="M12 5v14M5 12h14"/>,
    arrowLeft: <path d="m15 6-6 6 6 6"/>,
    arrowRight: <path d="m9 6 6 6-6 6"/>,
    arrowUp: <path d="m6 15 6-6 6 6"/>,
    arrowDown: <path d="m6 9 6 6 6-6"/>,
    close: <path d="M6 6l12 12M18 6 6 18"/>,
    check: <path d="m5 12 5 5L20 7"/>,
    star: <path d="m12 3 2.6 5.6 6.1.6-4.6 4.2 1.3 6L12 16.6 6.6 19.4l1.3-6L3.3 9.2l6.1-.6z"/>,
    pin: <><path d="M12 21s-7-7-7-12a7 7 0 0 1 14 0c0 5-7 12-7 12Z"/><circle cx="12" cy="9" r="2.5"/></>,
    bed: <><path d="M3 17V7"/><path d="M21 17v-7a3 3 0 0 0-3-3h-7v6"/><path d="M3 14h18"/><path d="M3 17h18"/><circle cx="7" cy="11" r="2"/></>,
    bath: <><path d="M4 12h16v3a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z"/><path d="M6 12V6a2 2 0 0 1 4 0"/><path d="M8 8h3"/><path d="M5 21l1-2M19 21l-1-2"/></>,
    wifi: <><path d="M2 9.5a16 16 0 0 1 20 0"/><path d="M5.5 13a11 11 0 0 1 13 0"/><path d="M9 16.5a6 6 0 0 1 6 0"/><circle cx="12" cy="20" r="1" fill={color} stroke="none"/></>,
    park: <><rect x="3" y="6" width="18" height="13" rx="2"/><path d="M8 6V4M16 6V4"/><path d="M9 14h6"/></>,
    shield: <><path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"/></>,
    filter: <path d="M3 5h18M6 12h12M10 19h4"/>,
    sliders: <><path d="M4 6h7M15 6h5M4 12h3M11 12h9M4 18h11M19 18h1"/><circle cx="13" cy="6" r="2"/><circle cx="9" cy="12" r="2"/><circle cx="17" cy="18" r="2"/></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></>,
    eye: <><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></>,
    download: <><path d="M12 4v12"/><path d="m7 11 5 5 5-5"/><path d="M5 20h14"/></>,
    share: <><circle cx="6" cy="12" r="2"/><circle cx="18" cy="6" r="2"/><circle cx="18" cy="18" r="2"/><path d="m8 11 8-4M8 13l8 4"/></>,
    cards: <><rect x="3" y="6" width="18" height="13" rx="2"/><path d="M3 11h18"/></>,
    refer: <><circle cx="9" cy="9" r="3"/><circle cx="17" cy="7" r="2.5"/><path d="M3 19c0-3.3 2.7-6 6-6s6 2.7 6 6"/><path d="M14 16c.6-1.8 2.4-3 4.5-3"/></>,
    trend: <><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></>,
    listings: <><rect x="3" y="3" width="7" height="7" rx="1.5"/><path d="M14 5h7M14 8h5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><path d="M14 16h7M14 19h5"/></>,
    settings: <><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-1.8-.3 1.6 1.6 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.6 1.6 0 0 0-1-1.5 1.6 1.6 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.6 1.6 0 0 0 .3-1.8 1.6 1.6 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1A1.6 1.6 0 0 0 4.6 9a1.6 1.6 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.6 1.6 0 0 0 1.8.3H9A1.6 1.6 0 0 0 10 3.1V3a2 2 0 1 1 4 0v.1a1.6 1.6 0 0 0 1 1.5 1.6 1.6 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8V9c.3.6.9 1 1.5 1H21a2 2 0 1 1 0 4h-.1a1.6 1.6 0 0 0-1.5 1Z"/></>,
    zap: <path d="M13 2 4 14h7l-1 8 9-12h-7z"/>,
    clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
    money: <><circle cx="12" cy="12" r="9"/><path d="M14.5 9.5c0-1-1-2-2.5-2s-2.5 1-2.5 2 1 1.7 2.5 2 2.5 1 2.5 2-1 2-2.5 2-2.5-1-2.5-2"/><path d="M12 6v1.5M12 16.5V18"/></>,
    coffee: <><path d="M3 8h14v6a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4z"/><path d="M17 10h2a2 2 0 0 1 0 4h-2"/><path d="M6 4v2M10 4v2M14 4v2"/></>,
    paper: <><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/><path d="M9 13h6M9 17h4"/></>,
    send: <path d="m22 2-7 20-4-9-9-4z"/>,
    image: <><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5-9 9"/></>,
    moreH: <><circle cx="6" cy="12" r="1.6" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.6" fill={color} stroke="none"/><circle cx="18" cy="12" r="1.6" fill={color} stroke="none"/></>,
    moreV: <><circle cx="12" cy="6" r="1.6" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.6" fill={color} stroke="none"/><circle cx="12" cy="18" r="1.6" fill={color} stroke="none"/></>,
    sparkle: <path d="M12 3v6M12 15v6M3 12h6M15 12h6M5.6 5.6l4.2 4.2M14.2 14.2l4.2 4.2M5.6 18.4l4.2-4.2M14.2 9.8l4.2-4.2"/>,
    flag: <><path d="M5 21V4"/><path d="M5 4h12l-2 4 2 4H5"/></>,
    key: <><circle cx="8" cy="15" r="4"/><path d="m11 12 9-9"/><path d="m16 7 3 3"/><path d="m19 4 2 2"/></>,
    handshake: <path d="M11 17 8 14l-3 3 4 4 4-4ZM13 17l3 3 4-4-3-3M2 12l4-4 4 4M22 12l-4-4-4 4M6 8l3-3 5 5M14 10l4-4"/>,
    package: <><path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5"/><path d="M12 13v8"/></>,
    minus: <path d="M5 12h14"/>,
    edit: <><path d="M11 4H5a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2v-6"/><path d="M18 2 22 6 12 16H8v-4Z"/></>,
    trash: <><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></>,
    user2: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>,
    users: <><circle cx="9" cy="8" r="3.5"/><path d="M3 20a6 6 0 0 1 12 0"/><circle cx="17" cy="7" r="2.5"/><path d="M16 13a5 5 0 0 1 5 5"/></>,
    phone: <path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.6a16 16 0 0 0 6 6l1.2-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6a2 2 0 0 1 1.7 2z"/>,
    map: <><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2z"/><path d="M9 4v14M15 6v14"/></>,
    list: <><path d="M8 6h13M8 12h13M8 18h13"/><circle cx="4" cy="6" r="1.2" fill={color} stroke="none"/><circle cx="4" cy="12" r="1.2" fill={color} stroke="none"/><circle cx="4" cy="18" r="1.2" fill={color} stroke="none"/></>,
    qr: <><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3M21 14v0M17 21h4M14 18h0M21 17v4"/></>,
    link: <><path d="M9 15l6-6"/><path d="M11 6.5 13 4.5a4 4 0 0 1 5.7 5.7L16.5 12.5"/><path d="M12.5 17.5 10.5 19.5a4 4 0 0 1-5.7-5.7L7 11.5"/></>,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke={color} strokeWidth={s} strokeLinecap="round" strokeLinejoin="round"
      style={{ display: "block" }}>
      {paths[name]}
    </svg>
  );
};

// ─────────── Currency ───────────
const fmtFCFA = (n) => {
  if (n === 0) return "0 FCFA";
  const s = Math.round(n).toLocaleString("fr-FR").replace(/\u202f|,/g, " ");
  return `${s} FCFA`;
};
const fmtFCFAk = (n) => {
  if (n >= 1_000_000) return `${(n/1_000_000).toFixed(n%1_000_000===0?0:1)} M FCFA`;
  if (n >= 1000) return `${Math.round(n/1000)} k FCFA`;
  return fmtFCFA(n);
};

// ─────────── App context ───────────
const AppCtx = createContext(null);

// ─────────── Top nav ───────────
const TopNav = ({ left, title, right, sub }) => (
  <div className="topnav" style={{ paddingTop: 56 }}>
    <div style={{ width: 40, display: "flex" }}>{left}</div>
    <div style={{ flex: 1, textAlign: "center" }}>
      {sub && <div className="t-eyebrow" style={{ marginBottom: 2 }}>{sub}</div>}
      <div className="t-h3">{title}</div>
    </div>
    <div style={{ width: 40, display: "flex", justifyContent: "flex-end" }}>{right}</div>
  </div>
);

// ─────────── Round icon button ───────────
const IconBtn = ({ children, onClick, size = 36 }) => (
  <button onClick={onClick} style={{
    width: size, height: size, borderRadius: 999,
    background: "var(--bg-elev-2)", border: "1px solid var(--line)",
    color: "var(--text)", display: "flex", alignItems: "center", justifyContent: "center",
    cursor: "pointer", padding: 0, flexShrink: 0,
  }}>{children}</button>
);

// ─────────── Tab bar (bottom) ───────────
const TabBar = ({ tabs, active, onChange }) => (
  <div className="tabbar">
    {tabs.map(t => (
      <div key={t.id} className={`tab ${active === t.id ? "active" : ""}`}
        onClick={() => onChange(t.id)}>
        <Icon name={t.icon} size={22} strokeWidth={active === t.id ? 2.2 : 1.7}/>
        <span style={{ marginTop: 2 }}>{t.label}</span>
      </div>
    ))}
  </div>
);

// ─────────── Stat tile ───────────
const Stat = ({ label, value, delta, tone = "accent" }) => (
  <div className="card" style={{ padding: "14px 16px", flex: 1, minWidth: 0 }}>
    <div className="t-eyebrow" style={{ marginBottom: 8 }}>{label}</div>
    <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700, letterSpacing: "-0.4px" }}>{value}</div>
    {delta !== undefined && (
      <div style={{ marginTop: 6, display: "flex", alignItems: "center", gap: 4 }}>
        <Icon name={delta >= 0 ? "arrowUp" : "arrowDown"} size={14}
          color={delta >= 0 ? "var(--success)" : "var(--danger)"} strokeWidth={2.4}/>
        <span style={{ fontSize: 12, color: delta >= 0 ? "var(--success)" : "var(--danger)", fontWeight: 600 }}>
          {Math.abs(delta)}%
        </span>
        <span style={{ fontSize: 12, color: "var(--text-3)" }}>vs. mois dern.</span>
      </div>
    )}
  </div>
);

// ─────────── Apartment listing data (shared) ───────────
const LISTINGS = [
  {
    id: "L1",
    title: "Loft moderne — Plateau",
    city: "Abidjan", area: "Plateau",
    price: 45000, currency: "FCFA",
    rating: 4.92, reviews: 128,
    beds: 1, baths: 1, surface: 38,
    tone: "1",
    superhost: true,
    type: "Loft entier",
    amenities: ["WiFi fibre", "Clim", "Parking", "Sécurité 24/7", "Cuisine équipée"],
    host: { name: "Aminata K.", since: "2023", rating: 4.9 },
    occupancy: 0.84,
    revenue: 1245000,
  },
  {
    id: "L2",
    title: "Studio cosy — Cocody",
    city: "Abidjan", area: "Cocody Riviera",
    price: 32000, currency: "FCFA",
    rating: 4.78, reviews: 64,
    beds: 1, baths: 1, surface: 28,
    tone: "2",
    type: "Studio entier",
    amenities: ["WiFi", "Clim", "Eau chaude"],
    host: { name: "Aminata K.", since: "2023", rating: 4.9 },
    occupancy: 0.71,
    revenue: 720000,
  },
  {
    id: "L3",
    title: "Appartement vue lagune",
    city: "Abidjan", area: "Marcory Zone 4",
    price: 68000, currency: "FCFA",
    rating: 4.95, reviews: 211,
    beds: 2, baths: 2, surface: 64,
    tone: "3",
    superhost: true,
    type: "Appartement entier",
    amenities: ["WiFi fibre", "Clim", "Piscine", "Salle de sport", "Parking"],
    host: { name: "Aminata K.", since: "2023", rating: 4.9 },
    occupancy: 0.92,
    revenue: 2080000,
  },
  {
    id: "L4",
    title: "Penthouse — Almadies",
    city: "Dakar", area: "Almadies",
    price: 120000, currency: "FCFA",
    rating: 4.97, reviews: 88,
    beds: 3, baths: 2, surface: 110,
    tone: "4",
    superhost: true,
    type: "Appartement entier",
    amenities: ["WiFi fibre", "Clim", "Piscine", "Vue mer", "Parking"],
    host: { name: "Aminata K.", since: "2023", rating: 4.9 },
    occupancy: 0.88,
    revenue: 3500000,
  },
];

// ─────────── Image placeholder with optional content ───────────
const ImgPh = ({ tone = "1", style, children }) => (
  <div className="img-ph" data-tone={tone} style={style}>{children}</div>
);

// Export to window for cross-script use
Object.assign(window, {
  Icon, fmtFCFA, fmtFCFAk, AppCtx, TopNav, IconBtn, TabBar, Stat, LISTINGS, ImgPh,
});
