# Intérprete en Ruby

Trabajo práctico: intérprete escrito en Ruby, siguiendo *Crafting Interpreters*.
No hace falta instalar Ruby: todo corre dentro de un contenedor.

## Estructura

```text
src/     código del intérprete (scanner, tokens)
spec/    tests con RSpec
```

## Primera vez

```bash
docker compose build
docker compose run --rm ruby bundle install
```

El `bundle install` se corre una sola vez: las gemas quedan en un volumen de
Docker y sobreviven entre contenedores.

## Uso

Entrar al contenedor:

```bash
docker compose run --rm ruby bash
```

Ya adentro:

```bash
bundle exec rake            # linter + tests
bundle exec rspec           # solo tests
bundle exec rubocop -a      # linter con autocorrección
```

## Gemas nuevas

Agregala al `Gemfile` y, dentro del contenedor:

```bash
bundle install
```

No hace falta reconstruir la imagen.