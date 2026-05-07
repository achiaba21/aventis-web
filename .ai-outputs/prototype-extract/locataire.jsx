// locataire.jsx — Tenant role screens for Asfar
const { useState: lsUseState, useMemo: lsUseMemo } = React;

// ─────── Hero card / search header ───────
function LocataireHome({ onOpen, onTab }) {
  const [tab, setTab] = lsUseState("decouvrir");
  const [filter, setFilter] = lsUseState("Tout");
  const filters = ["Tout", "Studio", "1 chambre", "2+ chambres", "Avec piscine", "Court séjour"];

  return (
    <div className="screen">
      {/* Top */}
      <div style={{ paddingTop: 56, padding: "56px 18px 0" }}>
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 14 }}>
          <div>
            <div className="t-small" style={{ color: "var(--text-3)" }}>Bonsoir,</div>
            <div className="t-h2">Aïcha 👋</div>
          </div>
          <div className="row" style={{ gap: 8 }}>
            <IconBtn><Icon name="bell" size={18}/></IconBtn>
            <div className="avatar" style={{ width: 36, height: 36, fontSize: 13 }}>AC</div>
          </div>
        </div>

        {/* Search */}
        <div onClick={() => onOpen("search")} className="card" style={{
          padding: "12px 14px", display: "flex", alignItems: "center", gap: 12,
          background: "var(--bg-elev-2)", cursor: "pointer",
        }}>
          <Icon name="search" size={20} color="var(--text-2)"/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 600 }}>Où voulez-vous séjourner ?</div>
            <div className="t-small" style={{ color: "var(--text-3)", fontSize: 12 }}>Abidjan · 12-15 nov · 2 voyageurs</div>
          </div>
          <div style={{
            width: 38, height: 38, borderRadius: 12, background: "var(--accent)",
            display: "flex", alignItems: "center", justifyContent: "center", color: "#1A1206",
          }}>
            <Icon name="sliders" size={18} color="#1A1206" strokeWidth={2.2}/>
          </div>
        </div>
      </div>

      <div className="scroll" style={{ paddingTop: 18 }}>
        {/* Filter chips */}
        <div style={{
          display: "flex", gap: 8, padding: "0 18px 4px", overflowX: "auto",
          scrollbarWidth: "none",
        }}>
          {filters.map(f => (
            <div key={f} className={`chip ${filter === f ? "chip-active" : ""}`}
              onClick={() => setFilter(f)}>{f}</div>
          ))}
        </div>

        {/* Featured */}
        <div className="section-h">
          <div className="t-h3">À la une</div>
          <span className="t-small" style={{ color: "var(--accent)" }}>Voir tout</span>
        </div>
        <div style={{ display: "flex", gap: 12, overflowX: "auto", padding: "0 18px 8px", scrollbarWidth: "none" }}>
          {LISTINGS.slice(0, 3).map(l => (
            <div key={l.id} onClick={() => onOpen("detail", l.id)}
              style={{ width: 220, flexShrink: 0, cursor: "pointer" }}>
              <ImgPh tone={l.tone} style={{
                width: "100%", aspectRatio: "4/5", borderRadius: 18,
                position: "relative", overflow: "hidden",
              }}>
                <div style={{
                  position: "absolute", top: 10, left: 10,
                  background: "rgba(10,10,11,0.7)", backdropFilter: "blur(10px)",
                  padding: "5px 9px", borderRadius: 99, fontSize: 11, fontWeight: 600,
                  display: "flex", alignItems: "center", gap: 4,
                }}>
                  <Icon name="star" size={11} color="var(--accent)" strokeWidth={2.4}/>
                  <span>{l.rating}</span>
                </div>
                <div style={{
                  position: "absolute", top: 10, right: 10,
                  width: 32, height: 32, borderRadius: 99, background: "rgba(10,10,11,0.5)",
                  backdropFilter: "blur(10px)", display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  <Icon name="heart" size={16} color="#fff"/>
                </div>
                {l.superhost && (
                  <div style={{
                    position: "absolute", bottom: 10, left: 10,
                    background: "var(--accent)", color: "#1A1206",
                    padding: "4px 8px", borderRadius: 6, fontSize: 10, fontWeight: 700,
                    letterSpacing: 0.3, textTransform: "uppercase",
                  }}>★ Hôte certifié</div>
                )}
              </ImgPh>
              <div style={{ padding: "10px 4px 4px" }}>
                <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 2 }}>{l.title}</div>
                <div className="t-small" style={{ fontSize: 12 }}>{l.area} · {l.city}</div>
                <div style={{ marginTop: 6, fontSize: 14 }}>
                  <span style={{ fontWeight: 700 }} className="t-mono-num">{fmtFCFAk(l.price)}</span>
                  <span style={{ color: "var(--text-3)", fontSize: 12 }}> / nuit</span>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Map teaser */}
        <div className="section-h">
          <div className="t-h3">Près de vous</div>
          <span className="t-small" style={{ color: "var(--accent)" }}>Voir carte</span>
        </div>
        <div style={{ padding: "0 18px" }}>
          <div className="map-ph" style={{
            height: 160, borderRadius: 18, position: "relative",
            border: "1px solid var(--line)",
          }}>
            {/* Pins */}
            {[
              { x: 30, y: 35, label: "45k" },
              { x: 60, y: 55, label: "32k" },
              { x: 75, y: 30, label: "68k" },
              { x: 45, y: 70, label: "55k" },
            ].map((p, i) => (
              <div key={i} style={{
                position: "absolute", left: `${p.x}%`, top: `${p.y}%`,
                transform: "translate(-50%,-50%)",
                background: i === 1 ? "var(--accent)" : "var(--bg-elev-2)",
                color: i === 1 ? "#1A1206" : "var(--text)",
                padding: "5px 10px", borderRadius: 99, fontSize: 11, fontWeight: 700,
                border: "1px solid var(--line)",
                boxShadow: "0 4px 12px rgba(0,0,0,0.4)",
              }}>{p.label}</div>
            ))}
            <div style={{
              position: "absolute", bottom: 12, right: 12,
              padding: "8px 12px", borderRadius: 10, background: "rgba(10,10,11,0.85)",
              backdropFilter: "blur(10px)", fontSize: 12, fontWeight: 600,
              display: "flex", alignItems: "center", gap: 6, border: "1px solid var(--line)",
            }}>
              <Icon name="map" size={14}/> Voir 124 logements
            </div>
          </div>
        </div>

        {/* List */}
        <div className="section-h">
          <div className="t-h3">Recommandés pour vous</div>
        </div>
        <div style={{ padding: "0 18px 24px", display: "flex", flexDirection: "column", gap: 14 }}>
          {LISTINGS.map(l => (
            <ListingCard key={l.id} l={l} onClick={() => onOpen("detail", l.id)}/>
          ))}
        </div>

        <div style={{ height: 100 }}/>
      </div>
    </div>
  );
}

// ─────── Listing card (full-width) ───────
function ListingCard({ l, onClick }) {
  return (
    <div onClick={onClick} className="card" style={{ overflow: "hidden", cursor: "pointer" }}>
      <ImgPh tone={l.tone} style={{
        width: "100%", aspectRatio: "16/10", position: "relative",
      }}>
        <div style={{
          position: "absolute", top: 12, right: 12,
          width: 34, height: 34, borderRadius: 99, background: "rgba(10,10,11,0.55)",
          backdropFilter: "blur(10px)", display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <Icon name="heart" size={18} color="#fff"/>
        </div>
        {l.superhost && (
          <div style={{
            position: "absolute", top: 12, left: 12,
            background: "rgba(10,10,11,0.7)", backdropFilter: "blur(10px)",
            color: "var(--accent)", padding: "5px 10px", borderRadius: 99,
            fontSize: 11, fontWeight: 700, letterSpacing: 0.3,
          }}>★ Hôte certifié</div>
        )}
        {/* Photo dots */}
        <div style={{
          position: "absolute", bottom: 12, left: "50%", transform: "translateX(-50%)",
          display: "flex", gap: 4,
        }}>
          {[0,1,2,3].map(i => (
            <div key={i} style={{
              width: 5, height: 5, borderRadius: 99,
              background: i === 0 ? "#fff" : "rgba(255,255,255,0.4)",
            }}/>
          ))}
        </div>
      </ImgPh>
      <div style={{ padding: 14 }}>
        <div className="row" style={{ justifyContent: "space-between", marginBottom: 4 }}>
          <div className="t-h3" style={{ fontSize: 15 }}>{l.title}</div>
          <div className="row" style={{ gap: 4 }}>
            <Icon name="star" size={13} color="var(--accent)" strokeWidth={2.4}/>
            <span style={{ fontSize: 13, fontWeight: 600 }}>{l.rating}</span>
            <span className="t-small" style={{ fontSize: 12, color: "var(--text-3)" }}>({l.reviews})</span>
          </div>
        </div>
        <div className="t-small" style={{ marginBottom: 8 }}>{l.area} · {l.city} · {l.surface} m²</div>
        <div className="row" style={{ gap: 12, color: "var(--text-3)", fontSize: 12, marginBottom: 10 }}>
          <span className="row" style={{ gap: 4 }}><Icon name="bed" size={14}/>{l.beds} ch.</span>
          <span className="row" style={{ gap: 4 }}><Icon name="bath" size={14}/>{l.baths} sdb.</span>
          <span className="row" style={{ gap: 4 }}><Icon name="wifi" size={14}/>WiFi</span>
        </div>
        <div className="row" style={{ justifyContent: "space-between", alignItems: "baseline" }}>
          <div>
            <span style={{ fontSize: 17, fontWeight: 700 }} className="t-mono-num">{fmtFCFAk(l.price)}</span>
            <span style={{ color: "var(--text-3)", fontSize: 13 }}> / nuit</span>
          </div>
          <span className="t-small" style={{ fontSize: 12 }}>3 nuits · {fmtFCFAk(l.price*3)}</span>
        </div>
      </div>
    </div>
  );
}

// ─────── Detail screen ───────
function LocataireDetail({ id, onBack, onReserve }) {
  const l = LISTINGS.find(x => x.id === id) || LISTINGS[0];
  const [photo, setPhoto] = lsUseState(0);

  return (
    <div className="screen">
      {/* Floating top buttons */}
      <div style={{
        position: "absolute", top: 56, left: 0, right: 0, zIndex: 10,
        display: "flex", justifyContent: "space-between", padding: "10px 18px",
      }}>
        <IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>
        <div style={{ display: "flex", gap: 8 }}>
          <IconBtn><Icon name="share" size={16}/></IconBtn>
          <IconBtn><Icon name="heart" size={18}/></IconBtn>
        </div>
      </div>

      <div className="scroll" style={{ paddingTop: 0 }}>
        {/* Hero gallery */}
        <ImgPh tone={l.tone} style={{
          width: "100%", aspectRatio: "1/1", position: "relative",
        }}>
          {/* Photo indicators */}
          <div style={{
            position: "absolute", bottom: 18, left: "50%", transform: "translateX(-50%)",
            display: "flex", gap: 5,
          }}>
            {[0,1,2,3,4].map(i => (
              <div key={i} onClick={() => setPhoto(i)} style={{
                width: i === photo ? 24 : 6, height: 6, borderRadius: 99,
                background: i === photo ? "#fff" : "rgba(255,255,255,0.5)",
                transition: "width .25s",
              }}/>
            ))}
          </div>
          <div style={{
            position: "absolute", bottom: 18, right: 18,
            background: "rgba(10,10,11,0.7)", backdropFilter: "blur(10px)",
            padding: "6px 10px", borderRadius: 8, fontSize: 12, fontWeight: 600,
          }}>{photo + 1} / 5</div>
        </ImgPh>

        <div style={{ padding: "20px 18px 0" }}>
          {/* Title block */}
          <div className="t-eyebrow" style={{ color: "var(--accent)", marginBottom: 6 }}>
            {l.type}
          </div>
          <div className="t-h1" style={{ marginBottom: 8 }}>{l.title}</div>
          <div className="row" style={{ gap: 12, marginBottom: 14, flexWrap: "wrap" }}>
            <div className="row" style={{ gap: 4 }}>
              <Icon name="star" size={15} color="var(--accent)" strokeWidth={2.4}/>
              <span style={{ fontSize: 14, fontWeight: 600 }}>{l.rating}</span>
              <span className="t-small">({l.reviews} avis)</span>
            </div>
            <div className="row" style={{ gap: 4 }}>
              <Icon name="pin" size={14} color="var(--text-2)"/>
              <span className="t-small">{l.area}, {l.city}</span>
            </div>
          </div>

          {/* Quick specs */}
          <div className="card" style={{
            display: "flex", padding: "14px 4px",
            background: "var(--bg-elev-1)", marginBottom: 18,
          }}>
            {[
              { i: "bed", v: `${l.beds}`, l: "chambre" + (l.beds > 1 ? "s" : "") },
              { i: "bath", v: `${l.baths}`, l: "salle" + (l.baths > 1 ? "s" : "") + " de bain" },
              { i: "grid", v: `${l.surface}`, l: "m²" },
              { i: "users", v: `${l.beds * 2}`, l: "voyageurs" },
            ].map((s, i) => (
              <div key={i} style={{
                flex: 1, textAlign: "center",
                borderRight: i < 3 ? "1px solid var(--line)" : "none",
                padding: "0 8px",
              }}>
                <Icon name={s.i} size={20} color="var(--accent)"/>
                <div style={{ fontSize: 16, fontWeight: 700, marginTop: 6 }} className="t-mono-num">{s.v}</div>
                <div className="t-small" style={{ fontSize: 11 }}>{s.l}</div>
              </div>
            ))}
          </div>

          {/* Host */}
          <div className="card" style={{ padding: 14, marginBottom: 18 }}>
            <div className="row" style={{ gap: 12 }}>
              <div className="avatar" style={{ width: 48, height: 48 }}>AK</div>
              <div style={{ flex: 1 }}>
                <div className="row" style={{ gap: 6, alignItems: "center" }}>
                  <span style={{ fontSize: 15, fontWeight: 600 }}>{l.host.name}</span>
                  {l.superhost && (
                    <span className="badge badge-accent">★ Certifié</span>
                  )}
                </div>
                <div className="t-small" style={{ fontSize: 12 }}>Hôte depuis {l.host.since} · répond en 1 h</div>
              </div>
              <button className="btn btn-secondary btn-sm">
                <Icon name="chat" size={14}/> Contacter
              </button>
            </div>
          </div>

          {/* Description */}
          <div className="t-h3" style={{ marginBottom: 8 }}>À propos du logement</div>
          <div className="t-body" style={{ marginBottom: 18 }}>
            Espace lumineux et calme au cœur de {l.area}. Décoration soignée, équipements modernes,
            balcon avec vue dégagée. Idéal pour séjours d'affaires ou tourisme. Quartier sécurisé,
            commerces et restaurants à 5 min à pied.
          </div>

          {/* Amenities */}
          <div className="t-h3" style={{ marginBottom: 12 }}>Équipements</div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 8 }}>
            {l.amenities.map((a, i) => (
              <div key={a} className="row" style={{ gap: 10, padding: "10px 0" }}>
                <Icon name={["wifi","park","shield","bath","coffee"][i % 5]} size={18} color="var(--accent)"/>
                <span style={{ fontSize: 14 }}>{a}</span>
              </div>
            ))}
          </div>
          <div style={{ marginBottom: 18 }}>
            <span className="t-small" style={{ color: "var(--accent)", fontWeight: 600 }}>
              Voir les 18 équipements →
            </span>
          </div>

          {/* Map */}
          <div className="t-h3" style={{ marginBottom: 12 }}>Emplacement</div>
          <div className="map-ph" style={{
            height: 180, borderRadius: 16, position: "relative",
            border: "1px solid var(--line)", marginBottom: 18,
          }}>
            <div style={{
              position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)",
              width: 44, height: 44, borderRadius: 99, background: "var(--accent)",
              display: "flex", alignItems: "center", justifyContent: "center",
              boxShadow: "0 0 0 8px rgba(232,184,107,0.18), 0 0 0 16px rgba(232,184,107,0.08)",
            }}>
              <Icon name="pin" size={22} color="#1A1206" strokeWidth={2.2}/>
            </div>
            <div style={{
              position: "absolute", bottom: 12, left: 12, right: 12,
              padding: "10px 12px", borderRadius: 10, background: "rgba(10,10,11,0.85)",
              backdropFilter: "blur(10px)", fontSize: 12, border: "1px solid var(--line)",
            }}>
              <div style={{ fontWeight: 600, marginBottom: 2 }}>{l.area}, {l.city}</div>
              <div style={{ color: "var(--text-3)" }}>L'adresse exacte sera communiquée après réservation</div>
            </div>
          </div>

          {/* Reviews */}
          <div className="row" style={{ justifyContent: "space-between", alignItems: "baseline", marginBottom: 12 }}>
            <div className="t-h3">
              <Icon name="star" size={16} color="var(--accent)" strokeWidth={2.4}
                style={{ display: "inline", verticalAlign: "middle", marginRight: 6 }}/>
              {l.rating} · {l.reviews} avis
            </div>
            <span className="t-small" style={{ color: "var(--accent)" }}>Tout voir</span>
          </div>
          <div style={{ display: "flex", gap: 10, overflowX: "auto", paddingBottom: 8, marginBottom: 18, marginLeft: -18, paddingLeft: 18 }}>
            {[
              { name: "Yacine D.", text: "Logement impeccable, hôte très réactif. Je recommande !", date: "Oct 2025", avi: "YD" },
              { name: "Mariam T.", text: "Quartier calme, lit confortable. Parfait pour 3 nuits.", date: "Sept 2025", avi: "MT" },
              { name: "Kofi A.", text: "Excellent rapport qualité-prix. À refaire.", date: "Sept 2025", avi: "KA" },
            ].map(r => (
              <div key={r.name} className="card" style={{
                width: 240, flexShrink: 0, padding: 14,
              }}>
                <div className="row" style={{ gap: 4, marginBottom: 8 }}>
                  {[0,1,2,3,4].map(i => (
                    <Icon key={i} name="star" size={11} color="var(--accent)" strokeWidth={2.4}/>
                  ))}
                </div>
                <div style={{ fontSize: 13, lineHeight: 1.5, marginBottom: 12 }}>"{r.text}"</div>
                <div className="row" style={{ gap: 8 }}>
                  <div className="avatar" style={{ width: 28, height: 28, fontSize: 11 }}>{r.avi}</div>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 600 }}>{r.name}</div>
                    <div className="t-small" style={{ fontSize: 11 }}>{r.date}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div style={{ height: 110 }}/>
        </div>
      </div>

      {/* Bottom bar */}
      <div style={{
        padding: "14px 18px 30px", background: "rgba(10,10,11,0.92)",
        backdropFilter: "blur(20px)", borderTop: "1px solid var(--line)",
        display: "flex", gap: 14, alignItems: "center",
      }}>
        <div>
          <div style={{ fontSize: 18, fontWeight: 700 }} className="t-mono-num">{fmtFCFAk(l.price)}</div>
          <div className="t-small" style={{ fontSize: 11 }}>par nuit · 12-15 nov</div>
        </div>
        <button className="btn btn-primary" style={{ flex: 1 }} onClick={() => onReserve(l.id)}>
          Réserver
        </button>
      </div>
    </div>
  );
}

// ─────── Reservation flow ───────
function LocataireReserve({ id, onBack, onConfirm }) {
  const l = LISTINGS.find(x => x.id === id) || LISTINGS[0];
  const [step, setStep] = lsUseState(1);
  const [pay, setPay] = lsUseState("om");

  const nights = 3;
  const subtotal = l.price * nights;
  const fees = Math.round(subtotal * 0.08);
  const total = subtotal + fees;

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="arrowLeft" size={18}/></IconBtn>}
        title={step === 1 ? "Confirmer la réservation" : step === 2 ? "Paiement" : "Confirmation"}
        sub={`Étape ${step} / 3`}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        {/* Listing summary */}
        <div className="card" style={{ padding: 12, marginBottom: 16, display: "flex", gap: 12 }}>
          <ImgPh tone={l.tone} style={{ width: 80, height: 80, borderRadius: 12, flexShrink: 0 }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="t-h3" style={{ fontSize: 14, marginBottom: 2 }}>{l.title}</div>
            <div className="t-small" style={{ fontSize: 12 }}>{l.area} · {l.city}</div>
            <div className="row" style={{ gap: 4, marginTop: 6 }}>
              <Icon name="star" size={12} color="var(--accent)" strokeWidth={2.4}/>
              <span style={{ fontSize: 12, fontWeight: 600 }}>{l.rating}</span>
              <span className="t-small" style={{ fontSize: 11 }}>({l.reviews})</span>
            </div>
          </div>
        </div>

        {step === 1 && (
          <>
            <div className="t-h3" style={{ marginBottom: 12 }}>Votre séjour</div>
            <div className="card" style={{ marginBottom: 16 }}>
              <div className="listrow" style={{ justifyContent: "space-between" }}>
                <div>
                  <div className="t-eyebrow" style={{ marginBottom: 2 }}>Dates</div>
                  <div style={{ fontSize: 14 }}>12 - 15 nov. 2025</div>
                </div>
                <Icon name="edit" size={16} color="var(--text-3)"/>
              </div>
              <div className="listrow" style={{ justifyContent: "space-between" }}>
                <div>
                  <div className="t-eyebrow" style={{ marginBottom: 2 }}>Voyageurs</div>
                  <div style={{ fontSize: 14 }}>2 adultes</div>
                </div>
                <Icon name="edit" size={16} color="var(--text-3)"/>
              </div>
            </div>

            <div className="t-h3" style={{ marginBottom: 12 }}>Détail du prix</div>
            <div className="card" style={{ padding: 14, marginBottom: 16 }}>
              {[
                [`${fmtFCFAk(l.price)} × ${nights} nuits`, fmtFCFA(subtotal)],
                ["Frais de service", fmtFCFA(fees)],
              ].map(([k, v]) => (
                <div key={k} className="row" style={{ justifyContent: "space-between", padding: "8px 0", fontSize: 14 }}>
                  <span style={{ color: "var(--text-2)" }}>{k}</span>
                  <span className="t-mono-num">{v}</span>
                </div>
              ))}
              <div style={{ height: 1, background: "var(--line)", margin: "10px 0" }}/>
              <div className="row" style={{ justifyContent: "space-between", padding: "4px 0" }}>
                <span style={{ fontSize: 15, fontWeight: 700 }}>Total</span>
                <span className="t-mono-num" style={{ fontSize: 17, fontWeight: 700 }}>{fmtFCFA(total)}</span>
              </div>
            </div>

            <div className="card" style={{
              padding: 14, marginBottom: 18, background: "var(--accent-soft)",
              border: "1px solid rgba(232,184,107,0.25)",
            }}>
              <div className="row" style={{ gap: 10, alignItems: "flex-start" }}>
                <Icon name="shield" size={18} color="var(--accent)"/>
                <div>
                  <div style={{ fontSize: 13, fontWeight: 600, color: "var(--accent)", marginBottom: 4 }}>
                    Annulation flexible
                  </div>
                  <div className="t-small" style={{ fontSize: 12, color: "var(--text-2)" }}>
                    Annulez gratuitement jusqu'au 10 nov. à 14 h. Après, remboursement partiel.
                  </div>
                </div>
              </div>
            </div>

            <button className="btn btn-primary btn-lg btn-block" onClick={() => setStep(2)}>
              Continuer vers le paiement
            </button>
            <div style={{ height: 24 }}/>
          </>
        )}

        {step === 2 && (
          <>
            <div className="t-h3" style={{ marginBottom: 12 }}>Méthode de paiement</div>
            <div className="card" style={{ marginBottom: 16 }}>
              {[
                { id: "om", name: "Orange Money", sub: "•••• 8742", color: "#FF6B00" },
                { id: "wave", name: "Wave", sub: "+225 07 ••• 4521", color: "#1DC4D5" },
                { id: "mtn", name: "MTN MoMo", sub: "•••• 2189", color: "#FFCC00" },
                { id: "card", name: "Carte bancaire", sub: "Ajouter une carte", color: "#5E6CFF" },
              ].map((p, i) => (
                <div key={p.id} className="listrow"
                  onClick={() => setPay(p.id)}
                  style={{ cursor: "pointer" }}>
                  <div style={{
                    width: 38, height: 38, borderRadius: 10,
                    background: p.color + "22", display: "flex", alignItems: "center", justifyContent: "center",
                    color: p.color, fontWeight: 700, fontSize: 13,
                  }}>{p.name.split(" ").map(w => w[0]).slice(0,2).join("")}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14, fontWeight: 600 }}>{p.name}</div>
                    <div className="t-small" style={{ fontSize: 12 }}>{p.sub}</div>
                  </div>
                  <div style={{
                    width: 20, height: 20, borderRadius: 99,
                    border: pay === p.id ? "6px solid var(--accent)" : "1.5px solid var(--text-3)",
                    background: pay === p.id ? "var(--bg)" : "transparent",
                  }}/>
                </div>
              ))}
            </div>

            <div className="card" style={{ padding: 14, marginBottom: 16 }}>
              <div className="row" style={{ justifyContent: "space-between", padding: "4px 0" }}>
                <span style={{ fontSize: 15, fontWeight: 600 }}>Total à payer</span>
                <span className="t-mono-num" style={{ fontSize: 19, fontWeight: 700, color: "var(--accent)" }}>{fmtFCFA(total)}</span>
              </div>
            </div>

            <button className="btn btn-primary btn-lg btn-block" onClick={() => setStep(3)}>
              Payer {fmtFCFAk(total)}
            </button>
            <div style={{ height: 24 }}/>
          </>
        )}

        {step === 3 && (
          <div style={{ padding: "20px 0", textAlign: "center" }}>
            <div style={{
              width: 88, height: 88, borderRadius: 99, background: "var(--accent)",
              margin: "0 auto 24px", display: "flex", alignItems: "center", justifyContent: "center",
              boxShadow: "0 0 0 14px rgba(232,184,107,0.12), 0 0 0 28px rgba(232,184,107,0.06)",
            }}>
              <Icon name="check" size={42} color="#1A1206" strokeWidth={2.6}/>
            </div>
            <div className="t-h1" style={{ marginBottom: 8 }}>Réservation confirmée !</div>
            <div className="t-body" style={{ marginBottom: 24 }}>
              Votre paiement a été reçu. Aminata a été prévenue.
            </div>

            <div className="card" style={{ padding: 16, marginBottom: 16, textAlign: "left" }}>
              <div className="t-eyebrow" style={{ marginBottom: 8 }}>Code de réservation</div>
              <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700, letterSpacing: 2 }}>ASF-7K2N9</div>
            </div>

            <div className="card" style={{ padding: 16, marginBottom: 24, textAlign: "left" }}>
              <div className="row" style={{ justifyContent: "space-between", marginBottom: 10 }}>
                <span className="t-small">Logement</span>
                <span style={{ fontSize: 13, fontWeight: 600 }}>{l.title}</span>
              </div>
              <div className="row" style={{ justifyContent: "space-between", marginBottom: 10 }}>
                <span className="t-small">Dates</span>
                <span style={{ fontSize: 13, fontWeight: 600 }}>12 - 15 nov</span>
              </div>
              <div className="row" style={{ justifyContent: "space-between" }}>
                <span className="t-small">Total payé</span>
                <span className="t-mono-num" style={{ fontSize: 13, fontWeight: 700 }}>{fmtFCFA(total)}</span>
              </div>
            </div>

            <button className="btn btn-primary btn-lg btn-block" onClick={onConfirm}>
              Voir mes réservations
            </button>
            <button className="btn btn-ghost btn-block" style={{ marginTop: 8 }} onClick={onBack}>
              Retour à l'accueil
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// Search filter sheet
function LocataireSearch({ onBack, onApply }) {
  const [price, setPrice] = lsUseState(60000);
  const [beds, setBeds] = lsUseState(1);

  return (
    <div className="screen">
      <TopNav
        left={<IconBtn onClick={onBack}><Icon name="close" size={18}/></IconBtn>}
        title="Filtres"
        right={<span className="t-small" style={{ color: "var(--accent)", fontWeight: 600 }}>Effacer</span>}
      />

      <div className="scroll" style={{ padding: "0 18px" }}>
        <div className="t-h3" style={{ marginBottom: 12 }}>Destination</div>
        <div className="input row" style={{ gap: 10 }}>
          <Icon name="search" size={18} color="var(--text-3)"/>
          <span style={{ fontSize: 15 }}>Abidjan, Côte d'Ivoire</span>
        </div>

        <div className="t-h3" style={{ marginTop: 24, marginBottom: 12 }}>Dates</div>
        <div style={{ display: "flex", gap: 10 }}>
          <div className="input" style={{ flex: 1 }}>
            <div className="t-eyebrow" style={{ marginBottom: 2 }}>Arrivée</div>
            <div style={{ fontSize: 15, fontWeight: 600 }}>12 nov.</div>
          </div>
          <div className="input" style={{ flex: 1 }}>
            <div className="t-eyebrow" style={{ marginBottom: 2 }}>Départ</div>
            <div style={{ fontSize: 15, fontWeight: 600 }}>15 nov.</div>
          </div>
        </div>

        <div className="t-h3" style={{ marginTop: 24, marginBottom: 4 }}>Budget par nuit</div>
        <div className="t-mono-num" style={{ fontSize: 22, fontWeight: 700, marginBottom: 12 }}>
          jusqu'à {fmtFCFAk(price)}
        </div>
        <div style={{ position: "relative", padding: "12px 0" }}>
          <div style={{
            position: "absolute", left: 0, right: 0, top: "50%",
            height: 4, borderRadius: 99, background: "var(--bg-elev-3)",
          }}/>
          <div style={{
            position: "absolute", left: 0, top: "50%", transform: "translateY(-50%)",
            height: 4, borderRadius: 99, background: "var(--accent)",
            width: `${(price/150000)*100}%`,
          }}/>
          <input type="range" min="10000" max="150000" step="5000"
            value={price} onChange={e => setPrice(+e.target.value)}
            style={{
              position: "relative", width: "100%", appearance: "none",
              background: "transparent", height: 24, margin: 0, padding: 0,
            }}
            className="asfar-range"/>
          <div className="row" style={{ justifyContent: "space-between", marginTop: 8 }}>
            <span className="t-small" style={{ fontSize: 11 }}>10k</span>
            <span className="t-small" style={{ fontSize: 11 }}>150k</span>
          </div>
        </div>

        <div className="t-h3" style={{ marginTop: 16, marginBottom: 12 }}>Chambres</div>
        <div style={{ display: "flex", gap: 8 }}>
          {["Studio", "1", "2", "3", "4+"].map((b, i) => (
            <div key={b} className={`chip ${beds === i ? "chip-active" : ""}`}
              onClick={() => setBeds(i)}
              style={{ flex: 1, justifyContent: "center" }}>{b}</div>
          ))}
        </div>

        <div className="t-h3" style={{ marginTop: 24, marginBottom: 12 }}>Équipements indispensables</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          {[
            { i: "wifi", l: "WiFi" }, { i: "park", l: "Parking" },
            { i: "shield", l: "Sécurité" }, { i: "coffee", l: "Cuisine" },
          ].map((a, i) => (
            <div key={a.l} className={`chip ${i < 2 ? "chip-active" : ""}`}
              style={{ justifyContent: "flex-start", padding: 14, gap: 10, borderRadius: 14 }}>
              <Icon name={a.i} size={18}/>
              <span>{a.l}</span>
            </div>
          ))}
        </div>

        <div style={{ height: 100 }}/>
      </div>

      <div style={{
        padding: "14px 18px 30px", background: "rgba(10,10,11,0.92)",
        backdropFilter: "blur(20px)", borderTop: "1px solid var(--line)",
      }}>
        <button className="btn btn-primary btn-lg btn-block" onClick={onApply}>
          Voir 124 logements
        </button>
      </div>
    </div>
  );
}

// Reservations / trips list
function LocataireTrips() {
  const trips = [
    { l: LISTINGS[0], status: "À venir", dates: "12 - 15 nov 2025", code: "ASF-7K2N9" },
    { l: LISTINGS[2], status: "Terminé", dates: "3 - 6 oct 2025", code: "ASF-3T8M1" },
    { l: LISTINGS[1], status: "Terminé", dates: "18 - 20 sept 2025", code: "ASF-9P2X4" },
  ];
  return (
    <div className="screen">
      <TopNav title="Mes voyages"/>
      <div className="scroll" style={{ padding: "0 18px" }}>
        <div style={{ display: "flex", gap: 8, marginBottom: 18 }}>
          <div className="chip chip-active">À venir (1)</div>
          <div className="chip">Passés (2)</div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          {trips.map((t, i) => (
            <div key={i} className="card" style={{ overflow: "hidden" }}>
              <div style={{ display: "flex" }}>
                <ImgPh tone={t.l.tone} style={{ width: 110, height: 110, flexShrink: 0 }}/>
                <div style={{ padding: 14, flex: 1 }}>
                  <div className="row" style={{ marginBottom: 6 }}>
                    <span className={`badge ${t.status === "À venir" ? "badge-success" : "badge-neutral"}`}>
                      {t.status}
                    </span>
                  </div>
                  <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>{t.l.title}</div>
                  <div className="t-small" style={{ fontSize: 12, marginBottom: 4 }}>{t.dates}</div>
                  <div className="t-mono-num t-small" style={{ fontSize: 11 }}>{t.code}</div>
                </div>
              </div>
              {t.status === "À venir" && (
                <div style={{ borderTop: "1px solid var(--line)", padding: 8, display: "flex", gap: 4 }}>
                  <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                    <Icon name="chat" size={14}/> Hôte
                  </button>
                  <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                    <Icon name="map" size={14}/> Itinéraire
                  </button>
                  <button className="btn btn-ghost btn-sm" style={{ flex: 1 }}>
                    <Icon name="paper" size={14}/> Reçu
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
        <div style={{ height: 80 }}/>
      </div>
    </div>
  );
}

Object.assign(window, { LocataireHome, LocataireDetail, LocataireReserve, LocataireSearch, LocataireTrips, ListingCard });
