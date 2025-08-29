import { useTranslation } from "react-i18next";
import { useUser } from "../contexts/UserContext";
import { Link } from "react-router-dom";
import BannerDesktop from "/images/image_banner.png";
import BannerMobile from "/images/image_banner_mobile.png";
import "./home.css";

function Home() {
  const { t } = useTranslation();

  const disasters = [
    {
      id: 1,
      name: t("home.disasters.tsunami"),
      image: "/images/disasters/tsunami/tsunami.png",
      link: "tsunami",
    },
    {
      id: 2,
      name: t("home.disasters.earthquake"),
      image: "/images/disasters/earthquake/earthquake.png",
      link: "earthquake",
    },
    {
      id: 3,
      name: t("home.disasters.volcano"),
      image: "/images/disasters/volcano/volcano.png",
    },
    {
      id: 4,
      name: t("home.disasters.fire"),
      image: "/images/disasters/fire/fire.png",
    },
    {
      id: 5,
      name: t("home.disasters.tornado"),
      image: "/images/disasters/tornado/tornado.png",
    },
  ];

  return (
    <div className="home">
      <div className="hero-banner">
        <img
          src={BannerDesktop}
          alt="Banner"
          className="img-banner img-banner-desktop"
        />
        <img
          src={BannerMobile}
          alt="Banner"
          className="img-banner img-banner-mobile"
        />
        <div className="banner-content">
          <h1 className="title-banner">{t("home.title")}</h1>
          <div className="button-banner-container">
            <a
              className="button-banner"
              href="https://www.roblox.com/fr/charts#/?device=computer&country=all"
            >
              {t("home.button")}
            </a>
            <p className="subtitle-banner">{t("home.subtitle")}</p>
          </div>
        </div>
      </div>

      <h2 className="title-disasters">{t("home.disasters.title")}</h2>
      <div className="carousel-disasters">
        {disasters.map((disaster) => (
          <Link
            to={disaster.link}
            key={disaster.id}
            className="home-disaster-card"
          >
            <img
              src={disaster.image}
              alt={disaster.name}
              className="disaster-img"
            />
            <p className="disaster-name">{disaster.name}</p>
          </Link>
          // <div key={disaster.id} className="home-disaster-card">
          //   <img
          //     src={disaster.image}
          //     alt={disaster.name}
          //     className="disaster-img"
          //   />
          //   <p className="disaster-name">{disaster.name}</p>
          // </div>
        ))}
      </div>
    </div>
  );
}
export default Home;
