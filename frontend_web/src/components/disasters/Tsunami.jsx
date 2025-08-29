import "./disastersContent.css";
import BannerTsunami from "/images/disasters/tsunami/tsunami_banner.png";

function Tsunami() {
  return (
    <div className="content">
      <h2>🧠 Les signes avant-coureurs d’un tsunami</h2>
      <section className="sections-content">
        <div className="div-section-content-4">
          <p className="icon">🚨 </p>
          <h3>Fort tremblement de terre</h3>
          <p>
            Si la terre <strong>bouge fortement</strong> pendant plus de{" "}
            <strong>20 secondes</strong>, cela peut vouloir dire qu’un tsunami
            se prépare. <br />
            <em>➜ Il faut vite s’éloigner de la mer !</em>
          </p>
        </div>
        <div className="div-section-content-4">
          <p className="icon">🌊</p>
          <h3>La mer se retire très vite</h3>
          <p>
            Si tu vois la mer <strong>se vider vite</strong>, c’est un{" "}
            <strong>signe très dangereux</strong>. <br />
            <em>➜ Il faut courir vers les hauteurs immédiatement !</em>
          </p>
        </div>
        <div className="div-section-content-4">
          <p className="icon">📣 </p>
          <h3>Alerte tsunami</h3>
          <p>
            Sirènes ou messages d’alerte dans certaines régions. <br />
            <em>➜ Suis les consignes et ne retourne pas à la mer !</em>
          </p>
        </div>

        <div className="div-section-content-4">
          <p className="icon">👂</p>
          <h3>Bruit étrange</h3>
          <p>
            Un <strong>bruit</strong> comme un{" "}
            <strong>train ou un avion</strong> peut annoncer une vague. <br />{" "}
            <em>➜ Cours te mettre à l’abri !</em>
          </p>
        </div>
      </section>

      <h2>✅ Que faire avant, pendant et après un tsunami ?</h2>
      <section className="sections-content">
        <div className="div-section-content-3">
          <h3>🟢 Avant : S’informer et se préparer</h3>
          <ul>
            <li>Connaître les risques dans ta région.</li>
            <li>Participer aux exercices d’évacuation.</li>
            <li>Savoir où se réfugier en hauteur.</li>
            <li>
              Préparer un sac d’urgence (eau, lampe, papiers, vêtement chaud).
            </li>
          </ul>
        </div>
        <div className="div-section-content-3">
          <h3>🟡 Pendant : Réagir vite et bien</h3>
          <ul>
            <li>Éloigne-toi immédiatement de la mer.</li>
            <li>Monte en hauteur.</li>
            <li>Ne perds pas de temps, n’attends pas les vagues.</li>
            <li>Ne retourne pas chercher tes affaires.</li>
          </ul>
        </div>
        <div className="div-section-content-3">
          <h3>🔴 Après : Rester prudent</h3>
          <ul>
            <li>
              Reste à l’écart de la mer jusqu’à l’annonce officielle de
              sécurité.
            </li>
            <li>Écoute la radio ou les adultes pour les consignes.</li>
            <li>Aide les autres si tu peux, sans te mettre en danger.</li>
          </ul>
        </div>
      </section>

      <h2>🔎 Tu veux aller plus loin ?</h2>
      <section className="sections-content">
        <div className="div-section-content-2">
          <h3>🧪 Coin des scientifiques</h3>
          <iframe
            className="YTvideo"
            width="560"
            height="315"
            src="https://www.youtube.com/embed/QOfS9kvsrjo"
            title="YouTube video player"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
          ></iframe>{" "}
          <ul>
            <li>
              Un tsunami peut aller à <strong>plus de 800 km/h</strong> en mer.
            </li>
            <li>
              En arrivant à la côte, la vague{" "}
              <strong>ralentit mais devient plus haute</strong>.
            </li>
            <li>
              Le <strong>Pacifique</strong> est la zone la plus touchée à cause
              de la “Ceinture de feu”.
            </li>
          </ul>
        </div>

        <div className="div-section-content-2">
          <h3>📚 Sources</h3>
          <ul>
            <li>UNESCO/IOC – Tsunami Awareness for Children (2020)</li>
            <li>IFRC – Red Cross Red Crescent Tsunami Preparedness Toolkit</li>
            <li>U.S. NOAA – Tsunami Education Resources for Kids</li>
            <li>
              Institut de Physique du Globe de Paris – « Que faire en cas de
              tsunami ? »
            </li>
          </ul>
        </div>
      </section>
    </div>
  );
}

export default Tsunami;
