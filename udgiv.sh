#!/bin/sh
# Udgiver et deck på GitHub Pages — låst med kodeord eller åbent.
#
#   ./udgiv.sh deck.html                spørger: låst eller åben, og hvilket kodeord
#   ./udgiv.sh deck.html --laast        låst, spring første spørgsmål over
#   ./udgiv.sh deck.html --aaben        åbent for alle med linket, ingen kodeord
#   ./udgiv.sh deck.html --standard     låst med dit standardkodeord, ingen spørgsmål
#   ./udgiv.sh deck.html --id a7f3k9q2  opdatér et udgivet deck og behold linket
#
#   ./udgiv.sh --saet-standard          gem et standardkodeord i macOS Nøglering
#   ./udgiv.sh --slet-standard          fjern standardkodeordet
#
# Kodeord skrives skjult. Standardkodeordet ligger kun i din Nøglering (ikke i filer eller git).
# Det ukrypterede deck kopieres kun til kilder/, som er udeladt af git.
set -e
cd "$(dirname "$0")"
LAAS="$HOME/Arbejde/io-slides/motor/laas.mjs"
[ -f "$LAAS" ] || LAAS="$HOME/.claude/skills/io-slides/motor/laas.mjs"

NOEGLERING="io-praesentationer-standardkodeord"
hent_standard() { security find-generic-password -a "$USER" -s "$NOEGLERING" -w 2>/dev/null || true; }
gem_standard() {
  security add-generic-password -U -a "$USER" -s "$NOEGLERING" -l "iO præsentationer: standardkodeord" -w "$1" \
    && echo "Standardkodeord gemt i Nøglering."
}

skjult() {
  if [ -t 0 ]; then stty -echo; read -r "$1"; stty echo; echo; else read -r "$1" || true; fi
}

# Spørger om et nyt kodeord to gange. Tomt svar er tilladt, hvis $1 = tomt-ok.
spoerg_kodeord() {
  while :; do
    if [ "$1" = tomt-ok ]; then printf "Kodeord (mindst 12 tegn, Enter = dan et tilfældigt): "; else printf "Kodeord (mindst 12 tegn): "; fi
    skjult KODE
    if [ -z "$KODE" ]; then [ "$1" = tomt-ok ] && return; echo "Skriv et kodeord."; continue; fi
    if [ ${#KODE} -lt 12 ]; then echo "For kort. Prøv igen."; continue; fi
    printf "Gentag kodeordet: "
    skjult KODE2
    [ "$KODE" = "$KODE2" ] && return
    echo "Kodeordene er ikke ens. Prøv igen."
  done
}

DECK=""; TILSTAND=""; ID=""; BRUG_STANDARD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --laast) TILSTAND=laast ;;
    --aaben) TILSTAND=aaben ;;
    --standard) TILSTAND=laast; BRUG_STANDARD=ja ;;
    --saet-standard)
      spoerg_kodeord
      gem_standard "$KODE"; unset KODE KODE2; exit 0 ;;
    --slet-standard)
      security delete-generic-password -a "$USER" -s "$NOEGLERING" >/dev/null 2>&1 \
        && echo "Standardkodeordet er fjernet." || echo "Der var intet standardkodeord."
      exit 0 ;;
    --id) shift; ID="$1" ;;
    -*) echo "Ukendt valg: $1" >&2; exit 1 ;;
    *) DECK="$1" ;;
  esac
  shift
done
[ -f "$DECK" ] || { echo "Brug: ./udgiv.sh deck.html [--laast | --aaben] [--id <id>]" >&2; exit 1; }

if [ -z "$TILSTAND" ]; then
  echo "Hvordan skal decket udgives?"
  echo "  l = låst med kodeord (standard)"
  echo "  å = åbent for alle med linket"
  while [ -z "$TILSTAND" ]; do
    printf "Vælg [l/å, Enter = låst]: "
    read -r svar || true
    case "$svar" in
      ""|l|L|låst|Låst|laast) TILSTAND=laast ;;
      å|Å|a|A|åben|Åben|aaben) TILSTAND=aaben ;;
      *) echo "Skriv l eller å." ;;
    esac
  done
fi

if [ "$TILSTAND" = aaben ]; then
  echo
  echo "ADVARSEL: Uden kodeord kan alle med linket se decket, og det kan findes i repoet på GitHub."
  echo "Brug det ikke til kundenavne, tal eller fortroligt indhold."
  printf "Udgiv åbent? [j/N] "
  read -r svar || true
  case "$svar" in j|J|ja|Ja) ;; *) echo "Afbrudt."; exit 1 ;; esac
fi

KODE=""
if [ "$TILSTAND" = laast ]; then
  STANDARD=$(hent_standard)
  if [ -n "$STANDARD" ] && [ -z "$BRUG_STANDARD" ]; then
    printf "Brug dit standardkodeord? [J/n] "
    read -r svar || true
    case "$svar" in n|N|nej|Nej) ;; *) BRUG_STANDARD=ja ;; esac
  fi
  if [ -n "$BRUG_STANDARD" ]; then
    [ -n "$STANDARD" ] || { echo "Der er intet standardkodeord. Sæt et med: ./udgiv.sh --saet-standard" >&2; exit 1; }
    KODE="$STANDARD"
    echo "Bruger standardkodeordet."
  else
    spoerg_kodeord tomt-ok
    if [ -n "$KODE" ] && [ -z "$STANDARD" ]; then
      printf "Gem som dit standardkodeord til næste gang? [j/N] "
      read -r svar || true
      case "$svar" in j|J|ja|Ja) gem_standard "$KODE" ;; esac
    fi
  fi
  unset STANDARD
fi

[ -n "$ID" ] || ID=$(python3 -c "import secrets,string; print(''.join(secrets.choice(string.ascii_lowercase+string.digits) for _ in range(10)))")
mkdir -p kilder docs
cp "$DECK" "kilder/$ID-$(basename "$DECK")"

if [ "$TILSTAND" = laast ]; then
  IO_KODEORD="$KODE" node "$LAAS" "$DECK" -o "docs/$ID.html"
else
  cp "$DECK" "docs/$ID.html"
  echo "Åben: $(basename "$DECK") -> docs/$ID.html"
fi
unset KODE KODE2

git add docs
if git diff --cached --quiet -- docs; then
  echo "Decket er uændret i forhold til det udgivne. Intet nyt at committe."
else
  git commit -q -m "Udgiv deck $ID ($TILSTAND)" -- docs
fi
git push -q || { echo "Push til GitHub fejlede. Decket er gemt lokalt; kør 'git push' i $(pwd)." >&2; exit 1; }

BRUGER=$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/.*#\1#' | tr 'A-Z' 'a-z')
REPO=$(basename "$(git remote get-url origin)" .git)
echo
echo "Link:    https://$BRUGER.github.io/$REPO/$ID.html"
if [ "$TILSTAND" = laast ]; then
  echo "Send linket og kodeordet i to forskellige beskeder."
else
  echo "Åbent link: alle med linket kan se decket."
fi
echo
echo "Bemærk: Der går typisk 1-3 minutter, før GitHub har udgivet ændringen."
echo "Indtil da kan linket vise den gamle version (eller en 404 ved et nyt deck)."
echo "Ser du den gamle version, så genindlæs uden cache med Cmd+Shift+R, eller åbn i et nyt privat vindue."
