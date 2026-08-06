# Amiga Tutorial Review Guidelines

Whenever creating, editing, or reviewing Amiga tutorial articles (such as those in `content/amiga/tutorials/`), strictly adhere to the following rules:

## 1. Tooling & Primary Target
- **Primary Target**: Focus on 68k Assembly cross-compiling.
- **Featured Tool**: The primary workflow section MUST be titled `### How to Run in Amiga Playground` and detail steps for running in the browser-based Amiga Playground (`../index.html#amiga-playground`).
- **Secondary Workflow**: The secondary section MUST be titled `### How to Compile and Run with vasm (Terminal & Emulator)` for desktop `vasm` + FS-UAE/vAmiga users.
- **No Unsupported Languages**: Do NOT include AMOS, BASIC, C, or other non-assembly code blocks unless the tutorial explicitly targets that language (e.g., `sound_c.md`). If Amiga Playground does not support the language, remove it.

## 2. Code Block Formatting
- **Clean Markdown Blocks**: Use standard Markdown code block syntax (` ```assembly `). NEVER use raw HTML wrappers (`<div class="code-block-wrapper"><pre><code>`).
- **No File Name in Heading**: The code section heading MUST be titled exactly: `### The Complete Code:`. Do NOT put the file name in the H3 heading.
- **File Name Inside Code Comment**: Place the source file name inside the top comment block of the code snippet itself:
  ```assembly
  ;-----------------------------------------------------
  ; filename.asm
  ; Description...
  ;-----------------------------------------------------
  ```
- **No Unnecessary Blank Lines**: Keep empty lines within assembly snippets minimal and intentional.
- **Assembly Memory Allocation**: Code intended for direct hardware access MUST include `SECTION Code,CODE_C` (or equivalent Chip RAM allocation) so Copper, Sprites, or Audio DMA can access memory.

## 3. Heading & Structural Hierarchy
- Use `##` (H2) for main document sections (Concept, Code Section, How to Run, Examples).
- Use `###` (H3) for sub-sections/step headings.
- Avoid `####` (H4) headers unless strictly required.
- Keep heading titles concise and direct (e.g., `## What is the Copper?`).

## 4. Assets & Hyperlink Integrity
- **Local Images Only**: All embedded images MUST use local relative paths under `images/` (e.g., `images/my_image.jpg`).
- **Static Assets Location**: Physical image files MUST exist inside `static/amiga/tutorials/images/`. NEVER rely on external URLs.
- **No Broken Links**: Verify all hyperlinked `.html` pages or section anchors actually exist within the project repository.
