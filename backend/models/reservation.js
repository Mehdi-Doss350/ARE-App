const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const reservationSchema = new Schema(
  {
    user_email: { type: String, required: true },
    material_list: { type: Map, of: Number, required: true },
    start_date: { type: String, required: true, match: /^\d{4}-\d{2}-\d{2}$/ },
    end_date: { type: String, required: true, match: /^\d{4}-\d{2}-\d{2}$/ },
    objective: { type: String, required: true },
    Comment: { type: String, required: false },
    isResponse: { type: Boolean, required: true, default: false },
    admin_response: {
      type: String,
      required: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Reservation", reservationSchema);
