/**
 * D header file for interaction with Microsoft C++ <xutility>
 *
 * Copyright: Copyright (c) 2018 D Language Foundation
 * License: Distributed under the
 *      $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0).
 *    (See accompanying file LICENSE)
 * Authors:   Manu Evans
 * Source:    $(DRUNTIMESRC core/stdcpp/xutility.d)
 */

module core.experimental.stdcpp.xutility;


enum CppStdRevision : uint
{
    cpp98 = 199711,
    cpp11 = 201103,
    cpp14 = 201402,
    cpp17 = 201703
}

enum __cplusplus = __traits(getTargetInfo, "cppStd");

// wrangle C++ features
enum __cpp_sized_deallocation = __cplusplus >= CppStdRevision.cpp14 ? 201309 : 0;
enum __cpp_aligned_new = __cplusplus >= CppStdRevision.cpp17 ? 201606 : 0;


extern(C++, "std"):

version (CppRuntime_Microsoft)
{
    import core.stdcpp.type_traits : is_empty;

    // Client code can mixin the set of MSVC linker directives
    mixin template MSVCLinkDirectives(bool failMismatch = false)
    {
        import core.stdcpp.xutility : __CXXLIB__, _ITERATOR_DEBUG_LEVEL;

        static if (__CXXLIB__ == "libcmtd")
        {
            pragma(lib, "libcpmtd");
            static if (failMismatch)
                pragma(linkerDirective, "/FAILIFMISMATCH:RuntimeLibrary=MTd_StaticDebug");
        }
        else static if (__CXXLIB__ == "msvcrtd")
        {
            pragma(lib, "msvcprtd");
            static if (failMismatch)
                pragma(linkerDirective, "/FAILIFMISMATCH:RuntimeLibrary=MDd_DynamicDebug");
        }
        else static if (__CXXLIB__ == "libcmt")
        {
            pragma(lib, "libcpmt");
            static if (failMismatch)
                pragma(linkerDirective, "/FAILIFMISMATCH:RuntimeLibrary=MT_StaticRelease");
        }
        else static if (__CXXLIB__ == "msvcrt")
        {
            pragma(lib, "msvcprt");
            static if (failMismatch)
                pragma(linkerDirective, "/FAILIFMISMATCH:RuntimeLibrary=MD_DynamicRelease");
        }
        static if (failMismatch)
            pragma(linkerDirective, "/FAILIFMISMATCH:_ITERATOR_DEBUG_LEVEL=" ~ ('0' + _ITERATOR_DEBUG_LEVEL));
    }

    // By specific user request
    version (_ITERATOR_DEBUG_LEVEL_0)
        enum _ITERATOR_DEBUG_LEVEL = 0;
    else version (_ITERATOR_DEBUG_LEVEL_1)
        enum _ITERATOR_DEBUG_LEVEL = 1;
    else version (_ITERATOR_DEBUG_LEVEL_2)
        enum _ITERATOR_DEBUG_LEVEL = 2;
    else
    {
        // Match the C Runtime
        static if (__CXXLIB__ == "libcmtd" || __CXXLIB__ == "msvcrtd")
            enum _ITERATOR_DEBUG_LEVEL = 2;
        else static if (__CXXLIB__ == "libcmt" || __CXXLIB__ == "msvcrt" || __CXXLIB__ == "msvcrt100")
            enum _ITERATOR_DEBUG_LEVEL = 0;
        else
        {
            static if (__CXXLIB__.length > 0)
                pragma(msg, "Unrecognised C++ runtime library '" ~ __CXXLIB__ ~ "'");

            // No runtime specified; as a best-guess, -release will produce code that matches the MSVC release CRT
            debug
                enum _ITERATOR_DEBUG_LEVEL = 2;
            else
                enum _ITERATOR_DEBUG_LEVEL = 0;
        }
    }

    // convenient alias for the C++ std library name
    enum __CXXLIB__ = __traits(getTargetInfo, "cppRuntimeLibrary");

package:
    struct _Container_base0 {}

    struct _Iterator_base12
    {
        _Container_proxy *_Myproxy;
        _Iterator_base12 *_Mynextiter;
    }
    struct _Container_proxy
    {
        const(_Container_base12)* _Mycont;
        _Iterator_base12* _Myfirstiter;
    }
    struct _Container_base12 { _Container_proxy* _Myproxy; }

    static if (_ITERATOR_DEBUG_LEVEL == 0)
        alias _Container_base = _Container_base0;
    else
        alias _Container_base = _Container_base12;

    extern (C++, class) struct _Compressed_pair(_Ty1, _Ty2, bool Ty1Empty = is_empty!_Ty1.value)
    {
    pragma (inline, true):
        enum _HasFirst = !Ty1Empty;

        ref inout(_Ty1) first() inout nothrow @safe @nogc { return _Myval1; }
        ref inout(_Ty2) second() inout nothrow @safe @nogc { return _Myval2; }

        static if (!Ty1Empty)
            _Ty1 _Myval1;
        else
        {
            @property ref inout(_Ty1) _Myval1() inout nothrow @trusted @nogc { return *_GetBase(); }
            private inout(_Ty1)* _GetBase() inout { return cast(inout(_Ty1)*)&this; }
        }
        _Ty2 _Myval2;
    }

    // these are all [[noreturn]]
    void _Xbad() nothrow @trusted @nogc;
    void _Xinvalid_argument(const(char)* message) nothrow @trusted @nogc;
    void _Xlength_error(const(char)* message) nothrow @trusted @nogc;
    void _Xout_of_range(const(char)* message) nothrow @trusted @nogc;
    void _Xoverflow_error(const(char)* message) nothrow @trusted @nogc;
    void _Xruntime_error(const(char)* message) nothrow @trusted @nogc;
}
else version (CppRuntime_Clang)
{
    import core.stdcpp.type_traits : is_empty;

    extern (C++, class) struct __compressed_pair(_T1, _T2)
    {
    pragma (inline, true):
        enum Ty1Empty = is_empty!_T1.value;
        enum Ty2Empty = is_empty!_T2.value;

        ref inout(_T1) first() inout nothrow @safe @nogc { return __value1_; }
        ref inout(_T2) second() inout nothrow @safe @nogc { return __value2_; }

    private:
        private inout(_T1)* __get_base1() inout { return cast(inout(_T1)*)&this; }
        private inout(_T2)* __get_base2() inout { return cast(inout(_T2)*)&__get_base1()[Ty1Empty ? 0 : 1]; }

        static if (!Ty1Empty)
            _T1 __value1_;
        else
            @property ref inout(_T1) __value1_() inout nothrow @trusted @nogc { return *__get_base1(); }
        static if (!Ty2Empty)
            _T2 __value2_;
        else
            @property ref inout(_T2) __value2_() inout nothrow @trusted @nogc { return *__get_base2(); }
    }
}
