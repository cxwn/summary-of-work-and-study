# 三种方式实现 Python 中的集合的交、并、补运算

## 一 背景

集合这个概念在我们高中阶段就有所了解，毕业已多年，我们一起回顾一下几个集合相关的基本概念吧？

>**集合**是指具有某种特定性质的具体的或抽象的对象汇总而成的集体。其中，构成集合的这些对象则称为该集合的元素。

>集合具有以下几种性质：
- **确定性**
给定一个集合，任给一个元素，该元素或者属于或者不属于该集合，二者必居其一，不允许有模棱两可的情况出现。
- **互异性**
一个集合中，任何两个元素都认为是不相同的，即每个元素只能出现一次。有时需要对同一元素出现多次的情形进行刻画，可以使用多重集，其中的元素允许出现多次。
- **无序性**
一个集合中，每个元素的地位都是相同的，元素之间是无序的。集合上可以定义序关系，定义了序关系后，元素之间就可以按照序关系排序。但就集合本身的特性而言，元素之间没有必然的序。

>交集定义：由属于A且属于B的相同元素组成的集合，记作A∩B（或B∩A），读作“A交B”（或“B交A”），即A∩B={x|x∈A,且x∈B}， 如右图所示。注意交集越交越少。若A包含B，则A∩B=B，A∪B=A。

>并集定义：由所有属于集合A或属于集合B的元素所组成的集合，记作A∪B（或B∪A），读作“A并B”（或“B并A”），即A∪B={x|x∈A,或x∈B}，注意并集越并越多，这与交集的情况正相反。

>补集
补集又可分为相对补集和绝对补集。
相对补集定义：由属于A而不属于B的元素组成的集合，称为B关于A的相对补集，记作A-B或A\B，即A-B={x|x∈A，且x∉B'}。
绝对补集定义：A关于全集合U的相对补集称作A的绝对补集，记作A'或∁u（A）或~A。有U'=Φ；Φ'=U。

在日常工作中，集合的交并补运算最为常见。例如：多个文件夹下的文件合并到一个文件夹、找出两个文件夹内名称相同、相异的文件。以以下两个列表来进行实践（lst_a 简称为集合 A，lst_b 简称为集合 B）：

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
```

## 二 实践过程

### 2.1 通过 Python 的推导式来实现

- 求集合 A 与集合 B 的交集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
lst_c = [x for x in lst_b if x in lst_a]
# lst_c = [x for x in lst_a if x in lst_b]
print(lst_c)
```

运行结果：

```python
[3, 4, 5]
```

- 求集合 A 与集合 B 的并集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
lst_c = lst_a + [x for x in lst_b if x not in lst_a]
print(lst_c)
```

运行结果：

```python
[1, 2, 3, 4, 5, 6, 7]
```

- 集合 A 关于集合 B 的补集(B - A)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
lst_c = [x for x in lst_b if x not in lst_a]
print(lst_c)
```

运行结果：

```python
[6, 7]
```

- 集合 B 关于集合 A 的补集(A - B)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
lst_c = [x for x in lst_a if x not in lst_b]
print(lst_c)
```

运行结果：

```python
[1, 2]
```

### 2.2 通过 Python 对集合的内置方法来实现

需要将列表转换为集合才能使用集合内置方法。

- 求集合 A 与集合 B 的交集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a.intersection(lst_b)
print(list(set_c))
```

运行结果：

```python
[3, 4, 5]
```

- 求集合 A 与集合 B 的并集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a.union(set_b)
print(list(set_c))
```

运行结果：

```python
[1, 2, 3, 4, 5, 6, 7]
```

- 集合 B 关于集合 A 的补集(A - B)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a.difference(set_b)
print(list(set_c))
```

运行结果：

```python
[1, 2]
```

- 集合 A 关于集合 B 的补集(B - A)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_b.difference(set_a)
print(list(set_c))
```

运行结果：

```python
[6, 7]
```

### 2.3 通过 Python 按位运算来实现

需要将列表转换为集合才能使用集合内置方法。

- 求集合 A 与集合 B 的交集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a & set_b
print(list(set_c))
```

运行结果：

```python
[3, 4, 5]
```

- 求集合 A 与集合 B 的并集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a | set_b
print(list(set_c))
```

运行结果：

```python
[1, 2, 3, 4, 5, 6, 7]
```

- 集合 B 关于集合 A 的补集(A - B)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_a - set_b
print(list(set_c))
```

运行结果：

```python
[1, 2]
```

- 集合 A 关于集合 B 的补集(B - A)

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_b - set_a
print(list(set_c))
```

运行结果：

```python
[6, 7]
```

- 集合 A 与集合 B 的全集除去交集

```python
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_b ^ set_a
print(list(set_c))
```

运行结果：

```python
[1, 2, 6, 7]
```

## 三 总结

3.1 在处理类似集合的数据时，需要注意集合与列表的相互转换，根据其特性，要会灵活使用；

3.2 集合的内置方法平时较少使用，但是使用起来还是比较方便的；

3.3 按位运算符在集合的运算中的应用简洁明了，建议平时稍加注意；

3.4 Python 中的推导式在列表、集合、字典等多种数据结构中均适用，使用恰当时往往能事半功倍；

3.5 由于列表在实际使用中较为常见，本文中的例子重点使用了列表来展示。
