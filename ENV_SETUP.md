# Environment Configuration - Simplified Approach

 **3 separate environment files** that contain all the configuration for each environment:

## 📁 File Structure

```
config/
├── env.dev.json      # Development environment
├── env.stg.json      # Staging environment
└── env.prod.json     # Production environment
```

## 🚀 How to Use

### Development
```bash
flutter run --dart-define-from-file=config/env.dev.json
```

### Staging
```bash
flutter run --dart-define-from-file=config/env.stg.json
```

### Production
```bash
flutter run --dart-define-from-file=config/env.prod.json
```

## 🎯 What Changed

**Before:** You had to specify both the env file AND the ENV variable:
```bash
flutter run --dart-define-from-file=config/env.json --dart-define=ENV=prod
```

**Now:** Just specify which env file to use:
```bash
flutter run --dart-define-from-file=config/env.prod.json
```

## ✅ Benefits

1. **Simpler**: One file = one environment
2. **Clearer**: Each file contains ALL settings for that environment
3. **Safer**: No risk of mixing dev URLs with prod keys
4. **Easier**: Just point to the right file

## 🔧 VS Code Launch Configurations

Updated configurations are ready to use:
- **xpensemate 2 (dev)** → uses `env.dev.json`
- **xpensemate 2 (staging)** → uses `env.stg.json`
- **xpensemate 2 (production)** → uses `env.prod.json`

## 📝 Adding New Variables

Just add to all three env files:

**env.dev.json:**
```json
{
  "BASE_URL": "http://localhost:5001/api/v1",
  "NEW_VARIABLE": "dev_value"
}
```

**env.prod.json:**
```json
{
  "BASE_URL": "https://api.production.com/api/v1",
  "NEW_VARIABLE": "prod_value"
}
```

## 🔒 Security Note

> ⚠️ Add `config/env.prod.json` to `.gitignore` to keep production secrets safe!

```gitignore
# Keep production secrets out of git
config/env.prod.json
```
