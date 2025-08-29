import "./disastersContent.css";
import BannerEarthquake from "/images/disasters/earthquake/earthquake_banner.png";

function Earthquake() {
  return (
    <div className="hero-banner">
      <img src={BannerEarthquake} alt="Banner" className="img-banner" />;
    </div>
  );
}

export default Earthquake;
