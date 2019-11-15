# 线性表的链式存储结构(单链表)的 C 语言实现，再次学习数据结构的心路历程

## 一 导读

弹指一挥间，已经毕业好几年，由于所选工作领域，大学期间学习过的许多知识都没有在工作中实践过，很多知识已经生疏了。数据结构是学生时代的一门必修课，可能由于当时的学习风气，加之自己为了应付考试的情绪，学习完这门课之后根本没怎么独立思考、深入理解、消化吸收，导致这些基础知识理解不深刻。最终，毕业立即忘记这些知识。在经历很多项目之后，发现这些基础学科的理论和知识才是一个人往专业、深入层次迈进的基石。由于线性表的顺序存储结构比较简单，本文以单链表为例，重温本科阶段关于链表的基础知识。

## 二 基本概念

（1）单链表：当链表中的每个结点只含有一个指针域时，称为单链表。

![单链表](https://raw.githubusercontent.com/mrivandu/summary-of-work-and-study/master/image-hosting-service/%E5%8D%95%E9%93%BE%E8%A1%A8/%E5%8D%95%E9%93%BE%E8%A1%A8.jpg)

（2）头指针：如上图所示，头指针就是指向链表第一个节点的指针。若链表有头节点，则是指向头节点的指针。头指针具有标识作用，常用头指针标识链表的名字。无论链表是否为空，头指针均不为空，头指针是链表的必要元素。

（3）头结点：头结点是放在第一个元素结点之前的结点，其数据域一般无意义(有些情况下会存放链表的长度)。有了头结点后，对在第一个元素结点前插入结点和删除第一个结点，其操作与对其它结点的操作统一了。头节点不一定是链表的必要元素。

（4）首元结点：就是第一个元素的结点，它是头结点后边的第一个结点。

## 三 单链表的结构定义（C语言实现）

单链表的定义是实现这一数据结构的第一步。在定义单链表的过程中，使用了结构体的相关知识，正好借由此机会再次温习结构体相关的知识。

```c
typedef int ElemType;
struct ListNode
{
  ElemType data;
  struct ListNode *next;
};

typedef struct ListNode Node;
typedef struct ListNode *LinkList;

```

或者：

```c
typedef int ElemType;
struct ListNode
{
  ElemType data;
  struct ListNode *next;
}Node;

typedef struct ListNode *LinkList;
```

在有的数据结构C语言描述的书籍中，我们经常看到如下这种类型的定义：

```c
typedef int ElemType;
struct Node
{
  ElemType data;
  struct Node *next;
}Node;
typedef struct Node *LinkList;
```

这三种定义方式本质上都是一样的，第一种定义方式可能是最易于理解的，跟第二种定义方式实际上就是第一种定义方式的简化版。第三种定义方里面的几个 Node 有点让人眼花缭乱，不知道所以然。

结合前两种定义方式，我们来仔细分析一下第三中定义方式。首先，需要明确的是：在第三种定义方式中，最后一个 Node 跟前两个 Node 不是同一个对象，前两个 Node 是同一个对象。从前面两种定义方式可以看出，例子中定义了一个名为 ListNode 的结构体，在这个机构体内又存在一个指向自己的结构体，通过关键字 typedef 将这个结构体定义了两个新的类型名 Node 和 LinkList。在这两种定义方式中，结构体内的结构体只能使用结构体名来指向自身，不能使用新的类型名。```typedef struct ListNode Node;```这个定义

## 四 单链表的基本操作
