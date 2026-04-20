# Development Tooling

This template includes professional development tools for code quality and CI/CD.

## Code Formatting

### Clang-Format

Automatically formats C code according to ESP-IDF style guidelines.

**Format a single file:**

```bash
clang-format -i src/main.c
```

**Format all C files:**

```bash
find src \( -name "*.c" -o -name "*.h" \) -exec clang-format -i {} +
```

**Check formatting without modifying:**

```bash
clang-format --dry-run --Werror src/main.c
```

Configuration is in `.clang-format` following ESP-IDF conventions:

- 4-space indentation
- 120 character line limit
- Linux-style braces

### VS Code Integration

The C/C++ extension automatically uses `.clang-format`. Format on save is
enabled by default in `.vscode/settings.json`:

- **Auto-format on save**: Files are formatted when you save (Ctrl+S / Cmd+S)
- **Manual format**: Right-click → "Format Document" or Shift+Alt+F
- **120 char ruler**: Visible guide at the line limit
- **Trim whitespace**: Automatically removes trailing whitespace

## Static Analysis

### Clang-Tidy

Performs static analysis to catch bugs and enforce best practices.

**Analyze a file:**

```bash
clang-tidy src/main.c -- -I./include
```

**Configuration:**

- `.clang-tidy` enables bugprone, cert, performance, and readability checks
- Disabled: magic numbers, unused parameters (common in embedded)
- Naming conventions enforce lower_case variables/functions, UPPER_CASE macros

## Pre-Commit Hooks

Automated checks run before each commit to maintain code quality.

### Setup

Pre-commit hooks are **automatically installed** when you open the project in
the dev container. You can verify installation with:

```bash
pre-commit --version
```

If you need to reinstall manually:

```bash
# Install pre-commit hooks
pre-commit install
```

### What Gets Checked

- ✅ Trailing whitespace removal
- ✅ End-of-file newline
- ✅ File size limits (500KB max)
- ✅ Merge conflict markers
- ✅ LF line endings (Unix style)
- ✅ YAML syntax
- ✅ C/C++ formatting (clang-format)
- ✅ Shell script linting (shellcheck)
- ✅ Markdown formatting
- ✅ EditorConfig compliance

### Manual Runs

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run clang-format --all-files

# Update hook versions
pre-commit autoupdate
```

### Bypass (when necessary)

```bash
git commit --no-verify -m "emergency fix"
```

## CI/CD (GitHub Actions)

Automated builds and checks run on every push and pull request.

### Build Workflow

**File:** `.github/workflows/build.yml`

**Jobs:**

1. **build** - Compiles firmware, checks size, uploads artifacts
2. **format-check** - Verifies code formatting
3. **lint** - Runs all pre-commit hooks

### Workflow Triggers

- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

### Viewing Results

1. Go to the "Actions" tab in GitHub
2. Click on a workflow run
3. View logs and download firmware artifacts

### Build Status Badge

Add to your README.md:

```markdown
![Build Status](https://github.com/USERNAME/REPO/workflows/Build%20and%20Test/badge.svg)
```

## Development Workflow

### Recommended Process

1. **Open in dev container** - All tools auto-install
2. **Make changes** to code (format-on-save enabled in VS Code)
3. **Test locally**: `make build` or `pio run`
4. **Stage changes**: `git add .`
5. **Commit**: Pre-commit hooks run automatically
6. **Push**: CI/CD runs in GitHub Actions

### Tips

- **Format on save** is enabled by default in VS Code
- **Pre-commit hooks** are automatically configured on container start
- **Run checks manually** with `make test` before committing
- **Check CI logs** if build fails remotely
- **Use clang-tidy** during development to catch bugs early

## Customization

### Modify Formatting Rules

Edit `.clang-format`:

```yaml
ColumnLimit: 100  # Change from 120
IndentWidth: 2    # Change from 4
```

### Add/Remove Pre-Commit Hooks

Edit `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-json  # Add new hook
```

### Modify CI Workflow

Edit `.github/workflows/build.yml` to:

- Add more build environments
- Run unit tests
- Deploy firmware
- Generate documentation

## Troubleshooting

**Pre-commit hooks not installed:**

- They should auto-install on container creation
- Manually install: `pre-commit install`
- Verify: `pre-commit --version`

**Pre-commit hook fails:**

- Run manually: `pre-commit run --all-files`
- Check specific file: `pre-commit run --files src/main.c`
- Update hooks: `pre-commit autoupdate`

**Clang-format not found:**

- Should be pre-installed in dev container
- Verify: `clang-format --version`
- If missing, rebuild container: "Dev Containers: Rebuild Container"

**CI build fails locally works:**

- Check Python version (CI uses 3.11)
- Clear cache: `rm -rf .pio`
- Check platformio.ini matches CI

## Resources

- [Clang-Format Documentation](https://clang.llvm.org/docs/ClangFormat.html)
- [Clang-Tidy Checks](https://clang.llvm.org/extra/clang-tidy/checks/list.html)
- [Pre-Commit Hooks](https://pre-commit.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
