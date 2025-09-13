require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const multer = require("multer");
const path = require("path");

// Import models
const Category = require("./models/category");
const User = require("./models/account");
const Material = require("./models/material");
const Account = require("./models/account");
const Reservation = require("./models/reservation");

// Initialize Express app
const app = express();

// Middleware setup
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// Database connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("MongoDB connection error:", err));

// File upload configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, `${Date.now()}${path.extname(file.originalname)}`),
});
const upload = multer({ storage });

// Helper function for error handling
const handleErrors = (res, error, statusCode = 400) => {
  console.error(error);
  res.status(statusCode).json({ error: error.message });
};

// Routes
app.get("/", (req, res) => res.send("Backend is running"));

// User routes (unchanged)
app.get("/api/users", async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

app.post("/api/users", async (req, res) => {
  try {
    const newUser = new User(req.body);
    await newUser.save();
    res.status(201).json(newUser);
  } catch (err) {
    handleErrors(res, err);
  }
});

app.put("/api/users/:id", async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { email: req.body.email },
      { new: true }
    );
    if (!updatedUser) return res.status(404).json({ error: "User not found" });
    res.json(updatedUser);
  } catch (err) {
    handleErrors(res, err);
  }
});

app.delete("/api/users", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOneAndDelete({ email });
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json({ message: "Account deleted successfully", deletedEmail: email });
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

// Authentication routes (unchanged)
app.post("/api/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email }).select("+password");

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    res.json({
      message: "Login successful",
      user: { email: user.email },
    });
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

// Category routes
const multerCategoryStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const uploadCategory = multer({ storage: multerCategoryStorage });

app.post(
  "/api/categories",
  uploadCategory.single("image"),
  async (req, res) => {
    try {
      const { name, op1, op2, op3, op4, op5 } = req.body;
      const image = req.file ? req.file.path : "";

      // Check if category name already exists
      const existing = await Category.findOne({ name });
      if (existing) {
        return res.status(409).json({ error: "Category name already exists" });
      }

      const category = new Category({
        name,
        image,
        op1,
        op2,
        op3,
        op4,
        op5,
      });

      await category.save();
      res.status(201).json(category);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

app.get("/api/categories", async (req, res) => {
  try {
    const categories = await Category.find();
    res.json(categories);
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

app.delete("/api/categories", async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Category name is required" });
    }
    const deletedCategory = await Category.findOneAndDelete({ name });
    if (!deletedCategory) {
      return res.status(404).json({ error: "Category not found" });
    }
    res.json({ message: "Category deleted successfully", deletedName: name });
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

// Materials routes
app.get("/api/materials", async (req, res) => {
  try {
    const { category } = req.query;
    let materials;
    if (category) {
      materials = await Material.find({ category });
    } else {
      materials = await Material.find();
    }
    res.json(materials);
  } catch (err) {
    handleErrors(res, err, 500);
  }
});

// POST /api/materials
app.post("/api/materials", upload.single("image"), async (req, res) => {
  try {
    const { name, type, quantity, detail, op1, op2, op3, op4, op5, category } =
      req.body;
    const image = req.file ? req.file.path : "";

    const existing = await Material.findOne({ name });
    if (existing) {
      return res.status(409).json({ error: "Material name already exists" });
    }

    const material = new Material({
      name,
      image,
      type,
      quantity,
      detail,
      op1,
      op2,
      op3,
      op4,
      op5,
      category,
    });

    await material.save();
    res.status(201).json(material);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/materials", async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Material name is required" });
    }
    const deletedMaterial = await Material.findOneAndDelete({ name });
    if (!deletedMaterial) {
      return res.status(404).json({ error: "Material not found" });
    }
    res.json({ message: "Material deleted successfully", deletedName: name });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/accounts", async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) return res.status(400).json({ error: "Email is required" });
    const user = await Account.findOne({ email }).select("-password");
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const uploadAccount = multer({ storage });

app.patch(
  "/api/accounts/upload-photo",
  uploadAccount.single("image"),
  async (req, res) => {
    try {
      const { email } = req.body;
      if (!req.file || !email)
        return res.status(400).json({ error: "Missing file or email" });

      const imageUrl = req.file.path;
      const updated = await Account.findOneAndUpdate(
        { email },
        { imageUrl },
        { new: true }
      );

      if (!updated) {
        return res.status(404).json({ error: "User not found" });
      }
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

app.patch("/api/accounts/update", async (req, res) => {
  try {
    const { email, classname, phone } = req.body;
    const updated = await Account.findOneAndUpdate(
      { email },
      { classname, phone },
      { new: true }
    );
    if (!updated) return res.status(404).json({ error: "User not found" });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Reservation routes
app.get("/api/reservations", async (req, res) => {
  try {
    const { email } = req.query;
    let query = {};

    if (email === "admin123@gmail.com") {
      query = {};
    } else {
      query = { user_email: email, isResponse: true };
    }

    const reservations = await Reservation.find(query);
    res.json(reservations);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/reservations/:id
app.put("/api/reservations/:id", async (req, res) => {
  try {
    const updatedReservation = await Reservation.findByIdAndUpdate(
      req.params.id,
      {
        $set: {
          status: req.body.status,
          admin_response: req.body.admin_response,
          isResponse: req.body.isResponse,
        },
      },
      { new: true }
    );
    res.json(updatedReservation);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});
app.post("/api/reservations", async (req, res) => {
  try {
    const {
      user_email,
      material_list,
      start_date,
      end_date,
      objective,
      Comment,
    } = req.body;

    // 1. Reduce material quantities
    for (const [materialName, q] of Object.entries(material_list)) {
      await Material.findOneAndUpdate(
        { name: materialName },
        { $inc: { quantity: -q } }
      );
    }

    // 2. Create reservation (now allows duplicate start dates)
    const newReservation = new Reservation({
      user_email,
      material_list: new Map(Object.entries(material_list)),
      start_date: req.body.start_date,
      end_date: req.body.end_date,
      objective,
      Comment: Comment || null,
    });

    await newReservation.save();
    res.status(201).json(newReservation);
  } catch (err) {
    handleErrors(res, err);
  }
});
// Test endpoint
app.get("/api/test", (req, res) => {
  res.json({
    status: "success",
    message: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
