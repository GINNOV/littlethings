# Reference URL Verification & Production Source of Truth

When the user provides a reference URL (e.g. `https://ginnov.github.io/`, `https://ginnov.github.io/Ultimate-Chrome-Bookmarks/`, or any external site/doc):

1. **Always Fetch the Live URL First**:
   - MUST fetch the live page immediately using `read_url_content` or `curl -sL <url>` BEFORE making any edits, making assumptions, or touching local files.
   - Never assume local workspace files or layout templates match what is live/published in production.

2. **Inspect the Full Source & Styles**:
   - Read and parse the exact live HTML structure, container hierarchies, class names, Tailwind configuration, inline styles, and external fonts.
   - Do not rely on partial reconstruction or fragments when the complete source of truth is directly accessible via URL.

3. **Prevent Template / CSS Collision**:
   - When replicating a published standalone page or adding components to it, verify whether it uses an inherited layout wrapper (like Hugo `baseof.html` or legacy stylesheets like `style.css`).
   - If the live page is a standalone document, ensure it is rendered as standalone without inheriting unwanted global CSS background/padding/font overrides.

4. **Verify Visual Fidelity**:
   - Re-check the rendered output against the live reference to confirm that typography, colors, layout flow, and spacing match 1:1.
