# Changelog

All notable changes to PixDeluxe are documented here.

## 1.0 (Build 111) - 2026-07-28

### Added

- Batch PNG and JPEG conversion to Amiga IFF/ILBM.
- Shared 1–8 bitplane selection for a conversion batch.
- Progress reporting with current filename, completed count, and cancellation.
- Collision-safe output naming that preserves existing files.
- Per-file success and failure summaries.
- Automated coverage for PNG/JPEG conversion, bitplane boundaries, batch conversion, collisions, partial failures, and cancellation.

### Changed

- Lowered the minimum supported operating system to macOS Sonoma 14.0. ([user request]([https://www.reddit.com/r/amiga/comments/1lvmi77/comment/ozill9p/?%24deep_link=true&context=1&correlation_id=7f87aa1c-523e-4bc6-b1ce-c3ef50cba189&ref=email_comment_reply&ref_campaign=email_comment_reply&ref_source=email&target_user=Improvement-Classic&%243p=e_as&_branch_match_id=1597521971339714550&utm_medium=Email+Amazon+SES&_branch_referrer=H4sIAAAAAAAAA32Q3W7CMAyFn6bcFdYGKCChaWKatKeI3NQt1vInJ23ZLvbscze4nZTIzsn5bCfXnGM6bTaMXUd5DTGuLfmPjYrPRb1V8Ywa0krSwDSQB6tHtufrQhXqpajfZM3zvL7zJjgRWDY4GkCiKA59TpJWdnLUNJJFunVoxxtq6nvdcpgTsp4IZwngO22Cn5AzLpXCF1l7jEsvJe129bZDjHoZs1CvmUcs6r0AGW9ZhOr3xIwWMgWvqROx6Q8NQGXKXa2w3LZmX7aVwdIo7HdPpoXqcBSOsRczOiCr74Nrxmg%2F%2F%2B60AReBBv%2BvKYWRDT4sImbgAbMe5Y2ivrvIYcIFKy8WUiKz%2BhYOmckPj884X64cHP4AobePyp8BAAA%3D]).
- Made palette sampling deterministic.
- Made temporary conversion paths unique.

### Fixed

- Corrected generated ILBM BODY data to use scanline-interleaved bitplanes.
- Corrected ILBM row padding to use the required 16-bit alignment.
- Ensured generated IFF files can be opened by PixDeluxe after conversion.
