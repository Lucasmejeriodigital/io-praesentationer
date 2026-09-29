#!/bin/sh
# Udgiver et deck på GitHub Pages — låst med kodeord eller åbent.
#
#   ./udgiv.sh deck.html                spørger: låst eller åben, og hvilket kodeord
#   ./udgiv.sh deck.html --laast        låst, spørger om kodeord (Enter = dan et)
#   ./udgiv.sh deck.html --aaben        åbent for alle med linket, ingen kodeord
#   ./udgiv.sh deck.html --id a7f3k9q2  opdatér et udgivet deck og behold linket
#
# Kodeordet skrives skjult og gemmes ingen steder. Det ukrypterede deck kopieres kun til
# kilder/, som er udeladt af git.
set -e
cd "$(dirname "$0")"
LAAS="$HOME/Arbejde/io-slides/motor/laas.mjs"
[ -f "$LAAS" ] || LAAS="$HOME/.claude/skills/io-slides/motor/laas.mjs"

DECK=""; TILSTAND=""; ID=""
while [ $# -gt 0 ]; do
  case "$1" in
    --laast) TILSTAND=laast ;;
    --aaben) TILSTAND=aaben ;;
    --id) shift; ID="$1" ;;
    -*) echo "Ukendt valg: $1" >&2; exit 1 ;;
    *) DECK="$1" ;;
  esac
  shift
done
[ -f "$DECK" ] || { echo "Brug: ./udgiv.sh deck.html [--laast | --aaben] [--id <id>]" >&2; exit 1; }

if [ -z "$TILSTAND" ]; then
  printf "Skal decket ligge bag kodeord? [J/n] "
  read -r svar || true
  case "$svar" in n|N|nej|Nej) TILSTAND=aaben ;; *) TILSTAND=laast ;; esac
fi

if [ "$TILSTAND" = aaben ]; then
  echo
  echo "ADVARSEL: Uden kodeord kan alle med linket se decket, og det kan findes i repoet på GitHub."
  echo "Brug det ikke til kundenavne, tal eller fortroligt indhold."
  printf "Udgiv åbent? [j/N] "
  read -r svar || true
  case "$svar" in j|J|ja|Ja) ;; *) echo "Afbrudt."; exit 1 ;; esac
fi

skjult() {
  if [ -t 0 ]; then stty -echo; read -r "$1"; stty echo; echo; else read -r "$1" || true; fi
}

KODE=""
if [ "$TILSTAND" = laast ]; then
  while :; do
    printf "Kodeord (mindst 12 tegn, Enter = dan et tilfældigt): "
    skjult KODE
    [ -z "$KODE" ] && break
    if [ ${#KODE} -lt 12 ]; then echo "For kort. Prøv igen."; continue; fi
    printf "Gentag kodeordet: "
    skjult KODE2
    [ "$KODE" = "$KODE2" ] && break
    echo "Kodeordene er ikke ens. Prøv igen."
  done
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
git commit -q -m "Udgiv deck $ID ($TILSTAND)" -- docs
git push -q

BRUGER=$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/.*#\1#' | tr 'A-Z' 'a-z')
REPO=$(basename "$(git remote get-url origin)" .git)
echo
echo "Link:    https://$BRUGER.github.io/$REPO/$ID.html"
if [ "$TILSTAND" = laast ]; then
  echo "Send linket og kodeordet i to forskellige beskeder."
else
  echo "Åbent link: alle med linket kan se decket."
fi
echo "Der kan gå et minut, før linket virker."
