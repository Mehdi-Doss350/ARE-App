const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const categorySchema = new Schema({
  name: { type: String, required: true, unique: true },
  image: { type: String, required: true },
  op1: { type: String, required: true },
  op2: { type: String, required: true },
  op3: { type: String, required: true },
  op4: { type: String, required: true },
  op5: { type: String, required: true },
});

const Category = mongoose.model("Category", categorySchema);

module.exports = Category;
