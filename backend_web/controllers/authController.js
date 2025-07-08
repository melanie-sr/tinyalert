import User from "../models/user.js";
import bcrypt from "bcrypt";

export async function register(req, res) {
  const { firstName, lastName, email, password } = req.body;

  try {
    const existing = await User.findOne({ email });
    if (existing)
      return res.status(400).json({ message: "Email déjà utilisé" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      firstName,
      lastName,
      email,
      password: hashedPassword,
    });

    res.status(201).json({ message: "Utilisateur créé", userId: user._id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
