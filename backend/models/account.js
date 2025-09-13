const mongoose = require("mongoose");
const Schema = mongoose.Schema;
const bcrypt = require("bcryptjs");

const accountSchema = new Schema(
  {
    imageUrl: { type: String, required: true, default: "null" },
    name: { type: String, required: true },
    classname: { type: String, required: true, default: "II" },
    role: { type: String, required: true, default: "member" },
    phone: { type: String, required: true, default: "XXX-XXXX-XXXX" },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
      select: false,
    },
  },
  { timestamps: true }
);

// Hash password before saving
accountSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Method to compare passwords
accountSchema.methods.correctPassword = async function (
  candidatePassword,
  userPassword
) {
  return await bcrypt.compare(candidatePassword, userPassword);
};

const Account = mongoose.model("Account", accountSchema);
module.exports = Account;
