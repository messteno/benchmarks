#!/usr/bin/env dub
/+ dub.json:
{
	"name": "matmul_mir",
	"dependencies": {"mir": "~>0.16.0-beta2"},
	"dflags-ldc": ["-mcpu=native"],
}
+/
//dub build --build=release-nobounds --single matmul_mir.d --compiler=ldmd2

// Writen by Attractive Chaos; distributed under the MIT license

import core.stdc.stdio, std.conv, std.array;
import mir.ndslice;
import mir.glas;

alias Matrix = Slice!(2, double*);

Matrix[2] generate2(size_t n)
{
	auto len = n * n;
	double tmp = 1.0 / len;
	auto ab = uninitializedArray!(double[])(len * 2).sliced(2, n, n);
	auto a = ab[0];
	auto b = ab[1];
	size_t i;
	foreach (row; assumeSameStructure!("a", "b")(a, b))
	{
		sizediff_t u = i, v = i;
		foreach (x; row)
		{
			x.a = x.b = tmp * (u * v);
			u--;
			v++;
		}
		i++;
	}
	return [a, b];
}

Matrix mul(Matrix a, Matrix b)
{
	auto c = slice!double([a.length!0, b.length!1], 0);
	auto ctx = new GlasContext;
	ctx.gemm(c, 1.0, a, b);
	return c;
}

void main(in string[] args)
{
	size_t n = 100;
	if (args.length >= 2)
		n = to!size_t(args[1]) / 2 * 2;
	auto ab = generate2(n);
	auto x = mul(ab[0], ab[1]);
	printf("%.6f\n", x[n / 2, n / 2]);
}
