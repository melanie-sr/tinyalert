import { useTranslation } from "react-i18next";
import "./footer.css";

function Footer() {
  const { t } = useTranslation();
  return (
    <div className="footer">
      <div className="footer-container">
        <div className="footer-newsletter">
          <h3 className="footer-title">{t("footer.newsletter.title")}</h3>
          <input
            className="footer-email"
            type="email"
            placeholder={t("footer.newsletter.email_placeholder")}
          />
        </div>
        <div className="footer-disasters">
          <h3 className="footer-title">{t("footer.disasters.title")}</h3>
          <div className="footer-links">
            <a className="footer-link" href="/tsunami">
              {t("footer.disasters.tsunami")}
            </a>
            <a className="footer-link" href="/earthequake">
              {t("footer.disasters.earthquake")}
            </a>
            <a className="footer-link" href="/volcano">
              {t("footer.disasters.volcano")}
            </a>
            <a className="footer-link" href="/fire">
              {t("footer.disasters.fire")}
            </a>
            <a className="footer-link" href="/tornado">
              {t("footer.disasters.tornado")}
            </a>
          </div>
        </div>
        <div className="footer-infos">
          <h3 className="footer-title">{t("footer.infos.title")}</h3>
          <div className="footer-links">
            <a className="footer-link" href="/about">
              {t("footer.infos.about")}
            </a>
            <a className="footer-link" href="/contact">
              {t("footer.infos.contact")}
            </a>
          </div>
        </div>
      </div>
      <p className="footer-copyright">
        &copy; {new Date().getFullYear()} {t("footer.copyright")}
      </p>
    </div>
  );
}

export default Footer;
