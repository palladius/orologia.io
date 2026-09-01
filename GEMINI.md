do NOT update solutions or create solutions unless explciitly asked!

## Deployment to GitHub Pages

The app is deployed to https://palladius.github.io/orologia.io/ via GitHub Actions.

To deploy, just push to `main` — the workflow `.github/workflows/static.yml` will automatically deploy
the `solutions/20260615-antigravity-managed-agents/` directory to GitHub Pages.

**Important**: All assets (audio files, images, etc.) must live **inside** `solutions/20260615-antigravity-managed-agents/`.
Do NOT use symlinks — GitHub Pages won't resolve them.

## Audio files

Audio files are generated via Edge TTS using `scripts/generate_time_audio.mjs`.
They must be copied into `solutions/20260615-antigravity-managed-agents/assets/audio/<language>/` for serving.

```bash
# Generate audio for a language (run from repo root):
node scripts/generate_time_audio.mjs italian --all

# Copy into solution directory for deployment:
cp -r assets/audio/italian solutions/20260615-antigravity-managed-agents/assets/audio/
```
