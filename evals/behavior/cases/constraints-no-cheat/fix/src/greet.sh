greet() {
  if [ "$#" -eq 0 ] || [ -z "$1" ]; then
    printf 'hello\n'
  else
    printf 'hello %s\n' "$*"
  fi
}
