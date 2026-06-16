import { createFileRoute } from "@tanstack/react-router";
import bgImg from "@/assets/bg-squeeze-page.webp";
import logoH2Web from "@/assets/logo-h2web.webp";

export const Route = createFileRoute("/agente")({
  head: () => ({
    meta: [
      { title: "Agente de Conteúdo para Assistências Técnicas" },
      {
        name: "description",
        content:
          "Agente de IA treinado exclusivamente para transformar a comunicação da sua assistência técnica em um canal real de autoridade, orçamento e clientes.",
      },
      {
        property: "og:title",
        content: "Agente de Conteúdo para Assistências Técnicas",
      },
      {
        property: "og:description",
        content:
          "O único agente de IA treinado para o nicho de assistência técnica. Calendário, Reels, legendas, anúncios e mais.",
      },
      { property: "og:type", content: "website" },
    ],
    links: [
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Manrope:wght@400;500;600;700;800&display=swap",
      },
      { rel: "canonical", href: "/agente" },
    ],
  }),
  component: AgentePage,
});

const heroBullets = [
  "Você posta sem direção e os posts morrem sem virar orçamento",
  "Já tentou ChatGPT, mas os textos eram genéricos demais para o seu nicho",
  "Sabe que precisa fazer melhor nas redes — mas não tem método nem tempo",
];

const painPoints = [
  {
    icon: "⏰",
    title: "Perfil parado ou irregular",
    text: "passa impressão de negócio abandonado.",
  },
  {
    icon: "😐",
    title: "Conteúdo que não converte",
    text: "posts sem CTA, promoções que não convencem.",
  },
  {
    icon: "👀",
    title: "Concorrência avançando",
    text:
      "uma assistência na sua cidade aparece mais, parece mais profissional. O cliente liga para ela primeiro.",
  },
];

const deliverables = [
  { icon: "📅", text: "Calendário editorial completo com lógica de conversão" },
  { icon: "🎬", text: "Roteiros de Reels prontos para gravar" },
  { icon: "✍️", text: "Legendas com CTA estratégico" },
  {
    icon: "💡",
    text: "Ideias por tipo de serviço (celular, notebook, TV, linha branca)",
  },
  { icon: "🎯", text: "Campanhas sazonais já adaptadas ao nicho" },
  { icon: "⭐", text: "Stories de prova social que convencem" },
  { icon: "📣", text: "Scripts de anúncios para tráfego pago" },
];

const comparison = [
  {
    label: "Contexto de nicho",
    chat: "Você explica do zero sempre",
    agent: "Já conhece o setor",
  },
  {
    label: "Qualidade",
    chat: "Genérico, serve para qualquer negócio",
    agent: "Específico para gerar confiança e orçamento",
  },
  {
    label: "Objeções do cliente",
    chat: "Não conhece o que trava o orçamento",
    agent: "Sabe exatamente o que freia a compra",
  },
  {
    label: "CTA estratégico",
    chat: "Precisa pedir sempre",
    agent: "Incluído por padrão em cada peça",
  },
];

const bonuses = [
  {
    icon: "🎬",
    title: "Bônus 1",
    text: "Biblioteca com +50 ganchos e estruturas de Reels testados",
  },
  {
    icon: "📅",
    title: "Bônus 2",
    text: "Calendário Editorial Sazonal completo para o ano",
  },
  { icon: "💬", title: "Bônus 3", text: "Modelos de CTA prontos para WhatsApp" },
  {
    icon: "🎯",
    title: "Bônus 4",
    text: "Kit de Oferta Promocional com copy de conversão",
  },
  { icon: "⭐", title: "Bônus 5", text: "Modelos de Stories de Prova Social" },
];

function AgentePage() {
  return (
    <>
      <style>{css}</style>
      <div className="agente">
        <div className="urgency-bar">
          <span>🔥</span> Lançamento especial — condição exclusiva por tempo
          limitado
        </div>

        <div className="glow-blob" />

        {/* HERO */}
        <section className="wrapper">
          <div className="hero">
            <span className="tag">Para Donos de Assistências Técnicas</span>
            <h1>
              O Problema da Sua Assistência Pode Não Ser o Serviço.{" "}
              <em>Pode Ser a Comunicação.</em>
            </h1>
            <p className="subheadline">
              A maioria das assistências perde clientes todo dia — não por
              prestar serviço ruim, mas por não comunicar valor. Conheça o
              agente de IA criado exclusivamente para transformar a comunicação
              da sua assistência em um canal real de autoridade, orçamento e
              clientes.
            </p>

            <ul className="hero-bullets">
              {heroBullets.map((b) => (
                <li key={b}>
                  <span className="x">✗</span>
                  <span>{b}</span>
                </li>
              ))}
            </ul>

            <a href="#oferta" className="btn-cta">
              → QUERO TRANSFORMAR MINHA ASSISTÊNCIA →
            </a>

            <p className="cta-meta">
              <span>✓ Acesso imediato</span>
              <span>✓ Sem experiência com IA</span>
              <span>✓ Garantia de 7 dias</span>
            </p>
          </div>
        </section>

        {/* DOR */}
        <section className="wrapper">
          <div className="card">
            <h2>
              Você cuida bem dos aparelhos. Mas quem cuida da comunicação da sua
              assistência?
            </h2>
            <div className="pain-grid">
              {painPoints.map((p) => (
                <div key={p.title} className="pain-item">
                  <div className="pain-icon">{p.icon}</div>
                  <h3>{p.title}</h3>
                  <p>{p.text}</p>
                </div>
              ))}
            </div>
            <blockquote className="quote">
              O problema não é o seu serviço. É que o seu serviço não está sendo
              comunicado do jeito certo.
            </blockquote>
          </div>
        </section>

        {/* SOLUÇÃO */}
        <section className="wrapper">
          <div className="card">
            <span className="tag">A inteligência que estava faltando</span>
            <h2>Agente de Conteúdo para Assistências Técnicas</h2>
            <p className="paragraph">
              O único agente de IA treinado especificamente para transformar a
              comunicação da sua assistência em um canal previsível de
              autoridade, orçamento e clientes — sem agência cara, sem
              improviso e sem experiência prévia em marketing ou IA.
            </p>
            <p className="paragraph">
              Não é um gerador de posts. É um estrategista que pensa como
              redator, social media e vendedor ao mesmo tempo — treinado para
              entender exatamente o que faz um cliente escolher uma assistência
              técnica.
            </p>

            <p className="section-label">
              O que você consegue criar a partir de hoje:
            </p>
            <ul className="deliverables">
              {deliverables.map((d) => (
                <li key={d.text}>
                  <span className="ico">{d.icon}</span>
                  <span>{d.text}</span>
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* COMPARAÇÃO */}
        <section className="wrapper">
          <div className="card">
            <h2>ChatGPT comum vs. Este Agente</h2>
            <div className="compare">
              <div className="compare-head">
                <div></div>
                <div className="col-chat">ChatGPT comum</div>
                <div className="col-agent">Este Agente</div>
              </div>
              {comparison.map((row) => (
                <div key={row.label} className="compare-row">
                  <div className="row-label">{row.label}</div>
                  <div className="row-chat">{row.chat}</div>
                  <div className="row-agent">
                    <span className="check">✓</span> {row.agent}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* OFERTA */}
        <section className="wrapper" id="oferta">
          <div className="card offer">
            <span className="tag">O que você leva hoje</span>
            <h2>
              <span className="ico">🤖</span> AGENTE DE CONTEÚDO PARA
              ASSISTÊNCIAS TÉCNICAS
            </h2>
            <p className="paragraph">
              Acesso imediato ao agente treinado exclusivamente para o seu
              nicho.
            </p>

            <p className="section-label">+ 5 Bônus incluídos:</p>
            <ul className="bonuses">
              {bonuses.map((b) => (
                <li key={b.title}>
                  <span className="ico">{b.icon}</span>
                  <div>
                    <strong>{b.title}</strong> — {b.text}
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </section>

        {/* GARANTIA + CTA FINAL */}
        <section className="wrapper">
          <div className="card final">
            <div className="guarantee">
              <div className="g-icon">🛡️</div>
              <div>
                <h3>Garantia de 7 Dias Sem Questionamentos</h3>
                <p>
                  Acesse, use e explore sem risco. Se não gostar por qualquer
                  motivo, devolvemos 100% do investimento. Sem burocracia.
                </p>
              </div>
            </div>

            <p className="warning">
              ⚠️ Condição de lançamento: bônus disponíveis por tempo limitado.
            </p>

            <blockquote className="quote">
              "Você não está comprando uma IA para fazer posts. Está adquirindo
              um sistema especialista para transformar sua rede social em um
              canal real de clientes."
            </blockquote>

            <a href="#oferta" className="btn-cta">
              → QUERO TRANSFORMAR MINHA ASSISTÊNCIA TÉCNICA →
            </a>

            <p className="cta-meta">
              <span>✓ Acesso imediato após confirmação</span>
              <span>✓ Garantia de 7 dias</span>
              <span>✓ Todos os 5 bônus incluídos</span>
              <span>✓ Tutorial de uso incluso</span>
            </p>
          </div>
        </section>

        <footer className="footer">
          <div className="footer-inner">
            <div className="footer-left">
              <img
                src={logoH2Web}
                alt="H2Web"
                className="footer-logo"
                loading="lazy"
              />
              <span className="footer-copy">
                H2Web Copyright ©2026 Todos os direitos reservados.
              </span>
            </div>
            <div className="footer-right">
              <p>Transformamos conhecimento em negócios lucrativos</p>
              <p className="footer-cta">
                Venha ser um Expert{" "}
                <a
                  href="https://agwebi.com.br/"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  AG WEBi
                </a>
              </p>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}

const css = `
.agente {
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
.agente *, .agente *::before, .agente *::after { box-sizing: border-box; margin: 0; padding: 0; }

.agente .urgency-bar {
  background: #dc2626;
  color: #fff;
  text-align: center;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.04em;
  position: relative;
  z-index: 100;
}
.agente::after {
  content: '';
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  pointer-events: none;
  z-index: 0;
}
.agente .glow-blob {
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
.agente .wrapper {
  position: relative;
  z-index: 1;
  max-width: 1040px;
  margin: 0 auto;
  padding: 48px 24px;
}

.agente .tag {
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
  margin-bottom: 20px;
}

.agente h1 {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(34px, 5vw, 58px);
  line-height: 1.04;
  letter-spacing: 0.01em;
  margin-bottom: 18px;
  color: var(--white);
}
.agente h1 em { font-style: normal; color: var(--orange); }

.agente h2 {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(26px, 3.4vw, 38px);
  letter-spacing: 0.02em;
  line-height: 1.1;
  margin-bottom: 18px;
  color: var(--white);
}

.agente h3 {
  font-family: 'Manrope', sans-serif;
  font-size: 18px;
  font-weight: 700;
  color: var(--white);
  margin-bottom: 6px;
}

.agente .subheadline {
  font-size: clamp(15px, 2vw, 18px);
  font-weight: 500;
  color: #b8b3aa;
  line-height: 1.6;
  margin-bottom: 26px;
  max-width: 720px;
}

.agente .paragraph {
  font-size: 15px;
  font-weight: 500;
  color: #b8b3aa;
  line-height: 1.7;
  margin-bottom: 14px;
}

.agente .section-label {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  color: var(--white);
  letter-spacing: 0.04em;
  margin: 24px 0 14px;
}

.agente .hero-bullets {
  list-style: none;
  margin: 0 0 28px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.agente .hero-bullets li {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  font-size: 15px;
  color: #ccc8c0;
  line-height: 1.55;
}
.agente .hero-bullets .x {
  color: var(--orange);
  font-weight: 800;
  font-size: 16px;
}

.agente .btn-cta {
  display: inline-block;
  background: var(--orange);
  color: #fff;
  font-family: 'Manrope', sans-serif;
  font-size: 17px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  text-decoration: none;
  padding: 18px 32px;
  border-radius: 9999px;
  transition: background 0.2s, transform 0.15s;
  box-shadow: 0 12px 30px rgba(232,80,10,0.32);
}
.agente .btn-cta:hover { background: var(--orange-dark); transform: translateY(-1px); }

.agente .cta-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 18px;
  margin-top: 16px;
  font-size: 13px;
  color: #b8b3aa;
  font-weight: 600;
}

.agente .card {
  background: rgba(20,20,20,0.72);
  backdrop-filter: blur(6px) saturate(160%);
  -webkit-backdrop-filter: blur(6px) saturate(160%);
  border: 1px solid var(--border);
  border-top: 3px solid var(--orange);
  border-radius: 22px;
  padding: 40px 36px;
}

.agente .pain-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-top: 20px;
}
.agente .pain-item {
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 22px 20px;
}
.agente .pain-icon { font-size: 28px; margin-bottom: 10px; }
.agente .pain-item p {
  font-size: 14px;
  color: #b8b3aa;
  line-height: 1.55;
}

.agente .quote {
  margin-top: 28px;
  padding: 20px 24px;
  border-left: 3px solid var(--orange);
  background: rgba(232,80,10,0.06);
  font-size: 16px;
  font-style: italic;
  color: #e8e3da;
  line-height: 1.55;
  border-radius: 0 12px 12px 0;
}

.agente .deliverables,
.agente .bonuses {
  list-style: none;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.agente .deliverables li,
.agente .bonuses li {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 14px 16px;
  font-size: 14px;
  color: #d0ccc4;
  line-height: 1.5;
}
.agente .deliverables .ico,
.agente .bonuses .ico { font-size: 20px; flex-shrink: 0; }
.agente .bonuses li strong { color: var(--white); font-weight: 700; }

.agente .compare {
  border: 1px solid var(--border);
  border-radius: 16px;
  overflow: hidden;
}
.agente .compare-head,
.agente .compare-row {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1.2fr;
}
.agente .compare-head {
  background: rgba(255,255,255,0.04);
  font-family: 'Bebas Neue', sans-serif;
  letter-spacing: 0.05em;
  font-size: 16px;
}
.agente .compare-head > div,
.agente .compare-row > div {
  padding: 14px 16px;
  font-size: 14px;
  border-bottom: 1px solid var(--border);
}
.agente .compare-row:last-child > div { border-bottom: none; }
.agente .compare-row .row-label { color: var(--white); font-weight: 700; }
.agente .compare-row .row-chat { color: #9b968d; }
.agente .compare-row .row-agent { color: #e8e3da; }
.agente .compare-row .check { color: var(--orange); font-weight: 800; margin-right: 4px; }
.agente .col-chat { color: #9b968d; }
.agente .col-agent { color: var(--orange); }

.agente .offer h2 .ico { margin-right: 6px; }

.agente .final { text-align: center; }
.agente .final .guarantee {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  text-align: left;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 22px;
}
.agente .final .g-icon { font-size: 32px; }
.agente .final .guarantee p { color: #b8b3aa; font-size: 14px; line-height: 1.55; }
.agente .final .warning {
  color: #f0c14b;
  font-size: 13px;
  font-style: italic;
  margin-bottom: 14px;
}
.agente .final .quote { text-align: left; }
.agente .final .btn-cta { margin-top: 24px; }
.agente .final .cta-meta { justify-content: center; }

.agente .footer {
  background: #000;
  border-top: 1px solid rgba(255,255,255,0.06);
  position: relative;
  z-index: 1;
  margin-top: 40px;
}
.agente .footer-inner {
  max-width: 1140px;
  margin: 0 auto;
  padding: 28px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
}
.agente .footer-left { display: flex; align-items: center; gap: 14px; }
.agente .footer-logo { height: 36px; width: auto; display: block; }
.agente .footer-copy { font-size: 13px; color: #b8b3aa; font-weight: 500; }
.agente .footer-right { text-align: right; font-size: 13px; color: #b8b3aa; line-height: 1.6; }
.agente .footer-cta { color: #fff; font-weight: 700; }
.agente .footer-cta a { color: var(--orange); text-decoration: none; }
.agente .footer-cta a:hover { text-decoration: underline; }

@media (max-width: 820px) {
  .agente .pain-grid { grid-template-columns: 1fr; }
  .agente .deliverables, .agente .bonuses { grid-template-columns: 1fr; }
  .agente .compare-head, .agente .compare-row { grid-template-columns: 1fr; }
  .agente .compare-head > div, .agente .compare-row > div { border-bottom: 1px solid var(--border); }
  .agente .card { padding: 28px 22px; }
}
@media (max-width: 640px) {
  .agente .footer-inner { flex-direction: column; align-items: flex-start; }
  .agente .footer-right { text-align: left; }
  .agente .btn-cta { width: 100%; text-align: center; font-size: 14px; padding: 16px 18px; }
}
`;
