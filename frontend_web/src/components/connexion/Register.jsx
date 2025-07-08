import React from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import "./register.css";

function Register() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const handleSubmit = async (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);
    const data = {
      firstName: formData.get("firstname"),
      lastName: formData.get("lastname"),
      email: formData.get("email"),
      password: formData.get("password"),
    };
    console.log("Data to be sent:", data);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_BACKEND}/auth/register`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify(data),
        }
      );

      const result = await response.json();

      if (response.ok) {
        console.log("Inscription réussie :", result);
        navigate("/login");
        // Tu peux ajouter une redirection ou un message de succès ici
      } else {
        console.error(
          "Erreur lors de l'inscription :",
          result.message || result
        );
        // Afficher une erreur à l'utilisateur si nécessaire
      }
    } catch (error) {
      console.error("Erreur réseau :", error);
    }
  };

  return (
    <div className="register">
      <form className="register-form" onSubmit={handleSubmit}>
        <h1>{t("register.title")}</h1>
        <div className="name-fields">
          <div className="field">
            <label htmlFor="firstname">{t("register.firstname")}</label>
            <input type="text" name="firstname" required />
          </div>
          <div className="field">
            <label htmlFor="lastname">{t("register.lastname")}</label>
            <input type="text" name="lastname" required />
          </div>
        </div>
        <div className="field">
          <label htmlFor="email">{t("register.email")}</label>
          <input type="email" name="email" required />
        </div>
        <div className="password-fields">
          <div className="field">
            <label htmlFor="password">{t("register.password")}</label>
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
          <div className="field">
            <label htmlFor="confirmPassword">
              {t("register.confirm_password")}
            </label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              required
            />
          </div>
        </div>
        <button type="submit" className="form-submit">
          {t("register.submit")}
        </button>
      </form>
    </div>
  );
}
export default Register;
