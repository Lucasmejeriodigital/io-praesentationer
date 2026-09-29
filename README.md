# iO præsentationer

HTML-decks lavet med iO slides-skillen, udgivet gratis på **GitHub Pages**. Hvert deck er enten **låst med kodeord** (standard) eller **åbent**.

- Repoet og siden er **offentlige**. Låste decks ligger kun krypteret (AES-256-GCM). Uden kodeordet ser man en login-side og ulæselig data.
- Åbne decks kan ses af alle med linket, og de kan findes i repoet.
- Hvert deck får et tilfældigt filnavn. Navnet afslører ikke kunden.
- De ukrypterede decks ligger kun lokalt i `kilder/` og pushes aldrig (`.gitignore`).

## Udgiv et deck

```bash
./udgiv.sh ~/sti/til/deck.html
```

Scriptet spørger:
1. **Skal decket ligge bag kodeord?** Enter betyder ja.
2. **Kodeord:** skriv dit eget (mindst 12 tegn, skrives to gange og vises ikke), eller tryk Enter for at få et dannet.

Til sidst skrives linket ud. Send linket og kodeordet i **to forskellige beskeder**.

Vælg på forhånd:

```bash
./udgiv.sh deck.html --laast     # låst, spørger kun om kodeord
./udgiv.sh deck.html --aaben     # åbent, beder om bekræftelse
```

**Opdatér et deck** og behold samme link. Id'et er det tilfældige navn i linket:

```bash
./udgiv.sh ~/sti/til/deck.html --id k7f2x9q4m8
```

Et låst deck skal have kodeordet igen. Brug samme kodeord, hvis modtagerne skal beholde det, de har.

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

- **Kodeordet er hele sikkerheden.** Filen er offentlig, så et svagt kodeord kan gættes. Brug mindst 12 tegn og gerne flere ord, fx `blå-fjord-mandag-kaffe`, eller brug det dannede.
- **Kan ikke trækkes tilbage.** Har nogen hentet filen, kan de åbne den med kodeordet, også efter den er slettet. Ældre versioner ligger desuden i git-historikken.
- **Ingen log** over, hvem der har åbnet et deck.
- Til fortroligt klientmateriale: brug PDF eller en løsning med login (se `arkiv/azure/`).
- "Husk på denne computer" gemmer en nøgle i browseren til netop den fil, ikke kodeordet.
