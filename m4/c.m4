# This file is part of Autoconf.			-*- Autoconf -*-
# Programming languages support.
# Copyright (C) 2001-2012 Free Software Foundation, Inc.

# This file is part of Autoconf.  This program is free
# software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Under Section 7 of GPL version 3, you are granted additional
# permissions described in the Autoconf Configure Script Exception,
# version 3.0, as published by the Free Software Foundation.
#
# You should have received a copy of the GNU General Public License
# and a copy of the Autoconf Configure Script Exception along with
# this program; see the files COPYINGv3 and COPYING.EXCEPTION
# respectively.  If not, see <http://www.gnu.org/licenses/>.

# Written by David MacKenzie, with help from
# Akim Demaille, Paul Eggert,
# Franc,ois Pinard, Karl Berry, Richard Pixley, Ian Lance Taylor,
# Roland McGrath, Noah Friedman, david d zuhn, and many others.

#
# THIS FILE WERE COPIED FROM AUTOCONF REPOSITORY, COMMIT
# db36f6df60b6aa4e692be7163407ef83c1de1afb. IT WAS MODIFIED A LITTLE BIT IN
# ORDER NOT TO CONFLICT WITH MACRO NAMES AND TO DEFINE ONLY WHAT WE NEED.
#

# _AC_C_C99_TEST_HEADER
# ---------------------
# A C header suitable for testing for C99.
AC_DEFUN([_AC_C_C99_TEST_HEADER],
[[#include <stdarg.h>
#include <stdbool.h>
#include <stdlib.h>
#include <wchar.h>
#include <stdio.h>

// Check varargs macros.  These examples are taken from C99 6.10.3.5.
#define debug(...) fprintf (stderr, __VA_ARGS__)
#define showlist(...) puts (#__VA_ARGS__)
#define report(test,...) ((test) ? puts (#test) : printf (__VA_ARGS__))
static void
test_varargs_macros (void)
{
  int x = 1234;
  int y = 5678;
  debug ("Flag");
  debug ("X = %d\n", x);
  showlist (The first, second, and third items.);
  report (x>y, "x is %d but y is %d", x, y);
}

// Check long long types.
#define BIG64 18446744073709551615ull
#define BIG32 4294967295ul
#define BIG_OK (BIG64 / BIG32 == 4294967297ull && BIG64 % BIG32 == 0)
#if !BIG_OK
  your preprocessor is broken;
#endif
#if BIG_OK
#else
  your preprocessor is broken;
#endif
static long long int bignum = -9223372036854775807LL;
static unsigned long long int ubignum = BIG64;

struct incomplete_array
{
  int datasize;
  double data[];
};

struct named_init {
  int number;
  const wchar_t *name;
  double average;
};

typedef const char *ccp;

static inline int
test_restrict (ccp restrict text)
{
  // See if C++-style comments work.
  // Iterate through items via the restricted pointer.
  // Also check for declarations in for loops.
  for (unsigned int i = 0; *(text+i) != '\0'; ++i)
    continue;
  return 0;
}

// Check varargs and va_copy.
static void
test_varargs (const char *format, ...)
{
  va_list args;
  va_start (args, format);
  va_list args_copy;
  va_copy (args_copy, args);

  const char *str;
  int number;
  float fnumber;

  while (*format)
    {
      switch (*format++)
	{
	case 's': // string
	  str = va_arg (args_copy, const char *);
	  break;
	case 'd': // int
	  number = va_arg (args_copy, int);
	  break;
	case 'f': // float
	  fnumber = va_arg (args_copy, double);
	  break;
	default:
	  break;
	}
    }
  va_end (args_copy);
  va_end (args);
}]])# _AC_C_C99_TEST_HEADER

# _AC_C_C99_TEST_BODY
# -------------------
# A C body suitable for testing for C99, assuming the corresponding header.
AC_DEFUN([_AC_C_C99_TEST_BODY],
[[
  // Check bool.
  _Bool success = false;

  // Check restrict.
  if (test_restrict ("String literal") == 0)
    success = true;
  char *restrict newvar = "Another string";

  // Check varargs.
  test_varargs ("s, d' f .", "string", 65, 34.234);
  test_varargs_macros ();

  // Check flexible array members.
  struct incomplete_array *ia =
    malloc (sizeof (struct incomplete_array) + (sizeof (double) * 10));
  ia->datasize = 10;
  for (int i = 0; i < ia->datasize; ++i)
    ia->data[i] = i * 1.234;

  // Check named initializers.
  struct named_init ni = {
    .number = 34,
    .name = L"Test wide string",
    .average = 543.34343,
  };

  ni.number = 58;

  int dynamic_array[ni.number];
  dynamic_array[ni.number - 1] = 543;

  // work around unused variable warnings
  return (!success || bignum == 0LL || ubignum == 0uLL || newvar[0] == 'x'
	  || dynamic_array[ni.number - 1] != 543);
]])

# _AC_PROG_CC_C11 ([ACTION-IF-AVAILABLE], [ACTION-IF-UNAVAILABLE])
# ----------------------------------------------------------------
# If the C compiler is not in ISO C11 mode by default, try to add an
# option to output variable CC to make it so.  This macro tries
# various options that select ISO C11 on some system or another.  It
# considers the compiler to be in ISO C11 mode if it handles _Alignas,
# _Alignof, _Noreturn, _Static_assert, UTF-8 string literals,
# duplicate typedefs, and anonymous structures and unions.
AC_DEFUN([_AC_PROG_CC_C11],
[_AC_C_STD_TRY([c11],
[_AC_C_C99_TEST_HEADER[
// Check _Alignas.
char _Alignas (double) aligned_as_double;
char _Alignas (0) no_special_alignment;
extern char aligned_as_int;
char _Alignas (0) _Alignas (int) aligned_as_int;

// Check _Alignof.
enum
{
  int_alignment = _Alignof (int),
  int_array_alignment = _Alignof (int[100]),
  char_alignment = _Alignof (char)
};
_Static_assert (0 < -_Alignof (int), "_Alignof is signed");

// Check _Noreturn.
int _Noreturn does_not_return (void) { for (;;) continue; }

// Check _Static_assert.
struct test_static_assert
{
  int x;
  _Static_assert (sizeof (int) <= sizeof (long int),
                  "_Static_assert does not work in struct");
  long int y;
};

// Check UTF-8 literals.
#define u8 syntax error!
char const utf8_literal[] = u8"happens to be ASCII" "another string";

// Check duplicate typedefs.
typedef long *long_ptr;
typedef long int *long_ptr;
typedef long_ptr long_ptr;

// Anonymous structures and unions -- taken from C11 6.7.2.1 Example 1.
struct anonymous
{
  union {
    struct { int i; int j; };
    struct { int k; long int l; } w;
  };
  int m;
} v1;
]],
[_AC_C_C99_TEST_BODY[
  v1.i = 2;
  v1.w.k = 5;
  _Static_assert (&v1.i == &v1.w.k, "Anonymous union alignment botch");
]],
dnl Try
dnl GCC		-std=gnu11 (unused restrictive mode: -std=c11)
dnl with extended modes being tried first.
[[-std=gnu11]], [$1], [$2])[]dnl
])# _AC_PROG_CC_C11

# AX_PROG_CC_C11
# --------------
AC_DEFUN([AX_PROG_CC_C11],
[ AC_REQUIRE([AC_PROG_CC])dnl
  _AC_PROG_CC_C11
])


# AX_PROG_CC_STDC
# ---------------
AC_DEFUN([AX_PROG_CC_STDC],
[ AC_REQUIRE([AC_PROG_CC])dnl
  AS_CASE([$ac_cv_prog_cc_stdc],
    [no], [ac_cv_prog_cc_c11=no; ac_cv_prog_cc_c99=no; ac_cv_prog_cc_c89=no],
	  [_AC_PROG_CC_C11([ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c11],
	     [AC_PROG_CC_C99([ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c99],
		[AC_PROG_CC_C89([ac_cv_prog_cc_stdc=$ac_cv_prog_cc_c89],
				 [ac_cv_prog_cc_stdc=no])])])])
  AC_MSG_CHECKING([for $CC option to accept ISO Standard C])
  AC_CACHE_VAL([ac_cv_prog_cc_stdc], [])
  AS_CASE([$ac_cv_prog_cc_stdc],
    [no], [AC_MSG_RESULT([unsupported])],
    [''], [AC_MSG_RESULT([none needed])],
	  [AC_MSG_RESULT([$ac_cv_prog_cc_stdc])])
])
