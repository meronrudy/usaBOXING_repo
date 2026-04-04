#![no_std]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct Millis(pub u64);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct Micros(pub u64);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct Hertz(pub u32);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct NewtonMilli(pub i32);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct SmO2Bp(pub u16);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct MetersMilli(pub i32);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct DegreesMilli(pub i32);
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct ConfidenceBp(pub u16);
