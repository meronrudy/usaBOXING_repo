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
  cat << RUST > "$DIR/src/lib.rs"
#![no_std]

use sportcore_kernel::{SportAdapter, SessionMeta};

pub struct Config;

pub enum Error {
    InvalidSession,
}

pub enum EventKind {}
pub enum SegmentKind {}

pub struct Adapter;

impl SportAdapter for Adapter {
    type Config = Config;
    type Error = Error;
    type EventKind = EventKind;
    type SegmentKind = SegmentKind;

    fn validate_session(_config: &Self::Config, _session: &SessionMeta) -> Result<(), Self::Error> {
        Ok(())
    }
}
RUST
done

PARA_SPORTS=(
  "blind-soccer" "boccia" "goalball" "para-archery" "para-badminton" "paracanoe"
  "para-climbing" "para-cycling" "para-equestrian" "para-judo" "para-kayak"
  "para-powerlifting" "para-rowing" "para-shooting" "para-swimming"
  "para-table-tennis" "para-taekwondo" "para-track-and-field" "paratriathlon"
  "sitting-volleyball" "wheelchair-basketball" "wheelchair-fencing"
  "wheelchair-rugby" "wheelchair-tennis"
)

for SPORT in "${PARA_SPORTS[@]}"; do
  DIR="sport-packs/paralympic/$SPORT"
  cat << RUST > "$DIR/src/lib.rs"
#![no_std]

use sportcore_kernel::{SportAdapter, SessionMeta};

pub struct Config;

pub enum Error {
    InvalidSession,
}

pub enum EventKind {}
pub enum SegmentKind {}

pub struct Adapter;

impl SportAdapter for Adapter {
    type Config = Config;
    type Error = Error;
    type EventKind = EventKind;
    type SegmentKind = SegmentKind;

    fn validate_session(_config: &Self::Config, _session: &SessionMeta) -> Result<(), Self::Error> {
        Ok(())
    }
}
RUST
done
