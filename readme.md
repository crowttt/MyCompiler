## Supported C subset

- Main function
- Integer data type
- Float data type
- Declarations
- Arithmetic expression
- If then & if else
- Comparison expression
- Printf function
- For loop
- While loop
- Comment /**/
- Increment (++, +=) and Decrement(--,-=)

## How to build

Just type `make` in command line, and we will get three .j files (test1.j  test2.j  test3.j )

```
make all
```

## Benchmarks

- Benchmark1: test1.c
  Variable declaration and arithmetic operation.

```
void main()
{
	int a;
	float b;
	char c;
	a = b+ 0;
}
```

- Benchmark2: test2.c
  Variable declaration, arithmetic operation, and conditional expression.

```
void main()
{
	int a;
	float b;

	a = b+1;
	b = a + 2 - 3 * 4 + 5;

	if(a>b) { a = b;}
}
```

- Benchmark: test3.c
  Testing for `for loop` and `while loop`

```
void main()
{
	int a;
	int i;
	float b;

	b = 5 ;
	a = b+1;

	while(a<10 || b>10)
	{
		a = a + 1 ;
	}
	if (a) 
		{ a = (2+4)-3; }
	else if(a<0)
		{a=3 ;}
	else
		a++;
	/* This line is comment */

	for(i=0;i<10;i++)
	{
		a = a -1 ;
	}
}

```

## How to run

```
java -jar jasmin.jar testx.j
java myResult
```
