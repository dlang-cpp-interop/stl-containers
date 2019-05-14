/**
 * D header file for interaction with C++ std::vector.
 *
 * Copyright: Copyright (c) 2018 D Language Foundation
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Guillaume Chatelet
 *            Manu Evans
 * Source:    $(DRUNTIMESRC core/stdcpp/vector.d)
 */

module core.experimental.stdcpp.vector;

///////////////////////////////////////////////////////////////////////////////
// std::vector declaration.
//
// Current caveats :
// - missing noexcept
// - nothrow @trusted @nogc for most functions depend on knowledge
//   of T's construction/destruction/assignment semantics
///////////////////////////////////////////////////////////////////////////////

import core.experimental.stdcpp.allocator;

enum DefaultConstruct { value }

/// Constructor argument for default construction
enum Default = DefaultConstruct();

extern(C++, "std"):

extern(C++, class) struct vector(T, Alloc = allocator!T)
{
    static assert(!is(T == bool), "vector!bool not supported!");
extern(D):

    ///
    alias size_type = size_t;
    ///
    alias difference_type = ptrdiff_t;
    ///
    alias value_type = T;
    ///
    alias allocator_type = Alloc;
    ///
    alias pointer = T*;
    ///
    alias const_pointer = const(T)*;

    ///
    alias as_array this;

    /// MSVC allocates on default initialisation in debug, which can't be modelled by D `struct`
    @disable this();

    ///
    extern(C++) ~this();

    ///
    alias length = size;
    ///
    alias opDollar = length;
    ///
    extern(C++) size_type max_size() const pure nothrow @safe @nogc;
    ///
    bool empty() const nothrow @safe                                        { return size() == 0; }


    ///
    ref inout(T) front() inout nothrow @safe                                { return this[0]; }
    ///
    ref inout(T) back() inout nothrow @safe                                 { return this[$-1]; }


    // WIP...

    this(size_type count);
    this(size_type count, ref const(value_type) val);
    this(size_type count, ref const(value_type) val, ref const(allocator_type) al);
    this(ref const(vector) x);
//    this(iterator first, iterator last);
//    this(iterator first, iterator last, ref const(allocator_type) al = defaultAlloc);
//    this(const_iterator first, const_iterator last);
//    this(const_iterator first, const_iterator last, ref const(allocator_type) al = defaultAlloc);
//    extern(D) this(T[] arr)                                                     { this(arr.ptr, arr.ptr + arr.length); }
//    extern(D) this(T[] arr, ref const(allocator_type) al = defaultAlloc)        { this(arr.ptr, arr.ptr + arr.length); }
//    extern(D) this(const(T)[] arr)                                              { this(arr.ptr, arr.ptr + arr.length); }
//    extern(D) this(const(T)[] arr, ref const(allocator_type) al = defaultAlloc) { this(arr.ptr, arr.ptr + arr.length); }
    //~this();

    ref vector opAssign(ref const(vector) s);

    void clear() nothrow;
    void resize(size_type n);
    void resize(size_type n, T c);
    void reserve(size_type n = 0) @trusted @nogc;
    void shrink_to_fit();

    // Modifiers
    void push_back(ref const(T) _);
//    extern(D) void push_back(const(T) el) { push_back(el); } // forwards to ref version

    void pop_back();

    version (CppRuntime_Microsoft)
    {
        // perf will be greatly improved by inlining the primitive access functions
        extern(D) size_type size() const nothrow @safe @nogc                        { return _Get_data()._Mylast - _Get_data()._Myfirst; }
        extern(D) size_type capacity() const nothrow @safe @nogc                    { return _Get_data()._Myend - _Get_data()._Myfirst; }
        extern(D) bool empty() const nothrow @safe @nogc                            { return _Get_data()._Myfirst == _Get_data()._Mylast; }

        extern(D)        T* data() nothrow @safe @nogc                              { return _Get_data()._Myfirst; }
        extern(D) const(T)* data() const nothrow @safe @nogc                        { return _Get_data()._Myfirst; }

        extern(D) ref        T at(size_type i) @trusted @nogc                       { if (size() <= i) _Xran(); return _Get_data()._Myfirst[i]; }
        extern(D) ref const(T) at(size_type i) const @trusted @nogc                 { if (size() <= i) _Xran(); return _Get_data()._Myfirst[i]; }

        extern(D)        T[] as_array() nothrow @trusted @nogc                      { return _Get_data()._Myfirst[0 .. size()]; }
        extern(D) const(T)[] as_array() const nothrow @trusted @nogc                { return _Get_data()._Myfirst[0 .. size()]; }

        extern(D) this(DefaultConstruct)
        {
            static if (_ITERATOR_DEBUG_LEVEL > 0)
                _Base._Alloc_proxy();
        }

        extern(D) this(this)
        {
            // we meed a compatible postblit
            _Alloc_proxy();

            size_t len = size(); // the alloc len should probably keep a few in excess? (check the MS implementation)
            pointer newAlloc = _Getal().allocate(len);

            newAlloc[0 .. len] = _Get_data()._Myfirst[0 .. len];

            _Get_data()._Myfirst = newAlloc;
            _Get_data()._Mylast = newAlloc + len;
            _Get_data()._Myend = newAlloc + len;
        }

    private:
        import core.experimental.stdcpp.xutility : MSVCLinkDirectives, _Xlength_error, _Xout_of_range;

        // Make sure the object files wont link against mismatching objects
        mixin MSVCLinkDirectives!true;

        pragma(inline, true)
        {
            extern (D) ref _Base.Alloc _Getal() nothrow @safe @nogc                 { return _Base._Mypair._Myval1; }
            extern (D) ref inout(_Base.ValTy) _Get_data() inout nothrow @safe @nogc { return _Base._Mypair._Myval2; }
        }

        extern (D) void _Alloc_proxy() nothrow @nogc
        {
            static if (_ITERATOR_DEBUG_LEVEL > 0)
                _Base._Alloc_proxy();
        }

        extern(D) void _Xlen() const @trusted @nogc                                 { _Xlength_error("vector!T too long"); }
        extern(D) void _Xran() const @trusted @nogc                                 { _Xout_of_range("invalid vector!T subscript"); }

        _Vector_alloc!(_Vec_base_types!(T, Alloc)) _Base;

        // extern to functions that we are sure will be instantiated
//        void _Destroy(pointer _First, pointer _Last) nothrow @trusted @nogc;
//        size_type _Grow_to(size_type _Count) const nothrow @trusted @nogc;
//        void _Reallocate(size_type _Count) nothrow @trusted @nogc;
//        void _Reserve(size_type _Count) nothrow @trusted @nogc;
//        void _Tidy() nothrow @trusted @nogc;
    }
    else version (None)
    {
        extern(D) size_type size() const nothrow @safe @nogc                        { return 0; }
        extern(D) size_type capacity() const nothrow @safe @nogc                    { return 0; }
        extern(D) bool empty() const nothrow @safe @nogc                            { return true; }

        extern(D)        T* data() nothrow @safe @nogc                              { return null; }
        extern(D) const(T)* data() const nothrow @safe @nogc                        { return null; }

        extern(D) ref        T at(size_type i) @trusted @nogc                       { data()[0]; }
        extern(D) ref const(T) at(size_type i) const @trusted @nogc                 { data()[0]; }

        extern(D)        T[] as_array() nothrow @trusted @nogc                      { return null; }
        extern(D) const(T)[] as_array() const nothrow @trusted @nogc                { return null; }
    }
    else
    {
        static assert(false, "C++ runtime not supported");
    }

private:
    // HACK: because no rvalue->ref
    extern (D) __gshared static immutable allocator_type defaultAlloc;
}


// platform detail
version (CppRuntime_Microsoft)
{
    import core.experimental.stdcpp.xutility : _ITERATOR_DEBUG_LEVEL;

    extern (C++, struct) struct _Vec_base_types(_Ty, _Alloc0)
    {
        alias Ty = _Ty;
        alias Alloc = _Alloc0;
    }

    extern (C++, class) struct _Vector_alloc(_Alloc_types)
    {
        import core.experimental.stdcpp.xutility : _Compressed_pair;
    nothrow @safe @nogc:

        alias Ty = _Alloc_types.Ty;
        alias Alloc = _Alloc_types.Alloc;
        alias ValTy = _Vector_val!Ty;

        void _Orphan_all();

        static if (_ITERATOR_DEBUG_LEVEL > 0)
        {
            void _Alloc_proxy();
            void _Free_proxy();
        }

        _Compressed_pair!(Alloc, ValTy) _Mypair;
    }

    extern (C++, class) struct _Vector_val(T)
    {
        import core.experimental.stdcpp.xutility : _Container_base;
        import core.experimental.stdcpp.type_traits : is_empty;

        static if (!is_empty!_Container_base.value)
        {
            _Container_base _Base;
        }

        T* _Myfirst;   // pointer to beginning of array
        T* _Mylast;    // pointer to current end of sequence
        T* _Myend;     // pointer to end of array
    }
}
