// proprietaire.jsx — Owner role screens for Asfar
const { useState: ownUseState, useMemo: ownUseMemo } = React;

// ─── Dashboard ───
function ProprietaireDashboard({ onOpen }) {
  const totalRev = LISTINGS.reduce((a, b) => a + b.revenue, 0);
  const occ = Math.round(LISTINGS.reduce((a, b) => a + b.occupancy, 0) / LISTINGS.length * 100);

  // Mocked monthly revenue last 6 months
  const months = [
    { m: "Juin", v: 740 }, { m: "Juil", v: 820 },
    { m: "Août", v: 1100 }, { m: "Sept", v: 1340 },
    { m: "Oct", v: 1580 }, { m: "Nov", v: 1900, hi: true },
  ];
  const max = Math.max(...months.map(x => x.v));

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn><Icon name="grid" size={18}/></IconBtn>}
        title="Tableau de bord"
        sub="Propriétaire"
        right={<IconBtn><Icon name="bell" size={18}/></IconBtn>}
      />
      <div className="scroll" style={{ padding: "0 18px" }}>
        {/* Greeting */}
        <div style={{ marginBottom: 18 }}>
          <div className="t-eyebrow" style={{ marginBottom: 4 }}>Bienvenue,</div>
          <div className="t-h1">Aminata K.</div>
        </div>

        {/* Hero revenue card */}
        <div style={{
          background: "linear-gradient(135deg, #2A1F0E 0%, #1A1206 60%, #0F0A04 100%)",
          border: "1px solid rgba(232,184,107,0.25)",
          borderRadius: 22, padding: 18, marginBottom: 16, position: "relative", overflow: "hidden",
        }}>
          <div style={{
            position: "absolute", top: -40, right: -40, width: 160, height: 160, borderRadius: 999,
            background: "radial-gradient(circle, rgba(232,184,107,0.18), transparent 70%)",
          }}/>
          <div className="t-eyebrow" style={{ color: "var(--accent)", marginBottom: 8 }}>Revenus du mois</div>
          <div className="row" style={{ alignItems: "baseline", gap: 8, marginBottom: 4 }}>
            <span className="t-mono-num" style={{ fontSize: 32, fontWeight: 700, letterSpacing: -1 }}>
              {fmtFCFAk(1900000)}
            </span>
          </div>
          <div className="row" style={{ gap: 6 }}>
            <span className="badge badge-success">
              <Icon name="arrowUp" size={11} strokeWidth={2.4}/> +20%
            </span>
            <span className="t-small" style={{ fontSize: 12 }}>vs. octobre · {fmtFCFAk(1580000)}</span>
          </div>

          {/* Mini chart */}
          <div style={{ marginTop: 18 }}>
            <div className="sparkbar" style={{ height: 60 }}>
              {months.map((m, i) => (
                <div key={i} className={m.hi ? "hi" : ""}
                  style={{ height: `${(m.v / max) * 100}%`, position: "relative" }}>
                  {m.hi && (
                    <div style={{
                      position: "absolute", top: -22, left: "50%", transform: "translateX(-50%)",
                      fontSize: 10, fontWeight: 600, color: "var(--accent)", whiteSpace: "nowrap",
                    }}>{fmtFCFAk(1900000)}</div>
                  )}
                </div>
              ))}
            </div>
            <div className="row" style={{ marginTop: 8, justifyContent: "space-between" }}>
              {months.map(m => (
                <span key={m.m} className="t-small" style={{ fontSize: 10, flex: 1, textAlign: "center" }}>{m.m}</span>
              ))}
            </div>
          </div>
        </div>

        {/* KPI row */}
        <div style={{ display: "flex", gap: 10, marginBottom: 16 }}>
          <Stat label="Occupation" value={`${occ}%`} delta={6}/>
          <Stat label="ADR moyen" value="48k" delta={4}/>
        </div>
        <div style={{ display: "flex", gap: 10, marginBottom: 22 }}>
          <Stat label="Réservations" value="42" delta={12}/>
          <Stat label="Note moy." value="4.91" delta={1}/>
        </div>

        {/* Cashflow split */}
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 12 }}>
          <div className="t-h3">Flux financier</div>
          <span className="t-small" style={{ color: "var(--accent)" }} onClick={() => onOpen("finances")}>Détails →</span>
        </div>
        <div className="card" style={{ padding: 16, marginBottom: 22 }}>
          {/* Stacked bar */}
          <div style={{
            height: 14, borderRadius: 99, overflow: "hidden", display: "flex",
            background: "var(--bg-elev-3)", marginBottom: 16,
          }}>
            <div style={{ width: "62%", background: "var(--accent)" }}/>
            <div style={{ width: "20%", background: "#A06B30" }}/>
            <div style={{ width: "12%", background: "#5E6CFF" }}/>
            <div style={{ width: "6%", background: "var(--text-3)" }}/>
          </div>
          {[
            { c: "var(--accent)", l: "Locations nettes", v: 1178000 },
            { c: "#A06B30", l: "Charges (entretien, eau, élec.)", v: 380000 },
            { c: "#5E6CFF", l: "Commissions démarcheurs", v: 228000 },
            { c: "var(--text-3)", l: "Frais plateforme", v: 114000 },
          ].map(r => (
            <div key={r.l} className="row" style={{ justifyContent: "space-between", padding: "6px 0" }}>
              <div className="row" style={{ gap: 10 }}>
                <div style={{ width: 8, height: 8, borderRadius: 99, background: r.c }}/>
                <span style={{ fontSize: 13, color: "var(--text-2)" }}>{r.l}</span>
              </div>
              <span className="t-mono-num" style={{ fontSize: 13, fontWeight: 600 }}>{fmtFCFAk(r.v)}</span>
            </div>
          ))}
        </div>

        {/* Active listings */}
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 12 }}>
          <div className="t-h3">Mes annonces</div>
          <span className="t-small" style={{ color: "var(--accent)" }} onClick={() => onOpen("listings")}>Tout voir</span>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 22 }}>
          {LISTINGS.map(l => (
            <div key={l.id} className="card" style={{
              padding: 12, display: "flex", gap: 12, cursor: "pointer",
            }} onClick={() => onOpen("listing", l.id)}>
              <ImgPh tone={l.tone} style={{ width: 64, height: 64, borderRadius: 12, flexShrink: 0 }}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>{l.title}</div>
                <div className="t-small" style={{ fontSize: 12, marginBottom: 6 }}>{l.area}</div>
                <div className="row" style={{ gap: 6 }}>
                  <span className="badge badge-success" style={{ fontSize: 10 }}>● Actif</span>
                  <span className="t-small" style={{ fontSize: 11 }}>{Math.round(l.occupancy*100)}% occup.</span>
                </div>
              </div>
              <div style={{ textAlign: "right" }}>
                <div className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>
                  {fmtFCFAk(l.revenue)}
                </div>
                <div className="t-small" style={{ fontSize: 11 }}>ce mois</div>
              </div>
            </div>
          ))}
        </div>

        {/* Pending requests */}
        <div className="t-h3" style={{ marginBottom: 12 }}>Demandes en attente</div>
        <div className="card" style={{ marginBottom: 22 }}>
          {[
            { who: "Diallo M. (démarcheur)", type: "Réservation pour client", date: "Loft Plateau · 22-25 nov · 3 nuits", new: true },
            { who: "Direct: Rachid B.", type: "Question sur l'annonce", date: "Penthouse Almadies", new: true },
          ].map((r, i) => (
            <div key={i} className="listrow" style={{ alignItems: "flex-start" }}>
              <div className="avatar" style={{ width: 36, height: 36, fontSize: 12, marginTop: 2 }}>
                {r.who.split(" ").map(w => w[0]).slice(0,2).join("")}
              </div>
              <div style={{ flex: 1 }}>
                <div className="row" style={{ gap: 6, marginBottom: 2 }}>
                  <span style={{ fontSize: 13, fontWeight: 600 }}>{r.who}</span>
                  {r.new && <span className="badge badge-accent" style={{ fontSize: 9 }}>NOUVEAU</span>}
                </div>
                <div className="t-small" style={{ fontSize: 12, marginBottom: 2 }}>{r.type}</div>
                <div className="t-small" style={{ fontSize: 11, color: "var(--text-3)" }}>{r.date}</div>
              </div>
              <Icon name="arrowRight" size={16} color="var(--text-3)"/>
            </div>
          ))}
        </div>

        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

// ─── Finances detail (P&L) ───
function ProprietaireFinances({ onBack }) {
  const [period, setPeriod] = ownUseState("Mois");

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title="Finances"
        sub="P&L · Charges · Projections"
        right={<IconBtn><Icon name="download" size={16}/></IconBtn>}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        {/* Period switcher */}
        <div style={{
          display: "flex", padding: 4, borderRadius: 12,
          background: "var(--bg-elev-2)", border: "1px solid var(--line)",
          marginBottom: 18,
        }}>
          {["Semaine", "Mois", "Trimestre", "Année"].map(p => (
            <div key={p} onClick={() => setPeriod(p)}
              style={{
                flex: 1, padding: "10px 8px", borderRadius: 8, textAlign: "center",
                fontSize: 13, fontWeight: 600, cursor: "pointer",
                background: period === p ? "var(--bg-elev-3)" : "transparent",
                color: period === p ? "var(--text)" : "var(--text-3)",
              }}>{p}</div>
          ))}
        </div>

        {/* Net income hero */}
        <div className="card" style={{ padding: 18, marginBottom: 16 }}>
          <div className="t-eyebrow" style={{ marginBottom: 6 }}>Bénéfice net · novembre</div>
          <div className="t-mono-num" style={{ fontSize: 30, fontWeight: 700, letterSpacing: -0.6 }}>
            {fmtFCFA(1178000)}
          </div>
          <div className="row" style={{ gap: 6, marginTop: 6 }}>
            <span className="badge badge-success">↑ 24%</span>
            <span className="t-small" style={{ fontSize: 12 }}>vs. octobre</span>
          </div>
        </div>

        {/* P&L */}
        <div className="t-h3" style={{ marginBottom: 12 }}>Compte de résultat</div>
        <div className="card" style={{ padding: 16, marginBottom: 22 }}>
          {/* Revenus */}
          <div className="row" style={{ justifyContent: "space-between", marginBottom: 10 }}>
            <span style={{ fontSize: 14, fontWeight: 700, color: "var(--success)" }}>+ Revenus</span>
            <span className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{fmtFCFAk(1900000)}</span>
          </div>
          {[
            ["Locations brutes (42 nuits)", 1900000],
            ["Frais ménage facturés", 84000],
          ].map(([k, v]) => (
            <div key={k} className="row" style={{ justifyContent: "space-between", padding: "6px 0 6px 12px", fontSize: 13, color: "var(--text-2)" }}>
              <span>{k}</span><span className="t-mono-num">{fmtFCFAk(v)}</span>
            </div>
          ))}

          <div style={{ height: 1, background: "var(--line)", margin: "12px 0" }}/>

          {/* Charges */}
          <div className="row" style={{ justifyContent: "space-between", marginBottom: 10 }}>
            <span style={{ fontSize: 14, fontWeight: 700, color: "var(--danger)" }}>− Charges</span>
            <span className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{fmtFCFAk(722000)}</span>
          </div>
          {[
            ["Frais plateforme Asfar (6%)", 114000],
            ["Commissions démarcheurs", 228000],
            ["Ménage & blanchisserie", 168000],
            ["Eau & électricité", 92000],
            ["Maintenance & réparations", 75000],
            ["Internet & TV", 45000],
          ].map(([k, v]) => (
            <div key={k} className="row" style={{ justifyContent: "space-between", padding: "6px 0 6px 12px", fontSize: 13, color: "var(--text-2)" }}>
              <span>{k}</span><span className="t-mono-num">{fmtFCFAk(v)}</span>
            </div>
          ))}

          <div style={{ height: 1, background: "var(--line)", margin: "12px 0" }}/>

          <div className="row" style={{ justifyContent: "space-between", padding: "4px 0" }}>
            <span style={{ fontSize: 15, fontWeight: 700 }}>Bénéfice net</span>
            <span className="t-mono-num" style={{ fontSize: 18, fontWeight: 700, color: "var(--accent)" }}>
              {fmtFCFAk(1178000)}
            </span>
          </div>
          <div className="row" style={{ justifyContent: "space-between", marginTop: 4 }}>
            <span className="t-small" style={{ fontSize: 11 }}>Marge nette</span>
            <span className="t-small t-mono-num" style={{ fontSize: 11, fontWeight: 600, color: "var(--success)" }}>62%</span>
          </div>
        </div>

        {/* Per listing */}
        <div className="t-h3" style={{ marginBottom: 12 }}>Performance par bien</div>
        <div className="card" style={{ marginBottom: 22 }}>
          {LISTINGS.map((l, i) => (
            <div key={l.id} className="listrow">
              <ImgPh tone={l.tone} style={{ width: 44, height: 44, borderRadius: 10, flexShrink: 0 }}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 4 }}>{l.title}</div>
                <div style={{
                  height: 4, borderRadius: 99, background: "var(--bg-elev-3)", overflow: "hidden",
                }}>
                  <div style={{
                    width: `${l.occupancy*100}%`, height: "100%",
                    background: "var(--accent)",
                  }}/>
                </div>
                <div className="t-small" style={{ fontSize: 11, marginTop: 4 }}>
                  {Math.round(l.occupancy*100)}% occupation
                </div>
              </div>
              <div style={{ textAlign: "right" }}>
                <div className="t-mono-num" style={{ fontSize: 13, fontWeight: 700 }}>
                  {fmtFCFAk(l.revenue)}
                </div>
                <div className="t-small" style={{ fontSize: 10, color: "var(--success)" }}>
                  +{[12, 8, 18, 14][i]}%
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Projection */}
        <div className="t-h3" style={{ marginBottom: 12 }}>Projection 3 mois</div>
        <div className="card" style={{ padding: 16, marginBottom: 22 }}>
          <div className="row" style={{ justifyContent: "space-between", marginBottom: 14 }}>
            <div>
              <div className="t-eyebrow" style={{ marginBottom: 4 }}>Estimation Q1 2026</div>
              <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700 }}>{fmtFCFAk(6800000)}</div>
            </div>
            <span className="badge badge-accent">★ Haute saison</span>
          </div>

          {/* Forecast chart */}
          <svg viewBox="0 0 280 80" style={{ width: "100%", height: 80 }}>
            <defs>
              <linearGradient id="grad1" x1="0" x2="0" y1="0" y2="1">
                <stop offset="0%" stopColor="rgba(232,184,107,0.4)"/>
                <stop offset="100%" stopColor="rgba(232,184,107,0)"/>
              </linearGradient>
            </defs>
            {/* Past actual */}
            <path d="M0,60 L40,50 L80,42 L120,32 L160,22"
              stroke="var(--accent)" strokeWidth="2" fill="none"/>
            {/* Projected (dashed) */}
            <path d="M160,22 L200,18 L240,12 L280,8"
              stroke="var(--accent)" strokeWidth="2" fill="none" strokeDasharray="4 4"/>
            {/* Area under */}
            <path d="M0,60 L40,50 L80,42 L120,32 L160,22 L200,18 L240,12 L280,8 L280,80 L0,80 Z"
              fill="url(#grad1)"/>
            {/* Marker */}
            <circle cx="160" cy="22" r="4" fill="var(--accent)"/>
            <line x1="160" y1="0" x2="160" y2="80" stroke="rgba(232,184,107,0.3)" strokeDasharray="2 2"/>
          </svg>
          <div className="row" style={{ justifyContent: "space-between", marginTop: 8 }}>
            {["Sept", "Oct", "Nov", "Déc", "Jan", "Fév", "Mars"].map((m, i) => (
              <span key={m} className="t-small" style={{
                fontSize: 10, flex: 1, textAlign: "center",
                color: i === 2 ? "var(--accent)" : "var(--text-3)",
                fontWeight: i === 2 ? 700 : 400,
              }}>{m}</span>
            ))}
          </div>
        </div>

        <button className="btn btn-secondary btn-block" style={{ marginBottom: 14 }}>
          <Icon name="download" size={16}/> Exporter en PDF / CSV
        </button>

        <div style={{ height: 80 }}/>
      </div>
    </div>
  );
}

// ─── Listings management ───
function ProprietaireListings({ onBack, onOpen }) {
  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title="Mes annonces"
        right={<IconBtn><Icon name="plus" size={20}/></IconBtn>}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        <div style={{ display: "flex", gap: 8, marginBottom: 16, overflowX: "auto", scrollbarWidth: "none" }}>
          <div className="chip chip-active">Tout (4)</div>
          <div className="chip">Actifs (4)</div>
          <div className="chip">En pause (0)</div>
          <div className="chip">Brouillon (1)</div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          {LISTINGS.map(l => (
            <div key={l.id} className="card" style={{ overflow: "hidden", cursor: "pointer" }}
              onClick={() => onOpen("listing", l.id)}>
              <ImgPh tone={l.tone} style={{ width: "100%", aspectRatio: "16/9", position: "relative" }}>
                <div style={{
                  position: "absolute", top: 12, left: 12, display: "flex", gap: 6,
                }}>
                  <span className="badge badge-success">● Actif</span>
                  {l.superhost && <span className="badge badge-accent">★ Certifié</span>}
                </div>
                <div style={{
                  position: "absolute", top: 12, right: 12,
                  width: 32, height: 32, borderRadius: 99, background: "rgba(10,10,11,0.6)",
                  backdropFilter: "blur(10px)", display: "flex", alignItems: "center", justifyContent: "center",
                }}><Icon name="moreH" size={18} color="#fff"/></div>
              </ImgPh>
              <div style={{ padding: 14 }}>
                <div className="row" style={{ justifyContent: "space-between", marginBottom: 6 }}>
                  <div style={{ fontSize: 15, fontWeight: 600 }}>{l.title}</div>
                  <div className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{fmtFCFAk(l.price)}/n</div>
                </div>
                <div className="t-small" style={{ fontSize: 12, marginBottom: 12 }}>{l.area} · {l.surface} m²</div>

                <div style={{ display: "flex", gap: 10 }}>
                  <div style={{ flex: 1 }}>
                    <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>OCCUP.</div>
                    <div className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{Math.round(l.occupancy*100)}%</div>
                  </div>
                  <div style={{ flex: 1 }}>
                    <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>NOTE</div>
                    <div className="row" style={{ gap: 3 }}>
                      <Icon name="star" size={12} color="var(--accent)" strokeWidth={2.4}/>
                      <span className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{l.rating}</span>
                    </div>
                  </div>
                  <div style={{ flex: 1 }}>
                    <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>REV. MOIS</div>
                    <div className="t-mono-num" style={{ fontSize: 14, fontWeight: 700 }}>{fmtFCFAk(l.revenue)}</div>
                  </div>
                </div>
              </div>
              <div style={{ borderTop: "1px solid var(--line)", padding: 6, display: "flex", gap: 4 }}>
                <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                  <Icon name="calendar" size={14}/> Calendrier
                </button>
                <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                  <Icon name="edit" size={14}/> Modifier
                </button>
                <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                  <Icon name="chart" size={14}/> Stats
                </button>
              </div>
            </div>
          ))}

          {/* Add new */}
          <div className="card" style={{
            padding: 24, textAlign: "center", borderStyle: "dashed", borderWidth: 1.5, cursor: "pointer",
          }}>
            <div style={{
              width: 50, height: 50, borderRadius: 99, margin: "0 auto 10px",
              background: "var(--accent-soft)", display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="plus" size={22} color="var(--accent)" strokeWidth={2.4}/>
            </div>
            <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>Nouvelle annonce</div>
            <div className="t-small" style={{ fontSize: 12 }}>Mettez votre logement en location en 5 min</div>
          </div>
        </div>

        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

// ─── Single listing edit ───
function ProprietaireListingEdit({ id, onBack }) {
  const l = LISTINGS.find(x => x.id === id) || LISTINGS[0];
  const [tab, setTab] = ownUseState("info");

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title={l.title}
        sub="Annonce active"
        right={<IconBtn><Icon name="moreV" size={18}/></IconBtn>}
      />

      <div className="scroll" style={{ padding: "0 0 80px" }}>
        <ImgPh tone={l.tone} style={{ width: "100%", aspectRatio: "16/10", position: "relative" }}>
          <div style={{
            position: "absolute", bottom: 12, right: 12,
            background: "rgba(10,10,11,0.7)", backdropFilter: "blur(10px)",
            padding: "8px 12px", borderRadius: 10, fontSize: 12, fontWeight: 600,
            display: "flex", alignItems: "center", gap: 6,
          }}>
            <Icon name="image" size={14}/> 8 photos
          </div>
        </ImgPh>

        {/* Quick stats */}
        <div style={{ padding: 18 }}>
          <div className="card" style={{ padding: 16, marginBottom: 18 }}>
            <div style={{ display: "flex", gap: 16 }}>
              <div style={{ flex: 1 }}>
                <div className="t-eyebrow" style={{ marginBottom: 4 }}>Occupation</div>
                <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700 }}>{Math.round(l.occupancy*100)}%</div>
                <div style={{
                  height: 4, borderRadius: 99, background: "var(--bg-elev-3)", marginTop: 6, overflow: "hidden",
                }}>
                  <div style={{ width: `${l.occupancy*100}%`, height: "100%", background: "var(--accent)" }}/>
                </div>
              </div>
              <div style={{ width: 1, background: "var(--line)" }}/>
              <div style={{ flex: 1 }}>
                <div className="t-eyebrow" style={{ marginBottom: 4 }}>Note moy.</div>
                <div className="row" style={{ gap: 4 }}>
                  <Icon name="star" size={20} color="var(--accent)" strokeWidth={2.4}/>
                  <span className="t-mono-num" style={{ fontSize: 22, fontWeight: 700 }}>{l.rating}</span>
                </div>
                <div className="t-small" style={{ fontSize: 11, marginTop: 6 }}>{l.reviews} avis</div>
              </div>
            </div>
          </div>

          {/* Tabs */}
          <div style={{
            display: "flex", marginBottom: 16, borderBottom: "1px solid var(--line)",
          }}>
            {[
              { id: "info", l: "Infos" }, { id: "calendar", l: "Calendrier" },
              { id: "price", l: "Tarifs" }, { id: "rules", l: "Règles" },
            ].map(t => (
              <div key={t.id} onClick={() => setTab(t.id)} style={{
                flex: 1, padding: "12px 4px", textAlign: "center",
                fontSize: 13, fontWeight: 600, cursor: "pointer",
                color: tab === t.id ? "var(--accent)" : "var(--text-3)",
                borderBottom: tab === t.id ? "2px solid var(--accent)" : "2px solid transparent",
                marginBottom: -1,
              }}>{t.l}</div>
            ))}
          </div>

          {tab === "info" && (
            <>
              <FieldRow label="Titre" value={l.title}/>
              <FieldRow label="Type" value={l.type}/>
              <FieldRow label="Adresse" value={`${l.area}, ${l.city}`}/>
              <FieldRow label="Surface" value={`${l.surface} m²`}/>
              <FieldRow label="Capacité" value={`${l.beds*2} voyageurs · ${l.beds} ch · ${l.baths} sdb`}/>
              <FieldRow label="Description" value="Espace lumineux et calme au cœur de…" multi/>
            </>
          )}

          {tab === "calendar" && <CalendarView/>}

          {tab === "price" && (
            <>
              <div className="card" style={{ padding: 16, marginBottom: 14 }}>
                <div className="t-eyebrow" style={{ marginBottom: 6 }}>Tarif de base</div>
                <div className="t-mono-num" style={{ fontSize: 28, fontWeight: 700 }}>{fmtFCFA(l.price)}<span style={{ fontSize: 14, color: "var(--text-3)" }}>/nuit</span></div>
              </div>
              {[
                ["Tarif weekend (ven-sam)", l.price*1.2],
                ["Tarif haute saison", l.price*1.4],
                ["Réduction semaine (≥7 nuits)", -l.price*0.10],
                ["Réduction mois (≥28 nuits)", -l.price*0.20],
                ["Frais ménage (par séjour)", 8000],
              ].map(([k, v]) => (
                <FieldRow key={k} label={k} value={`${v < 0 ? "−" : ""}${fmtFCFA(Math.abs(v))}`}/>
              ))}
            </>
          )}

          {tab === "rules" && (
            <>
              {[
                ["Arrivée", "À partir de 14h"],
                ["Départ", "Avant 11h"],
                ["Animaux", "Non autorisés"],
                ["Fêtes", "Non autorisées"],
                ["Fumeurs", "Non autorisé"],
                ["Caution", "50 000 FCFA"],
              ].map(([k, v]) => <FieldRow key={k} label={k} value={v}/>)}
            </>
          )}
        </div>
      </div>
    </div>
  );
}

const FieldRow = ({ label, value, multi }) => (
  <div className="card" style={{
    padding: "12px 14px", marginBottom: 8,
    display: "flex", alignItems: multi ? "flex-start" : "center", gap: 12,
  }}>
    <div style={{ flex: 1 }}>
      <div className="t-eyebrow" style={{ marginBottom: 4 }}>{label}</div>
      <div style={{ fontSize: 14, fontWeight: 500, color: "var(--text)" }}>{value}</div>
    </div>
    <Icon name="edit" size={16} color="var(--text-3)"/>
  </div>
);

// Mini calendar
function CalendarView() {
  const days = ["L", "M", "M", "J", "V", "S", "D"];
  const startOffset = 5; // Nov 1 2025 is Sat
  const total = 30;
  const today = 7;
  const booked = [9, 10, 11, 14, 15, 16, 17, 22, 23, 24, 25];
  const pending = [28, 29];

  return (
    <div>
      <div className="card" style={{ padding: 16, marginBottom: 14 }}>
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 14 }}>
          <Icon name="arrowLeft" size={16}/>
          <div className="t-h3">Novembre 2025</div>
          <Icon name="arrowRight" size={16}/>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 4 }}>
          {days.map((d, i) => (
            <div key={i} className="t-small" style={{
              textAlign: "center", fontSize: 11, padding: "4px 0", fontWeight: 600,
            }}>{d}</div>
          ))}
          {Array.from({ length: startOffset }).map((_, i) => <div key={`e${i}`}/>)}
          {Array.from({ length: total }).map((_, i) => {
            const d = i + 1;
            const isBooked = booked.includes(d);
            const isPending = pending.includes(d);
            const isToday = d === today;
            return (
              <div key={d} style={{
                aspectRatio: "1/1",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 12, fontWeight: 500, borderRadius: 8,
                background: isBooked ? "var(--accent)" : isPending ? "var(--accent-soft)" : "transparent",
                color: isBooked ? "#1A1206" : isPending ? "var(--accent)" : isToday ? "var(--accent)" : "var(--text)",
                border: isToday && !isBooked ? "1.5px solid var(--accent)" : "1px solid transparent",
                fontWeight: isBooked ? 700 : 500,
              }}>{d}</div>
            );
          })}
        </div>
      </div>
      <div className="card" style={{ padding: 14 }}>
        <div className="row" style={{ gap: 16, fontSize: 12 }}>
          <div className="row" style={{ gap: 6 }}>
            <div style={{ width: 12, height: 12, borderRadius: 4, background: "var(--accent)" }}/>
            <span>Réservé</span>
          </div>
          <div className="row" style={{ gap: 6 }}>
            <div style={{ width: 12, height: 12, borderRadius: 4, background: "var(--accent-soft)", border: "1px solid rgba(232,184,107,0.4)" }}/>
            <span>En attente</span>
          </div>
          <div className="row" style={{ gap: 6 }}>
            <div style={{ width: 12, height: 12, borderRadius: 4, border: "1.5px solid var(--accent)" }}/>
            <span>Aujourd'hui</span>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ProprietaireDashboard, ProprietaireFinances, ProprietaireListings, ProprietaireListingEdit });
