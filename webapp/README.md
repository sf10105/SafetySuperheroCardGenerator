# Safety Superhero Card Web App

This is a static browser version of the Safety Superhero Card generator. It does not need a backend or a build step, so it can be hosted on GitHub Pages, Cloudflare Pages, Netlify, or any static web host.

The web version does not collect or include photos. It renders the selected frame, name, role, qualification icons, and qualification text, leaving the photo area empty in the exported PNG.

## Run Locally

From the repository root:

```sh
cd webapp
python3 -m http.server 5173
```

Then open:

```text
http://localhost:5173
```

## Deploy To GitHub Pages

This repo includes a GitHub Actions workflow at `.github/workflows/deploy-webapp.yml`. Once the repo is pushed to GitHub, enable Pages using GitHub Actions as the source. Pushes to the default branch will publish the contents of this `webapp` folder.

## Asset Notes

The frame and icon PNGs were copied from the SwiftUI app's `.xcassets` folder. If those source assets change, copy the updated PNGs into `webapp/assets`.
