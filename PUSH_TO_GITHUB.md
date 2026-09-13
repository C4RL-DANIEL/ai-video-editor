# Push to GitHub — Quick Guide

## Option A: Using GitHub CLI (Fastest)

### 1. Install GitHub CLI (if not installed)
```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux
sudo apt install gh
```

### 2. Login to GitHub
```bash
gh auth login
```

### 3. Create Repo & Push (One Command)
```bash
cd /root/Projects/App
gh repo create ai-video-editor --public --source=. --remote=origin --push
```

Done! The GitHub Actions workflow will automatically build your app.

---

## Option B: Using Git (Manual)

### 1. Create a Repository on GitHub
1. Go to https://github.com/new
2. Name: `ai-video-editor`
3. **Don't** initialize with README (we already have one)
4. Click **Create repository**
5. Copy the URL (e.g., `https://github.com/YOUR_USERNAME/ai-video-editor.git`)

### 2. Push from Terminal
```bash
cd /root/Projects/App

# Add the remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/ai-video-editor.git

# Push to GitHub
git push -u origin main
```

---

## After Pushing

### Check the Build
1. Go to your repo on GitHub
2. Click **Actions** tab
3. You should see the build running
4. Wait 5-10 minutes for it to complete
5. Download the APK from **Artifacts** section

### Download the APK
1. Go to **Actions** → click the latest workflow run
2. Scroll down to **Artifacts**
3. Click **android-apk** to download
4. Extract and install on your Android device

---

## First Launch Setup

1. Install the APK on your phone
2. Open the app
3. Go to https://cloud.appwrite.io and create a free account
4. Create a project and copy the **Project ID**
5. Open `lib/config/appwrite_config.dart` in the code
6. Replace `defaultValue: ''` with your Project ID
7. Push the change:
   ```bash
   git add .
   git commit -m "feat: add Appwrite project ID"
   git push
   ```
8. The new build will auto-create all collections!

---

## Need Help?

If you get stuck, tell me:
1. What error you see
2. Which step you're on
3. Your operating system (macOS/Windows/Linux)
