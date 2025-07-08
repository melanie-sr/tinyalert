import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Home from "./components/Home";
import Disasters from "./components/Disasters";
import Ranking from "./components/Ranking";
import Layout from "./components/layout/Layout";
import Register from "./components/connexion/Register";
import Login from "./components/connexion/Login";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="disasters" element={<Disasters />} />
          <Route path="ranking" element={<Ranking />} />
          <Route path="register" element={<Register />} />
          <Route path="login" element={<Login />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
