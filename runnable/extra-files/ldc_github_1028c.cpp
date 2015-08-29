// counterpart to ldc_github_1028.d
#if __cplusplus
extern "C" {
#endif

struct C4 { char c[4];};
struct C5 { char c[5];};
struct C6 { char c[6];};
struct C7 { char c[7];};
struct C8 { char c[8];};

struct C4 ctestc4()
{
    struct C4 x = {{'1','2','3','4'}};
    return x;
}

struct C5 ctestc5()
{
    struct C5 x = {{'1','2','3','4','5'}};
    return x;
}

struct C6 ctestc6()
{
    struct C6 x = {{'1','2','3','4','5','6'}};
    return x;
}

struct C7 ctestc7()
{
    struct C7 x = {{'1','2','3','4','5','6','7'}};
    return x;
}

struct C8 ctestc8()
{
    struct C8 x = {{'1','2','3','4','5','6','7','8'}};
    return x;
}
   
#if __cplusplus
}
#endif
