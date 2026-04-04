use clap::{Parser, Subcommand};
#[derive(Parser)] struct Cli { #[command(subcommand)] command: Command }
#[derive(Subcommand)] enum Command { Validate { path: String }, Inspect { path: String }, Eval { fixture: String } }
fn main() { let cli = Cli::parse(); match cli.command { Command::Validate { path } => println!("validate: {}", path), Command::Inspect { path } => println!("inspect: {}", path), Command::Eval { fixture } => println!("eval: {}", fixture), } }
