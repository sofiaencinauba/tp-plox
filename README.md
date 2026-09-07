# Ruby con Docker

No hace falta instalar Ruby en tu máquina: Docker lo ejecuta dentro de un
contenedor.

Para ejecutar el ejemplo:

```bash
docker compose run --rm ruby
```

El comando debería imprimir:

```text
Hello, world!
```

El programa está en `hello.rb`. Para ejecutarlo explícitamente después de
editarlo:

```bash
docker compose run --rm ruby ruby hello.rb
```

Si agregás gemas al `Gemfile`, reconstruí la imagen para instalarlas:

```bash
docker compose build
```


