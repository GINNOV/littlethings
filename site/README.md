# Littlethings Site

This directory contains the Hugo source for the public Amiga project site.

## Structure

- `content/`: Markdown pages and tutorial articles.
- `layouts/`: Hugo templates and reusable partials.
- `static/`: Images, stylesheets, scripts, and downloadable site assets.
- `hugo.toml`: Site configuration.
- `public/`: Local build output, ignored by Git.

## Local development

From the repository root:

```sh
hugo server --source site
```

To create a production build locally:

```sh
hugo --source site --destination site/public --cleanDestinationDir
```

GitHub Pages is configured to serve the separate `gh-pages` branch. The `Publish Hugo site` workflow builds this directory whenever `master` changes and updates that branch with the generated output.
