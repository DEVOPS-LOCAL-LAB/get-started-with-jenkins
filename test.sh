#!/bin/sh
set -eu  
# -e: arrête le script si une commande échoue. -u: arrête si une variab

test -f index.html
grep -q "Application déployée par Jenkins" index.html

echo "Test reussi : index.html est ouvert"
