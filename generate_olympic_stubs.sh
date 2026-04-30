#!/bin/bash

SPORTS=(
  "archery" "artistic-gymnastics" "artistic-swimming" "badminton" "baseball" "basketball"
  "basketball-3x3" "beach-volleyball" "bmx" "canoe-kayak" "climbing"
  "coastal-rowing" "cricket" "cycling" "diving" "fencing" "field-hockey"
  "flag-football" "golf" "handball" "judo" "lacrosse" "modern-pentathlon"
  "mountain-bike" "open-water-swimming" "rhythmic-gymnastics" "rugby-sevens"
  "sailing" "shooting" "skateboarding" "soccer" "softball" "squash" "surfing"
  "table-tennis" "taekwondo" "tennis" "track-and-field" "trampoline-gymnastics"
  "triathlon" "volleyball" "water-polo" "weightlifting" "wrestling"
)

for SPORT in "${SPORTS[@]}"; do
  DIR="sport-packs/olympic/$SPORT"
  mkdir -p "$DIR/src"
  
  cat << TOML > "$DIR/Cargo.toml"
[package]
name = "sport-olympic-$SPORT"
version = "0.1.0"
edition = "2021"

[dependencies]
sportcore-kernel = { path = "../../../crates/sportcore-kernel" }
TOML

  cat << RUST > "$DIR/src/lib.rs"
#![no_std]

use sportcore_kernel::{SportAdapter, Session, ValidationResult};

pub struct Config;

pub enum Error {
    InvalidSession,
}

pub enum Event {}
pub enum Segment {}

pub struct Adapter;

impl SportAdapter for Adapter {
    type Config = Config;
    type Error = Error;
    type Event = Event;
    type Segment = Segment;

    fn validate_session(_session: &Session, _config: &Self::Config) -> ValidationResult<Self::Error> {
        Ok(())
    }
}
RUST

done
