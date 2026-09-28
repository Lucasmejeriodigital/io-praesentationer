#!/usr/bin/env python3
"""Opret en kundemappe med egen adgangsrolle.

    python3 ny-kunde.py <kunde>        fx  python3 ny-kunde.py sbst

Decks i kunder/<kunde>/ kan ses af rollen "io" og "kunde-<kunde>".
Alt andet i repoet kan kun ses af "io". Inviter kunden i Azure-portalen
med rollen kunde-<kunde> (se README).
"""
import json, re, sys
from pathlib import Path

ROD = Path(__file__).resolve().parent
if len(sys.argv) != 2:
    sys.exit(__doc__)
slug = re.sub(r'[^a-z0-9-]+', '-', sys.argv[1].lower()).strip('-')
cfg_fil = ROD / 'staticwebapp.config.json'
cfg = json.loads(cfg_fil.read_text())
rute = f'/kunder/{slug}/*'
if not any(r.get('route') == rute for r in cfg['routes']):
    ny = {'route': rute, 'allowedRoles': ['io', f'kunde-{slug}']}
    cfg['routes'].insert(len(cfg['routes']) - 1, ny)  # før fang-alt-reglen "/*"
    cfg_fil.write_text(json.dumps(cfg, ensure_ascii=False, indent=2) + '\n')
(ROD / 'kunder' / slug).mkdir(parents=True, exist_ok=True)
print(f'Kundemappe: kunder/{slug}/   rolle: kunde-{slug}')
