# Bundle Format

A session bundle is the portable evidence package for an athlete session. It keeps the raw capture context, validated metadata, timing anchors, and assets together so downstream tools can inspect, reproduce, and explain every derived result.

## Layout

The bundle is intentionally boring on disk. Boring is good here: predictable files, explicit checksums, and no hidden state.

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

## Manifest Example

The manifest is the front door. It tells the runtime what should be present before anything more expensive or trust-sensitive begins.

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

## Contract

- Every bundle has a versioned manifest.
- Every asset is counted and checksum-tracked.
- Session, actor, instrument, and anchor data stay separate so validation can report precise failures.
- Malformed or incomplete bundles are rejected explicitly instead of guessed into shape.
