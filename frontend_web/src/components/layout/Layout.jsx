import { Outlet } from "react-router-dom";
import NavBar from "./Navbar";
import Footer from "./Footer";

function Layout() {
  return (
    <>
      <header>
        <NavBar />
      </header>

      <main>
        <Outlet />
      </main>

      <footer>
        <Footer />
      </footer>
    </>
  );
}

export default Layout;
