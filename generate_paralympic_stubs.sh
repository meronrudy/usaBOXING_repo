#!/bin/bash

SPORTS=(
  "blind-soccer" "boccia" "goalball" "para-archery" "para-badminton" "paracanoe"
  "para-climbing" "para-cycling" "para-equestrian" "para-judo" "para-kayak"
  "para-powerlifting" "para-rowing" "para-shooting" "para-swimming"
  "para-table-tennis" "para-taekwondo" "para-track-and-field" "paratriathlon"
  "sitting-volleyball" "wheelchair-basketball" "wheelchair-fencing"
  "wheelchair-rugby" "wheelchair-tennis"
)

for SPORT in "${SPORTS[@]}"; do
  DIR="sport-packs/paralympic/$SPORT"
  mkdir -p "$DIR/src"
  
  cat << TOML > "$DIR/Cargo.toml"
[package]
name = "sport-paralympic-$SPORT"
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
