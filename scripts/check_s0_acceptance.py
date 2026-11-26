from pathlib import Path

text = Path('docs/implementation/S0_ACCEPTANCE.md').read_text()
required = ['S0-01', 'S0-06', 'S0-07', 'S0-08', 'S0-15']
incomplete = [key for key in required if not any(
    line.startswith('| ' + key + ' |') and '| DONE ' in line
    for line in text.splitlines()
)]
if incomplete:
    raise SystemExit('Incomplete S0 acceptance criteria: ' + ', '.join(incomplete))
