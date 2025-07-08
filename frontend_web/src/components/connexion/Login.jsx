import React from "react";
import { useTranslation } from "react-i18next";
import "./login.css";

function Login() {
  const { t } = useTranslation();

  return (
    <div className="login">
      <form className="login-form">
        <h1>{t("login.title")}</h1>
        <div className="field">
          <label htmlFor="email">{t("login.email")}</label>
          <input type="email" name="email" required />
        </div>

        <div className="field">
          <label htmlFor="password">{t("login.password")}</label>
          <input
            type="password"
            id="password"
            name="password"
            minLength="8"
            pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}"
            title="Doit contenir une majuscule, une minuscule, un chiffre, et au moins 8 caractères"
            required
          />
        </div>
        <button type="submit" className="form-submit">
          {t("login.submit")}
        </button>
      </form>
    </div>
  );
}
export default Login;
