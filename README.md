# iO præsentationer

HTML-decks lavet med iO slides-skillen, udgivet gratis på **GitHub Pages** og låst med **kodeord**.

- Repoet og siden er **offentlige**, men decks ligger kun krypteret (AES-256-GCM). Uden kodeordet ser man en login-side og ulæselig data.
- Hvert deck får et tilfældigt filnavn og sit eget kodeord. Navnet afslører ikke kunden.
- De ukrypterede decks ligger kun lokalt i `kilder/` og pushes aldrig (`.gitignore`).

## Udgiv et deck

```bash
./udgiv.sh ~/sti/til/deck.html
```

Scriptet skriver et link og et kodeord ud, fx:

```
Link:    https://lucasmejeriodigital.github.io/io-praesentationer/k7f2x9q4m8.html
Kodeord: klit-fjord-hus-birk-eg-50
```

Gem kodeordet i din kodeordsmanager. Send linket og kodeordet i **to forskellige beskeder**.

**Opdatér et deck** og behold samme link. Id'et er det tilfældige navn i linket:

```bash
./udgiv.sh ~/sti/til/deck.html k7f2x9q4m8
```

Det giver et nyt kodeord. Det gamle virker ikke på den nye version.

## Opsætning (én gang)

1. Gør repoet offentligt (kræves for gratis Pages):
   ```bash
   gh repo edit Lucasmejeriodigital/io-praesentationer --visibility public --accept-visibility-change-consequences
   ```
2. Slå Pages til fra mappen `docs/`:
   ```bash
   gh api -X POST repos/Lucasmejeriodigital/io-praesentationer/pages -f "source[branch]=main" -f "source[path]=/docs"
   ```

## Forbehold

- **Kodeordet er hele sikkerheden.** Filen er offentlig, så et svagt kodeord kan gættes. Brug det dannede (fem ord + tal).
- **Kan ikke trækkes tilbage.** Har nogen hentet filen, kan de åbne den med kodeordet, også efter den er slettet. Ældre versioner ligger desuden i git-historikken.
- **Ingen log** over, hvem der har åbnet et deck.
- Til fortroligt klientmateriale: brug PDF eller en løsning med login (se `arkiv/azure/`).
- "Husk på denne computer" gemmer en nøgle i browseren til netop den fil, ikke kodeordet.
