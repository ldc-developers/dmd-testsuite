// https://issues.dlang.org/show_bug.cgi?id=19590
// REQUIRED_ARGS: -Icompilable/imports
module test19590;

import pkg16044;
import pkg16044.sub;
import pkgmod313.mod : bar; // excluded for now

static assert ([__traits(allMembers, test19590)] == [ "object", "pkg16044",
                                                    "pkg16044.sub"]);
