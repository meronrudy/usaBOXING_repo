use sportcore_units::ConfidenceBp;
#[test] fn confidence_newtype_works(){ assert_eq!(ConfidenceBp(9000).0, 9000); }
