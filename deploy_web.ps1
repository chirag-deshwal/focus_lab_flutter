$ErrorActionPreference = "Stop"

echo "Building Flutter Web App..."
flutter build web --release --base-href "/focus_lab_flutter/"

echo "Deploying to GitHub Pages..."
cd build\web

# Initialize a new git repo in the build folder
# (Or re-initialize to be safe)
git init
git add .
git commit -m "Deploy to GitHub Pages"
git branch -M gh-pages

# Add the remote (it might already exist, so ignore error)
try {
    git remote add origin https://github.com/chirag-deshwal/focus_lab_flutter.git
} catch {
    echo "Remote already exists"
}

# Force push to the gh-pages branch
git push -f origin gh-pages

echo "Deployed Successfully!"
echo "Visit: https://chirag-deshwal.github.io/focus_lab_flutter/"
