import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import Search from "/images/icons/loupe.png";
import "./disasters.css";

function Disasters() {
  const { t } = useTranslation();
  const [searchTerm, setSearchTerm] = useState("");

  const disasters = [
    {
      id: 1,
      name: t("disasters.tsunami.title"),
      description: t("disasters.tsunami.description"),
      image: "/images/disasters/tsunami/tsunami_little_banner.png",
      link: "../tsunami",
    },
    {
      id: 2,
      name: t("disasters.earthquake.title"),
      description: t("disasters.earthquake.description"),
      image: "/images/disasters/earthquake/earthquake_little_banner.png",
    },
  ];

  const filteredDisasters = disasters.filter((disaster) =>
    disaster.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="disasters">
      <div className="disasters-filter">
        <input
          type="text"
          placeholder={t("disasters.filter")}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
        <img src={Search} alt="search" />
      </div>
      <div className="disasters-container">
        {filteredDisasters.map((disaster) => (
          <div className="disaster-card" key={disaster.id}>
            <img
              className="disaster-image"
              src={disaster.image}
              alt={disaster.name}
            />
            <div className="disaster-info">
              <h3>{disaster.name}</h3>
              <p>{disaster.description}</p>
              <Link to={disaster.link}>{t("disasters.button")}</Link>
            </div>
          </div>
        ))}
        {filteredDisasters.length === 0 && (
          <p className="no-results">
            {t("disasters.noResults") || "Aucune catastrophe trouvée."}
          </p>
        )}
      </div>
    </div>
  );
}
export default Disasters;
