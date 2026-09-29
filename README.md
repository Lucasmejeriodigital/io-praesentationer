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
1. **Låst eller åben?** Tryk `l` for låst med kodeord (Enter gør det samme) eller `å` for åbent.
2. **Brug dit standardkodeord?** Spørges kun, hvis du har gemt et. Enter betyder ja.
3. **Kodeord:** ellers skriver du et (mindst 12 tegn, skrives to gange og vises ikke), eller trykker Enter for at få et dannet. Har du intet standardkodeord, tilbyder scriptet at gemme det, du skriver.

Til sidst skrives linket ud. Send linket og kodeordet i **to forskellige beskeder**.

> **Det tager et par minutter.** GitHub skal udgive ændringen, og det tager typisk 1-3 minutter. Indtil da viser linket den gamle version, eller en 404, hvis decket er nyt. Genindlæs uden cache med `⌘⇧R`, eller åbn linket i et nyt privat vindue. Tjek altid linket, før du sender det videre eller går ind til mødet.

Vælg på forhånd:

```bash
./udgiv.sh deck.html --laast     # låst, spørger kun om kodeord
./udgiv.sh deck.html --aaben     # åbent, beder om bekræftelse
./udgiv.sh deck.html --standard  # låst med standardkodeordet, ingen spørgsmål
```

**Standardkodeord** ligger kun i macOS Nøglering, ikke i filer eller git:

```bash
./udgiv.sh --saet-standard       # sæt eller skift
./udgiv.sh --slet-standard       # fjern
```

Et nyt standardkodeord gælder kun decks, der udgives bagefter. Allerede udgivne decks bruger stadig det gamle.

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
