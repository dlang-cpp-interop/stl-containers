import core.experimental.stdcpp.vector;

unittest
{
    vector!int vec = vector!int(5);
    vec[] = [1, 2, 3, 4, 5];

    assert(vec.size == 5);
    assert(vec.length == 5);
    assert(vec.empty == false);

    assert(sumOfElements_val(vec) == 45);
    assert(sumOfElements_ref(vec) == 15);

    vec.push_back(6);
    vec.push_back(7);
    vec ~= 8;
    assert(vec.size == 8 && vec[5 .. $] == [6, 7, 8]);

    vec.pop_back();
    assert(vec.size == 7 && vec.back == 7);

    vector!int vec2 = vector!int(Default);
    assert(vec2.size == 0);
    assert(vec2.length == 0);
    assert(vec2.empty == true);
    assert(vec2[] == []);
}


extern(C++):

// test the ABI for calls to C++
int sumOfElements_val(vector!int vec);
int sumOfElements_ref(ref const(vector!int) vec);

// test the ABI for calls from C++
int fromC_val(vector!int vec)
{
    assert(vec[] == [1, 2, 3, 4, 5]);
    assert(vec.front == 1);
    assert(vec.back == 5);

    int r;
    foreach (e; vec)
        r += e;

    assert(r == 15);
    return r;
}

int fromC_ref(ref const(vector!int) vec)
{
    int r;
    foreach (e; vec)
        r += e;
    return r;
}
