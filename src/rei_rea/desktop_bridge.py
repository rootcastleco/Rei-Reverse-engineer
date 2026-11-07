"""Configure the local desktop's MCP bridges without executing target artifacts."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
try:
    import tomllib
except ImportError:  # Python 3.10: create new profiles, preserve existing TOML verbatim.
    tomllib = None

from .mcp import TOOLS


def prepare(workspace: Path, config: Path, *, node: Path | None = None) -> dict:
    workspace = workspace.resolve(strict=True)
    config = config.resolve()
    config.mkdir(parents=True, exist_ok=True)
    plugins = config / 'plugins'
    plugins.mkdir(exist_ok=True)
    # The desktop reads these schemas at startup; calls still reach the real MCP server.
    (plugins / 'rei.tools.json').write_text(json.dumps(TOOLS, indent=2), encoding='utf-8')
    quoted = lambda text: json.dumps(str(text), ensure_ascii=False)
    content = (
        'first_run_done = true\nlanguage = "en"\nmode = "experienced"\n'
        'projects_dir = "Projects"\n\n'
        '[[plugins.mcp]]\nid = "rei"\nname = "REI Python Workbench"\n'
        f'command = {quoted(sys.executable)}\nargs = ["-m", "rei_rea", "mcp"]\n'
        f'cwd = {quoted(workspace)}\n'
        f'env = {{ PYTHONPATH = {quoted(workspace / "src")}, PYTHONUTF8 = "1" }}\n'
        'enabled = true\nconsent = true\n'
    )
    upstream = workspace / 'upstream' / 'rea'
    upstream_ready = bool(node and node.is_file() and (upstream / 'dist/mcp/main.js').is_file())
    upstream_section = ''
    if upstream_ready:
        upstream_section = (
            '\n[[plugins.mcp]]\nid = "upstream_rea"\nname = "Upstream REA"\n'
            f'command = {quoted(node.resolve())}\n'
            f'args = [{quoted(upstream / "scripts/rea.mjs")}, "mcp"]\n'
            'env = { REA_MCP_OUTPUT_SCHEMA_PROFILE = "compact" }\n'
            f'cwd = {quoted(upstream)}\nenabled = true\nconsent = true\n'
        )
        content += upstream_section
    settings = config / 'config.toml'
    created = False
    try:
        with settings.open('x', encoding='utf-8') as stream:
            stream.write(content)
        created = True
    except FileExistsError:
        # Add a newly available engine without replacing settings edited in the UI.
        if upstream_ready and tomllib is not None:
            old = settings.read_text(encoding='utf-8')
            parsed = tomllib.loads(old)
            configured = parsed.get('plugins', {}).get('mcp', [])
            if not any(p.get('id') == 'upstream_rea' for p in configured):
                backup = config / 'config.before-upstream.toml'
                if not backup.exists():
                    backup.write_text(old, encoding='utf-8')
                settings.write_text(old + upstream_section, encoding='utf-8')
    return {'config': str(config), 'settings_created': created,
            'python_tools': len(TOOLS), 'upstream_runtime_available': upstream_ready,
            'note': 'Existing settings preserved; upstream tool discovery requires Plugins refresh.'}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, required=True)
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--node', type=Path)
    args = parser.parse_args()
    print(json.dumps(prepare(args.workspace, args.config, node=args.node), indent=2))


if __name__ == '__main__':
    main()
