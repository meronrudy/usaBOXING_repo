use sportcore_time::*; use sportcore_units::Micros; #[test] fn interval_valid(){ let i = Interval{ start: Timestamp(Micros(1)), end: Timestamp(Micros(2))}; assert!(i.is_valid()); }
