"""Self-check for rebuild_module.embed: python3 scripts/test_rebuild_module.py"""
from rebuild_module import PAGE, embed

page = PAGE.format(stem="demo")
once = embed(page, "# Demo\n\nBody $x$\n")
assert '<script id="markdown-source" type="text/plain">\n# Demo\n\nBody $x$\n\n  </script>' in once
assert embed(once, "# New\n") == embed(page, "# New\n"), "re-embedding must replace, not append"
assert embed(once, "# Demo\n\nBody $x$\n") == once, "rebuild must be idempotent"
try:
    embed(page, "</script>")
    raise AssertionError("'</script' in Markdown must be rejected")
except ValueError:
    pass
print("ok")
