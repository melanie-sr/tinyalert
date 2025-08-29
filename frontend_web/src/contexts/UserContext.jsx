import { createContext, useContext, useState, useEffect } from "react";

const UserContext = createContext();

export function UserProvider({ children }) {
  const [user, setUser] = useState(null);

  const fetchUser = async () => {
    try {
      const res = await fetch(`${import.meta.env.VITE_API_BACKEND}/users/me`, {
        credentials: "include",
      });
      const data = await res.json();

      if (res.ok) setUser(data.user);
    } catch (err) {
      setUser(null);
    }
  };

  useEffect(() => {
    fetchUser();
  }, []);

  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  return useContext(UserContext);
}
