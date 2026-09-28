#!/bin/sh
# Låser et deck med kodeord og udgiver det på GitHub Pages.
#
#   ./udgiv.sh sti/til/deck.html              nyt deck: tilfældigt filnavn og dannet kodeord
#   ./udgiv.sh sti/til/deck.html a7f3k9q2     opdatér et udgivet deck (samme link, nyt kodeord)
#
# Kun den krypterede fil i docs/ bliver pushet. Det ukrypterede deck kopieres til kilder/,
# som er udeladt af git.
set -e
cd "$(dirname "$0")"
LAAS="$HOME/Arbejde/io-slides/motor/laas.mjs"
[ -f "$LAAS" ] || LAAS="$HOME/.claude/skills/io-slides/motor/laas.mjs"
[ -f "$1" ] || { echo "Brug: ./udgiv.sh deck.html [id]" >&2; exit 1; }

ID="${2:-$(python3 -c "import secrets,string; print(''.join(secrets.choice(string.ascii_lowercase+string.digits) for _ in range(10)))")}"
mkdir -p kilder docs
cp "$1" "kilder/$ID-$(basename "$1")"
node "$LAAS" "$1" -o "docs/$ID.html"

git add docs
git commit -q -m "Udgiv deck $ID" -- docs
git push -q

BRUGER=$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/.*#\1#' | tr 'A-Z' 'a-z')
REPO=$(basename "$(git remote get-url origin)" .git)
echo
echo "Link:    https://$BRUGER.github.io/$REPO/$ID.html"
echo "Send linket og kodeordet i to forskellige beskeder. Der kan gå et minut, før linket virker."
