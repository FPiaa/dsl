# DSL passo a passo

Tenha em mente que a gramática ainda reconhece coisas estranhas
Mas elas serão tratadas nos outros passos da compilação para gerar erros ou warnings

# Introdução
Pode não receber nenhuma string
(vazio)


- valido `given G sobreviver ` equivalente a `given G sobreviver()`

- inválido `given`

# Usando beliefs e goals
- `G` para objetivo 
- `B` para belief
- `~` não tenho nenhuma crença ou goal sobre
- `-` não tenho a crença ou goal específico

```
given G sobreviver, 
  B posicao(X, Y), 
  ~B alienigenas,
  -B temperatura(50),
  B crenca_recebida_de_outro_agente from outroAgent 
```
O exemplo anterior pode ser traduzido para:
- Tenho um `goal` sobreviver()
- Tenho uma crença de posicao onde atribuo os valores a `X` e `Y`
- Não tenho nenhuma crença sobre alienigenas 
- Não tenho uma crença de temperatura = 50
- Crença que deve ser vinda de `outroAgent`

Também é possível filtrar especificamente a partir da cláusula `where`
```
  Given B bel1(x), G coisar(y, z) 
    where
      expressão1
```

Ou mais de uma expressão de filtro
```
  Given B bel1(x), G coisar(y, z) 
    where
      expressão1, expressão2, ... expressãoN
```
# Operadores
Os operadores a seguir estão disposto por ordem de prioridade, agrupados caso tenham a mesma prioridade. No caso de uma expressão com mesma prioridade serão associados da direita pra esquerda. Exemplo: `5 * 5 / 5` será equivalente a `(5 * 5) / 5`.

## Aritméticos
- Maior prioridade
  - `-` menos unário `-5` 
- Prioridade média
  - `*` Multiplicação
  - `/` Divisão
- Menor prioridade
  - `+` Soma
  - `-` Subtração

## Comparações
- Maior prioridade
  - `<` Menor que
  - `>` Maior que
  - `<=` Menor igual a
  - `>=` Maior igual a 
- Menor prioridade 
  - `=` Igual a
  - `!=` Diferente de

## Lógicos
- `and` Operador lógico E
- `or` Operador lógico ou
- `!` Operador lógico negação

# Tipos primitivos
- Inteiros `1`, `234`, 
- Strings: `'abc'`,
- Booleanos: `true`, `false`
- Tuplas: `(1, 'abc', false)`. As tuplas não podem ser aninhadas ou seja `((1,2,3), (4,5,6))` não é válido.

Não pretendo suportar número de ponto flutuante, porque comparações com eles são sempre horríveis.

# Exemplos Básicos
## Exemplo 1
```
given B posicao(x, y), B bel1(z) 
  where
    x > y and x < z or x * 10 < y * y and !(x < z)
```

Deixando os parenteses explicitos

```
given B posicao(x, y), B bel1(z) 
  where
    ((x > y) and (x < z)) or (((x * 10) < (y * y)) and !(x < z))
```

## Exemplo 2
Multiplas condições podem ser separadas por `,` é são equivalentes a `and`
```
...
where 
  X + 10 < 50 * 100 and Y >= and z = 12   

```
```
...
where 
  X + 10 < 50 * 100, 
  Y >= -30,
  z = 12  
```

## Exemplo 3
Considere por exemplo os dois trechos. Veja a diferença entre eles.
```
...
where 
  X + 10 < 50 * 100 and Y >= -30 or X = Y and X != 12   
```
e
```
...
    X + 10 < 50 * 100,
    Y >= -30 or X = Y,
    X != 12   
```


O primeiro equivale a 
```
...
where 
  (X + 10 < 50 * 100 and Y >= -30) or (X = Y and X != 12)   
```

O segundo equivale a 
```
...
where 
  X + 10 < 50 * 100 and (Y >= -30 or X = Y) and X != 12   
```

# Utilizando objetos de _python_
As `beliefs` e `goals` podem armazenar objetos arbitrários de _python_. A DSL permite modifica-los.

## Acesso a membros
Dado o código `given B bel(objeto)`, é possível fazer `objeto.campo`, `objeto.campo.campo` ou `objeto.metodo()`, igual é feito normalmente. 

```
given B posicao(x, y), B bel(objeto), B bel(indexavel)
  where
    objeto.campo = 2,
    objeto.metodo(x, y),
    indexavel[x]
```

## Funções
É possível utilizar qualquer função que já foi importada e podem ser chamadas igual em _python_.

Assuma que foi importada uma biblioteca `bib` da seguinte maneira `import bib` e uma função `f` de uma biblioteca `bib2` da seguinte maneira `from bib2 import f`.

```
given B posicao(x, y), B bel(objeto_de_bib), B bel1(lista)
  where
    bib.modulo1.modulo2.função(objeto_de_bib),
    f(x, y),
    len(lista) > 10
```

# Declarando variáveis nas condições
É possível definir variáveis novas dentro da cláusula `where`, funcionam da mesma maneira que
nas `beliefs` e `goals`.

A atribuição pode receber qualquer expressão

```
...
  where
    var := x * y - 30,
    var := f(x, y),
    var := 1 * 2 = x or z < 10
```

As declarações de variáveis podem ser feitas no meio de outras expressões

```
...
  where
  25 = (var := x.lista)[0]
```
Neste caso a variável `var` receberá o valor de `x.lista` e a comparação será feita de maneira igual a `25 = x.lista[0]`. 

Note que sem os parenteses do exemplo anterior as prioridades ficam igual a 

```
...
  where
    25 = (var := x.lista[0])
```
Neste caso a variável `var` recebe `x.lista[0]` e a comparação é feita como `25 = x.lista[0]`.

# Pattern match
As cláusulas `where` aceitam pattern match, além das expressões. É possível realizá-lo
em expressões, objetos e tuplas

Neles, é possível verificar se uma variável existente segue algum dos padrões definidos. São permitidos os seguintes `patterns`:

- `!= x` Elemento é diferente de `x` 
- `< x` Elemento é menor que `x`
- `> x` Elemento é maior que `x`
- `<= x` Elemento é menor ou igual a `x`
- `>= x` Elemento é maior ou igual a `x` 
- `x..y` O elemento está entre `x` e `y` *não inclusivo*
- `x..=y` O elemento está entre `x` e `y` *inclusivo* 
- `pattern1 and pattern2` Satisfaz o `pattern1` e `pattern2`  
- `x` O elemento é igual a `x`
- `func(x, y)` O elemento é igual o resultado de `func(x, y)`
- '_' Satisfaz qualquer coisa


Diferentes patterns podem ser separados por `|`

## Pattern match de expressões

```
...
  where
    funcao(x, y) is 
      > 2 
      | 5 
      | f1(1, 2) 
      | 1 .. 10 
      | 1 ..= 20
      | < 5 and 1..10
```

Traduzido como: O resultado da função `funcao(x,y)` é `maior que 2`, ou `igual a 5`, ou `igual a f1(1,2)`, ou `está entre 1 e 10 - 1`, ou `está entre 1 e 20`, ou `é menor que 5 e está entre 1 e 10 - 1`.

## Pattern match de listas
Suponha a situação de manipulação de uma lista específica, sendo um objeto de _python_.

```
given B posicao(x, y), B bel(lista) where
  lista is [x, *, y],
  lista is [x, 1, *, 2, y],
  lista is [1,2,3,4],
  lista is [x, *resto],
  lista is [l, *resto]
```
Os items podem ser traduzidos como:
1. O primeiro e o último elemento da lista devem ser iguais a `x` e `y`, respectivamente.
2. O primeiro elemento é igual a `x`, o segundo igual a `1`, o penúltimo igual a `2` e o último igual a `y`
3. A lista é igual a lista `[1,2,3,4]`
4. O primeiro elemento é igual a `x` e atribua todos os elementos exceto primeiro à `resto`.
5. Não deverá ser aceito, pois `l` não foi definido no escopo.

## Pattern match de tuplas

É possível fazer o pattern match em tuplas, funcionam de maneira similar ao pattern match de expressões

```
given B posicao(p), B tamanhoMapa(T)
  where
    (p.x, p.y) is
      (<= 0, _)
      | (>= T.largura, _)
      | (_, <= 0)
      | (_, >= T.altura)
```

Que pode representar uma checagem para ver se o agente está perto de uma parede no mapa.

Embora a gramática permita

```
given B bel(x, y)
  where
    (x, y) is (1, 2, 3, 4)
```

Este trecho de código é inválido e deverá ser rejeitado em passos futuros da compilação.