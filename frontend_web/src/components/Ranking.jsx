import React from "react";
import { useTranslation } from "react-i18next";

function Disasters() {
  const { t } = useTranslation();

  return (
    <div className="ranking">
      <h1>{t("ranking.title")}</h1>
    </div>
  );
}
export default Disasters;
