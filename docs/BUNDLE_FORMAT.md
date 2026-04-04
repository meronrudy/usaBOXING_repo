# BUNDLE_FORMAT

## Layout
```text
SessionBundle/
  manifest.json
  session.json
  actors.json
  instruments.json
  anchors.json
  assets/
    video_main.mov
```

## Manifest example
```json
{
  "bundle_version": "1",
  "session_id": "sess_001",
  "asset_count": 1,
  "checksums": {
    "assets/video_main.mov": "sha256:..."
  }
}
```
