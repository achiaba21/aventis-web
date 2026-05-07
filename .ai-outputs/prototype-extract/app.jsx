// app.jsx — Main app shell, role-aware tab nav, route stack
const { useState: appUseState, useEffect: appUseEffect } = React;

// ─── In-phone navigation ───
function PhoneApp({ initialRole = "locataire", showRoleChip = true }) {
  const [role, setRole] = appUseState(initialRole);
  const [stack, setStack] = appUseState([{ tab: "home" }]);
  const top = stack[stack.length - 1];

  appUseEffect(() => {
    // Reset to home tab when role changes
    setStack([{ tab: "home" }]);
  }, [role]);

  const push = (frame) => setStack(s => [...s, frame]);
  const pop = () => setStack(s => s.length > 1 ? s.slice(0, -1) : s);
  const setTab = (tab) => setStack([{ tab }]);

  // ── Tabs by role ──
  const tabsByRole = {
    locataire: [
      { id: "home", label: "Explorer", icon: "search" },
      { id: "trips", label: "Voyages", icon: "calendar" },
      { id: "saved", label: "Favoris", icon: "heart" },
      { id: "messages", label: "Messages", icon: "chat" },
      { id: "profile", label: "Profil", icon: "user" },
    ],
    proprietaire: [
      { id: "home", label: "Accueil", icon: "grid" },
      { id: "listings", label: "Annonces", icon: "listings" },
      { id: "finances", label: "Finances", icon: "chart" },
      { id: "messages", label: "Messages", icon: "chat" },
      { id: "profile", label: "Profil", icon: "user" },
    ],
    demarcheur: [
      { id: "home", label: "Accueil", icon: "grid" },
      { id: "referrals", label: "Demandes", icon: "send" },
      { id: "wallet", label: "Gains", icon: "wallet" },
      { id: "messages", label: "Messages", icon: "chat" },
      { id: "profile", label: "Profil", icon: "user" },
    ],
  };
  const tabs = tabsByRole[role];

  // ── Render screen by (role, top.tab + nested route) ──
  let screen = null;
  const tab = top.tab;
  const sub = top.sub;
  const subId = top.id;

  if (role === "locataire") {
    if (tab === "home" && !sub) screen = <LocataireHome onOpen={(s, id) => push({ tab: "home", sub: s, id })}/>;
    else if (tab === "home" && sub === "search") screen = <LocataireSearch onBack={pop} onApply={pop}/>;
    else if (tab === "home" && sub === "detail") screen = <LocataireDetail id={subId} onBack={pop} onReserve={(id) => push({ tab: "home", sub: "reserve", id })}/>;
    else if (tab === "home" && sub === "reserve") screen = <LocataireReserve id={subId} onBack={pop} onConfirm={() => setTab("trips")}/>;
    else if (tab === "trips") screen = <LocataireTrips/>;
    else if (tab === "saved") screen = <SavedScreen/>;
    else if (tab === "messages" && !sub) screen = <MessagingList role="locataire" onOpen={(id) => push({ tab: "messages", sub: "thread", id })}/>;
    else if (tab === "messages" && sub === "thread") screen = <MessagingThread id={subId} role="locataire" onBack={pop}/>;
    else if (tab === "profile") screen = <Profile role={role} onSwitchRole={setRole} onLogout={() => {}}/>;
  } else if (role === "proprietaire") {
    if (tab === "home" && !sub) screen = <ProprietaireDashboard onOpen={(s, id) => {
      if (s === "finances") setTab("finances");
      else if (s === "listings") setTab("listings");
      else if (s === "listing") push({ tab: "listings", sub: "edit", id });
    }}/>;
    else if (tab === "listings" && !sub) screen = <ProprietaireListings onBack={() => setTab("home")} onOpen={(s, id) => push({ tab: "listings", sub: "edit", id })}/>;
    else if (tab === "listings" && sub === "edit") screen = <ProprietaireListingEdit id={subId} onBack={pop}/>;
    else if (tab === "finances") screen = <ProprietaireFinances onBack={() => setTab("home")}/>;
    else if (tab === "messages" && !sub) screen = <MessagingList role="proprietaire" onOpen={(id) => push({ tab: "messages", sub: "thread", id })}/>;
    else if (tab === "messages" && sub === "thread") screen = <MessagingThread id={subId} role="proprietaire" onBack={pop}/>;
    else if (tab === "profile") screen = <Profile role={role} onSwitchRole={setRole} onLogout={() => {}}/>;
  } else if (role === "demarcheur") {
    if (tab === "home" && !sub) screen = <DemarcheurDashboard onOpen={(s, id) => {
      if (s === "new") push({ tab: "referrals", sub: "new" });
      else if (s === "referrals") setTab("referrals");
      else if (s === "referral") push({ tab: "referrals", sub: "detail", id });
    }}/>;
    else if (tab === "referrals" && !sub) screen = <DemarcheurReferrals onOpen={(s, id) => push({ tab: "referrals", sub: s, id })}/>;
    else if (tab === "referrals" && sub === "new") screen = <DemarcheurNew onBack={pop} onSubmit={pop}/>;
    else if (tab === "referrals" && sub === "detail") screen = <DemarcheurReferralDetail id={subId} onBack={pop}/>;
    else if (tab === "wallet") screen = <DemarcheurWallet onBack={() => setTab("home")}/>;
    else if (tab === "messages" && !sub) screen = <MessagingList role="demarcheur" onOpen={(id) => push({ tab: "messages", sub: "thread", id })}/>;
    else if (tab === "messages" && sub === "thread") screen = <MessagingThread id={subId} role="demarcheur" onBack={pop}/>;
    else if (tab === "profile") screen = <Profile role={role} onSwitchRole={setRole} onLogout={() => {}}/>;
  }

  // Determine if we should hide tabbar (e.g. on detail screens where bottom-bar is used)
  const hideTabBar = (
    (role === "locataire" && tab === "home" && (sub === "detail" || sub === "reserve" || sub === "search")) ||
    (tab === "messages" && sub === "thread")
  );

  return (
    <div className="asfar" style={{ width: "100%", height: "100%", display: "flex", flexDirection: "column", overflow: "hidden", background: "var(--bg)" }}>
      <div style={{ flex: 1, position: "relative", overflow: "hidden" }}>
        {screen}
      </div>
      {!hideTabBar && (
        <TabBar tabs={tabs} active={tab} onChange={setTab}/>
      )}
    </div>
  );
}

// ─── Saved screen (lightweight) ───
function SavedScreen() {
  return (
    <div className="screen">
      <TopNav title="Favoris"/>
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {LISTINGS.slice(0, 4).map(l => (
            <div key={l.id} className="card" style={{ overflow: "hidden", cursor: "pointer" }}>
              <ImgPh tone={l.tone} style={{ width: "100%", aspectRatio: "1/1", position: "relative" }}>
                <div style={{
                  position: "absolute", top: 8, right: 8,
                  width: 28, height: 28, borderRadius: 99, background: "rgba(10,10,11,0.6)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  <Icon name="heart" size={14} color="var(--accent)" strokeWidth={2.4}/>
                </div>
              </ImgPh>
              <div style={{ padding: 10 }}>
                <div style={{ fontSize: 12, fontWeight: 600, marginBottom: 2 }}>{l.title}</div>
                <div className="t-small" style={{ fontSize: 11 }}>{l.area}</div>
                <div className="t-mono-num" style={{ fontSize: 12, fontWeight: 700, marginTop: 4 }}>
                  {fmtFCFAk(l.price)}<span style={{ color: "var(--text-3)", fontWeight: 400 }}>/n</span>
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

// ─── Demarcheur referrals list ───
function DemarcheurReferrals({ onOpen }) {
  const [filter, setFilter] = appUseState("all");
  const all = [
    { id: 1, client: "Rachid B.", listing: "Loft Plateau", nights: 3, comm: 13500, status: "accepted", date: "2h", tone: "1" },
    { id: 2, client: "Fatou S.", listing: "Studio Cocody", nights: 5, comm: 16000, status: "pending", date: "Hier", tone: "2" },
    { id: 3, client: "Hassan O.", listing: "Penthouse Almadies", nights: 4, comm: 48000, status: "pending", date: "Hier", tone: "4" },
    { id: 4, client: "Akua N.", listing: "Vue lagune", nights: 2, comm: 13600, status: "accepted", date: "3 j", tone: "3" },
    { id: 5, client: "Yacouba D.", listing: "Loft Plateau", nights: 7, comm: 31500, status: "completed", date: "5 nov", tone: "1" },
    { id: 6, client: "Mamadou T.", listing: "Studio Cocody", nights: 1, comm: 0, status: "rejected", date: "3 nov", tone: "2" },
    { id: 7, client: "Sékou B.", listing: "Loft Plateau", nights: 4, comm: 18000, status: "completed", date: "1 nov", tone: "1" },
  ];
  const filtered = filter === "all" ? all : all.filter(r => r.status === filter);

  return (
    <div className="screen">
      <TopNav title="Mes demandes" right={
        <button className="btn btn-primary btn-sm" onClick={() => onOpen("new")}>
          <Icon name="plus" size={14} strokeWidth={2.4}/> Nouvelle
        </button>
      }/>
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div style={{ display: "flex", gap: 8, marginBottom: 16, overflowX: "auto", scrollbarWidth: "none" }}>
          {[
            { id: "all", l: `Toutes (${all.length})` },
            { id: "pending", l: "En attente" },
            { id: "accepted", l: "Acceptées" },
            { id: "completed", l: "Terminées" },
            { id: "rejected", l: "Refusées" },
          ].map(f => (
            <div key={f.id} className={`chip ${filter === f.id ? "chip-active" : ""}`}
              onClick={() => setFilter(f.id)}>{f.l}</div>
          ))}
        </div>
        <div className="card">
          {filtered.map(r => (
            <ReferralRow key={r.id} r={{ ...r, listingTone: r.tone }} onOpen={() => onOpen("detail", r.id)}/>
          ))}
        </div>
        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

window.PhoneApp = PhoneApp;
window.SavedScreen = SavedScreen;
window.DemarcheurReferrals = DemarcheurReferrals;
