#![no_std]
use sportcore_ids::{ActorId, EventId, SegmentId, SessionId};
use sportcore_time::{Interval, Timestamp};
use sportcore_units::ConfidenceBp;
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct SessionMeta { pub session_id: SessionId, pub sport_code: u16, pub discipline_code: u16, pub actor_count: u16 }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum GenericSegmentKind { Warmup, ActiveBlock, RestBlock, Trial, Rep, Round, Unknown }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct Segment { pub segment_id: SegmentId, pub kind: GenericSegmentKind, pub interval: Interval, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum GenericEventKind { Start, Stop, Contact, LiftOff, Landing, PhaseChange, Annotation, Unknown }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct Event { pub event_id: EventId, pub kind: GenericEventKind, pub ts: Timestamp, pub primary_actor: ActorId, pub confidence: ConfidenceBp }
