import std.datetime;
void main() {
    auto r = cast(Duration[2])benchmark!({},{})(1);
}