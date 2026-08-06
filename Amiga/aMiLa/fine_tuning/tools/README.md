# fine_tuning/tools

| Script | Purpose |
|--------|---------|
| `minimal_sealed_asm.py` | First-shot ASM generate + vasm `-Fhunkexe` scoreboard |
| `fixtures/` | Sealed benchmark + target-gate configs |

```bash
cd aMiLa/fine_tuning
uv run python tools/minimal_sealed_asm.py \
  --adapter runtime/adapter \
  --output-dir /tmp/asm-score \
  --limit 0 --compile-backend both
```
