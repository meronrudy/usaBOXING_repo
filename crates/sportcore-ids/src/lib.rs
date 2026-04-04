#![no_std]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct SessionId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct ActorId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct InstrumentId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct StreamId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct EventId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct SegmentId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct FeatureId(pub u128);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct PredictionId(pub u128);

// Stable code types for registry-backed identifiers
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct SportCode(pub u16);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct DisciplineCode(pub u16);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct StreamSchemaId(pub u16);
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct FeatureCode(pub u16);
