import json
from pathlib import Path
import tempfile
import unittest
from rei_rea import desktop_bridge

from rei_rea.desktop_bridge import prepare
from rei_rea.mcp import TOOLS


class DesktopBridgeTests(unittest.TestCase):
    def test_mcp_effect_annotations_preserve_case_write_boundary(self):
        for tool in TOOLS:
            self.assertFalse(tool['annotations']['openWorldHint'])
            self.assertEqual(tool['annotations']['readOnlyHint'], tool['name'] != 'rei_rea_case_create')

    def test_python_schemas_and_user_settings_are_preserved(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            result = prepare(root, root/'config')
            self.assertTrue(result['settings_created'])
            self.assertEqual(json.loads((root/'config/plugins/rei.tools.json').read_text()), TOOLS)
            settings = root/'config/config.toml'
            settings.write_text('language = "tr"\n', encoding='utf-8')
            self.assertFalse(prepare(root, root/'config')['settings_created'])
            self.assertEqual(settings.read_text(), 'language = "tr"\n')

    def test_missing_upstream_is_not_advertised(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.assertFalse(prepare(root, root/'config')['upstream_runtime_available'])
            self.assertNotIn('upstream_rea', (root/'config/config.toml').read_text())

    def test_ready_upstream_is_configured_with_compact_schemas(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            node = root/'node.exe'
            node.write_bytes(b'not executed')
            runtime = root/'upstream/rea/dist/mcp/main.js'
            runtime.parent.mkdir(parents=True)
            runtime.write_text('// fixture')
            result = prepare(root, root/'config', node=node)
            self.assertTrue(result['upstream_runtime_available'])
            settings = (root/'config/config.toml').read_text()
            self.assertEqual(settings.count('id = "upstream_rea"'), 1)
            self.assertIn('REA_MCP_OUTPUT_SCHEMA_PROFILE = "compact"', settings)
            prepare(root, root/'config', node=node)
            self.assertEqual((root/'config/config.toml').read_text(), settings)

    @unittest.skipIf(desktop_bridge.tomllib is None, 'Existing TOML merge requires Python 3.11+')
    def test_newly_available_upstream_is_added_without_replacing_preferences(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            prepare(root, root/'config')
            settings = root/'config/config.toml'
            original = settings.read_text().replace('language = "en"', 'language = "fr"')
            settings.write_text(original, encoding='utf-8')
            node = root/'node.exe'
            node.write_bytes(b'not executed')
            runtime = root/'upstream/rea/dist/mcp/main.js'
            runtime.parent.mkdir(parents=True)
            runtime.write_text('// fixture')
            prepare(root, root/'config', node=node)
            result = desktop_bridge.tomllib.loads(settings.read_text())
            self.assertEqual(result['language'], 'fr')
            self.assertEqual([p['id'] for p in result['plugins']['mcp']], ['rei', 'upstream_rea'])
            self.assertEqual((root/'config/config.before-upstream.toml').read_text(), original)
