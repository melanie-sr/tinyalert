import { Link, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useState } from "react";
import { useUser } from "../../contexts/UserContext";
import Hamburger from "hamburger-react";
import LanguageSelector from "../snippets/LanguageSelector";
import "./navbar.css";

function NavBar() {
  const [isOpen, setOpen] = useState(false);
  const { t } = useTranslation();
  const { user, setUser } = useUser();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await fetch(`${import.meta.env.VITE_API_BACKEND}/auth/logout`, {
        method: "POST",
        credentials: "include",
      });
      setUser(null);
      navigate("/");
    } catch (err) {
      console.error("Erreur de déconnexion :", err);
    }
  };

  return (
    <nav className="navbar">
      <div className="navbar-desktop">
        <img className="nav-logo" src="/" alt="" />
        <div className="nav-links">
          <Link className="nav-link" to="/">
            {t("navbar.home")}
          </Link>
          <Link className="nav-link" to="/disasters">
            {t("navbar.disasters")}
          </Link>
          <Link className="nav-link" to="/ranking">
            {t("navbar.ranking")}
          </Link>
        </div>
        <div className="nav-right">
          {user ? (
            <>
              <button className="nav-link" onClick={handleLogout}>
                {t("navbar.logout")}
              </button>
              <Link className="nav-link" to="/profile">
                {t("navbar.profile")}
              </Link>
            </>
          ) : (
            <>
              <Link className="nav-link nav-login" to="/register">
                {t("navbar.register")}
              </Link>
              <Link className="nav-link nav-login" to="/login">
                {t("navbar.login")}
              </Link>
            </>
          )}
          <LanguageSelector />
        </div>
      </div>
      <div className="navbar-mobile">
        <img className="nav-logo" src="/" alt="" />
        <Hamburger toggled={isOpen} toggle={setOpen} />
        {isOpen && (
          <div className={`hamburger-menu ${isOpen ? "menu-slide-in" : ""}`}>
            <div className="nav-links">
              <Link className="nav-link" to="/">
                {t("navbar.home")}
              </Link>
              <Link className="nav-link" to="/disasters">
                {t("navbar.disasters")}
              </Link>
              <Link className="nav-link" to="/ranking">
                {t("navbar.ranking")}
              </Link>
            </div>
            <div>
              {user ? (
                <>
                  <button className="nav-link" onClick={handleLogout}>
                    {t("navbar.logout")}
                  </button>
                  <Link className="nav-link" to="/profile">
                    {t("navbar.profile")}
                  </Link>
                </>
              ) : (
                <>
                  <Link className="nav-link" to="/register">
                    {t("navbar.register")}
                  </Link>
                  <Link className="nav-link" to="/login">
                    {t("navbar.login")}
                  </Link>
                </>
              )}
              <LanguageSelector />
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}

export default NavBar;
