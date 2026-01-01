# Quick Start Guide

## 🚀 First Time Setup

```bash
cd app/api-node

# Install all dependencies (including new dev tools)
npm install

# Initialize Husky (for pre-commit hooks)
npx husky install
```

---

## 📝 Daily Development Workflow

### Before You Start Coding

```bash
# Pull latest changes
git pull

# Install any new dependencies
npm install
```

### While Coding

```bash
# Run in development mode (auto-restart on changes)
npm run dev

# In another terminal, run tests in watch mode
npm test -- --watch
```

### Before Committing

```bash
# Run tests
npm test

# Check code quality (finds issues)
npm run lint

# Auto-fix linting issues
npm run lint:fix

# Format all code
npm run format

# Run tests with coverage
npm run test:coverage
```

**Note**: Pre-commit hooks will run automatically, but it's good to check manually first!

---

## 🔧 Available Commands

| Command                 | Description                            |
| ----------------------- | -------------------------------------- |
| `npm start`             | Start production server                |
| `npm run dev`           | Start development server (auto-reload) |
| `npm test`              | Run tests once                         |
| `npm run test:coverage` | Run tests with coverage report         |
| `npm run lint`          | Check for code quality issues          |
| `npm run lint:fix`      | Auto-fix linting issues                |
| `npm run format`        | Format all code with Prettier          |
| `npm run format:check`  | Check if code is formatted             |

---

## 🧪 Testing Your Changes

### Test a specific file

```bash
npm test -- movies.test.js
```

### Run tests in watch mode

```bash
npm test -- --watch
```

### See detailed coverage

```bash
npm run test:coverage
# Then open: coverage/lcov-report/index.html
```

---

## 🐛 Common Issues & Solutions

### Issue: Pre-commit hook fails

**Solution**: Fix the linting errors shown, then commit again

```bash
npm run lint:fix
git add .
git commit -m "Your message"
```

### Issue: Tests fail after changes

**Solution**: Check what broke

```bash
npm test -- --verbose
```

### Issue: Can't commit (Husky error)

**Solution**: Reinitialize Husky

```bash
npx husky install
chmod +x .husky/pre-commit
```

### Issue: Winston can't write logs

**Solution**: Create logs directory

```bash
mkdir -p logs
```

### Issue: ESLint shows many errors

**Solution**: Auto-fix what you can

```bash
npm run lint:fix
npm run format
```

---

## 📚 Testing the API

### Start the server

```bash
npm run dev
```

### Test with curl

```bash
# Health check
curl http://localhost:3000/health

# Get all movies
curl http://localhost:3000/movies

# Create a movie
curl -X POST http://localhost:3000/movies \
  -H "Content-Type: application/json" \
  -d '{"title": "Inception", "rating": 5}'

# Get movies with rating >= 4
curl http://localhost:3000/movies?minRating=4
```

### Test with httpie/xh

```bash
# Get all movies
xh http://localhost:3000/movies

# Create a movie
xh POST http://localhost:3000/movies title="Dune" rating:=5

# Test validation (should fail)
xh POST http://localhost:3000/movies title="Bad" rating:=10
```

---

## 🔍 Code Quality Checks

### What gets checked automatically?

When you commit, these run automatically:

1. **ESLint** - Checks code quality
2. **Prettier** - Formats code
3. **lint-staged** - Only checks files you changed

### Manual quality check

```bash
# Full check
npm run lint && npm run format:check && npm test
```

---

## 📊 Understanding Coverage Reports

After running `npm run test:coverage`:

```
----------|---------|----------|---------|---------|
File      | % Stmts | % Branch | % Funcs | % Lines |
----------|---------|----------|---------|---------|
All files |   85.5  |   75.2   |   90.1  |   86.3  |
----------|---------|----------|---------|---------|
```

- **Stmts**: Statement coverage (how many lines executed)
- **Branch**: Branch coverage (how many if/else paths tested)
- **Funcs**: Function coverage (how many functions called)
- **Lines**: Line coverage (similar to statements)

**Goal**: Keep all above 70% (configured in jest.config.js)

---

## 🚨 CI/CD Pipeline

When you push code, GitHub Actions runs:

1. **Checkout code**
2. **Install dependencies**
3. **Run ESLint** ❌ Fails if errors
4. **Run Prettier check** ❌ Fails if not formatted
5. **Run tests** ❌ Fails if tests don't pass
6. **Build Docker image**
7. **Scan with Trivy** ⚠️ Warns on vulnerabilities

### View CI results

- Go to GitHub → Actions tab
- Click on your workflow run
- Check each job's logs

---

## 🔐 Security Best Practices

### Dependabot PRs

1. Review the changelog
2. Check if tests pass
3. Merge if safe

### Trivy Findings

1. Check severity (CRITICAL > HIGH > MEDIUM)
2. Update vulnerable packages: `npm update`
3. Or update base Docker image

### Never commit secrets

```bash
# Bad ❌
API_KEY = "sk_live_abc123..."

# Good ✅
API_KEY = process.env.API_KEY
```

---

## 💡 Pro Tips

### Tip 1: Use watch mode while developing

```bash
# Terminal 1: Server with auto-reload
npm run dev

# Terminal 2: Tests with auto-run
npm test -- --watch
```

### Tip 2: Format on save in VS Code

Add to `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

### Tip 3: See what pre-commit will check

```bash
npx lint-staged
```

### Tip 4: Skip pre-commit in emergencies

```bash
git commit --no-verify -m "Emergency hotfix"
```

⚠️ Use sparingly! CI will still catch issues.

### Tip 5: Debug tests

```bash
# Run specific test
npm test -- -t "should create a movie"

# See console.logs in tests
npm test -- --verbose
```

---

## 🎯 Your First Contribution Checklist

- [ ] Pull latest code
- [ ] Install dependencies: `npm install`
- [ ] Make your changes
- [ ] Add/update tests
- [ ] Run tests: `npm test`
- [ ] Check coverage: `npm run test:coverage`
- [ ] Lint code: `npm run lint:fix`
- [ ] Format code: `npm run format`
- [ ] Commit (pre-commit hook will run)
- [ ] Push to GitHub
- [ ] Check CI passes
- [ ] Create Pull Request

---

## 📖 More Documentation

- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Complete API reference
- [IMPROVEMENTS_SUMMARY.md](../../IMPROVEMENTS_SUMMARY.md) - What was added and why

---

## 🆘 Getting Help

If you're stuck:

1. Check error messages carefully
2. Review this guide
3. Check the test files for examples
4. Read the API documentation
5. Check CI logs on GitHub

Happy coding! 🎉
