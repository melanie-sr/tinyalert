import i18n from "i18next";
import { useTranslation, initReactI18next } from "react-i18next";
import frJSON from "./locale/fr.json";
import enJSON from "./locale/en.json";
i18n.use(initReactI18next).init({
  resources: {
    fr: { ...frJSON },
    en: { ...enJSON },
  },
  lng: "fr",
});
