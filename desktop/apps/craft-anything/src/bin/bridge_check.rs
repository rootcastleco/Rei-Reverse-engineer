//! Verify the same MCP plugin routes used by the desktop, without target execution.
use craft_anything_engine::{CallOptions, Caller, CancelToken, Consent, Engine, Session, Settings, plugins};
use serde_json::json;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let target = std::env::args().nth(1);
    let mut settings = Settings::load();
    let upstream = settings.plugins.mcp.iter().any(|p| p.id == "upstream_rea" && p.enabled);
    // This diagnostic's optional call inspects only the explicitly supplied file.
    // Normal desktop sessions retain the user's Clean room / Deep selection.
    if target.is_some() {
        settings.deep_mode = true;
    }
    let mut session = Session::new(settings);
    let config = session.config_dir();
    for plugin in session.settings.plugins.mcp.iter().filter(|p| p.enabled) {
        let tools = plugins::refresh(plugin, &config)?;
        println!("{}: {} tools discovered over real MCP", plugin.id, tools.len());
    }
    let routes = plugins::install(&mut session);
    println!("{} external routes registered in desktop engine", routes.len());
    let engine = Engine::shared_with(session, vec![], routes);
    if let Some(path) = target {
        let result = engine.call(
            "rei_rei_rea_inspect",
            json!({"target": &path}),
            CallOptions { caller: Caller::Cli, consent: Consent::Granted, cancel: CancelToken::default(), progress: &|_| {} },
        )?;
        println!("{}", serde_json::to_string_pretty(&result)?);
        if upstream {
            let result = engine.call(
                "upstream_rea_inspect_byte_entropy",
                json!({"path": path}),
                CallOptions { caller: Caller::Cli, consent: Consent::Granted, cancel: CancelToken::default(), progress: &|_| {} },
            )?;
            println!("Upstream static entropy call completed:\n{}", serde_json::to_string_pretty(&result)?);
        }
    }
    Ok(())
}
