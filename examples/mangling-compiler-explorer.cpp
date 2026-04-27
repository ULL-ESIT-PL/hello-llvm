int just_int;

extern int extern_int;

const int const_int = 1;

static int static_int = 2;

static const int static_const_int = 3;

class MyClass {
public:
    static int static_class_member;
    static const int static_const_class_member;
};

// If we don't use the global variables, the frontend does
// not emit code for most of them.
int use_variables() {
    &extern_int;
    &const_int;
    &static_int;
    &static_const_int;
    &MyClass::static_class_member;
    &MyClass::static_const_class_member;
}