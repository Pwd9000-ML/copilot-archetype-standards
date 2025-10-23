---
mode: 'ask'
description: Plan migration strategy for code or infrastructure changes
---

# Migration Planning Prompt

Create a detailed migration plan for moving code, infrastructure, or systems from one state to another.

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
