import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useUser } from "../contexts/UserContext";
import "./profile.css";

function Profile() {
  const { t } = useTranslation();
  const { user, setUser } = useUser();
  const [firstName, setFirstName] = useState(user?.firstName || "");
  const [lastName, setLastName] = useState(user?.lastName || "");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (password && password !== confirmPassword) {
      setErrorMessage(t("profile.password_mismatch"));
      return;
    }

    const updatedData = {
      firstName,
      lastName,
      ...(password && { password }),
    };

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_BACKEND}/users/updateProfile`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          credentials: "include",
          body: JSON.stringify(updatedData),
        }
      );

      const result = await response.json();

      if (response.ok) {
        setErrorMessage("");
        setSuccessMessage(t("profile.update_success"));
        setUser(result.user);
        setPassword("");
        setConfirmPassword("");
      } else {
        setErrorMessage(result.message || t("profile.update_error"));
      }
    } catch (err) {
      setErrorMessage(t("profile.network_error"));
    }
  };

  useEffect(() => {
    if (user) {
      setFirstName(user.firstName);
      setLastName(user.lastName);
    }
  }, [user]);

  return (
    <div className="profile">
      <form className="profile-form" onSubmit={handleSubmit}>
        <h1>{t("profile.title")}</h1>

        <div className="field">
          <label htmlFor="firstName">{t("profile.firstname")}</label>
          <input
            type="text"
            id="firstName"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            required
          />
        </div>

        <div className="field">
          <label htmlFor="lastName">{t("profile.lastname")}</label>
          <input
            type="text"
            id="lastName"
            value={lastName}
            onChange={(e) => setLastName(e.target.value)}
            required
          />
        </div>

        <div className="field">
          <label htmlFor="password">{t("profile.new_password")}</label>
          <input
            type="password"
            id="password"
            value={password}
            placeholder={t("profile.password_placeholder")}
            onChange={(e) => setPassword(e.target.value)}
            minLength="8"
            pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}"
            title="Doit contenir une majuscule, une minuscule, un chiffre, et au moins 8 caractères"
          />
        </div>

        <div className="field">
          <label htmlFor="confirmPassword">
            {t("profile.confirm_password")}
          </label>
          <input
            type="password"
            id="confirmPassword"
            value={confirmPassword}
            placeholder={t("profile.confirm_password_placeholder")}
            onChange={(e) => setConfirmPassword(e.target.value)}
            minLength="8"
            pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}"
          />
        </div>

        {successMessage && <p className="success">{successMessage}</p>}
        {errorMessage && <p className="error">{errorMessage}</p>}

        <button type="submit" className="form-submit">
          {t("profile.save_changes")}
        </button>
      </form>
    </div>
  );
}

export default Profile;
