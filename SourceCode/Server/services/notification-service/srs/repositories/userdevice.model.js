const mongoose = require("mongoose");

const userDeviceSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    fcmToken: {
      type: String,
      required: true,
      unique: true,
    },
    deviceType: {
      type: String,
      enum: ["ANDROID", "IOS", "WEB"],
      required: true,
    },
    deviceInfo: {
      model: String,
      osVersion: String,
      appVersion: String,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastUsedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

userDeviceSchema.index({ userId: 1, isActive: 1 });

module.exports = mongoose.model("UserDevice", userDeviceSchema);
