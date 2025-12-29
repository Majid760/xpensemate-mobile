# Android Studio / IntelliJ IDEA Setup for Environment Variables

Follow these step-by-step instructions to configure `--dart-define-from-file` in Android Studio or IntelliJ IDEA.

## Method 1: Edit Existing Run Configuration (Recommended)

### Step 1: Open Run Configuration
1. Click on the **run configuration dropdown** at the top toolbar (next to the run/debug buttons)
2. Select **"Edit Configurations..."**

   ![Location: Top toolbar, left of the green play button]

### Step 2: Select Your Flutter Configuration
1. In the left panel, expand **"Flutter"**
2. Select your main run configuration (usually named after your project, e.g., "main.dart")

### Step 3: Add Additional Run Args
1. Find the **"Additional run args"** field
2. Add one of the following based on your environment:

   **For Development:**
   ```
   --dart-define-from-file=config/env.dev.json
   ```

   **For Staging:**
   ```
   --dart-define-from-file=config/env.stg.json
   ```

   **For Production:**
   ```
   --dart-define-from-file=config/env.prod.json
   ```

### Step 4: Apply and Save
1. Click **"Apply"**
2. Click **"OK"**

### Step 5: Run Your App
- Click the green **play button** or press **Shift + F10** (Windows/Linux) or **Control + R** (Mac)
- Your app will now run with the environment variables loaded!

---

## Method 2: Create Multiple Run Configurations (Best Practice)

This allows you to easily switch between environments.

### Step 1: Open Run Configuration
1. Click on the run configuration dropdown
2. Select **"Edit Configurations..."**

### Step 2: Duplicate Your Configuration
1. Select your existing Flutter configuration
2. Right-click and select **"Copy Configuration"** or click the **"Copy"** icon (two overlapping rectangles)
3. Repeat this 2 more times to create 3 total configurations

### Step 3: Configure Development Environment
1. Select the first configuration
2. Rename it to: **"Flutter (Development)"**
3. In **"Additional run args"**, add:
   ```
   --dart-define-from-file=config/env.dev.json
   ```
4. Click **"Apply"**

### Step 4: Configure Staging Environment
1. Select the second configuration
2. Rename it to: **"Flutter (Staging)"**
3. In **"Additional run args"**, add:
   ```
   --dart-define-from-file=config/env.stg.json
   ```
4. Click **"Apply"**

### Step 5: Configure Production Environment
1. Select the third configuration
2. Rename it to: **"Flutter (Production)"**
3. In **"Additional run args"**, add:
   ```
   --dart-define-from-file=config/env.prod.json
   ```
4. Click **"Apply"**

### Step 6: Save and Use
1. Click **"OK"** to close the dialog
2. Now you can easily switch environments using the dropdown:
   - Select **"Flutter (Development)"** → runs with dev settings
   - Select **"Flutter (Staging)"** → runs with staging settings
   - Select **"Flutter (Production)"** → runs with production settings

---

## Method 3: Using Build Variants (Advanced)

### Step 1: Create Build Configuration
1. Go to **Run → Edit Configurations...**
2. Click the **"+"** button
3. Select **"Flutter"**

### Step 2: Configure Each Variant
For each environment (dev, staging, prod):
1. Set **Name**: e.g., "main.dart (dev)"
2. Set **Dart entrypoint**: `lib/main.dart`
3. Set **Additional run args**: `--dart-define-from-file=config/env.dev.json`
4. Set **Build flavor** (optional): `dev`, `staging`, or `production`

---

## Verification

### Test Your Configuration
1. Select your run configuration from the dropdown
2. Click the **run button**
3. Check the **Run** tab at the bottom
4. You should see output like:
   ```
   Launching lib/main.dart on iPhone 15 in debug mode...
   Running with additional args: --dart-define-from-file=config/env.dev.json
   ```

### Verify Environment Variables Are Loaded
Add a temporary debug print in your `network_configs.dart`:
```dart
static void printConfig() {
  print('🌍 Base URL: $baseUrl');
  print('🔑 API Key: $apiKey');
}
```

Call it in `main.dart`:
```dart
void main() async {
  NetworkConfigs.printConfig(); // Add this line
  // ... rest of your code
}
```

Run the app and check the console output.

---

## Troubleshooting

### Issue: "Additional run args" field is grayed out
**Solution:** Make sure you've selected a Flutter configuration, not a Dart configuration.

### Issue: Environment variables not loading
**Solution:** 
1. Check that the path is correct: `config/env.dev.json` (relative to project root)
2. Ensure the JSON file exists and is valid
3. Try using an absolute path: `/Users/majid/Desktop/xpensemate 2/config/env.dev.json`

### Issue: Configuration not saving
**Solution:** Click "Apply" before clicking "OK"

### Issue: Can't find "Additional run args"
**Solution:** 
1. Make sure you're using Android Studio Arctic Fox or later
2. Update your Flutter plugin to the latest version
3. The field might be collapsed - look for a "Show more" or expand arrow

---

## Quick Reference

| Environment | Command to Add |
|-------------|----------------|
| Development | `--dart-define-from-file=config/env.dev.json` |
| Staging | `--dart-define-from-file=config/env.stg.json` |
| Production | `--dart-define-from-file=config/env.prod.json` |

---

## Screenshots Guide

If you need visual help, the key locations are:

1. **Run Configuration Dropdown**: Top toolbar, left side, shows current configuration name
2. **Edit Configurations**: Click dropdown → "Edit Configurations..."
3. **Additional run args**: In the configuration dialog, middle section
4. **Apply/OK buttons**: Bottom right of the dialog

---

## Next Steps

After setup:
1. ✅ Create configurations for all environments
2. ✅ Test each configuration
3. ✅ Set development as default
4. ✅ Share configurations with team (optional - see below)

### Sharing Configurations with Team (Optional)

To share run configurations with your team:
1. Go to **Run → Edit Configurations...**
2. Select your configuration
3. Check **"Share through VCS"**
4. Configurations will be saved in `.idea/runConfigurations/`
5. Commit these files to git

---

**You're all set!** 🎉 You can now easily switch between environments in Android Studio.
