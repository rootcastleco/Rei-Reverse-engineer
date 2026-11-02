//! Hosted gateway preset and provider-owned browser sign-in commands.
use crate::{BackendConfig, BackendKind, Detected};
use craft_anything_engine::CancelToken;
use craft_anything_evidence::ToolError;
use craft_anything_platform::Process;
use std::time::Duration;

pub const EXPERIENTIAL_NAME: &str = "Experiential Labs";
pub const EXPERIENTIAL_BASE: &str = "https://api.experientiallabs.ai/v1";
pub const EXPERIENTIAL_KEY: &str = "EXPLABS_API_KEY";

pub fn experiential(key_present: bool) -> Detected {
    Detected {
        suggestion: BackendConfig {
            name: EXPERIENTIAL_NAME.into(),
            kind: BackendKind::OpenaiCompatible,
            model: "qwen3.8-27b".into(),
            base_url: Some(EXPERIENTIAL_BASE.into()),
            ssh_host: None,
            enabled: true,
        },
        reason: "OpenAI-compatible API; choose a model from the live catalog after connecting.".into(),
        needs_key: !key_present,
    }
}

/// Fixed provider commands only; callers cannot supply shell fragments or OAuth URLs.
pub fn login_command(agent: &str) -> Result<(&'static str, &'static [&'static str]), ToolError> {
    match agent {
        "codex" => Ok(("codex", &["login"])),
        "antigravity" => Ok(("agy", &["login"])),
        _ => Err(ToolError::invalid("This agent has no reviewed browser sign-in command.")),
    }
}

/// Credentials remain owned by the official CLI; no output or tokens are retained by REI.
pub fn login(agent: &str, cancel: CancelToken) -> Result<(), ToolError> {
    let (program, args) = login_command(agent)?;
    let process_cancel = cancel.clone();
    let output = Process::new(program)
        .args(args.iter().copied())
        .timeout(Duration::from_secs(300))
        .cancel_when(move || process_cancel.is_cancelled())
        .stdout_cap(4096)
        .stderr_cap(4096)
        .label("provider browser sign-in")
        .run()
        .map_err(|_| {
            if cancel.is_cancelled() {
                ToolError::cancelled()
            } else {
                ToolError::unavailable("Provider sign-in could not finish. Run its official CLI login in a terminal and retry.")
            }
        })?;
    if output.success {
        Ok(())
    } else {
        Err(ToolError::unavailable("Provider sign-in did not complete.")
            .with_remediation("Run the official CLI login in a terminal, finish in your browser, then retry. REI did not retain the login output."))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn gateway_has_separate_credentials_and_real_endpoint() {
        let preset = experiential(false);
        assert_eq!(preset.suggestion.base_url.as_deref(), Some(EXPERIENTIAL_BASE));
        assert_eq!(preset.suggestion.kind, BackendKind::OpenaiCompatible);
        assert!(preset.needs_key);
        assert!(!experiential(true).needs_key);
        assert_eq!(EXPERIENTIAL_KEY, "EXPLABS_API_KEY");
        assert_eq!(crate::keys::env_var_for_backend(EXPERIENTIAL_NAME, BackendKind::OpenaiCompatible), Some(EXPERIENTIAL_KEY));
        assert_eq!(crate::keys::env_var_for_backend("Other gateway", BackendKind::OpenaiCompatible), None);
        assert_eq!(crate::keys::env_var_for_backend(EXPERIENTIAL_NAME, BackendKind::Openai), Some("OPENAI_API_KEY"));
    }
    #[test]
    fn login_is_a_closed_command_contract() {
        assert_eq!(login_command("codex").unwrap(), ("codex", &["login"][..]));
        assert_eq!(login_command("antigravity").unwrap(), ("agy", &["login"][..]));
        assert!(login_command("codex; echo unsafe").is_err());
        assert!(login_command("https://unknown.example").is_err());
    }
}
