import core.experimental.stdcpp.vector;

unittest
{
    vector!int arr = vector!int(Default);
    arr[] = [1, 2, 3, 4, 5];

    assert(arr.size == 5);
    assert(arr.length == 5);
    assert(arr.max_size == 5);
    assert(arr.empty == false);

    assert(sumOfElements_val(arr) == 40);
    assert(sumOfElements_ref(arr) == 15);

    vector!int arr2 = vector!int(Default);
    assert(arr2.size == 0);
    assert(arr2.length == 0);
    assert(arr2.max_size == 0);
    assert(arr2.empty == true);
    assert(arr2[] == []);
}


extern(C++):

// test the ABI for calls to C++
int sumOfElements_val(vector!int arr);
int sumOfElements_ref(ref const(vector!int) arr);

// test the ABI for calls from C++
int fromC_val(vector!int arr)
{
    assert(arr[] == [1, 2, 3, 4, 5]);
    assert(arr.front == 1);
    assert(arr.back == 5);

    int r;
    foreach (e; arr)
        r += e;

    assert(r == 10);
    return r;
}

int fromC_ref(ref const(vector!int) arr)
{
    int r;
    foreach (e; arr)
        r += e;
    return r;
}
