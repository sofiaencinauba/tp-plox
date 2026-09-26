Para ejecutar todos los archivos `.lox` una vez, desde la raíz del proyecto:

```bash
docker compose run --rm -T ruby ruby real-tests/run.rb
```

El runner muestra la salida de cada archivo y termina con código 1 ante un error
del proceso, salida en stderr, un mensaje ERROR o ausencia de mensajes OK.
Si todos pasan, muestra `Todo OK`. No realiza mediciones de rendimiento.

Para ejecutar un archivo individual dentro del contenedor, desde `/app`:

```bash
ruby src/main.rb real-tests/0-simple.lox
```
