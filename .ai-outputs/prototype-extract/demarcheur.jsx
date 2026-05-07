// demarcheur.jsx — Referrer / agent role for Asfar
const { useState: dmUseState } = React;

// ─── Démarcheur Dashboard ───
function DemarcheurDashboard({ onOpen }) {
  const stats = {
    pending: 3, accepted: 12, totalCommission: 540000,
    monthCommission: 228000, clients: 27,
  };

  const referrals = [
    { id: 1, client: "Rachid B.", phone: "+225 07 84 21 ••", listing: "Loft Plateau", nights: 3, comm: 13500, status: "accepted", date: "il y a 2h" },
    { id: 2, client: "Fatou S.", phone: "+221 77 12 ••", listing: "Studio Cocody", nights: 5, comm: 16000, status: "pending", date: "Hier", listingTone: "2" },
    { id: 3, client: "Hassan O.", phone: "+212 6 12 ••", listing: "Penthouse Almadies", nights: 4, comm: 48000, status: "pending", date: "Hier", listingTone: "4" },
    { id: 4, client: "Akua N.", phone: "+233 24 ••", listing: "Vue lagune", nights: 2, comm: 13600, status: "accepted", date: "Il y a 3 j", listingTone: "3" },
    { id: 5, client: "Yacouba D.", phone: "+225 05 ••", listing: "Loft Plateau", nights: 7, comm: 31500, status: "completed", date: "5 nov", listingTone: "1" },
    { id: 6, client: "Mamadou T.", phone: "+221 77 ••", listing: "Studio Cocody", nights: 1, comm: 0, status: "rejected", date: "3 nov", listingTone: "2" },
  ];

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn><Icon name="grid" size={18}/></IconBtn>}
        title="Démarcheur"
        sub="Tableau de bord"
        right={<IconBtn><Icon name="bell" size={18}/></IconBtn>}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        {/* Wallet hero */}
        <div style={{
          background: "linear-gradient(135deg, #1A2A4A 0%, #0E1626 60%, #060A14 100%)",
          border: "1px solid rgba(94,108,255,0.25)",
          borderRadius: 22, padding: 18, marginBottom: 16, position: "relative", overflow: "hidden",
        }}>
          <div style={{
            position: "absolute", top: -50, right: -30, width: 180, height: 180, borderRadius: 999,
            background: "radial-gradient(circle, rgba(94,108,255,0.18), transparent 70%)",
          }}/>
          <div className="row" style={{ justifyContent: "space-between", marginBottom: 8 }}>
            <span className="t-eyebrow" style={{ color: "#8B9AFF" }}>Mes commissions ce mois</span>
            <Icon name="wallet" size={18} color="#8B9AFF"/>
          </div>
          <div className="t-mono-num" style={{ fontSize: 32, fontWeight: 700, letterSpacing: -1, marginBottom: 6 }}>
            {fmtFCFA(stats.monthCommission)}
          </div>
          <div className="row" style={{ gap: 6, marginBottom: 16 }}>
            <span className="badge badge-success">↑ 32%</span>
            <span className="t-small" style={{ fontSize: 12 }}>vs. octobre</span>
          </div>
          <div style={{
            display: "flex", gap: 10, padding: 12, background: "rgba(255,255,255,0.05)",
            borderRadius: 12, border: "1px solid rgba(255,255,255,0.08)",
          }}>
            <div style={{ flex: 1 }}>
              <div className="t-eyebrow" style={{ fontSize: 9 }}>Cumul total</div>
              <div className="t-mono-num" style={{ fontSize: 15, fontWeight: 700 }}>{fmtFCFAk(stats.totalCommission)}</div>
            </div>
            <div style={{ width: 1, background: "rgba(255,255,255,0.1)" }}/>
            <div style={{ flex: 1 }}>
              <div className="t-eyebrow" style={{ fontSize: 9 }}>En attente</div>
              <div className="t-mono-num" style={{ fontSize: 15, fontWeight: 700, color: "var(--warn)" }}>
                {fmtFCFAk(64000)}
              </div>
            </div>
            <div style={{ width: 1, background: "rgba(255,255,255,0.1)" }}/>
            <div style={{ flex: 1 }}>
              <div className="t-eyebrow" style={{ fontSize: 9 }}>Clients</div>
              <div className="t-mono-num" style={{ fontSize: 15, fontWeight: 700 }}>{stats.clients}</div>
            </div>
          </div>
        </div>

        {/* CTA: new referral */}
        <div className="card" style={{
          padding: 14, marginBottom: 22, display: "flex", alignItems: "center", gap: 14,
          background: "linear-gradient(90deg, rgba(232,184,107,0.10), rgba(232,184,107,0.02))",
          border: "1px solid rgba(232,184,107,0.25)", cursor: "pointer",
        }} onClick={() => onOpen("new")}>
          <div style={{
            width: 44, height: 44, borderRadius: 12, background: "var(--accent)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Icon name="send" size={20} color="#1A1206" strokeWidth={2.2}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 2 }}>Envoyer un client à un propriétaire</div>
            <div className="t-small" style={{ fontSize: 12 }}>Créer une demande de réservation</div>
          </div>
          <Icon name="arrowRight" size={18}/>
        </div>

        {/* Status pills */}
        <div style={{ display: "flex", gap: 10, marginBottom: 18 }}>
          <div className="card" style={{ flex: 1, padding: 14, textAlign: "center" }}>
            <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700, color: "var(--warn)" }}>{stats.pending}</div>
            <div className="t-small" style={{ fontSize: 11, marginTop: 2 }}>En attente</div>
          </div>
          <div className="card" style={{ flex: 1, padding: 14, textAlign: "center" }}>
            <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700, color: "var(--success)" }}>{stats.accepted}</div>
            <div className="t-small" style={{ fontSize: 11, marginTop: 2 }}>Acceptées</div>
          </div>
          <div className="card" style={{ flex: 1, padding: 14, textAlign: "center" }}>
            <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700 }}>89%</div>
            <div className="t-small" style={{ fontSize: 11, marginTop: 2 }}>Taux acceptation</div>
          </div>
        </div>

        {/* Referrals */}
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 12 }}>
          <div className="t-h3">Mes clients référés</div>
          <span className="t-small" style={{ color: "var(--accent)" }} onClick={() => onOpen("referrals")}>Tout voir</span>
        </div>
        <div className="card" style={{ marginBottom: 22 }}>
          {referrals.slice(0, 5).map(r => (
            <ReferralRow key={r.id} r={r} onOpen={() => onOpen("referral", r.id)}/>
          ))}
        </div>

        {/* Top apartments to push */}
        <div className="t-h3" style={{ marginBottom: 12 }}>Logements à pousser</div>
        <div className="t-small" style={{ marginBottom: 12, fontSize: 12 }}>
          Les annonces avec le plus de disponibilités cette semaine
        </div>
        <div style={{ display: "flex", gap: 10, overflowX: "auto", scrollbarWidth: "none", marginLeft: -18, paddingLeft: 18, paddingRight: 18 }}>
          {LISTINGS.slice(0, 3).map(l => (
            <div key={l.id} className="card" style={{ width: 200, flexShrink: 0, overflow: "hidden", cursor: "pointer" }}>
              <ImgPh tone={l.tone} style={{ width: "100%", aspectRatio: "16/10" }}/>
              <div style={{ padding: 12 }}>
                <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 2 }}>{l.title}</div>
                <div className="t-small" style={{ fontSize: 11, marginBottom: 8 }}>{l.area}</div>
                <div className="row" style={{ justifyContent: "space-between", alignItems: "baseline" }}>
                  <div>
                    <div className="t-eyebrow" style={{ fontSize: 9 }}>Comm. estimée</div>
                    <div className="t-mono-num" style={{ fontSize: 14, fontWeight: 700, color: "var(--accent)" }}>
                      {fmtFCFAk(Math.round(l.price * 0.10))}
                    </div>
                  </div>
                  <button className="btn btn-primary btn-sm" style={{ padding: "6px 10px", fontSize: 11 }}>
                    Référer
                  </button>
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

const ReferralRow = ({ r, onOpen }) => {
  const sBadge = {
    pending: { c: "badge-warn", t: "● En attente" },
    accepted: { c: "badge-success", t: "✓ Acceptée" },
    completed: { c: "badge-info", t: "Terminée" },
    rejected: { c: "badge-danger", t: "Refusée" },
  }[r.status];
  return (
    <div className="listrow" onClick={onOpen} style={{ cursor: "pointer" }}>
      <ImgPh tone={r.listingTone || "1"} style={{ width: 44, height: 44, borderRadius: 10, flexShrink: 0 }}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="row" style={{ gap: 8, marginBottom: 4 }}>
          <span style={{ fontSize: 13, fontWeight: 600 }}>{r.client}</span>
          <span className={`badge ${sBadge.c}`} style={{ fontSize: 9 }}>{sBadge.t}</span>
        </div>
        <div className="t-small" style={{ fontSize: 12 }}>{r.listing} · {r.nights} nuits</div>
        <div className="t-small" style={{ fontSize: 11, color: "var(--text-3)" }}>{r.date}</div>
      </div>
      <div style={{ textAlign: "right" }}>
        <div className="t-mono-num" style={{
          fontSize: 14, fontWeight: 700,
          color: r.status === "accepted" || r.status === "completed" ? "var(--accent)" :
                 r.status === "rejected" ? "var(--text-3)" : "var(--text-2)",
        }}>
          +{fmtFCFAk(r.comm)}
        </div>
        <div className="t-small" style={{ fontSize: 10 }}>commission</div>
      </div>
    </div>
  );
};

// ─── New referral flow ───
function DemarcheurNew({ onBack, onSubmit }) {
  const [step, setStep] = dmUseState(1);
  const [pickedListing, setPickedListing] = dmUseState(null);
  const [client, setClient] = dmUseState({ name: "", phone: "" });

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={() => step > 1 ? setStep(step - 1) : onBack()}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title="Nouvelle demande"
        sub={`Étape ${step} / 3`}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        {step === 1 && (
          <>
            <div className="t-h2" style={{ marginBottom: 6 }}>Choisir un logement</div>
            <div className="t-body" style={{ marginBottom: 18 }}>
              Sélectionnez l'appartement à proposer à votre client.
            </div>
            <div className="input row" style={{ gap: 10, marginBottom: 16 }}>
              <Icon name="search" size={18} color="var(--text-3)"/>
              <span style={{ color: "var(--text-3)", fontSize: 14 }}>Rechercher par ville, propriétaire…</span>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              {LISTINGS.map(l => {
                const active = pickedListing === l.id;
                return (
                  <div key={l.id} className="card"
                    onClick={() => setPickedListing(l.id)}
                    style={{
                      padding: 12, display: "flex", gap: 12, cursor: "pointer",
                      borderColor: active ? "var(--accent)" : "var(--line)",
                      background: active ? "var(--accent-soft)" : "var(--bg-elev-1)",
                    }}>
                    <ImgPh tone={l.tone} style={{ width: 64, height: 64, borderRadius: 10, flexShrink: 0 }}/>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>{l.title}</div>
                      <div className="t-small" style={{ fontSize: 12 }}>{l.area} · {l.host.name}</div>
                      <div className="t-mono-num" style={{ fontSize: 13, fontWeight: 600, marginTop: 4 }}>
                        {fmtFCFAk(l.price)}/n · <span style={{ color: "var(--accent)" }}>+{fmtFCFAk(Math.round(l.price*0.10))} comm.</span>
                      </div>
                    </div>
                    <div style={{
                      width: 22, height: 22, borderRadius: 99, flexShrink: 0,
                      border: active ? "none" : "1.5px solid var(--text-3)",
                      background: active ? "var(--accent)" : "transparent",
                      display: "flex", alignItems: "center", justifyContent: "center",
                    }}>
                      {active && <Icon name="check" size={14} color="#1A1206" strokeWidth={2.6}/>}
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        )}

        {step === 2 && (
          <>
            <div className="t-h2" style={{ marginBottom: 6 }}>Infos client</div>
            <div className="t-body" style={{ marginBottom: 18 }}>
              Renseignez les coordonnées du client pour que le propriétaire puisse confirmer.
            </div>
            <div style={{ marginBottom: 14 }}>
              <div className="t-eyebrow" style={{ marginBottom: 8 }}>Nom du client</div>
              <input className="input" placeholder="ex. Rachid Bensalah"
                value={client.name} onChange={e => setClient({ ...client, name: e.target.value })}/>
            </div>
            <div style={{ marginBottom: 14 }}>
              <div className="t-eyebrow" style={{ marginBottom: 8 }}>Téléphone (WhatsApp)</div>
              <input className="input" placeholder="+225 07 ••• ••••"
                value={client.phone} onChange={e => setClient({ ...client, phone: e.target.value })}/>
            </div>

            <div className="t-eyebrow" style={{ marginTop: 18, marginBottom: 8 }}>Dates souhaitées</div>
            <div style={{ display: "flex", gap: 10, marginBottom: 14 }}>
              <div className="input" style={{ flex: 1 }}>
                <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>Arrivée</div>
                <div style={{ fontSize: 14, fontWeight: 600 }}>22 nov.</div>
              </div>
              <div className="input" style={{ flex: 1 }}>
                <div className="t-eyebrow" style={{ fontSize: 9, marginBottom: 2 }}>Départ</div>
                <div style={{ fontSize: 14, fontWeight: 600 }}>25 nov.</div>
              </div>
            </div>

            <div className="t-eyebrow" style={{ marginTop: 4, marginBottom: 8 }}>Note pour le propriétaire (optionnel)</div>
            <textarea className="input" placeholder="Client professionnel, paiement par OM…"
              style={{ minHeight: 80, fontFamily: "inherit", resize: "none" }}/>

            <div className="card" style={{
              padding: 14, marginTop: 22, marginBottom: 8,
              background: "var(--accent-soft)", border: "1px solid rgba(232,184,107,0.25)",
            }}>
              <div className="row" style={{ gap: 10 }}>
                <Icon name="zap" size={18} color="var(--accent)"/>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, color: "var(--accent)", marginBottom: 4 }}>
                    Commission estimée
                  </div>
                  <div className="t-mono-num" style={{ fontSize: 18, fontWeight: 700 }}>
                    +{fmtFCFA(13500)}
                  </div>
                  <div className="t-small" style={{ fontSize: 11, marginTop: 2 }}>
                    10% du séjour · versée après paiement client
                  </div>
                </div>
              </div>
            </div>
          </>
        )}

        {step === 3 && (
          <div style={{ padding: "20px 0", textAlign: "center" }}>
            <div style={{
              width: 88, height: 88, borderRadius: 99, background: "var(--accent)",
              margin: "0 auto 24px", display: "flex", alignItems: "center", justifyContent: "center",
              boxShadow: "0 0 0 14px rgba(232,184,107,0.12), 0 0 0 28px rgba(232,184,107,0.06)",
            }}>
              <Icon name="send" size={36} color="#1A1206" strokeWidth={2.2}/>
            </div>
            <div className="t-h1" style={{ marginBottom: 8 }}>Demande envoyée !</div>
            <div className="t-body" style={{ marginBottom: 24 }}>
              Aminata K. a 24 h pour confirmer la réservation. Vous serez notifié.
            </div>
            <div className="card" style={{ padding: 14, marginBottom: 14, textAlign: "left" }}>
              <div className="row" style={{ justifyContent: "space-between", marginBottom: 8 }}>
                <span className="t-small">Référence</span>
                <span className="t-mono-num" style={{ fontSize: 13, fontWeight: 600 }}>REF-D8H3K</span>
              </div>
              <div className="row" style={{ justifyContent: "space-between", marginBottom: 8 }}>
                <span className="t-small">Logement</span>
                <span style={{ fontSize: 13, fontWeight: 600 }}>Loft Plateau</span>
              </div>
              <div className="row" style={{ justifyContent: "space-between", marginBottom: 8 }}>
                <span className="t-small">Client</span>
                <span style={{ fontSize: 13, fontWeight: 600 }}>{client.name || "Rachid B."}</span>
              </div>
              <div className="row" style={{ justifyContent: "space-between" }}>
                <span className="t-small">Commission</span>
                <span className="t-mono-num" style={{ fontSize: 13, fontWeight: 700, color: "var(--accent)" }}>
                  +{fmtFCFA(13500)}
                </span>
              </div>
            </div>
            <button className="btn btn-primary btn-lg btn-block" onClick={onSubmit}>
              Voir mes demandes
            </button>
          </div>
        )}

        <div style={{ height: 100 }}/>
      </div>

      {step < 3 && (
        <div style={{
          padding: "14px 18px 30px", background: "rgba(10,10,11,0.92)",
          backdropFilter: "blur(20px)", borderTop: "1px solid var(--line)",
        }}>
          <button className="btn btn-primary btn-lg btn-block"
            onClick={() => setStep(step + 1)}
            disabled={step === 1 && !pickedListing}
            style={{ opacity: step === 1 && !pickedListing ? 0.5 : 1 }}>
            {step === 1 ? "Continuer" : "Envoyer la demande au propriétaire"}
          </button>
        </div>
      )}
    </div>
  );
}

// ─── Single referral detail ───
function DemarcheurReferralDetail({ id, onBack }) {
  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title="Détail de la demande"
        sub="REF-D8H3K"
      />
      <div className="scroll" style={{ padding: "0 18px" }}>
        {/* Status timeline */}
        <div className="card" style={{ padding: 16, marginBottom: 16 }}>
          <div className="t-eyebrow" style={{ marginBottom: 14 }}>Suivi de la demande</div>
          {[
            { t: "Demande envoyée", s: "il y a 2h", done: true },
            { t: "Vue par le propriétaire", s: "il y a 1h 15", done: true },
            { t: "Acceptée par Aminata K.", s: "il y a 28 min", done: true, hi: true },
            { t: "Paiement client", s: "En attente", done: false },
            { t: "Commission versée", s: fmtFCFA(13500), done: false },
          ].map((step, i, arr) => (
            <div key={i} className="row" style={{ alignItems: "flex-start", gap: 12, position: "relative" }}>
              <div style={{ position: "relative", flexShrink: 0 }}>
                <div style={{
                  width: 22, height: 22, borderRadius: 99,
                  background: step.done ? (step.hi ? "var(--accent)" : "var(--success)") : "var(--bg-elev-3)",
                  border: step.done ? "none" : "1.5px solid var(--line)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  {step.done && <Icon name="check" size={12} color={step.hi ? "#1A1206" : "#fff"} strokeWidth={2.8}/>}
                </div>
                {i < arr.length - 1 && (
                  <div style={{
                    position: "absolute", top: 22, left: "50%", transform: "translateX(-50%)",
                    width: 2, height: 28, background: arr[i+1].done ? "var(--success)" : "var(--bg-elev-3)",
                  }}/>
                )}
              </div>
              <div style={{ flex: 1, paddingBottom: 18 }}>
                <div style={{ fontSize: 14, fontWeight: step.done ? 600 : 500, color: step.done ? "var(--text)" : "var(--text-3)" }}>
                  {step.t}
                </div>
                <div className="t-small" style={{ fontSize: 11 }}>{step.s}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Listing */}
        <div className="card" style={{ padding: 12, marginBottom: 16, display: "flex", gap: 12 }}>
          <ImgPh tone="1" style={{ width: 70, height: 70, borderRadius: 12, flexShrink: 0 }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>Loft moderne — Plateau</div>
            <div className="t-small" style={{ fontSize: 12 }}>Plateau · Abidjan</div>
            <div className="t-small" style={{ fontSize: 12, marginTop: 4 }}>3 nuits · 22 - 25 nov.</div>
          </div>
        </div>

        {/* Client */}
        <div className="t-h3" style={{ marginBottom: 10 }}>Client</div>
        <div className="card" style={{ padding: 14, marginBottom: 16 }}>
          <div className="row" style={{ gap: 12 }}>
            <div className="avatar" style={{ width: 44, height: 44 }}>RB</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>Rachid Bensalah</div>
              <div className="t-small" style={{ fontSize: 12 }}>+225 07 84 21 ••</div>
            </div>
            <button className="btn btn-secondary btn-sm">
              <Icon name="phone" size={14}/> Appeler
            </button>
          </div>
        </div>

        {/* Owner */}
        <div className="t-h3" style={{ marginBottom: 10 }}>Propriétaire</div>
        <div className="card" style={{ padding: 14, marginBottom: 16 }}>
          <div className="row" style={{ gap: 12 }}>
            <div className="avatar" style={{ width: 44, height: 44 }}>AK</div>
            <div style={{ flex: 1 }}>
              <div className="row" style={{ gap: 6 }}>
                <span style={{ fontSize: 14, fontWeight: 600 }}>Aminata K.</span>
                <span className="badge badge-accent" style={{ fontSize: 9 }}>★ Certifiée</span>
              </div>
              <div className="t-small" style={{ fontSize: 12 }}>Répond en 1h en moy.</div>
            </div>
            <button className="btn btn-secondary btn-sm">
              <Icon name="chat" size={14}/> Message
            </button>
          </div>
        </div>

        {/* Money */}
        <div className="card" style={{
          padding: 16, marginBottom: 16,
          background: "linear-gradient(135deg, rgba(232,184,107,0.10), rgba(232,184,107,0.02))",
          border: "1px solid rgba(232,184,107,0.25)",
        }}>
          <div className="t-eyebrow" style={{ color: "var(--accent)", marginBottom: 8 }}>Votre commission</div>
          <div className="row" style={{ justifyContent: "space-between", padding: "4px 0", fontSize: 13 }}>
            <span style={{ color: "var(--text-2)" }}>Sous-total séjour</span>
            <span className="t-mono-num">{fmtFCFA(135000)}</span>
          </div>
          <div className="row" style={{ justifyContent: "space-between", padding: "4px 0", fontSize: 13 }}>
            <span style={{ color: "var(--text-2)" }}>Taux commission</span>
            <span className="t-mono-num">10%</span>
          </div>
          <div style={{ height: 1, background: "var(--line)", margin: "10px 0" }}/>
          <div className="row" style={{ justifyContent: "space-between", padding: "4px 0" }}>
            <span style={{ fontSize: 14, fontWeight: 700 }}>À recevoir</span>
            <span className="t-mono-num" style={{ fontSize: 18, fontWeight: 700, color: "var(--accent)" }}>
              {fmtFCFA(13500)}
            </span>
          </div>
        </div>

        <div style={{ height: 80 }}/>
      </div>
    </div>
  );
}

// ─── Earnings / wallet detail ───
function DemarcheurWallet({ onBack }) {
  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title="Mes commissions"
        right={<IconBtn><Icon name="download" size={16}/></IconBtn>}
      />
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div style={{
          background: "linear-gradient(135deg, #1A2A4A 0%, #0E1626 100%)",
          border: "1px solid rgba(94,108,255,0.25)",
          borderRadius: 22, padding: 20, marginBottom: 18,
        }}>
          <div className="t-eyebrow" style={{ color: "#8B9AFF", marginBottom: 6 }}>Solde disponible</div>
          <div className="t-mono-num" style={{ fontSize: 36, fontWeight: 700, letterSpacing: -1, marginBottom: 6 }}>
            {fmtFCFA(164000)}
          </div>
          <div className="t-small" style={{ fontSize: 12, marginBottom: 16 }}>
            Versement automatique tous les vendredis sur Orange Money
          </div>
          <button className="btn btn-block" style={{
            background: "rgba(255,255,255,0.1)", color: "#fff",
            border: "1px solid rgba(255,255,255,0.15)",
          }}>
            <Icon name="download" size={16}/> Retirer maintenant
          </button>
        </div>

        <div className="t-h3" style={{ marginBottom: 12 }}>Historique</div>
        <div className="card">
          {[
            { d: "8 nov.", t: "Versement OM", n: "Sem. 45", v: 75000, ok: true, kind: "out" },
            { d: "7 nov.", t: "Yacouba D. — Loft Plateau", n: "Séjour terminé", v: 31500, ok: true, kind: "in" },
            { d: "5 nov.", t: "Akua N. — Vue lagune", n: "Paiement client confirmé", v: 13600, ok: true, kind: "in" },
            { d: "1 nov.", t: "Versement OM", n: "Sem. 44", v: 53000, ok: true, kind: "out" },
            { d: "30 oct.", t: "Mariam T. — Studio Cocody", n: "Paiement client confirmé", v: 9600, ok: true, kind: "in" },
            { d: "28 oct.", t: "Demande refusée", n: "Mamadou T.", v: 0, ok: false, kind: "in" },
          ].map((tr, i) => (
            <div key={i} className="listrow">
              <div style={{
                width: 36, height: 36, borderRadius: 10, flexShrink: 0,
                background: tr.kind === "out" ? "rgba(96,165,250,0.14)" : tr.ok ? "var(--accent-soft)" : "var(--bg-elev-3)",
                color: tr.kind === "out" ? "var(--info)" : tr.ok ? "var(--accent)" : "var(--text-3)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={tr.kind === "out" ? "arrowUp" : "arrowDown"} size={16} strokeWidth={2.4}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{tr.t}</div>
                <div className="t-small" style={{ fontSize: 11 }}>{tr.d} · {tr.n}</div>
              </div>
              <div className="t-mono-num" style={{
                fontSize: 14, fontWeight: 700,
                color: tr.kind === "out" ? "var(--info)" : tr.ok ? "var(--accent)" : "var(--text-3)",
              }}>
                {tr.kind === "out" ? "−" : "+"}{fmtFCFAk(tr.v)}
              </div>
            </div>
          ))}
        </div>
        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

Object.assign(window, { DemarcheurDashboard, DemarcheurNew, DemarcheurReferralDetail, DemarcheurWallet });
