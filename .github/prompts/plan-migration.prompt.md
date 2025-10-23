---
mode: 'agent'
description: Plan and execute migration strategy for code or infrastructure changes
---

# Migration Planning Prompt for Agent Mode

Create a detailed migration plan for moving code, infrastructure, or systems from one state to another. When using agent mode, you can both plan AND execute migration steps incrementally.

## Agent Migration Workflow

### Phase 0: Pre-Migration Analysis (Agent-Specific)
Before planning, use agent capabilities to gather comprehensive information:

#### Automated Discovery
```bash
# Analyze codebase structure
find . -name "*.py" -o -name "*.java" -o -name "*.tf" | wc -l
find . -type f -name "*.py" -exec wc -l {} + | sort -rn | head -20

# Check dependencies
pip list                    # Python
./gradlew dependencies      # Java
terraform providers schema  # Terraform

# Analyze git history
git --no-pager log --oneline --since="6 months ago" --format="%h %an %s" | head -50
git --no-pager log --stat --since="3 months ago" | grep -E "files? changed"

# Find potential issues
grep -r "TODO\|FIXME\|HACK" src/
grep -r "deprecated" src/
```

#### Parallel Code Analysis
Use view tool to read multiple files simultaneously:
- Read current implementation files
- Read target/new implementation files
- Read configuration files
- Read documentation files

## Migration Planning Framework

### 1. Assessment Phase

#### Current State Analysis
- Document existing architecture/codebase
- Identify all dependencies and integrations
- List current users and stakeholders
- Measure baseline metrics (performance, cost, usage)
- Identify technical debt and pain points

#### Target State Definition
- Define desired end state
- List improvements and benefits
- Identify new technologies/patterns
- Define success criteria
- Estimate resource requirements

#### Gap Analysis
- Compare current vs. target state
- Identify breaking changes
- List incompatibilities
- Assess risk areas
- Estimate effort and timeline

### 2. Strategy Development

#### Migration Approach
Choose and justify the migration strategy:
- **Big Bang**: Complete cutover in single event
- **Phased**: Gradual migration in stages
- **Parallel Run**: Old and new systems running simultaneously
- **Strangler Fig**: Incrementally replace components
- **Blue-Green**: Maintain two identical environments
- **Canary**: Gradual rollout to subset of users

#### Risk Mitigation
- Identify potential risks
- Define mitigation strategies
- Create rollback procedures
- Plan for data loss prevention
- Define incident response plan

### 3. Technical Planning

#### For Code Migration

Reference language-specific guidelines:
- [Python Standards](../instructions/python.instructions.md)
- [Java Standards](../instructions/java.instructions.md)

**Code Refactoring Plan**
- Identify files/modules to migrate
- Define new code structure
- Plan dependency updates
- Update import statements
- Refactor in small, testable increments

**Testing Strategy**
- Create comprehensive test suite first
- Ensure tests pass before migration
- Add integration tests
- Plan regression testing
- Define acceptance criteria

**Example Python Migration**
```python
# Phase 1: Add new code alongside old
# Phase 2: Deprecate old code with warnings
# Phase 3: Update all callers
# Phase 4: Remove old code
```

#### For Infrastructure Migration

Reference: [Terraform Conventions](../instructions/terraform.instructions.md)

**Infrastructure Planning**
- Document current infrastructure
- Design target infrastructure
- Plan resource migration order
- Define cutover strategy
- Plan DNS/traffic switching

**Terraform Migration Example**
```hcl
# Phase 1: Import existing resources
terraform import azurerm_resource_group.rg /subscriptions/xxx/resourceGroups/rg-name

# Phase 2: Create parallel infrastructure
# Phase 3: Migrate data/state
# Phase 4: Switch traffic
# Phase 5: Decommission old infrastructure
```

### 4. Data Migration

#### Data Strategy
- Inventory all data sources
- Define data mapping/transformation
- Plan for data validation
- Ensure data integrity
- Define rollback for data

#### Data Migration Steps
1. **Backup**: Full backup of production data
2. **Dry Run**: Test migration in non-prod
3. **Validation**: Verify data integrity
4. **Cutover**: Execute production migration
5. **Verification**: Validate in production

### 5. Timeline and Phases

Create detailed timeline with:
- Phase descriptions and goals
- Duration estimates
- Dependencies between phases
- Key milestones and checkpoints
- Go/no-go decision points

**Example Timeline**
```
Phase 1: Preparation (2 weeks)
├─ Week 1: Assessment and planning
└─ Week 2: Environment setup and testing framework

Phase 2: Development (4 weeks)
├─ Week 3-4: Core migration implementation
└─ Week 5-6: Testing and refinement

Phase 3: Deployment (2 weeks)
├─ Week 7: Staging deployment and validation
└─ Week 8: Production migration

Phase 4: Stabilization (1 week)
└─ Week 9: Monitoring, bug fixes, optimization
```

### 6. Communication Plan

#### Stakeholder Communication
- Define communication schedule
- Identify who needs to be informed
- Plan for downtime notifications
- Create status update templates
- Define escalation paths

#### Documentation Updates
- Update architecture diagrams
- Revise API documentation
- Update runbooks and procedures
- Document new processes
- Create training materials

### 7. Rollback Strategy

**Rollback Triggers**
- Critical bugs in production
- Performance degradation >20%
- Data integrity issues
- Security vulnerabilities
- Unplanned downtime >threshold

**Rollback Procedures**
1. Stop new deployments
2. Switch traffic back to old system
3. Restore data from backups if needed
4. Communicate status to stakeholders
5. Document issues for post-mortem

### 8. Post-Migration

#### Validation
- Verify all functionality working
- Check performance metrics
- Validate data integrity
- Confirm integrations working
- Collect user feedback

#### Optimization
- Monitor resource usage
- Optimize performance
- Address technical debt
- Refine processes
- Update documentation

#### Decommissioning
- Archive old code/infrastructure
- Update references and links
- Clean up unused resources
- Document lessons learned
- Conduct retrospective

## Migration Checklist Template

Use this checklist to track migration progress:

### Pre-Migration
- [ ] Current state documented
- [ ] Target state defined
- [ ] Risk assessment completed
- [ ] Rollback plan documented
- [ ] Stakeholders informed
- [ ] Backups completed
- [ ] Test environment validated

### During Migration
- [ ] Phase 1 completed and validated
- [ ] Phase 2 completed and validated
- [ ] Phase 3 completed and validated
- [ ] All tests passing
- [ ] Performance metrics acceptable
- [ ] No critical issues identified

### Post-Migration
- [ ] Production validation completed
- [ ] Monitoring in place
- [ ] Documentation updated
- [ ] Stakeholders notified of completion
- [ ] Old resources decommissioned
- [ ] Retrospective conducted

## Best Practices

✅ Start with non-critical components
✅ Test thoroughly in lower environments
✅ Migrate during low-traffic periods
✅ Have experts on standby during cutover
✅ Monitor closely after migration
✅ Document everything
✅ Communicate frequently
✅ Plan for the unexpected
✅ Learn from each phase

❌ Don't skip testing
❌ Don't ignore warnings
❌ Don't rush the process
❌ Don't forget about rollback
❌ Don't neglect documentation

## Agent-Specific Migration Execution

### Incremental Migration Pattern
When executing migration with agent mode:

#### Step 1: Create Parallel Implementation
```markdown
1. Keep old code working
2. Add new code alongside
3. Add feature flag/switch
4. Test both paths
5. Report progress
```

#### Step 2: Gradual Cutover
```markdown
1. Update one caller at a time
2. Test after each change
3. Run full test suite
4. Report progress
5. Continue to next caller
```

#### Step 3: Deprecation
```markdown
1. Mark old code as deprecated
2. Add warnings
3. Document migration path
4. Update all internal usages
5. Report progress
```

#### Step 4: Removal
```markdown
1. Verify no usages remain
2. Remove old code
3. Clean up tests
4. Update documentation
5. Report final progress
```

### Migration Execution Commands

#### Python Migration
```bash
# Find all usages of old code
grep -r "old_function_name" src/
grep -r "OldClassName" src/

# Run tests for each module being migrated
pytest tests/test_module.py -v

# Check for deprecation warnings
pytest tests/ -W default::DeprecationWarning
```

#### Java Migration
```bash
# Find usages with grep
grep -r "OldClassName" src/

# Run tests for specific package
./gradlew test --tests com.example.package.*

# Check for deprecation warnings during build
./gradlew build -Xlint:deprecation
```

#### Terraform Migration
```bash
# Import existing resources
terraform import azurerm_resource.name /subscriptions/.../resource

# Plan with target for specific resources
terraform plan -target=azurerm_resource.name

# Apply incrementally
terraform apply -target=azurerm_resource.name
```

## Migration Progress Tracking

### Initial Migration Plan
```markdown
## Migration: [From X to Y]

### Assessment Complete
- [x] Current state analyzed
- [x] Target state defined
- [x] Gap analysis completed
- [x] Risk assessment done
- [x] Migration strategy selected: [Strategy]

### Migration Phases
- [ ] Phase 1: Preparation (estimated: X days)
  - [ ] Setup new infrastructure/code
  - [ ] Add feature flags
  - [ ] Create parallel implementation
- [ ] Phase 2: Gradual Migration (estimated: X days)
  - [ ] Migrate component A
  - [ ] Migrate component B
  - [ ] Migrate component C
- [ ] Phase 3: Validation (estimated: X days)
  - [ ] Verify all functionality
  - [ ] Performance testing
  - [ ] Security review
- [ ] Phase 4: Cleanup (estimated: X days)
  - [ ] Remove old code
  - [ ] Update documentation
  - [ ] Decommission old resources

### Next Steps
Starting Phase 1: Setting up new infrastructure
```

### Migration Progress Update
```markdown
## Migration: [From X to Y]

### Progress Summary
- [x] Phase 1: Preparation ✅
  - [x] Setup new infrastructure/code
  - [x] Add feature flags
  - [x] Create parallel implementation
- [x] Phase 2: Gradual Migration (In Progress)
  - [x] Migrate component A ✅
  - [x] Migrate component B ✅
  - [ ] Migrate component C (In Progress)
- [ ] Phase 3: Validation
- [ ] Phase 4: Cleanup

### Recent Changes
- Migrated component A: 15 files updated, all tests passing
- Migrated component B: 8 files updated, all tests passing
- Component C migration: 3 of 7 files completed

### Metrics
- Files migrated: 23 of 30
- Tests passing: 245 of 245
- Coverage maintained: 87%
- No performance degradation

### Next Steps
Completing component C migration (4 files remaining)
```

## Agent Tips for Migration

1. **Use report_progress frequently**: After each migration step
2. **Test incrementally**: After migrating each component
3. **Keep rollback simple**: Don't delete old code until migration is complete
4. **Parallel operations**: Migrate independent components in parallel
5. **Automate validation**: Use existing test suites to verify migration
6. **Document as you go**: Update docs with each progress report
7. **Monitor metrics**: Track files migrated, tests passing, coverage

## Migration Safety Checklist

```markdown
### Before Each Migration Step
- [ ] All existing tests passing
- [ ] Current code behavior documented
- [ ] Rollback plan ready
- [ ] Backup of current state available

### After Each Migration Step
- [ ] New code functions correctly
- [ ] All tests still passing
- [ ] No performance degradation
- [ ] Documentation updated
- [ ] Progress reported

### Before Final Cutover
- [ ] All components migrated
- [ ] Full test suite passing
- [ ] Performance validated
- [ ] Security review completed
- [ ] Rollback tested
- [ ] Stakeholders informed
```
