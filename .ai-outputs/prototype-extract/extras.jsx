// extras.jsx — onboarding, messaging, profile, role switcher
const { useState: exUseState, useEffect: exUseEffect, useRef: exUseRef } = React;

// ─── Onboarding (role pick) ───
function Onboarding({ onPickRole }) {
  return (
    <div className="screen" style={{ background: "var(--bg)" }}>
      {/* Hero gradient */}
      <div style={{
        position: "absolute", inset: 0, opacity: 0.6, pointerEvents: "none",
        background: `
          radial-gradient(ellipse 400px 300px at 20% 0%, rgba(232,184,107,0.18), transparent 70%),
          radial-gradient(ellipse 400px 400px at 90% 60%, rgba(232,184,107,0.10), transparent 70%)
        `,
      }}/>

      <div className="scroll" style={{
        paddingTop: 80, padding: "80px 28px 0",
        position: "relative", zIndex: 1,
      }}>
        {/* Logo */}
        <div className="row" style={{ gap: 10, marginBottom: 60 }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10, background: "var(--accent)",
            display: "flex", alignItems: "center", justifyContent: "center",
            color: "#1A1206", fontWeight: 800, fontSize: 18, fontStyle: "italic",
          }}>A</div>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.5 }}>asfar</div>
        </div>

        <div className="t-display" style={{ marginBottom: 16 }}>
          Voyagez,<br/>louez,<br/>
          <span style={{ color: "var(--accent)" }}>gagnez.</span>
        </div>
        <div className="t-body" style={{ marginBottom: 50 }}>
          La plateforme de location meublée qui connecte voyageurs, propriétaires et démarcheurs.
        </div>

        <div className="t-eyebrow" style={{ marginBottom: 14 }}>Je suis…</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 28 }}>
          {[
            { id: "locataire", icon: "key", title: "Locataire", sub: "Trouver un logement à louer" },
            { id: "proprietaire", icon: "home", title: "Propriétaire", sub: "Mettre mon bien en location" },
            { id: "demarcheur", icon: "handshake", title: "Démarcheur", sub: "Référer des clients & gagner des commissions" },
          ].map(r => (
            <div key={r.id} className="card" onClick={() => onPickRole(r.id)} style={{
              padding: 16, display: "flex", alignItems: "center", gap: 14, cursor: "pointer",
              background: "var(--bg-elev-1)",
            }}>
              <div style={{
                width: 46, height: 46, borderRadius: 12,
                background: "var(--accent-soft)", color: "var(--accent)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={r.icon} size={22} strokeWidth={1.8}/>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{r.title}</div>
                <div className="t-small" style={{ fontSize: 12 }}>{r.sub}</div>
              </div>
              <Icon name="arrowRight" size={18} color="var(--text-3)"/>
            </div>
          ))}
        </div>

        <div style={{ textAlign: "center" }}>
          <span className="t-small" style={{ fontSize: 13 }}>
            Vous avez déjà un compte ? <span style={{ color: "var(--accent)", fontWeight: 600 }}>Se connecter</span>
          </span>
        </div>
        <div style={{ height: 60 }}/>
      </div>
    </div>
  );
}

// ─── Messaging — conversation list ───
function MessagingList({ role, onOpen }) {
  // Different conversations depending on role
  const convosByRole = {
    locataire: [
      { id: 1, who: "Aminata K.", sub: "Loft Plateau", last: "Bienvenue ! Le code wifi est…", time: "14:32", unread: 1, role: "Hôte", certified: true },
      { id: 2, who: "Service Asfar", sub: "Support", last: "Votre paiement a été reçu ✓", time: "Hier", unread: 0, role: "Asfar" },
      { id: 3, who: "Kofi A.", sub: "Studio Cocody", last: "Merci pour votre séjour !", time: "12 oct", unread: 0, role: "Hôte" },
    ],
    proprietaire: [
      { id: 1, who: "Rachid B.", sub: "Loft Plateau · 12-15 nov", last: "À quelle heure puis-je arriver ?", time: "14:32", unread: 2, role: "Locataire" },
      { id: 2, who: "Diallo M.", sub: "Démarcheur · REF-D8H3K", last: "J'ai un client pour Vue lagune…", time: "13:08", unread: 1, role: "Démarcheur" },
      { id: 3, who: "Mariam T.", sub: "Studio Cocody · terminé", last: "Tout était parfait, merci !", time: "Hier", unread: 0, role: "Locataire" },
      { id: 4, who: "Hassan O.", sub: "Penthouse Almadies", last: "Le prix est-il négociable ?", time: "Hier", unread: 0, role: "Locataire" },
    ],
    demarcheur: [
      { id: 1, who: "Aminata K.", sub: "REF-D8H3K · acceptée", last: "OK, dis à ton client qu'il peut payer", time: "14:00", unread: 0, role: "Hôte", certified: true },
      { id: 2, who: "Rachid B.", sub: "Client · Loft Plateau", last: "Je confirme, j'envoie le paiement", time: "12:15", unread: 1, role: "Client" },
      { id: 3, who: "M. Konaté", sub: "Propriétaire · Vue lagune", last: "Tu peux m'envoyer plus de clients ?", time: "Hier", unread: 0, role: "Hôte" },
    ],
  };
  const convos = convosByRole[role] || convosByRole.locataire;

  return (
    <div className="screen">
      <TopNav title="Messages" right={<IconBtn><Icon name="edit" size={16}/></IconBtn>}/>
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div className="input row" style={{ gap: 10, marginBottom: 16 }}>
          <Icon name="search" size={18} color="var(--text-3)"/>
          <span style={{ color: "var(--text-3)", fontSize: 14 }}>Rechercher</span>
        </div>
        <div className="card">
          {convos.map((c, i) => (
            <div key={c.id} className="listrow" onClick={() => onOpen(c.id)}
              style={{ cursor: "pointer", alignItems: "flex-start" }}>
              <div className="avatar" style={{ width: 46, height: 46, fontSize: 14, flexShrink: 0, marginTop: 2 }}>
                {c.who.split(" ").map(w => w[0]).slice(0, 2).join("")}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="row" style={{ justifyContent: "space-between", marginBottom: 2 }}>
                  <div className="row" style={{ gap: 6, minWidth: 0 }}>
                    <span style={{ fontSize: 14, fontWeight: 600, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                      {c.who}
                    </span>
                    {c.certified && <Icon name="shield" size={12} color="var(--accent)"/>}
                  </div>
                  <span className="t-small" style={{ fontSize: 11, flexShrink: 0 }}>{c.time}</span>
                </div>
                <div className="row" style={{ gap: 6, marginBottom: 4 }}>
                  <span className={`badge badge-${c.role === "Démarcheur" ? "info" : c.role === "Asfar" ? "neutral" : "accent"}`}
                    style={{ fontSize: 9 }}>{c.role}</span>
                  <span className="t-small" style={{ fontSize: 11 }}>· {c.sub}</span>
                </div>
                <div className="row" style={{ justifyContent: "space-between" }}>
                  <span className="t-small" style={{
                    fontSize: 13, color: c.unread ? "var(--text)" : "var(--text-3)",
                    fontWeight: c.unread ? 500 : 400,
                    overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap",
                    flex: 1, minWidth: 0,
                  }}>{c.last}</span>
                  {c.unread > 0 && (
                    <span style={{
                      width: 18, height: 18, borderRadius: 99,
                      background: "var(--accent)", color: "#1A1206",
                      fontSize: 11, fontWeight: 700,
                      display: "flex", alignItems: "center", justifyContent: "center",
                      marginLeft: 8,
                    }}>{c.unread}</span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

// ─── Messaging — single conversation ───
function MessagingThread({ id, role, onBack }) {
  const data = {
    locataire: {
      who: "Aminata K.", sub: "Hôte · Loft Plateau", certified: true,
      messages: [
        { from: "them", text: "Bonjour Aïcha 👋 ! Bienvenue à Abidjan !", t: "14:00" },
        { from: "them", text: "Voici les infos pour votre arrivée demain :", t: "14:00" },
        { from: "them", kind: "card", t: "14:01" },
        { from: "me", text: "Super merci ! On arrivera vers 18h", t: "14:25" },
        { from: "them", text: "Parfait, je serai là pour vous accueillir. Le code wifi est ASFAR2025 et le digicode du portail est 4892.", t: "14:32" },
      ],
    },
    proprietaire: {
      who: "Rachid B.", sub: "Locataire · Loft Plateau · 12-15 nov", certified: false,
      messages: [
        { from: "them", text: "Bonjour, j'arrive demain", t: "13:30" },
        { from: "me", text: "Bienvenue Rachid !", t: "14:00" },
        { from: "them", text: "À quelle heure puis-je arriver ?", t: "14:32" },
        { from: "them", text: "Je suis à l'aéroport vers 17h", t: "14:32" },
      ],
    },
    demarcheur: {
      who: "Aminata K.", sub: "Hôte · Loft Plateau", certified: true,
      messages: [
        { from: "me", text: "Bonsoir Aminata ! J'ai un client pour le Loft, 3 nuits du 22 au 25 nov", t: "13:15" },
        { from: "them", text: "Salut Diallo. Le client a déjà fait un séjour avec toi ?", t: "13:40" },
        { from: "me", text: "Oui, c'est Rachid, il est très sérieux", t: "13:45" },
        { from: "them", text: "OK parfait, j'accepte la demande", t: "14:00" },
        { from: "them", kind: "accept", t: "14:00" },
      ],
    },
  };
  const c = data[role] || data.locataire;

  return (
    <div className="screen">
      {/* Custom top */}
      <div style={{ paddingTop: 56 }}>
        <div style={{
          padding: "10px 14px 14px",
          borderBottom: "1px solid var(--line)",
          display: "flex", alignItems: "center", gap: 12,
        }}>
          <IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>
          <div className="avatar" style={{ width: 38, height: 38, fontSize: 13 }}>
            {c.who.split(" ").map(w => w[0]).slice(0,2).join("")}
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="row" style={{ gap: 6 }}>
              <span style={{ fontSize: 14, fontWeight: 600 }}>{c.who}</span>
              {c.certified && <Icon name="shield" size={12} color="var(--accent)"/>}
            </div>
            <div className="t-small" style={{ fontSize: 11, marginTop: 1 }}>{c.sub}</div>
          </div>
          <IconBtn><Icon name="phone" size={16}/></IconBtn>
        </div>
      </div>

      <div className="scroll" style={{ padding: "20px 18px 0", display: "flex", flexDirection: "column", gap: 8 }}>
        <div className="t-small" style={{ textAlign: "center", fontSize: 11, marginBottom: 12 }}>Aujourd'hui</div>
        {c.messages.map((m, i) => (
          <div key={i} style={{
            display: "flex", justifyContent: m.from === "me" ? "flex-end" : "flex-start",
            marginBottom: 4,
          }}>
            {m.kind === "card" ? (
              <div className="card" style={{ maxWidth: "82%", padding: 12, display: "flex", gap: 10 }}>
                <ImgPh tone="1" style={{ width: 56, height: 56, borderRadius: 10 }}/>
                <div>
                  <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>RÉSERVATION</div>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>Loft Plateau</div>
                  <div className="t-small" style={{ fontSize: 11 }}>12-15 nov · 3 nuits</div>
                  <div className="t-mono-num" style={{ fontSize: 11, marginTop: 2, fontWeight: 600 }}>ASF-7K2N9</div>
                </div>
              </div>
            ) : m.kind === "accept" ? (
              <div className="card" style={{
                maxWidth: "82%", padding: 12,
                background: "var(--accent-soft)", border: "1px solid rgba(232,184,107,0.25)",
              }}>
                <div className="row" style={{ gap: 8, marginBottom: 4 }}>
                  <Icon name="check" size={16} color="var(--accent)" strokeWidth={2.6}/>
                  <span style={{ fontSize: 13, fontWeight: 700, color: "var(--accent)" }}>Demande acceptée</span>
                </div>
                <div className="t-small" style={{ fontSize: 11 }}>REF-D8H3K · Loft Plateau · 22-25 nov</div>
                <div className="t-mono-num" style={{ fontSize: 13, fontWeight: 700, marginTop: 4 }}>
                  Commission: +{fmtFCFA(13500)}
                </div>
              </div>
            ) : (
              <div style={{
                maxWidth: "78%", padding: "10px 14px",
                background: m.from === "me" ? "var(--accent)" : "var(--bg-elev-2)",
                color: m.from === "me" ? "#1A1206" : "var(--text)",
                borderRadius: 18,
                borderBottomRightRadius: m.from === "me" ? 6 : 18,
                borderBottomLeftRadius: m.from === "me" ? 18 : 6,
                fontSize: 14, lineHeight: 1.4,
              }}>
                {m.text}
                <div style={{
                  fontSize: 10, opacity: 0.6, marginTop: 4,
                  textAlign: m.from === "me" ? "right" : "left",
                }}>{m.t}</div>
              </div>
            )}
          </div>
        ))}
        <div style={{ height: 20 }}/>
      </div>

      {/* Input */}
      <div style={{
        padding: "10px 14px 30px", borderTop: "1px solid var(--line)",
        background: "rgba(10,10,11,0.92)",
        display: "flex", gap: 10, alignItems: "center",
      }}>
        <IconBtn><Icon name="plus" size={20}/></IconBtn>
        <div className="input" style={{
          flex: 1, padding: "10px 14px", color: "var(--text-3)", fontSize: 14,
        }}>Message…</div>
        <button style={{
          width: 40, height: 40, borderRadius: 99, background: "var(--accent)", border: "none",
          display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
        }}>
          <Icon name="send" size={18} color="#1A1206" strokeWidth={2.2}/>
        </button>
      </div>
    </div>
  );
}

// ─── Profile / Settings ───
function Profile({ role, onSwitchRole, onLogout }) {
  const profiles = {
    locataire: { name: "Aïcha Camara", sub: "Locataire · Membre depuis 2024", verified: true },
    proprietaire: { name: "Aminata Koné", sub: "Propriétaire · 4 biens", verified: true, badge: "★ Hôte certifié" },
    demarcheur: { name: "Diallo Mamadou", sub: "Démarcheur · 27 clients", verified: true, badge: "Top démarcheur" },
  };
  const p = profiles[role];

  return (
    <div className="screen">
      <TopNav title="Profil" right={<IconBtn><Icon name="settings" size={16}/></IconBtn>}/>
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div className="card" style={{ padding: 18, marginBottom: 18, textAlign: "center" }}>
          <div className="avatar" style={{
            width: 78, height: 78, fontSize: 28, margin: "0 auto 14px",
          }}>{p.name.split(" ").map(w => w[0]).slice(0,2).join("")}</div>
          <div className="row" style={{ justifyContent: "center", gap: 6, marginBottom: 4 }}>
            <span style={{ fontSize: 18, fontWeight: 700 }}>{p.name}</span>
            {p.verified && <Icon name="shield" size={14} color="var(--accent)"/>}
          </div>
          <div className="t-small" style={{ marginBottom: 12 }}>{p.sub}</div>
          {p.badge && <span className="badge badge-accent">{p.badge}</span>}
        </div>

        {/* Role switcher */}
        <div className="t-h3" style={{ marginBottom: 10 }}>Changer de rôle</div>
        <div className="card" style={{ marginBottom: 18 }}>
          {[
            { id: "locataire", icon: "key", l: "Locataire" },
            { id: "proprietaire", icon: "home", l: "Propriétaire" },
            { id: "demarcheur", icon: "handshake", l: "Démarcheur" },
          ].map(r => (
            <div key={r.id} className="listrow" onClick={() => onSwitchRole(r.id)}
              style={{ cursor: "pointer" }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10,
                background: role === r.id ? "var(--accent)" : "var(--bg-elev-3)",
                color: role === r.id ? "#1A1206" : "var(--text-2)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={r.icon} size={18} strokeWidth={2}/>
              </div>
              <span style={{ flex: 1, fontSize: 14, fontWeight: role === r.id ? 600 : 500 }}>{r.l}</span>
              {role === r.id ? (
                <span className="badge badge-accent">Actif</span>
              ) : (
                <Icon name="arrowRight" size={16} color="var(--text-3)"/>
              )}
            </div>
          ))}
        </div>

        <div className="t-h3" style={{ marginBottom: 10 }}>Compte</div>
        <div className="card" style={{ marginBottom: 18 }}>
          {[
            { i: "user", l: "Informations personnelles" },
            { i: "shield", l: "Vérification d'identité", v: "Vérifié" },
            { i: "wallet", l: "Méthodes de paiement", v: "3 actives" },
            { i: "bell", l: "Notifications" },
            { i: "settings", l: "Préférences" },
          ].map(r => (
            <div key={r.l} className="listrow">
              <Icon name={r.i} size={18} color="var(--text-2)"/>
              <span style={{ flex: 1, fontSize: 14 }}>{r.l}</span>
              {r.v && <span className="t-small" style={{ fontSize: 12 }}>{r.v}</span>}
              <Icon name="arrowRight" size={16} color="var(--text-3)"/>
            </div>
          ))}
        </div>

        <button className="btn btn-secondary btn-block" onClick={onLogout}
          style={{ marginBottom: 10, color: "var(--danger)" }}>
          Se déconnecter
        </button>

        <div className="t-small" style={{ textAlign: "center", fontSize: 11, marginTop: 16 }}>
          Asfar v1.0 · 🇨🇮 Côte d'Ivoire
        </div>

        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

Object.assign(window, { Onboarding, MessagingList, MessagingThread, Profile });
