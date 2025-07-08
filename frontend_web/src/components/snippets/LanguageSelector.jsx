import { useState } from "react";
import { useTranslation } from "react-i18next";
import FlagFr from "/images/flags/flag_fr.png";
import FlagEn from "/images/flags/flag_en.png";
import "./languageSelector.css";

const languages = {
  fr: { label: "Français", flag: FlagFr },
  en: { label: "English", flag: FlagEn },
};

function LanguageSelector() {
  const {
    i18n: { changeLanguage, language },
  } = useTranslation();
  const [showLangMenu, setShowLangMenu] = useState(false);

  const handleChangeLanguage = (lang) => {
    changeLanguage(lang);
    setShowLangMenu(false);
  };

  return (
    <div className="language-selector">
      <button
        onClick={() => setShowLangMenu((prev) => !prev)}
        className="language-toggle"
      >
        <img
          src={languages[language].flag}
          alt={language}
          className="language-flag"
        />
      </button>

      {showLangMenu && (
        <div className="language-dropdown">
          {Object.entries(languages).map(([langCode, { label, flag }]) => (
            <button
              key={langCode}
              onClick={() => handleChangeLanguage(langCode)}
              className="language-option"
            >
              <img src={flag} alt={label} className="language-option-flag" />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default LanguageSelector;
