# Runbook: Alert routing

## Alert sinks

| Sink | Purpose | Config |
|------|---------|--------|
| Sentry | Runtime errors / panics in pager/shell | `SENTRY_DSN`, project alerts in Sentry UI |
| GitHub Issues | Human-readable failure tickets | workflow `.github/workflows/error-to-issue.yml` |
| GitHub Actions failure emails | CI regression pages | repo notification settings |
| Mixpanel anomalies | Product-usage drops after ship | project alerts in Mixpanel |

## Recommended Sentry alert rules

Create these in the Sentry project used by the do binary:

1. **New issue** — notify on first-seen errors (P2 default).
2. **Spike** — error rate > 2× baseline over 15 minutes (P1).
3. **Fatal** — panic / abort events (P0).

Optional PagerDuty / OpsGenie: attach the Sentry integration so P0/P1 routes to on-call. Document the service name here when wired:

```
# Placeholder — set when connecting a pager:
# PagerDuty service: <name>
# OpsGenie team: <name>
```

## CI as alerts

Failed **CI** or **Release** workflows are treated as ship-blocking alerts. Agents should not merge while required checks fail (once branch protection is active).
