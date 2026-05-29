import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import professorImg from "@/assets/professor.webp";
import bgImg from "@/assets/bg-squeeze-page.webp";

const EMBED_SCRIPT_SRC = "https://agwebinar.com.br/embed.js";
const FORM_SLUG =
  "como-usar-intelig-ncia-artificial-para-transformar-o-instagram-da-sua-assist-ncia-t-cnica-em-um-canal-de-clientes-1779800811194";
const FORM_CONTAINER_ID = `agform-${FORM_SLUG}`;



export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Webinário Gratuito — Alan Terra" },
      {
        name: "description",
        content:
          "Aula gratuita: como transformar o Instagram da sua assistência técnica em um canal de clientes com IA especializada.",
      },
      { property: "og:title", content: "Webinário Gratuito — Alan Terra" },
      {
        property: "og:description",
        content:
          "Descubra o método usado por assistências técnicas para gerar orçamentos com consistência.",
      },
      { property: "og:type", content: "website" },
    ],
    links: [
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Manrope:wght@400;500;600;700;800&display=swap",
      },
      { rel: "canonical", href: "/" },
    ],
  }),
  component: SqueezePage,
});

const pad = (n: number) => String(n).padStart(2, "0");

function SqueezePage() {
  const [seconds, setSeconds] = useState(5 * 60);

  useEffect(() => {
    if (seconds <= 0) return;
    const t = setTimeout(() => setSeconds((s) => s - 1), 1000);
    return () => clearTimeout(t);
  }, [seconds]);

  useEffect(() => {
    // Patch para o bug do embed.js oficial do AGWebinar:
    // ele chama r.json() em respostas 201 com body vazio (POST /form_submissions
    // não pede Prefer: return=representation), o que lança SyntaxError e
    // dispara o catch com "Erro ao enviar. Tente novamente.".
    // Interceptamos respostas do REST do Supabase com body vazio e devolvemos
    // um JSON válido ("null") para que o fluxo do embed continue.
    const w = window as unknown as { __agFetchPatched?: boolean };
    if (!w.__agFetchPatched) {
      w.__agFetchPatched = true;
      const originalFetch = window.fetch.bind(window);
      window.fetch = async (input: RequestInfo | URL, init?: RequestInit) => {
        const res = await originalFetch(input, init);
        try {
          const url =
            typeof input === "string"
              ? input
              : input instanceof URL
                ? input.href
                : input.url;
          if (
            res.ok &&
            url.includes("qywlapkndyjwbkpoqefx.supabase.co/rest/v1") &&
            res.headers.get("content-length") === "0"
          ) {
            return new Response("null", {
              status: res.status,
              statusText: res.statusText,
              headers: res.headers,
            });
          }
        } catch {
          /* ignore */
        }
        return res;
      };
    }

    if (document.querySelector(`script[src="${EMBED_SCRIPT_SRC}"]`)) return;
    const s = document.createElement("script");
    s.src = EMBED_SCRIPT_SRC;
    s.async = true;
    s.setAttribute("data-form", FORM_SLUG);
    s.setAttribute("data-unstyled", "true");
    document.body.appendChild(s);
  }, []);



  const countdown = `${pad(Math.floor(seconds / 60))}:${pad(seconds % 60)}`;

  return (
    <>
      <style>{css}</style>
      <div className="squeeze">
        <div className="urgency-bar">
          <span className="blink-circle" /> &nbsp;UMA TURMA ESTÁ COMEÇANDO EM&nbsp;
          <span id="countdown">{countdown}</span>
          &nbsp;— Cadastre-se e assista agora
        </div>

        <div className="glow-blob" />

        <div className="wrapper">
          <div className="hero-grid">
            <div className="hero-left">
              <div className="fade-up">
                <div className="tag">Aula gratuita — Assistências Técnicas</div>
              </div>

              <div className="fade-up">
                <h1>
                  Como transformar o Instagram da sua assistência em{" "}
                  <em>um canal de clientes</em>
                </h1>
              </div>

              <div className="fade-up">
                <p className="subheadline">
                  Descubra o método usado por assistências técnicas para sair do
                  improviso e <strong>gerar orçamentos com consistência</strong>,
                  usando inteligência artificial treinada para o seu nicho.
                </p>
              </div>

            </div>

            <div className="hero-right fade-up">
              <div className="form-box">
                <p className="form-title">Quero assistir agora</p>
                <p className="form-subtitle">
                  Preencha abaixo, o acesso é{" "}
                  <strong>imediato e gratuito</strong>
                </p>

                <div id={FORM_CONTAINER_ID}></div>

                <p className="form-privacy">
                  🔒 Seus dados estão protegidos. Sem spam.
                </p>
              </div>
            </div>
          </div>


          <div className="bullets-card fade-up">
            <p className="bullets-label">O que você vai aprender</p>
            <ul className="bullets">
              <li>
                <span>
                  <strong>Por que seus posts não geram clientes</strong> — e o
                  que fazer diferente a partir de hoje
                </span>
              </li>
              <li>
                <span>
                  <strong>O sistema de conteúdo que converte</strong> atenção em
                  orçamento, mesmo sem equipe de marketing
                </span>
              </li>
              <li>
                <span>
                  <strong>Como a IA especializada</strong> entrega em minutos o
                  que levaria dias para produzir sozinho
                </span>
              </li>
              <li>
                <span>
                  <strong>A comparação ao vivo</strong> entre IA genérica e o
                  agente treinado para assistências — você vai ver a diferença na
                  tela
                </span>
              </li>
              <li>
                <span>
                  <strong>O plano para sair do improviso</strong> e publicar com
                  direção comercial a partir desta semana
                </span>
              </li>
            </ul>
          </div>

          <div className="fade-up for-whom">
            <p className="bullets-label">Esta aula é para você que...</p>
            <div className="whom-grid">
              <div className="whom-item">
                <span>Tem assistência técnica e quer vender mais pelo digital</span>
              </div>
              <div className="whom-item">
                <span>Posta nas redes, mas não vê resultado em orçamentos</span>
              </div>
              <div className="whom-item">
                <span>Quer parar de depender só de indicação</span>
              </div>
              <div className="whom-item">
                <span>Já tentou ChatGPT e achou o resultado genérico demais</span>
              </div>
              <div className="whom-item">
                <span>Gerencia ou faz o social media de uma assistência</span>
              </div>
              <div className="whom-item">
                <span>Quer um sistema — não mais ideias soltas</span>
              </div>
            </div>
          </div>

          <div className="fade-up authority">
            <div className="authority-grid">
              <div className="authority-photo">
                <img src={professorImg} alt="Alan Terra, especialista em marketing para assistências técnicas" loading="lazy" />
              </div>
              <div className="authority-body">
                <p className="bullets-label">Quem é o seu professor</p>
                <p>
                  <strong>Alan Terra</strong> é especialista em marketing para
                  assistências técnicas e criador do Agente de IA para Redes Sociais
                  — desenvolvido exclusivamente para quem conserta e quer vender
                  mais. Nesta aula, ele mostra na prática como transformar presença
                  em clientes.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

const css = `
.squeeze {
  --black: #0a0a0a;
  --white: #f5f2ec;
  --orange: #e8500a;
  --orange-dark: #c43e00;
  --orange-glow: rgba(232, 80, 10, 0.18);
  --gray: #1c1c1c;
  --muted: #8a8a8a;
  --border: rgba(255,255,255,0.07);
  background-color: var(--black);
  background-image: url(${bgImg});
  background-size: cover;
  background-position: center;
  background-attachment: scroll;
  background-repeat: no-repeat;
  color: var(--white);
  font-family: 'Manrope', sans-serif;
  min-height: 100vh;
  overflow-x: hidden;
  position: relative;
}
.squeeze *, .squeeze *::before, .squeeze *::after { box-sizing: border-box; margin: 0; padding: 0; }

.squeeze .urgency-bar {
  background: #dc2626;
  color: #fff;
  text-align: center;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.04em;
  position: relative;
  z-index: 100;
  animation: sq-pulse-bar 2s ease-in-out infinite;
}
.squeeze .urgency-bar span { font-size: 16px; font-weight: 800; }
@keyframes sq-pulse-bar { 0%,100%{opacity:1} 50%{opacity:.88} }
.blink-circle {
  display: inline-block;
  width: 10px;
  height: 10px;
  background: #fff;
  border-radius: 50%;
  vertical-align: middle;
  animation: blink-pulse 1.2s ease-in-out infinite;
}
@keyframes blink-pulse { 0%,100%{opacity:1; transform:scale(1)} 50%{opacity:.4; transform:scale(.85)} }

.squeeze::after {
  content: '';
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.30);
  pointer-events: none;
  z-index: 0;
}
.squeeze::before {
  content: '';
  position: fixed;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
  pointer-events: none;
  z-index: 0;
  opacity: 0.4;
}

.squeeze .glow-blob {
  position: fixed;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, var(--orange-glow) 0%, transparent 70%);
  top: -100px;
  left: 50%;
  transform: translateX(-50%);
  pointer-events: none;
  z-index: 0;
}

.squeeze .wrapper {
  position: relative;
  z-index: 1;
  max-width: 1140px;
  margin: 0 auto;
  padding: 60px 24px 80px;
}

.squeeze .hero-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: center;
}

.squeeze .hero-left {
  display: flex;
  flex-direction: column;
}

.squeeze .tag {
  display: inline-block;
  background: var(--orange-glow);
  border: 1px solid var(--orange);
  color: var(--orange);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  padding: 5px 14px;
  border-radius: 999px;
  margin-bottom: 28px;
}

.squeeze h1 {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(32px, 4.2vw, 48px);
  line-height: 1.05;
  letter-spacing: 0.01em;
  margin-bottom: 10px;
  color: var(--white);
}
.squeeze h1 em { font-style: normal; color: var(--orange); }

.squeeze .subheadline {
  font-size: clamp(16px, 2.2vw, 19px);
  font-weight: 500;
  color: #b8b3aa;
  line-height: 1.6;
  margin-bottom: 44px;
  max-width: 640px;
}
.squeeze .subheadline strong { color: var(--white); font-weight: 700; }

.squeeze .divider {
  width: 48px;
  height: 3px;
  background: var(--orange);
  margin-bottom: 36px;
  border-radius: 2px;
}

.squeeze .bullets {
  list-style: none;
  display: flex;
  flex-direction: column;
  position: relative;
  z-index: 1;
}
.squeeze .bullets li {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  font-size: 15px;
  font-weight: 500;
  color: #ccc8c0;
  line-height: 1.55;
  padding: 18px 0;
  border-bottom: 1px solid rgba(255,255,255,0.06);
}
.squeeze .bullets li:last-child {
  border-bottom: none;
}
.squeeze .bullets li::before {
  content: '';
  display: block;
  flex-shrink: 0;
  width: 8px;
  height: 8px;
  margin-top: 7px;
  border-radius: 50%;
  background: var(--orange);
  box-shadow: 0 0 0 3px rgba(232, 80, 10, 0.18);
}
.squeeze .bullets strong { color: var(--white); }

.squeeze .form-box {
  background: rgba(28,28,28,0.7);
  backdrop-filter: blur(5px) saturate(160%);
  -webkit-backdrop-filter: blur(5px) saturate(160%);
  border: 1px solid var(--border);
  border-top: 3px solid var(--orange);
  border-radius: 20px;
  padding: 40px 36px;
  position: relative;
  overflow: hidden;
}
.squeeze .form-box::after {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at top center, rgba(232,80,10,0.06), transparent 70%);
  pointer-events: none;
}

.squeeze .form-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 28px;
  letter-spacing: 0.04em;
  color: var(--white);
  margin-bottom: 6px;
}
.squeeze .form-subtitle {
  font-size: 13px;
  color: var(--muted);
  margin-bottom: 28px;
  font-weight: 500;
}
.squeeze .form-subtitle strong { color: var(--orange); }

.squeeze .form-group { margin-bottom: 14px; }
.squeeze .form-group label {
  display: block;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 6px;
}
.squeeze .form-group input {
  width: 100%;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 9999px;
  padding: 14px 20px;
  font-size: 15px;
  font-family: 'Manrope', sans-serif;
  color: var(--white);
  outline: none;
  transition: border-color 0.2s;
}
.squeeze .form-group input::placeholder { color: #555; }
.squeeze .form-group input:focus { border-color: var(--orange); }

.squeeze .btn-submit {
  width: 100%;
  background: var(--orange);
  color: #fff;
  font-family: 'Manrope', sans-serif;
  font-size: 18px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  border: none;
  border-radius: 9999px;
  padding: 18px 24px;
  cursor: pointer;
  margin-top: 8px;
  transition: background 0.2s, transform 0.15s;
  position: relative;
  overflow: hidden;
}
.squeeze .btn-submit:hover { background: var(--orange-dark); transform: translateY(-1px); }
.squeeze .btn-submit:active { transform: translateY(0); }
.squeeze .btn-submit .arrow { display: inline-block; margin-left: 6px; transition: transform 0.2s; }
.squeeze .btn-submit:hover .arrow { transform: translateX(4px); }

.squeeze .form-privacy {
  text-align: center;
  font-size: 11px;
  color: #555;
  margin-top: 14px;
  font-weight: 500;
}
.squeeze .form-privacy a { color: #777; text-decoration: none; }

.squeeze .agform,
.squeeze [id^="agform-"] form {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.squeeze .agform-field,
.squeeze [id^="agform-"] .field,
.squeeze [id^="agform-"] > div {
  display: flex;
  flex-direction: column;
}
.squeeze .agform-label,
.squeeze [id^="agform-"] label {
  display: block;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 6px;
}
.squeeze .agform-input,
.squeeze [id^="agform-"] input,
.squeeze [id^="agform-"] select,
.squeeze [id^="agform-"] textarea {
  width: 100%;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 9999px;
  padding: 14px 20px;
  font-size: 15px;
  font-family: 'Manrope', sans-serif;
  color: var(--white);
  outline: none;
  transition: border-color 0.2s;
}
.squeeze .agform-input::placeholder,
.squeeze [id^="agform-"] input::placeholder { color: #555; }
.squeeze .agform-input:focus,
.squeeze [id^="agform-"] input:focus,
.squeeze [id^="agform-"] select:focus,
.squeeze [id^="agform-"] textarea:focus { border-color: var(--orange); }

.squeeze .agform-button,
.squeeze [id^="agform-"] button[type="submit"],
.squeeze [id^="agform-"] button {
  width: 100%;
  background: var(--orange);
  color: #fff;
  font-family: 'Manrope', sans-serif;
  font-size: 18px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  border: none;
  border-radius: 9999px;
  padding: 18px 24px;
  cursor: pointer;
  margin-top: 8px;
  transition: background 0.2s, transform 0.15s;
}
.squeeze .agform-button:hover,
.squeeze [id^="agform-"] button:hover { background: var(--orange-dark); transform: translateY(-1px); }
.squeeze .agform-button:active,
.squeeze [id^="agform-"] button:active { transform: translateY(0); }

.squeeze [id^="agform-"] h2,
.squeeze [id^="agform-"] .agform-title,
.squeeze [id^="agform-"] .form-header {
  display: none !important;
}

.squeeze [id^="agform-"] .agform-label,
.squeeze [id^="agform-"] label,
.squeeze .agform-label {
  display: none !important;
}




.squeeze .for-whom {
  margin-top: 60px;
}
.squeeze .whom-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.squeeze .whom-item {
  background: rgba(28,28,28,0.28);
  backdrop-filter: blur(5px) saturate(160%);
  -webkit-backdrop-filter: blur(5px) saturate(160%);
  border: 1px solid var(--border);
  border-radius: 20px;
  padding: 16px 18px;
  font-size: 14px;
  font-weight: 600;
  color: #c8c2b8;
  display: flex;
  align-items: center;
  gap: 10px;
  position: relative;
  overflow: hidden;
  isolation: isolate;
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.06), 0 10px 30px rgba(0,0,0,0.18);
}
.squeeze .whom-item::before {
  content: '';
  position: absolute;
  inset: -22px;
  border-radius: inherit;
  background-image: url(${bgImg});
  background-size: cover;
  background-position: center;
  filter: blur(5px);
  transform: scale(1.08);
  opacity: 0.9;
  z-index: -2;
}
.squeeze .whom-item::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: rgba(28,28,28,0.36);
  pointer-events: none;
  z-index: -1;
}
.squeeze .whom-item span {
  position: relative;
  z-index: 1;
}
.squeeze .whom-item span::before {
  content: '→';
  color: var(--orange);
  font-size: 16px;
  margin-right: 10px;
  flex-shrink: 0;
  position: relative;
  z-index: 1;
}

.squeeze .authority {
  margin-top: 48px;
  padding: 36px 32px;
  background: rgba(28,28,28,0.7);
  backdrop-filter: blur(5px) saturate(160%);
  -webkit-backdrop-filter: blur(5px) saturate(160%);
  border: 1px solid var(--border);
  border-top: 3px solid var(--orange);
  border-radius: 20px;
}
.squeeze .authority-grid {
  display: grid;
  grid-template-columns: 440px 1fr;
  gap: 28px;
  align-items: center;
  margin-top: 8px;
}
.squeeze .authority-photo {
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--border);
  background: #111;
  aspect-ratio: 1 / 1;
}
.squeeze .authority-photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: top center;
  display: block;
}
.squeeze .authority-body > p:not(.bullets-label) {
  font-size: 15px;
  font-weight: 500;
  color: #b0a99f;
  line-height: 1.7;
  margin-top: 18px;
}
.squeeze .authority-body > p:not(.bullets-label) strong { color: var(--white); font-weight: 700; }
@media (max-width: 640px) {
  .squeeze .authority-grid { grid-template-columns: 1fr; }
  .squeeze .authority-photo { max-width: 440px; margin: 0 auto; }
}

.squeeze .bullets-card {
  background: rgba(28,28,28,0.7);
  backdrop-filter: blur(5px) saturate(160%);
  -webkit-backdrop-filter: blur(5px) saturate(160%);
  border: 1px solid var(--border);
  border-top: 3px solid var(--orange);
  border-radius: 20px;
  padding: 36px 32px;
  margin-top: 40px;
  position: relative;
  overflow: hidden;
}
.squeeze .bullets-card::after {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at top center, rgba(232,80,10,0.06), transparent 70%);
  pointer-events: none;
}
.squeeze .bullets-label {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 26px;
  letter-spacing: 0.04em;
  color: var(--white);
  margin-bottom: 8px;
  position: relative;
  z-index: 1;
}
.squeeze .bullets-label::after {
  content: '';
  display: block;
  width: 40px;
  height: 3px;
  background: var(--orange);
  border-radius: 2px;
  margin-top: 10px;
}

.squeeze #countdown {
  font-size: 16px;
  font-weight: 800;
  background: rgba(0,0,0,0.25);
  padding: 2px 10px;
  border-radius: 2px;
  letter-spacing: 0.06em;
  display: inline-block;
  margin-left: 6px;
}

@media (max-width: 900px) {
  .squeeze .hero-grid { grid-template-columns: 1fr; gap: 12px; }
}

@media (max-width: 540px) {
  .squeeze .glow-blob { width: 360px; height: 360px; opacity: 0.22; top: -140px; }
  .squeeze::after { background: rgba(0,0,0,0.55); }
  .squeeze .wrapper { padding: 40px 18px 60px; }
  .squeeze .form-box { padding: 28px 20px; }
  .squeeze .whom-grid { grid-template-columns: 1fr; }
  .squeeze .btn-submit { font-size: 14px; }
  .squeeze p,
  .squeeze h1,
  .squeeze li span,
  .squeeze .whom-item {
    text-wrap: pretty;
  }
}

.squeeze .fade-up {
  opacity: 0;
  transform: translateY(22px);
  animation: sq-fadeUp 0.7s ease forwards;
}
.squeeze .hero-left .fade-up:nth-child(1) { animation-delay: 0.1s; }
.squeeze .hero-left .fade-up:nth-child(2) { animation-delay: 0.22s; }
.squeeze .hero-left .fade-up:nth-child(3) { animation-delay: 0.34s; }

.squeeze .hero-right.fade-up { animation-delay: 0.3s; }
.squeeze .fade-up.for-whom {
  animation-delay: 0.5s;
  transform: none;
  animation-name: sq-fadeIn;
}
@keyframes sq-fadeIn { to { opacity: 1; } }
.squeeze .fade-up.authority { animation-delay: 0.6s; }
@keyframes sq-fadeUp { to { opacity: 1; transform: translateY(0); } }
`;
