#!/bin/bash
# Validation script for GitHub Copilot customization files
# Usage: .github/scripts/validate-files.sh

set -e

REPO_URL="https://github.com/Pwd9000-ML/copilot-archetype-standards"
ERRORS=0

echo "🔍 Validating GitHub Copilot customization files..."
echo ""

# Function to report errors
report_error() {
    echo "❌ ERROR: $1"
    ERRORS=$((ERRORS + 1))
}

report_warning() {
    echo "⚠️  WARNING: $1"
}

report_success() {
    echo "✅ $1"
}

# Check 1: Validate YAML front matter in instruction files
echo "📋 Checking instruction files..."
for file in .github/instructions/*.instructions.md; do
    if [ -f "$file" ]; then
        # Check for front matter
        if ! head -n 1 "$file" | grep -q "^---$"; then
            report_error "$file: Missing front matter"
        else
            # Check for required fields
            if ! grep -q "^applyTo:" "$file"; then
                report_error "$file: Missing 'applyTo' field"
            fi
            if ! grep -q "^description:" "$file"; then
                report_error "$file: Missing 'description' field"
            fi
            report_success "$file: Valid front matter"
        fi
    fi
done
echo ""

# Check 2: Validate YAML front matter in prompt files
echo "📋 Checking prompt files..."
for file in .github/prompts/*.prompt.md; do
    if [ -f "$file" ]; then
        if ! head -n 1 "$file" | grep -q "^---$"; then
            report_error "$file: Missing front matter"
        else
            # Check for required fields
            if ! grep -q "^mode:" "$file"; then
                report_error "$file: Missing 'mode' field"
            fi
            if ! grep -q "^description:" "$file"; then
                report_error "$file: Missing 'description' field"
            fi
            if ! grep -q "^tools:" "$file"; then
                report_error "$file: Missing 'tools' field"
            fi
            report_success "$file: Valid front matter"
        fi
    fi
done
echo ""

# Check 3: Validate YAML front matter in chatmode files
echo "📋 Checking chatmode files..."
for file in .github/chatmodes/*.chatmode.md; do
    if [ -f "$file" ]; then
        if ! head -n 1 "$file" | grep -q "^---$"; then
            report_error "$file: Missing front matter"
        else
            # Check for required fields
            if ! grep -q "^description:" "$file"; then
                report_error "$file: Missing 'description' field"
            fi
            if ! grep -q "^tools:" "$file"; then
                report_error "$file: Missing 'tools' field"
            fi
            report_success "$file: Valid front matter"
        fi
    fi
done
echo ""

# Check 4: Validate URL consistency
echo "🔗 Checking URL consistency..."
if grep -r "blob/main" --include="*.md" . 2>/dev/null | grep -v ".git" | grep -v "validate-files.sh"; then
    report_error "Found 'blob/main' URLs. Should use 'tree/master'"
fi

if grep -r "blob/master" --include="*.md" . 2>/dev/null | grep -v ".git" | grep -v "validate-files.sh"; then
    report_warning "Found 'blob/master' URLs. Consider using 'tree/master' for directory links"
fi

# Check for relative links
if grep -r "](\.\./" --include="*.md" . 2>/dev/null | grep -v ".git" | grep -v "validate-files.sh"; then
    report_error "Found relative links. Should use full GitHub URLs"
fi

if [ $ERRORS -eq 0 ]; then
    report_success "No URL consistency issues found"
fi
echo ""

# Check 5: File naming conventions
echo "📝 Checking file naming conventions..."

# Instruction files
for file in .github/instructions/*.md; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        if [[ ! "$basename" =~ ^[a-z]+\.instructions\.md$ ]] && [[ "$basename" != "README.md" ]]; then
            report_error "$file: Should follow pattern: {language}.instructions.md"
        fi
    fi
done

# Prompt files - allow optional platform/framework specifier
for file in .github/prompts/*.md; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        # Allow: scope.purpose.prompt.md or scope.platform.purpose.prompt.md
        if [[ ! "$basename" =~ ^[a-z]+\.[a-z.-]+\.prompt\.md$ ]] && [[ "$basename" != "README.md" ]]; then
            report_error "$file: Should follow pattern: {scope}.{purpose}.prompt.md or {scope}.{platform}.{purpose}.prompt.md"
        fi
    fi
done

# Chatmode files
for file in .github/chatmodes/*.md; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        if [[ ! "$basename" =~ ^[a-z]+\.[a-z-]+\.chatmode\.md$ ]] && [[ "$basename" != "README.md" ]]; then
            report_error "$file: Should follow pattern: {language}.{mode}.chatmode.md"
        fi
    fi
done

if [ $ERRORS -eq 0 ]; then
    report_success "File naming conventions are correct"
fi
echo ""

# Check 6: Placeholder detection in templates
echo "🔍 Checking for unfilled placeholders..."
for file in .github/instructions/*.md .github/prompts/*.md .github/chatmodes/*.md; do
    if [ -f "$file" ] && [[ "$file" != *"template"* ]]; then
        if grep -q "{" "$file" && grep -q "}" "$file"; then
            # Check for common placeholders
            if grep -E "\{Language\}|\{Version\}|\{Purpose\}|\{Mode\}|\{extension\}" "$file" > /dev/null; then
                report_warning "$file: Contains unfilled placeholders"
            fi
        fi
    fi
done
echo ""

# Check 7: Check for code fence consistency
echo "📦 Checking code fence consistency..."
for file in .github/instructions/*.md .github/prompts/*.md .github/chatmodes/*.md docs/*.md; do
    if [ -f "$file" ]; then
        # Count opening and closing code fences
        opening=$(grep -c "^\`\`\`" "$file" || true)
        if [ $((opening % 2)) -ne 0 ]; then
            report_error "$file: Unmatched code fences (found $opening)"
        fi
    fi
done

if [ $ERRORS -eq 0 ]; then
    report_success "Code fences are properly matched"
fi
echo ""

# Summary
echo "═══════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All validation checks passed!"
    echo "═══════════════════════════════════════"
    exit 0
else
    echo "❌ Validation failed with $ERRORS error(s)"
    echo "═══════════════════════════════════════"
    echo ""
    echo "Please fix the errors above before submitting."
    echo "See CONTRIBUTING.md for guidelines."
    exit 1
fi
