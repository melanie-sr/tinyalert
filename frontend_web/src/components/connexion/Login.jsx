import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useUser } from "../../contexts/UserContext";
import "./login.css";

function Login() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { setUser } = useUser();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = async (event) => {
    event.preventDefault();

    const data = {
      email,
      password,
    };

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_BACKEND}/auth/login`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          credentials: "include",
          body: JSON.stringify(data),
        }
      );

      const result = await response.json();

      if (response.ok) {
        console.log("Connexion réussie :", result);
        const meResponse = await fetch(
          `${import.meta.env.VITE_API_BACKEND}/users/me`,
          {
            credentials: "include",
          }
        );
        const meResult = await meResponse.json();
        if (meResponse.ok) {
          setUser(meResult.user);
        }
        navigate("/");
      } else {
        console.error(
          "Erreur lors de la connexion :",
          result.message || result
        );
      }
    } catch (error) {
      console.error("Erreur réseau :", error);
    }
  };

  return (
    <div className="login">
      <form className="login-form" onSubmit={handleSubmit}>
        <h1>{t("login.title")}</h1>
        <div className="field">
          <label htmlFor="email">{t("login.email")}</label>
          <input
            type="email"
            name="email"
            onChange={(e) => setEmail(e.target.value)}
            required
          />
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
            onChange={(e) => setPassword(e.target.value)}
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
