#![no_std]
use sportcore_ids::ActorId;
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum ActorKind { Human, Equine, Team, Equipment, Vehicle, Implement }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum BodyRegion { Head, Neck, Torso, Pelvis, Limb(u8), Distal(u8), Custom(u16) }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct Actor { pub actor_id: ActorId, pub kind: ActorKind, pub body_model_ref: u32 }
