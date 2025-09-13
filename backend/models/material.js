const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const materialSchema = new Schema({
  name: { type: String, required: true, unique: true },
  image: { type: String, required: true },
  type: { type: String, required: true },
  quantity: { type: Number, required: true, min: 0 },
  detail: { type: String, required: true },
  op1: { type: String, required: true },
  op2: { type: String, required: true },
  op3: { type: String, required: true },
  op4: { type: String, required: true },
  op5: { type: String, required: true },
  category: { type: String, required: true },
});

module.exports = mongoose.model("Material", materialSchema);
