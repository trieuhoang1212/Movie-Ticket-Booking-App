const mongoose = require("mongoose");

const movieSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Movie title is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Movie description is required"],
    },
    duration: {
      type: Number, // phút
      required: [true, "Movie duration is required"],
    },
    genre: {
      type: [String], // ["Action", "Drama"]
      required: [true, "Movie genre is required"],
    },
    releaseDate: {
      type: Date,
      required: [true, "Release date is required"],
    },
    rating: {
      type: Number,
      min: 0,
      max: 10,
      default: 0,
    },
    posterUrl: {
      type: String,
    },
    trailerUrl: {
      type: String,
    },
    director: {
      type: String,
    },
    cast: {
      type: [String], // ["Actor 1", "Actor 2"]
    },
    language: {
      type: String,
      default: "Vietnamese",
    },
    status: {
      type: String,
      enum: ["now_showing", "coming_soon", "ended"],
      default: "now_showing",
    },
    isHot: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Movie", movieSchema);
