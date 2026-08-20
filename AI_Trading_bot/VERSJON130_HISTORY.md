AI BOT — FULL PLAN V1–V11

V1 — GRUNNSYSTEM
STATUS: FERDIG

Formål:
Lage grunnlaget for AI-boten og definere faste signalregler.

Oppsett:

* Separat MT5-demo
* MetaQuotes Demo
* XAUUSD
* H1
* MA50
* MA200
* RSI14

Signaler:

* BUY
* SELL
* WAIT

Regler:

* MA50 over MA200 = OPP TREND
* MA50 under MA200 = NED TREND
* Opptrend = se etter BUY
* Nedtrend = se etter SELL
* RSI over 70 = WAIT
* RSI under 30 = WAIT
* RSI mellom 30 og 70 = normalt område
* Ikke jag markedet
* Vent helst på pullback mot MA50

V1 åpner ingen handler.

---

V2 — AUTOMATISK LOGGING
STATUS: TESTING

Formål:
Samle data automatisk og finne ut om V1-reglene fungerer.

V2 skal:

* Lese XAUUSD H1
* Lese MA50
* Lese MA200
* Lese RSI14
* Beregne trend
* Gi BUY / SELL / WAIT
* Logge resultatene automatisk

V2 skal IKKE:

* Åpne trades
* Bruke ekte penger
* Endre V1
* Endre Bot 1

Data som logges:

* Tidspunkt
* Symbol
* Timeframe
* Close
* MA50
* MA200
* RSI14
* Trend
* Signal

Test:

* 48–80 timer
* Ingen endringer under testen
* Morgenbilde
* Ettermiddagsbilde
* Kveldsbilde
* CSV-logg

Etter testen:

* Antall BUY
* Antall SELL
* Antall WAIT
* Signalnøyaktighet
* Prisbevegelse etter signal
* Simulert profit/loss
* Feilsignaler
* Manglende signaler

---

V3 — SIMULERT TRADING

Formål:
Teste hva som ville skjedd dersom signalene faktisk ble handlet.

V3 skal simulere:

* Entry
* Stop Loss
* Take Profit
* Risk/Reward
* Spread
* Slippage
* Lot size
* Resultat per trade

Ingen ekte handler.

Resultater:

* Profit
* Loss
* Win rate
* Drawdown
* Expectancy
* Antall trades

---

V4 — OPTIMALISERING

Formål:
Forbedre strategien basert på data.

Teste:

* MA-perioder
* RSI-grenser
* Pullback-regler
* Stop Loss
* Take Profit
* Risk/Reward
* Tidspunkt på dagen
* Volatilitet

Mål:
Robust strategi, ikke bare best mulig historisk resultat.

Unngå overoptimalisering.

---

V5 — ROBUSTHETS- OG STRESSTEST

Teste strategien under:

* Sterk opptrend
* Sterk nedtrend
* Sideveis marked
* Høy volatilitet
* Lav volatilitet
* Raske bevegelser
* Dårlige innganger
* Lengre testperioder

Fokus:

* Maks drawdown
* Stabilitet
* Konsistente resultater

---

V6 — DEMO-EA

Formål:
Gjøre strategien til en automatisk Expert Advisor på demo.

EA-en kan:

* Overvåke markedet
* Generere signal
* Beregne Entry
* Beregne SL
* Beregne TP
* Simulere eller sende demoordre
* Logge alt

Ingen ekte penger.

---

V7 — RISIKO OG SIKKERHET

Legg inn:

* Maks risiko per trade
* Maks daglig tap
* Maks antall trades
* Spread-filter
* Trading session
* Emergency stop
* Daily kill switch
* Stopp ved manglende data
* Stopp ved forbindelsesproblemer
* Stopp ved indikatorfeil

---

V8 — LANG DEMO-TEST

Kjør boten som om den var live.

Mål:

* Månedlig avkastning
* Win rate
* Expectancy
* Drawdown
* Antall trades
* Taprekker
* Stabilitet
* Tekniske feil

Ikke endre boten hele tiden under testen.

---

V9 — SHADOW / LIVE OBSERVATION

Botten får live markedsdata, men sender ingen ordre.

Sammenlign:

* Hva boten ville gjort
* Hva markedet faktisk gjorde

Mål:
Siste virkelighetskontroll før ekte trading.

---

V10 — MINIMAL LIVE TRADING

Start med:

* Ekte konto
* Svært liten risiko
* Ingen aggressiv skalering
* Full logging

Sammenlign live-resultater med demo-resultater.

Hvis live-resultatene avviker kraftig:
STOPP og analyser.

---

V11 — PRODUKSJONSVERSJON

Mål:
Stabil produksjonsbot.

Skal inneholde:

* Automatisk analyse
* Automatisk signal
* Risikostyring
* Automatisk trading
* Logging
* Overvåkning
* Sikkerhetsmekanismer
* Kill switch
* Resultatrapportering

BOT 1 SKAL FORBLI HELT SEPARAT.

---

VIKTIG

Hver versjon må bestå testen før vi går videre.

Vi skal ikke hoppe direkte fra V2 til live trading.

AKTUELL STATUS:

V1 = FERDIG
V2 = TESTING
V3 = NESTE FASE

V2 skal nå få samle data i 48–80 timer før vi gjør endringer.
