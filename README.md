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

## Explicacion del proyecto

### Scanner
El Scanner recibe el texto del "archivo fuente". Este se encarga de separar e identificar los distintos lexemas, transformandolos en los Tokens reconocibles. 
Para eso se apoya en la clase de Token y TokenType.

#### Token
Usamos modulos para diferenciar los distintos tipos de lexemas, y poder reconocerlos facilmente.
Existen los Single-Char, Double-Char, y las Keywords o palabras reservadas. Estos representan los simbolos validos de nuestro lenguaje.
Ademas se cuenta con la clase Token que guarda el TokenType, el valor del lexema y literal del token correspondiente. Tambien cuenta con la funcion de "inspect", que permite imprimir de una forma mas legible el Token correspondiente.

### Parser
El Parser se encarga de transformar la lista de Tokens en expresiones, analogo a como una serie de palabras se transforman en oraciones. Este tiene reglas de precedencia establecidas por las convenciones de Lox (Por ejemplo, en la matematica no es lo mismo 2 + 2 * 2 que (2 + 2) * 2). El Parser las respeta y recursivamente va creando las distintas expresiones en el orden adecuado, haciendo uso de un arbol binario de sintaxis abstracta (AST), que esta definido en el archino node.rb.
Tambien este se encarga de detectar secuencias invalidas de Tokens y arrojar el error correspondiente, como un parentesis faltante.

Precedencias de Lox:
```bash
expression     → equality ;
equality       → comparison ( ( "!=" | "==" ) comparison )* ;
comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
term           → factor ( ( "-" | "+" ) factor )* ;
factor         → unary ( ( "/" | "" ) unary ) ;
unary          → ( "!" | "-" ) unary | primary ;
primary        → NUMBER | STRING | "true" | "false" | "nil"
                 | "(" expression ")" ;
```

#### Node
Similar al Token, esta clase define las distintas expresiones aceptadas en el lenguaje con sus respectivos parametros (Por ejemplo, una comparacion tiene 2 operadores y 1 operando, mientras que un literal, que es la minima unidad de una expresion, tiene solo su valor).
Tambien

### ASTPrinter
ASTPrinter es una clase auxiliar utilizada para poder imprimir los nodos del arbol de una forma mas idiomatica, usado en el modo parser del interprete.

### Interprete
El interprete se encarga de leer y evaluar las expresiones, recorriendo el AST y ejecutando los nodos. Empieza de la raiz, llegando recursivamente hasta los nodos hoja que tienen valores literales, y luego sube evaluando las expresiones resultantes, siempre respetando el orden de precedencia que se establecio en la creacion del arbol.