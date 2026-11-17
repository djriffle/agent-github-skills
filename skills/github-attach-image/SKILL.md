---
name: github-attach-image
description: Upload and embed an image in a GitHub issue, pull request, or comment without committing it to the repository. Use when asked to attach, add, post, or embed a screenshot, diagram, plot, or other image in a GitHub issue/PR body or comment.
---

# GitHub Attach Image

Embed an image in a GitHub issue, PR, or comment by uploading it to GitHub's own attachment store (`user-attachments/assets`) and referencing the returned URL in markdown. The image stays out of the repository and remains access-controlled to the repo.

## Prefer the built-in flag when available

Recent `gh` releases add `--attach` to `gh issue comment`, `gh pr comment`, `gh issue create`, and `gh pr create`. Check first:

```bash
gh issue comment --help | grep -i attach
```

If present, use it and skip the endpoint below:

```bash
gh issue comment <number> --repo OWNER/REPO --body-file body.md --attach /path/to/image.png
```

## Fallback: upload via the user-attachments endpoint

`gh` <= 2.97 has no attachment support. Upload directly:

```bash
REPO=OWNER/REPO
FILE=/path/to/image.png
TOKEN=$(gh auth token)
REPO_ID=$(gh api "repos/$REPO" --jq .id)
MIME=$(file --mime-type -b "$FILE")
URL=$(curl -s "https://uploads.github.com/user-attachments/assets?name=$(basename "$FILE")&content_type=$MIME&repository_id=$REPO_ID" \
  -X POST -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" \
  --data-binary "@$FILE" | jq -r .url)
```

The response is JSON like `{"url":"https://github.com/user-attachments/assets/<uuid>"}`. Embed it:

```bash
gh issue comment <number> --repo "$REPO" --body "![caption]($URL)"
gh pr comment <number> --repo "$REPO" --body "![caption]($URL)"
```

## Constraints and gotchas

- Send `--data-binary @FILE`; `-d`/`--data` corrupt binary data.
- `repository_id` is the repo's numeric database id, not `OWNER/REPO` or the GraphQL node id. Fetch it with `gh api repos/$REPO --jq .id`.
- Set `content_type` to the real MIME type (`image/png`, `image/jpeg`, `image/gif`, ...) and include the extension in `name` so GitHub serves and renders it correctly.
- The endpoint is undocumented and can change; it requires a Bearer token and works with `gh auth token`.
- Uploaded assets are access-controlled to the repo: they render for anyone with repo access but return 404 to anonymous requests. Do not validate with an unauthenticated `curl`.
- Do not fall back to a third-party image host for private-repo content; that leaks it. Keep attachments on GitHub.
- Upload once and reuse the URL in any issue, PR, comment, or markdown; no per-reference re-upload.
- For multi-line bodies, write the body to a file and pass `--body-file` rather than embedding newlines in `--body`.
- Confirm the reference landed with `gh api repos/$REPO/issues/comments/<id> --jq .body`.
